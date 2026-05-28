`timescale 1ns/1ns

module mux256_tb;

/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam  WIDTH = 16; // 16'hFFFF

/*===Signal===*/
reg  clk;
reg [7:0] sel;
reg [WIDTH*256-1:0] din;
wire [WIDTH-1:0] q;


/*================================== Instantiation ===============================*/

/*===DUT===*/
mux256_reg # (
    .WIDTH(WIDTH)
)mux256_reg_inst (
    .clk(clk),
    .sel(sel),
    .din(din),
    .q(q)
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 clk = ~clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	clk = 1'b1;
	#20;
	init_data_bus();
	#100;

	// done
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

`include "tb_event.vh"

/*==================================== task =======================================*/

// 1. 初始化数据总线：将每一路的数据设置为其索引值
task init_data_bus();
    integer i;
    begin
        for (i = 0; i < 256; i = i + 1) begin
            din[i*WIDTH +: WIDTH] = i[WIDTH-1:0];
        end
        $display("[INIT] Data bus initialized with index values.");
    end
endtask

// 2. 驱动并验证：处理流水线延迟的核心逻辑
// target_sel: 要选择的通道
task drive_and_verify(input [7:0] target_sel);
    reg [WIDTH-1:0] expected_value;
    begin
        // 设置选择信号
        sel = target_sel;
        
        // 修正处：直接赋值，不要写 [WIDTH-1:0]
        // target_sel 是 8位，expected_value 是 16位，会自动补零
        expected_value = target_sel; 

        // 流水线豁免等待：该设计有4拍延迟
        repeat(4) @(posedge clk);
        
        // 在时钟采样沿之后稍作延迟进行比对
        #2; 
        if (q === expected_value) begin
            $display("[CHECK PASS] Sel: %0d | Expected: %h | Got: %h", target_sel, expected_value, q);
        end else begin
            $display("[CHECK FAIL] Sel: %0d | Expected: %h | Got: %h", target_sel, expected_value, q);
            // $stop; // 如果你想看到底错在哪，可以先注释掉 stop 让它跑完
        end
    end
endtask

// 3. 封装好的测试用例实例
task run_full_range_test();
    integer j;
    begin
        $display("===== Starting Full Range Test (0-255) =====");
        for (j = 0; j < 256; j = j + 1) begin
            drive_and_verify(j[7:0]);
        end
        $display("===== Full Range Test Completed Successfully =====");
    end
endtask




/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);
	-> simulation_next;
	run_full_range_test();

	-> simulation_next;
	$display("===== Starting Random Jump Test =====");
    repeat(10) begin
        drive_and_verify($random % 256);
    end
	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

endmodule

