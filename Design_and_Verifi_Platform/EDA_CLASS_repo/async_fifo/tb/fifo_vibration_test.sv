/** 测试用例：混合并发读写
 * 继承自fifo_base_test
 * 
 * 1000次随机读和1000次随机写并发执行
 * 
 * 相比简单的fifo_mixed_test：
 * 
 * 1. 反应式激励：模拟了真实系统中的流量控制
 * 2. 数据水位震荡：逻辑会让 FIFO 的数据量在将近空和将近满之间反复横跳
 *              测试到指针在中间区域连续跳转时的同步逻辑是否稳健
 * 3. 时序压力：因为读得比写快，通过 wait(vif.walmost_full)
 *              这里我制造了一个“蓄水-瞬间泄洪”的突发传输效果
 *              这会产生很高的瞬时带宽，测试设计在面对突然的高速切换时
 *              其异步传输逻辑是否有延迟导致的误判
 */
class fifo_vibration_test extends fifo_base_test;
    // 注册到工厂
    `uvm_component_utils(fifo_vibration_test)

    // 需要 vif 来观察将近空满信号
    virtual async_fifo_if#() vif;

    // 构造函数
    function new(string name = "fifo_vibration_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#())::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Could not get vif")
    endfunction

    // 重写运行函数
    virtual task run_phase(uvm_phase phase);
        // 实例化基础序列，并将 limit 设为 1，这样可以精确控制每一次读写
        fifo_write_seq wr_seq;
        fifo_read_seq  rd_seq;
        int total_writes = 0;
        int total_reads  = 0;
        int max_trans    = 1000;
        bit writer_done  = 0;

        wr_seq = fifo_write_seq::type_id::create("wr_seq");
        rd_seq = fifo_read_seq::type_id::create("rd_seq");
        wr_seq.limit = 1;
        rd_seq.limit = 1;

        // 启动
        phase.raise_objection(this);
        `uvm_info("VIB_TEST", "Starting Vibration Test: Throttling by Almost_Full/Empty...", UVM_LOW)

        // 核心反馈循环
        fork
            // 写进程
            begin
                while (total_writes < max_trans) begin
                    // 如果快满了，写进程就歇一个时钟周期再看
                    if (vif.walmost_full) begin
                        @(vif.w_cb);
                    end else begin
                        wr_seq.start(env.w_agent.sqr);
                        total_writes++;
                    end
                end
                // 如果已经每东西可以写了，就不要把读进程死锁了，反馈一个信号
                writer_done = 1;
                `uvm_info("VIB_TEST", "All writes finished.", UVM_LOW)
            end

            // 读进程
            begin
                while (total_reads < max_trans) begin
                    // 策略是：如果还不是快满了，我就先不动
                    // 为了让数据在 FIFO 内部产生震荡，我们等它攒到 Almost_Full 再疯狂读
                    // 除非已经永远没有新数据了
                    wait(vif.walmost_full || writer_done); 
                    
                    // 一旦快满了，就开始读，直到读到快空了为止
                    // 除非已经永远没有新数据了
                    while ((!vif.ralmost_empty || writer_done) && total_reads < max_trans) begin
                        rd_seq.start(env.r_agent.sqr);
                        total_reads++;
                        if (writer_done && vif.rempty) break;
                    end
                    // 永远没有新数据就不要死锁了
                    if (writer_done && total_reads >= max_trans) break;
                end
                `uvm_info("VIB_TEST", "All reads finished.", UVM_LOW)
            end
        join

        // 最后收尾阶段，如果还有残留数据，一次性读完
        `uvm_info("VIB_TEST", "Final cleanup: draining FIFO...", UVM_LOW)
        while (!vif.rempty) begin
            rd_seq.start(env.r_agent.sqr);
        end

        #500ns;
        phase.drop_objection(this);
    endtask
endclass