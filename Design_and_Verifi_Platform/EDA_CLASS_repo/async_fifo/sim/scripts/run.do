# ===========================================================================
# 自动多用例运行、合并及过滤的 UVM 仿真脚本 (兼容 ModelSim 10.4)
# ===========================================================================

# 静态报错/报错不杀死tcl线程，把能跑的都跑完先
onbreak {resume}  ;

# 定义路径
set build_dir  "../build"
set log_dir    "../output/log"
set wave_dir   "../output/wave"
set cov_dir    "../output/cov"

set lib_name   "work"
set top_module "async_fifo_tb_top"

# 创建目录
if {![file exists $build_dir]} { file mkdir $build_dir }
if {![file exists $log_dir]}   { file mkdir $log_dir }
if {![file exists $wave_dir]}  { file mkdir $wave_dir }
if {![file exists $cov_dir]}   { file mkdir $cov_dir }

# 映射库
if {[file exists $build_dir/$lib_name]} {
    vdel -lib $build_dir/$lib_name -all
}
vlib $build_dir/$lib_name
vmap $lib_name $build_dir/$lib_name

if {[file exists $env(MODEL_TECH)/../uvm-1.1d]} {
    vmap uvm $env(MODEL_TECH)/../uvm-1.1d
} else {
    vmap uvm $env(MODEL_TECH)/../uvm-1.2
}

# 编译文件
# RTL 编译（开启全套代码覆盖率，注入 1ns/1ps 时间尺度）
vlog -sv -work $lib_name \
     -timescale "1ns/1ps" \
     +cover=bcesft \
     -f file_list_rtl.f

# TB 编译（不开启覆盖率，避免污染）
vlog -sv -work $lib_name \
     -timescale "1ns/1ps" \
     +incdir+$env(MODEL_TECH)/../verilog_src/uvm-1.1d/src \
     -f file_list_tb.f

# 【核心逻辑】循环运行多个测试用例，在test_list里面删补即可
set test_list {fifo_full_empty_test fifo_mixed_test fifo_extreme_test fifo_vibration_test}

foreach test $test_list {
    echo "======================================================"
    echo " Running Test: $test"
    echo "======================================================"
    
    # 启动仿真
    vsim -voptargs="+acc" \
         -coverage \
         -assertdebug \
         -L uvm \
         -l $log_dir/sim_${test}.log \
         -wlf $wave_dir/vsim_${test}.wlf \
         +UVM_TESTNAME=$test \
         $lib_name.$top_module

    # 运行足够长的仿真时间
    run 20ms

    # 保存单次运行的覆盖率数据
    coverage save $cov_dir/${test}.ucdb
    
    # 退出当前仿真实例，准备运行下一个
    quit -sim
}

# 【合并操作】将多个测试的 ucdb 合并为统一的数据库
echo "======================================================"
echo " Merging Coverage Databases..."
echo "======================================================"
vcover merge $cov_dir/merged_cov.ucdb \
             $cov_dir/fifo_full_empty_test.ucdb \
             $cov_dir/fifo_mixed_test.ucdb \
             $cov_dir/fifo_extreme_test.ucdb \
             $cov_dir/fifo_vibration_test.ucdb

# 【过滤报告】仅针对 DUT 实例生成 HTML
echo "======================================================"
echo " Generating HTML Report for DUT only..."
echo "======================================================"
vcover report -html \
              -htmldir $cov_dir/html_cov \
              -code bcesft \
              -assert \
              -source \
              -instance /async_fifo_tb_top/u_dut \
              $cov_dir/merged_cov.ucdb

echo "======================================================"
echo " Coverage Report Generated successfully!"
echo " Please open: $cov_dir/html_cov/index.html in browser."
echo "======================================================"

if {[batch_mode]} {
    quit -force
}