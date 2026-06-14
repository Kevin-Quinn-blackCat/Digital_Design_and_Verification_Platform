/** 测试用例：空满标志测试
 * 继承自fifo_base_test
 * 
 * 空满标志位是否能按预期拉高？
 * 
 */
class fifo_full_empty_test extends fifo_base_test;
    // 注册到工厂
    `uvm_component_utils(fifo_full_empty_test)
    // 获取接口
    virtual async_fifo_if#() vif;
    // 构造函数
    function new(string name = "fifo_full_empty_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#())::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Could not get vif")
    endfunction
    // 重写run_phase
    virtual task run_phase(uvm_phase phase);

        // 声明与实例化读写seq
        fifo_write_seq wr_seq;
        fifo_read_seq  rd_seq;
        wr_seq = fifo_write_seq::type_id::create("wr_seq");
        rd_seq = fifo_read_seq::type_id::create("rd_seq");
        // 保持仿真
        phase.raise_objection(this);

        // 写到 Full
        `uvm_info("TEST1", "Starting Write Phase: Writing until Full...", UVM_LOW)
        wr_seq.limit = 80;
        fork
            wr_seq.start(env.w_agent.sqr);
        join_none  // 交付阻塞权限给wfull

        // 监测 wfull 信号
        @(posedge vif.wfull);
        `uvm_info("TEST1", "WFULL detected successfully!", UVM_LOW)
        repeat(5) @(posedge vif.wclk); // 冗余逻辑，用于分割两次不同的测试
        
        // 停止当前可能还未执行完的写序列
        disable fork;

        // 2. 读到 Empty
        `uvm_info("TEST1", "Starting Read Phase: Reading until Empty...", UVM_LOW)
        rd_seq.limit = 80;
        fork
            rd_seq.start(env.r_agent.sqr);
        join_none

        // 监测 rempty 信号
        @(posedge vif.rempty);
        `uvm_info("TEST1", "REMPTY detected successfully!", UVM_LOW)
        repeat(5) @(posedge vif.rclk);

        disable fork;

        // 结束
        phase.drop_objection(this);
    endtask
endclass