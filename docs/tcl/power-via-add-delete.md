---
title: PowerVia 打上与删除（dual_rail_via1）
description: editPowerVia -top_layer M2 -bottom_layer M1 -add_vias 1 -uda dual_rail_via1 打上并命名 dual-rail PowerVia；editDelete -subclass dual_rail_via1 按名删除这一类 via；用于 Calibre 验证前打、验证后删
date: 2026-09-24
---

# PowerVia 打上与删除（dual_rail_via1）

> 日期：2026-09-24  
> 来源：截图识别整理（picture-tcl，2 张截图）  
> 阶段：Powerplan（M1/M2 dual-rail PowerVia：打上并命名 / 按名删除）

## 使用场景

去 **Calibre** 验证的时候，先给 M2 和 M1 之间打上这类**带名字的通孔**（图 1：`editPowerVia ... -uda dual_rail_via1`）；验证完后再把这类 via 删除（图 2：`editDelete -subclass dual_rail_via1`）。

## 图 1：打上 PowerVia 并命名

```text
editPowerVia -top_layer M2 -bottom_layer M1 -orthogonal_only 0 -add_vias 1 -split_long_via {0.135 0.111 0.042} -skip_via_on_pin {pad block cover standardcell physicalpin} -uda dual_rail_?ial（截断）
```

## 图 2：删除这一类 via

```text
innovus 58> ##editDelete -subclass dual_rail_via1
```

## 完整脚本

```tcl
# 图 1：打上 PowerVia 并命名（-uda dual_rail_via1）
editPowerVia -top_layer M2 -bottom_layer M1 -orthogonal_only 0 -add_vias 1 -split_long_via {0.135 0.111 0.042} -skip_via_on_pin {pad block cover standardcell physicalpin} -uda dual_rail_via1

# 图 2：删除这一类 via
editDelete -subclass dual_rail_via1
```

同目录可直接 source 的版本：[power-via-add-delete.tcl](/tcl/power-via-add-delete.tcl)

**转录注记（存疑处均照录未改）：**

1. 图 1（1584×56）为单行长命令，未见行首提示符；**右侧截断**：`-uda` 的值可见部分为 `dual_rail_?ial`（`?` 为不确定字符），完整值 `dual_rail_via1` 由图 2 `editDelete -subclass dual_rail_via1` 佐证拼合，**存疑**；`-uda` 之后是否还有其他选项未知。
2. 图 2 行首提示符 `innovus 58>`；命令前的 `##` 照录，疑为注释符或识别误差，完整脚本中去掉 `##` 以保证可执行；其后另有一行空提示符 `innovus 59>`，未收录。
3. 打 via 时用 `-uda`（user-defined attribute）给这一类 via 命名，删除时 `editDelete -subclass` 按同一个名字删——先命名、后按名删，是这一对命令的配合方式。

## 原图

图 1（打上并命名）：

![PowerVia 打上并命名](./images/power-via-add.png)

图 2（删除这一类 via）：

![删除这一类 via](./images/power-via-delete.png)

## 相关笔记

- [TCL 脚本](./index.md)
- [Innovus 03 Powerplan](./innovus-03-powerplan.md)
- [Power Switch Stapling Stripe（power_stape_pso）](./power-stape-pso.md)
- [M10 Power Stripe（addStripe M10）](./m10-power-stripe.md)
- [T12nm · Powerplan 做什么](../experience/t12nm/powerplan.md)
