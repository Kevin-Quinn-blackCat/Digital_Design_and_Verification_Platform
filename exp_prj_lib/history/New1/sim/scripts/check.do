set lib_name   $1
set build_dir  "../build"

if {![file exists $build_dir]} { file mkdir $build_dir }

if {[file exists $build_dir/$lib_name]} {
    vdel -lib $build_dir/$lib_name -all
}

vlib $build_dir/$lib_name
vmap $lib_name $build_dir/$lib_name

vlog -sv -nologo -quiet -work $lib_name -f file_list.f
