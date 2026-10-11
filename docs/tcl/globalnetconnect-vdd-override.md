---
title: globalNetConnect 覆盖 VDD 逻辑连接
description: globalNetConnect VDD_LOCAL -type pgpin -pin {VDD} -inst * -powerDomain PD_PSO -override，PD_PSO 域内 instance 的 VDD pgpin 改连 VDD_LOCAL
date: 2026-09-24
---

# globalNetConnect 覆盖 VDD 逻辑连接

> 日期：2026-09-24  
> 来源：截图识别整理（picture-tcl，1 张截图）  
> 阶段：Powerplan（PG 逻辑连接）

## 完整脚本

```tcl
globalNetConnect VDD_LOCAL -type pgpin -pin {VDD} -inst * -powerDomain PD_PSO -override
```


**转录注记（存疑处均照录未改）：**

1. 原图高 40 px，仅一行；行首提示符为 `innovus 29>`，正文命令逐字符转录（代码块中已去掉提示符）。
2. 首次整图识别回传了「`**info:  global net connect instance pins: 21 ...`」回显片段，与单行原图不符（疑为误识别，未采纳）；二次定点识别结果如上，以二次为准，原图见下。

## 原图

![globalNetConnect 覆盖 VDD 逻辑连接](./images/globalnetconnect-vdd-override.png)

## 相关笔记

- [TCL 脚本](./index.md)
- [Innovus 03 Powerplan](./innovus-03-powerplan.md)
- [Power Switch Stapling Stripe（power_stape_pso）](./power-stape-pso.md)
- [T12nm · Powerplan 做什么](../experience/t12nm/powerplan.md)
