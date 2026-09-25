# via1-insert.tcl
# 日期：2026-09-24
# 来源：截图识别整理（picture-tcl，4 张截图，
#       原图 docs/tcl/images/via1-insert-1.png ~ via1-insert-4.png）
# 工具：Innovus
#
# 作用：PG VIA1 插入完整流程——
#   1) setViaGenMode 配置 via 生成规则（VIAGEN12）；
#   2) 收集 VDD/VSS 在 M1 的 rail shape，在 rail 范围外建 route block
#      （RB_FOR_FINISH_RAIL，M1/VIA1/M2）；
#   3) editPowerVia 在 M2–M1 之间插 VIA1（只落在 rail 内）；
#   4) 删 route block、删 VIAGEN12 这类 cross via；
#   5) verify_drc。
#
# 转录注记（详见同目录 via1-insert.md）：
# - 四图按顺序首尾相接；图 2 末行与图 3 开头整段重叠，拼接时去重，
#   else 分支续接图 3 内容（按图 2 缩进层级）。
# - 重叠段一处拼写不同：图 2 -pnetonly / 图 3 -pgnetonly，照录未改（存疑）。
# - 注释行中下划线疑被识别为空格（respect_signal routes 等）、
#   VIAIInsert 疑为 VIA1Insert、foreach net_name VDD 疑缺 $/{}/，
#   top.fplan/top.fPlan 大小写不一致——均照录，未改。
# - 生效的 editPowerVia 与 power-via-add-delete 页同款命令
#   （该页截图末尾多 -uda dual_rail_via1 命名变体，用于 Calibre 验证后按名删）。

global DVA TVAR FVAR
###########################################
### PG VIAL Insertion
###########################################
set if_fix_via_drc 0
set if_within_rail 1
set if_delete_cross_via 1

# VIAGEN12 P48 2
set cross_via_names [list \
 VIAGEN12 \
]

set rb_name_prefix RB_FOR_FINISH_RAIL

setViaGenMode -reset
## setViaGenMode -extend_out_wire_end false
## setViaGenMode -optimize_cross_via_true
## setViaGenMode -full_cut_via_only true
## set stageName VIAIInsert
setViaGenMode -ignore_DRC false
setViaGenMode -allow_wire_shape_change 0
## setViaGenMode -preferred_vias_only_keep
setViaGenMode -respect_signal_routes 2 -respect_stdcell_geometry 1 -viarule preference VIAGEN12 -keep_existing_via 1 -disable_via_merging 1
##setViaGenMode -respect_signal routes 2 -respect stdcell geometry 1 -viarule preference VIAGEN12 P48 -keep existing via 1 -disable via merging 1
### editPowerVia -top_layer M2 -bottom_layer M1 -orthogonal_only 0 -add_vias 1 -split_long_via {0.135 0.111 0.042}
###
if {$if_within_rail} {
 set if_create_rail_rb 0
 ## setViaGenMode -area_only true
 set net_names [list ]
 foreach net_name VDD {
 lappend net_names $net_name
 }
 foreach net_name VSS {
 lappend net_names $net_name
 }
 set net_names [lsort -u $net_names]
set layer_names [list M1]
set shape_type stripe
set all_shapes [list]
foreach layer_name $layer_names {
  foreach net_name $net_names {
    set net [dbGet top.nets.name $net_name -p]
    set shapes [dbGet $net.wires.shape $shape_type -p]
    set shapes [dbGet $shapes.layer.name $layer_name -p2]
    foreach shape $shapes {
      lappend all_shapes $shape
    }
  }
}
set boxes [list]
set ext 0.001
foreach shape $all_shapes {
  if {$shape == 0x0} {
    continue
  }
  set box [dbGet $shape.box]
  set box [dbShape -output rect $box SIZE $ext]
  set box [lindex $box 0]
  if {$box == 0x0} {
    continue
  }
  lappend boxes $box
}

set bdry_boxes [dbGet top.fplan.boxes]
set if_create_poly 0
if {[llength $boxes] && $bdry_boxes != 0x0} {
  ## set rb_rects [dbShape $bdry_boxes ANDNOT $boxes -output rect]
  set rbs [dbGet top.fPlan.rBlkgs.name ${rb_name_prefix}* -p]
  if {$rbs != 0x0} {
    deleteRouteBlk -name ${rb_name_prefix}*
  }
  if {$if_create_poly} {
    set rb_rects [dbShape $bdry_boxes ANDNOT $boxes -output polygon]
    createRouteBlk -layer [list M1 VIA1 M2] -cutLayer VIA1 -polygon [lindex $rb_rects 0] -name $rb_name_prefix -pnetonly
  } else {
    set rb_rects [dbShape $bdry_boxes ANDNOT $boxes -output rect]
  set i 0
  foreach rb_rect $rb_rects {
    incr i
    createRouteBlk -layer [list M1 VIA1 M2] -cutLayer VIA1 -box $rb_rect -name ${rb_name_prefix}_${i} -pgnetonly
  }
 }
}

 #tproc_msg -info "Invoke via1 ..."
 ## editPowerVia -top_layer M2 -bottom_layer M1 -delete_vias true
 editPowerVia -top_layer M2 -bottom_layer M1 -orthogonal_only 0 -add_vias 1 -split_long_via {0.135 0.111 0.042} -skip_via_on_pin {pad block cover standardcell physicalpin}

 if {$if_fix_via_drc} {
   fixVia -cutSpacing -shape FOLLOWPIN -layer {VIA1}
 }

 if {$if_within_rail} {
   set rbs [dbGet top.fPlan.rBlkgs.name ${rb_name_prefix}* -p]
   if {$rbs != 0x0} {
     deleteRouteBlk -name ${rb_name_prefix}*
   }
 }


 if {$if_delete_cross_via} {
   set vias [list]
   foreach cross_via_name $cross_via_names {
     set tmp_vias [dbGet -e top.nets.sVias.via.name $cross_via_name  -p2]
     if {$tmp_vias == 0x0} {
       continue
     }
     foreach tmp_via $tmp_vias {
       lappend vias $tmp_via
     }
   }
 }
 if {[llength $vias]} {
   #tproc_msg -warn "Remove [llength $vias] cross vias ..."
   deselectAll
   select_obj $vias
        editDelete -selected
        deselectAll
    }
}
set_verify_drc_mode -check_implant false
verify_drc -limit 0 -check_only regular
#saveDesign ./db/${stageName}.enc
