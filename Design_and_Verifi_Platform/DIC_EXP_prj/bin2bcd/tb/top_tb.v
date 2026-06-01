`timescale 1ns/1ns
module top_tb;

/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam  DATA_WIDTH = 4;
localparam  DIGIT_WIDTH = 2;

/*===Signal===*/
reg  sys_clk;
reg  sys_rst_n;
reg [DATA_WIDTH-1:0] data;
wire [DIGIT_WIDTH*7-1:0] sig_out;

/*================================== Instantiation ===============================*/

/*===DUT===*/
bin2sig # (
    .DATA_WIDTH(DATA_WIDTH),
    .DIGIT_WIDTH(DIGIT_WIDTH)
) bin2sig_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .data(data),
    .sig_out(sig_out)
);
/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;
	data <= 4'h0;
	// rst
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	#40

	// done
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

`include "tb_event.vh"

/*==================================== task =======================================*/

// 任务：驱动输入数据并等待转换完成
task drive_data(input [DATA_WIDTH-1:0] v);
    begin
        @(posedge sys_clk);
        data <= v;
        $display("[DRIVE] Data Input: %d (Hex: %h)", v, v);
        
        // 转换周期计算: (DATA_WIDTH + 2) 个状态 * 每个状态 2 个 clock (shift_flag 翻转)
        repeat ((DATA_WIDTH + 2) * 2) @(posedge sys_clk);
        
        $display("[CHECK] Data: %d -> Segments(Hex): %h", v, sig_out);
    end
endtask

// 任务：等待指定数量的时钟周期
task wait_clk(input integer n);
    begin
        repeat (n) @(posedge sys_clk);
    end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
    // 等待初始化和复位完成
    @(init_sig);

    -> simulation_next;
    // --- 测试用例 1：基本数值验证 ---
    $display("\n--- Test Case 1: Basic Values ---");
    drive_data(4'd5);    // 预期显示 05
    drive_data(4'd9);    // 预期显示 09
    -> simulation_next;

    // --- 测试用例 2：进位与边界验证 ---
    $display("\n--- Test Case 2: Boundary Values ---");
    drive_data(4'd10);   // 预期显示 10 (A 转换成 BCD 的 1 和 0)
    drive_data(4'd15);   // 预期显示 15 (F 转换成 BCD 的 1 和 5)
    drive_data(4'd0);    // 预期显示 00
    -> simulation_next;

    // --- 测试用例 3：连续背对背输入 ---
    // 由于模块是 free-running 的，连续改变输入会触发不同的转换周期
    $display("\n--- Test Case 3: Back-to-Back ---");
    @(posedge sys_clk);
    data <= 4'd12;
    // 不调用 drive_data 的等待逻辑，模拟异步输入
    wait_clk(5); 
    data <= 4'd7; 
    wait_clk(25); // 等待转换结果稳定输出 07
    


    // 结束仿真
    #100;
    -> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

// 自动监控：当输出变化时打印结果
always @(sig_out) begin
    if (sys_rst_n) begin
        $display("Time:%t | sig_out Changed to: %h", $time, sig_out);
    end
end

endmodule

