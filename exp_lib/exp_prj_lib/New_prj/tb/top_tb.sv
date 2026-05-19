`timescale 1ns/1ns
/**
 * File         : {{FILE_NAME}}_tb.sv
 * Author list  : {{NAME}}
 * Type         : Testbench
 * tool         : {{RTL_TOOL}}
 * Description  : 
 * 				1. 0Insert_short_description_here0
 * 				2. 0Insert_short_description_here0
 * 				3. 0Insert_short_description_here0
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By             Version     Description
 * {{DATE}}      {{NAME}}       v0.0        Created
 * -----------------------------------------------------------------------------
 */


module {{FILE_NAME}}_tb;


/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam  CNT_MAX = 9;

/*===Signal===*/
reg  sys_clk;
reg  sys_rst_n;
wire [6:0] led;


/*================================== Instantiation ===============================*/

/*===DUT===*/
led # (
	.CNT_MAX(CNT_MAX)
)
led_inst (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.led(led)
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #10 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;

	// rst
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	#40

	// done
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

`include "tb_event.svh"

/*==================================== task =======================================*/





/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	wait(init_sig.triggered);
	-> simulation_next;

	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

endmodule