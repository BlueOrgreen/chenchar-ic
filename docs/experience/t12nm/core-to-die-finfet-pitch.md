---
title: 宽高与 CoreToDie 须为 FinFET 隔点整数倍
description: FinFET 工艺下芯片宽度、高度、CoreToDie 均须为 FinFET 隔点的整数倍
date: 2026-09-19
---

# 宽高与 CoreToDie 须为 FinFET 隔点整数倍

> 工艺：T12nm（FinFET）  
> 阶段：Floorplan（die / core 尺寸与边距）  
> 类型：物理约束 / 经验口径

## 口径

**在 FinFET 工艺下，芯片的宽度、高度、CoreToDie 都要满足 FinFET 隔点的整数倍。**

## 备注

- 设 `floorPlan` / die size / core size，以及 core-to-die（如 `core2left` 等边距）时，按工艺 FinFET 隔点（pitch）对齐取整。
- 「隔点」指该工艺 FinFET 相关 pitch / 制造栅格；具体数值以 PDK / tech LEF 为准。
- 后续可补充：本项目实际隔点数值、推荐公式与违例时的报错现象。
