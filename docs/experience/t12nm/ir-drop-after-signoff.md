---
title: 为何 Physical / Timing Signoff 后还要看 IR Drop
description: 芯片做完 physical signoff 和 timing signoff 后仍要看 IR Drop——芯片不同位置的电压不一样（供电阻抗 / 电流导致压降），且电压与功耗相关；Physical / Timing 过了只说明几何与标称/约束下的时序，IR Drop 查的是片上实际供电是否够匀、够高
date: 2026-09-29
---

# 为何 Physical / Timing Signoff 后还要看 IR Drop

> 日期：2026-09-29  
> 工艺：T12nm（12nm ARM A55）  
> 阶段：Signoff / IR Drop 分析  
> 类型：问答整理

## Q：为何 Physical / Timing Signoff 后还要看 IR Drop？

**A：** 芯片做完 **physical signoff** 和 **timing signoff** 后，仍要看 **IR Drop**，因为：

1. 芯片**不同位置的电压不一样**（供电阻抗 / 电流导致压降）。
2. **电压跟功耗成正比**（动态功耗与电压相关，见 [低功耗设计手段](./low-power-design.md) 的 Multi-Voltage 公式）。

因此要看在**电压偏低**的位置，功耗（以及依赖电压的时序/功能裕量）是否还满足。

**Physical / Timing 过了只说明几何与标称/约束下的时序；IR Drop 查的是片上实际供电是否够匀、够高。**

## Q: IR Drop是只有VDD吗

IR Drop 是VDD 和 VSS 的IR Drop，两者都有

## 相关笔记

- [低功耗设计手段](./low-power-design.md) —— Multi-Voltage 公式（动态功耗 ∝ V²）、Power Gating
- [Powerplan 做什么](./powerplan.md) —— 供电网络决定 IR Drop 的物理基础
- [Power Switch：Core / Channel 与边界](./power-switch-core-channel.md)
