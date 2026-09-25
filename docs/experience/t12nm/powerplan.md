---
title: Powerplan 做什么
description: Powerplan 建供电通路；M1/M2 dual rail；PD_PSO→VDD_LOCAL、PD_AW_ON→VDD_CORE；1P11M PG 到 M9
date: 2026-09-21
---

# Powerplan 做什么

> 工艺：T12nm（12nm ARM A55）  
> 阶段：Power planning  
> 类型：方法口径 / 经验记录

## 口径

**Powerplan 做什么？**  
创建从芯片**供电源头**到各个 **cell、PG pin** 的**供电通路**。

**在 T12nm 中，powerplan 的结构是：M1 和 M2 是 power rail，并联 dual rail（du rail）。**

### Domain 的 VDD 逻辑连接

| Power domain | VDD 逻辑连到 |
|--------------|--------------|
| **PD_PSO** | **VDD_LOCAL** |
| **PD_AW_ON** | **VDD_CORE** |

### 金属层（1P11M）

本项目用 **1P11M**（1 层 Poly + 11 层 Metal）：

| 层 | 用途 |
|------|------|
| **M1 / M2** | Power rail（并联 dual rail） |
| **最高打 PG：M9** | 本设计内部 powerplan / PG 打到 **M9** |
| **M10 / M11** | 给到**顶层打 Power**（更上层/封装侧供电） |

```text
M11 / M10 ── 顶层 Power
    │
   M9 ────── 本芯片 PG 最高层
    │
  … stripe / mesh …
    │
  M2 ∥ M1 ── power rail → cell / PG pin
```

### Power Switch 与高低层

**Power switch 相关电源：TVDD、VDD_LOCAL、VSS。**

高层的 **VDD_CORE** 打到 Power switch **低层（M1、M2）的 VDD_LOCAL**。

```text
高层 VDD_CORE
      │
      ▼
 Power switch（TVDD / VDD_LOCAL / VSS）
      │
      ▼
 M1 / M2 的 VDD_LOCAL
```

与上表一致：`PD_AW_ON` 走 **VDD_CORE**；经 switch 后到 `PD_PSO` 的 **VDD_LOCAL**。

## 供电路径总览（结合 Power Switch）

```text
封装 / 顶层电源
     │
  M11 / M10 ──── 顶层打 Power（更上层 / 封装侧供电）
     │
    M9 ────────── 本设计 PG 最高层（global mesh 的起点）
     │
  M8 … M3 ────── stripe / mesh 横向铺开，via 逐层往下分流
     │
  VDD_CORE ───── global 网（always-on 一侧；PD_AW_ON 域直接用它）
     │
     ▼
┌────────────── Power Switch（闸门）─────────────┐
│  输入：VDD_CORE    控制/驱动：TVDD    地：VSS      │
│  输出：VDD_LOCAL（受控通断 → power gating）        │
└──────────────────────────────────────────────┘
     │
     ├─► std cell：M1 ∥ M2 dual rail（VDD_LOCAL / VSS）→ row 内每个 cell 的 PG pin
     │
     └─► Memory：macro box 内 M5 VDD_LOCAL stripe（addStripe）→ via 叠层 → memory PG pin

VSS：全程共地，回流路径与供电对称
```

### ① 高层段（M11→M9→中间层）：把 global 电铺满全片

- M11/M10 留给顶层打 Power，M9 是本设计内部 PG 的最高层，从这里开始往下做 mesh / stripe。
- 这一段走 **global 网（VDD_CORE）**，不经过 switch、永远有电；`PD_AW_ON` 这种 always-on 域直接挂在它上面。

### ② Power Switch：唯一的水闸

- 输入 `VDD_CORE`，输出 `VDD_LOCAL`；开关一断，下游整个 `PD_PSO` 域掉电——power gating 省功耗的机制（PSO = Power Shut Off）。
- switch 自身的控制 / 驱动一路由 **TVDD** 常供电（即 secondary PG 的实例，见下文 Q 节）。
- 摆放策略（core / channel 分开插、channel 先挡 blockage、边界加 switch 防 IR Drop）详见 [Power Switch：Core / Channel 分区与边界](./power-switch-core-channel.md)。

### ③ 到 std cell：M1/M2 dual rail

