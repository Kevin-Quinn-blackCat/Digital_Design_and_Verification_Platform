package fifo_cfg_pkg;

    // 复位类型枚举
    typedef enum logic [1:0] {
        ASYNC_RST          = 2'b00, // 异步复位，异步释放
        SYNC_RST           = 2'b01, // 同步复位，同步释放
        ASYNC_SYNC_RELEASE = 2'b10  // 异步复位，同步释放（最安全推荐）
    } rst_type_e;

    // 复位电平极性
    typedef enum logic {
        ACTIVE_LOW  = 1'b0,
        ACTIVE_HIGH = 1'b1
    } rst_pol_e;

endpackage : fifo_cfg_pkg