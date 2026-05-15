`timescale 1ns/1ns

module fifo_tb;

  // Parameters
  localparam int DEPTH = 16;
  localparam int WIDTH = 8;

  // Ports
  reg wclk;
  reg wrst_n;
  reg winc;
  reg [WIDTH-1:0] wdata;
  wire wfull;
  
  reg rclk;
  reg rrst_n;
  reg rinc;
  wire [WIDTH-1:0] rdata;
  wire rempty;

  // Instantiate the Unit Under Test (UUT)
  async_fifo # (
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
  )
  async_fifo_inst (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .winc(winc),
    .wdata(wdata),
    .wfull(wfull),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .rinc(rinc),
    .rdata(rdata),
    .rempty(rempty)
  );

  // Clock generation
  // wclk: 20ns period (50MHz)
  always #10 wclk = ~wclk;
  // rclk: 6ns period (~166.7MHz) 
  always #3  rclk = ~rclk;

  // --- Test Logic ---
  
  initial begin
    // 1. Initialize signals
    wclk = 1'b1;
    rclk = 1'b1;
    wrst_n = 1'b0;
    rrst_n = 1'b0;
    winc = 1'b0;
    wdata = 0;
    rinc = 1'b0;

    // 2. Reset sequence
    #50;
    @(posedge wclk) wrst_n = 1'b1;
    @(posedge rclk) rrst_n = 1'b1;
    #20;

    // 3. Test Case: Write until Full
    $display("--- Test Case: Writing until Full ---");
    repeat (DEPTH) begin
        @(posedge wclk);
        if (!wfull) begin
            winc = 1'b1;
            wdata = $random % 256;
            $display("[WRITE] Time=%t, Data=%h", $time, wdata);
        end
    end
    @(posedge wclk);
    winc = 1'b0;
    
    // Wait for sync logic
    repeat(5) @(posedge wclk);
    if (wfull) $display("Status: FIFO is FULL as expected.");

    #100;

    // 4. Test Case: Read until Empty
    $display("--- Test Case: Reading until Empty ---");
    while (!rempty) begin
        @(posedge rclk);
        rinc = 1'b1;
        // 这里的读数据要在时钟边沿后观察
    end
    @(posedge rclk);
    rinc = 1'b0;
    
    repeat(5) @(posedge rclk);
    if (rempty) $display("Status: FIFO is EMPTY as expected.");

    #100;

    // 5. Test Case: Simultaneous Read and Write
    $display("--- Test Case: Simultaneous Read/Write ---");
    fork
        // Write thread
        repeat (30) begin
            @(posedge wclk);
            if (!wfull) begin
                winc = 1'b1;
                wdata = $random % 256;
            end else begin
                winc = 1'b0;
            end
        end
        // Read thread
        repeat (30) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1'b1;
            end else begin
                rinc = 1'b0;
            end
        end
    join
    
    winc = 1'b0;
    rinc = 1'b0;

    #200;
    $display("Simulation Finished.");
    $finish;
  end

  // Monitor Read Data
  always @(posedge rclk) begin
      if (rinc && !rempty) begin
          $display("[READ]  Time=%t, Data=%h", $time, rdata);
      end
  end

endmodule