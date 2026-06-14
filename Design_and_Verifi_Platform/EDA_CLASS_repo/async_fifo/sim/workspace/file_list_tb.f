// =========================================================================
// Verification Source Files (TB) - Coverage Disabled
// =========================================================================

// 1. 指定 include 寻找路径（指向 TB 源码存放的实际目录）
+incdir+../../tb

// 2. 先编译含有所有 UVM Class 文件的包
../../tb/async_fifo_if.sv
../../tb/async_fifo_pkg.sv

// 3. 最后编译顶层测试平台
../../tb/async_fifo_tb_top.sv