`timescale 1ns/1ns
/**
 * File         : mem_ROM_tb.v
 * Author list  : Kevin_Quinn
 * Type         : Testbench
 * tool         : Modelsim
 * Description  : 
 * 				1. genvar是用于 generate 循环的变量类型，只在编译/综合阶段存在
 * 				2. 使用generate批量生成实例
 * 				3. begin : gen_mem_rom: 在 generate 循环中，begin 后面必须跟着
 *					一个实例名称（label）。工具会自动生成类似
 *					gen_mem_rom[0].mem_ROM_inst, gen_mem_rom[1].mem_ROM_inst
 *					这样的层次化路径。
 * 				4. 参数动态化: .MODE(i + 1) 允许你根据循环索引动态地向每个实例传递不同的参数
 * 				5. 这里 5 个实例同时运行，它们的输出 dout 不能连到同一个变量上，使用数组适合循环生成
 * 				6. 对于监控有延迟的信号，可以将驱动打拍，使得响应和驱动同步，然后用组合逻辑监控延迟的驱动信号即可
 * 				6. 仿真竞争: 在if (monitor_en)处实例化了5个always来监控各个实例，它们的驱动同时是addr_reg
 *					而其语句是瞬发的打印语句，这会产生竞争，具体打印的值和打印顺序取决于运行时仿真软件调度顺序
 *					解决方法是使用strobe代替display，$strobe 会在当前仿真时间槽（time-slot）的所有非阻塞赋值
 *					完成后才执行，能确保拿到最新的 dout 值。并且调度顺序确定。
 * 
 * Revision History:
 * -----------------------------------------------------------------------------
 * Date          By        Version     Description
 * 2026-15-14    kq        v0.0        Created
 * 2026-15-14    kq        v1.0        Complete Date read test
 * 2026-15-14    kq        v2.0        Complete CPU test
 * -----------------------------------------------------------------------------
 */


module mem_ROM_tb;


/*======================== Parameter and Internal Signal =========================*/

/*===Parameter===*/

/*===Signal===*/
reg  			sys_clk;
reg  			r_en;
reg  [3:0] 		addr;
wire [7:0] 		dout 		[0:4];

reg  [3:0] 		addr_reg;
reg  			monitor_en;

/*================================== Instantiation ===============================*/

/*===DUT===*/
genvar i;
generate
    for (i = 0; i < 5; i = i + 1) begin : gen_mem_rom
        mem_ROM #(
            .MODE(i + 1)
        ) mem_ROM_inst (
            .sys_clk (sys_clk),
            .r_en    (r_en),
            .addr    (addr),
            .dout    (dout[i])
        );
    end
endgenerate

/*==================================== initial ====================================*/

/*===clk_gen===*/
always #10 sys_clk = ~sys_clk;

/*===init_sig===*/
event init_sig;

initial begin

	// sig
	sys_clk = 1'b1;
	monitor_en <= 1'b1;

	// rst

	#40
	$display("+------------------------------------------------------------------------------+");
	$display("|                         =====Simulation Start=====                           |");
	$display("+------------------------------------------------------------------------------+");
	-> init_sig;
end

/*==================================== event ======================================*/

/*===finish===*/
event simulation_finish;
initial begin
	forever begin
		@(simulation_finish);
		$display("+------------------------------------------------------------------------------+");
		$display("|                        =====Simulation Finish=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$finish;
	end
end

/*===stop===*/
event simulation_stop;
initial begin
	forever begin
		@(simulation_stop);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Stop=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$stop;
	end
end

/*===next===*/
event simulation_next;
initial begin : SIM_NUM
	integer sim_num;
	sim_num <= 1;
	forever begin 
		@(simulation_next);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Next=====                           |");
		$display("|                         =====Simulation No.%0d=====                          |", sim_num);
		$display("+------------------------------------------------------------------------------+");
		sim_num <= sim_num + 1;
	end
end

/*==================================== task =======================================*/

task addr_refresh;
	begin : ADDR_ADD
		integer i;
		for (i = 0; i < 16; i=i+1) begin
			@(posedge sys_clk);
			addr <= i;
		end
	end
endtask

task read_cpu;
	input [3:0] _addr;
	input integer burst;
	begin : READ_CPU
		integer i;
		for (i = 0; i < burst; i=i+1) begin
			@(posedge sys_clk);
			addr <= _addr + i;
		end
	end
endtask

task encode_cpu;
	input  [7:0]  code;
	begin
		case (code[7:4])
			4'h1 : $display("Executing ADD with operand %h", code[3:0]);
			4'h2 : $display("Executing SUB with operand %h", code[3:0]);
			4'hF : $display("Executing HALT with operand %h", code[3:0]);
			default: $display("CPU EXE ERROR!!!");
		endcase
	end
endtask

/*================================== Main Code ===================================*/

/*===main_simulation_logic===*/
initial begin
	/*===========*/
	@(init_sig);
	/*===========*/

	r_en <= 1'b1;
	addr_refresh();
	@(posedge sys_clk);
	@(posedge sys_clk);
	r_en <= 1'b0;

	/*===========*/
	-> simulation_next;
	/*===========*/

	monitor_en <= 1'b0;
	r_en <= 1'b1;
	read_cpu(4'ha, 3);
	@(posedge sys_clk);
	@(posedge sys_clk);

	/*===========*/
	-> simulation_stop;
end

/*=========================== Monitoring & Debug Logic ===========================*/
always @(posedge sys_clk) begin
	addr_reg <= addr;
end

genvar j;
generate
    for (j = 0; j < 5; j = j + 1) begin : gen_print_loop
        always @(addr_reg) begin
			if (monitor_en) begin
				$strobe("@%t ns: ROM MODE %1d addr %h pop data: %h", $time, j, addr_reg, dout[j]);
			end
        end
    end
endgenerate

always @(addr_reg) begin
	if (!monitor_en) begin
		encode_cpu(dout[4]);
	end
end

endmodule