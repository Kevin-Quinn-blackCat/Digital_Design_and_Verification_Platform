# Digital Design and Verification Platform

## English

This repository provides a scripted file structure for digital RTL design and verification, with a focus on ModelSim-based simulation workflows.

### Key Concepts
- Each design example is organized into a project folder containing RTL, testbench, simulation scripts, and workspace files.
- Most projects use a per-project `sim/workspace/Makefile` to control ModelSim commands.
- `config.mk` defines the top-level testbench module, simulation time, and library mapping.
- `run.do` and `check.do` are ModelSim command scripts that compile and simulate or verify the design.

### Repository Structure
- `DV_prj_repo/` — digital verification project collection
  - `0.default_repo/`, `EDA_CLASS_repo/`, `KEY_FILTER_repo/` — grouped example repositories
  - Each project typically contains:
    - `rtl/` — design source files (`.v`, `.sv`, etc.)
    - `tb/` — testbench sources
    - `sim/scripts/` — ModelSim DO scripts such as `run.do` and `check.do`
    - `sim/workspace/` — a local makefile, generated build/output files, and simulation artifacts
    - `doc/` — documentation, logs, and notes
- `exp_prj_lib/` — experimental project/library examples
- `New/`, `New0/`, `New1/` — additional design examples with their own simulation setups
- `scripts/` — helper scripts for project generation and file operations

### How Make Works
- There is no single top-level `Makefile` for the entire repository.
- Use the `Makefile` inside each project's `sim/workspace/` directory.
- Common targets include:
  - `make sim` — run ModelSim in batch mode and exit after simulation
  - `make gui` — open ModelSim GUI and run the design interactively
  - `make check` — perform a synthesis-style syntax check without running the simulation
  - `make clean` — remove generated build/output directories and ModelSim temporary files
  - `make all` — default target, usually mapped to `gui` or `check` depending on the project

### Typical Usage
1. Create or copy a local project based on an existing template, such as `0.default_repo`.
   - If the project includes a top-level `Makefile`, run it to generate the local example workspace.
   ```bat
   make
   ```
2. Place design RTL files under `rtl/` and testbench files under `tb/`.
3. Enter the project workspace, for example:
   ```bat
   cd DV_prj_repo\KEY_FILTER_repo\Integral_filter\sim\workspace
   ```
4. Edit `config.mk` and `file_list.f` to update the top module, simulation time, and source list.
5. Run syntax checking:
   ```bat
   make check
   ```
6. Run the simulation in batch mode:
   ```bat
   make sim
   ```
7. Run the simulation in GUI mode:
   ```bat
   make gui
   ```
8. Clean generated artifacts:
   ```bat
   make clean
   ```

### What the Scripts Do
- `config.mk` defines:
  - `TOP_MODULE` — top-level module name for simulation
  - `SIM_TIME` — simulation runtime, such as `1ms`
  - `LIB_NAME` — ModelSim library name (`work` by default)
- `run.do`:
  - creates `../build`, `../output/log`, and `../output/wave`
  - resets and creates the simulation library
  - compiles source files from `file_list.f`
  - launches ModelSim and runs the testbench for the configured time
- `check.do`:
  - resets and creates the library
  - compiles sources from `file_list.f` in quiet mode for syntax checking only

### Notes
- The structure is designed for ModelSim but can be adapted for compatible simulators using similar scripts.
- `scripts/gen_prj.bat` is used by some project-level makefiles (for example `DV_prj_repo/0.default_repo/Makefile`) to copy example project files into new directories.
- Output logs and waveform files are typically stored under `sim/output/` and `sim/workspace`.

## 中文

本仓库提供了一个用于数字RTL设计与验证的脚本化文件体系，主要面向基于 ModelSim 的仿真流程。

### 关键概念
- 每个设计示例都组织为一个项目目录，包含 RTL、测试平台、仿真脚本和工作区文件。
- 大多数项目通过各自 `sim/workspace/Makefile` 控制 ModelSim 命令。
- `config.mk` 定义了顶层测试平台模块、仿真时间和库映射。
- `run.do` 和 `check.do` 是 ModelSim 命令脚本，分别用于编译仿真和语法检查。

### 仓库结构
- `DV_prj_repo/` — 数字验证项目集合
  - `0.default_repo/`、`EDA_CLASS_repo/`、`KEY_FILTER_repo/` — 分组示例仓库
  - 每个项目通常包含：
    - `rtl/` — 设计源文件（`.v`、`.sv` 等）
    - `tb/` — 测试平台源文件
    - `sim/scripts/` — 如 `run.do`、`check.do` 的 ModelSim 脚本
    - `sim/workspace/` — 本地 Makefile、生成的构建输出和仿真文件
    - `doc/` — 文档、日志和说明
- `exp_prj_lib/` — 实验项目和库示例
- `New/`、`New0/`、`New1/` — 额外的设计示例及其仿真设置
- `scripts/` — 项目生成和文件操作辅助脚本

### Make 如何工作
- 本仓库没有一个统一的顶层 `Makefile`。
- 使用每个项目 `sim/workspace/` 内的 `Makefile`。
- 常用目标包括：
  - `make sim` — 批处理模式运行 ModelSim，仿真结束后退出
  - `make gui` — 打开 ModelSim GUI 交互运行
  - `make check` — 执行语法检查，不运行仿真
  - `make clean` — 删除生成的构建/输出目录和 ModelSim 临时文件
  - `make all` — 默认目标，通常映射到 `gui` 或 `check`

### 典型使用方法
1. 打开或复制并重命名`0.default_repo`以打开一个本地工程仓库
2. 在本地工程仓库下执行Makefile创建工程项目New：
   ```bat
   make
   ```
3. 将设计和仿真文件分别放入`rtl`和`tb`后进入项目工作区，例如：
   ```bat
   cd DV_prj_repo\KEY_FILTER_repo\Integral_filter\sim\workspace
   ```
4. 改动配置文件`config.mk`和`file_list.f`
5. 运行语法检查：
   ```bat
   make check
   ```
6. 批处理模式运行仿真：
   ```bat
   make sim
   ```
7. GUI 模式运行仿真：
   ```bat
   make gui
   ```
8. 清理生成文件：
   ```bat
   make clean
   ```

### 脚本功能说明
- `config.mk` 定义：
  - `TOP_MODULE` — 仿真顶层模块名
  - `SIM_TIME` — 仿真时间，例如 `1ms`
  - `LIB_NAME` — ModelSim 库名（默认 `work`）
- `run.do`：
  - 创建 `../build`、`../output/log`、`../output/wave`
  - 重置并创建仿真库
  - 从 `file_list.f` 编译源文件
  - 启动 ModelSim 并运行测试平台
- `check.do`：
  - 重置并创建仿真库
  - 从 `file_list.f` 编译源文件，进行静态语法检查

### 备注
- 该结构适用于 ModelSim，但可根据类似脚本适配兼容仿真器。
- `scripts/gen_prj.bat` 被一些项目级 Makefile 调用（例如 `DV_prj_repo/0.default_repo/Makefile`），用于复制示例项目文件。
- 输出日志和波形文件通常保存在 `sim/output/` 和 `sim/workspace` 下。
