# globalnetconnect-vdd-override.tcl
# 日期：2026-09-24
# 来源：截图识别整理（picture-tcl，1 张截图，原图 docs/tcl/images/globalnetconnect-vdd-override.png）
# 工具：Innovus
#
# 作用：覆盖原先 VDD 的逻辑连接——把 PD_PSO 域内所有 instance（-inst *）的
#       VDD pgpin 逻辑连接到 VDD_LOCAL（-override 覆盖既有连接）。
#
# 转录注记：
# - 原图高 40 px，仅一行；行首提示符 innovus 29>，命令部分逐字符转录
#   （本文件去掉提示符，保留可直接 source 的命令）。
# - 首次整图识别回传了「**info:  global net connect instance pins: 21 ...」
#   回显片段，与单行原图不符（疑为误识别，未采纳）；二次定点识别结果如上，
#   以二次为准，原图备查。

globalNetConnect VDD_LOCAL -type pgpin -pin {VDD} -inst * -powerDomain PD_PSO -override
