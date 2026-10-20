---
title: CTS 涉及脚本
description: Innovus CTS debug：report_clock_timing、load/driver、Memory sink_type / insertion_delay、hilite capture clock path
date: 2026-10-11
---

# CTS 涉及脚本

> 日期：2026-10-11  
> 来源：截图识别整理（picture-tcl）  
> 阶段：CTS / Clock Tree Debug

CTS 后排查 **insertion delay / clock latency**、沿时钟树查负载与上游 driver、查看 **Memory CLK** 的 `sink_type` / `insertion_delay`，以及在 GUI 里**高亮到 Memory endpoint 的 capture clock path**。

## 场景

1. 查某颗寄存器时钟脚上的 **clock latency**（insertion delay）。  
   clock latency / insertion delay：可理解为 clock root 到 sink 的时间。
2. 加载项目别名脚本后，用 `load` / `driver` 在时钟树上查电容负载、向上追 driver。
3. GUI 选中 Memory 后，查其 **sink_type**、**insertion_delay**，并用 `report_clock_timing -verbose` 看详细 latency。
4. 以 Memory 数据脚（`D*`）为 endpoint，报 timing → 再 **hilite capture clock path**（高亮到达该点的 capture 侧时钟树）。

## 环境

- 工具：Innovus
- 前提：设计已打开、CTS / CCOpt 已完成；`load` / `driver` 来自 `innv_alias.tcl`；`hilitePath_1` 来自 `hilite.tcl`

## 脚本汇总

```tcl
# --- 寄存器 latency / 爬树 ---
report_clock_timing -to u_vcpu/u_cpu/u_ananke_dpu/u_dpu_dp/u_div/rem_carry_reg_17_/CP -type latency
source /home_new/top_data/scripts/innv_alias.tcl
load u_vcpu/u_cpu/CTS_cfo_inv_03828/ZN
driver u_vcpu/u_cpu/CTS_cfo_inv_03828/I

# --- Memory：sink_type / insertion_delay / timing report ---
dbGet selected.name
get_ccopt_property sink_type -pin u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK
get_ccopt_property insertion_delay -pin u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK
report_clock_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK -type latency -verbose

# --- 高亮到 Memory endpoint 的 capture clock path ---
report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D*
set path "report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D* -path_type full_clock"
report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D* -path_type full_clock
source /data/scripts/innovus_hilite/hilite.tcl
hilitePath_1 -capture_clock_path -deselectAll -report_timing_args $path
```

---

## 一、寄存器 latency / 爬树

```tcl
report_clock_timing -to u_vcpu/u_cpu/u_ananke_dpu/u_dpu_dp/u_div/rem_carry_reg_17_/CP -type latency
source /home_new/top_data/scripts/innv_alias.tcl
load u_vcpu/u_cpu/CTS_cfo_inv_03828/ZN
driver u_vcpu/u_cpu/CTS_cfo_inv_03828/I
```

| 命令 | 作用 |
|------|------|
| `report_clock_timing -to <sink> -type latency` | 报该 sink 的 clock latency（insertion delay） |
| `source .../innv_alias.tcl` | 加载项目 alias（后续 `load` / `driver` 依赖它） |
| `load <pin>` | 查 pin / net 电容负载（本例 CTS inverter 输出 `ZN`） |
| `driver <pin>` | 查上游 driver，沿时钟树往根追一级（本例 inverter 输入 `I`） |

---

## 二、Memory：sink_type / insertion_delay / timing report

对象：`u_tlb_tag_bank0`（Memory）的 `CLK`。流程：GUI 选中 Memory → `dbGet selected.name` → 拼 `/CLK` 再查。

```tcl
dbGet selected.name
# 回显示例：u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0

get_ccopt_property sink_type -pin u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK
# 回显示例：auto

get_ccopt_property insertion_delay -pin u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK
# 回显示例：auto

report_clock_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/CLK -type latency -verbose
```

| 命令 | 作用 |
|------|------|
| `dbGet selected.name` | 取 GUI 当前选中对象层次名 |
| `get_ccopt_property sink_type -pin <mem>/CLK` | 查 Memory 时钟脚 sink type（本例 `auto`） |
| `get_ccopt_property insertion_delay -pin <mem>/CLK` | 查 insertion_delay 属性（本例 `auto`） |
| `report_clock_timing -to <mem>/CLK -type latency -verbose` | 详细报告到 Memory CLK 的 latency |

---

## 三、高亮到 Memory 的 capture clock tree

**做完cts后可以去高亮到memeory的tree看有没有detour**

目的：GUI **高亮到达该 Memory endpoint 的 capture 侧时钟路径**。  
endpoint 用数据脚 `.../u_tlb_tag_bank0/D*`（以数据端为 timing 终点，再抽 capture clock）。

```tcl
report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D*

set path "report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D* -path_type full_clock"

report_timing -to u_vcpu/u_cpu/u_ananke_tlb/u_tlb_tag_data_ram/u_tlb_tag_bank0/D* -path_type full_clock

source /data/scripts/innovus_hilite/hilite.tcl

hilitePath_1 -capture_clock_path -deselectAll -report_timing_args $path
```

| 命令 / 选项 | 作用 |
|-------------|------|
| `report_timing -to <mem>/D*` | 报到 Memory 数据脚的 timing path |
| `set path "report_timing ... -path_type full_clock"` | 存 hilite 用的 report_timing 参数串 |
| `report_timing ... -path_type full_clock` | 含 full clock 的 timing 报告 |
| `source .../hilite.tcl` | 加载 `hilitePath_1` |
| `-capture_clock_path` | 高亮 capture 侧时钟路径（不是 data path） |
| `-deselectAll` | 先清掉当前选中 / 高亮 |
| `-report_timing_args $path` | 使用前面 `set path` 存下的参数 |

---

## 四、高亮到物理路径最长的path

```tcl
source /data/scripts/innovus_clock_debug_scripts/finding_geometric_farthest_sink.tcl

findingFarthestSink -in_clock_tree coreclk -root coreclk -skew_group coreclk/func
```

如果发现物理路径太长了，可以重新cts在 clusting 后摆path把路径做短，然后再继续 Balance -> Routing Clock Net -> Post Conditioning(CTS后续脚本)

作为一个问题的case 去分析， cts后发现物理路径太长了，通过单独做 clustering后摆path的方法解决完后在继续 balance、clock net routing、post conditioning

---

## 五、驱动设大

```tcl
# 原先的 cell 驱动为
u_cortexa7noram/u_ca7tlb/U6537 IGA22D48WP40PI40

# 驱动设大 pt_shell
size_cell u_cortexa7noram/u_ca7tlb/U6537 IGA22D68WP40PI40

# 查看这款cell有哪些驱动
get_lib_cell */IGA22D*8WP40PI40
```

---

## 相关笔记

- [Clock Tree Debug 高频命令](./ccopt-clock-tree-debug.md)
- [Innovus CCOpt CTS 脚本](./innovus-ccopt-cts.md)
- [CCOpt target_skew](./ccopt-target-skew.md)
- [CTS：CCOpt Mode、漏 Tree 与 Debug](../experience/t12nm/cts-ccopt-mode-debug.md)
- [Case：Clock Tree ECO 做短 Launch Path](../experience/t12nm/cts-eco-shorten-launch.md)
- [CTS 要点：Sink Type / insertion_delay](../experience/t12nm/cts.md)
