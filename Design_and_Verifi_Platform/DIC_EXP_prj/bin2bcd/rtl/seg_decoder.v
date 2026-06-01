module seg_decoder (
    input  wire [3:0]    bcd_code,
    output reg  [6:0]    sig
);
/*======================== Parameter and Internal Signal =========================*/

// output led (共阳极信号：0表示亮，1表示灭)
localparam  V0  = 7'h40; // 7'b100_0000
localparam  V1  = 7'h79; // 7'b111_1001
localparam  V2  = 7'h24; // 7'b010_0100
localparam  V3  = 7'h30; // 7'b011_0000
localparam  V4  = 7'h19; // 7'b001_1001
localparam  V5  = 7'h12; // 7'b001_0010
localparam  V6  = 7'h02; // 7'b000_0010
localparam  V7  = 7'h78; // 7'b111_1000
localparam  V8  = 7'h00; // 7'b000_0000
localparam  V9  = 7'h10; // 7'b001_0000

// state
localparam  BCD0  = 4'h0;
localparam  BCD1  = 4'h1;
localparam  BCD2  = 4'h2;
localparam  BCD3  = 4'h3;
localparam  BCD4  = 4'h4;
localparam  BCD5  = 4'h5;
localparam  BCD6  = 4'h6;
localparam  BCD7  = 4'h7;
localparam  BCD8  = 4'h8;
localparam  BCD9  = 4'h9;

/*================================== Main Code ===================================*/

always @(*) begin
    case (bcd_code)
        BCD0 : sig = V0;
        BCD1 : sig = V1;
        BCD2 : sig = V2;
        BCD3 : sig = V3;
        BCD4 : sig = V4;
        BCD5 : sig = V5;
        BCD6 : sig = V6;
        BCD7 : sig = V7;
        BCD8 : sig = V8;
        BCD9 : sig = V9;
        // 如果输入不是0-9，默认全灭（共阳极设为全1）
        default: sig = 7'h7f; 
    endcase
end

endmodule