---
title: Pin 不要出在 M1–M2
description: T12nm FinFET 下 M1/M2 有 double patterning，die pin 改出到更高金属层；补充 double patterning 原理与和 pin / via 的关系
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

---

## Double Patterning 是什么

### 一句话

**Double Patterning（DP，双重图形 / 双重曝光）**：光刻机一次曝光的分辨率不够密时，把同一层金属的图形拆成 **两套（或多套）mask**，分两次（或多次）曝光/刻蚀，拼出更密的线距。

### 为什么需要

先进工艺（本项目 T12nm）里，**下层金属线宽、线距极小**。若用单张 mask 一次曝光，相邻线会糊在一起、对不准。解决办法之一就是：

1. 把该层所有线网按颜色 / 掩模分组（常见叫 **coloring**，如 color A / color B）；
2. 同色、够间距的线放在同一张 mask 上；
3. 两张 mask 分别曝光，合起来才是完整的 M1（或 M2）图形。

常见实现形态（概念上即可，不必背设备细节）：

| 类型 | 思路 |
|------|------|
| **LELE**（Litho-Etch-Litho-Etch） | 先曝+刻第一套，再曝+刻第二套 |
| **SADP**（Self-Aligned Double Patterning） | 用侧墙自对准，把间距再「劈」一刀，换更规则的间距 |

后端日常更常碰到的是：**某层标成 DP → 有 2 张 mask → 布线 / via / pin 要满足 DP spacing 与 coloring 规则**。

### 和「单层」的差别

| | 非 DP 层 | DP 层（如本项目下层金属） |
|--|----------|---------------------------|
| Mask | 通常 1 张 | **2 张**（本项目口径：M1–M3 为 DP） |
| 相邻线 | 主要看同一套 spacing | 还要看 **同色 / 异色** 能否相邻 |
| 改版成本 | 相对简单 | 多一张 mask、OPC / 对准更严，**签收更贵、更严** |
| Via 落点 | 相对自由 | 容易踩到 **异色间距 / via enclosure**，via 更难塞 |

本项目 [Powerplan](./powerplan.md) 口径：**M1–M3 都是 double patterning，有 2 张 mask**；因此 powerplan 阶段**不急着加 via1**（spacing 问题多），往往放到 **chipfinish** 再插 via1。

---

## 为何避开 M1–M2 出 Pin

和 DP 直接相关，也和用法相关：

1. **Double patterning 规则紧**  
   Die pin 出在 M1/M2：边 pin 与周边金属、via、escape 都要吃 DP coloring / spacing。对接、DRC、ECO 成本高，不如放到规则更松的中高层。

2. **给 std cell 留局部互连**  
   M1/M2 多为单元内走线、track、以及本项目 **dual rail PG** 所在层，不宜再堆一圈 IO pin 抢资源。

3. **和 via / escape 配合**  
   下层 DP + via1 难放（见 powerplan：via1 推到 chipfinish）。Pin 出在 M5 / M7，escape 与上层布线更容易，也少跟 M1/M2 DP 死磕。

因此本项目实践：**input → M5，output → M7**，刻意避开 M1–M2。

---

## 和 Pin 命令的对应关系

上面 `editPin ... -layer 5 / -layer 7` 就是在落实「不要出在 M1–M2」：

- `-layer 5` → Input 落在 **M5**（非下层 DP 主战场）
- `-layer 7` → Output 落在 **M7**

改 Pin 层时，仍要核对：是否与库 / package / 顶层对接约定一致，以及该层是否仍有 DP 或其它特殊 rule（以 PDK / techlef 为准）。

## 相关笔记

- [Powerplan 做什么](./powerplan.md)（M1–M3 DP、via1 延后、dual rail）
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
