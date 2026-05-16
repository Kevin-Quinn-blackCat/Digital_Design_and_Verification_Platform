/**
 * File         : wave_FSM.v
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. The button controls the state machine switching after debounce
 * 				2. Cycle switching between 
 *					sine wave, triangle wave, sawtooth wave and square wave
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-16    kq        v0.0        Created
 * 2026-15-16    kq        v1.0        Complete FSM
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/

module wave_FSM (
	input  wire  	  sys_clk,
	input  wire  	  sys_rst_n,
	input  wire  	  pulse_in,
	output  reg [3:0] state_out
);

/*==================================== FSM P&S =====================================*/

/*===Paramter===*/
// state
localparam S_SIN   	=	 4'h1;
localparam S_TRI   	=	 4'h2;
localparam S_SAW  	=	 4'h4;
localparam S_SQU 	=	 4'h8;

// input

// output

/*=== Signal ===*/
reg [3:0] curr_state;
reg [3:0] next_state;

/*=================================== FSM Main ====================================*/

/* ---Manage status jump (Driver curr_state)--- */
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		curr_state <= S_SIN;
	end
	else begin
		curr_state <= next_state;
	end
end

/* ---Determine next state (Driver next_state)--- */
always @(*) begin
	// Keep by Default
	next_state = curr_state;
	// Manage Change
	case (curr_state)
		S_SIN     :   if (pulse_in)   next_state = S_TRI;
		S_TRI     :   if (pulse_in)   next_state = S_SAW;
		S_SAW     :   if (pulse_in)   next_state = S_SQU;
		S_SQU     :   if (pulse_in)   next_state = S_SIN;
		default   :                   next_state = S_SIN;
	endcase
end

/* ---Prediction output (Driver output)--- */
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		state_out <= 4'h0;
	end
	else begin
		state_out <= next_state;
	end
end
/*================================================================================*/



/*================================ Instantiation =================================*/




endmodule