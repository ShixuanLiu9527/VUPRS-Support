# FPGA Learning

本文档是关于 `FPGA` 的基础开发笔记.  

## 1. `VIVADO` 界面

`VIVADO` 软件的界面是按照 `FPGA` 的标准程序设计流程设计的.  

### 1.1 Source 

放置了 `Verilog` 源文件, 这里面放置 `Verilog` 源代码以及一些 `IP` 核, 包括设计文件 `.v` 和约束文件 `.xdc`.  

### 1.2 Simulation

代码仿真, 在代码仿真时需要书写顶层的测试模块 (Test Bench Module, TB), 一般是在原始代码顶层套一层.  
代码放在的 `TB` 文件名字可以随意写，但是最好写成 `myModule_tb.v` 的形式.  
`TB` 的语法如下:  

| 语法代码 | 说明 |
| :--- | :--- |
| `timescale 1ns / 1ps | 设置仿真的时间长度, `1ns` 对应 `#` 语句的延时长度, `1ps` 对应 `#` 语句的延时精度 |
| `#200` | 延时 `200ns`, 与 `timescale` 的设置对应 |
| `initial` | 是仿真信号的开始, 夹在 `initial begin` 和 `end` 之间的部分就是仿真过程 |

假设待测试模块为 `myModule`, 则一个典型的 `TB` 代码如下:  

    `timescale 1ns / 1ps

    module myModule_tb()

        reg s_a;
        reg s_b;
        wire s_o;

        myModule test_myModule(
            .a(s_a),
            .b(s_b),
            .out(s_o)
        );

        initial begin
            #200                // 延时 200ns
            s_a = 0; s_b = 0;
            #200
            s_a = 1; s_b = 1;
            $stop               // 当使用 ModelSim 软件仿真时需要使用
            // $finish             // 结束仿真并退出仿真器
        end

    endmodule

### 1.3 RTL Analysis

`RTL` 分析，将用户的设计输入细化成逻辑电路，也就是常说的 `RTL` 电路, 这是理想电路, 还需要后面 `2` 步才能生成真实电路.  
分析后会生成原理图视图 (`Schematic`), 可以直接查看逻辑结构.  
**只有完成这个才能进行代码仿真, 因为已经有了理想的电路结构**

### 1.4 Synthesis

`RTL` 代码综合，类似于软件编程中的编译，是一个把 `RTL` 电路用 `FPGA` 内资源实现的过程，会生成 `综合网表`.  
综合后会计算 `FPGA` 中的资源利用情况.  

### 1.5 Implementation

实现 (布局与布线), 将 `Verilog` 代码生成的 `综合网表` 映射到 `FPGA` 硬件电路上 (**只有完成布线后才能时序仿真, 因为在这之前没有真正的硬件用于仿真计算**).  
完成综合后, 需要将 `FPGA` 内部的电路接出来到 `IO` 引脚上, 在软件中点击菜单栏中的 `Layout --> I/O Planning`, 设置 `Verilog` 代码中每个信号对应的实际输出引脚, 也可以编写 `XDC` 文件建立约束.  
在引脚界面中需要确定电平标准, 以及其他一些必要信息.  
对于时钟信号, 需要在 `XDC` 文件中约束时钟, 例如:  

    set_property PACKAGE_PIN Y18 [get_ports clk]           # 绑定引脚
    set_property IOSTANDARD LVCMOS33 [get_ports clk]       # 设置电平
    create_clock -name sys_clk -period 20 [get_ports clk]  # 周期 20ns 的时钟

# 2. `Verilog` 语法

注: 此文档适用于 `Verilog-2001` 及以上.  

## 2.1 数值语法

`Verilog` 语言中数字通过 `3` 部分共同表示, 分别是 `位宽`, `进制` 和 `数值`, 例如:  

    4'b1011
    8'b1000_0001
    32'h3022_c0de

分别表示:  
1. `4` 位的 `二进制` 数 `1011`;  
2. `8` 位的 `二进制` 数 `10000001`, 下划线是方便设计人员读数字设计的, 在编译时会自动删除;  
3. `32` 位的 `16进制` 数 `0x3022C0DE`;  
注意这里使用的是单引号 `'`.  

## 2.2 `Verilog Module`

