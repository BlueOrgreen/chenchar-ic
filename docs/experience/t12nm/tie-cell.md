---
title: Tie Cell
description: Tie cell 给常量 1'b0/1'b1 的 gate 提供"正规驱动"——防 ESD 击穿栅氧、过 foundry DRC（禁 gate 直连 rail）、保 DFT 覆盖率；不加则 DRC 挂 signoff、ESD 脆弱、ATPG 掉覆盖率、rail 波动可能引入毛刺
date: 2026-09-28
---

# Tie Cell

> 日期：2026-09-28  
> 来源：对话问答整理（非截图）  
> 阶段：基本概念 · 常量信号驱动 / ESD · DFT  
> 工艺：通用概念（T12nm 项目同样适用）

## 讲讲 Tie Cell

**核心：常量信号（1'b0 / 1'b1）的负载是 std cell 的 gate，而 gate 不能直接连在电源轨（VDD/VSS）上**——必须由一个真正的 cell（tie-high / tie-low）来驱动

提供常量信号（tie-high、tie-low）的单元，用来接入 VDD/VSS 中，可以防止栅层击穿、天线效应


```tcl
# 设置 TieCell
setTieHiLoMode -prefix Tie -maxFanout 8 -maxDistance 20 -cell "TIEHBWP16P90CPD TIELBWP16P90CPD"

addTieHiLo -powerDomain PD_PSO
addTieHiLo -powerDomain PD_AW_ON


# 选中 Tie Cell
select_obj [dbGet top.insts.cell.name TIE* -p2]
```

## 相关笔记

- [Isolation Cell](./isolation-cell.md) —— 姊妹概念：关断域输出钳 0/1（低功耗）
- [低功耗设计手段](./low-power-design.md)
- [Placement 做什么](./placement.md) —— PR 阶段摆放
