---
title: UPF 传递功耗设计意图
description: UPF 把功耗意图（constraint）传给 EDA；电源网络主要命令 create_supply_port/net、connect、power_switch
date: 2026-09-21
---

# UPF 传递功耗设计意图

> 工艺：T12nm（12nm ARM A55）  
> 阶段：低功耗 / Floorplan / 物理实现  
> 类型：方法口径 / 经验记录

## 口径

**UPF 是把功耗的设计意图（constraint）传递给 EDA 工具，从而帮助物理设计。**

## 说明

- UPF（Unified Power Format）是功耗侧的 **constraint / 意图文件**：把 power domain、电源网、开关、isolation / level shifter 等设计意图正式交给 EDA。  
- 物理工具（如 Innovus）通过 `read_power_intent` / `commit_power_intent` 读入后，按这些约束做 floorplan、power switch、供电与跨域检查。  
- 没有 UPF，工具缺少功耗意图，物理实现难以正确落实多电源 / 关断等策略。  
- 本项目有 `ananke_core.upf` 以及 `PD_PSO`、`PD_AW_ON` 等，均来自这类意图（constraint）传递。

## UPF 主要组成部分：Power Supply Network

电源供给网络相关命令（课件：**Power Supply Network Commands**）。记住：这些都是 **UPF 里描述的逻辑对象**，不是已经画好的物理金属。

![UPF Power Supply Network](./images/upf-supply-network.png)

### 命令解析

| 命令 | 作用 | 怎么理解 |
|------|------|----------|
| **`create_supply_port`** | 在指定 scope / 层次上创建 **supply port** | 该层次上的电源“端口”；同 scope 内 power domain 可共用 |
| **`create_supply_net`** | 创建电源/地的 **逻辑网** | 逻辑上的供电线（logical power/ground），还不是物理 stripe |
| **`connect_supply_net`** | 把 supply net 连到一个或多个 supply port | 把“线”接到“口”，建立层次间供电连通关系 |
| **`create_power_switch`** | 定义可开关供电：输入常电、输出 virtual supply、以及 sleep 等控制 | 对应 Power Gating：常电 → switch → 可关断域电源 |


1. **Port + Net**：描述哪一层有电源口、逻辑电源网叫什么。  
2. **connect**：上下层如何把供电接进来（外层 Net2 → 内层 Port3 → Net3）。  
3. **power switch**：Net3 作为输入，经 switch 得到 **VirtualSupply** 再给可关断逻辑；`sleep` 控制开/关。  

与本项目 **Global VDD → Power Switch → VDD_LOCAL → Memory** 同一类模型：UPF 先定义逻辑意图，物理阶段再落成 `addPowerSwitch`、stripe 等。

## UPF 组成部分详解（推荐书写顺序）

如图，按下面顺序写完功耗意图，再交给 EDA：

```text
1. 定义 power domain
2. 定义 supply ports
3. 定义 supply nets
4. 联通（connect）
5. 定义 Top 的 power rail
6. 定义 switch domain 的 power rail
7. 定义开关的行为描述
8. 定义 isolation cell
9. 最后定义 PST
```

| 步骤 | 做什么 | 课件/命令例 |
|------|--------|-------------|
| 1. Power domain | 划常开域与可关断域 | `create_power_domain TOP`；`create_power_domain PD_SW -elements pd_switchable`（`-elements` 绑 **Module**） |
| 2. Supply ports | 顶层电源/地口 | `create_supply_port VDD` / `VDDL` / `VSS` |
| 3. Supply nets | 逻辑电源网（含 local） | `create_supply_net VDD` / `VDDL` / `VSS` / `VDDLS1`（图中 local ≈ VDD LOCAL） |
| 4. Connect | net 接到 port | `connect_supply_net VDD -ports {VDD}` 等 |
| 5. Top power rail | 常开域供电轨意图 | Top / leon3s 等用 VDD（如 1.08V） |
| 6. Switch domain rail | 可关断域用 switched / local 轨 | `PD_SW` 内 `pd_switchable` 用 `VDDLS1`（0.9V / OFF） |
| 7. Switch 行为 | 开关输入/输出/控制 | `create_power_switch`：VDDL 入 → switch → VDDLS1；`on/off` 由 power_controller |
| 8. Isolation cell | 关断域输出钳位 | 防 X；见 [Isolation Cell](./isolation-cell.md) |
| 9. PST | Power State Table | 定义各 supply 在不同电源状态下的组合关系 |

