`timescale 1ns/1ps

module dual_port_ram #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4
) (
    input  logic                    wclk,   // 写时钟
    input  logic                    w_en,   // 写使能
    input  logic [ADDR_WIDTH-1:0]   waddr,  // 写地址
    input  logic [DATA_WIDTH-1:0]   wdata,  // 写数据
    input  logic [ADDR_WIDTH-1:0]   raddr,  // 读地址
    output logic [DATA_WIDTH-1:0]   rdata   // 读数据（组合逻辑输出，支持FWFT）
);


/*======================== Parameter and Internal Signal =========================*/

/*===param===*/
localparam int DEPTH = 1 << ADDR_WIDTH;

/*===sig===*/
logic [DATA_WIDTH-1:0] mem [DEPTH];


/*================================== Main Code ===================================*/

/*===w===*/
always_ff @(posedge wclk) begin
    if (w_en) begin
        mem[waddr] <= wdata;
    end
end

/*===r===*/
assign rdata = mem[raddr];


/*==================================SVA==================================*/

/* 断言1-2：确定性断言
 * 
 * 使用写时钟域采样
 * 写使能写地址写数据都不能是一个不确定信号
 * 
 */
property p_wen_no_x;
    @(posedge wclk) !$isunknown(w_en);
endproperty
a_wen_no_x: assert property (p_wen_no_x);

property p_wdata_waddr_no_x;
    @(posedge wclk) w_en |-> (!$isunknown(waddr) && !$isunknown(wdata));
endproperty
a_wdata_waddr_no_x: assert property (p_wdata_waddr_no_x);

/* 断言3：功能性断言
 * 
 * 在写入数据后，下一周期时检查写入数据是否正确
 * 
 */
property p_write_check;
    logic [ADDR_WIDTH-1:0] addr_held;
    logic [DATA_WIDTH-1:0] data_held;
    @(posedge wclk) 
    (w_en, addr_held = waddr, data_held = wdata) |=> (mem[addr_held] == data_held);
endproperty
a_write_check: assert property (p_write_check);

endmodule