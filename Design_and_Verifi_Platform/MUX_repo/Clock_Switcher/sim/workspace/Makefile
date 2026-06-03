include config.mk

# ##########################################################################################################################
#  !! 警告 !!：请勿随意修改此脚本。除非你完全理解代码逻辑并明确知道你在做什么，否则任何微小的变动都可能导致程序运行异常或系统崩溃。
# 
#  警告 (WARNING):
# 请勿轻易修改本脚本。本代码包含核心逻辑，除非你具备相关的开发经验并完全理解修改后的后果，
# 否则擅自改动可能会导致不可预知的错误。
# ##########################################################################################################################


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