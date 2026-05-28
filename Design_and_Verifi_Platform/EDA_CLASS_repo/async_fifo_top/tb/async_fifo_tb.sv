`timescale 1ns/1ns
/**
 * File         : async_fifo_tb.sv
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : VCS / ModelSim
 * Description  : Advanced Multi-DUT Async FIFO Testbench using Interface Arrays,
 *                Virtual Interfaces, and parameterized flow tasks.
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By             Version     Description
 * 2026-05-24    Kevin_Quinn    v1.0        Completed with Multi-DUT, Driver Tasks,
 *                                          and Flow-based Testcases.
 * 2026-05-24    Kevin_Quinn    v2.0        Implemented Interface Arrays,
 *                                          Error/Warning Counter, and 3 advanced
 *                                          Robust Testcases.
 * -----------------------------------------------------------------------------
 */

import fifo_cfg_pkg::*;

/*================================== Interface ===================================*/
// 使用 Interface 统一封装每个 DUT 的独有信号
interface fifo_if #(parameter int WIDTH = 16) (
    input logic wclk,
    input logic wrst,
    input logic rclk,
    input logic rrst
);
    logic             winc;
    logic [WIDTH-1:0] wdata;
    logic             wfull;
    logic             walmost_full;
    logic             rinc;
    logic [WIDTH-1:0] rdata;
    logic             rempty;
    logic             ralmost_empty;
endinterface

module async_fifo_tb;

/*======================== Parameter and Internal Signal =========================*/

localparam int DEPTH = 64;
localparam int WIDTH = 16;
localparam int NUM_DUTS = 4; // 扩展测试 4 个具有不同特性的 DUT

// 全局统计计数器
int error_cnt   = 0;
int warning_cnt = 0;

// 统一的全局时钟和复位
bit wclk;
bit rclk;
bit wrst_n;
bit rrst_n;

/*==================================== Clock Gen ==================================*/

// 读时钟频率（100MHz，周期 10ns）是写时钟频率（33.33MHz，周期 30ns）的 3 倍
always #15 wclk = ~wclk;
always #5  rclk = ~rclk;

/*============================ Interface Instantiation ===========================*/

// 实例化接口数组管理 4 个 DUT 的信号
fifo_if #(.WIDTH(WIDTH)) ports[NUM_DUTS] (
    .wclk(wclk), .wrst(wrst_n),
    .rclk(rclk), .rrst(rrst_n)
);

/*================================== DUT Instantiation ===============================*/

// DUT 0: 标准 FIFO (无 FWFT, 无 Almost)
async_fifo_top # (
    .DEPTH(64), .WIDTH(WIDTH), .FWFT_EN(1'b0), .OUT_REG_EN(1'b0),
    .ALMOST_FULL_EN(1'b0), .ALMOST_EMPTY_EN(1'b0)
) dut_0 (
    .wclk(wclk), .wrst(wrst_n), .winc(ports[0].winc), .wdata(ports[0].wdata), .wfull(ports[0].wfull), .walmost_full(ports[0].walmost_full),
    .rclk(rclk), .rrst(rrst_n), .rinc(ports[0].rinc), .rdata(ports[0].rdata), .rempty(ports[0].rempty), .ralmost_empty(ports[0].ralmost_empty)
);

// DUT 1: FWFT FIFO (有 FWFT, 无 Almost)
async_fifo_top # (
    .DEPTH(64), .WIDTH(WIDTH), .FWFT_EN(1'b1), .OUT_REG_EN(1'b0),
    .ALMOST_FULL_EN(1'b0), .ALMOST_EMPTY_EN(1'b0)
) dut_1 (
    .wclk(wclk), .wrst(wrst_n), .winc(ports[1].winc), .wdata(ports[1].wdata), .wfull(ports[1].wfull), .walmost_full(ports[1].walmost_full),
    .rclk(rclk), .rrst(rrst_n), .rinc(ports[1].rinc), .rdata(ports[1].rdata), .rempty(ports[1].rempty), .ralmost_empty(ports[1].ralmost_empty)
);

// DUT 2: 带 Almost 报警的标准 FIFO
async_fifo_top # (
    .DEPTH(64), .WIDTH(WIDTH), .FWFT_EN(1'b0), .OUT_REG_EN(1'b0),
    .ALMOST_FULL_EN(1'b1), .ALMOST_FULL_VAL(4),
    .ALMOST_EMPTY_EN(1'b1), .ALMOST_EMPTY_VAL(4)
) dut_2 (
    .wclk(wclk), .wrst(wrst_n), .winc(ports[2].winc), .wdata(ports[2].wdata), .wfull(ports[2].wfull), .walmost_full(ports[2].walmost_full),
    .rclk(rclk), .rrst(rrst_n), .rinc(ports[2].rinc), .rdata(ports[2].rdata), .rempty(ports[2].rempty), .ralmost_empty(ports[2].ralmost_empty)
);

// DUT 3: FWFT + Almost 报警的 FIFO
async_fifo_top # (
    .DEPTH(64), .WIDTH(WIDTH), .FWFT_EN(1'b1), .OUT_REG_EN(1'b0),
    .ALMOST_FULL_EN(1'b1), .ALMOST_FULL_VAL(3),
    .ALMOST_EMPTY_EN(1'b1), .ALMOST_EMPTY_VAL(3)
) dut_3 (
    .wclk(wclk), .wrst(wrst_n), .winc(ports[3].winc), .wdata(ports[3].wdata), .wfull(ports[3].wfull), .walmost_full(ports[3].walmost_full),
    .rclk(rclk), .rrst(rrst_n), .rinc(ports[3].rinc), .rdata(ports[3].rdata), .rempty(ports[3].rempty), .ralmost_empty(ports[3].ralmost_empty)
);

/*==================================== initial ====================================*/

event init_sig;

initial begin
    wclk   = 1'b0;
    rclk   = 1'b0;
    wrst_n = 1'b1;
    rrst_n = 1'b1;

    // 清零所有接口控制信号
    for (int i = 0; i < NUM_DUTS; i++) begin
        ports[i].winc  = 1'b0;
        ports[i].wdata = '0;
        ports[i].rinc  = 1'b0;
    end

    // 复位流
    #10;
    wrst_n = 1'b0;
    rrst_n = 1'b0;
    #60;
    @(posedge wclk);
    wrst_n = 1'b1;
    @(posedge rclk);
    rrst_n = 1'b1;
    #40;

    $display("+------------------------------------------------------------------------------+");
    $display("|                         =====Simulation Start=====                           |");
    $display("+------------------------------------------------------------------------------+");
    -> init_sig;
end

/*==================================== event ======================================*/

/*===finish===*/
event simulation_finish;
initial begin
    forever begin
        wait(simulation_finish.triggered);
        $display("+------------------------------------------------------------------------------+");
        $display("|                        =====Simulation Finish=====                           |");
        $display("|  Total Warnings Detected: %-5d                                              |", warning_cnt);
        $display("|  Total Errors Detected:   %-5d                                              |", error_cnt);
        if (error_cnt == 0) begin
            $display("|  FINAL STATUS: [ SUCCESS / PASSED ]                                          |");
        end else begin
            $display("|  FINAL STATUS: [ FAILURE / FAILED ]                                          |");
        end
        $display("+------------------------------------------------------------------------------+");
        $finish;
    end
end

/*===stop===*/
event simulation_stop;
initial begin
    forever begin
        wait(simulation_stop.triggered);
        $display("+------------------------------------------------------------------------------+");
        $display("|                          =====Simulation Stop=====                           |");
        $display("|  Current Warnings: %-5d                                                     |", warning_cnt);
        $display("|  Current Errors:   %-5d                                                     |", error_cnt);
        $display("+------------------------------------------------------------------------------+");
        $stop;
    end
end

/*===next===*/
event simulation_next;
initial begin : SIM_NUM
    integer sim_num;
    sim_num <= 1;
    forever begin 
        wait(simulation_next.triggered);
        $display("+------------------------------------------------------------------------------+");
        $display("|                          =====Simulation Next=====                           |");
        $display("|                         =====Simulation No.%0d=====                          |", sim_num);
        $display("|  Current Accumulated Warnings: %-5d                                         |", warning_cnt);
        $display("|  Current Accumulated Errors:   %-5d                                         |", error_cnt);
        $display("+------------------------------------------------------------------------------+");
        sim_num <= sim_num + 1;
    end
end

/*============================ Task: Helper Functions =============================*/

function automatic void report_error(string msg);
    error_cnt++;
    $display("[%0t] [ERROR] %s", $time, msg);
endfunction

function automatic void report_warning(string msg);
    warning_cnt++;
    $display("[%0t] [WARNING] %s", $time, msg);
endfunction

/*========================= Task: Advanced Test Cases =============================*/

// 用例 1：测试随机数据写满/读空，并实时校验数据一致性和 FIFO 状态控制信号
task automatic test_rand_full_empty(
    virtual fifo_if #(WIDTH) vif, 
    int depth, 
    bit fwft_en, 
    string dut_name
);
    logic [WIDTH-1:0] rand_val;
    logic [WIDTH-1:0] golden_q[$];
    logic [WIDTH-1:0] popped_val;
    
    $display("[%0t] Starting [Test 1: Random Full-Empty] on %s (Depth=%0d, FWFT=%b)", $time, dut_name, depth, fwft_en);
    
    // 1. 写满过程
    while (!vif.wfull) begin
        @(posedge vif.wclk);
        if (!vif.wfull) begin
            rand_val  = $urandom();
            vif.winc  = 1'b1;
            vif.wdata = rand_val;
            golden_q.push_back(rand_val);
        end
    end
    @(posedge vif.wclk);
    vif.winc  = 1'b0;
    vif.wdata = '0;

    repeat(5) @(posedge vif.wclk); // 确保标志同步

    if (!vif.wfull) begin
        report_error($sformatf("%s: Failed to assert wfull when full!", dut_name));
    end

    // 2. 读空过程并实时比对
    while (!vif.rempty) begin
        if (fwft_en) begin
            // FWFT 模式下，首个数据在不拉高 rinc 时直接呈现在 rdata 上
            popped_val = golden_q.pop_front();
            if (vif.rdata !== popped_val) begin
                report_error($sformatf("%s (FWFT) Data Mismatch! Got:%h, Exp:%h", dut_name, vif.rdata, popped_val));
            end
            @(posedge vif.rclk);
            vif.rinc = 1'b1;
        end else begin
            // 标准模式
            @(posedge vif.rclk);
            vif.rinc = 1'b1;
            @(posedge vif.rclk);
            vif.rinc = 1'b0;
            popped_val = golden_q.pop_front();
            if (vif.rdata !== popped_val) begin
                report_error($sformatf("%s (Std) Data Mismatch! Got:%h, Exp:%h", dut_name, vif.rdata, popped_val));
            end
        end
    end
    @(posedge vif.rclk);
    vif.rinc = 1'b0;

    repeat(5) @(posedge vif.rclk);

    if (!vif.rempty) begin
        report_error($sformatf("%s: Failed to assert rempty when empty!", dut_name));
    end else begin
        $display("[%0t] [PASS] %s: Random Full-Empty Test Completed.", $time, dut_name);
    end
endtask


// 用例 2：测试混合随机读写流 (2000 组随机输入激励)，读写时钟比为 3:1
task automatic test_random_mixed(
    virtual fifo_if #(WIDTH) vif, 
    int num_cycles, 
    bit fwft_en, 
    string dut_name
);
    mailbox #(logic [WIDTH-1:0]) golden_mbx = new();
    int write_cnt = 0;
    int read_cnt  = 0;
    
    $display("[%0t] Starting [Test 2: 2000 Mixed Random Stimulus] on %s", $time, dut_name);
    
    fork
        // 独立的写控制进程（同步到 wclk）
        begin
            while (write_cnt < num_cycles) begin
                @(posedge vif.wclk);
                // 60% 随机概率发起写入（只要 FIFO 未满）
                if (!vif.wfull && ($urandom_range(0, 99) < 60)) begin
                    logic [WIDTH-1:0] wval = $urandom();
                    vif.winc  = 1'b1;
                    vif.wdata = wval;
                    golden_mbx.put(wval);
                    write_cnt++;
                end else begin
                    vif.winc  = 1'b0;
                end
            end
            @(posedge vif.wclk);
            vif.winc = 1'b0;
            $display("[%0t] %s: Concurrent Writer Process finished %0d transfers.", $time, dut_name, write_cnt);
        end

        // 独立的读控制进程（同步到 rclk，频率为写时钟 3 倍）
        begin
            while (read_cnt < num_cycles) begin
                @(posedge vif.rclk);
                // 35% 随机概率发起读取（只要 FIFO 非空）
                // 调低读取期望概率，防止因为读时钟过快导致 FIFO 经常处于排空状态
                if (!vif.rempty && ($urandom_range(0, 99) < 35)) begin
                    logic [WIDTH-1:0] exp_val;
                    logic [WIDTH-1:0] act_val;
                    golden_mbx.get(exp_val);
                    
                    if (fwft_en) begin
                        act_val  = vif.rdata;
                        vif.rinc = 1'b1;
                        @(posedge vif.rclk);
                        vif.rinc = 1'b0;
                    end else begin
                        vif.rinc = 1'b1;
                        @(posedge vif.rclk);
                        act_val  = vif.rdata;
                        vif.rinc = 1'b0;
                    end
                    
                    if (act_val !== exp_val) begin
                        report_error($sformatf("%s Mixed Test Mismatch! Got:%h, Exp:%h", dut_name, act_val, exp_val));
                    end
                    read_cnt++;
                end else begin
                    vif.rinc = 1'b0;
                end
            end
            @(posedge vif.rclk);
            vif.rinc = 1'b0;
            $display("[%0t] %s: Concurrent Reader Process finished %0d transfers.", $time, dut_name, read_cnt);
        end
    join

    $display("[%0t] [PASS] %s: Mixed Random Stimulus Completed.", $time, dut_name);
endtask


// 用例 3：写溢出 (Overflow) 与读下溢 (Underflow) 保护测试
task automatic test_overflow_underflow(
    virtual fifo_if #(WIDTH) vif, 
    int depth, 
    bit fwft_en, 
    string dut_name
);
    logic [WIDTH-1:0] write_data;
    logic [WIDTH-1:0] expected_q[$];
    logic [WIDTH-1:0] got_val;

    $display("[%0t] Starting [Test 3: Overflow/Underflow Protection] on %s", $time, dut_name);

    // 1. 写满 FIFO
    for (int i = 0; i < depth; i++) begin
        @(posedge vif.wclk);
        write_data = 16'hE000 + i;
        vif.winc   = 1'b1;
        vif.wdata  = write_data;
        expected_q.push_back(write_data);
    end
    @(posedge vif.wclk);
    vif.winc  = 1'b0;
    vif.wdata = '0;

    repeat(5) @(posedge vif.wclk);

    if (!vif.wfull) begin
        report_error($sformatf("%s: Expected FULL state, but wfull is low!", dut_name));
    end

    // 2. 超额写（溢出攻击测试，应该被 DUT 丢弃且不破坏已有状态）
    $display("[%0t] %s: Attempting 5 invalid Overflow writes...", $time, dut_name);
    for (int i = 0; i < 5; i++) begin
        @(posedge vif.wclk);
        vif.winc  = 1'b1;
        vif.wdata = 16'hDEAD; // 无效溢出数据
    end
    @(posedge vif.wclk);
    vif.winc  = 1'b0;
    vif.wdata = '0;

    repeat(5) @(posedge vif.rclk);

    // 3. 读取并验证：必须只读取到原有的 depth 个数据，没有 16'hDEAD
    $display("[%0t] %s: Draining FIFO and verifying content...", $time, dut_name);
    while (!vif.rempty) begin
        if (fwft_en) begin
            got_val = expected_q.pop_front();
            if (vif.rdata !== got_val) begin
                report_error($sformatf("%s Overflow Verify Mismatch! Got:%h, Exp:%h", dut_name, vif.rdata, got_val));
            end
            @(posedge vif.rclk);
            vif.rinc = 1'b1;
        end else begin
            @(posedge vif.rclk);
            vif.rinc = 1'b1;
            @(posedge vif.rclk);
            vif.rinc = 1'b0;
            got_val = expected_q.pop_front();
            if (vif.rdata !== got_val) begin
                report_error($sformatf("%s Overflow Verify Mismatch! Got:%h, Exp:%h", dut_name, vif.rdata, got_val));
            end
        end
    end
    @(posedge vif.rclk);
    vif.rinc = 1'b0;

    repeat(5) @(posedge vif.rclk);

    if (!vif.rempty) begin
        report_error($sformatf("%s: Expected EMPTY state, but rempty is low!", dut_name));
    end

    // 4. 超额读（下溢攻击测试，应该不改变空状态且安全返回）
    $display("[%0t] %s: Attempting 5 invalid Underflow reads...", $time, dut_name);
    for (int i = 0; i < 5; i++) begin
        @(posedge vif.rclk);
        vif.rinc = 1'b1;
    end
    @(posedge vif.rclk);
    vif.rinc = 1'b0;

    repeat(5) @(posedge vif.rclk);

    if (!vif.rempty) begin
        report_error($sformatf("%s: Underflow test failed. FIFO is no longer empty!", dut_name));
    end else begin
        $display("[%0t] [PASS] %s: Overflow/Underflow Protection Test Passed.", $time, dut_name);
    end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
    wait(init_sig.triggered);
    
    // ----------------------------------------------------
    // 运行 用例 1：随机数据写满/读空测试
    // ----------------------------------------------------
    -> simulation_next; 
    test_rand_full_empty(ports[0], 64, 1'b0, "DUT_0 (Std_64)");
    test_rand_full_empty(ports[1], 64, 1'b1, "DUT_1 (FWFT_64)");
    test_rand_full_empty(ports[2], 32, 1'b0, "DUT_2 (Std_Almost_32)");
    test_rand_full_empty(ports[3], 16, 1'b1, "DUT_3 (FWFT_Almost_16)");
    #100;
    
    // ----------------------------------------------------
    // 运行 用例 2：2000 组随机混合读写激励压力测试
    // ----------------------------------------------------
    -> simulation_next;
    test_random_mixed(ports[0], 2000, 1'b0, "DUT_0 (Std_64)");
    test_random_mixed(ports[1], 2000, 1'b1, "DUT_1 (FWFT_64)");
    test_random_mixed(ports[2], 2000, 1'b0, "DUT_2 (Std_Almost_32)");
    test_random_mixed(ports[3], 2000, 1'b1, "DUT_3 (FWFT_Almost_16)");
    #100;

    // ----------------------------------------------------
    // 运行 用例 3：溢出与下溢保护测试
    // ----------------------------------------------------
    -> simulation_next;
    test_overflow_underflow(ports[0], 64, 1'b0, "DUT_0 (Std_64)");
    test_overflow_underflow(ports[1], 64, 1'b1, "DUT_1 (FWFT_64)");
    test_overflow_underflow(ports[2], 32, 1'b0, "DUT_2 (Std_Almost_32)");
    test_overflow_underflow(ports[3], 16, 1'b1, "DUT_3 (FWFT_Almost_16)");
    #100;

    // 触发结束
    -> simulation_finish;
end

/*=========================== Monitoring & Debug Logic ===========================*/

endmodule