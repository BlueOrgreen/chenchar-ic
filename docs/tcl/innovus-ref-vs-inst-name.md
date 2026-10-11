---
title: dbGet 里 cell 名与 instance 名的区别
description: cell 名是"图纸"（库里 master 名，定义版图/功能/面积/timing，同名唯一），instance 名是"门牌号"（每个摆下去的 cell 的唯一编号）；top.insts.cell.name 匹配 cell 名配 -p2 跳回 inst，top.insts.name / get_cells 匹配 inst 名；-p/-p1/-p2 = 从匹配字段往上跳 N 层拿对象，cell.name 链上 -p1 是 libCell、-p2 才是 inst；box_llx/lly/urx/ury = bounding box 四角坐标（box_url 不存在，是 ury 的手滑）；ECO 换 cell 换的是 cell、inst 名不变——所以 inst 叫 ENDCAP_TAP_PD_PSO_1 而 cell 带 VPP_VSS
date: 2026-09-28
---

# dbGet 里 cell 名与 instance 名的区别

> 日期：2026-09-28  
> 工具：Innovus  
> 场景：按名字选 cell / 数量时，先分清匹配的是哪个名字

## Q：cell 名和 instance 名的区别是什么

**A：cell 名是"图纸"，instance 名是"门牌号"。**

- **cell 名（reference / master 名）**：库里 cell 的名字，比如 `TIELBWP16P90CPD`。定义版图、功能、面积、timing，库里同名只有一种
- **instance 名**：每个**实际摆下去**的 cell 的唯一编号。同一个 cell 可以摆 18299 次，每次起不同的名字区分

对应 Verilog：

```verilog
TIEHBWP16P90CPD  u_tie_0  (.X(x1));   // cell 名 = TIEHBWP16P90CPD，instance 名 = u_tie_0
```

## dbGet 对应

```tcl
dbGet top.insts.name         ;# inst 名：谁、在哪（带层级全路径，如 u_vcpu/ENDCAP_TAP_PD_PSO_1）
dbGet top.insts.cell.name    ;# cell 名：是什么（库里 master 名）
select_obj [dbGet top.insts.cell.subClass block -p2]    ;# 选中所有的 block
dbGet head.lib
dbGet head.libCells.name *CK*   ;# 从全部 lib cell 里捞出 cts用来长tree的 clock inverter、clock buffer、clock gating cell
```

## box：查选中 cell 的位置和大小

`dbGet selected.box_lly`、`dbGet selected.box_url` 分别是什么意思？

`box` 是对象的 **bounding box（外接矩形）**，由四个角坐标组成：

| 字段 | 含义 |
|------|------|
| `box_llx` | **l**ower-**l**eft **x** —— 左下角 x 坐标 |
| `box_lly` | **l**ower-**l**eft **y** —— 左下角 y 坐标（cell 底边的位置） |
| `box_urx` | **u**pper-**r**ight **x** —— 右上角 x 坐标 |
| `box_ury` | **u**pper-**r**ight **y** —— 右上角 y 坐标 |

> 没有 `box_url` 这个字段——它是 `box_ury` 的常见手滑，敲了会报错。

```tcl
dbGet selected.box                  ;# 一口气出四个值 {llx lly urx ury}
dbGet selected.box_lly              ;# 左下角 y：cell 底边的位置
expr [dbGet selected.box_urx] - [dbGet selected.box_llx]   ;# 宽
expr [dbGet selected.box_ury] - [dbGet selected.box_lly]   ;# 高
```

案例里挑"x < 1000 的 cell"用的 `dbGet $i.box_llx` 就是左下角 x。

## -p / -p1 / -p2 的区别（各自拿到什么对象）

**`-pN`：从匹配到的字段往上跳 N 层，返回那一层的对象。跳到哪层由你写的查询链决定，不是固定的。**

以 `top.insts.cell.name` 这条链为例：

```
inst ──cell──> libCell ──name──> "XXX_VPP_VSS_yyy"（字符串）
```

