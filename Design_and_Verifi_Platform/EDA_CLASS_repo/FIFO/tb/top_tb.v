`timescale 1ns/1ns
/**
 * File         : [FILE_NAME].v/sv
 * Author list  : [Name1],[Name2]
 * Type         : [Digital Design / Testbench]
 * tool         : [None/Vivado/Modelsim]
 * Description  : 
 * 				1. [Insert short description here]
 * 				2. [Insert short description here]
 * 				3. [Insert short description here]
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-XX-XX   [Name]     v1.0        Created
 * -----------------------------------------------------------------------------
 */


module top_tb;

/*================================================================================*/
/*======================== Parameter and Internal Signal =========================*/
/*================================================================================*/

localparam  CNT_MAX = 9;

reg  sys_clk;
reg  sys_rst_n;
wire [6:0] led;

/*================================================================================*/
/*================================== Instantiation ===============================*/
/*================================================================================*/
led # (
	.CNT_MAX(CNT_MAX)
)
led_inst (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.led(led)
);


/*================================================================================*/
/*================================== Main Code ===================================*/
/*================================================================================*/

always #10 sys_clk = ~sys_clk;

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	#1000000
	$stop;
end

endmodule