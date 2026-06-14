// 方向类型direction_e
// 用于区分读写操作
typedef enum {WRITE, READ} direction_e;

/** 数据交换对象
 * 
 * fifo_seq_item.sv
 * 
 * 继承uvm_sequence_item以提供打印、记录、随机化等功能
 * 
 * 组件之间传递的基本信息类，应该作为Transaction的基类
 * 包含：读写类型、读写数据、动作延迟
 * （均随机化）
 */
class fifo_seq_item #(parameter int DATA_WIDTH = 16) extends uvm_sequence_item;

    // 随机化
    rand direction_e             dir;   // 随机方向
    rand bit [DATA_WIDTH-1:0]    data;  // 随机数据
    rand int                     delay; // 随机延迟

    // 随机约束，延迟限制在0到4个周期以内
    constraint c_delay { delay inside {[0:4]}; }

    // UVM域注册自动化宏
    // 这玩意这么全自动的说是ALL_ON
    `uvm_object_param_utils_begin(fifo_seq_item#(DATA_WIDTH))
        `uvm_field_enum(direction_e, dir, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
    `uvm_object_utils_end



    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction
endclass