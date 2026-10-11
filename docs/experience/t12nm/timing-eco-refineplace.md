---
title: Timing ECO 盯住 refinePlace 的 Max Move
description: 做 timing ECO 一定要关注 refine place 的结果——当 max move 超过 150，timing 肯定会变差；refine place 把 cell 挪太远，ECO 在 timing 上赚的就亏回去了
date: 2026-09-28
---

# Timing ECO 盯住 refinePlace 的 Max Move

> 日期：2026-09-28  
> 工艺：T12nm（12nm ARM A55）  
> 阶段：Timing ECO（PR 后）  
> 类型：经验数字 / 踩坑口径

## 口径

**做 timing ECO 的时候，一定要关注 refine place 的结果：当 max move 超过 150，timing 肯定会变差。**

- ECO 跑完别只看 timing 数字，先看 refine place 报的 **max move**；
- max move 一大，说明 cell 被挪得很远，net length 全变了——ECO 在 timing report 上赚的，可能全被 refine place 亏回去；
- **max move 超 150 就要警惕**，这个 ECO 的结果不能直接信。

## 相关笔记

- [Placement 做什么](./placement.md) —— place_opt_design 里的 global place / legalize，refine place 同是 legalize 逻辑
