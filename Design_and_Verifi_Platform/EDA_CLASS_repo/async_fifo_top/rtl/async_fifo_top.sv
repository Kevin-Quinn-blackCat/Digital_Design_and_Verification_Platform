module async_fifo_top 
    import fifo_cfg_pkg::*;
#(
    parameter int        DEPTH            = 64,
    parameter int        WIDTH            = 16,
    parameter bit        FWFT_EN          = 1'b0, // 1: 启用头优先模式 (First-Word Fall-Through)
    parameter bit        OUT_REG_EN       = 1'b0, // 1: 启用额外的输出管道寄存器
    parameter rst_type_e RST_TYPE         = ASYNC_RST,
    parameter rst_pol_e  RST_POLARITY     = ACTIVE_LOW,
    parameter int        SYNC_STAGES      = 2,    // 跨时钟域格雷码同步级数
    parameter bit        ALMOST_FULL_EN   = 1'b0, // 启用将近满信号
    parameter int        ALMOST_FULL_VAL  = 4,    // 距离满还剩多少空间时报将近满
    parameter bit        ALMOST_EMPTY_EN  = 1'b0, // 启用将近空信号
    parameter int        ALMOST_EMPTY_VAL = 4     // 距离空还剩多少数据时报将近空
)(
    input  logic                 wclk,
    input  logic                 wrst, 
    input  logic                 winc,
    input  logic [WIDTH-1:0]     wdata,
    output logic                 wfull,
    output logic                 walmost_full,

    input  logic                 rclk,
    input  logic                 rrst, 
    input  logic                 rinc,
    output logic [WIDTH-1:0]     rdata,
    output logic                 rempty,
    output logic                 ralmost_empty
);

/*======================== Parameter and Internal Signal =========================*/
    localparam int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1;
    localparam int PTR_WIDTH  = ADDR_WIDTH + 1;
    localparam int MEM_DEPTH  = 1 << ADDR_WIDTH;

    // 内部复位信号
    logic wrst_internal;
    logic rrst_internal;
    logic rst_cond_r; // 读域复位条件

    assign rst_cond_r = (RST_POLARITY == ACTIVE_HIGH) ? rrst_internal : !rrst_internal;

    // 格雷码同步信号
    logic [PTR_WIDTH-1:0] wptr_gray;
    logic [PTR_WIDTH-1:0] rptr_gray;
    logic [PTR_WIDTH-1:0] rptr_gray_sync_w2;
    logic [PTR_WIDTH-1:0] wptr_gray_sync_r2;

    // 内存读写地址
    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;

    // 原始读控制信号与 RAM 输出
    logic                 rinc_internal;
    logic                 rempty_raw;
    logic [WIDTH-1:0]     ram_rdata;

