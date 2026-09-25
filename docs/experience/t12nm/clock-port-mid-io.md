---
title: Clock Port：位置、NDR 与 Shielding
description: Clock port 摆 IO 中间；设 NDR 2w2s，并考虑 shielding
date: 2026-09-20
---

# Clock Port：位置、NDR 与 Shielding

> 工艺：T12nm  
> 阶段：Floorplan / Pin assignment / 时钟互连  
> 类型：时钟入口 / 经验口径

## 口径

1. **位置：** Clock port 可以放在 IO port 摆放位置的中间，让 clock port 到芯片其余角的长度更均匀。  
2. **NDR：** Clock port（及相关 clock net）会设置 **NDR 2w2s**（double width / double spacing）。  
3. **Shielding：** 还要考虑 **shielding**（时钟线两侧/周边地或电源屏蔽），降低串扰与噪声。

## 位置用意

- Clock 从 die 边进入后，往往要扇出到整颗芯片的多个区域。
- 若 clock port 偏在某一侧角，到对角区域的连线会偏长，CTS / 时钟树更容易一边松一边紧。
- 放在该边 **IO 排布区间的中部**，到两侧、到其余角的几何距离更接近，有利于后续时钟均衡。

## NDR 2w2s 与 Shielding

| 项 | 做法 | 用意 |
|------|------|------|
| NDR 2w2s | 时钟相关 net 用非默认线宽/线距（2× width、2× spacing） | 降电阻与耦合，改善时钟完整性 |
| Shielding | 为 clock 走线预留/加 shield | 抑制邻线串扰，稳定 clock |

具体 `add_ndr` / `create_route_type` / shield 命令以项目 CTS、时钟约束脚本为准（可与 `cts_w2s2` 一类规则对照）。

## 备注

- 「中间」相对的是本边 IO port 的排布范围；具体坐标结合 `editPin` / pin 区域调整。
- 后续可补充：本项目 clock port 名、NDR 规则名、shield net（如 VSS）与适用金属层。

## 相关笔记

- [T12nm · Pin 不要出在 M1–M2](./pin-avoid-m1-m2.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
- [Innovus CCOpt CTS 脚本](../../tcl/innovus-ccopt-cts.md)
