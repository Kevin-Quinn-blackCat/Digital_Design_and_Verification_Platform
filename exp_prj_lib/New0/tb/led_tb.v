`timescale 1ns/1ns

module led_tb;

  // Parameters
  localparam  CNT_MAX = 9;

  //Ports
  reg  sys_clk;
  reg  sys_rst_n;
  wire [6:0] led;

  led # (
    .CNT_MAX(CNT_MAX)
  )
  led_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .led(led)
  );

always #10 sys_clk = ~sys_clk;

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	#40;
	sys_rst_n <= 1'b1;
	#1000000
	$stop;
end

endmodule