/*================================= Reset Bridge =================================*/
    generate
        if (RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_rst_bridge
            logic [1:0] wrst_sync_reg;
            logic [1:0] rrst_sync_reg;
            
            if (RST_POLARITY == ACTIVE_LOW) begin : g_wrst_al
                always_ff @(posedge wclk or negedge wrst) begin
                    if (!wrst) wrst_sync_reg <= '0;
                    else       wrst_sync_reg <= {wrst_sync_reg[0], 1'b1};
                end
                assign wrst_internal = wrst_sync_reg[1];
            end else begin : g_wrst_ah
                always_ff @(posedge wclk or posedge wrst) begin
                    if (wrst)  wrst_sync_reg <= '0;
                    else       wrst_sync_reg <= {wrst_sync_reg[0], 1'b1};
                end
                assign wrst_internal = ~wrst_sync_reg[1]; 
            end

            if (RST_POLARITY == ACTIVE_LOW) begin : g_rrst_al
                always_ff @(posedge rclk or negedge rrst) begin
                    if (!rrst) rrst_sync_reg <= '0;
                    else       rrst_sync_reg <= {rrst_sync_reg[0], 1'b1};
                end
                assign rrst_internal = rrst_sync_reg[1];
            end else begin : g_rrst_ah
                always_ff @(posedge rclk or posedge rrst) begin
                    if (rrst)  rrst_sync_reg <= '0;
                    else       rrst_sync_reg <= {rrst_sync_reg[0], 1'b1};
                end
                assign rrst_internal = ~rrst_sync_reg[1];
            end
        end else begin : g_rst_direct
            assign wrst_internal = wrst;
            assign rrst_internal = rrst;
        end
    endgenerate

/*================================== Instantiation ===============================*/
    
    // 读指针同步至写时钟域
    sync_gray #(
        .WIDTH(PTR_WIDTH),
        .STAGES(SYNC_STAGES),
        .RST_TYPE(RST_TYPE == ASYNC_SYNC_RELEASE ? ASYNC_RST : RST_TYPE),
        .RST_POLARITY(RST_TYPE == ASYNC_SYNC_RELEASE ? ACTIVE_LOW : RST_POLARITY)
    ) u_sync_r2w (
        .clk(wclk),
        .rst(wrst_internal),
        .din(rptr_gray),
        .dout(rptr_gray_sync_w2)
    );

    // 写指针同步至读时钟域
    sync_gray #(
        .WIDTH(PTR_WIDTH),
        .STAGES(SYNC_STAGES),
        .RST_TYPE(RST_TYPE == ASYNC_SYNC_RELEASE ? ASYNC_RST : RST_TYPE),
        .RST_POLARITY(RST_TYPE == ASYNC_SYNC_RELEASE ? ACTIVE_LOW : RST_POLARITY)
    ) u_sync_w2r (
        .clk(rclk),
        .rst(rrst_internal),
        .din(wptr_gray),
        .dout(wptr_gray_sync_r2)
    );

    // 写控制与指针
    wptr #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH),
        .RST_TYPE(RST_TYPE == ASYNC_SYNC_RELEASE ? ASYNC_RST : RST_TYPE),
        .RST_POLARITY(RST_TYPE == ASYNC_SYNC_RELEASE ? ACTIVE_LOW : RST_POLARITY),
        .ALMOST_FULL_EN(ALMOST_FULL_EN),
        .ALMOST_FULL_VAL(ALMOST_FULL_VAL)
    ) u_write_pointer (
        .wclk(wclk),
        .wrst(wrst_internal),
        .winc(winc),
        .rgray_sync(rptr_gray_sync_w2),
        .waddr(waddr),
        .wgray(wptr_gray),
        .wfull(wfull),
        .walmost_full(walmost_full)
    );

    // 读控制与指针
    rptr #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .RST_TYPE(RST_TYPE == ASYNC_SYNC_RELEASE ? ASYNC_RST : RST_TYPE),
        .RST_POLARITY(RST_TYPE == ASYNC_SYNC_RELEASE ? ACTIVE_LOW : RST_POLARITY),
        .ALMOST_EMPTY_EN(ALMOST_EMPTY_EN),
        .ALMOST_EMPTY_VAL(ALMOST_EMPTY_VAL)
    ) u_read_pointer (
        .rclk(rclk),
        .rrst(rrst_internal),
        .rinc(rinc_internal),
        .wgray_sync(wptr_gray_sync_r2),
        .raddr(raddr),
        .rgray(rptr_gray),
        .rempty(rempty_raw),
        .ralmost_empty(ralmost_empty)
    );

    // 内存实例化
    dual_port_ram #(
        .WIDTH(WIDTH),
        .DEPTH(MEM_DEPTH)
    ) u_dual_port_ram (
        .wclk(wclk),
        .waddr(waddr),
        .winc(winc && !wfull),
        .wdata(wdata),
        .raddr(raddr),
        .rdata(ram_rdata)
    );

