/* verilator lint_off DECLFILENAME */
module async_fifo #(
    parameter int DEPTH = 64,
    parameter int WIDTH = 16
)(
    input  logic                 wclk,
    input  logic                 wrst_n,
    input  logic                 winc,
    input  logic [WIDTH-1:0]      wdata,
    output logic                 wfull,

    input  logic                 rclk,
    input  logic                 rrst_n,
    input  logic                 rinc,
    output logic [WIDTH-1:0]      rdata,
    output logic                 rempty
    );

    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int PTR_WIDTH  = ADDR_WIDTH + 1;
    localparam int MEM_DEPTH  = 1 << ADDR_WIDTH;

    logic [PTR_WIDTH-1:0] wptr_gray;

    logic [PTR_WIDTH-1:0] rptr_gray;

    logic [PTR_WIDTH-1:0] rptr_gray_sync_w2;
    logic [PTR_WIDTH-1:0] wptr_gray_sync_r2;
    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;

    sync_gray #(.WIDTH(PTR_WIDTH)) u_sync_r2w (
        .clk(wclk),
        .rst_n(wrst_n),
        .din(rptr_gray),
        .dout(rptr_gray_sync_w2)
    );

    sync_gray #(.WIDTH(PTR_WIDTH)) u_sync_w2r (
        .clk(rclk),
        .rst_n(rrst_n),
        .din(wptr_gray),
        .dout(wptr_gray_sync_r2)
    );

    write_pointer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) u_write_pointer (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .rgray_sync(rptr_gray_sync_w2),
        .waddr(waddr),
        .wgray(wptr_gray),
        .wfull(wfull)
    );

    read_pointer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) u_read_pointer (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .wgray_sync(wptr_gray_sync_r2),
        .raddr(raddr),
        .rgray(rptr_gray),
        .rempty(rempty)
    );

    dual_port_ram #(
        .WIDTH(WIDTH),
        .DEPTH(MEM_DEPTH)
    ) u_dual_port_ram (
        .wclk(wclk),
        .waddr(waddr),
        .winc(winc && !wfull),
        .wdata(wdata),
        .rclk(rclk),
        .raddr(raddr),
        .rinc(rinc && !rempty),
        .rdata(rdata)
    );

endmodule

module write_pointer #(
    parameter int ADDR_WIDTH = 6,
    parameter int PTR_WIDTH = ADDR_WIDTH + 1
)(
    input  logic                 wclk,
    input  logic                 wrst_n,
    input  logic                 winc,
    input  logic [PTR_WIDTH-1:0]  rgray_sync,
    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [PTR_WIDTH-1:0]  wgray,
    output logic                 wfull
    );

    logic [PTR_WIDTH-1:0] wbin;
    logic [PTR_WIDTH-1:0] wbin_next;
    logic [PTR_WIDTH-1:0] wgray_next;

    // 计算下一个二进制地址和格雷码
    assign wbin_next  = wbin + (winc && !wfull);
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;
    
    // 内存写入地址使用当前的二进制地址
    assign waddr = wbin[ADDR_WIDTH-1:0];

    // 满标志判断逻辑：最高位和次高位不同，其余位相同
    wire wfull_val = (wgray_next == {~rgray_sync[PTR_WIDTH-1:PTR_WIDTH-2], rgray_sync[PTR_WIDTH-3:0]});

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= '0;
            wgray <= '0;
            wfull <= 1'b0;
        end else begin
            wbin  <= wbin_next;
            wgray <= wgray_next;
            wfull <= wfull_val;
        end
    end

endmodule

module read_pointer #(
    parameter int ADDR_WIDTH = 6,
    parameter int PTR_WIDTH = ADDR_WIDTH + 1
)(
    input  logic                 rclk,
    input  logic                 rrst_n,
    input  logic                 rinc,
    input  logic [PTR_WIDTH-1:0]  wgray_sync,
    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [PTR_WIDTH-1:0]  rgray,
    output logic                 rempty
    );

    logic [PTR_WIDTH-1:0] rbin;
    logic [PTR_WIDTH-1:0] rbin_next;
    logic [PTR_WIDTH-1:0] rgray_next;

    assign rbin_next  = rbin + (rinc && !rempty);
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;
    
    // 内存读取地址
    assign raddr = rbin[ADDR_WIDTH-1:0];

    // 空标志判断逻辑：读格雷码等于同步过来的写格雷码
    wire rempty_val = (rgray_next == wgray_sync);

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin   <= '0;
            rgray  <= '0;
            rempty <= 1'b1; // 复位时为空
        end else begin
            rbin   <= rbin_next;
            rgray  <= rgray_next;
            rempty <= rempty_val;
        end
    end

endmodule

module sync_gray #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
    );

    logic [WIDTH-1:0] stage1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1 <= '0;
            dout <= '0;
        end else begin
            stage1 <= din;
            dout <= stage1;
        end
    end

endmodule

module dual_port_ram #(
    parameter int WIDTH = 16,
    parameter int DEPTH = 64,
    localparam int ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic                 wclk,
    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic                 winc,
    input  logic [WIDTH-1:0]      wdata,
    input  logic                 rclk,
    input  logic [ADDR_WIDTH-1:0] raddr,
    input  logic                 rinc, // 虽然异步读，rinc 可保留用于逻辑门控或保持
    output logic [WIDTH-1:0]      rdata
    );

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge wclk) begin
        if (winc) begin
            mem[waddr] <= wdata;
        end
    end

    // 修改：改为异步读（组合逻辑输出）
    assign rdata = mem[raddr];

endmodule

