`timescale 1ns/1ns
/**
 * File         : Inte_filter_tb.v
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-13    KQ        v0.0        Created
 * 2026-15-13    KQ        v1.0        Copy from cnt_filter
 * 2026-15-13    KQ        v1.0        Complete basic code
 * 2026-15-17    KQ        v2.0        refactor: synchronize and refactor verification platform implementation
 * -----------------------------------------------------------------------------
 */


module Inte_filter_tb;


/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam CNT_STATE_NUM = 10;

/*===Signal===*/
reg  sys_clk;
reg  sys_rst_n;
reg  din;
wire dout;


/*================================== Instantiation ===============================*/

/*===DUT===*/
Inte_filter # (
    .CNT_STATE_NUM(CNT_STATE_NUM)
)
Inte_filter_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .din(din),
    .dout(dout)
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;
	din <= 1'd0;

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

`include "tb_event.vh"

/*==================================== task =======================================*/

task automatic change;
	input  integer i;
	input          data;
	begin
		#1;
		$display("--change to %b for %d--", data, i);
		if (din == data) begin
			repeat (i) @(posedge sys_clk);
		end
		else begin
			din <= ~din;
			repeat (i) @(posedge sys_clk);
			din <= ~din;
		end
	end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);
	-> simulation_next;
		change(10, 1'b1);
		change(5, 1'b0);
		change(40, 1'b1);
		change(40, 1'b0);
		change(10, 1'b1);
		change(10, 1'b0);
		change(9, 1'b1);
		change(1, 1'b1);

	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/
always @(dout) begin
	case (dout)
		1'b1: $display("@%dns dout change to %b", $time,dout);
		1'b0: $display("@%dns dout change to %b", $time,dout);
		default: $display("Error @%dns", $time);
	endcase
end


endmodule