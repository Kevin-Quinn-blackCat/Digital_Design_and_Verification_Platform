module mux4_reg #(parameter WIDTH = 32) (
    input  wire clk,
    input  wire [1:0] sel,
    input  wire [WIDTH-1:0] d0, d1, d2, d3,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        case(sel)
            2'b00: q <= d0;
            2'b01: q <= d1;
            2'b10: q <= d2;
            2'b11: q <= d3;
        endcase
    end
endmodule