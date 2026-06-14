// 定义 Sequencer，因为seq_item的逻辑很简单，这里随便用typedef定义一个
// Sequencer负责管理Sequence并将其发送给Driver
typedef uvm_sequencer#(fifo_seq_item#()) fifo_sequencer;

/** 写代理类
 * 
 * 继承uvm_agent
 * 
 * 将drv的数据输入连接进sqr通道
 */
class fifo_write_agent extends uvm_agent;
    `uvm_component_utils(fifo_write_agent)
    fifo_sequencer        sqr;  // 刚刚定义的Sequencer，来自uvm_sequencer
    fifo_write_driver#()  drv;  // 写驱动类
    fifo_write_monitor#() mon;  // 写监测类

    // 构造函数
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    // 构建函数
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // 用工厂函数快速实例化对应的成员
        sqr = fifo_sequencer::type_id::create("sqr", this);
        drv = fifo_write_driver#()::type_id::create("drv", this);
        mon = fifo_write_monitor#()::type_id::create("mon", this);
    endfunction


    // 连接函数
    function void connect_phase(uvm_phase phase);
        // 将Driver数据输入连到Sequencer数据输出上
        // Driver里的seq_item_port.get_next_item()方法就来源于这里
        // 而sqr用fifo_seq_item例化，逻辑闭环
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

/** 读代理类
 * 
 * 继承uvm_agent
 * 
 * 将drv的数据输入连接进sqr通道
 */
class fifo_read_agent extends uvm_agent;
    // 注册工厂函数
    `uvm_component_utils(fifo_read_agent)

    // 成员
    fifo_sequencer      sqr;
    fifo_read_driver#()  drv;
    fifo_read_monitor#() mon;

    // 构造函数
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    // 建立函数
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // 调用对应工厂函数实例化
        sqr = fifo_sequencer::type_id::create("sqr", this);
        drv = fifo_read_driver#()::type_id::create("drv", this);
        mon = fifo_read_monitor#()::type_id::create("mon", this);
    endfunction

    // 连接函数
    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass


/** 环境类
 * 
 * 继承uvm_env，作为顶层容器
 * 
 * 把所有Agent，Scoreboard，Coverage全部实例化
 * 并按预期设计连接起来
 */
class fifo_env extends uvm_env;

    // 注册工厂函数
    `uvm_component_utils(fifo_env)
    
    // 成员
    fifo_write_agent      w_agent;
    fifo_read_agent       r_agent;
    fifo_scoreboard#()    scb;
    fifo_coverage#()      cov;

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // 调用工厂函数实例化
        w_agent = fifo_write_agent::type_id::create("w_agent", this);
        r_agent = fifo_read_agent::type_id::create("r_agent", this);
        scb     = fifo_scoreboard#()::type_id::create("scb", this);
        cov     = fifo_coverage#()::type_id::create("cov", this);
    endfunction

    // 连接函数
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // 写代理内写监测的广播连接到计分板的write_imp口
        // 着将在ap.write(item)时回调write_write
        w_agent.mon.ap.connect(scb.write_imp);
        // 同理
        r_agent.mon.ap.connect(scb.read_imp);
        // 将两路监测的广播回调都接入覆盖率模块
        w_agent.mon.ap.connect(cov.analysis_export);
        r_agent.mon.ap.connect(cov.analysis_export);
    endfunction
endclass