/**
 * File         : gene.v
 * Author list  : KevinQuinn
 * Type         : Digital Design
 * tool         : Modelsim
 * Description  : 
 * 				1.OP_MODE == 0 Ripple Carry Adder
 * 				2.OP_MODE == 1 Bitwise NOT
 * 				3.OP_MODE == 2 Bit-reversal
 */


module gene #(
	parameter WIDTH = 4,
	parameter PIPELINED = 1,
    parameter OP_MODE = 0 // 0: Adder, 1: NOT, 2: Reverse
)(
	input  wire               sys_clk,
	input  wire  [WIDTH-1:0]  a,
	input  wire  [WIDTH-1:0]  b,
	input  wire               cin_mux,
	output wire  [WIDTH-1:0]  data_out,
	output wire               cout
);

/*======================== Parameter and Internal Signal =========================*/

/*===Paramter===*/

/*=== Signal ===*/
wire [WIDTH-1:0] _data_out;
wire  			 _cout;

/*================================== Main Code ===================================*/
generate
	if (PIPELINED) begin : PIPELINED
		/*===sig===*/
		reg [WIDTH-1:0]  _data_out_reg;
		reg  			 _cout_reg;

		/*===logic===*/
		// reg
		always @(posedge sys_clk) begin
			_data_out_reg <= _data_out;
			_cout_reg     <= _cout;
		end

		// output
		assign data_out = _data_out_reg;
		assign cout = _cout_reg;

	end

	else begin : NO_PIPELINED
		/*===logic===*/
		assign data_out = _data_out;
		assign cout = _cout;
	end
endgenerate


/*================================ Instantiation =================================*/
generate
	case (OP_MODE)
		0 : begin : ADDER
		/*===inst===*/
		Ripple_Carry_Adder # (
			.WIDTH(WIDTH)
		) Ripple_Carry_Adder_inst (
			.a(a),
			.b(b),
			.cin(cin_mux),
			.sum(_data_out),
			.cout(_cout)
		);
		end

		1 : begin : NOT
			/*===logic===*/
			assign _data_out = (cin_mux) ? (~b) : (~a);
			assign _cout = 1'b0;
		end

		2 : begin : REVERSE
			/*===sig===*/
			wire [WIDTH-1:0] data_in;

			/*===logic===*/
			assign data_in = (cin_mux) ? (b) : (a);
			assign _cout = 1'b0;

			/*===inst===*/
			reverse # (
				.WIDTH(WIDTH)
			)
			reverse_inst (
			.data_in(data_in),
			.data_out(_data_out)
			);
		end

		default: begin : NONE
			/*===logic===*/
			assign _data_out = 1'b0;
			assign _cout = 1'b0;
		end
	endcase
endgenerate



endmodule