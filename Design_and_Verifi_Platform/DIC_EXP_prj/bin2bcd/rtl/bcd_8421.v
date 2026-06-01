module bcd_8421 #(
    parameter DATA_WIDTH  = 20,          // 输入二进制位宽
    parameter DIGIT_WIDTH = 6            // 输出十进制位数
)(
    input   wire                        sys_clk   , // 系统时钟
    input   wire                        sys_rst_n , // 复位信号
    input   wire [DATA_WIDTH-1:0]       data      , // 输入待转换数据

    // 输出总位宽为：位数 * 4
    output  reg  [DIGIT_WIDTH*4-1:0]    bcd_out
);

// 计算移位寄存器的总位宽：输入位宽 + BCD结果位宽
localparam TOTAL_WIDTH = DATA_WIDTH + (DIGIT_WIDTH * 4);

// 计算计数器的位宽（需要能容纳 DATA_WIDTH + 1）
localparam CNT_WIDTH = $clog2(DATA_WIDTH + 2);

// reg define
reg [CNT_WIDTH-1:0]   cnt_shift;   // 移位判断计数器
reg [TOTAL_WIDTH-1:0] data_shift;  // 移位判断数据寄存器
reg                   shift_flag;  // 移位判断标志信号：0-调整, 1-移位

// cnt_shift: 计数范围 0 到 DATA_WIDTH + 1
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        cnt_shift <= {CNT_WIDTH{1'b0}};
    else if ((cnt_shift == DATA_WIDTH + 1) && (shift_flag == 1'b1))
        cnt_shift <= {CNT_WIDTH{1'b0}};
    else if (shift_flag == 1'b1)
        cnt_shift <= cnt_shift + 1'b1;
end

// data_shift：核心逻辑
integer i;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        data_shift <= {TOTAL_WIDTH{1'b0}};
    else if (cnt_shift == 0)
        // 初始状态：高位清零，低位放入待转换数据
        data_shift <= {{ (DIGIT_WIDTH*4){1'b0} }, data};
    else if ((cnt_shift <= DATA_WIDTH) && (shift_flag == 1'b0)) begin
        // 调整阶段：遍历每一个 BCD 单元 (4位)
        // 如果该单元数值 > 4，则加 3
        for (i = 0; i < DIGIT_WIDTH; i = i + 1) begin
            if (data_shift[DATA_WIDTH + i*4 +: 4] > 4)
                data_shift[DATA_WIDTH + i*4 +: 4] <= data_shift[DATA_WIDTH + i*4 +: 4] + 2'd3;
            else
                data_shift[DATA_WIDTH + i*4 +: 4] <= data_shift[DATA_WIDTH + i*4 +: 4];
        end
    end
    else if ((cnt_shift <= DATA_WIDTH) && (shift_flag == 1'b1)) begin
        // 移位阶段：整体左移一位
        data_shift <= data_shift << 1;
    end
end

// shift_flag：控制逻辑先后顺序
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        shift_flag <= 1'b0;
    else
        shift_flag <= ~shift_flag;
end

// 结果输出赋值
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0)
        bcd_out <= {(DIGIT_WIDTH*4){1'b0}};
    else if (cnt_shift == DATA_WIDTH + 1)
        bcd_out <= data_shift[TOTAL_WIDTH-1 : DATA_WIDTH];
end

endmodule