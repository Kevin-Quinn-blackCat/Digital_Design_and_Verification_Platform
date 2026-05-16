/**
 * File         : cnt_filter.v
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
 * 2026-05-13    KQ        v0.0        Created
 * 2026-05-13    KQ        v0.1        Add clogb2 Function
 * 2026-05-13    KQ        v0.2        Add clogb2 Function Description
 * 2026-05-13    KQ        v0.3        Add Timing Board
 * 2026-05-13    KQ        v1.0        Complete basic code
 * 2026-05-13    kq        v1.1        Normalized function definition
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
--            _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
-- sys_clk   | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
--           __                                                              
-- sys_rst_n   |_____________________________________________________________
--                        ___________             ___________________________
-- din       ____________|           |___________|                           
--           ________________ ___ ___ ___ ___________ ___ ___ ___ ___ _______
-- cnt       ________________X___X___X___X___________X___X___X___X___X_______
--                                                                    _______
-- dout      ________________________________________________________|       
===*/


module cnt_filter #(
	parameter integer CNT_STATE_NUM = 1000
)(
	input  wire  sys_clk,
	input  wire  sys_rst_n,
	input  wire  din,
	output reg   dout
);

/*=================================== function ===================================*/
/*
 * b = clog2(s) = clog2(m+1) = shift(s-1) = shift(m)
 * clog2: 信息量函数，计算s个状态需要至少多少个比特储存
 * shift: 最高有效位函数，计算最大可能值m的最高位1位置
 * 对于s个状态，由0~m编码，有s=m+1
 * 当s=1；m=0；时w=0与函数意义符合但与位宽要求不符
 * 实际上对于所需位宽 w = max{1, $clog2(s)}
 */
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

/*===计数器逻辑===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		cnt <= 1'd0;
	end
	else if ((din_sync_1 != dout) && (cnt == CNT_MAX)) begin
		cnt <= 1'd0;
	end
	else if (din_sync_1 != dout) begin
		cnt <= cnt + 1'd1;
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
	else if ((din_sync_1 != dout) && (cnt == CNT_MAX)) begin
		dout <= din_sync_1;
	end
	else begin
		dout <= dout;
	end
end

/*================================== Instantiation ===============================*/



endmodule