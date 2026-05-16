/**
 * File         : SequenceSearcher.v/sv
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 *   [命名块 (Named Blocks) 实用笔记]
 *   1. 作用域隔离：只有命名的 begin 块才能声明局部变量（如 integer i），防止变量名污染全局。
 *   2. 流程控制：使用 'disable block_name' 可实现类似 C 语言的 'break'，跳出当前命名块。
 *   3. 可综合性：在 for 循环中使用 disable 会被综合器映射为“优先级编码逻辑 (Priority Encoder)”。
 *   4. 赋值陷阱：在包含 disable 的块中使用非阻塞赋值 (<=) 时需注意，disable 会立即停止代码执行，
 *      但非阻塞赋值仅在当前时刻最后一次生效。若搜索成功时多次赋值，遵循“最后一次赋值有效”原则。
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-14    kq        v0.0        Created
 * 2026-05-14    kq        v0.1        copy exp
 * 2026-05-14    kq        v1.0        complete logic
 * 2026-05-14    kq        v1.1        add Description
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module SequenceSearcher (
    input wire clk,
    input wire start,
    input wire [7:0] target,
    output reg [3:0] found_index,
    output reg found_flag
);

    reg [7:0] memory [0:15];

    // 初始化 ROM 
    initial begin : INIT_BLOCK
		integer i;
        for (i = 0; i < 16; i = i + 1) begin
			memory[i] <= {i[3:0],4'h0};
		end
		found_flag <= 1'b0;
		found_index <= 8'h00;
    end

    always @(posedge clk) begin
        if (start) begin : SEARCH_LOGIC
            // 1. 在这里声明局部变量 i
            integer i;
            // 2. 初始化输出
            found_flag <= 1'b0;
            
            // 3. 编写 for 循环
			for (i = 0; i < 16; i = i + 1) begin
				if (memory[i] == target) begin
					found_index <= i[3:0];
					found_flag <= 1'b1;
					// 4. 使用 disable 退出命名块
					disable SEARCH_LOGIC;
					// disable 会立即杀掉这个块
					// 但是found_index和found_flag是非阻塞，因此会延迟一个周期生效
				end
			end
            
        end
    end

endmodule
