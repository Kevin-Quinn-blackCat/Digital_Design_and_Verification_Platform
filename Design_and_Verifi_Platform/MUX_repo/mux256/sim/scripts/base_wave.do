# 获取顶层设计名
set top_module $1

# 遇到错误时继续执行此脚本
onerror {resume}

# 添加分割符
# add wave -divider "GLOBAL CONTROL"
# add wave -color "Cyan" /$top_module/sys_clk
# add wave -color "Cyan" /$top_module/sys_rst_n

# 只显示信号名，不显示完整的层次路径
configure wave -signalnamewidth 1

# 设置信号名字列和数值列的宽度
configure wave -namecolwidth 250
configure wave -valuecolwidth 100

# 使得数值显示靠右对齐，方便阅读
configure wave -justifyvalue right

# 设置时间单位显示
configure wave -timelineunits ns

# 开启或关闭网格线：0 关闭，1 开启
# configure wave -gridperiod 1

# 更新上述设置
update

# 设置初始缩放范围。从 0 ns 到 1000 ns。
# 注意：如果仿真时间还没到 1000ns，它会缩放到当前仿真的最大时间
WaveRestoreZoom {0 ns} {1000 ns}

