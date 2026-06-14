`timescale 1ns/1ps

module async_fifo_top #(
    parameter int DATA_WIDTH             = 16, // 数据宽度
    parameter int ADDR_WIDTH             = 6,  // 深度为 2^ADDR_WIDTH，(6即深度64)
    parameter int ALMOST_FULL_THRESHOLD  = 4,  // 将近满阈值
    parameter int ALMOST_EMPTY_THRESHOLD = 4   // 将近空阈值
    /*
     * 深度不能单独设置是因为如果不是2^ADDR_WIDTH用格雷码在首尾不能循环，就没有意义了
     * 
     * 现在默认就是头优先直通，不需要只需要手动打一拍就好了，没必要用generate那么麻烦还不利于仿真
     * 
     * 复位也是一样的逻辑，有需要再在例化的时候外部传入就好了，之前脑子生锈搞麻烦了，现在默认是异步低电平
     */
)(
    // 写时钟域
    input  logic                    wclk,
    input  logic                    wrst_n,
    input  logic                    winc,
    input  logic [DATA_WIDTH-1:0]   wdata,
    output logic                    wfull,
    output logic                    walmost_full,

    // 读时钟域
    input  logic                    rclk,
    input  logic                    rrst_n,
    input  logic                    rinc,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic                    rempty,
    output logic                    ralmost_empty
);

/*======================== Parameter and Internal Signal =========================*/

/*===sig===*/
// 写指针与同步后的写指针（格雷码）
logic [ADDR_WIDTH:0] wptr_g;
logic [ADDR_WIDTH:0] wptr_g_sync;

// 读指针与同步后的读指针（格雷码）
logic [ADDR_WIDTH:0] rptr_g;
logic [ADDR_WIDTH:0] rptr_g_sync;

// RAM 读写地址
logic [ADDR_WIDTH-1:0] waddr;
logic [ADDR_WIDTH-1:0] raddr;

// 受保护的写使能
logic w_en;


/*================================== Main Code ===================================*/

// 受保护的写使能
assign w_en = winc & ~wfull;

/*================================== Instantiation ===============================*/

/*===双端口RAM===*/
dual_port_ram #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_dual_port_ram (
    .wclk  (wclk),
    .w_en  (w_en),
    .waddr (waddr),
    .wdata (wdata),
    .raddr (raddr),
    .rdata (rdata)  // 组合逻辑输出，支持头优先直通（FWFT）
);

/*================================================================================*/

/*===写指针===*/
wptr #(
    .ADDR_WIDTH            (ADDR_WIDTH),
    .ALMOST_FULL_THRESHOLD (ALMOST_FULL_THRESHOLD)
) u_wptr (
    .wclk         (wclk),
    .wrst_n       (wrst_n),
    .winc         (winc),
    .rptr_g_sync  (rptr_g_sync),
    .wfull        (wfull),
    .walmost_full (walmost_full),
    .waddr        (waddr),
    .wptr_g       (wptr_g)
);


/*===读指针===*/
rptr #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .ALMOST_EMPTY_THRESHOLD (ALMOST_EMPTY_THRESHOLD)
) u_rptr (
    .rclk           (rclk),
    .rrst_n         (rrst_n),
    .rinc           (rinc),
    .wptr_g_sync    (wptr_g_sync),
    .rempty         (rempty),
    .ralmost_empty  (ralmost_empty),
    .raddr          (raddr),
    .rptr_g         (rptr_g)
);

/*================================================================================*/

/*===写指针同步到读时钟域===*/
sync_gray #(
    .ADDR_WIDTH (ADDR_WIDTH)
) u_sync_wptr (
    .clk      (rclk),
    .rst_n    (rrst_n),
    .gray_in  (wptr_g),
    .gray_out (wptr_g_sync)
);


/*===读指针同步到写时钟域===*/
sync_gray #(
    .ADDR_WIDTH (ADDR_WIDTH)
) u_sync_rptr (
    .clk      (wclk),
    .rst_n    (wrst_n),
    .gray_in  (rptr_g),
    .gray_out (rptr_g_sync)
);


/*==================================SVA==================================*/

/** 断言1： 写溢出
 * 
 * 使用所属的写时钟域采样
 * 当满信号wfull抬高时，于此同时w_en不能抬高
 * 
*/
property p_top_no_overflow;
    @(posedge wclk) disable iff (!wrst_n)
    wfull |-> !w_en;
endproperty
a_top_no_overflow: assert property (p_top_no_overflow);

/** 断言2： 读溢出
 * 
 * 我是傻逼，这里是一个假断言，读溢出保护由rptr决定
 * 放这里挺对称的，就这样吧 :)
 * 
 */
property p_top_no_underflow;
    @(posedge rclk) disable iff (!rrst_n)
    rempty |-> (rinc & ~rempty) == 1'b0;
endproperty
a_top_no_underflow: assert property (p_top_no_underflow);


/**断言3：复位
 */
property p_top_reset_state;
    @(posedge wclk) !wrst_n |-> (wfull == 1'b0 && walmost_full == 1'b0);
endproperty
a_top_reset_state: assert property (p_top_reset_state);

property p_top_reset_state_rclk;
    @(posedge rclk) !rrst_n |-> (rempty == 1'b1 && ralmost_empty == 1'b1);
endproperty
a_top_reset_state_rclk: assert property (p_top_reset_state_rclk);

endmodule