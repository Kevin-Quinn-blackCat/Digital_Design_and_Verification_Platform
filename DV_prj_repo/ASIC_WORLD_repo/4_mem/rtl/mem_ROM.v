/**
 * File         : mem_ROM.v
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. $readmemh("file_name",mem_array,start_addr,stop_addr);
 * 				2. $readmemb("file_name",mem_array,start_addr,stop_addr);
 *				3. start_addr and stop_addr are optional.
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-05-14    kq        v0.0        Created
 * 2026-05-14    kq        v1.0        Complete logic
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module mem_ROM #(
	parameter MODE = 1
)(
	input  wire       sys_clk,
	input  wire       r_en,
	input  wire [3:0] addr,
	output reg  [7:0] dout
);

/*======================== Parameter and Internal Signal =========================*/

/*===Paramter===*/

/*=== Signal ===*/
reg [7:0] mem [0:15];

/*================================== Main Code ===================================*/
/*===init_mem===*/
initial begin
	case (MODE)
		1 : $readmemh("../../rtl/datalist_fit.txt", mem);
		2 : $readmemh("../../rtl/datalist_long.txt", mem);
		3 : $readmemh("../../rtl/datalist_short.txt", mem);
		4 : $readmemh("../../rtl/datalist_sin.txt", mem);
		5 : $readmemh("../../rtl/datalist_cpu.txt", mem);
		default: $readmemh("../../rtl/datalist_fit.txt", mem);
	endcase
end

/*================================ Instantiation =================================*/

always @(posedge sys_clk) begin
    if (r_en) begin
        dout <= mem[addr];
    end
end


endmodule