`Verilog` 使用 `Module` 描述一个电路元件, 一个 `Module` 的格式如下:

    module pwm_output
    (
        input clk,
        output reg led
    );

        parameter COUNT_MAX = 25_000_000 - 1;

        reg [24:0] counter;

        always @(posedge clk) begin
            if (counter == COUNT_MAX) begin
                counter <= 0;
                led <= ~led;
            end
            else begin
                counter <= counter + 1;
            end
        end

    endmodule

其中最外层的就是 `Module` 的整体, 语法格式为 (`Module` 的名称为 `module_name`):  

    module module_name
    (
        /* signal of module, input and output */
    );

        /* code */

    endmodule

在 `Module` 名称后的 `()` 中进行端口信号声明, 包括信号方向 (相对于 `Module`) 是 `input` 还是 `output`, 信号的类型是 `reg` 还是 `wire`, 默认所有端口的信号是 `wire` 类型, 例如上面 `pwm_output` 中的 `clk` 就是 `wire` 类型, `wire` 关键字可以选择不写.  
  
例如在端口声明部分使用如下语法:

    module example 
    (
        input      [3:0] a,  // 输入a，4位，默认为wire
        output reg [7:0] b   // 输出b，8位，直接声明为reg
    );
        // 无需在内部重复声明b
    endmodule

或者指明 `wire` 类型的输入:  

    module example 
    (
        input  wire [3:0] a,  // 输入a，4位，默认为wire
        output reg [7:0] b   // 输出b，8位，直接声明为reg
    );
        // 无需在内部重复声明b
    endmodule

需要特别注意的是, 输入端口不可以是 `reg` 类型, 只能是 `wire` 类型, 因为对于一个元件来说这个元件一定是由外部驱动的, 必须是线连接.  

## 2.3 模块内部声明 `wire` 和 `reg`

模块内部是可以声明 `wire` 和 `reg` 类型的, `wire` 相当于线的标签, 可以把多种逻辑运算的线组合在一起, 或者也可以被 `reg` 的东西赋值, 直接表示 `reg` 的值. `reg` 类型就是电子元件内部的寄存器, 可以存储一些运算数据.  

### 允许的赋值方向

1.`wire` 给 `wire` 赋值:  

    wire w1,w2;
    assign w1=~w2;

2.`reg` 给 `reg` 赋值:  

    reg r1,r2;

    always @(*) begin
        r1 = r2;
    end

3.`wire` 给 `reg` 赋值:  
  
对于组合逻辑  

    wire a;
    reg b;

    always @(*) begin
        b = a; 
    end

对于时序逻辑  

    wire a;
    reg b;

    always @(posedge clk or negedge rst_n) begin
        b <= a; 
    end

4.`reg` 给 `wire` 赋值

    reg a;
    wire b;


    always @(posedge clk) begin
        a <= a + 1;
    end

    assign b = a;

只要是对 `reg` 的赋值, 都必须在 `always` 中进行, 对 `wire` 的赋值都必须使用 `assign` 连线.  

## 2.4 `always` 语法

`always` 是 `Verilog` 中描述 `组合逻辑` 和 `时序逻辑` 的语法块, 基本语法结构为:  

    always @(/* sensitivity list */) begin

        /* 逻辑实现部分 */

    end

`always` 中只能对 `reg` 赋值, 因为只有 `reg` 可以被赋值, `wire` 只能使用 `assign` 语句在外面连线, 或者出现在 `always` 的敏感列表里面.  
`always` 语句通过敏感列表信号类型不同分为 `组合逻辑` 和 `时序逻辑`.  

### 2.4.1 组合逻辑

`always` 敏感列表如果全是非时钟信号, 那么称这个逻辑块为组合逻辑, 块中 `reg` 的赋值使用阻塞赋值, 即 `=`, 例如:  

    always @(a or b) begin
        y = a & b;
    end

代码表示当 `a` 或 `b` 发生变化时执行逻辑. 敏感列表中的信号可以用 `*` 代替, 表示所有输入信号发生改变时触发, 例如:  

    always @(*) begin
        y = a & b;
    end

阻塞赋值是具有先后顺序的, 代码会先执行第 `1` 句然后执行第 `2` 句.  

### 2.4.2 时序逻辑

`always` 敏感列表如果含有时钟信号, 那么称这个逻辑快为时序逻辑, 块中 `reg` 的赋值使用非阻塞赋值 (并行赋值), 即 `<=`, 例如:

    always @(posedge clk) begin
        q <= d;
    end

或者添加一个 `reset` 信号:  

    always @(posedge clk or negedge reset) begin
        if (reset) q <= 0;
        else q <= d;
    end

