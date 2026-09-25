---
title: Power Switch：Core / Channel 分区与边界
description: Core 与 Channel 分别设 power switch；先挡 channel；边界加 switch 防 IR Drop
date: 2026-09-20
---

# Power Switch：Core / Channel 分区与边界

> 工艺：T12nm  
> 阶段：Floorplan / Power Switch 插入  
> 类型：供电结构 / 经验口径

## 口径

1. **设置 power switch 时，要对 core 区域和 channel 区域分别设置。**  
2. **先给 channel 盖住 blockage**，避免 **core** 的 power switch 落到 channel 里。  
3. **加 channel 的 power switch 之前，先对 channel 加 soft blockage**：soft blockage **不影响**插入 power switch（配合 `-ignoreSoftBlockage`），但可继续约束普通 std cell。  
4. **再在模块边界处加 power switch**，减轻边界处的 **IR Drop**。

## 推荐顺序

```text
Channel 盖 PlaceBlockage（先挡住 core 插 switch）
    →  Core 区域 addPowerSwitch
    →  Channel 改为 soft blockage
    →  Channel 区域 addPowerSwitch（soft 不挡 switch）
    →  模块边界处加 Power Switch（防边界 IR Drop）
```

| 步骤 | 用意 |
|------|------|
| Channel 先（硬）blockage | 防止核心区批量插 switch 时误落到 channel |
| 改成 soft 再插 channel switch | **soft blockage 不影响插入 power switch**；std cell 仍受约束 |
| Core / Channel 分开设 | 两区域间距、密度、offset 往往不同 |
| 边界加 switch | 缩短边界供电路径，改善边界 **IR Drop** |

本项目脚本中：channel 先 `createPlaceBlockage` → 插 boundary/core switch → `delete` 后重建 `-type soft` → 再 `addPowerSwitch ... -ignoreSoftBlockage` 插 channel switch，与上述口径一致。

## Cell 尺寸与间距（T12nm）

| 参数 | 数值 |
|------|------|
| Power switch cell 高度 | **0.576 µm × 2 = 1.152 µm**（double-height cell，占 2 个 row） |
| Row 高度 | **0.576 µm** |
| 相邻 power switch cell 间距 | **30 µm** |

power switch 高度恰为 row 高度的 2 倍（1.152 µm / 0.576 µm = 2），即每个 switch 跨两行摆放；相邻 switch 之间拉开 **30 µm**。

## 相关笔记

- [T12nm · Macro / Std Cell 供电（Global→Switch→Local→Memory）](./pg-term-local-vdd.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
