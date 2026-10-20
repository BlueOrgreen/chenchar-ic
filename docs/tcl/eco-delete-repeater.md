---
title: ecoDeleteRepeater（删除 Buffer / Repeater）
description: Innovus ECO 删除 hold buffer 等 repeater；配合选中 PHC 后 ecoDeleteRepeater
date: 2026-10-17
---

# ecoDeleteRepeater（删除 Buffer / Repeater）

> 日期：2026-10-17  
> 工具：Innovus  
> 阶段：ECO / PostCTS Hold 过修清理  
> 用途：删除已插入的 **buffer / repeater**（如过多的 **PHC** hold buffer）

判定 hold buffer 过修（例如一条 path 上 PHC 明显多于 2～3 颗）后，可用 **`ecoDeleteRepeater`** 删掉选定的 repeater，网表会重连绕过该 buffer。

## 常用用法

先选中要删的 instance（例如全部或局部 PHC）：

```tcl
select_obj [dbGet top.insts.name *PHC*]
# 或只选某一颗 / 某一批
# selectInst FE_PHC203791_bias_table_10__1
```

再删除：

```tcl
ecoDeleteRepeater
```

按选中对象删除（具体参数以当前 Innovus 版本文档为准；无项目常用即对当前 selection 执行 `ecoDeleteRepeater`）。

删完后建议：

1. 再 `report_timing`（hold）确认 slack / PHC 数量  
2. 若根因是 CRPR=0，仍应 **重做 clock propagated**，避免删完工具又按错误口径插回来  

## 相关笔记

- [T12nm · Case：Hold Buffer 过多（CRPR=0）](../experience/t12nm/hold-phc-too-many-crpr.md)
- [T12nm · Hold Time Analysis](../experience/t12nm/hold-time-analysis.md)
- [insert_port_buffer（端口插 Buffer）](./insert-port-buffer.md)
