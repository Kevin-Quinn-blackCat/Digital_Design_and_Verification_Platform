/**
 * File         : cnt4.v
 * Author list  : KQ
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. This is a 4-bit wide adder
 * 				2. Enable signal is active at high level
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-12    KQ        v0.0        Created
 * 2026-05-12    KQ        v0.1        add TIMING BOARD
 * 2026-05-12    KQ        v1.0        basic logic coding
 * 2026-05-12    KQ        v1.1        Bit width bug fixed
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
--                 _   _   _   _   _   _   _   _   _   _   _   _
-- sys_clk        | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| 
--                __                                            
-- sys_rst_n        |___________________________________________
--                                         _____________________
-- Default Signal ________________________|                     
--                ____________________________ ___ ___ ___ ___ ___
-- cnt4           ___0________________________X_1_X_2_X_~_X15_X_0_
===*/


module cnt4 (
	input  wire			sys_clk,
	input  wire			sys_rst_n,
	input  wire			enable,
	output reg  [3:0] 	cnt
);

/*======================== Parameter and Internal Signal =========================*/

localparam CNT_MAX = 4'b1111;

/*================================== Main Code ===================================*/

always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		cnt <= 4'd0;
	end
	else if (enable && (cnt == CNT_MAX)) begin
		cnt <= 4'd0;
	end
	else if (enable) begin
		cnt <= cnt + 4'd1;
	end
	else begin
		cnt <= cnt;
	end
end



endmodule