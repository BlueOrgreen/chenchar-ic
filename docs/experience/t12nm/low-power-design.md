---
title: 低功耗设计手段
description: Clock Gating、Multi-Vth、Power Gating、Multi-Voltage、DVFS、Well Biasing、Multi-bit Reg
date: 2026-09-20
---

# 低功耗设计手段

> 工艺：T12nm（12nm ARM A55）  
> 阶段：低功耗 / 电源规划  
> 类型：方法清单 / 经验记录



![Low Power Design](./images/low-power-design.png)

## 口径

| # | 手段 | 含义 |
|---|------|------|
| 1 | **Clock Gating（ICG）** | 时钟门控，在**逻辑综合**阶段加 |
| 2 | **Multi-Vth** | 使用不同阈值电压的 cell |
| 3 | **Power Gating** | Power Switch Cell；会带来 **Isolation**（见 [Isolation Cell](./isolation-cell.md)） |
| 4 | **Multi-Voltage** | 多电源电压 / Voltage domain；动态功耗与电压相关（公式含 \(V_{dd}^{2}\)） |
| 5 | **DVFS** | Dynamic Voltage Frequency Scaling，动态调整电压和频率 |
| 6 | **Well Biasing** | 井偏置：N-well 接 **VDD ± ΔV**，P-substrate 接 **VSS ± ΔV**，调阈值以改善性能与功耗 |
| 7 | **Multi-bit Reg** | 多比特寄存器；也属于低功耗相关设置 |

## 说明

1. **Clock Gating**：关掉不工作逻辑的时钟，减动态功耗；ICG 一般在综合插入。  
2. **Multi-Vth**：高阈值 cell 漏电小、速度慢；低阈值相反。按路径选用。  
3. **Power Gating**：用 Power Switch 切断某 power domain 的供电；断电域与常电域之间要加 **Isolation**（详见 [Isolation Cell](./isolation-cell.md)）。本项目 `PD_PSO` 的 `addPowerSwitch` 属于这一类。  
4. **Multi-Voltage**：不同 voltage domain 电压不同，跨域要用 Level Shifter。公式里 **动态功耗跟电压成正比**（见下节 \(V_{dd}^{2}\)）。  
5. **DVFS**：运行中按负载升降电压和频率。  
6. **Well Biasing（井偏置）**：  
   - **N-well** 连接到 **VDD ± ΔV**  
   - **P-substrate** 连接到 **VSS ± ΔV**  
   从而调整阈值电压，改善 **performance**，并改善功耗。  
7. **Multi-bit Reg**：多比特寄存器打包，也属于低功耗相关设置（相对单比特 reg 可减面积/时钟相关开销）。

## HVT / SVT / LVT 的 PPA 差异

**低阈值电压改善 performance，高阈值电压改善 leakage。**

| 类型 | Delay（性能） | Leakage |
|------|----------------|---------|
| **LVT** | 最快（delay 最低） | 最高 |
| **SVT** | 居中 | 居中（相对 LVT 明显下降） |
| **HVT** | 最慢 | 最低 |

- 低阈值标准单元：速度快、泄漏功耗高。  
- 高阈值标准单元：速度慢、泄漏功耗低。
- 不同阈值电压cell的面积是一样的

![Multi-Vth leakage vs delay](./images/multi-vth-ppa.png)

## Multi-Voltage（多电源电压）概念

**公式里动态功耗跟电压成正比**（图中动态功耗公式含 \(V_{dd}^{2}\)，降压对动态功耗效果显著）：

\[
P_{dyn} = C_{eff} ✖️ V_{dd}^{2} ✖️ f_{clock}
\]

口径（来自课件）：

- 动态功耗与电压的平方相关，降低供电电压对减动态功耗很有效。  
- 相对独立、没有关键时序路径的模块，可降低供电电压，在满足时序的前提下减动态功耗。  
- 有关键时序路径的模块保持高电压，保证高性能。

![多电源电压技术 - 概念](./images/multi-voltage-concept.png)

## Power Gating 结构

顶层 **VA_top 常开**。里面可关断的子域（图中 **VA1 / VA2**）不直接吃全局 VDD，而是：

```text
VDD  ──► Power Switch (VIN) ──► VDD_SW  ──► VA1
VDD1 ──► Power Switch (VIN) ──► VDD1_SW ──► VA2
```

| 项 | 图中做法 |
|------|----------|
| 常开 | `VA_top` |
| 可关断 | `VA1`、`VA2`（关断） |
| Switch | `VDD`/`VDD1` 进 `VIN`，`VOUT` 接到域内 `VDD_SW` / `VDD1_SW` |
| 控制 | `EN` 接 `iso_en1` / `iso_en2`，由 Power Supply module 给出 |
| 地 | 两边 **VSS 仍接全局 VSS**，不切断 |

关断时只断电源、不断地；跨域信号还要 Isolation（与 Power Switch 配套）。本项目路径是 Global VDD → Power Switch → VDD_LOCAL → Memory，和这张图同一类结构。

![Power Gating](./images/power-gating.png)

## Power Switch：12nm Common Nwell / 28nm Two Nwell

**12nm 用 Common Nwell，28nm 用 Two Nwell。**

| 工艺 | Power Switch 阱结构 |
|------|---------------------|
| **28nm** | **Two Nwell**：N-well 拆开（中间 PMOS 阱 + 两侧 split common nwell，接 **VPP**）；P-well 为 shared pwell（NMOS body 接 **VBB**）。PMOS source 接 **VDDE** |
| **12nm** | **Common Nwell**：一整条 **shared nwell**（N-well bias 接 **VPP**）；下面 **shared pwell**（body 接 **VBB**）。PMOS source 接 **VDDG** |

本项目是 12nm，Power Switch 按 **Common Nwell（shared nwell）** 来理解，不是 28nm 那种两段 N-well。

![Two Nwell vs Common Nwell](./images/power-switch-nwell.png)


## 相关笔记

- [T12nm · ICG Enable Pin 容易 Setup 违例](./icg-enable-setup.md) —— Clock Gating enable 的 setup 问题单独成篇
- [T12nm · 为何 Signoff 后还要看 IR Drop](./ir-drop-after-signoff.md) —— IR Drop 问答单独成篇
- [T12nm · Macro / Std Cell 供电（Global→Switch→Local→Memory）](./pg-term-local-vdd.md)
- [T12nm · Power Switch：Core / Channel 与边界](./power-switch-core-channel.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)
