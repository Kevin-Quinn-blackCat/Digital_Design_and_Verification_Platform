`timescale 1ns/1ns
/**
 * File         : wave_gen_tb.v
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				none
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-16    kq        v0.0        Created
 * 2026-15-16    kq        v1.0        feat
 * -----------------------------------------------------------------------------
 */


`timescale 1ns/1ns

module wave_gen_tb;

/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/
localparam  FILTER_STATE_NUM = 10;
localparam  FREQ_WIDTH       = 12; // 仿真建议 12-16
localparam  CLK_PERIOD       = 20; // 50MHz

/*===Signal===*/
reg                  sys_clk;
reg                  sys_rst_n;
reg                  key_in;
reg [FREQ_WIDTH-1:0] freq;
wire [15:0]          wave_out;

/*================================== Instantiation ===============================*/

/*===DUT===*/
wave_gen # (
    .FILTER_STATE_NUM(FILTER_STATE_NUM),
    .FREQ_WIDTH      (FREQ_WIDTH)
)
wave_gen_inst (
    .sys_clk  (sys_clk),
    .sys_rst_n(sys_rst_n),
    .key_in   (key_in),
    .freq     (freq),
    .wave_out (wave_out)
);

/*==================================== initial ====================================*/

/*===clk_gen===*/
initial sys_clk = 1'b1;
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin
    // sig
    key_in    <= 1'b1;
    freq      <= 1; // 初始频率设为 1

    // rst
    sys_rst_n <= 1'b0;
    #(CLK_PERIOD*2);
    sys_rst_n <= 1'b1;
    #(CLK_PERIOD*2);

    $display("+------------------------------------------------------------------------------+");
    $display("|                         =====Simulation Start=====                           |");
    $display("+------------------------------------------------------------------------------+");
    -> init_sig;
end

/*==================================== event ======================================*/
event simulation_finish;
initial begin
    forever begin
        @(simulation_finish);
        $display("Finish at %t", $time);
        $finish;
    end
end

event simulation_stop;
initial begin
    forever begin
        @(simulation_stop);
        $stop;
    end
end

event simulation_next;
initial begin : SIM_NUM
    integer sim_num;
    sim_num = 1;
    forever begin 
        @(simulation_next);
        $display("[Step %0d] at %t", sim_num, $time);
        sim_num = sim_num + 1;
    end
end

/*==================================== task =======================================*/
// 模拟一次按键
task key_press;
    begin
        @(posedge sys_clk);
        key_in <= 1'b0;
        repeat(FILTER_STATE_NUM * 2) @(posedge sys_clk); // 确保超过消抖时间
        key_in <= 1'b1;
        repeat(FILTER_STATE_NUM * 2) @(posedge sys_clk); // 等待消抖释放
    end
endtask

task rst1000;
    begin
        @(posedge sys_clk);
        sys_rst_n <= 1'b0;
        repeat(100) @(posedge sys_clk); // 仿真不需要 1000 那么久
        sys_rst_n <= 1'b1;
        @(posedge sys_clk);
    end
endtask

// 增加频率
task increase_frequency;
    input integer step;
    input integer times;
    integer i;
    begin
        for (i = 0; i < times; i=i+1) begin
            // 每次增加后多等一会，方便看波形周期变短
            repeat(2000) @(posedge sys_clk); 
            freq = freq + step;
            $display("Freq increased to: %d", freq);
        end
    end
endtask

task wait_N;
    input integer N;
    begin
        repeat(N) @(posedge sys_clk);
    end
endtask

/*================================== Main Code ===================================*/

initial begin
    @(init_sig);
    
    // 1. 观察初始频率（正弦波）
    -> simulation_next;
    wait_N(5000); // 12位宽下，freq=1需要4096个周期走完一个波形

    // 2. 阶梯式增加频率
    -> simulation_next;
    increase_frequency(4, 10); // 每次加4，加5次

    // 3. 切换波形：三角波
    -> simulation_next;
    $display("Switching to Triangle Wave...");
    key_press();
    wait_N(5000);

    // 4. 切换波形：锯齿波
    -> simulation_next;
    $display("Switching to Sawtooth Wave...");
    key_press();
    wait_N(5000);

    // 5. 切换波形：方波
    -> simulation_next;
    $display("Switching to Square Wave...");
    key_press();
    wait_N(5000);

    // 6. 复位测试
    -> simulation_next;
    rst1000();
    wait_N(1000);

    -> simulation_stop;
end

endmodule


