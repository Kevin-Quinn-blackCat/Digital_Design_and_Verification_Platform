/** 覆盖率类
 * 
 * 继承自uvm_subscriber，带有analysis_export，在env里面连上Monitor的ap就好
 * 必须要实现一个名为write()的回调函数，监控Monitor
 * 
 * 用于接收并处理从Monitor发来的数据
 */
class fifo_coverage #(parameter int DATA_WIDTH = 16) extends uvm_subscriber#(fifo_seq_item#(DATA_WIDTH));
    // 注册工厂函数
    `uvm_component_param_utils(fifo_coverage#(DATA_WIDTH))

    // 接口
    virtual async_fifo_if#(DATA_WIDTH) vif;
    
    // 覆盖率组covergroup定义
    covergroup fifo_cov_cg;

        // 为每个实例单独统计
        option.per_instance = 1;

        // 写使能
        CP_WINC: coverpoint vif.winc {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        // 写满
        CP_WFULL: coverpoint vif.wfull {
            bins full     = {1'b1};
            bins not_full = {1'b0};
        }

        // 将满
        CP_WALMOST_FULL: coverpoint vif.walmost_full {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        // 读使能
        CP_RINC: coverpoint vif.rinc {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        // 读空
        CP_REMPTY: coverpoint vif.rempty {
            bins empty     = {1'b1};
            bins not_empty = {1'b0};
        }

        // 将空
        CP_RALMOST_EMPTY: coverpoint vif.ralmost_empty {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        // 交叉覆盖率
        // 尝试在写满时写入
        CROSS_WRITE_FULL: cross CP_WINC, CP_WFULL;
        // 尝试在读空时读取
        CROSS_READ_EMPTY: cross CP_RINC, CP_REMPTY;
        
        // 尝试在将近满时继续写
        CROSS_ALMOST_FULL:  cross CP_WINC, CP_WALMOST_FULL;
        // 尝试在将近空时继续读
        CROSS_ALMOST_EMPTY: cross CP_RINC, CP_RALMOST_EMPTY;
    endgroup

    // 构造
    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_cov_cg = new();
    endfunction

    // 建立
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#(DATA_WIDTH))::get(this, "", "vif", vif))
            `uvm_fatal("COV", "Could not get vif")
    endfunction

    // 回调函数：每当 Monitor 发出一笔数据，都会触发这个 write 函数
    virtual function void write(fifo_seq_item#(DATA_WIDTH) t);
        // 由于连接Monitor的ap，而Monitor只在有效的读写事务时广播
        // 因此这里的sample会过滤掉无意义的动作
        // 每当有有效动作时，都要sample一下
        fifo_cov_cg.sample();

        // 这里虽然传入了fifo_seq_item，但是我们监控vif
    endfunction
endclass