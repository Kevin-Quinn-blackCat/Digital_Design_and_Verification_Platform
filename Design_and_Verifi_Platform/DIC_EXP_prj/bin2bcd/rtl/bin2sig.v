module bin2sig #(
    parameter DATA_WIDTH  = 20,
    parameter DIGIT_WIDTH = 6,
    parameter LEADING_ZERO_BLANKING = 1, // 是否忽略高位0
    parameter SHOW_SIGN = 0              // 是否支持负号 (开启时默认启用消隐)
)(
    input   wire                        sys_clk   ,
    input   wire                        sys_rst_n ,
    input   wire [DATA_WIDTH-1:0]       data      , 

    output  wire [DIGIT_WIDTH*7-1:0]    sig_out
);

/*======================== 信号处理 =========================*/

    wire [DATA_WIDTH-1:0] abs_data;
    wire is_negative;

    generate
        if (SHOW_SIGN) begin : gen_sign_logic
            // 假设输入为补码，如果是负数，取绝对值进行BCD转换
            assign is_negative = data[DATA_WIDTH-1];
            assign abs_data    = is_negative ? (~data + 1'b1) : data;
        end else begin : gen_no_sign
            assign is_negative = 1'b0;
            assign abs_data    = data;
        end
    endgenerate

/*======================== BCD 转换 =========================*/

    wire [DIGIT_WIDTH*4-1:0] bcd_data;

    bcd_8421 #(
        .DATA_WIDTH  (DATA_WIDTH),
        .DIGIT_WIDTH (DIGIT_WIDTH)
    ) u_bcd_8421 (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .data      (abs_data),
        .bcd_out   (bcd_data)
    );

/*======================== 消隐与符号算法 =====================*/

    wire [DIGIT_WIDTH-1:0] zero_mask;      // 标记哪些位是 0
    wire [DIGIT_WIDTH-1:0] leading_zero;   // 标记哪些位是高位无意义的 0
    wire [DIGIT_WIDTH-1:0] sign_pos;       // 标记负号应该放置的位置

    genvar j;
    generate
        for (j = 0; j < DIGIT_WIDTH; j = j + 1) begin : mask_gen
            // 1. 检查当前 BCD 码是否为 0
            assign zero_mask[j] = (bcd_data[j*4 +: 4] == 4'd0);

            // 2. 计算是否为前导零
            if (j == DIGIT_WIDTH - 1) begin
                // 最高位如果是0，就是前导零
                assign leading_zero[j] = zero_mask[j];
            end else begin
                // 其他位是前导零的条件：自己是0 且 更高位全是前导零
                assign leading_zero[j] = zero_mask[j] && leading_zero[j+1];
            end

            // 3. 计算负号位置 (SHOW_SIGN 开启时有效)
            if (SHOW_SIGN) begin
                if (j == DIGIT_WIDTH - 1) begin
                    assign sign_pos[j] = 1'b0; // 最高位无法显示负号(前面没位置了)
                end else begin
                    // 负号条件：当前位是前导零，且下一位是最高有效位
                    assign sign_pos[j] = is_negative && leading_zero[j] && !leading_zero[j-1];
                end
            end else begin
                assign sign_pos[j] = 1'b0;
            end
        end
    endgenerate

/*======================== 输出赋值 =========================*/

    genvar i;
    generate
        for (i = 0; i < DIGIT_WIDTH; i = i + 1) begin : output_gen
            wire [6:0] raw_seg;

            // 例化原始段选解码器
            seg_decoder u_seg_decoder (
                .bcd_code ( bcd_data[i*4 +: 4] ), 
                .sig      ( raw_seg            )
            );

            // 根据逻辑选择最终输出
            if (LEADING_ZERO_BLANKING || SHOW_SIGN) begin : gen_output_mux
                assign sig_out[i*7 +: 7] = 
                    (i == 0) ? raw_seg : // 个位始终显示
                    (sign_pos[i]) ? 7'b011_1111 : // 显示负号 (G段亮，其余灭，共阳极)
                    (leading_zero[i]) ? 7'h7F : // 消隐 (全灭)
                    raw_seg; // 显示正常数字
            end else begin : gen_raw_output
                assign sig_out[i*7 +: 7] = raw_seg;
            end
        end
    endgenerate

endmodule