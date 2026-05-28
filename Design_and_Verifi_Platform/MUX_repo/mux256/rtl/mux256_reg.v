/**
 * File         : mux256.v
 * Author list  : kq
 * Type         : Digital Design
 * tool         : 
 * Description  : 
 * 				1. 4:1(1reg) -> 16:4 -> 16:1 (1reg)
 * 				2. 16:1 -> 64:4 -> 64:1 (1reg)
 * 				3. 64:1 -> 256:4 -> 256:1 (1reg)
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By             Version     Description
 * 2026-05-28    kq             v0.0        Created
 * -----------------------------------------------------------------------------
 */


module mux256_reg #(parameter WIDTH = 32) (
    input  wire clk,
    input  wire [7:0] sel,
    input  wire [WIDTH*256-1:0] din,
    output wire [WIDTH-1:0] q
);
    wire [WIDTH-1:0] m64_out [3:0];
    reg  [1:0] sel_hi_d1, sel_hi_d2, sel_hi_d3; // 需要延迟3拍匹配mux64深度

    generate
        for(genvar i=0; i<4; i=i+1) begin : stage_256_4
            mux64_reg #(WIDTH) inst (
                .clk(clk), .sel(sel[5:0]),
                .din(din[WIDTH*(i*64) +: WIDTH*64]),
                .q(m64_out[i])
            );
        end
    endgenerate

    always @(posedge clk) begin
        sel_hi_d1 <= sel[7:6];
        sel_hi_d2 <= sel_hi_d1;
        sel_hi_d3 <= sel_hi_d2; 
    end

    mux4_reg #(WIDTH) final_stage (
        .clk(clk), .sel(sel_hi_d3),
        .d0(m64_out[0]), .d1(m64_out[1]), .d2(m64_out[2]), .d3(m64_out[3]),
        .q(q)
    );
endmodule