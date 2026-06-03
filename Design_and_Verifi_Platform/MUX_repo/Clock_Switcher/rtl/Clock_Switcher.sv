/**
 * File         : Clock_Switcher.sv
 * Author list  : kq
 * Type         : Digital Design
 * tool         : none
 * Description  : 
 * 				1. none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By             Version     Description
 * 2026-06-02      kq       v0.0        Created
 * 2026-06-02      kq       v1.0        Complete basic logic
 * 2026-06-03      kq       v2.0        add assert
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module Clock_Switcher (
	input  logic  clk0,
	input  logic  clk1,
	input  logic  rst_n,
	input  logic  sel,		// 0 : clk0; 1 : clk1
	output logic  clk_out
);

/*======================== Parameter and Internal Signal =========================*/

/*=== Signal ===*/
logic q0_reg1;
logic q0_reg2;
logic q1_reg1;
logic q1_reg2;

logic en0;
logic en1;

/*================================== Main Code ===================================*/
/*===clk0的门控信号：只能在clk1除能后才能预备使能===*/
// 在下降沿变化，确保把所有的高电平跑完才判断是否启动/关闭，确保后续由0开头
// 预备信号q0取决于另一个时钟域的使能信号en1，需要打两排隔离亚稳态
// 只有在另一个时钟关闭了，才能取决于sel变化
always_ff @(negedge clk0 or negedge rst_n) begin
	if (!rst_n) begin
		q0_reg1 <= 1'b0;
	end
	else begin
		q0_reg1 <= (~sel) & (~en1);
	end
end

always_ff @(negedge clk0 or negedge rst_n) begin
	if (!rst_n) begin
		q0_reg2 <= 1'b0;
	end
	else begin
		q0_reg2 <= q0_reg1;
		assert(!clk0) else $error("The clock0 turn at a high level");
	end
end

assign en0 = q0_reg2;

/*===clk1的门控信号：只能在clk0除能后才能预备使能===*/
// 同理
always_ff @(negedge clk1 or negedge rst_n) begin
	if (!rst_n) begin
		q1_reg1 <= 1'b0;
	end
	else begin
		q1_reg1 <= sel & (~en0);
	end
end

always_ff @(negedge clk1 or negedge rst_n) begin
	if (!rst_n) begin
		q1_reg2 <= 1'b0;
	end
	else begin
		q1_reg2 <= q1_reg1;
		assert(!clk1) else $error("The clock1 turn at a high level");
	end
end

assign en1 = q1_reg2;

/*===时钟汇聚===*/

assign clk_out = (en0 & clk0) | (en1 & clk1);


/*=============================== SVA Verification ===============================*/
/*===性质一：门控互斥：en0和en1不能同时开启===*/
property clk_no_overlap;
	@(clk0 or clk1)
	disable iff (!rst_n)
	!(en0 && en1);
endproperty

assert_mutual_exclusive: assert property (clk_no_overlap)
else $error("Violation: en0 and en1 are both HIGH!");

/*===性质二：死锁解除：在切换时使能信号需要先解除===*/
property sel0_to_sel1;
	@(negedge clk0)
	disable iff (!rst_n)
	$rose(sel) |-> ##[1:3] !en0;
endproperty

assert_deadlock0_release: assert property (sel0_to_sel1)
else $error("Violation: en0 not fall when sel changes");

property sel1_to_sel0;
	@(negedge clk1)
	disable iff (!rst_n)
	$fell(sel) |-> ##[1:3] !en1;
endproperty

assert_deadlock1_release: assert property (sel1_to_sel0)
else $error("Violation: en1 not fall when sel changes");

/*===性质三：复位时为低电平===*/
property rst4low;
	(!rst_n) |-> (!clk_out);
endproperty
assert_rst_low: assert property (@(clk_out) rst4low);

endmodule