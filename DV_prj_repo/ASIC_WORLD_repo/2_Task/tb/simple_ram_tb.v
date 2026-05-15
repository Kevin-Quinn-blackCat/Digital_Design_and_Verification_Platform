`timescale 1ns/1ns
/**
 * File         : simple_ram_tb.v
 * Author list  : KIMQUIN
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-13    kq        v0.0        Created
 * 2026-05-13    kq        v1.0        Complete logic
 * -----------------------------------------------------------------------------
 */



module simple_ram_tb;

/*======================== Parameter and Internal Signal =========================*/

/*===param===*/

/*===sig===*/
reg  		clk;
reg  	   wr_en;
reg [7:0]  addr;
reg [7:0]  data_in;
wire [7:0] data_out;

/*================================== Instantiation ===============================*/

simple_ram  simple_ram_inst (
    .clk(clk),
    .wr_en(wr_en),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out)
);

/*================================== Main Code ===================================*/

/*===init===*/
initial begin
	clk = 1'b1;
	wr_en	 <= 1'b0;
	addr	 <= 1'b0;
	data_in	 <= 1'b0;
	#40;
end

/*===gen_clk===*/
always #5 clk = ~clk;

/*================================================================================*/

initial begin
	#50;
	#100;
	write_data(8'ha6, 8'hff);
	#100;
	write_data(8'ha7, 8'h00);
	#100;
	write_data(8'ha8, 8'h01);
	#100;
	write_data(8'hb1, 8'hf1);
	write_data(8'hb2, 8'hf2);
	write_data(8'hb3, 8'hf3);
	write_data(8'hb4, 8'hf4);

	#20;

	#100;
	read_and_check(8'ha6, 8'hff);
	#100;
	read_and_check(8'ha7, 8'h00);
	#100;
	read_and_check(8'ha8, 8'h01);
	#100;
	read_and_check(8'hb1, 8'hf1);
	read_and_check(8'hb2, 8'hf2);
	read_and_check(8'hb3, 8'hf3);
	read_and_check(8'hb4, 8'hf4);
	#10;
	$stop;
end

/*=====================================task=======================================*/

task write_data ;
	input [7:0] _addr;
	input [7:0] _data_in;
	begin
		@(posedge clk) begin
			wr_en    <=  1'b1;
			addr     <=  _addr;
			data_in  <=  _data_in;
		end
		@(posedge clk) wr_en <=  1'b0;
	end
endtask

task read_and_check ;
	input [7:0] _addr;
	input [7:0] expected_data;
	begin
		@(posedge clk) begin
			addr <= _addr;
		end
		@(posedge clk);
		@(posedge clk) begin
			if (expected_data == data_out) begin
				$display("@%dns, expected %b, which correct by %b", $time, expected_data, data_out);
			end 
			else begin
				$display("@%dns Caught ERROR! which expected %b, BUT %b", $time, expected_data, data_out);
			end
		end
	end
endtask


endmodule