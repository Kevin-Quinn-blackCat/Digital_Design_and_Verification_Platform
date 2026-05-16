`timescale 1ns/1ns
/**
 * File         : SequenceSearcher_tb.v/sv
 * Author list  : kq
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 *   [调试经验笔记]
 *   1. 层次化访问：语法为 [inst_name].[block_name].[var_name]。
 *      - 必须指向 SEARCH_LOGIC.i 才能观察搜索进度；INIT_BLOCK.i 在 0ns 后固定为 16。
 *   2. 仿真竞争与电平触发：
 *      - wait(found_flag) 是电平触发。如果上一次搜索完后 flag 未复位，下一次 wait 会立即跳过。
 *      - 修复方法：在发送 start 后，应等待 found_flag 的上升沿 @(posedge found_flag)。
 *   3. 变量截断：i=16 时，i[3:0] 结果为 0，观察层级变量时需注意位宽。
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-14    kq        v0.0        Created
 * 2026-05-14    kq        v1.0        Complete
 * -----------------------------------------------------------------------------
 */


module SequenceSearcher_tb;


/*======================== Parameter and Internal Signal =========================*/

reg  sys_clk;
reg  start;
reg [7:0] target;
wire [3:0] found_index;
wire found_flag;

reg time_out;

/*================================== Instantiation ===============================*/


SequenceSearcher  SequenceSearcher_inst (
    .clk(sys_clk),
    .start(start),
    .target(target),
    .found_index(found_index),
    .found_flag(found_flag)
);


/*================================== Main Code ===================================*/

/*===gen_clk===*/
always #5 sys_clk = ~sys_clk;

/*===initial===*/
event init_done;
initial begin
	sys_clk = 1'b0;
	start <= 1'b0;
	target <= 8'hff;
	time_out <= 1'b0;
	#20;
	-> init_done;
end

/*===start pulse===*/
event start_pulse;
event start_done;

initial begin
	forever begin
		@(start_pulse);
		@(posedge sys_clk) start <= 1'b1;
		@(posedge sys_clk) start <= 1'b0;
		-> start_done;
	end
end

/*===find===*/
initial begin
	@(init_done);

	target <= 8'h50;
	-> start_pulse;
	@(start_done);
	wait_flag();

	target <= 8'h70;
	-> start_pulse;
	@(start_done);
	wait_flag();

	target <= 8'h01;
	-> start_pulse;
	@(start_done);
	wait_flag();

	target <= 8'h80;
	-> start_pulse;
	@(start_done);
	wait_flag();

	$stop;

end

/*===wait_flag===*/
task wait_flag;
	begin
		wait (found_flag || time_out);
		@(posedge sys_clk);
		$display("@%t ns found_index = %d, i = %d", $time,
		found_index, SequenceSearcher_inst.SEARCH_LOGIC.i[3:0]);
	end
endtask


/*===time_out===*/
initial begin
	@(start_done);
	time_out <= 1'b0;
	begin : TIME_OUT
	repeat(20) begin
		@(posedge sys_clk);
		if (found_flag) begin
			disable TIME_OUT;
		end
	end
	time_out <= 1'b1;
	$display("ERROR! @%t ns :time out!", $time);
	end
end

/*===monitor_i===*/
always @(SequenceSearcher_inst.SEARCH_LOGIC.i) begin
	$display("@%t ns: i = %d", $time, SequenceSearcher_inst.SEARCH_LOGIC.i[3:0]);
end

endmodule

