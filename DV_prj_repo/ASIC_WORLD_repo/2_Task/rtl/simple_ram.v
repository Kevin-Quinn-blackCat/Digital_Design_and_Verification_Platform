/**
 * File         : simple_ram.v
 * Author list  : KIMQUIN
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				None
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-13    kq        v0.0        Created
 * 2026-05-13    kq        v1.0        Copy exp code
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module simple_ram (
    input wire clk,
    input wire wr_en,
    input wire [7:0] addr,
    input wire [7:0] data_in,
    output reg [7:0] data_out
);
    reg [7:0] mem [0:255];

    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= data_in;
        data_out <= mem[addr];
    end
endmodule