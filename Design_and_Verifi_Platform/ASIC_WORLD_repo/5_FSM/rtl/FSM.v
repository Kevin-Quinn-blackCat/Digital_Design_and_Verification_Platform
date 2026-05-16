/**
 * File         : FSM.v
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. Detect 1011 sequence
 * 				2. sliding window mechanism
 * 				3. Output pulse
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-15    kq        v0.0        Created
 * 2026-05-15    kq        v1.0        Complete basic logic
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/

module FSM (
	input  wire  sys_clk,
	input  wire  sys_rst_n,
	input  wire  data,
	output  reg   flag
);

/*======================== Parameter and Internal Signal =========================*/

/*===Paramter===*/
// state
localparam S_0   	=	 4'h1;
localparam S_1   	=	 4'h2;
localparam S_10  	=	 4'h4;
localparam S_101 	=	 4'h8;

// input

// output

/*=== Signal ===*/
reg [3:0] curr_state;
reg [3:0] next_state;

/*================================== Main Code ===================================*/

// Manage status jump (Driver curr_state)
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		curr_state <= S_0;
	end
	else begin
		curr_state <= next_state;
	end
end

// Determine next state (Driver next_state)
always @(*) begin
	// Keep by Default
	next_state = curr_state;
	// Manage Change
	case (curr_state)
		S_0     :   if (data)   next_state = S_1;
		S_1     :   if (~data)  next_state = S_10;
		S_10    :   if (data)   next_state = S_101; else next_state = S_0;
		S_101   :   if (data)   next_state = S_1;   else next_state = S_10;
		default :               next_state = S_0;
	endcase
end

// Prediction output (Driver output)
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		flag <= 1'b0;
	end
	else begin
		// Zero by Default
		flag <= 1'b0;
		case (curr_state)
			S_101 : if (data) flag <= 1'b1;
			default: flag <= 1'b0;
		endcase
	end
end

/*================================ Instantiation =================================*/




endmodule
