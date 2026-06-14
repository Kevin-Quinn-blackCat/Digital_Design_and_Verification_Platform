/** 测试用例：空满压力测试
 * 继承自fifo_base_test
 * 
 * 硬件是否能正确处理边界情况下非法操作？
 * 
 */
class fifo_extreme_test extends fifo_base_test;
    // 注册到工厂
    `uvm_component_utils(fifo_extreme_test)

    // 为观察fifo其他端口，也获取虚拟接口
    virtual async_fifo_if#() vif;

    // 构造函数
    function new(string name = "fifo_extreme_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // 从config_db中获取vif
        if(!uvm_config_db#(virtual async_fifo_if#())::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Could not get vif")
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);

        // 声明与实例化seq
        fifo_write_seq wr_seq;
        fifo_read_seq  rd_seq;
        wr_seq = fifo_write_seq::type_id::create("wr_seq");
        rd_seq = fifo_read_seq::type_id::create("rd_seq");

        // 保持仿真进行
        phase.raise_objection(this);

/*==================================写满保护测试==================================*/
        // 写满
        `uvm_info("TEST3", "Step 1: Write until Full...", UVM_LOW)
        wr_seq.limit = 64; // FIFO 满额
        fork
            wr_seq.start(env.w_agent.sqr);
        join_none // join_none不会阻塞，去等待wfull的posedge
        
        // 要不然等join完posedge早没了，就一直死锁在这里
        // 等待wfull信号抬高
        @(posedge vif.wfull);
        `uvm_info("TEST3", "FIFO is now FULL. Forcing 10 additional WRITES...", UVM_LOW)

        // 已经满了就没必要再继续写了，同时也是配合基准模型验证空信号的准确性
        disable fork;

        // 强行再写10次
        // 这里重新创建一个新的实例 wr_force_seq，而不是复用旧的 wr_seq，因为wr_seq卡死在刚刚的fork里面了
        begin
            fifo_write_seq wr_force_seq;
            wr_force_seq = fifo_write_seq::type_id::create("wr_force_seq");
            wr_force_seq.limit = 10;
            wr_force_seq.start(env.w_agent.sqr);
        end


/*==================================读空保护测试==================================*/
        // 排空
        `uvm_info("TEST3", "Step 2: Read until Empty...", UVM_LOW)
        rd_seq.limit = 74; // 读出先前全部尝试写入的数据
        fork
            rd_seq.start(env.r_agent.sqr);
        join_none // join_none不会阻塞

        // 等待空信号，由rempty接管是否继续阻塞
        @(posedge vif.rempty);
        `uvm_info("TEST3", "FIFO is now EMPTY. Forcing 10 additional READS...", UVM_LOW)

        // 已经空了就没必要再继续读了，同时也是配合基准模型验证空信号的准确性
        disable fork;

        // 追加10次读
        begin
            fifo_read_seq rd_force_seq;
            rd_force_seq = fifo_read_seq::type_id::create("rd_force_seq");
            rd_force_seq.limit = 10;
            rd_force_seq.start(env.r_agent.sqr);
        end

        #500ns;
        phase.drop_objection(this);
    endtask
endclass