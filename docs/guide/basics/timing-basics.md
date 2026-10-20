---
title: 建立时间与保持时间（Setup / Hold）
description: Setup / Hold 含义、路径模型、公式与 slack；skew 对两者的相反影响
date: 2026-10-14
---

# 建立时间与保持时间（Setup / Hold）

静态时序分析（STA）关心路径是否满足时序约束。最基础的两个库单元约束就是 **Setup（建立时间）** 和 **Hold（保持时间）**。

## 是什么

对寄存器（flip-flop）来说：

| | 建立时间 Setup | 保持时间 Hold |
|--|----------------|---------------|
| **问的是** | 时钟沿到来**之前**，数据要提前稳定多久 | 时钟沿到来**之后**，数据还要稳住多久 |
| **怕什么** | 数据来得**太晚**，沿到了还在变 | 数据撤得**太早**，沿刚采完就变了 |
| **典型修法** | 加快 data / 让 capture 时钟晚一点 / 降频等 | 加长 data 最短路径 / 调 skew / 插 delay buffer |

一句话：**Setup 管「来得及采」，Hold 管「采完别马上变」。**

## 一条常见时序路径

```text
CLK ──► Launch FF ──(Q)──► 组合逻辑 ──(D)──► Capture FF ──► CLK
              │                                    │
         launch 时钟到达                      capture 时钟到达
```

符号约定：

| 符号 | 含义 |
|------|------|
| `T_co` | 时钟到 Q 的延迟（clock-to-Q） |
| `T_logic_max` / `T_logic_min` | 组合逻辑最大 / 最小延迟 |
| `T_su` | capture FF 的 setup 要求 |
| `T_h` | capture FF 的 hold 要求 |
| `T_clk_l` | 时钟源到 launch 时钟脚的延迟 |
| `T_clk_c` | 时钟源到 capture 时钟脚的延迟 |
| `T_period` | 时钟周期 |

有符号 skew：

```text
skew = T_clk_c − T_clk_l
```

（工程报告里还会加 uncertainty / jitter / OCV，下面先写核心形式。）

## Setup 公式

同一时钟、本拍 launch → **下一拍** capture：

```text
T_clk_l + T_co + T_logic_max  ≤  T_clk_c + T_period − T_su
```

写成 slack（余量）：

```text
Setup Slack
  = (T_clk_c + T_period − T_su) − (T_clk_l + T_co + T_logic_max)
  = T_period − T_co − T_logic_max − T_su + (T_clk_c − T_clk_l)
  = T_period − T_co − T_logic_max − T_su + skew
```

- **Slack ≥ 0**：setup 过  
- **Slack < 0**：setup 违例  

直觉：周期越大越容易过；data 路径越长越难过；**capture 越晚 / launch 越早**（skew 越大）越帮 setup。

## Hold 公式

通常同一拍：launch 沿采完后，新数据不能太早冲到 capture：

```text
T_clk_l + T_co + T_logic_min  ≥  T_clk_c + T_h
```

写成 slack：

```text
Hold Slack
  = (T_clk_l + T_co + T_logic_min) − (T_clk_c + T_h)
  = T_co + T_logic_min − T_h − (T_clk_c − T_clk_l)
  = T_co + T_logic_min − T_h − skew
```

- **Slack ≥ 0**：hold 过  
- **Slack < 0**：hold 违例  

直觉：data 最短路径太短容易 hold 违例；**capture 越早 / launch 越晚**（skew 越小甚至为负）越帮 hold。  
和 setup **对着干**：帮 setup 的 skew 往往会伤 hold。

## Setup / Hold 对照

| | Setup | Hold |
|--|-------|------|
| 比的是 | 数据最晚到 vs 下一拍时钟 | 数据最早变 vs 本拍时钟 |
| 关键量 | `T_logic_max`、周期 | `T_logic_min` |
| skew = `T_c − T_l` | skew↑ 有利 | skew↑ 不利 |
| 和频率 | 周期短更难 | 基本与频率无关 |

## 和「skew 大」的关系（易混点）

- **某条 path 上**：`skew = T_clk_c − T_clk_l`；capture 晚帮 setup、伤 hold。  
- **CTS 说 skew 大**：多指 skew group 内 sink 到达时间 **最大−最小** 很大（没 balance 好），不是特指 capture > launch。  
- 组内又有到得很早、又有到得很晚的 sink 时，**setup 和 hold 都可能**被拍爆。

## 面试一句话

> Setup：时钟来之前数据要稳定——launch 时钟 + cq + 逻辑 max 要小于 capture 时钟 + 周期 − setup。  
> Hold：时钟来之后数据还要稳住——launch 时钟 + cq + 逻辑 min 要大于 capture 时钟 + hold。  
> Skew = capture 时钟延迟 − launch 时钟延迟；加大 skew 帮 setup、伤 hold。

## 相关笔记

- [数字 IC 学习地图](../intro/learning-map.md)
- [工艺节点与命名速览](./process-nodes.md)
- [CTS：Clock Path / Data Path 预算](../../experience/t12nm/cts-path-budget.md)
- [ICG Enable Pin 容易 Setup 违例](../../experience/t12nm/icg-enable-setup.md)
