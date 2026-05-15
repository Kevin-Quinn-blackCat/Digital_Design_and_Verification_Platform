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
# 注意：这里不再套用 proc，直接执行 vsim
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