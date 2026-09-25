---
title: 示例：统计 cell 数量
description: 占位示例脚本，演示本栏目的写法
---

# 示例：统计 cell 数量

## 场景

快速查看当前设计里 instance / cell 的大致数量，方便开局摸底。

## 环境

- 工具：常见后端实现工具（命令名可能因工具略有差异）
- 前提：设计已打开

## 用法

在工具 Tcl 控制台直接粘贴执行，或 `source` 保存后的文件。

## 脚本

```tcl
# report_cells.tcl
# 占位示例：请按实际工具命令替换

set cells [get_cells -hierarchical *]
puts "cell count: [sizeof_collection $cells]"
```

## 备注

不同工具里 `get_cells` / `sizeof_collection` 的可用性不一致；接入真实流程前先在目标工具里验证。
