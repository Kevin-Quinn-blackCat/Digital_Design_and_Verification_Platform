package async_fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // 最基础的 transaction 定义
    `include "fifo_seq_item.sv"

    // 驱动与监视器
    `include "fifo_driver_monitor.sv"

    // 通道、记分板与覆盖率
    `include "fifo_scoreboard.sv"
    `include "fifo_coverage.sv"
    `include "fifo_env.sv"

    // 测试序列与用例
    `include "fifo_base_test.sv"
    `include "fifo_full_empty_test.sv"
    `include "fifo_mixed_test.sv"
    `include "fifo_extreme_test.sv"
    `include "fifo_vibration_test.sv"

endpackage