`timescale 1ns/1ps

// // 独立编译接口
// `include "async_fifo_if.sv"

//  ____  __.          .__         ________        .__               
// |    |/ _|_______  _|__| ____   \_____  \  __ __|__| ____   ____  
// |      <_/ __ \  \/ /  |/    \   /  / \  \|  |  \  |/    \ /    \ 
// |    |  \  ___/\   /|  |   |  \ /   \_/.  \  |  /  |   |  \   |  \
// |____|__ \___  >\_/ |__|___|  / \_____\ \_/____/|__|___|  /___|  /
//         \/   \/             \/         \__>             \/     \/ 
//     ___                                                                       
//   /'___\        __                       /'\_/`\                              
//  /\ \__/  _ __ /\_\     __     _ __     /\      \     __    ___   __  __  __  
//  \ \ ,__\/\`'__\/\ \  /'__`\  /\`'__\   \ \ \__\ \  /'__`\ / __`\/\ \/\ \/\ \ 
//   \ \ \_/\ \ \/ \ \ \/\ \L\.\_\ \ \/     \ \ \_/\ \/\  __//\ \L\ \ \ \_/ \_/ \
//    \ \_\  \ \_\  \ \_\ \__/.\_\\ \_\      \ \_\\ \_\ \____\ \____/\ \___x___/'
//     \/_/   \/_/   \/_/\/__/\/_/ \/_/       \/_/ \/_/\/____/\/___/  \/__//__/  

module async_fifo_tb_top;

/*======================== Parameter and Internal Signal =========================*/

    /*===import===*/
    // 导入uvm基础类
    import uvm_pkg::*;
    // 导入uvm宏
    `include "uvm_macros.svh"
    // 导入自己写的uvm组件
    import async_fifo_pkg::*;

    /*===sig===*/
    logic wclk;
    logic wrst_n;
    logic rclk;
    logic rrst_n;

/*================================== initial ===================================*/

    // 初始化时钟
    // 写时钟：周期 30ns (33.3MHz)
    initial begin
        wclk = 0;
        forever #15ns wclk = ~wclk;
    end

    // 读时钟：周期 10ns (100MHz)
    initial begin
        rclk = 0;
        forever #5ns rclk = ~rclk;
    end

    // 初始化复位
    initial begin
        wrst_n = 1'b0;
        rrst_n = 1'b0;
        #20ns;
        wrst_n = 1'b1;
        rrst_n = 1'b1;
        #10ns;
        wrst_n = 1'b0;
        rrst_n = 1'b0;
        #10ns;
        wrst_n = 1'b1;
        rrst_n = 1'b1;
    end

    // 初始化各输入信号
    initial begin
        intf.winc  = 1'b0;
        intf.wdata = '0;
        intf.rinc  = 1'b0;
    end

/*================================== Instantiation ===============================*/

    // 接口例化
    async_fifo_if #(.DATA_WIDTH(16)) intf (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // DUT
    async_fifo_top #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(6),
        .ALMOST_FULL_THRESHOLD(4),
        .ALMOST_EMPTY_THRESHOLD(4)
    ) u_dut (
        .wclk          (intf.wclk),
        .wrst_n        (intf.wrst_n),
        .winc          (intf.winc),
        .wdata         (intf.wdata),
        .wfull         (intf.wfull),
        .walmost_full  (intf.walmost_full),
        .rclk          (intf.rclk),
        .rrst_n        (intf.rrst_n),
        .rinc          (intf.rinc),
        .rdata         (intf.rdata),
        .rempty        (intf.rempty),
        .ralmost_empty (intf.ralmost_empty)
    );


/*================================== Main Code ===================================*/

    initial begin
        // 将物理接口 intf 存入 uvm_config_db，UVM内部虚接口才能访问到
        // null 表示从顶层开始存，*表示所有组件都能访问
        // vif 是存取的号，必须和 Driver/Monitor中的 get()匹配
        uvm_config_db#(virtual async_fifo_if#(16))::set(null, "*", "vif", intf);
        
        // 阻止 UVM 结束后调用 $finish 强退仿真器把我run.do直接挤掉了，
        uvm_top.finish_on_completion = 0;
        
        // 启动~~~~
        // 仿真命令行参数 +UVM_TESTNAME=xxx 即可找到对应的 Test 类并开始运行
        run_test();
    end
/* 终于写完了，到底是谁周末在重构屎山代码 */


endmodule
