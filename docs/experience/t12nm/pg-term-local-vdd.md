---
title: Macro / Std Cell 供电与 PG Term
description: Global VDD 经 power switch 到 VDD_LOCAL 再供 memory；Design Browser 查 PG term
date: 2026-09-20
---

# Macro / Std Cell 供电与 PG Term

> 工艺：T12nm  
> 阶段：Floorplan / Power planning 前分析  
> 类型：供电方式 / 经验口径  
> 工具：Innovus → Design Browser → PG term

## 口径

做电源规划前，要先搞清楚 **Macro 和 std cell 怎么供电**，并判断是 **local 供电** 还是 **global 供电**。

### 本项目 Memory 供电路径

**Global VDD → Power Switch → Local（VDD_LOCAL）→ Memory**

```text
Global VDD  ──►  Power Switch  ──►  VDD_LOCAL  ──►  Memory
```

Memory 不直接吃全局 `VDD`，而是经 **power switch** 转到 **local 电源**，再接到 memory 的电源脚。

### PG Term 观察到的连接

Design Browser 打开 **PG term** 可见：

| PG / 逻辑电源 | 连接到 |
|---------------|--------|
| **VDD** | **VDD_LOCAL** |
| **VSS** | **VSS**（地网） |

与上图路径一致：memory 侧看到的是 **local（VDD_LOCAL）**。

## 怎么查

1. Innovus 打开 **Design Browser**。  
2. 选中关注的 **Macro** 或 **std cell / lib cell** 实例。  
3. 展开 **PG term**（power/ground terminals）。  
4. 看每个 PG pin 连到哪条 net：是全局 `VDD`/`VSS`，还是 `VDD_LOCAL` 等 local 网。  
5. 再结合 UPF / `addPowerSwitch`（如 `PD_PSO`）确认 switch 前后的 global / local 关系。

## Local vs Global（怎么判断）

| 类型 | 典型特征 | 规划含义 |
|------|----------|----------|
| **Global** | 全芯片/域级 `VDD` 网格 | 做全局 mesh / ring；经 switch 下到 local |
| **Local** | `VDD_LOCAL` 等，经 switch 之后 | 在 memory/区域附近做 local stripe、via，接到 macro PG |

本项目 memory：**global → switch → local → memory**；规划时既要全局 VDD，也要 local 网与 switch 单元（与 Floorplan 里 `addPowerSwitch`、`addStripe ... VDD_LOCAL` 一致）。

## 备注

- Std cell 与 Macro 都要分别点开核对，不要默认两者供电方式相同。  
- Power domain 参考：`PD_PSO`、`PD_AW_ON`。  
- 后续可补充：Design Browser 截图、switch cell 名、各 memory 的 PG term 列表。

## 相关笔记

- [T12nm · 设计规模速览](./design-scale.md)
- [Innovus PG Special（Memory M5）](../../tcl/innovus-pg-special.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
