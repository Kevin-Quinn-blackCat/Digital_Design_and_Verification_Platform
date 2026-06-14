`timescale 1ns/1ps

module sync_gray #(
    parameter int ADDR_WIDTH = 4
) (
    input  logic                  clk,      // 目的时钟域时钟
    input  logic                  rst_n,    // 目的时钟域复位（异步复位，同步释放后输入）
    input  logic [ADDR_WIDTH:0]   gray_in,  // 源时钟域输入的格雷码
    output logic [ADDR_WIDTH:0]   gray_out  // 同步到目的时钟域的格雷码
);

/*======================== Parameter and Internal Signal =========================*/
/*===param===*/

/*===sig===*/
logic [ADDR_WIDTH:0] sync_reg_0;
logic [ADDR_WIDTH:0] sync_reg_1;


/*================================== Main Code ===================================*/

/*===sync_dual_reg===*/
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_reg_0 <= '0;
        sync_reg_1 <= '0;
    end else begin
        sync_reg_0 <= gray_in;
        sync_reg_1 <= sync_reg_0;
    end
end

/*===output===*/
assign gray_out = sync_reg_1;


/*==================================SVA==================================*/

/* 断言1：复位断言
 * 
 * 使用对应时钟域：clk（这个是传进来的）进行采样
 * 如果复位发生
 * 蕴含着默认输出为 0
 * 
 */
property p_reset_behavior;
    @(posedge clk) (!rst_n) |-> (gray_out == '0);
endproperty
a_reset_behavior: assert property (p_reset_behavior);


/* 断言2：确定性断言
 * 
 * 使用对应时钟域采样
 * 复位时不断言
 * 输出信号不能是高阻态或者位置态
 * 
 */
    property p_no_unknown_out;
        @(posedge clk) disable iff (!rst_n)
        !$isunknown(gray_out);
    endproperty
    a_no_unknown_out: assert property (p_no_unknown_out);


endmodule