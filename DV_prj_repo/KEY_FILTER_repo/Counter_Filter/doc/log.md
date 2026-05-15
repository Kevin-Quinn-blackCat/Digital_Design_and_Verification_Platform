Task  任务
Tasks are used in all programming languages, generally known as procedures or subroutines. The lines of code are enclosed in task....end task brackets. Data is passed to the task, the processing done, and the result returned. They have to be specifically called, with data ins and outs, rather than just wired in to the general netlist. Included in the main body of code, they can be called many times, reducing code repetition.
任务在所有编程语言中都使用，通常被称为过程或子程序。代码行被包含在任务...end task 括号中。数据传递给任务，进行处理，并返回结果。它们需要被明确调用，带有输入和输出数据，而不是简单地连接到通用网络列表中。包含在代码主体中，它们可以被多次调用，减少代码重复。

 	 	


tasks are defined in the module in which they are used. It is possible to define a task in a separate file and use the compile directive 'include to include the task in the file which instantiates the task.
任务在它们被使用的模块中定义。可以在一个单独的文件中定义任务，并使用编译指令'include'将任务包含在实例化任务的文件中。
tasks can include timing delays, like posedge, negedge, # delay and wait.
任务可以包括定时延迟，如 posedge、negedge、#延迟和等待。
tasks can have any number of inputs and outputs.
任务可以有任意数量的输入和输出。
The variables declared within the task are local to that task. The order of declaration within the task defines how the variables passed to the task by the caller are used.
在任务中声明的变量属于该任务。声明顺序定义了调用者传递给任务的变量如何被使用。
tasks can take, drive and source global variables, when no local variables are used. When local variables are used, basically output is assigned only at the end of task execution.
当不使用局部变量时，任务可以获取、驱动和源全局变量。当使用局部变量时，基本上输出只在任务执行结束时被分配。
tasks can call another task or function.
任务可以调用另一个任务或函数。
tasks can be used for modeling both combinational and sequential logic.
任务可用于建模组合逻辑和时序逻辑。
A task must be specifically called with a statement, it cannot be used within an expression as a function can.
任务必须通过语句显式调用，不能像函数那样在表达式中使用。
 	 	


 		Syntax  语法
 	 	


A task begins with keyword task and ends with keyword endtask
任务以关键字 task 开始，并以关键字 endtask 结束。
Inputs and outputs are declared after the keyword task.
输入和输出在 task 关键字之后声明。
Local variables are declared after input and output declaration.
局部变量在输入和输出声明之后声明。
 	 	


 		Example - Simple Task
示例 - 简单任务
 	 	



  1 module simple_task();
  2 
  3 task convert;
  4 input [7:0] temp_in;
  5 output [7:0] temp_out;
  6 begin
  7   temp_out = (9/5) *( temp_in + 32)
  8 end
  9 endtask
 10 
 11 endmodule
You could download file simple_task.v here
你可以在这里下载文件 simple_task.v
 	 	


 		Example - Task using Global Variables
示例 - 使用全局变量的任务
 	 	



  1 module task_global();
  2 
  3 reg [7:0] temp_out;
  4 reg [7:0] temp_in;
  5 
  6 task convert;
  7 begin
  8   temp_out = (9/5) *( temp_in + 32);
  9 end
 10 endtask
 11 
 12 endmodule
You could download file task_global.v here
您可以从这里下载 task_global.v 文件
 	 	


 	 	


 		Calling a Task  调用任务
Let's assume that the task in example 1 is stored in a file called mytask.v. Advantage of coding a task in a separate file, is that it can be used in multiple modules.
假设示例 1 中的任务存储在一个名为 mytask.v 的文件中。将任务编码在单独的文件中的优点是，它可以在多个模块中使用。

 	 	



  1 module  task_calling (temp_a, temp_b, temp_c, temp_d);
  2 input [7:0] temp_a, temp_c;
  3 output [7:0] temp_b, temp_d;
  4 reg [7:0] temp_b, temp_d;
  5 `include "mytask.v"
  6   	 
  7 always @ (temp_a)
  8 begin	
  9   convert (temp_a, temp_b);
 10 end  
 11 
 12 always @ (temp_c)
 13 begin	
 14   convert (temp_c, temp_d);
 15 end  
 16   	 
 17 endmodule
You could download file task_calling.v here
您可以从这里下载文件 task_calling.v