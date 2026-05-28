module wptr 
    import fifo_cfg_pkg::*;
#(
    parameter int        ADDR_WIDTH      = 6,
    parameter int        DEPTH           = 64,
    parameter rst_type_e RST_TYPE        = ASYNC_RST,
    parameter rst_pol_e  RST_POLARITY    = ACTIVE_LOW,
    parameter bit        ALMOST_FULL_EN  = 1'b0,
    parameter int        ALMOST_FULL_VAL = 4
)(
    input  logic                  wclk,
    input  logic                  wrst, // 来自顶层的内部复位信号
    input  logic                  winc,
    input  logic [ADDR_WIDTH:0]   rgray_sync,
    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [ADDR_WIDTH:0]   wgray,
    output logic                  wfull,
    output logic                  walmost_full
);

    localparam int PTR_WIDTH = ADDR_WIDTH + 1;

    logic [PTR_WIDTH-1:0] wbin;
    logic [PTR_WIDTH-1:0] wbin_next;
    logic [PTR_WIDTH-1:0] wgray_next;
    
    logic                 wfull_val;
    logic                 rst_cond;

    // 复位极性选择
    assign rst_cond = (RST_POLARITY == ACTIVE_HIGH) ? wrst : !wrst;

    // 计算下一个二进制地址和格雷码
    assign wbin_next  = wbin + (winc && !wfull);
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;
    
    // 内存写入地址使用当前的二进制地址
    assign waddr = wbin[ADDR_WIDTH-1:0];

    // 满标志判断逻辑：最高位和次高位不同，其余位相同
    assign wfull_val = (wgray_next == {~rgray_sync[PTR_WIDTH-1:PTR_WIDTH-2], rgray_sync[PTR_WIDTH-3:0]});

    // 寄存器时序逻辑：根据复位类型进行 generate
    generate
        if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_async_rst
            always_ff @(posedge wclk or posedge rst_cond) begin
                if (rst_cond) begin
                    wbin  <= '0;
                    wgray <= '0;
                    wfull <= 1'b0;
                end else begin
                    wbin  <= wbin_next;
                    wgray <= wgray_next;
                    wfull <= wfull_val;
                end
            end
        end else begin : g_sync_rst
            always_ff @(posedge wclk) begin
                if (rst_cond) begin
                    wbin  <= '0;
                    wgray <= '0;
                    wfull <= 1'b0;
                end else begin
                    wbin  <= wbin_next;
                    wgray <= wgray_next;
                    wfull <= wfull_val;
                end
            end
        end
    endgenerate

    // =========================================================================
    // 将近满 (Almost Full) 检测逻辑
    // =========================================================================
    generate
        if (ALMOST_FULL_EN) begin : g_almost_full
            logic [PTR_WIDTH-1:0] rbin_sync;
            logic [PTR_WIDTH-1:0] wcount;
            logic                 walmost_full_val;

            // 格雷码转二进制：将同步过来的读指针还原为二进制
            always_comb begin
                rbin_sync[PTR_WIDTH-1] = rgray_sync[PTR_WIDTH-1];
                for (int i = PTR_WIDTH-2; i >= 0; i--) begin
                    rbin_sync[i] = rbin_sync[i+1] ^ rgray_sync[i];
                end
            end

            // 计算当前写入域看到的 FIFO 占用大小 (考虑回绕)
            assign wcount = wbin - rbin_sync;

            // 预估下一拍是否达到将近满阈值
            // 当剩余空间小于等于 ALMOST_FULL_VAL 时拉高
            assign walmost_full_val = (wcount >= (DEPTH - ALMOST_FULL_VAL));

            if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_af_async
                always_ff @(posedge wclk or posedge rst_cond) begin
                    if (rst_cond) walmost_full <= 1'b0;
                    else          walmost_full <= walmost_full_val;
                end
            end else begin : g_af_sync
                always_ff @(posedge wclk) begin
                    if (rst_cond) walmost_full <= 1'b0;
                    else          walmost_full <= walmost_full_val;
                end
            end
        end else begin : g_no_almost_full
            assign walmost_full = 1'b0;
        end
    endgenerate

endmodule