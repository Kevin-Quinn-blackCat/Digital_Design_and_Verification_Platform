module mux16_reg #(parameter WIDTH = 32) (
    input  wire clk,
    input  wire [3:0] sel,
    input  wire [WIDTH*16-1:0] din,
    output wire [WIDTH-1:0] q
);
    wire [WIDTH-1:0] m4_out [3:0];
    reg  [1:0] sel_hi;

    // 并行拆分 16:4
    genvar i;
    generate
        for(i=0; i<4; i=i+1) begin : stage_16_4
            mux4_reg #(WIDTH) inst (
                .clk(clk), .sel(sel[1:0]),
                .d0(din[WIDTH*(i*4+0) +: WIDTH]),
                .d1(din[WIDTH*(i*4+1) +: WIDTH]),
                .d2(din[WIDTH*(i*4+2) +: WIDTH]),
                .d3(din[WIDTH*(i*4+3) +: WIDTH]),
                .q(m4_out[i])
            );
        end
    endgenerate

    // 串连缓存 4:1 (延迟1拍同步sel)
    always @(posedge clk) sel_hi <= sel[3:2];

    mux4_reg #(WIDTH) final_stage (
        .clk(clk), .sel(sel_hi),
        .d0(m4_out[0]), .d1(m4_out[1]), .d2(m4_out[2]), .d3(m4_out[3]),
        .q(q)
    );
endmodule