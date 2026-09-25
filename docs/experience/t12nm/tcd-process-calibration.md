---
title: Dummy TCD 与工艺校准
description: TCD 做工艺校准；摆左下角或 channel；需设 RoutingBlockage
date: 2026-09-20
---

# Dummy TCD 与工艺校准

> 工艺：T12nm（FinFET）  
> 阶段：Floorplan / 工艺结构单元摆放  
> 类型：工艺校准 / 经验口径

## 口径

1. **加 dummy 的 TCD 是为了工艺校准。**  
2. 工艺校准分为：  
   - **Frontend（前端）**：OD、Poly  
   - **Backend（后端）**：VIA  
3. **Frontend 不能做 90° 翻转**；**std cell 的 poly 方向必须相同。**  
4. **TCD 放在芯片左下角**（或塞进 **channel**），**不要摆在中间**——因为它占用芯片的 **base layer、via 空间**。  
5. **TCD 也需要设置 RoutingBlockage**，避免信号/电源走线穿进 TCD 占用的金属与 via 区域。

## 说明

| 项 | 含义 |
|------|------|
| TCD（dummy） | 为工艺/制造校准放置的测试或填充结构，不是功能逻辑 |
| Frontend 校准 | 与 OD、Poly 等相关；方向受 poly 取向约束 |
| Backend 校准 | 与 VIA 等相关 |
| Poly 方向 | 全芯片（或同区域）std cell 的 poly 取向保持一致；FE 结构禁止 90° 翻转 |
| 摆放位置 | 左下角或 channel；避开芯片中部核心逻辑区，少占 base layer / via 资源 |
| RoutingBlockage | 在 TCD 周边/区域设 route blk（如 M1–M10），挡住自动布线 |

本项目 Floorplan 中有 `N12_DTCD_*` / `addInst ... -physical -loc {4.74 4.8}`，以及对 FEOL TCD 的 `createRouteBlk ... -name DTCD_rBlk -layer {M1 ... M10}`，与上述口径一致。

## 备注

- 后续可补充：FEOL / BEOL TCD cell 列表、route blk halo 尺寸、与 place blockage 是否同时需要。

## 相关笔记

- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
- [T12nm · 宽高 / CoreToDie 与 FinFET 隔点](./core-to-die-finfet-pitch.md)