`negedge` 和 `posedge` 分别表示下降沿和上升沿, 代表 `clk` 信号的下降沿或 `reset` 信号的上升沿到来时触发该逻辑行为, `<=` 间的赋值是同步发生的, 没有先后顺序, 当时序逻辑开始时, 等式右侧的所有信号被同时所存, 然后同时赋值到等式左侧.  
当时钟上升沿到来时，所有 `D` 触发器的输入端 (`D`) 的值会被同时捕获，并存储到输出端 (`Q`)。这个捕获的过程是并行的, 只有再时序逻辑中使用 `<=` 才能完全模拟这种情况.  
使用 `<=` 和 `=` 是为了让代码和硬件统一, 避免出现与仿真结果不符合的情况.  

## 2.5 在当前模块中使用其他模块

`Verilog` 语言可以在本模块中使用其他模块的例化, 例如子模块写为:  

    module sub_module_example 
    (
        input  wire a,
        output reg out
    );
        
    endmodule

在顶层模块中按照如下方式调用子模块 `sub_module_example`:  

    module top_module_example 
    (
        input  wire c,
        output reg d
    );

        reg s_a;
        wire s_out;

        sub_module_example new_sub_module
        (
            .a(s_a),
            .out(s_out)
        )

    endmodule

## 2.6 模块参数化设计

顶层模块可以修改子模块的参数, 例如有一个子模块:  

    module sub_module_example 
    (
        input  wire a,
        output reg out
    );

    parameter PARAM = 1`b0000_1000;
        
    endmodule

那么顶层模块可以修改 `PARAM` 的值, 示例如下:  

    module top_module_example 
    (
        input  wire c,
        output reg d
    );

        reg s_a;
        wire s_out;

        sub_module_example new_sub_module
        (
            .a(s_a),
            .out(s_out)
        )

        defparam new_sub_module.PARAM = 1`b0000_0000;  /* 修改子模块中的参数 */

    endmodule

这样顶层模块就修改了子模块中的参数. 更现代的参数化赋值方法是使用 `#()`, 例如:  

    sub_module_example #(

    .PARAM(8'b0000_0000)

    ) new_sub_module (
        .a(s_a),
        .out(s_out)
    );

这个语法是 `Verilog-2001` 的特性, 更加安全.  

## 2.7 位拼接与位拆分

### 2.7.1 `wire` 类型位拼接与拆分

多个串行或者并行信号可以通过位拼接组成一个并行信号, 使用符号 `{ }` 表示位拼接, 例如:  

    wire a[3:0], b[4:0];
    wire c[7:0];

    assign c = {a, b};
    
