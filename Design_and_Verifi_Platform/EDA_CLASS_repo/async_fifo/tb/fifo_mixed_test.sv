/** 测试用例：混合并发读写
 * 继承自fifo_base_test
 * 
 * 1000次随机读和1000次随机写并发执行
 * 
 */
class fifo_mixed_test extends fifo_base_test;
    // 注册到工厂
    `uvm_component_utils(fifo_mixed_test)

    // 构造函数
    function new(string name = "fifo_mixed_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // 重写父类的run_phase，定义具体的测试逻辑
    virtual task run_phase(uvm_phase phase);

        // 声明两个Sequence实例
        fifo_write_seq wr_seq;
        fifo_read_seq  rd_seq;

        // 实例化它们
        wr_seq = fifo_write_seq::type_id::create("wr_seq");
        rd_seq = fifo_read_seq::type_id::create("rd_seq");

        // 反对UVM停止仿真
        phase.raise_objection(this);

        `uvm_info("TEST2", "Starting 2000 mixed Transactions (1000 Writes & 1000 Reads)...", UVM_LOW)

        // 将两个Sequence的次数改成1000次
        wr_seq.limit = 1000;
        rd_seq.limit = 1000;

        // 并发读写
        fork
            wr_seq.start(env.w_agent.sqr);
            rd_seq.start(env.r_agent.sqr);
        join

        // 确保流水线排空
        #2000ns;

        // 允许UVM结束仿真进入check_phase
        phase.drop_objection(this);
    endtask
endclass