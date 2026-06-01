# ##########################################################################################################################
#  !! 警告 !!：请勿随意修改此脚本。除非你完全理解代码逻辑并明确知道你在做什么，否则任何微小的变动都可能导致程序运行异常或系统崩溃。
# 
#  警告 (WARNING):
# 请勿轻易修改本脚本。本代码包含核心逻辑，除非你具备相关的开发经验并完全理解修改后的后果，
# 否则擅自改动可能会导致不可预知的错误。
# ##########################################################################################################################


set lib_name   $1
set build_dir  "../build"

if {![file exists $build_dir]} { file mkdir $build_dir }

if {[file exists $build_dir/$lib_name]} {
    vdel -lib $build_dir/$lib_name -all
}

vlib $build_dir/$lib_name
vmap $lib_name $build_dir/$lib_name

vlog -sv -nologo -quiet -work $lib_name -f file_list.f
