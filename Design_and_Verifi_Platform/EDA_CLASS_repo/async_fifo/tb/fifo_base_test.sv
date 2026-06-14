/** 基础写序列
 * 
 * 继承uvm_sequence（不是uvm_sequencer）
 * 属于工具类，不是组件的一种
 * 所以后面的工厂函数注册宏叫uvm_object_utils而不是uvm_component_param_utils
 * 定义如何去写
 */
class fifo_write_seq extends uvm_sequence#(fifo_seq_item#());
    // Sequence 是 Object，不是 Component，Sequencer才是
    `uvm_object_utils(fifo_write_seq)

    // 成员，控制循环次数，修改它来决定写多少个数据
    int limit = 10;

    // 构造函数
    function new(string name = "fifo_write_seq"); super.new(name); endfunction

    // sequence启动时会自动回调这个body()
    task body();
        repeat(limit) begin
            // `uvm_do_with 是一个复合宏，它包含了以下动作：
            // 创建一个叫req对象(用了工厂函数create，实际为fifo_seq_item)
            // 等待Sequencer允许发送
            // 随机化req，并加上方向约束
            // 将req发送给Driver
            // 等待Driver完成处理（阻塞直到Driver执行item_done方法）
            `uvm_do_with(req, {req.dir == WRITE;})
        end
    endtask
endclass

/* 基础读序列
 * 同理
 */
class fifo_read_seq extends uvm_sequence#(fifo_seq_item#());

    `uvm_object_utils(fifo_read_seq)

    int limit = 10;

    function new(string name = "fifo_read_seq"); super.new(name); endfunction


    task body();
        repeat(limit) begin
            `uvm_do_with(req, {req.dir == READ;})
        end
    endtask
endclass


/** 基础测试用例类
 * 
 * 继承uvm_test，负责实例化 Env，进而实例化所有组件
 * 作为所有UVM层次结构的根节点
 * 
 */
class fifo_base_test extends uvm_test;

    // 将此类也注册到工厂，这样可以在命令行通过 +UVM_TESTNAME=fifo_base_test 来启动
    `uvm_component_utils(fifo_base_test)

    // 一个env成员，就是每一个测试用例都包含一套完整组件的意思
    fifo_env env;

    // 构造函数
    function new(string name = "fifo_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // 实例化成员
        env = fifo_env::type_id::create("env", this);
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);
        // 基类不做具体动作，由派生测试用例实现控制
    endtask
endclass