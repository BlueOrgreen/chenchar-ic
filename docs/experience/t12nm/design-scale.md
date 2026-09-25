---
title: 设计规模速览
description: 12nm ARM A55（ananke_core）：约 51 万 cell、2 个 PD、22 个 Macro
date: 2026-09-20
---

# 设计规模速览

> 工艺：T12nm  
> 设计：ARM A55（顶层 `ananke_core`）  
> 阶段：项目概况  
> 类型：设计规模 / 经验记录

## 口径

**本项目是 12nm ARM A55**（Innovus 设计名 `ananke_core`）。

该设计约有 **51 万个 cell、2 个 power domain、22 个 Macro**。

2 个 power domain 分别为：**PD_PSO**、**PD_AW_ON**。

| 项 | 内容 |
|------|------|
| 产品 | ARM A55 |
| 工艺 | 12nm（T12nm） |
| 设计名 | `ananke_core` |
| Cell | ~51 万 |
| Power domain | 2：`PD_PSO`、`PD_AW_ON` |
| Macro | 22 |

## 备注

- 数量与 PD 名为项目经验记录，具体以当时网表 / UPF / floorplan 为准。
- 后续可补充：macro 类型分布（SRAM / IP 等）、各 PD 电压与开关策略。
