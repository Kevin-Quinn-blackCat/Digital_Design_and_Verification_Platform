`timescale 1ns/1ns
/**
 * File         : FSM_tb.v
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-15    kq        v0.0        Created
 * 2026-05-15    kq        v0.0        Complete basic logic
 * -----------------------------------------------------------------------------
 */


module FSM_tb;


/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/

/*===Signal===*/
reg  sys_clk;
reg  sys_rst_n;
reg  data;
wire flag;

reg  flag_reg;

/*================================== Instantiation ===============================*/

/*===DUT===*/
FSM  FSM_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .data(data),
    .flag(flag)
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;
	data <= 1'b0;

	// rst
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	#40;

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
		$display("===Simulation have %d warning===", WARNING_NOT_PULSE.w);
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
task send_bit;
	input  _bit;
	begin
		data <= _bit;
		@(posedge sys_clk);
	end
endtask

task send_4bit;
	input [3:0] _4bit;
	begin
		@(posedge sys_clk)
		send_bit(_4bit[3]);
		send_bit(_4bit[2]);
		send_bit(_4bit[1]);
		send_bit(_4bit[0]);
	end
endtask

task pull_down;
	begin
		send_bit(1'b0);
		send_4bit(4'b0000);
	end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);
	
	-> simulation_next;
	$strobe("Hope pulses two times!");
	send_4bit(4'b1011);
	pull_down();
	send_4bit(4'b1011);
	pull_down();

	-> simulation_next;
	$strobe("Hope pulses zero times!");
	send_4bit(4'b0001);
	pull_down();
	send_4bit(4'b0111);
	pull_down();
	send_4bit(4'b1110);
	pull_down();
	send_4bit(4'b1000);
	pull_down();
	send_4bit(4'b1010);
	pull_down();

	-> simulation_next;
	$strobe("Hope pulses two times!");
	send_4bit(4'b1011);
	send_bit(1'b0);
	send_bit(1'b1);
	send_bit(1'b1);
	pull_down();

	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

always @(flag) begin
	if (flag) begin
		$display("@%t ns: flag up", $time);
	end
end

always @(posedge sys_clk) begin
	flag_reg <= flag;
end

initial begin : WARNING_NOT_PULSE
	integer w;
	w = 0;
	forever begin
		@(posedge sys_clk);
		if (~(flag^flag_reg) && flag_reg) begin
			$strobe("Warning @%t ns: flag is not single bit pulse", $time);
			w = w + 1;
		end
	end
end

endmodule

