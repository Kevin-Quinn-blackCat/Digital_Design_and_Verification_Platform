`timescale 1ns/1ps

module rptr #(
    parameter int ADDR_WIDTH = 4,
    parameter int ALMOST_EMPTY_THRESHOLD = 2
) (
    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rinc,
    input  logic [ADDR_WIDTH:0]   wptr_g_sync,
    output logic                  rempty,
    output logic                  ralmost_empty,
    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [ADDR_WIDTH:0]   rptr_g
);

/*======================== Parameter and Internal Signal =========================*/
localparam int DEPTH = 1 << ADDR_WIDTH;

logic [ADDR_WIDTH:0] rptr_bin;
logic [ADDR_WIDTH:0] rbin_next;
logic [ADDR_WIDTH:0] rgray_next;

logic [ADDR_WIDTH:0] wbin_sync;
logic [ADDR_WIDTH:0] occupancy_next;
logic                rempty_val; // 格雷码域直接比较产生的空信号

/*================================== Main Code ===================================*/

always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rptr_bin <= '0;
        rptr_g   <= '0;
    end else begin
        rptr_bin <= rbin_next;
        rptr_g   <= rgray_next;
    end
end

// 支持 FWFT 模式
assign rbin_next  = rptr_bin + (rinc & ~rempty);
assign rgray_next = rbin_next ^ (rbin_next >> 1);
assign raddr      = rptr_bin[ADDR_WIDTH-1:0];

/*===在格雷码域直接判断空，消除多 bit 采样抖动===*/
// 空条件：读指针格雷码完全等于同步写指针格雷码
// 貌似不这么做，而和将近信号一起赋值会导致某些断言失败，Why？
assign rempty_val = (rgray_next == wptr_g_sync);

/*=== 用于将近空的辅助二进制计算 ===*/
function automatic logic [ADDR_WIDTH:0] gray2bin (input logic [ADDR_WIDTH:0] gray);
    logic [ADDR_WIDTH:0] bin;
    bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
    for (int i = ADDR_WIDTH - 1; i >= 0; i--) begin
        bin[i] = bin[i+1] ^ gray[i];
    end
    return bin;
endfunction

assign wbin_sync      = gray2bin(wptr_g_sync);
assign occupancy_next = wbin_sync - rbin_next;

always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rempty        <= 1'b1;
        ralmost_empty <= 1'b1;
    end else begin
        rempty        <= rempty_val;
        ralmost_empty <= (occupancy_next <= ALMOST_EMPTY_THRESHOLD);
    end
end

/*==================================SVA==================================*/

// 禁止空读：空时读指针绝对不能改变
property p_no_underflow_read;
    @(posedge rclk) disable iff (!rrst_n)
    rempty |=> $stable(rptr_bin);
endproperty
a_no_underflow_read: assert property (p_no_underflow_read);


// 格雷码单比特变化检测：相邻的格雷码在变化时只能有一位发生翻转
property p_rptr_gray_single_bit;
    @(posedge rclk) disable iff (!rrst_n)
    $changed(rptr_g) |-> ($countones(rptr_g ^ $past(rptr_g)) == 1);
endproperty
a_rptr_gray_single_bit: assert property (p_rptr_gray_single_bit);


// 空标志一致性：当 rempty 为高时，ralmost_empty 也必须为高
property p_empty_implies_almost_empty;
    @(posedge rclk) disable iff (!rrst_n)
    rempty |-> ralmost_empty;
endproperty
a_empty_implies_almost_empty: assert property (p_empty_implies_almost_empty);


// 二进制指针与格雷码指针一致性：任意时刻 rptr_g 必须是 rptr_bin 转换后的格雷码
property p_bin_gray_consistency;
    @(posedge rclk) disable iff (!rrst_n)
    rptr_g == (rptr_bin ^ (rptr_bin >> 1));
endproperty
a_bin_gray_consistency: assert property (p_bin_gray_consistency);


// 指针递增性：当非空且有读使能时，读指针在下一个周期必须恰好加 1
property p_rptr_increment;
    @(posedge rclk) disable iff (!rrst_n)
    (rinc && !rempty) |=> (rptr_bin == $past(rptr_bin) + 1'b1);
endproperty
a_rptr_increment: assert property (p_rptr_increment);


// 复位状态检查：复位时所有指针必须清零，空/将近空标志必须置 1
property p_reset_state;
    @(posedge rclk) !rrst_n |-> (rptr_bin == '0 && rptr_g == '0 && rempty == 1'b1 && ralmost_empty == 1'b1);
endproperty
a_reset_state: assert property (p_reset_state);

endmodule