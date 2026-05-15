`timescale 1ns/1ns
/**
 * File         : 0FILE_NAME0.v/sv
 * Author list  : 0Name10,0Name20
 * Type         : Testbench
 * tool         : 0None/Vivado/Modelsim0
 * Description  : 
 * 				1. 0Insert short description here0
 * 				2. 0Insert short description here0
 * 				3. 0Insert short description here0
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-XX-XX   0Name0     v0.0        Created
 * -----------------------------------------------------------------------------
 */


module top_tb;


/*======================== Parameter and Internal Signal =========================*/


localparam  CNT_MAX = 9;

reg  sys_clk;
reg  sys_rst_n;
wire [6:0] led;


/*================================== Instantiation ===============================*/

led # (
	.CNT_MAX(CNT_MAX)
)
led_inst (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.led(led)
);



/*================================== Main Code ===================================*/


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