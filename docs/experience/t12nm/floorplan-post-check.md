---
title: Floorplan 后检查 EndCap / Tap / Memory
description: Floorplan 完成后用 Calibre DRC 查 endcap 与 memory 间距，并做 Tapcell verify
date: 2026-09-20
---

# Floorplan 后检查 EndCap / Tap / Memory

> 工艺：T12nm（12nm ARM A55）  
> 阶段：Floorplan 完成后  
> 类型：检查清单 / 经验口径

## 口径

**做完 floorplan 后要检查：**

1. **EndCap**：到 **Calibre DRC** 中检查。  
2. **Tapcell**：做 **verify**（如 `verifyWellTap`）。  
3. **Memory 有没有摆放错**：用 **Calibre** 检查 **Memory 之间是否有 DRC 问题**。

## 检查项

| 对象 | 怎么查 | 看什么 |
|------|--------|--------|
| EndCap | Calibre DRC | 边 / 角 endCap 类型与间距是否过 DRC |
| Tapcell | Innovus `verifyWellTap`（及规则） | tap 间距、power domain 覆盖是否满足 |
| Memory | Calibre DRC | Macro 之间间距、摆放是否互相冲突 |

## 备注

- EndCap 角与边类型不同，类型一样会有 DRC；Calibre 是最终确认手段。  
- Memory 摆放错误常表现为 Macro 之间 DRC，而不只是 GUI 上看位置对不对。  
- 后续可补充：本项目用的 Calibre deck、`verifyWellTap` 规则号、典型报错名。

## 相关笔记

- [T12nm · FinFET Row 角处 EndCap 类型不同](./endcap-row-corner.md)
- [T12nm · Dirty Memory 靠近 IO Port](./dirty-memory-near-io.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