### 图：定义 Power Domain & PG ports

![Create power domain & PG ports](./images/upf-create-power-domain.jpg)

```tcl
create_power_domain TOP
create_power_domain PD_SW -elements pd_switchable

create_supply_port VDD
create_supply_port VDDL
create_supply_port VSS
```

### 图：Create Nets

![Create supply nets](./images/upf-create-nets.jpg)

```tcl
create_supply_net VDD
create_supply_net VDDL
create_supply_net VSS
create_supply_net VDDLS1
```

课件注：`VDDLS1` 为 switch 后的 local（图注 VDD LOCAL）；power switch 可稍后正式定义，图中先画出便于理解。

### 图：Connect Nets

![Connect supply nets](./images/upf-connect-nets.jpg)

```tcl
connect_supply_net VDD -ports {VDD}
connect_supply_net VDDL -ports VDDL
connect_supply_net VSS -ports {VSS}
```

联通后：`VDDL` → power switch → `VDDLS1` 供 `pd_switchable`；`on/off` 控制开关。

### 图: Domian Nets

给 Domain 规划 power rail

![alt text](./images/domain-net.png)

## 相关笔记

- [T12nm · 低功耗设计手段](./low-power-design.md)
- [T12nm · Isolation Cell](./isolation-cell.md)
- [T12nm · Macro / Std Cell 供电（Global→Switch→Local→Memory）](./pg-term-local-vdd.md)
- [T12nm · Power Switch：Core / Channel 与边界](./power-switch-core-channel.md)
- [Innovus 02 Floorplan](../../tcl/innovus-02-floorplan.md)

## 附录：本项目 UPF 完整脚本（截图拼合）

> 来源：T12nm 项目 UPF 截图识别整理（picture-tcl，四张连续截图拼合）  
> 对应上文书写顺序：domain → port/net → connect → primary rail → switch → isolation → PST。

### 截图

![UPF 1/4 domain / port / net / connect](./images/upf-t12nm-1.png)

![UPF 2/4 primary supply / power switch](./images/upf-t12nm-2.png)

![UPF 3/4 isolation](./images/upf-t12nm-3.png)

![UPF 4/4 PST](./images/upf-t12nm-4.png)

### 完整脚本

