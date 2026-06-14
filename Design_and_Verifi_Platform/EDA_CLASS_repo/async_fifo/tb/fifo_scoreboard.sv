// 声明uvm_analysis_imp 对应的回调函数名后缀
// 本来是都叫write()的，但是我们有两个Monitor都要发给Scoreboard，用同一个会冲突
// 现在定义两个带后缀的端口类型，对应的回调函数将变为 write_write() 和 write_read()

`uvm_analysis_imp_decl(_write)  // 生成一个名为 uvm_analysis_imp_write 的类，固定调用 write_write()
`uvm_analysis_imp_decl(_read)   // 生成一个名为 uvm_analysis_imp_read 的类，固定调用 write_read()


/** 计分板类
 * 
 * fifo_scoreboard.sv
 * 
 * 继承uvm_scoreboard，监听ap端口的广播
 * 
 */
class fifo_scoreboard #(parameter int DATA_WIDTH = 16) extends uvm_scoreboard;

    // 注册工厂函数
    `uvm_component_param_utils(fifo_scoreboard#(DATA_WIDTH))

    // 声明两个不同的端口，后缀上面用宏定义过了
    // 在env中进行匹配连接这些端口：write_imp 连接 Write Monitor，read_imp 连接 Read Monitor
    // 这里预留两个端口名为：
    uvm_analysis_imp_write #(fifo_seq_item#(DATA_WIDTH), fifo_scoreboard#(DATA_WIDTH)) write_imp;
    uvm_analysis_imp_read  #(fifo_seq_item#(DATA_WIDTH), fifo_scoreboard#(DATA_WIDTH)) read_imp;

    // 基准模型：一个相同大小的队列
    bit [DATA_WIDTH-1:0] expected_queue[$];
    int match_count = 0;
    int error_count = 0;

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
        // 实例化这些端口，后续在env中对应地连上就行
        write_imp = new("write_imp", this);
        read_imp  = new("read_imp", this);
    endfunction

    // 当Write Monitor调用ap.write(item)时自动触发这个回调函数
    function void write_write(fifo_seq_item#(DATA_WIDTH) item);
        // 在基准模型的背后压入一个刚刚写入的数据
        expected_queue.push_back(item.data);
        // 使用UVM_HIGH默认不显示这条调试消息
        `uvm_info("SCB_WR", $sformatf("Stored expected data: 'h%0h. Queue Size: %0d", item.data, expected_queue.size()), UVM_HIGH)
    endfunction

    // 当Read Monitor调用ap.write(item)时会自动触发这个回调函数
    function void write_read(fifo_seq_item#(DATA_WIDTH) item);

        // 中间变量
        bit [DATA_WIDTH-1:0] expected_data;

        // 如果回调了此函数，但是基准模型却是空的，说明读空了-报错
        if(expected_queue.size() == 0) begin
            `uvm_error("SCB_RD_ERR", $sformatf("Read action occurred, but expected queue is EMPTY! Read Data: 'h%0h", item.data))
            error_count++;
            return;
        end

        // 否则将基准模型的前端弹出一个数据
        expected_data = expected_queue.pop_front();

        // 如果二者相等（使用===意味着使用4值比较）
        if(item.data === expected_data) begin
            // 匹配则报告
            `uvm_info("SCB_MATCH", $sformatf("SUCCESS! Read: 'h%0h, Expected: 'h%0h", item.data, expected_data), UVM_LOW)
            match_count++;
        end else begin
            // 不匹配则说明设计出错
            `uvm_error("SCB_MISMATCH", $sformatf("MISMATCH! Read: 'h%0h, Expected: 'h%0h", item.data, expected_data))
            error_count++;
        end
    endfunction

    // 结束函数
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        // 仿真结束了，队列里还有数据，这是否是有意为之取决于测试用例，但是报告一下
        if(expected_queue.size() != 0) begin
            `uvm_info("SCB_CHECK", $sformatf("Simulation finished with %0d items remaining in expected queue!", expected_queue.size()), UVM_LOW)
        end

        // 最终结果打印
        `uvm_info("SCB_STATUS", $sformatf("Final Results -> Matches: %0d, Errors: %0d", match_count, error_count), UVM_LOW)
    endfunction
endclass