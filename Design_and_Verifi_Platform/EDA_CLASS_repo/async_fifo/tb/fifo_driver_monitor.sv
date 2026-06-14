
/*==================================driver==================================*/

/** 写驱动类
 * 
 * 继承uvm_driver类、输入fifo_seq_item类
 * 
 */
class fifo_write_driver #(parameter int DATA_WIDTH = 16) extends uvm_driver#(fifo_seq_item#(DATA_WIDTH));

    // 定义接口async_fifo_if
    virtual async_fifo_if#(DATA_WIDTH) vif;

    // 注册工厂函数create()
    `uvm_component_param_utils(fifo_write_driver#(DATA_WIDTH))

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        // 调用父类的建立函数
        super.build_phase(phase);
        // 尝试在config_db中获取虚拟接口，若失败fatal
        if(!uvm_config_db#(virtual async_fifo_if#(DATA_WIDTH))::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get vif")
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);

        // 初始化
        vif.w_cb.winc  <= 1'b0;
        vif.w_cb.wdata <= '0;
        @(posedge vif.wrst_n);


        // 循环
        forever begin

            // 请求一个数据，如果请求不到这里会卡住
            // 显然其是fifo_seq_item类型的
            seq_item_port.get_next_item(req);

            // 使用里面的随机延迟，约束为0~4
            repeat(req.delay) @(vif.w_cb);
            
            // 发出去
            vif.w_cb.winc  <= 1'b1;
            vif.w_cb.wdata <= req.data;
            @(vif.w_cb);
            vif.w_cb.winc  <= 1'b0;
            
            // 结束
            seq_item_port.item_done();
        end
    endtask
endclass

/** 读驱动类
 * 
 * 继承uvm_driver类、输入fifo_seq_item类
 * 
 */
class fifo_read_driver #(parameter int DATA_WIDTH = 16) extends uvm_driver#(fifo_seq_item#(DATA_WIDTH));

    // 接口
    virtual async_fifo_if#(DATA_WIDTH) vif;

    // 注册工厂函数
    `uvm_component_param_utils(fifo_read_driver#(DATA_WIDTH))

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#(DATA_WIDTH))::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get vif")
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);

        // 初始化
        vif.r_cb.rinc <= 1'b0;
        @(posedge vif.rrst_n);

        // 循环
        forever begin
            // 获取随机数据
            seq_item_port.get_next_item(req);

            // 延迟
            repeat(req.delay) @(vif.r_cb);
            
            // 读取
            vif.r_cb.rinc <= 1'b1;
            @(vif.r_cb);
            vif.r_cb.rinc <= 1'b0;
            
            // 结束
            seq_item_port.item_done();
        end
    endtask
endclass







/*==================================monitor==================================*/

/** 写监测类
 * 
 * 继承自uvm_monitor类
 * 
 */
class fifo_write_monitor #(parameter int DATA_WIDTH = 16) extends uvm_monitor;

    // 接口
    virtual async_fifo_if#(DATA_WIDTH) vif;

    // 声明analysis_port变量，用来广播给Scoreboard
    // 传递的数据类型为fifo_seq_item
    uvm_analysis_port #(fifo_seq_item#(DATA_WIDTH)) ap;

    // 注册工厂函数
    `uvm_component_param_utils(fifo_write_monitor#(DATA_WIDTH))

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#(DATA_WIDTH))::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);

        // 循环
        forever begin

            // 延迟一拍
            @(vif.wmon_cb);

            // 若写使能且没有写满
            // 说明写入了数据
            if (vif.wmon_cb.winc && !vif.wmon_cb.wfull) begin

                // 声明一个内部的fifo_seq_item类型实例
                fifo_seq_item#(DATA_WIDTH) item;

                // 重新create，否则会覆盖之前的指针
                item = fifo_seq_item#(DATA_WIDTH)::type_id::create("item");

                // 指定这个数据的方向属性是‘写’
                item.dir  = WRITE;

                // 数据是刚刚写入的数据
                item.data = vif.wmon_cb.wdata;

                // 广播出去
                ap.write(item);
            end
        end
    endtask
endclass


/** 读监测类
 * 
 * 继承自uvm_monitor类
 * 
 */
class fifo_read_monitor #(parameter int DATA_WIDTH = 16) extends uvm_monitor;

    // 接口
    virtual async_fifo_if#(DATA_WIDTH) vif;

    // 广播
    uvm_analysis_port #(fifo_seq_item#(DATA_WIDTH)) ap;

    // 注册工厂函数
    `uvm_component_param_utils(fifo_read_monitor#(DATA_WIDTH))

    // 构造函数
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    // 建立函数
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_if#(DATA_WIDTH))::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")
    endfunction

    // 执行函数
    virtual task run_phase(uvm_phase phase);
        forever begin

            // 延迟一拍
            @(vif.rmon_cb);

            // 如果读了且非空
            // 说明读取到正确信息了
            if (vif.rmon_cb.rinc && !vif.rmon_cb.rempty) begin

                // 中间变量
                fifo_seq_item#(DATA_WIDTH) item;
                item = fifo_seq_item#(DATA_WIDTH)::type_id::create("item");

                // 保存
                item.dir  = READ;
                item.data = vif.rmon_cb.rdata;

                // 广播
                ap.write(item);
            end
        end
    endtask
endclass

/*================================================================================*/