/**
 * File         : wave_gen.v
 * Author list  : Kevin_Quinn
 * Type         : Digital Design
 * tool         : None
 * Description  : 
 * 				1. <TOP Design>
 * 				2. Cycle switching between 
 *					sine wave, triangle wave, sawtooth wave and square wave
 *				3. The button controls the state machine switching after debounce
 *				4. f_out = (freq * f_clk)/(2^FREQ_WIDTH)
 *				5. Resolution is approximately 0.0116Hz(50MHz clk)
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-16    kq        v0.0        Created
 * 2026-15-16    kq        v0.1        docs: Add Added state transition diagram
 * 2026-15-16    kq        v0.2        docs: Add description
 * 2026-15-16    kq        v0.3        feat: Add wave_FSM.v and Instantiation
 * 2026-15-16    kq        v0.4        feat: Add 
 *											DV_prj_repo\KEY_FILTER_repo\Counter_Filter\rtl\cnt_filter.v
 *											and Instantiation
 * 2026-15-16    kq        v0.6        feat: Add ROM and initial data
 * 2026-15-16    kq        v0.7        feat: state decoder
 * 2026-15-16    kq        v0.8        fix: fix start_addr spelling errors
 * 2026-15-16    kq        v0.9        feat: Introduce phase accumulator to achieve frequency control
 * 2026-15-16    kq        v1.0        feat: Complete logic
 * 2026-15-16    kq        v1.1        docs: Add description
 * -----------------------------------------------------------------------------
 */

/*===TIMING BOARD
===*/


module wave_gen #(
	parameter FILTER_STATE_NUM = 1000_000,
	parameter FREQ_WIDTH       = 32
)(
	input  wire                   	sys_clk,
	input  wire                   	sys_rst_n,
	input  wire                   	key_in,
	input  wire  [FREQ_WIDTH-1:0] 	freq,		// step
	output reg   [15:0]           	wave_out
);

/*======================== Parameter and Internal Signal =========================*/

/*===Paramter===*/
// state
localparam S_SIN   	  =	 4'h1;
localparam S_TRI   	  =	 4'h2;
localparam S_SAW  	  =	 4'h4;
localparam S_SQU 	  =	 4'h8;

/*=== Signal ===*/
wire       key_pulse;
wire [3:0] state_out;

reg  [15:0] mem_rom [0:1023];
reg  [9:0]  start_addr;

reg  [FREQ_WIDTH-1:0] phase_acc; 
wire [7:0]            rom_index; // 每个波形 256 个点，需要 8 位寻址

/*================================== Main Code ===================================*/

/*===initial ROM===*/
initial begin
	$readmemh("../../py/wave_data.txt", mem_rom);
end

/*===decoder===*/
always @(posedge sys_clk) begin
	if (!sys_rst_n) begin
		start_addr <= 10'd0;
	end
	else begin
		case (state_out)
			S_SIN : start_addr <= 10'd0;
			S_TRI : start_addr <= 10'd256;
			S_SAW : start_addr <= 10'd512;
			S_SQU : start_addr <= 10'd768;
			default: start_addr <= 10'd0;
		endcase
	end
end

/*===freq_cnt===*/
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        phase_acc <= {FREQ_WIDTH{1'b0}};
    end
    else begin
        // Accumulate the frequency word once every clock cycle
        // The larger freq is, the faster phase_acc overflows and the higher the frequency.
        phase_acc <= phase_acc + freq;
    end
end

// Take the high 8 bits of the phase accumulator as the search index of the current waveform
assign rom_index = phase_acc[FREQ_WIDTH-1 : FREQ_WIDTH-8];


/*===wave_out===*/
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        wave_out <= 16'd0;
    end
    else begin
        wave_out <= mem_rom[start_addr + rom_index];
    end
end
/*================================ Instantiation =================================*/
wave_FSM  wave_FSM_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .pulse_in(key_pulse),
    .state_out(state_out)
);

cnt_filter # (
    .CNT_STATE_NUM(FILTER_STATE_NUM)
)
cnt_filter_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .din(key_in),
    .dout(key_pulse)
);

endmodule


