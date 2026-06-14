`timescale 1ns/1ps

module wptr #(
    parameter int ADDR_WIDTH = 4,
    parameter int ALMOST_FULL_THRESHOLD = 2
) (
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  winc,
    input  logic [ADDR_WIDTH:0]   rptr_g_sync,
    output logic                  wfull,
    output logic                  walmost_full,
    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [ADDR_WIDTH:0]   wptr_g
);

/*======================== Parameter and Internal Signal =========================*/
localparam int DEPTH = 1 << ADDR_WIDTH;

logic [ADDR_WIDTH:0] wptr_bin;
logic [ADDR_WIDTH:0] wbin_next;
logic [ADDR_WIDTH:0] wgray_next;

logic [ADDR_WIDTH:0] rbin_sync;
logic [ADDR_WIDTH:0] occupancy_next;
logic                wfull_val; // 格雷码域直接比较产生的满信号

/*================================== Main Code ===================================*/

always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        wptr_bin <= '0;
        wptr_g   <= '0;
    end else begin
        wptr_bin <= wbin_next;
        wptr_g   <= wgray_next;
    end
end

// 产生真正的递增控制
assign wbin_next  = wptr_bin + (winc & ~wfull);
assign wgray_next = wbin_next ^ (wbin_next >> 1);
assign waddr      = wptr_bin[ADDR_WIDTH-1:0];

/*===在格雷码域直接判断满，消除多 bit 采样抖动===*/
// 满条件：写指针格雷码的最高两位与同步读指针相反，其余位相同
assign wfull_val = (wgray_next == {~rptr_g_sync[ADDR_WIDTH:ADDR_WIDTH-1], rptr_g_sync[ADDR_WIDTH-2:0]});

/*===用于将近满的辅助二进制计算===*/
function automatic logic [ADDR_WIDTH:0] gray2bin (input logic [ADDR_WIDTH:0] gray);
    logic [ADDR_WIDTH:0] bin;
    bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
    for (int i = ADDR_WIDTH - 1; i >= 0; i--) begin
        bin[i] = bin[i+1] ^ gray[i];
    end
    return bin;
endfunction

assign rbin_sync      = gray2bin(rptr_g_sync);
assign occupancy_next = wbin_next - rbin_sync;

always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        wfull        <= 1'b0;
        walmost_full <= 1'b0;
    end else begin
        wfull        <= wfull_val;
        walmost_full <= (occupancy_next >= (DEPTH - ALMOST_FULL_THRESHOLD));
    end
end

/*==================================SVA==================================*/

// 禁止溢出写：满时写指针绝对不能改变
property p_no_overflow_write;
    @(posedge wclk) disable iff (!wrst_n)
    wfull |=> $stable(wptr_bin);
endproperty
a_no_overflow_write: assert property (p_no_overflow_write);


// 格雷码单比特变化检测：相邻的格雷码在变化时只能有一位发生翻转
property p_wptr_gray_single_bit;
    @(posedge wclk) disable iff (!wrst_n)
    $changed(wptr_g) |-> ($countones(wptr_g ^ $past(wptr_g)) == 1);
endproperty
a_wptr_gray_single_bit: assert property (p_wptr_gray_single_bit);


// 满标志一致性：当 wfull 为高时，walmost_full 也必须为高
property p_full_implies_almost_full;
    @(posedge wclk) disable iff (!wrst_n)
    wfull |-> walmost_full;
endproperty
a_full_implies_almost_full: assert property (p_full_implies_almost_full);


// 二进制指针与格雷码指针一致性：任意时刻 wptr_g 必须是 wptr_bin 转换后的格雷码
property p_bin_gray_consistency;
    @(posedge wclk) disable iff (!wrst_n)
    wptr_g == (wptr_bin ^ (wptr_bin >> 1));
endproperty
a_bin_gray_consistency: assert property (p_bin_gray_consistency);


// 指针递增性：当非满且有写使能时，写指针在下一个周期必须恰好加 1
property p_wptr_increment;
    @(posedge wclk) disable iff (!wrst_n)
    (winc && !wfull) |=> (wptr_bin == $past(wptr_bin) + 1'b1);
endproperty
a_wptr_increment: assert property (p_wptr_increment);


// 复位状态检查：复位时所有关键输出和指针必须清零
property p_reset_state;
    @(posedge wclk) !wrst_n |-> (wptr_bin == '0 && wptr_g == '0 && wfull == 1'b0 && walmost_full == 1'b0);
endproperty
a_reset_state: assert property (p_reset_state);

endmodule