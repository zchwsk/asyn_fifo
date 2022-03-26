# asyn_fifo
异步FIFO(asyn_fifo)的Verilog实现。

写在前面：这是本人第一个repository，多有不足之处请见谅。

文件内asyn_fifo是主模块，另一个是SRAM的子模块，该子模块已经在主模块中被调用。直接在Vivado中使用即可。

作为一个IC（FPGA）初学者，最近几日通过各种资料学了有关异步FIFO的有关内容，深感异步FIFO在跨时钟域处理中的好用之处。为了能对异步FIFO的理解更深刻（更为了今年秋招哈哈哈），决定使用Verilog实现异步FIFO。如有问题欢迎讨论，如有错误恳请大佬指正。
