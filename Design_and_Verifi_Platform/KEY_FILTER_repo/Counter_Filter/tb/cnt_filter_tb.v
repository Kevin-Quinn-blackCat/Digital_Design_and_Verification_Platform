`timescale 1ns/1ns
/**
 * File         : cnt_filter_tb.v
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				1. `timescale 1ns/1ns
 * 				2. for cnt_filter
 * 				3. task change aim to assign signal for i cycle
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-13    KQ        v0.0        Created
 * 2026-15-13    KQ        v1.0        add basic logic
 * 2026-15-13    KQ        v1.0        Complete basic code
 * -----------------------------------------------------------------------------
 */

module cnt_filter_tb;

/*======================== Parameter and Internal Signal =========================*/

localparam integer CNT_STATE_NUM = 10;

reg  sys_clk;
reg  sys_rst_n;
reg  din;
wire dout;


/*================================== Instantiation ===============================*/

cnt_filter # (
    .CNT_STATE_NUM(CNT_STATE_NUM)
)
cnt_filter_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .din(din),
    .dout(dout)
);


/*================================== Main Code ===================================*/

always #5 sys_clk = ~sys_clk;

initial begin
	sys_clk = 1'b1;
	din <= 1'd0;
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
end

initial begin
	#50;

	$display("--Simulation Start!--");
	$display("--change to 1 for 10--");
	change(10, 1'b1);
	$display("--change to 0 for 5--");
	change(5, 1'b0);
	$display("--change to 1 for 40--");
	change(40, 1'b1);
	$display("--change to 0 for 40--");
	change(40, 1'b0);
	$display("--change to 1 for 10--");
	change(10, 1'b1);
	$display("--change to 0 for 10--");
	change(10, 1'b0);
	$display("--change to 1 for 9--");
	change(9, 1'b1);
	$display("--change to 1 for 1--");
	change(1, 1'b1);
	$display("--Simulation Finish!--");

	$stop;
end

task change(
	input  integer i,
	input  data
);
	begin
		if (din == data) begin
			repeat(i+1) @(posedge sys_clk) ;
		end
		else begin
			din = ~din;
			repeat(i+1) @(posedge sys_clk) ;
			din = ~din;
		end
		
	end
endtask

always @(dout) begin
	case (dout)
		1'b1: $display("@%dns dout change to %b", $time,dout);
		1'b0: $display("@%dns dout change to %b", $time,dout);
		default: $display("Error @%dns", $time);
	endcase
end

endmodule