- switch 输出的 `VDD_LOCAL` 落到 M1+M2 **并联双轨**：同一电源两层一起走、via 连通，等效电阻小、电流分流，改善 IR Drop。
- row 里每个 std cell 的 primary PG pin 从这两层轨上取电。

### ④ 到 Memory：本地 M5 stripe

- memory 电流大，只靠 rail 不够：在 `TEM5N28HPC*` box 内 `addStripe` 打 **M5 / VDD_LOCAL** 条，且 std 区挡 M5 route blk、指定 memory 区外挡 M5/M6，把 M5 层留给 memory 本地电源（详见 [Innovus PG Special（Memory M5）](../../tcl/innovus-pg-special.md)）。
- stripe 经 via 叠层接到 memory PG pin；Design Browser 看 PG term，memory 侧看到的就是 `VDD_LOCAL` + `VSS`。

### 名词对号入座

| 名词 | 角色 |
|------|------|
| **VDD_CORE** | global 电，switch **之前**，always-on |
| **TVDD** | switch 的控制 / 驱动电源，常供电 |
| **VDD_LOCAL** | switch **之后**的 local 电，PD_PSO 域内 std cell / memory 实际使用 |
| **PD_AW_ON** | always-on 域，直接用 VDD_CORE |
| **PD_PSO** | 可断电域，经 switch 用 VDD_LOCAL |
| **M1/M2 dual rail** | std cell 取电层 |
| **M5 memory stripe** | memory 本地供电层 |

**一句话：高层把 global 电（VDD_CORE）铺满全片 → power switch 这道闸决定哪片区域有电 → 闸后变成 VDD_LOCAL，std cell 走 M1/M2 双轨、memory 走自己的 M5 stripe 拿电。**

## Memory 的供电结构（T12nm）

**总路径：**

```text
Global VDD → TVDD → Power Switch 打开 → VDD_LOCAL 的 power rail
    → 通过 pillar 反爬到高层 → 然后送进 Memory
```

**物理连接（从 Memory 往回看）：**

| 步骤 | 连接 |
|------|------|
| Memory 摆放 | 位于 **PD_PSO** 区域 |
| Memory 出 pin | 在 **M4**，逻辑连接到 **VDD_LOCAL** |
| M5 → M4 | Memory 的 M4 pin 由 **M5 打孔**进来 |
| M6 → M5 | **M5 又跟 M6 打孔** |
| Pillar | M6 找到**就近 pillar**，pillar 从 **M6 打到 M3** |
| Pillar → Switch | M3 之后从**就近 Power Switch** 拿电：switch 的 **M1** 的 TVDD 电有了之后，送到 **M2**，然后在 pillar 上送到 **M3** |

```text
Memory（PD_PSO 区）
  M4 pin ── 逻辑连 VDD_LOCAL
    ▲ via
   M5 ──via── M6 ──► 就近 pillar（M6 … M3）──► M3 ◄── M2 ◄── Power Switch（M1，TVDD）
```

即：switch 打开后 VDD_LOCAL 从低层 rail 经 pillar 反爬到 M6/M5 高层，再打孔逐层送进 Memory 的 M4 pin。

**注记：** 此处口径为 Global VDD → **TVDD** → switch（输入侧）；与上文「Power Switch 与高低层」中 **VDD_CORE** → switch 的表述并存，具体网名以项目 UPF / def 为准。

## 说明

- UPF 先把功耗意图（domain / net / switch 等）交给工具；**Powerplan** 再在物理上把供电从源头接到每个单元与 PG 脚。  
- 典型包括 ring、mesh、stripe、via 叠层，以及接到 std cell / macro 的 PG pin（含 local 如 `VDD_LOCAL`）。  
- 本项目路径：高层 **VDD_CORE** → Power switch → 低层 **M1/M2 的 VDD_LOCAL** → Memory / cell。Switch 侧电源名为 **TVDD、VDD_LOCAL、VSS**。

### T12nm 层结构

| 层 | 角色 |
|------|------|
| **M1** | Power rail |
| **M2** | Power rail |
| **M9** | 本设计 PG 最高层 |
| **M10 / M11** | 顶层打 Power |
| 关系（底层） | M1/M2 **并联 dual rail** |

底层用 M1 + M2 双轨并联供电，再往上接到更高层 stripe / mesh 与源头。

## Q：并联 dual rail 是什么？

在 **「M1 和 M2 是 power rail，并联 dual rail」** 里：

### Dual rail

