---
title: PR 后 Density 目标
description: T12nm PR 后 density 约 78%；PostCTS 查 density——ECO 插 buf、过高会加大 dynamic IR Drop；ARM CPU 勿塞太满，留空插 decap
date: 2026-09-19
---

# PR 后 Density 目标

> 工艺：T12nm  
> 阶段：Place & Route（PR）完成后 / PostCTS 检查  
> 类型：签核 / 经验口径

## 口径

**T12nm 做完 PR 后，density 控制在 78 左右。**

## 为什么 PostCTS 也要看 density

- **后续 ECO 会插 buffer**：density 太高，后面没空间做 hold/setup/DRV ECO。  
- **density 过高会加重 dynamic IR Drop**（开关电流更密）。  
- 做 **ARM CPU** 时 **不必 / 不宜把 density 搞得太大**，留出空隙；空的地方可插 **decap cell** 改善电源完整性。

## 备注

- 数值为项目经验目标，非 Foundry 硬性 rule；具体以当前项目 signoff checklist 为准。
- 与 PostCTS 检查清单对照见 [CTS：CCOpt Mode、步骤、漏 Tree 与 Debug](./cts-ccopt-mode-debug.md)。
