`timescale 1ns/1ns
/**
 * File         : Clock_Switcher_tb.sv
 * Author list  : kq
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By             Version     Description
 * 2026-06-02      kq       v0.0        Created
 * -----------------------------------------------------------------------------
 */


module Clock_Switcher_tb;


/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/

/*===Signal===*/
logic clk0;
logic clk1;
logic rst_n;
logic sel;
logic clk_out;


/*================================== Instantiation ===============================*/

/*===DUT===*/
  Clock_Switcher  Clock_Switcher_inst (
    .clk0(clk0),
    .clk1(clk1),
    .rst_n(rst_n),
    .sel(sel),
    .clk_out(clk_out)
  );

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 clk0 = ~clk0;
always #8 clk1 = ~clk1;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	clk0 = 1'b1;
	clk1 = 1'b1;
	sel = 1'b0;

	// rst
	rst_n <= 1'b0;
	#40;
	rst_n <= 1'b1;
	#40

	// done
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

`include "tb_event.svh"

/*================================= Basic task ====================================*/
task random_sel();
	sel <= $random%2;
endtask

task long_random_delay();
	int i;
	i = $urandom_range(100, 200);
	repeat(i) #1;
endtask

task short_random_delay();
	int i;
	i = $urandom_range(20, 60);
	repeat(i) #1;
endtask

task flash_random_delay();
	int i;
	i = $urandom_range(1, 10);
	repeat(i) #1;
endtask

/*============================= Driver package task ===============================*/
task long_delay_sel(integer n);
	repeat(n) begin
		random_sel();
		long_random_delay();
	end
endtask

task short_delay_sel(integer n);
	repeat(n) begin
		random_sel();
		short_random_delay();
	end
endtask

task flash_delay_sel(integer n);
	repeat(n) begin
		random_sel();
		flash_random_delay();
	end
endtask

/*================================= Case task ====================================*/
task long_delay_case();
	long_delay_sel(10000);
endtask

task short_delay_case();
	short_delay_sel(10000);
endtask

task flash_delay_case();
	flash_delay_sel(10000);
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);
	-> simulation_next;
	long_delay_case();
	#10
	-> simulation_next;
	short_delay_case();
	-> simulation_next;
	flash_delay_case();
	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

endmodule