一般指沿 std cell / row **成对铺的电源轨**：一边（或一层）走 **电源**，一边走 **地**（VDD / VSS，或 local 电源 / VSS）。不是随便两根信号线，而是**供电用的双轨**。

### 并联（M1 ∥ M2）

**M1 和 M2 都当 power rail**，再用 via 把同一电源网在两层上**并联**起来：

```text
更高层 stripe / mesh
        │
   ┌────┴────┐
  M2 power ──via── M1 power ──► cell / PG pin
   └────┬────┘
```

效果是：等效电阻更小，电流可分流，有利于 **IR Drop**。

### 一句话

**Dual rail** = 电源/地那套供电双轨；**并联** = 同一供电在 M1、M2 两层一起走、via 连上，不是只靠单层。

## Q：Primary PG / Secondary PG 是什么？

| 概念 | 含义 |
|------|------|
| **Primary PG** | cell 的主电源脚，接本 domain 的 VDD/VSS（如 VDD_LOCAL） |
| **Secondary PG** | 特殊 cell 上额外的那组电源脚，接的是另一路（通常是 always-on）电源，保证主轨断电时这部分功能还活着 |

需要 Secondary PG 的典型 cell：power switch（gate 驱动要常供电）、isolation cell（钳位电源常在）、retention register（备份状态 always-on）、always-on buffer / enable level shifter、**tap cell**（well tap，secondary PG pin 为 VPP）。

对应本项目：高层 **VDD_CORE / TVDD** 这类常供电网络接到这些 cell 的 secondary pin，普通 std cell 只接 M1/M2 的 **VDD_LOCAL**（见上文「Power Switch 与高低层」）。

**T12nm 中 tap cell 的 secondary PG pin（VPP）逻辑连接到 VDD_CORE。** 脚本佐证：[power_stape_pso](../../tcl/power-stape-pso.md) 图 1 先按 domain 连（PD_AW_ON 域 VPP→VDD_CORE、PD_PSO 域 VPP→VDD_LOCAL）；随后 [Innovus 03 Powerplan](../../tcl/innovus-03-powerplan.md) 图 3 对 `*VPP_VSS` cell（tap cell）先 `setPGPinUseSignalRoute` 让 VPP 走 signal route，再 `globalNetConnect VDD_CORE -type pgpin -pin VPP ... -override` 统一重连到 **VDD_CORE**。

**Core 区域 cell 的电源连接结构（物理）：** tapcell 的连接即是 std cell 的连接——从 **VPP** 出发往上层，接到 **power switch 附近的 pillar**，之后连接 **power switch**：

```text
VPP（tapcell，连接方式同 std cell）
   │  往上层（via 逐层上爬）
   ▼
power switch 附近的 pillar
   │
   ▼
power switch
```

pillar 即 power switch cell 上的 stapling / via pillar，其创建脚本见 [power_stape_pso](../../tcl/power-stape-pso.md)。

## VPP

**VPP：N-well 的连接**（well bias 供电网络，常见于 memory macro 的 PG pin）。

T12nm 本项目中，**tap cell 的 secondary PG pin（VPP）逻辑连接到 VDD_CORE**（详见上文「Primary PG / Secondary PG」一节）。

## Powerplan 质量检查

| 检查项 | 查什么 |
|--------|--------|
| **checkConnectivity** | **PG Floating**：供电网络断连 / 悬空（cell、PG pin 没接上 PG） |
| **Powerplan DRC** | PG 相关工艺规则违例（spacing / enclosure / via 规则等） |
| **PG short** | 电源网络之间短路 |
| **PG Weakness** | 供电薄弱点（via / stripe 不足、通路电阻过大等） |
| **IR Drop 分析** | 压降分析，验证供电网络能否满足电压余量 |

## 相关笔记

- [T12nm · UPF 传递功耗设计意图](./upf-power-intent.md)
- [T12nm · Macro / Std Cell 供电（Global→Switch→Local→Memory）](./pg-term-local-vdd.md)
- [T12nm · Power Switch：Core / Channel 与边界](./power-switch-core-channel.md)
- [Innovus PG Special（Memory M5）](../../tcl/innovus-pg-special.md)
- [Innovus 03 Powerplan 脚本](../../tcl/innovus-03-powerplan.md)
- [Via Pillar 下方不摆放特殊 cell（PG DRC）](../../tcl/via-pillar-pg-keepout.md)
