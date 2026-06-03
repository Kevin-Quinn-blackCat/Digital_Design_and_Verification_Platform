/**
 * File         : Inte_filter.v
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. "CNT_STATE_NUM" is the number of counting cycles
 * 				2. The maximum bit width is 32
 * 				3. The input is synchronized with two-cycle 
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-13    kq        v0.0        Created
 * 2026-05-13    kq        v0.1        Copy cnt_filter
 * 2026-05-13    kq        v1.0        Complete basic logic
 * 2026-05-13    kq        v1.1        Normalized function definition
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module Inte_filter #(
	parameter integer CNT_STATE_NUM = 1000
)(
	input  wire  sys_clk,
	input  wire  sys_rst_n,
	input  wire  din,
	output reg   dout
);

/*=================================== function ===================================*/

function integer clogb2;
	input integer state_num;
    begin
        if (state_num <= 1)
            clogb2 = 1;
        else begin
            clogb2 = 0;
            for (state_num = state_num - 1; state_num > 0; state_num = state_num >> 1) begin
                clogb2 = clogb2 + 1;
            end
        end
    end
endfunction

/*======================== Parameter and Internal Signal =========================*/
localparam integer CNT_WIDTH = clogb2(CNT_STATE_NUM);
localparam integer CNT_MAX = CNT_STATE_NUM - 1;

reg 					din_sync_0;
reg 					din_sync_1;
reg [CNT_WIDTH - 1:0]	cnt;

/*================================== Main Code ===================================*/
/*===异步同步===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		din_sync_0 <= 1'b0;
		din_sync_1 <= 1'b0;
	end
	else begin
		din_sync_0 <= din;
		din_sync_1 <= din_sync_0;
	end
end

/*===对din做离散积分===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		cnt <= 1'd0;
	end
	else if (din_sync_1 && (cnt == CNT_MAX)) begin
		cnt <= CNT_MAX;
	end
	else if ((~din_sync_1) && (cnt == 1'b0)) begin
		cnt <= 1'b0;
	end
	else if (din_sync_1) begin
		cnt <= cnt + 1'b1;
	end
	else if (~din_sync_1) begin
		cnt <= cnt - 1'b1;
	end
	else begin
		cnt <= cnt;
	end
end

/*===输出逻辑===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		dout <= 1'd0;
	end
	else if (dout && (cnt == 1'b0)) begin
		dout <= 1'b0;
	end
	else if ((~dout) && (cnt == CNT_MAX)) begin
		dout <= 1'b1;
	end
	else begin
		dout <= dout;
	end
end

/*================================== Instantiation ===============================*/



endmodule
