`timescale 1ns/1ns
/**
 * File         : 0FILE_NAME0.v/sv
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : 0None/Vivado/Modelsim0
 * Description  : 
 * 				1. 0Insert_short_description_here0
 * 				2. 0Insert_short_description_here0
 * 				3. 0Insert_short_description_here0
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-XX-XX    kq        v0.0        Created
 * -----------------------------------------------------------------------------
 */


module top_tb;


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

/*===finish===*/
event simulation_finish;
initial begin
	forever begin
		@(simulation_finish);
		$display("+------------------------------------------------------------------------------+");
		$display("|                        =====Simulation Finish=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$finish;
	end
end

/*===stop===*/
event simulation_stop;
initial begin
	forever begin
		@(simulation_stop);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Stop=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$stop;
	end
end

/*===next===*/
event simulation_next;
initial begin : SIM_NUM
	integer sim_num;
	sim_num <= 1;
	forever begin 
		@(simulation_next);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Next=====                           |");
		$display("|                         =====Simulation No.%0d=====                          |", sim_num);
		$display("+------------------------------------------------------------------------------+");
		sim_num <= sim_num + 1;
	end
end

/*==================================== task =======================================*/





/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);
	

	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

endmodule