```tcl
#set enable_ao_synthesis true
#set keep_mv_net_dont_touch true
#set compile_power_domain_boundary_optimization false
#set upf_create_implicit_supply_sets false

###########################
# power domain define
###########################
create_power_domain PD_AW_ON -include_scope -exclude_elements {u_vcpu} -supply {extra_supplies ""}
create_power_domain PD_PSO -elements {u_vcpu}
#create_power_domain PD_AW_ON -exclude_elements {u_vcpu}

###########################
# create supply port
###########################
create_supply_port VDD_CORE  -domain PD_AW_ON -direction in
create_supply_port VSS       -domain PD_AW_ON -direction in

###########################
# create supply net at top level
###########################
create_supply_net VDD_CORE   -domain PD_AW_ON
create_supply_net VSS        -domain PD_AW_ON

###########################
# create supply net at child level
###########################
create_supply_net VDD_CORE   -domain PD_PSO -reuse
create_supply_net VDD_LOCAL  -domain PD_PSO
create_supply_net VSS        -domain PD_PSO -reuse

###########################
# connect supply nets to ports
###########################
connect_supply_net VDD_CORE  -port VDD_CORE
connect_supply_net VSS       -port VSS

#############################################
# specify primary supply net for power domain
#############################################
set_domain_supply_net PD_AW_ON -primary_power_net VDD_CORE -primary_ground_net VSS
set_domain_supply_net PD_PSO -primary_power_net VDD_LOCAL -primary_ground_net VSS

#############################################
# create power switch for PD_PSO/CPU1/CPU2/CPU3
#############################################
create_power_switch PWS_PD_PSO -domain PD_PSO \
    -output_supply_port {PD_PSO_VDD_OUT  VDD_LOCAL       } \
    -input_supply_port  {PD_PSO_VDD_IN   VDD_CORE        } \
    -control_port       {PD_PSO_PWS_CTRL pd_dwn_req      } \
    -on_state           {PD_PSO_PWS_ON   PD_PSO_VDD_IN   {!PD_PSO_PWS_CTRL}} \
    -ack_port           {PD_PSO_PWS_ACK  u_vcpu/pd_dwn_ack }

###############################
#insert iso cell
###############################

##PD_PSO
set_isolation PD_PSO2MP \
    -domain PD_PSO \
    -no_isolation \
    -applies_to inputs

set_isolation PD_PSO2MP_LOW \
    -domain PD_PSO \
    -isolation_power_net VDD_CORE \
    -isolation_ground_net VSS \
    -clamp_value 0 \
    -applies_to outputs

set_isolation_control PD_PSO2MP_LOW \
    -domain PD_PSO \
    -isolation_signal pd_dwn_clamp_n \
    -isolation_sense low \
    -location parent

set_isolation PD_PSO_ISO_OUT_NO \
    -domain PD_PSO \
    -no_isolation \
    -elements u_vcpu/pd_dwn_ack

##pst
add_port_state VDD_CORE                   -state {NOR_VOL 0.72}
add_port_state VSS                        -state {GND     0.0}
add_port_state PD_PSO/PD_PSO_VDD_OUT      -state {NOR_VOL 0.72}
add_port_state PD_PSO/PD_PSO_VDD_OUT      -state {OFF_VOL off}

create_pst PD_CPU_PST -supplies [list VDD_CORE VDD_LOCAL VSS]

add_pst_state PST_PD1_ON           -pst PD_CPU_PST -state {NOR_VOL NOR_VOL GND} ;#all on
add_pst_state PST_PD2_OFF          -pst PD_CPU_PST -state {NOR_VOL OFF_VOL GND} ;#all off
```

### 脚本解析

| 段落 | 在写什么 | 和本项目的对应 |
|------|----------|----------------|
| Domain | `PD_AW_ON`：当前 scope 常开，排除 `u_vcpu`；`PD_PSO`：只含 `u_vcpu`（可关断） | Always-on vs Power Shut Off |
| Supply port / net | 顶层 `VDD_CORE`/`VSS`；子域 **reuse** 常电网，并新建 `VDD_LOCAL` | Global 常电 + switch 后 local |
| Connect | net ↔ port | 供电入口接好 |
| Primary supply | AO 用 `VDD_CORE`；PSO 用 `VDD_LOCAL` | 可关断域主电源是 local |
| Power switch | `VDD_CORE` → `PWS_PD_PSO` → `VDD_LOCAL`；`pd_dwn_req` 控制（低有效为 on：`{!PD_PSO_PWS_CTRL}`）；ack 为 `u_vcpu/pd_dwn_ack` | 与物理 `addPowerSwitch` 同一意图 |
| Isolation | 输入不插 ISO；输出 clamp 0，供电用 always-on 的 `VDD_CORE`，控制 `pd_dwn_clamp_n`（low，放 parent）；`pd_dwn_ack` 单独 `-no_isolation` | 关断时输出钳位，ack 不隔离 |
| PST | `VDD_CORE`/`VDD_LOCAL`/`VSS` 组合：全开 `NOR/NOR/GND`，CPU 关 `NOR/OFF/GND`（0.72V / off） | 合法电源状态表 |

**读法一句话：** 常开域吃 `VDD_CORE`；`u_vcpu` 在 `PD_PSO`，经 power switch 吃 `VDD_LOCAL`；关断时输出靠 always-on 供电的 isolation clamp，PST 声明「核开 / 核关」两种合法状态。
