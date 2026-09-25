---
title: Dirty Memory 靠近 IO Port
description: Dirty memory 与 IO port 有直接关系，摆放时需靠近 IO port
date: 2026-09-20
---

# Dirty Memory 靠近 IO Port

> 工艺：T12nm  
> 阶段：Floorplan / Macro placement  
> 类型：Macro 摆放 / 经验口径

## 口径

**Dirty memory 跟 IO port 有直接关系，摆放时需要靠近 IO port。**

## 用意

- 与 IO 有直接数据/通路关系的 memory（本项目称 dirty memory），若摆得远离 IO 边，进出线会变长，易带来 timing、拥塞与绕线压力。
- Floorplan 摆 macro 时，优先把这类 memory **靠 IO port 所在边 / 区域** 放置，缩短到 port 的物理距离。

## 备注

- 具体哪些 instance 算 dirty memory，以项目命名或数据通路文档为准。
- 后续可补充：本项目 dirty memory 列表、靠近的 edge、与普通 memory 摆放策略的差异。

## 相关笔记

- [T12nm · 设计规模速览](./design-scale.md)
- [T12nm · 剩余 Pin 的 Pin Editor 摆放](./pin-editor-remaining.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
