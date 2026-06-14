/** 接口定义
 * 
 * async_fifo_if.sv
 * 
 * 
 * 
 * 
 */
interface async_fifo_if #(parameter int DATA_WIDTH = 16) (
    input logic wclk,
    input logic wrst_n,
    input logic rclk,
    input logic rrst_n
);
    /*===dut的IO口===*/
    logic                    winc;
    logic [DATA_WIDTH-1:0]   wdata;
    logic                    wfull;
    logic                    walmost_full;

    logic                    rinc;
    logic [DATA_WIDTH-1:0]   rdata;
    logic                    rempty;
    logic                    ralmost_empty;

    // 注册到Clock Block里面
    // 写时钟域 Clocking Block
    clocking w_cb @(posedge wclk);
        default input #1ns output #1ns;
        output winc;
        output wdata;
        input  wfull;
        input  walmost_full;
    endclocking

    // 读时钟域 Clocking Block
    clocking r_cb @(posedge rclk);
        default input #1ns output #1ns;
        output rinc;
        input  rdata;
        input  rempty;
        input  ralmost_empty;
    endclocking

/*===============================================*/

    /*===monitor的时钟===*/
    // 这里对monitor而言就都是input了
    // 写 Monitor Clocking Block
    clocking wmon_cb @(posedge wclk);
        default input #1ns;
        input winc;
        input wdata;
        input wfull;
        input walmost_full;
    endclocking

    // 读 Monitor Clocking Block
    clocking rmon_cb @(posedge rclk);
        default input #1ns;
        input rinc;
        input rdata;
        input rempty;
        input ralmost_empty;
    endclocking

endinterface