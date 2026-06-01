`timescale 1ns/1ns

module top4_tb;

    // --- 参数配置 ---
    localparam DATA_WIDTH  = 16; // 16位二进制
    localparam DIGIT_WIDTH = 4;  // 4位十进制 (显示 0000-9999)

    // --- 信号定义 ---
    reg                     sys_clk;
    reg                     sys_rst_n;
    reg  [DATA_WIDTH-1:0]   data;
    wire [DIGIT_WIDTH*7-1:0] sig_out;

    // --- 模块例化 ---
    bin2sig # (
        .DATA_WIDTH(DATA_WIDTH),
        .DIGIT_WIDTH(DIGIT_WIDTH),
        .LEADING_ZERO_BLANKING(1),
        .SHOW_SIGN(0)
    )bin2sig_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data(data),
        .sig_out(sig_out)
    );



    // --- 时钟生成 (50MHz) ---
    always #10 sys_clk = ~sys_clk;

    // --- 驱动任务 ---
    task send_data(input [DATA_WIDTH-1:0] val);
        begin
            data <= val;
            // 等待转换完成：(位宽 + 2) * 2 个时钟周期
            repeat ((DATA_WIDTH + 2) * 2) @(posedge sys_clk);
            #100; // 额外停顿，方便在波形上看清楚
        end
    endtask

    // --- 主仿真流程 ---
    initial begin
        // 系统初始化
        sys_clk   = 1'b1;
        sys_rst_n = 1'b0;
        data      = 0;

        // 复位释放
        #100;
        sys_rst_n = 1'b1;
        #100;

        // 测试几个典型值
        send_data(16'd0);       // 预期：sig_out 显示 4个0的编码
        send_data(16'd0);
        send_data(16'd1234);    // 预期：sig_out[27:21]=1, [20:14]=2, [13:7]=3, [6:0]=4 的编码
        send_data(16'd5678);    // 预期：sig_out 分别显示 5,6,7,8
        send_data(16'd9999);    // 预期：最大值边界
        send_data(16'd0100);
        send_data(16'd0010);
        send_data(16'd1000);

        #500;
        $display("Simulation Task Finished.");
        $stop;
    end


endmodule