/*============================ FWFT & Output Register Logic ============================*/
    generate
        // ---------------------------------------------------------------------
        // 模式 0: 标准模式 (FWFT=0, OUT_REG=0) -> 读使能后 1 拍输出
        // ---------------------------------------------------------------------
        if (!FWFT_EN && !OUT_REG_EN) begin : g_std_mode
            assign rinc_internal = rinc;
            assign rempty        = rempty_raw;
            
            if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_out_async
                always_ff @(posedge rclk or posedge rst_cond_r) begin
                    if (rst_cond_r) rdata <= '0;
                    else if (rinc)  rdata <= ram_rdata;
                end
            end else begin : g_out_sync
                always_ff @(posedge rclk) begin
                    if (rst_cond_r) rdata <= '0;
                    else if (rinc)  rdata <= ram_rdata;
                end
            end
        end

        // ---------------------------------------------------------------------
        // 模式 1: 带输出寄存器的标准模式 (FWFT=0, OUT_REG=1) -> 读使能后 2 拍输出
        // ---------------------------------------------------------------------
        else if (!FWFT_EN && OUT_REG_EN) begin : g_std_reg_mode
            assign rinc_internal = rinc;
            assign rempty        = rempty_raw;
            logic [WIDTH-1:0] rdata_stage1;

            if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_out_reg_async
                always_ff @(posedge rclk or posedge rst_cond_r) begin
                    if (rst_cond_r) begin
                        rdata_stage1 <= '0;
                        rdata        <= '0;
                    end else begin
                        if (rinc) rdata_stage1 <= ram_rdata;
                        rdata <= rdata_stage1;
                    end
                end
            end else begin : g_out_reg_sync
                always_ff @(posedge rclk) begin
                    if (rst_cond_r) begin
                        rdata_stage1 <= '0;
                        rdata        <= '0;
                    end else begin
                        if (rinc) rdata_stage1 <= ram_rdata;
                        rdata <= rdata_stage1;
                    end
                end
            end
        end

        // ---------------------------------------------------------------------
        // 模式 2: 头优先模式 (FWFT=1, OUT_REG=0) -> 0 拍输出（数据随 empty 自动呈现）
        // ---------------------------------------------------------------------
        else if (FWFT_EN && !OUT_REG_EN) begin : g_fwft_direct_mode
            // 在直通 FWFT 中，只要外部有读使能且 FIFO 非空，内部就对 RAM 递增
            assign rinc_internal = rinc && !rempty_raw;
            assign rempty        = rempty_raw;
            assign rdata         = ram_rdata;
        end

        // ---------------------------------------------------------------------
        // 模式 3: 带输出寄存器的 FWFT 模式 (FWFT=1, OUT_REG=1) -> 寄存器输出 & 头优先
        // ---------------------------------------------------------------------
        else if (FWFT_EN && OUT_REG_EN) begin : g_fwft_reg_mode
            // 使用经典的 Skid Buffer 架构
            logic [WIDTH-1:0] rdata_reg;
            logic             rdata_valid;
            
            // 当外部不读，但内部 RAM 输出了新数据时，使用一个暂存寄存器暂存
            logic [WIDTH-1:0] skid_reg;
            logic             skid_valid;

            assign rempty = !rdata_valid;
            
            // 只要输出寄存器空，或者外部正在读出，内部就允许向 RAM 索要新数据
            assign rinc_internal = !rempty_raw && (!rdata_valid || rinc || !skid_valid);

            if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_skid_async
                always_ff @(posedge rclk or posedge rst_cond_r) begin
                    if (rst_cond_r) begin
                        rdata_reg   <= '0;
                        rdata_valid <= 1'b0;
                        skid_reg    <= '0;
                        skid_valid  <= 1'b0;
                    end else begin
                        // 状态转移与数据寄存
                        if (rinc_internal) begin
                            if (rdata_valid && !rinc) begin
                                // 外部不读，但内部读了，数据滑入 skid_reg
                                skid_reg   <= ram_rdata;
                                skid_valid <= 1'b1;
                            end else begin
                                // 正常读出，数据直接进入主输出寄存器
                                rdata_reg   <= ram_rdata;
                                rdata_valid <= 1'b1;
                            end
                        end else if (rinc) begin
                            if (skid_valid) begin
                                // 外部读，且 skid 中有数据，将 skid 数据移入主寄存器
                                rdata_reg   <= skid_reg;
                                rdata_valid <= 1'b1;
                                skid_valid  <= 1'b0;
                            end else begin
                                rdata_valid <= 1'b0;
                            end
                        end
                    end
                end
            end else begin : g_skid_sync
                always_ff @(posedge rclk) begin
                    if (rst_cond_r) begin
                        rdata_reg   <= '0;
                        rdata_valid <= 1'b0;
                        skid_reg    <= '0;
                        skid_valid  <= 1'b0;
                    end else begin
                        if (rinc_internal) begin
                            if (rdata_valid && !rinc) begin
                                skid_reg   <= ram_rdata;
                                skid_valid <= 1'b1;
                            end else begin
                                rdata_reg   <= ram_rdata;
                                rdata_valid <= 1'b1;
                            end
                        end else if (rinc) begin
                            if (skid_valid) begin
                                rdata_reg   <= skid_reg;
                                rdata_valid <= 1'b1;
                                skid_valid  <= 1'b0;
                            end else begin
                                rdata_valid <= 1'b0;
                            end
                        end
                    end
                end
            end

            assign rdata = rdata_reg;
        end
    endgenerate

endmodule