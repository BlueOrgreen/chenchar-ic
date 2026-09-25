---
title: FinFET 下 Row 角处 EndCap 类型不同
description: FinFET 下 Row 角处 endCap 类型须不同，类型一样会有 DRC 问题
date: 2026-09-20
---

# FinFET 下 Row 角处 EndCap 类型不同

> 工艺：T12nm（FinFET）  
> 阶段：Floorplan / EndCap & Well Tap  
> 类型：物理结构 / 经验口径

## 口径

**FinFET 工艺下，在 Row 的角处，endCap 的类型不一样。**

边（left / right / top / bottom）与角（如 leftTopCorner、leftBottomCorner 等）要用不同的 boundary / endCap cell，不能只用同一种 endCap 铺满。

**如果类型一样，会有 DRC 问题。**

因此实际检查时，会重点看这些有「左右侧 / 边界」的地方：

- **Design 的左右 2 侧**
- **Memory 的左右 2 侧**
- **Channel 的左右 2 侧**
- **Channel** 本身（通道区域的 row / 边界）

这些位置容易出现边与角交接，endCap 类型要配对正确。

## 说明

| 位置 | 含义 |
|------|------|
| 边 endCap | 沿 row 左右边或上下边的边界 cell |
| 角 endCap | Row / 区域拐角处专用 cell，类型与边不同 |
| 类型混用错误 | 角上仍用边同款 endCap → 易触发 DRC |
| 重点检查区 | design 左右侧、memory 左右侧、channel 左右侧及 channel 内 |

本项目 `setEndCapMode` 中分别指定了 `-leftEdge`、`-rightEdge`、`-leftTopCorner`、`-leftBottomCorner`、`-topEdge`、`-bottomEdge` 等，即体现「角与边类型不同」；并对各 power domain / 区域 `addEndCap`。

## 备注

- 后续可补充：典型 DRC 报错名、各角对应的 cell 名表、与 poly 方向 / PD 的关系。

## 相关笔记

- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
- [T12nm · Dummy TCD（校准 / 摆角或 channel）](./tcd-process-calibration.md)
- [T12nm · 宽高 / CoreToDie 与 FinFET 隔点](./core-to-die-finfet-pitch.md)