这样就把 `a` 和 `b` 拼接成一个并行信号 `c`. 同样的, 常量也可以进行拼接:  

    assign c = {a, 8`b1};

这就表示把 `8'b1` 也拼接进去.  
还可以进行 `复制拼接`, 例如:  

    assign c = {8{a, b}};

等效为:  

    assign c = {{a,b}, {a,b}, ..., {a,b}} // 8 times

如果只需要并行信号中的其中一个或几个信号用于拼接, 那么可以通过 `[ ]` 方式访问这个需要的信号, 例如:  

    assign c = {a[1], b};
    assign d = {a[1:0], b[1]};

表示将 `a` 的第 `1` 位和 `b` 拼接为 `c`, 将 `a` 的 `1` 到 `0` 位和 `b` 的第 `1` 位拼接为 `d`.  

### 2.7.2 `reg` 类型位拼接与拆分

对于 `reg` 信号, 是不能在 `always` 块外面拼接的, 必须在 `always` 块内部拼接, 表示数据同步, 例如:  

    reg [3:0] a, b;
    reg [7:0] c;
 
    always @(*) begin
        c = {a, b}; // a, b -> 4 bit, then the c will be 8 bit
    end

除了必须在 `always` 中使用位拼接, `reg` 的其他拼接语法和 `wire` 类型是相同的, 只是不需要 `assign` 关键字, 因为这不是连线.  

## 2.8 逻辑结构

### 2.8.1 `if-else` 块

与 `C` 语言相区别, 这里 `if-else` 没有大括号, 而是使用关键字描述:  

    if (condition) begin
        /* code for this condition */
    end 

如果具有其他分支:  

    if (condition1) begin

        /* code for condition1 */

    end else if (condition2) begin

        /* code for condition2 */

    end else if (condition3) begin

        /* code for condition3 */

    end else begin

        /* code for condition */

    end

为了避免生成锁存器, `if-else` 代码块尽可能为所有情况提供处理.  
和 `C` 语言一样, 如果 `if` 后面只有一句话, 可以省略 `begin` 和 `end`.  

### 2.8.2 `case` 块

    case (expression)

        value1: begin
            /* code for value1 */
        end

        value2: begin
            /* code for value2 */
        end
       
        ... 

        default: begin 
            /* code for default condition */
        end

    endcase

同样为了避免生成锁存器, `case` 代码块尽可能为所有情况提供处理, 尽可能添加 `default` 分支.  
如果每个分支只有一句话, 可以省略 `begin` 和 `end`.  

## 2.9 程序结构

### 2.9.1 `for` 语句

`Verilog` 中的 `for` 语句是程序员为了偷懒发明的, 和 `C` 语言中的 `for` 有本质区别.  `C` 语言的 `for` 代表顺序执行, 但是 `Verilog` 里面的 `for` 只是说明程序有这些分支, `FPGA` 处理时会将他展开生成多个并行的硬件单元, 然后同时执行.  

**(1) `for` 循环用于生成多个同类型电路**  
  
例如要生成 `128` 个 `非门`, 传统方案为:  

    wire [127:0] a;
    wire [127:0] b;

    assign a[0] = ~b[0];
    assign a[1] = ~b[1];
    ... ...
    assign a[127] = ~b[127];

如果使用 `for` 循环, 可以这样写:  

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : your_block
            assign a[i] = ~b[i];
        end
    endgenerate

`your_block` 名称可以自定义, 注意对于生成电路的这种 `for`, 索引 `i` 的类型必须是 `genvar` (generate value), 并且必须取个名字.  
  
**(2) `for` 用于生成重复性逻辑电路**  
  
在 `always` 块中, 如果想要实现一个 `8` 位数的移位, 每个时钟到来时都把新数据放在低位, 然后其他数据依次向高位移动, 传统方案应该是:  

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            data_out <= 8'b0;

        end else begin

            data_out[7] <= data_out[6];
            data_out[6] <= data_out[5];
            data_out[5] <= data_out[4];
            data_out[4] <= data_out[3];
            data_out[3] <= data_out[2];
            data_out[2] <= data_out[1];
            data_out[1] <= data_out[0];
            data_out[0] <= data_in;

        end
    end

使用 `for` 循环后可以这样写:  

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            data_out <= 8'b0;

        end else begin
        
            integer i;

            for (i = 7; i > 0; i = i - 1) begin

                data_out[i] <= data_out[i-1];

            end

            data_out[0] <= data_in;
        end
    end

对于这种方式, 索引 `i` 的类型必须是 `integer`.  
不管从哪个方面来说, `for` 都是一个减少代码量的工具, 在看 `for` 循环时都需要把他展开.  
  
**(3) `for` 语句使用注意事项**  
  
由于 `for` 只是一个减少代码的工具, 因此 `for` 的上下限必须是固定值, 保证等效的代码是固定.  

# 3. 程序结构

## 3.1 状态机

本部分体现在实际代码中, 此处略.  

# 4. `IP` 核

`IP` 核 (`Intellectual Property Core`) 即知识产权, 是预先设计好, 经过验证的, 可重复使用的功能模块. 在 `FPGA` 设计中，将这些参数配置正确的参数并连线, 就可以使用这些复杂功能, 可以理解为预制件.  

## `PLL` 

`PLL` 是锁相环 `IP` 核, 是程序中最常用的 `IP` 之一, 在 `Xilinx FPGA` 时钟管理模块中, 包含了时钟管理单元 (`Clock Management Tile`, `CMT`), 每个 `CMT` 由一个混合模式时钟管理 (`Mixed-Mode Clock Manager`, `MMCM`) 和锁相环 (`Phase Locked Loop`, `PLL`) 组成.  
其中 `PLL` 用来整合时钟信号, 使高频器件正常工作;  
`MMCM` 是基于 `PLL` 的新型混合模式时钟管理器, 实现了最低的抖动和抖动滤波, 为高性能的 `FPGA` 设计提供更高性能的时钟管理功能, `MMCM` 在 `PLL` 的基础上加上了相位动态调整功能, 又因为 `PLL` 是模拟电路, 而动态调相是数字电路, 所以 `MMCM` 被称为混合模式;  

# 5. `AXI4` 总线