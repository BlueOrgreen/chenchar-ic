---
title: Placement 做什么
description: Placement 的五点要求：std cell 摆到 core 区域、满足时序（setup / max_cap / max_transition）、net length 最短、congestion 合理、cell density 合理；看 density 得看 overflow，通常在 1.5% 内；place_opt_design 内部 = global place 粗摆 → legalize 到 row/site → timing/drv/congestion/density 优化；约束 = setPlaceMode（congEffort/uniform_density/clock_gate_aware）+ Don't Use（低阈值、小驱动）+ std cell spacing（high pin count congestion / base layer DRC）；checkPlace 查 base layer DRC、row 摆放、PG 逻辑连接
date: 2026-09-24
---

# Placement 做什么

> 工艺：T12nm（12nm ARM A55）  
> 阶段：Placement  
> 类型：方法口径 / 经验记录

## 口径

**Placement 的要求：**

1. 把 **std cell** 摆放到 **core 区域**；
2. 满足**时序需求**（**setup、max_cap、max_transition**）；
3. **net length 最短**；
4. **congestion 合理**；
5. **cell density 合理**。

**看 density 得看 overflow，通常在 1.5% 内。**

## place_opt_design 内部做了什么

**`place_opt_design` 内部做了什么？**

1. **global place**：进行粗摆；
2. **legalize**：摆到具体的 **row / site**；
3. **优化**：timing 时序优化、drv、congestion、density。

## placement 做了哪些约束

### 设置 setPlaceMode

```tcl
setPlaceMode -congEffort high
setPlaceMode -place_global_uniform_density true
setPlaceMode -place_global_clock_gate_aware true
```

| 设置 | 作用 |
|------|------|
| `-congEffort high` | 让工具**加大力度优化 congestion** |
| `-place_global_uniform_density true` | 让工具**均匀摆放**（density） |
| `-place_global_clock_gate_aware true` | **ICG 倾向于其扇出寄存器摆放**、更聚拢 → **clock tree 更短、clock buffer 插入更少** |

### 设置 Don't Use

12nm 库里有 **UltraVT、LVT、RVT**；placement 阶段会将**低阈值电压的 cell** 设置 Don't use，还有**小驱动、容易有 DRC 问题的 cell**。

### std cell spacing rules

- 解决 **High pin count cell** 的 congestion；
- 避免 **base layer DRC**。

设置 spacing 的案例脚本（图 1，照录）：

```tcl
setSpacingLabelMode -mode true; #设置规则检查模式，对特殊cell边距检查（如对齐失败、cell宽度小等）
setSpacing -name high_pin_count_cell_spacing -sll {M1 M2} -check_type base_layer_drc -level cell
```

### 原图

placement 约束笔记：

![placement 约束笔记](./images/placement-constraint.png)

图 1（设置 spacing 的案例脚本）：

![std cell spacing 案例脚本](./images/placement-spacing-rule.png)

## checkPlace

**`checkPlace` 在检查什么？**

- 是否因为**摆放不合理**导致 **base layer 的 DRC**；
- 除此之外，还检查 **cell 是否摆放在 row 上**、**cell 的 PG 逻辑连接是否正确**。

## 相关笔记

- [PR Density](./pr-density.md) —— cell density 的经验值
- [Floorplan Post Check](./floorplan-post-check.md) —— placement 之前 floorplan 的检查项
- [Powerplan 做什么](./powerplan.md) —— placement 之前的供电网络
