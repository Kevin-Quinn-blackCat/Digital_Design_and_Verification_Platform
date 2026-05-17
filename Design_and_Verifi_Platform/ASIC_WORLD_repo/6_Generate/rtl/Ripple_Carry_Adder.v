module Ripple_Carry_Adder #(
	parameter WIDTH = 4
)(
	input  wire  [WIDTH-1:0]  a,
	input  wire  [WIDTH-1:0]  b,
	input  wire               cin,
	output wire  [WIDTH-1:0]  sum,
	output wire               cout
);

/*======================== Parameter and Internal Signal =========================*/

/*===Paramter===*/

/*=== Signal ===*/
wire  [WIDTH:0]  carry;

/*================================== Main Code ===================================*/

assign carry[0] = cin;
assign cout = carry[WIDTH];

/*================================ Instantiation =================================*/

genvar i;
generate
	for (i = 0; i < WIDTH; i = i + 1) begin : FULL_ADDER
		full_adder  full_adder_inst (
			.a(a[i]),
			.b(b[i]),
			.cin(carry[i]),
			.sum(sum[i]),
			.cout(carry[i+1])
		);
	end
endgenerate


endmodule