include config.mk

# 路径定义
SCRIPT_PATH = ../scripts/run.do
CHECK_SCRIPT = ../scripts/check.do

all:

# 命令行模式：执行完立即退出
sim:
	vsim -c -do "do $(SCRIPT_PATH) $(TOP_MODULE) $(SIM_TIME) $(LIB_NAME); quit -f"

# GUI 模式：执行完停留在界面
gui:
	vsim -do "do $(SCRIPT_PATH) $(TOP_MODULE) $(SIM_TIME) $(LIB_NAME)"


# 极速语法检查
check:
	@echo ----------------------------------------------------
	@echo  Starting Syntax Check...
	@echo ----------------------------------------------------
	vsim -c -do "do $(CHECK_SCRIPT) $(LIB_NAME); quit -f"
	@echo ----------------------------------------------------
	@echo  Syntax Check Finished!
	@echo ----------------------------------------------------
	pause

# clean 重置所有环境
clean:
	@echo ----------------------------------------------------
	@echo  Clear Cache...
	@echo Cleaning up project folders...
	vsim -c -do "file delete -force ../build ../output; quit"
	@if exist transcript del /q transcript
	@if exist modelsim.ini del /q modelsim.ini
	@if exist vsim.wlf del /q vsim.wlf
	@echo  Cleanup Completed!
	@echo ----------------------------------------------------