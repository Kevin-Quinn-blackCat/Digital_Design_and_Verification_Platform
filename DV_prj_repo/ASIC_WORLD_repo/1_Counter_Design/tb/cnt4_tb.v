`timescale 1ns/1ns
/**
 * File         : cnt4_tb.sv
 * Author list  : kq
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				1. tested all cases
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-12    kq        v0.0        Created
 * 2026-05-12    kq        v1.0        basic logic coding
 * -----------------------------------------------------------------------------
 */


module cnt4_tb;


/*======================== Parameter and Internal Signal =========================*/

reg  sys_clk;
reg  sys_rst_n;
reg  enable;
wire [3:0] cnt;


/*================================== Instantiation ===============================*/

cnt4  cnt4_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .enable(enable),
    .cnt(cnt)
);


/*================================== Main Code ===================================*/

always #10 sys_clk = ~sys_clk;

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	enable <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	
end

initial begin
	#200
	enable <= 1'b1;
	#200
	enable <= 1'b0;
	sys_rst_n <= 1'b0;
	#200
	enable <= 1'b1;
	#200
	$finish;
end

initial begin
	$display("time\tclk\trst\ten\tcnt");
	$monitor("%g\t%b\t%b\t%b\t%d", $time, sys_clk, sys_rst_n, enable, cnt);
end

endmodule