module dual_port_ram #(
    parameter int WIDTH = 16,
    parameter int DEPTH = 64
)(
    input  logic                    wclk,
    input  logic                    winc,
    input  logic [$clog2(DEPTH)-1:0] waddr,
    input  logic [WIDTH-1:0]        wdata,

    input  logic [$clog2(DEPTH)-1:0] raddr,
    output logic [WIDTH-1:0]        rdata
);

    // 存储阵列
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // 同步写入
    always_ff @(posedge wclk) begin
        if (winc) begin
            mem[waddr] <= wdata;
        end
    end

    // 异步读取（组合逻辑），以便顶层通过寄存器灵活控制时延
    assign rdata = mem[raddr];

endmodule