---
title: CTS：Clock Path / Data Path 预算
description: 12nm 经验数字——clock path 约 150ps，data path 约 350ps
date: 2026-10-08
---

# CTS：Clock Path / Data Path 预算

> 日期：2026-10-08  
> 工艺：T12nm（12nm ARM A55）  
> 阶段：CTS  
> 类型：经验数字

## 口径

**T28nm ，signoff 的 clock path 在 150ps，data path 在 350ps。 因此在PR实现的时候会约束一点，如在cts设置 clock path为120ps**

| 路径 | 经验量级 |
|------|----------|
| Clock path | ~150 ps |
| Data path | ~350 ps |

做 CTS / 看 timing 时，可拿这对数字当本工艺的粗量级参考；具体以当时 period、corner、实际 report 为准。

## 相关笔记

- [CTS 要点：Sink Type / SDC→CCOpt / Clock NDR / Routing](./cts.md)
- [CTS：CCOpt Mode、步骤、Log 与 Debug](./cts-ccopt-flow.md)
- [Clock Port：位置 / NDR 2w2s / Shielding](./clock-port-mid-io.md)
- [Innovus CCOpt CTS 脚本](../../tcl/innovus-ccopt-cts.md)
