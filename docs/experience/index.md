---
title: 项目经验
description: 按工艺与项目沉淀的签核口径、指标与踩坑记录
---

# 项目经验

本分区用于积累 **真实项目里的经验数字与口径**（工艺 / 阶段 / 指标），和博客随笔、知识库概念、TCL 脚本分开存放。

建议每条笔记写清：

- 工艺节点（如 T12nm）
- 阶段（如 PR 后）
- 指标与目标值
- 可选：背景、例外、和其它指标的关系

## 按工艺

本站 T12nm 条目对应项目：**12nm ARM A55**（设计名 `ananke_core`）。

- [T12nm · ARM A55 设计规模](./t12nm/design-scale.md)
- [T12nm · PR 后 Density](./t12nm/pr-density.md)
- [T12nm · 宽高 / CoreToDie 与 FinFET 隔点](./t12nm/core-to-die-finfet-pitch.md)
- [T12nm · Pin 不要出在 M1–M2](./t12nm/pin-avoid-m1-m2.md)
- [T12nm · Clock Port：位置 / NDR 2w2s / Shielding](./t12nm/clock-port-mid-io.md)
- [T12nm · 剩余 Pin 的 Pin Editor 摆放](./t12nm/pin-editor-remaining.md)
- [T12nm · Macro / Std Cell 供电（Global→Switch→Local→Memory）](./t12nm/pg-term-local-vdd.md)
- [T12nm · Dirty Memory 靠近 IO Port](./t12nm/dirty-memory-near-io.md)
- [T12nm · Dummy TCD（校准 / 摆角或 channel）](./t12nm/tcd-process-calibration.md)
- [T12nm · FinFET Row 角处 EndCap 类型不同](./t12nm/endcap-row-corner.md)
- [T12nm · Power Switch：Core / Channel 与边界](./t12nm/power-switch-core-channel.md)
- [T12nm · Floorplan 后检查 EndCap / Tap / Memory](./t12nm/floorplan-post-check.md)
- [T12nm · 低功耗设计手段](./t12nm/low-power-design.md)
- [T12nm · UPF 传递功耗设计意图](./t12nm/upf-power-intent.md)
- [T12nm · Isolation Cell](./t12nm/isolation-cell.md)
- [T12nm · Powerplan 做什么](./t12nm/powerplan.md)
- [T12nm · Placement 做什么](./t12nm/placement.md)
- [T12nm · CTS 要点：Sink Type / SDC→CCOpt / Clock NDR / Routing](./t12nm/cts.md)
- [T12nm · CTS：Clock Path / Data Path 预算](./t12nm/cts-path-budget.md)
- [T12nm · CTS：CCOpt Mode、步骤、漏 Tree 与 Debug](./t12nm/cts-ccopt-mode-debug.md)
- [T12nm · Case：Clock Tree ECO 做短 Launch Path](./t12nm/cts-eco-shorten-launch.md)
- [T12nm · Hold Time Analysis](./t12nm/hold-time-analysis.md)
- [T12nm · Case：Hold Buffer 过多（CRPR=0 / Memory Channel）](./t12nm/hold-phc-too-many-crpr.md)
- [T12nm · Placement OCV Setting（ssg corner）](./t12nm/ocv-setting.md)
- [T12nm · Tie Cell](./t12nm/tie-cell.md)
- [T12nm · Timing ECO 盯住 refinePlace 的 Max Move](./t12nm/timing-eco-refineplace.md)
- [T12nm · Timing Optimization 手段](./t12nm/timing-optimization.md)
- [T12nm · Routing（Double Patterning / Power Aware）](./t12nm/routing.md)
- [T12nm · Power Optimization 手段（Leakage / Dynamic）](./t12nm/power-optimization.md)
- [T12nm · Leakage 优化](./t12nm/leakage-optimization.md)
- [T12nm · ICG Enable Pin 容易 Setup 违例](./t12nm/icg-enable-setup.md)
- [T12nm · Power Gating 两种类型：Common Nwell / Two Nwell](./t12nm/power-switch-nwell-type.md)
- [T12nm · 为何 Signoff 后还要看 IR Drop](./t12nm/ir-drop-after-signoff.md)
- [T12nm · Power Switch vdd_local 打太密引发 Congestion](./t12nm/power-switch-congestion.md)
- [T12nm · Flow Checklist（PR 全流程检查表）](./t12nm/flow-checklist.md)
