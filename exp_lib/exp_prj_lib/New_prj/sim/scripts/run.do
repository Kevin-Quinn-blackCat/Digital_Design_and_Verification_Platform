# ##########################################################################################################################
#  !! 警告 !!：请勿随意修改此脚本。除非你完全理解代码逻辑并明确知道你在做什么，否则任何微小的变动都可能导致程序运行异常或系统崩溃。
# 
#  警告 (WARNING):
# 请勿轻易修改本脚本。本代码包含核心逻辑，除非你具备相关的开发经验并完全理解修改后的后果，
# 否则擅自改动可能会导致不可预知的错误。
# ##########################################################################################################################


# ---------------------------------------------------------------------------
# 变量获取 (来自 Makefile 的传参)
# $1: TOP_MODULE, $2: SIM_TIME, $3: LIB_NAME
# ---------------------------------------------------------------------------
set top_module $1
set sim_time   $2
set lib_name   $3

# 1. 定义路径（相对于执行命令的 workspace 目录）
set build_dir  "../build"
set log_dir    "../output/log"
set wave_dir   "../output/wave"

# 2. 创建必要的目录
if {![file exists $build_dir]} { file mkdir $build_dir }
if {![file exists $log_dir]}   { file mkdir $log_dir }
if {![file exists $wave_dir]}  { file mkdir $wave_dir }

# 3. 编译库准备
if {[file exists $build_dir/$lib_name]} {
    # 仅在非仿真运行状态下尝试删除库，防止锁死
    vdel -lib $build_dir/$lib_name -all
}
vlib $build_dir/$lib_name
vmap $lib_name $build_dir/$lib_name

# 4. 编译文件
vlog -sv -work $lib_name -f file_list.f

# 5. 启动仿真
vsim -voptargs="+acc" \
     -l $log_dir/sim.log \
     -wlf $wave_dir/vsim.wlf \
     $lib_name.$top_module

# 6. 添加波形 (如果是 GUI 模式则执行)
# 在 ModelSim 中，用 [batch_mode] 检查是否为命令行模式
if {[batch_mode] == 0} {
    add wave -position insertpoint sim:/$top_module/*
}

# 7. 运行仿真
run $sim_time