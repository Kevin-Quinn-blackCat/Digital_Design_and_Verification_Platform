module sync_gray 
    import fifo_cfg_pkg::*;
#(
    parameter int        WIDTH        = 4,
    parameter int        STAGES       = 2, // 同步级数
    parameter rst_type_e RST_TYPE     = ASYNC_RST,
    parameter rst_pol_e  RST_POLARITY = ACTIVE_LOW
)(
    input  logic             clk,
    input  logic             rst, // 统一命名为 rst，内部根据极性处理
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

    // 内部同步链寄存器
    logic [WIDTH-1:0] sync_reg [STAGES-1:0];

    // 复位信号内部极性处理
    logic rst_cond;
    assign rst_cond = (RST_POLARITY == ACTIVE_HIGH) ? rst : !rst;

    // 根据不同的复位类型生成不同的时序逻辑
    generate
        if (RST_TYPE == ASYNC_RST || RST_TYPE == ASYNC_SYNC_RELEASE) begin : g_async_rst
            always_ff @(posedge clk or posedge rst_cond) begin
                if (rst_cond) begin
                    for (int i = 0; i < STAGES; i++) begin
                        sync_reg[i] <= '0;
                    end
                end else begin
                    sync_reg[0] <= din;
                    for (int i = 1; i < STAGES; i++) begin
                        sync_reg[i] <= sync_reg[i-1];
                    end
                end
            end
        end else begin : g_sync_rst // SYNC_RST
            always_ff @(posedge clk) begin
                if (rst_cond) begin
                    for (int i = 0; i < STAGES; i++) begin
                        sync_reg[i] <= '0;
                    end
                end else begin
                    sync_reg[0] <= din;
                    for (int i = 1; i < STAGES; i++) begin
                        sync_reg[i] <= sync_reg[i-1];
                    end
                end
            end
        end
    endgenerate

    assign dout = sync_reg[STAGES-1];

endmodule