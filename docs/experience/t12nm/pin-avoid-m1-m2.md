---
title: Pin 不要出在 M1–M2
description: T12nm FinFET 下 M1/M2 有 double patterning，die pin 改出到更高金属层
date: 2026-09-20
---

# Pin 不要出在 M1–M2

> 工艺：T12nm（FinFET）  
> 阶段：Floorplan / Pin assignment  
> 类型：物理约束 / 经验口径

## 口径

**M1–M2 有 double patterning（双重曝光），不要把 die Pin 出在 M1–M2；改到更高金属层（本项目实践：input → M5，output → M7）。**

## 本项目做法（摘录）

```tcl
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 3 -layer 5 -spreadType start -spacing 0.16 -start 499.95 499.968 -pin [get_object_name [all_inputs ]]
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 3 -layer 7 -spreadType start -spacing 0.16 -start 499.95 499.968 -pin [get_object_name [all_outputs ]]
setPinAssignMode -pinEditInBatch false
```

| 端口 | 出 Pin 层 |
|------|-----------|
| Input | M5（`-layer 5`） |
| Output | M7（`-layer 7`） |

## 为何避开 M1–M2

- **Double patterning**：下层金属 DP 规则紧，边 pin 对接与签收成本高。
- **给 std cell 留局部互连**：M1/M2 多为单元内走线与 track，不宜再堆 IO pin。
- 中高层出 pin 更利于 escape，也和后续 PG / route 规划更容易配合。

## 相关笔记

- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
