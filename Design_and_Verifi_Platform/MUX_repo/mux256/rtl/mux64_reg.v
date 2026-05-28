module mux64_reg #(parameter WIDTH = 32) (
    input  wire clk,
    input  wire [5:0] sel,
    input  wire [WIDTH*64-1:0] din,
    output wire [WIDTH-1:0] q
);
    wire [WIDTH-1:0] m16_out [3:0];
    reg  [1:0] sel_hi_d1, sel_hi_d2; // 需要延迟2拍以匹配mux16的深度

    generate
        for(genvar i=0; i<4; i=i+1) begin : stage_64_4
            mux16_reg #(WIDTH) inst (
                .clk(clk), .sel(sel[3:0]),
                .din(din[WIDTH*(i*16) +: WIDTH*16]),
                .q(m16_out[i])
            );
        end
    endgenerate

    always @(posedge clk) begin
        sel_hi_d1 <= sel[5:4];
        sel_hi_d2 <= sel_hi_d1; // 经过两拍后与 m16_out 对齐
    end

    mux4_reg #(WIDTH) final_stage (
        .clk(clk), .sel(sel_hi_d2),
        .d0(m16_out[0]), .d1(m16_out[1]), .d2(m16_out[2]), .d3(m16_out[3]),
        .q(q)
    );
endmodule