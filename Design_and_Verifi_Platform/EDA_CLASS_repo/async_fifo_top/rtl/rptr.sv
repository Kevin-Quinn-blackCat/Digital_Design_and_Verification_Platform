module rptr 
    import fifo_cfg_pkg::*;
#(
    parameter int        ADDR_WIDTH       = 6,
    parameter rst_type_e RST_TYPE         = ASYNC_RST,
    parameter rst_pol_e  RST_POLARITY     = ACTIVE_LOW,
    parameter bit        ALMOST_EMPTY_EN  = 1'b0,
    parameter int        ALMOST_EMPTY_VAL = 4,
    parameter bit        FWFT_EN          = 1'b0
)(
    input  logic                  rclk,
    input  logic                  rrst, // 来自顶层的内部复位信号
    input  logic                  rinc,
    input  logic [ADDR_WIDTH:0]   wgray_sync,
    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [ADDR_WIDTH:0]   rgray,
    output logic                  rempty,
    output logic                  ralmost_empty
);

    localparam int PTR_WIDTH = ADDR_WIDTH + 1;

    logic [PTR_WIDTH-1:0] rbin;
    logic [PTR_WIDTH-1:0] rbin_next;
    logic [PTR_WIDTH-1:0] rgray_next;
    
    logic                 rempty_val;
    logic                 rst_cond;

    // 复位极性选择
    assign rst_cond = (RST_POLARITY == ACTIVE_HIGH) ? rrst : !rrst;

    // 计算下一个二进制地址和格雷码
    // 注意：如果启用了 FWFT，读指针的递增条件会有微调，我们由顶层或在此处进行统一的时序管理
    assign rbin_next  = rbin + (rinc && !rempty);
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;
    
    // 内存读取地址
    assign raddr = rbin[ADDR_WIDTH-1:0];

    // 空标志判断逻辑：读格雷码等于同步过来的写格雷码
    assign rempty_val = (rgray_next == wgray_sync);

    // 寄存器时序逻辑：根据复位类型进行 generate
    generate
        if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_async_rst
            always_ff @(posedge rclk or posedge rst_cond) begin
                if (rst_cond) begin
                    rbin   <= '0;
                    rgray  <= '0;
                    rempty <= 1'b1; // 复位时为空
                end else begin
                    rbin   <= rbin_next;
                    rgray  <= rgray_next;
                    rempty <= rempty_val;
                end
            end
        end else begin : g_sync_rst
            always_ff @(posedge rclk) begin
                if (rst_cond) begin
                    rbin   <= '0;
                    rgray  <= '0;
                    rempty <= 1'b1;
                end else begin
                    rbin   <= rbin_next;
                    rgray  <= rgray_next;
                    rempty <= rempty_val;
                end
            end
        end
    endgenerate

    // =========================================================================
    // 将近空 (Almost Empty) 检测逻辑
    // =========================================================================
    generate
        if (ALMOST_EMPTY_EN) begin : g_almost_empty
            logic [PTR_WIDTH-1:0] wbin_sync;
            logic [PTR_WIDTH-1:0] rcount;
            logic                 ralmost_empty_val;

            // 格雷码转二进制：将同步过来的写指针还原为二进制
            always_comb begin
                wbin_sync[PTR_WIDTH-1] = wgray_sync[PTR_WIDTH-1];
                for (int i = PTR_WIDTH-2; i >= 0; i--) begin
                    wbin_sync[i] = wbin_sync[i+1] ^ wgray_sync[i];
                end
            end

            // 计算当前读取域看到的 FIFO 剩余数据量
            assign rcount = wbin_sync - rbin;

            // 预估下一拍是否达到将近空阈值
            // 当数据量小于等于 ALMOST_EMPTY_VAL 时拉高
            assign ralmost_empty_val = (rcount <= ALMOST_EMPTY_VAL);

            if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_ae_async
                always_ff @(posedge rclk or posedge rst_cond) begin
                    if (rst_cond) ralmost_empty <= 1'b1; // 复位时默认处于将近空状态
                    else          ralmost_empty <= ralmost_empty_val;
                end
            end else begin : g_ae_sync
                always_ff @(posedge rclk) begin
                    if (rst_cond) ralmost_empty <= 1'b1;
                    else          ralmost_empty <= ralmost_empty_val;
                end
            end
        end else begin : g_no_almost_empty
            assign ralmost_empty = 1'b0;
        end
    endgenerate

endmodule