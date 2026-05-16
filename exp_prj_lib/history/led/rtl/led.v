/*===
--            _   _   _   _   _   _   _   _   _   _
-- sys_clk   | |_| |_| |_| |_| |_| |_| |_| |_| |_| 
--           ________                              
-- sys_rst_n         |_____________________________
--           ____________ _______ ___________ _____
-- clk_1s    ____________X_______X___________X_____
--                                ___         ___  
-- flag      ____________________|   |_______|   |_
--           ____________ ___________ ___________ _
-- state     ____________X___________X___________X_
--           ____________ ___________ ___________ _
-- led       ____________X___________X___________X_
===*/


module led #(
	parameter CNT_MAX = 25'd24_999_999
)(
	input  wire  		sys_clk,
	input  wire  		sys_rst_n,
	output reg   [6:0]	led
);

/*================================================================================*/
/*======================== Parameter and Internal Signal =========================*/
/*================================================================================*/
reg [24:0]	cnt_1s;
reg 		flag;
reg [9:0]   state;


/*==================================Encoding==================================*/
/*==input_encoding==*/

/*==output_encoding==*/
// output led
localparam  V0  = 7'h40;
localparam  V1  = 7'h79;
localparam  V2  = 7'h24;
localparam  V3  = 7'h30;
localparam  V4  = 7'h19;
localparam  V5  = 7'h12;
localparam  V6  = 7'h02;
localparam  V7  = 7'h78;
localparam  V8  = 7'h00;
localparam  V9  = 7'h10;


/*==state_encoding==*/
// state
localparam  S0  = 10'h001;
localparam  S1  = 10'h002;
localparam  S2  = 10'h004;
localparam  S3  = 10'h008;
localparam  S4  = 10'h010;
localparam  S5  = 10'h020;
localparam  S6  = 10'h040;
localparam  S7  = 10'h080;
localparam  S8  = 10'h100;
localparam  S9  = 10'h200;


/*================================================================================*/
/*================================== Main Code ===================================*/
/*================================================================================*/

/*===cnt_1s===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		cnt_1s <= 25'd0;
	end
	else if (cnt_1s == CNT_MAX) begin
		cnt_1s <= 25'd0;
	end
	else begin
		cnt_1s <= cnt_1s + 25'd1;
	end
end


/*===flag===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		flag <= 1'b0;
	end
	else if (cnt_1s == CNT_MAX) begin
		flag <= 1'b1;
	end
	else begin
		flag <= 1'b0;
	end
end

/*================================================================================*/
/*===================================== FSM ======================================*/
/*================================================================================*/

/*==================================State Transition==================================*/
always @(posedge sys_clk) begin
	if(!sys_rst_n)
		state <= S0;
	else case(state)
		S0: begin
			if(flag)
				state <= S1;
			else
				state <= S0;
		end
		S1: begin
			if(flag)
				state <= S2;
			else
				state <= S1;
		end
		S2: begin
			if(flag)
				state <= S3;
			else
				state <= S2;
		end
		S3: begin
			if(flag)
				state <= S4;
			else
				state <= S3;
		end
		S4: begin
			if(flag)
				state <= S5;
			else
				state <= S4;
		end
		S5: begin
			if(flag)
				state <= S6;
			else
				state <= S5;
		end
		S6: begin
			if(flag)
				state <= S7;
			else
				state <= S6;
		end
		S7: begin
			if(flag)
				state <= S8;
			else
				state <= S7;
		end
		S8: begin
			if(flag)
				state <= S9;
			else
				state <= S8;
		end
		S9: begin
			if(flag)
				state <= S0;
			else
				state <= S9;
		end
		default: state <= S0;
	endcase
end

/*==================================FSM Output==================================*/
// output_name
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		led <= 7'hff;
	end
	else if (state == S0) begin
		led <= V0;
	end
	else if (state == S1) begin
		led <= V1;
	end
	else if (state == S2) begin
		led <= V2;
	end
	else if (state == S3) begin
		led <= V3;
	end
	else if (state == S4) begin
		led <= V4;
	end
	else if (state == S5) begin
		led <= V5;
	end
	else if (state == S6) begin
		led <= V6;
	end
	else if (state == S7) begin
		led <= V7;
	end
	else if (state == S8) begin
		led <= V8;
	end
	else if (state == S9) begin
		led <= V9;
	end
	else begin
		led <= led;
	end
end

/*=============================================================================*/


endmodule