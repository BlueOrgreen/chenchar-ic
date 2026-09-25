---
title: VIA1 插入（PG VIA1 Insertion）
description: setViaGenMode 配置 VIAGEN12 → route block（RB_FOR_FINISH_RAIL）限定 M1 rail 范围 → editPowerVia M2–M1 插 VIA1 → 删 route block 与 cross via → verify_drc 的完整流程脚本
date: 2026-09-24
---

# VIA1 插入（PG VIA1 Insertion）

> 日期：2026-09-24  
> 来源：截图识别整理（picture-tcl，4 张截图）  
> 阶段：Powerplan（M1/M2 dual-rail 之间插 VIA1）

## 流程一览

1. `setViaGenMode` 配置 via 生成规则（VIAGEN12）；
2. 收集 VDD/VSS 在 M1 的 rail shape，在 rail 范围**外**建 route block（`RB_FOR_FINISH_RAIL`，M1/VIA1/M2）；
3. `editPowerVia` 在 M2–M1 之间插 VIA1——因为有 route block 挡住，via 只落在 rail 范围内；
4. 删 route block、删 VIAGEN12 这类 cross via；
5. `verify_drc`。

## 图 1：脚本开头（开关与 setViaGenMode）

```text
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
```

## 图 2：收集 M1 rail shape 并建 route block

```text
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
    set rb_rects [dbShape $bdry_boxes ANDNOT $boxes -output rect]（截断）
```

## 图 3：插 VIA1 + 删 route block + 删 cross via

```text
    if {$if_create_poly} {
      set rb_rects [dbShape $bdry_boxes ANDNOT $boxes -output polygon]
      createRouteBlk -layer [list M1 VIA1 M2] -cutLayer VIA1 -polygon [lindex $rb_rects 0] -name $rb_name_prefix -pgnetonly
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
```

## 图 4：收尾（verify_drc）

```text
        editDelete -selected
        deselectAll
    }
}

set_verify_drc_mode -check_implant false
verify_drc -limit 0 -check_only regular
#saveDesign ./db/${stageName}.enc
```

（图 4 顶部另有一行被截断的中文提示文字、右侧水印文字不可辨，未转录。）

## 完整脚本

四图首尾相接、重叠段去重后的可 `source` 版本（拼接方式见下方注记 1）：

```tcl
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
```

同目录可直接 source 的版本：[via1-insert.tcl](/tcl/via1-insert.tcl)

**转录注记（存疑处均照录未改）：**

1. 四图按 图 1→图 4 顺序首尾相接；**图 2 末行（右侧截断）与图 3 开头整段重叠**（`if {$if_create_poly}` 一段两图都拍到），完整脚本中已去重，`else` 分支续接图 3 内容（该段缩进按图 2 层级）。各截图视图缩进层级不一，拼接后保留各图原样缩进。
2. 重叠段一处拼写不同：图 2 `-pnetonly` / 图 3 `-pgnetonly`，均照录，疑同一选项（识别差异，**存疑**，原图备查）。
3. 图 1 注释行中下划线疑被识别为空格（`respect_signal routes`、`keep existing via` 等），照录未改；`## set stageName VIAIInsert` 的 `VIAIInsert` 疑为 `VIA1Insert`（1/I 易混），**存疑**。
4. `foreach net_name VDD {` 疑缺 `$`/`{}`（照录）；`top.fplan.boxes` 与 `top.fPlan.rBlkgs` 大小写不一致（照录）；`dbGet ... $cross_via_name  -p2` 中双空格照录。
5. 生效的 `editPowerVia ...` 与 [PowerVia 打上与删除](./power-via-add-delete.md) 图 1 为同款命令——该页截图末尾多 `-uda dual_rail_via1`（命名变体，Calibre 验证后按名删）；本脚本则用 route block 限定插入范围，两种用法互补。

## 原图

图 1（脚本开头）：

![VIA1 插入 图 1](./images/via1-insert-1.png)

图 2（收集 rail shape 建 route block）：

![VIA1 插入 图 2](./images/via1-insert-2.png)

图 3（插 VIA1 与删除）：

![VIA1 插入 图 3](./images/via1-insert-3.png)

图 4（收尾 verify_drc）：

![VIA1 插入 图 4](./images/via1-insert-4.png)

## 相关笔记

- [TCL 脚本](./index.md)
- [PowerVia 打上与删除（dual_rail_via1）](./power-via-add-delete.md)
- [Power Switch Stapling Stripe（power_stape_pso）](./power-stape-pso.md)
- [Innovus 03 Powerplan](./innovus-03-powerplan.md)
- [T12nm · Powerplan 做什么](../experience/t12nm/powerplan.md)
