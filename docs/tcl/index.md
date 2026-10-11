---
title: TCL 脚本
description: chenchar-ic TCL 脚本收集区
---

# TCL 脚本

本栏目用于收集数字 IC / EDA 流程里常用的 **Tcl** 片段与小工具脚本，方便检索复用。

新增脚本时，建议在 `docs/tcl/` 下新建一页 Markdown，写清：场景、工具环境、用法，并把脚本放在代码块中。

## 脚本列表

- [脚本页模板](./template.md)
- [示例：统计 cell 数量](./report-cells.md)
- [PT DMSA Hold ECO 脚本](./pt-dmsa-hold-eco.md)
- [Innovus CCOpt CTS 脚本](./innovus-ccopt-cts.md)
- [set_ccopt_property target_skew](./ccopt-target-skew.md)
- [PT 查看功耗](./pt-report-power.md)
- [Innovus 估算 Chip 面积](./innovus-estimate-area.md)
- [Innovus 01 Import Design](./innovus-01-import-design.md)
- [Innovus 02 Floorplan](./innovus-02-floorplan.md)
- [Innovus 03 Powerplan](./innovus-03-powerplan.md)
- [Power Switch Stapling Stripe（power_stape_pso）](./power-stape-pso.md)
- [M10 Power Stripe（addStripe M10）](./m10-power-stripe.md)
- [globalNetConnect 覆盖 VDD 逻辑连接](./globalnetconnect-vdd-override.md)
- [PowerVia 打上与删除（dual_rail_via1）](./power-via-add-delete.md)
- [VIA1 插入（PG VIA1 Insertion）](./via1-insert.md)
- [PT 入口：source run_pt.tcl](./pt-source-run-pt.md)
- [Innovus PG Special（Memory M5）](./innovus-pg-special.md)
- [选中 Macro 并导出 DEF](./innovus-select-macros.md)
- [Innovus 复制走线并改层改线宽](./innovus-edit-duplicate-change-layer.md)
- [Via Pillar 下方不摆放特殊 cell](./via-pillar-pg-keepout.md)
- [Innovus Place Padding（cell / instance / module）](./innovus-place-padding.md)
- [dbGet 里 ref 名与 instance 名的区别](./innovus-ref-vs-inst-name.md)
- [Path Group 分组与权重（group_path / setPathGroupOptions）](./path-group-weight.md)
- [Create Region 区域约束（createInstGroup / createRegion）](./create-region.md)
- [统计 VT Cell 比例（RVT / LVT）](./vt-cell-ratio.md)
- [high_opt.tcl（High Effort Opt + LVT）](./high-opt.md)
- [Clock Tree Debug 高频命令](./ccopt-clock-tree-debug.md)
- [CTS 涉及脚本](./cts-related-scripts.md)
- [insert_port_buffer（端口插 Buffer）](./insert-port-buffer.md)
- [Place 后检查 Input Floating](./check/input-floating.md)
- [检查 Always-on Isolation 前是否插 Buf](./check/iso-buf-always-on.md)
- [报告 Path 逻辑深度](./timing_report/report-logic-depth.md)
- [report_clocks 查看 Design 频率](./timing_report/report-clocks.md)
