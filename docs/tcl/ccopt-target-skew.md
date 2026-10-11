---
title: set_ccopt_property target_skew
description: CTS 阶段 target_skew 含义——给 Balance 停手标准，压组内时钟到达差；与 insertion delay 分工
date: 2026-10-09
---

# set_ccopt_property target_skew

> 日期：2026-10-09  
> 工具：Innovus CCOpt  
> 阶段：CTS

## 脚本

```tcl
set_ccopt_property target_max_trans 0.12
set_ccopt_property target_skew 0.02
set_ccopt_property max_fanout 24
```

项目 CTS 脚本里常见设成 **0.02**（约 20ps）。完整流程见 [Innovus CCOpt CTS 脚本](./innovus-ccopt-cts.md)。

跑完对照实际 skew：

```tcl
report_ccopt_skew_groups -summary -file ../report/CTS/skew_group.rpt
```

## 是干嘛的

**Target skew** 告诉 CCOpt：同一组 sink（一个 skew group）之间，时钟到达时间**允许差多少**。CTS 的 **Balance** 按这个目标去长树、插 buf/inv，尽量把组内 skew 压到这个数以内。

设了 `0.02`，工具会把大部分 sink 的 insertion delay 拉到彼此差 **≤ 20ps**。

## 有什么用

1. **给 Balance 一个停手标准**  
   没有它，工具不知道「够齐了」还是「还要继续插 cell / 绕线」。有了 target，均衡才有明确预算。

2. **管 setup / hold 余量**  
   Skew 太大：快时钟到 capture、慢时钟到 launch → setup 紧；反过来 hold 紧。先把时钟不平衡压在可接受范围，data path 才好修。

3. **和 insertion delay 分工**  
   - **Insertion delay**：树有多深（12nm 经验 clock path ~150ps，见 [CTS path budget](../experience/t12nm/cts-path-budget.md)）  
   - **Target skew**：各终点差多少  
   `report_ccopt_skew_groups` 就是拿实际 skew 对照这个 target。

4. **不是越小越好**  
   目标过严（比如几 ps）会多插 cell、树更深、功耗 / 拥塞变差，还可能逼出无用的 useful skew。**20ps 这类量级是「够用、别过度」**。局部 hold 紧时，用 `insertion_delay` 做短/做长（见 [CTS 要点](../experience/t12nm/cts.md)），而不是把全局 target 拧死。

## 相关笔记

- [Innovus CCOpt CTS 脚本](./innovus-ccopt-cts.md)
- [CTS：CCOpt Mode、步骤、Log 与 Debug](../experience/t12nm/cts-ccopt-flow.md)
- [CTS 要点：Sink Type / SDC→CCOpt / Clock NDR / Routing](../experience/t12nm/cts.md)
- [CTS：Clock Path / Data Path 预算](../experience/t12nm/cts-path-budget.md)
