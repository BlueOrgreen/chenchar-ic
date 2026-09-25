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
