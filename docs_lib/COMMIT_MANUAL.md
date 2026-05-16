这份手册旨在为 Verilog/SystemVerilog 数字电路开发项目提供一套标准化的 Git Commit 规范。采用 `type: description` 格式（基于 Angular 规范演进），并针对硬件描述语言（HDL）和验证环境的特殊需求进行了扩展。

---

### Commit Message 基本格式

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

- **type**: 变更类型（必选）
- **scope**: 作用域，如模块名、子系统、工具链等（可选）
- **description**: 简洁的中文/英文描述（必选）

---

### 1. 通用开发类型 (Standard Types)

| 类型 | 描述 | 硬件工程示例 |
| :--- | :--- | :--- |
| **feat** | 引入新功能/新模块 | `feat(alu): 增加浮点加法支持` |
| **fix** | 修复 Bug | `fix(fsm): 修复状态机死循环逻辑` |
| **docs** | 文档变更 | `docs(readme): 更新寄存器映射表 (Address Map)` |
| **style** | 格式调整（不影响逻辑） | `style(top): 统一缩进为4个空格，清理冗余注释` |
| **refactor** | 代码重构（既非新增也非修复） | `refactor(decoder): 使用 casez 简化指令译码逻辑` |
| **perf** | 性能优化（Timing/Area/Power） | `perf(mult): 插入流水线寄存器以优化 Slack` |
| **test** | 增加或修改测试用例 | `test(uvm): 增加随机约束以覆盖极端地址边界` |
| **chore** | 构建过程或辅助工具变动 | `chore(makefile): 增加 VCS 编译选项 -debug_access+all` |
| **revert** | 撤销之前的 commit | `revert: feat(dma): 撤回错误的 DMA 突发模式修改` |

---

### 2. 硬件/EDA 专项类型 (Hardware Specific Types)

针对数字 IC/FPGA 开发流程定制的特定类型：

| 类型 | 描述 | 适用场景 |
| :--- | :--- | :--- |
| **rtl** | RTL 级逻辑变更 | 专门指代对 Verilog/SV 逻辑代码的物理实现修改 |
| **dv** | 设计验证相关 | UVM/SVTB 环境、Scoreboard、Monitor 等更新 |
| **syn** | 综合相关 | 综合脚本、Tcl 约束、Area/Gate count 优化 |
| **constr** | 时序约束 | SDC、XDC 约束文件修改，如时钟定义、输入输出延迟 |
| **sim** | 仿真环境 | 仿真模型替换（如内存模型）、波形记录配置变更 |
| **formal** | 形式验证 | SVA (SystemVerilog Assertions) 或 Formal 脚本变更 |
| **ip** | 第三方 IP 核 | IP 升级、配置变更（如 Xilinx .xci 或 Altera .ip） |
| **netlist** | 网表级别变更 | 后仿真修复、ECO 修改、网表替换 |
| **dsa** | 架构定义 | 涉及寄存器定义文件（JSON/YAML/Excel）的变更 |

---

### 3. 作用域 (Scope) 建议

在硬件工程中，`<scope>` 建议按以下维度划分：
- **Module**: `alu`, `fifo`, `dma_ctrl`
- **Subsystem**: `pcie_top`, `mem_subsys`
- **Toolchain**: `vcs`, `vivado`, `quartus`, `dc`
- **Interface**: `axi4`, `apb`, `chi`
- **Environment**: `uvm`, `verilator`, `cocotb`

---

### 4. 典型场景示例

#### 场景 A：逻辑修复（针对 Timing）
```text
perf(ecc): insert register stage to fix setup timing violation
- Added a pipeline stage after the parity tree.
- Improved Fmax by 15% in Vivado 2024.1.
```

#### 场景 B：验证环境更新
```text
dv(ral): update register model from XML source
- Re-generated the UVM RAL model to match the latest address map.
- Fixed an offset mismatch in the CTRL_REG2.
```

#### 场景 C：时序约束调整
```text
constr(spi): add input_delay constraints for MISO
- Added set_input_delay to align with sensor datasheet.
- Defined multicycle path for the slow reset domain.
```

#### 场景 D：形式验证
```text
formal(arbiter): add cover points for starvation check
- Inserted SVA to ensure all request grants are issued within 32 cycles.
```

---

### 5. 快速查阅表

| 目的 | 推荐 Type |
| :--- | :--- |
| 改了 `.v` / `.sv` 的逻辑 | `rtl` / `feat` / `fix` |
| 改了 `.sdc` / `.xdc` | `constr` |
| 改了 `Makefile` | `chore` |
| 跑了 lint 修复了代码风格 | `style` |
| 为了过 Timing 动了电路结构 | `perf` |
| 增加了断言（Assertion） | `formal` |
| 更新了设计文档/寄存器表 | `docs` |
| 修改了 Testbench / UVM 序列 | `dv` |
