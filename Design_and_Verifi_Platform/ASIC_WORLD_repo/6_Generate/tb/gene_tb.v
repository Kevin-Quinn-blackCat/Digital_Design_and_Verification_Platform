`timescale 1ns/1ns
/**
 * File         : gene_tb.v
 * Author list  : KevinQuinn
 * Type         : Testbench
 * tool         : none
 */


module gene_tb;

/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam WIDTH = 4;

/*===Signal===*/
reg  			 sys_clk;
reg  [WIDTH-1:0] a;
reg  [WIDTH-1:0] b;
reg  			 cin_mux 	[0:1];
wire [WIDTH-1:0] data_out 	[0:3];
wire  			 cout 		[0:3];

/*================================== Instantiation ===============================*/

/*===DUT===*/
// 0: Adder, 1: NOT, 2: Reverse
gene # (
    .WIDTH(WIDTH),
    .PIPELINED(0),
    .OP_MODE(0)
)
gene_inst_adder (
    .sys_clk(sys_clk),
    .a(a),
    .b(b),
    .cin_mux(cin_mux[0]),
    .data_out(data_out[0]),
    .cout(cout[0])
);

gene # (
    .WIDTH(WIDTH),
    .PIPELINED(1),
    .OP_MODE(0)
)
gene_inst_adder_pipe (
    .sys_clk(sys_clk),
    .a(a),
    .b(b),
    .cin_mux(cin_mux[0]),
    .data_out(data_out[1]),
    .cout(cout[1])
);

gene # (
    .WIDTH(WIDTH),
    .PIPELINED(0),
    .OP_MODE(1)
)
gene_inst_not (
    .sys_clk(sys_clk),
    .a(a),
    .b(b),
    .cin_mux(cin_mux[1]),
    .data_out(data_out[2]),
    .cout(cout[2])
);

gene # (
    .WIDTH(WIDTH),
    .PIPELINED(0),
    .OP_MODE(2)
)
gene_inst_reverse (
    .sys_clk(sys_clk),
    .a(a),
    .b(b),
    .cin_mux(cin_mux[1]),
    .data_out(data_out[3]),
    .cout(cout[3])
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #5 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;
	a <= 1'b0;
	b <= 1'b0;
	cin_mux[0] <= 1'b0;
	cin_mux[1] <= 1'b0;

	#40;

	// done
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

`include "tb_event.vh"

/*==================================== task =======================================*/
task ran_input;
	begin
		@(posedge sys_clk);
		a <= $random;
		b <= $random;
		@(posedge sys_clk);
		moni_group();
	end
endtask

task overflow_min;
	begin
		@(posedge sys_clk);
		a <= 4'hF;
		b <= 4'h1;
		@(posedge sys_clk);
		moni_adder();
	end
endtask

task overflow_max;
	begin
		@(posedge sys_clk);
		a <= 4'hF;
		b <= 4'hF;
		@(posedge sys_clk);
		moni_adder();
	end
endtask

task no_overflow_min;
	begin
		@(posedge sys_clk);
		a <= 4'h0;
		b <= 4'h0;
		@(posedge sys_clk);
		moni_adder();
	end
endtask

task no_overflow_max;
	begin
		@(posedge sys_clk);
		a <= 4'h8;
		b <= 4'h7;
		@(posedge sys_clk);
		moni_adder();
	end
endtask

task cin;
	input n;
	begin
		@(posedge sys_clk);
		cin_mux[0] <= n;
		@(posedge sys_clk);
	end
endtask

task mux;
	input n;
	begin
		@(posedge sys_clk);
		cin_mux[1] <= n;
		@(posedge sys_clk);
	end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	@(init_sig);

	-> simulation_next;
	ran_input();
	ran_input();
	ran_input();
	ran_input();

	-> simulation_next;
	mux(1'b1);
	ran_input();
	ran_input();
	ran_input();
	ran_input();
	mux(1'b0);

	-> simulation_next;
	overflow_min();
	overflow_max();
	no_overflow_min();
	no_overflow_max();

	-> simulation_next;
	cin(1'b1);
	no_overflow_min();
	no_overflow_max();
	cin(1'b0);

	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/

task automatic monid;
	input integer data_out_num;
	input integer cin_mux_num;
	begin
		$display("@%t ns: inst[%0d] a=%d b=%d cin/mux=%d dout=%d cout=%d"
				, $time, data_out_num, a, b, cin_mux[cin_mux_num], data_out[data_out_num], cout[data_out_num]);
	end
endtask

task automatic monib;
	input integer data_out_num;
	input integer cin_mux_num;
	begin
		$display("@%t ns: inst[%0d] a=%b b=%b cin/mux=%b dout=%b cout=%b"
				, $time, data_out_num, a, b, cin_mux[cin_mux_num], data_out[data_out_num], cout[data_out_num]);
	end
endtask

task moni_group;
	begin
		monid(0,0);
		monid(1,0);
		monib(2,1);
		monib(3,1);
	end
endtask

task moni_adder;
	begin
		monid(0,0);
		monid(1,0);
	end
endtask

endmodule