```tcl
dbGet top.insts.cell.name *VPP_VSS*        ;# 不带 -p：name 字符串列表，只能看，select_obj 不认
dbGet top.insts.cell.name *VPP_VSS* -p     ;# -p 等价 -p1：跳 1 层 → libCell 对象（库里 master）
dbGet top.insts.cell.name *VPP_VSS* -p2    ;# 跳 2 层 → inst 对象（设计里摆的 cell，可 select_obj）
```

- **不带 -p**：拿到的是字段值（字符串），用来"看"
- **-p / -p1**：跳一层，拿到**拥有这个字段的对象**——链不同，对象就不同
- **-p2**：再跳一层。链写到 `.cell.name` 时，-p2 才是 inst

所以想选中摆放的 cell 时，**层数跟着链走**：

```tcl
select_obj [dbGet top.insts.name      *VPP_VSS* -p ]  ;# 链只到 inst 的 name，-p 一步就是 inst
select_obj [dbGet top.insts.cell.name *VPP_VSS* -p2]  ;# 链绕到 cell 的 name，要跳两层才回 inst
```

验证各自拿到什么（打印对比）：

```tcl
set libcells [dbGet top.insts.cell.name *VPP_VSS* -p1]
dbGet [lindex $libcells 0].name        ;# XXX_VPP_VSS_yyy —— libCell 的名字
dbGet [lindex $libcells 0].subClass    ;# core / block —— master 的类型

set insts [dbGet top.insts.cell.name *VPP_VSS* -p2]
dbGet [lindex $insts 0].name           ;# u_vcpu/ENDCAP_TAP_PD_PSO_1 —— inst 的名字
dbGet [lindex $insts 0].cell.name      ;# XXX_VPP_VSS_yyy —— 又绕回 cell 名
```

同款套路：选 Macro 用的 `dbGet top.insts.cell.subClass block -p2`，链是 inst→cell→subClass，一样要 -p2（见 [选中 Macro 并导出 DEF](./innovus-select-macros.md)）。

另外：`-p` 系列没匹配到返回 `0x0`，脚本里常用来判空。

## 案例：按 cell 名选中带 VPP_VSS 的 cell

```tcl
# cell.name 上通配匹配，-p2 从 name 跳两级回到 inst
set vpp [dbGet top.insts.cell.name *VPP_VSS* -p2]

# 同一个 inst 的两个名字（注意区分）
dbGet [lindex $vpp 0].name         ;# inst 名：u_vcpu/ENDCAP_TAP_PD_PSO_1
dbGet [lindex $vpp 0].cell.name    ;# cell 名：带 VPP_VSS 的

# 数量 & 选中其中一个（下标从 0 开始）
llength $vpp
deselectAll
select_obj [lindex $vpp 0]
zoomToSelection
```

按 cell 名分档统计个数：

```tcl
foreach c [lsort -unique [dbGet top.insts.cell.name *VPP_VSS*]] {
    puts "$c : [llength [dbGet top.insts.cell.name $c -p2]]"
}
```

若要按 **instance 名**匹配（不是 cell 名）：

```tcl
select_obj [dbGet top.insts.name *VPP_VSS* -p]
select_obj [get_cells *VPP_VSS*]   ;# get_cells 匹配的也是 inst 名
```

## 两条实用推论

1. **ECO 换 cell（swap / upsize）换的是 cell，instance 名不变**——所以会出现 inst 叫 `ENDCAP_TAP_PD_PSO_1`、cell 却带 `VPP_VSS`：inst 名是插入时起的，后来 cell 换了别的版本
2. timing / DRC 报告里报的是 **instance 名**；查库、`get_lib_cells` 用 **cell 名**

## 相关笔记

- [选中 Macro 并导出 DEF](./innovus-select-macros.md) —— 同款 `dbGet ... -p2` 选中套路
- [T12nm · Tie Cell](../experience/t12nm/tie-cell.md) —— `select_obj [dbGet top.insts.cell.name TIE* -p2]`
