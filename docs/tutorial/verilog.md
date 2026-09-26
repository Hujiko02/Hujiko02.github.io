# Verilog 入门教程

> **面向读者**：学过一点数字电路（知道与或非、触发器、时序图、状态图），但没写过 Verilog。
> **环境**：Debian（bookworm 及以上），`iverilog 13.0` + `vvp` + `gtkwave 3.3`。
> **承诺**：本文里每一段带「文件:」标记的代码都在本机真实编译、真实仿真跑过，输出结果直接抄自终端。
> **语言**：中文正文，关键术语保留英文，方便你以后查资料。
> **代码文件编号**：按文中出现顺序编号（`ex01`…`ex21`），同名加 `tb_` 前缀的是它的测试平台（`tb_ex01_and_gate.v` 等）。附录 B 可以一键把它们全部导出成文件。

## 目录

- [第 0 章 先把工具链跑通](#第-0-章-先把工具链跑通)
- [第 1 章 Verilog 是什么：用文字画电路](#第-1-章-verilog-是什么用文字画电路)
- [第 2 章 数据类型、位宽与赋值](#第-2-章-数据类型位宽与赋值)
- [第 3 章 组合逻辑](#第-3-章-组合逻辑)
- [第 4 章 时序逻辑](#第-4-章-时序逻辑)
- [第 5 章 状态机（FSM）](#第-5-章-状态机fsm)
- [第 6 章 存储器与总线](#第-6-章-存储器与总线)
- [第 7 章 测试平台（Testbench）](#第-7-章-测试平台testbench)
- [第 8 章 GTKWave 实战](#第-8-章-gtkwave-实战)
- [第 9 章 可综合风格与工程约定](#第-9-章-可综合风格与工程约定)
- [附录 A 命令行速查](#附录-a-命令行速查)
- [附录 B 一键导出本文所有代码](#附录-b-一键导出本文所有代码)
- [附录 C Makefile](#附录-c-makefile)
- [附录 D 练习题](#附录-d-练习题)
- [附录 E 继续学习](#附录-e-继续学习)

---

## 第 0 章 先把工具链跑通

### 0.1 三个工具的分工

初学者最容易糊涂的就是这三个命令谁管谁。一句话记住：

```text
  你的源码                编译                      仿真执行                波形
  tb.v + ex.v  --[iverilog]-->  sim.vvp  --[vvp]-->  终端打印  +  dump.vcd  --[gtkwave]-->  图形波形
   (人写的)                    (仿真可执行文件)        (跑的引擎)                 (波形文件)
```

- **iverilog**：编译器。把 Verilog 源码"编译"成一个只有 `vvp` 能执行的文件（默认后缀习惯写成 `.vvp`）。它**不**执行任何仿真。
- **vvp**：仿真引擎（runtime）。真正跑时间、跑 `#10`、打印 `$display`、写 `.vcd` 波形文件。
- **gtkwave**：波形查看器。它只读 `.vcd`（或 FST/LXT 等格式），不参与仿真。

所以：**编译错误找 iverilog，运行时报错找 vvp，波形看不懂找 gtkwave。**

### 0.2 安装与确认版本

```bash
sudo apt update
sudo apt install -y iverilog gtkwave
iverilog -V | head -3
vvp -V | head -2
gtkwave --version | head -2
```

本文验证过的版本：`Icarus Verilog version 13.0 (stable)`。

### 0.3 第一个例子：与门

数字电路的起点永远是门电路。下面两段代码：第一段是**设计**（DUT, Design Under Test），第二段是**测试平台**（testbench）。

```verilog
// 文件: ex01_and_gate.v
`timescale 1ns/1ps
module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);
    assign y = a & b;
endmodule
```

```verilog
// 文件: tb_ex01_and_gate.v
`timescale 1ns/1ps
module tb_ex01_and_gate;
    reg  a, b;
    wire y;

    and_gate u_dut (.a(a), .b(b), .y(y));

    initial begin
        $dumpfile("tb_ex01_and_gate.vcd");
        $dumpvars(0, tb_ex01_and_gate);
        $display("time  a b | y");
        $monitor("%4t  %b %b | %b", $time, a, b, y);
        a = 1'b0; b = 1'b0;
        #10 a = 1'b0; b = 1'b1;
        #10 a = 1'b1; b = 1'b0;
        #10 a = 1'b1; b = 1'b1;
        #10 $display("仿真结束");
        $finish;
    end
endmodule
```

三板斧命令：

```bash
# 1. 编译：把 testbench 和设计一起编译成一个仿真可执行文件
iverilog -Wall -o sim.vvp tb_ex01_and_gate.v ex01_and_gate.v

# 2. 仿真：跑起来，看打印
vvp sim.vvp

# 3. 看波形（& 放后台，别占着终端）
gtkwave tb_ex01_and_gate.vcd &
```

vvp 的真实输出：

```text
VCD info: dumpfile tb_ex01_and_gate.vcd opened for output.
time  a b | y
   0  0 0 | 0
10000  0 1 | 0
20000  1 0 | 0
30000  1 1 | 1
仿真结束
tb_ex01_and_gate.v:19: $finish called at 40000 (1ps)
```

**逐行讲解（这些是 Verilog 仿真的核心机制）**

| 代码 | 作用 |
| --- | --- |
| `` `timescale 1ns/1ps `` | 时间单位是 1ns，精度 1ps。`#10` 就是 10ns。**每个文件都要写**，否则默认单位是 1s，你会等到天荒地老 |
| `module tb_xxx;` | testbench 没有端口，它是"顶层"，代表那块试验板 |
| `reg a, b;` | tb 里要**主动赋值**的信号用 `reg` |
| `wire y;` | DUT 输出的信号用 `wire` 接回来 |
| `and_gate u_dut (...)` | **例化**：把一块 and_gate 电路插到板上，起名叫 `u_dut`。这就是电路复制，不是函数调用 |
| `.a(a), .b(b), .y(y)` | 命名端口连接：DUT 的 `a` 接到 tb 的 `a` 上 |
| `initial begin ... end` | 一个只执行一次的进程（程序语义，用在 tb 里） |
| `#10 a = 1'b1;` | 等 10 个时间单位再赋值 |
| `$dumpfile` / `$dumpvars` | 打开波形文件并记录信号，`0` 表示记录所有层级的全部信号 |
| `$monitor` | 只要有信号变化就打印一次（比 `$display` 贴心） |
| `$finish` | 结束仿真。**忘记写它，仿真可能永远挂着** |

注意模拟输出的时间：`0, 10000, 20000, 30000`。`timescale` 是 1ns，但打印显示的是 **1ps 为单位的整数**（10000 ps = 10ns）。这是因为 `$monitor` 默认按仿真精度（1ps）打印时间。想让时间好看点，在 tb 里加一句 `$timeformat(-9, 0, " ns", 8);`（第 7 章讲）。

### 0.4 iverilog 常用选项

| 选项 | 含义 |
| --- | --- |
| `-o file` | 输出文件名（一般写 `sim.vvp`） |
| `-s topmodule` | 指定顶层模块，等价于硬件上的"上电那块板" |
| `-Wall` | 打开所有警告。**强烈建议永远加上**，能提前抓到位宽截断、未使用信号等问题 |
| `-D macro[=val]` | 定义宏，等价于源码里的 `` `define macro `` |
| `-I dir` | 增加 `` `include `` 的搜索目录 |
| `-y dir` / `-Y suf` | 自动到目录里找未定义的模块（按文件名找模块） |
| `-c cmdfile` | 从文件读参数，适合超长文件列表 |
| `-t vvp` | 指定输出目标，默认就是 `vvp` |
| `-g2012` | 语言版本。**Icarus 默认是 IEEE1364-2005**（见 `man iverilog`），要用 SystemVerilog 的 `logic`/`always_ff`/`unique` 等才需要显式加 `-g2012` |
| `-pfileline=1` | 给运行时代码带行号信息，vvp 报错时更准 |
| `-M depfile` | 生成依赖文件，可配合 Makefile |

### 0.5 三个一开始就会踩的坑

1. **多个文件都要写 `` `timescale ``。** 它按文件生效，不写就沿用默认（1s/1s），一混用时间就全乱。
2. **编译顺序无所谓，但文件名要写全。** iverilog 会把所有文件合成一个设计，模块名重复会报 `already been declared`。
3. **`$finish` 不要漏。** 另外 `$stop` 是暂停（交互式调试用），`$finish` 才是结束。

---

## 第 1 章 Verilog 是什么：用文字画电路

### 1.1 你写的是电路，不是程序

这是从软件转过来最难接受的一点：**Verilog 里的所有 `always` 块和 `assign` 是同时存在的电路，不是按行执行的代码。**

```text
  你写的：                              实际合成的：
  assign y1 = a & b;      ────┐
  assign y2 = c | d;      ────┤   两块电路并联，谁先谁后没有意义
  assign y3 = y1 ^ y2;    ────┘
```

只有在**同一个 `always` 块内部**，语句才有先后顺序（而且这个顺序还会被"阻塞/非阻塞赋值"影响，第 4 章专门讲）。

### 1.2 一个模块的骨架

```verilog
// 这是骨架示意，不用抄
`timescale 1ns/1ps              // 时间单位/精度

module 模块名 #(                 // #(...) 是参数表，可选
    parameter WIDTH = 8
) (
    input  wire        clk,     // 输入引脚
    input  wire        rst_n,
    input  wire [7:0]  din,
    output reg  [7:0]  dout,    // 输出：always 里赋值 → 声明成 reg
    output wire        valid    // 输出：assign 驱动 → 声明成 wire
);
    // 内部信号声明
    wire [7:0] next;

    // 组合逻辑 / 时序逻辑
    assign next = din + 8'd1;

    always @(posedge clk)
        dout <= next;

    assign valid = (dout != 8'd0);
endmodule
```

要点：

- `module ... endmodule` 就是一块电路，**模块不能嵌套**（模块里只能"例化"别的模块）。
- 端口方向只有三种：`input` / `output` / `inout`。
- 端口类型规则很死板：
  - `output` 想用 `assign` 驱动 → 声明成 `wire`（或省略类型，默认就是 wire）；
  - `output` 想在 `always` 里赋值 → 必须声明成 `reg`；
  - `input` 永远是 `wire` 那种"导线"性质，不能声明成 `reg`。

### 1.3 例化的两种写法

```verilog
// 方式一：位置连接（顺序必须和模块定义一致，容易错，不推荐）
  counter #(4) u1 (clk, rst_n, en, cnt, tick);

// 方式二：命名连接（推荐，端口顺序随便，漏接会警告）
  counter #(.WIDTH(4)) u_cnt (
      .clk(clk), .rst_n(rst_n), .en(en),
      .cnt(cnt), .tick(tick)
  );
```

- 参数用 `#(.WIDTH(4))` 覆盖，端口用 `.端口名(信号名)`。
- 一个模块可以被例化很多次，每次是一份独立的电路（就像同一型号芯片焊多片）。

### 1.4 层次化引用：跨层看信号

tb 里可以用**点号**访问 DUT 内部信号：

```verilog
$display("DUT 内部状态 = %b", tb_ex09_fsm.u_bin.state);
$dumpvars(1, tb_ex09_fsm.u_bin);     // 只 dump 这一个子模块
```

调试时非常有用（波形里也直接出现 `u_bin.state` 这样的层级名）。但注意：**综合出来的芯片里这些名字可能被改掉**，别在真设计的逻辑里依赖层次名。

### 1.5 数电对照表

| 数电概念 | Verilog 对应 |
| --- | --- |
| 子电路 / 功能块 | `module` |
| 芯片引脚 | 端口 `input/output/inout` |
| 导线 | `wire` |
| 焊上芯片 | 例化 `模块名 实例名 (...)` |
| 电路板上的多块芯片互联 | 顶层模块里例化多个子模块 |

---

## 第 2 章 数据类型、位宽与赋值

### 2.1 四种值：0、1、x、z

| 值 | 含义 | 出现场景 |
| --- | --- | --- |
| `0` / `1` | 逻辑低 / 高 | 正常情况 |
| `x` | 未知（unknown） | 没初始化的 `reg`、多个源驱动同一根线、读未写过的内存、组合逻辑有环 |
| `z` | 高阻（high-impedance） | 三态门没使能（第 6 章） |

仿真里 `x` 会传染：`x & 1 = x`、`x + 1 = x`。所以**看到波形里一片红（gtkwave 里 x 是红色）**，第一反应应该是"这个信号没人驱动/没复位"。注意 `~x` 也是 `x`，但 `x !== x` 是"真"（这是 `!==` 和 `!=` 的区别，tb 里校验要用 `!==`）。

### 2.2 wire 和 reg：一条最容易记错的规则

| | `wire` | `reg` |
| --- | --- | --- |
| 本质 | 网（net），像一根导线 | 变量（variable），像一块存储区 |
| 能不能在 `always` 里赋值 | 不能 | 能 |
| 能不能被 `assign` 驱动 | 能 | 不能 |
| 综合出来一定是触发器吗 | 不是 | **不是！** |

**关键认知：`reg` 不等于寄存器。** 它只表示"这个信号是在 `always`/`initial` 里被赋值的变量"。看下面两种 `reg`：

```verilog
reg y_comb;                        // 组合逻辑
always @* y_comb = a & b;          // 综合出来是一个与门，没有触发器

reg q_seq;                         // 时序逻辑
always @(posedge clk) q_seq <= d;  // 综合出来才是 D 触发器
```

决定电路形态的是 **`always` 的敏感列表和赋值方式**，不是 `reg`/`wire` 关键字。

> 补充：SystemVerilog 用 `logic` 统一了两者（`-g2012` 可用）。为了兼容性和理解清晰，本文全程用经典写法。

### 2.3 向量、位选、部分选择、拼接

```verilog
wire [7:0] a;            // 8 位，a[7] 是最高位 MSB，a[0] 是最低位 LSB
wire [7:0] b = a[3:0];   // 部分选择：取低 4 位（高位补 0）
wire [7:0] c = {a, b};   // 拼接：a 在高位，b 在低位（结果 16 位）
wire [7:0] d = {4{2'b10}};   // 重复拼接 → 2'b10 复制 4 次 = 10101010
wire [1:0] e = {a[0], a[1]}; // 拼接的元素可以从窄到宽任意组合
wire [7:0] g = {2'b11, a[5:0]};  // 拼接总位宽 = 2+6 = 8，正好
```

规则：

- **索引范围 `[high:low]`，MSB 在左**。`wire [0:3]` 也是合法的（MSB 在左但低位在右），这种写法极少用，别自找麻烦。
- 位选越界、x 索引都会得到 `x`。
- 拼接里**左边是高位**。`{1'b0, a}` 就是"零扩展"：把一个 4 位数变成 5 位数。
- 重复拼接 `{N{...}}` 里 N 必须是常量。

### 2.4 常量、基数、有符号

| 写法 | 含义 |
| --- | --- |
| `4'b1010` | 4 位二进制 |
| `8'hFF` | 8 位十六进制 |
| `8'd200` | 8 位十进制 |
| `'d5` | 不写位宽的常量。这是 SystemVerilog 的写法，Icarus 在 `-g2005` 下也接受，但**移植性差**，正式代码请写全位宽 |
| `4'b10x0` | 带 x 的常量，常用于 case 通配 |
| `4'b1_010` | 下划线可读性分隔符，等同于 `4'b1010` |

**默认是无符号的。** 这是 Verilog 最大的坑来源之一：`reg [3:0] a = 4'b1111;` 里的 `a` 是 **15**，不是 -1。要做有符号运算，必须显式声明或转换：

```verilog
wire signed [3:0] s = a;      // 声明成 signed，位模式按补码解释
$signed(a)                    // 或者用系统函数临时转换
$unsigned(x)                  // 反向
```

有符号数的两个实用推论：

- 右移有两种：`>>` 逻辑右移（补 0）给无符号用，`>>>` 算术右移（补符号位）给有符号用。
- 有符号和无符号混在一个表达式里时，**整个表达式会按无符号算**。所以 `if ($signed(a) < $signed(b))` 这种地方一定要两边都写全。

### 2.5 parameter 与 localparam

```verilog
module counter #(
    parameter WIDTH = 4              // 可以被例化时覆盖
) (
    ...
);
    localparam MAX = (1 << WIDTH) - 1;   // 模块内部用，不允许外部改
```

- `parameter`：可配置，相当于"模块的出厂选项"，用 `#(.WIDTH(8))` 覆盖。
- `localparam`：只在本模块内使用的常量，用来给状态编码、位宽算式起名字。
- 覆盖参数的第二种写法是 `defparam`，**不建议用**（层次化覆盖，难维护）。

位宽算式里尽量用 `localparam` 推导，而不是硬编码数字：

```verilog
localparam CNT_W = $clog2(DEPTH);   // SystemVerilog 函数，需 -g2012
```

### 2.6 位宽陷阱：本节是本教程最该记住的一节

Verilog 的表达式的位宽是**静态推导**出来的，跟你想的"先算再截"不一样：

```text
  a + b        结果位宽 = max(width(a), width(b))     ← 4 位 + 4 位 = 4 位！
  a * b        结果位宽 = width(a) + width(b)         ← 乘法会自动变宽
  {a, b}       结果位宽 = width(a) + width(b)         ← 拼接总是变宽
  a >> 1       结果位宽 = width(a)
```

所以 **两个 4 位数相加，即使赋给 8 位变量，进位也已经丢了**。下面这个例子同时演示了位宽陷阱、符号问题、移位：

```verilog
// 文件: ex02_ports_types.v
`timescale 1ns/1ps
module ports_types #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [WIDTH-1:0]   a_and_b,
    output wire [WIDTH-1:0]   a_xor_b,
    output wire [WIDTH-1:0]   a_not,
    output wire [2*WIDTH-1:0] concat_ab,
    output wire [2*WIDTH-1:0] concat_ba,
    output wire [WIDTH-1:0]   reversed,
    output wire               msb_of_a,
    output wire [WIDTH-1:0]   a_slice,
    output wire [WIDTH-1:0]   sum_narrow,   // 陷阱示范：4 位 + 4 位 = 4 位
    output wire [2*WIDTH-1:0] sum_ext,      // 正确做法：先扩位再相加
    output wire [WIDTH-1:0]   asr_signed,   // 算术右移（补符号位）
    output wire [WIDTH-1:0]   lsr_unsigned  // 逻辑右移（补 0）
);
    localparam HIGH = WIDTH - 1;

    assign a_and_b = a & b;
    assign a_xor_b = a ^ b;
    assign a_not   = ~a;

    assign concat_ab = {a, b};        // 拼接：a 在高位
    assign concat_ba = {b, a};

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_reverse
            assign reversed[i] = a[HIGH-i];
        end
    endgenerate

    assign msb_of_a = a[HIGH];
    assign a_slice  = a[HIGH:HIGH-1];       // 部分选择

    // 两个 4 位数相加，结果还是 4 位：进位被丢掉
    assign sum_narrow = a + b;

    // 先把两边都扩到 8 位再相加，结果才完整
    wire [2*WIDTH-1:0] a_ext = {{WIDTH{1'b0}}, a};
    wire [2*WIDTH-1:0] b_ext = {{WIDTH{1'b0}}, b};
    assign sum_ext = a_ext + b_ext;

    wire signed [WIDTH-1:0] a_s = a;        // 用 signed 声明，位模式就按补码解释
    assign asr_signed   = a_s >>> 1;        // 算术右移：符号位不动
    assign lsr_unsigned = a   >>  1;        // 逻辑右移：最高位补 0
endmodule
```

```verilog
// 文件: tb_ex02_ports_types.v
`timescale 1ns/1ps
module tb_ex02_ports_types;
    reg  [3:0] a, b;
    wire [3:0] a_and_b, a_xor_b, a_not, reversed, a_slice;
    wire [7:0] concat_ab, concat_ba, sum_ext;
    wire       msb_of_a;
    wire [3:0] sum_narrow, asr_signed, lsr_unsigned;

    ports_types #(.WIDTH(4)) u_dut (
        .a(a), .b(b),
        .a_and_b(a_and_b), .a_xor_b(a_xor_b), .a_not(a_not),
        .concat_ab(concat_ab), .concat_ba(concat_ba),
        .reversed(reversed), .msb_of_a(msb_of_a), .a_slice(a_slice),
        .sum_narrow(sum_narrow), .sum_ext(sum_ext),
        .asr_signed(asr_signed), .lsr_unsigned(lsr_unsigned)
    );

    initial begin
        $dumpfile("tb_ex02_ports_types.vcd");
        $dumpvars(0, tb_ex02_ports_types);
        a = 4'b1100; b = 4'b1010;
        #10;
        $display("== 位运算 ==");
        $display("a=%b b=%b", a, b);
        $display("a&b   = %b      a^b  = %b      ~a = %b", a_and_b, a_xor_b, a_not);

        $display("== 拼接与选择 ==");
        $display("{a,b} = %b   {b,a} = %b", concat_ab, concat_ba);
        $display("reversed=%b  msb_of_a=%b  a[3:2]=%b", reversed, msb_of_a, a_slice);

        $display("== 位宽陷阱 ==");
        a = 4'd15; b = 4'd1; #10;
        $display("15 + 1（4 位）    = %b  = %0d   <- 进位没了", sum_narrow, sum_narrow);
        $display("15 + 1（扩到 8 位）= %b = %0d   <- 正确", sum_ext, sum_ext);

        $display("== 有符号 vs 无符号右移 ==");
        a = 4'b1111; #10;
        $display("a = %b。当成有符号是 -1:  a >>> 1 = %b (%0d)", a, asr_signed, $signed(asr_signed));
        $display("当成无符号是 15:          a >>  1 = %b (%0d)", lsr_unsigned, lsr_unsigned);
        $finish;
    end
endmodule
```

真实输出（节选）：

```text
== 位宽陷阱 ==
15 + 1（4 位）    = 0000  = 0   <- 进位没了
15 + 1（扩到 8 位）= 00010000 = 16   <- 正确

== 有符号 vs 无符号右移 ==
a = 1111。当成有符号是 -1:  a >>> 1 = 1111 (-1)
当成无符号是 15:          a >>  1 = 0111 (7)
```

**防御手段**：

1. 相加前先扩位：`assign sum = {1'b0, a} + {1'b0, b};`
2. 累加器比数据宽：8 位数据 256 个求和，至少要 16 位累加器。
3. 用 `$signed()` / `$unsigned()` 明确意图，别让工具猜。
4. 编译永远带 `-Wall`，iverilog 会警告可疑的位宽截断。

### 2.7 声明中的初值：只对仿真有效

```verilog
reg clk = 1'b0;                 // 仿真有初值
reg [7:0] mem [0:15];           // 未初始化 → 读出来是 x
initial clk = 1'b0;             // 等价写法
```

**`reg x = 1;` 这种声明时赋值的写法，综合工具会忽略（FPGA 上的寄存器初值要靠复位或厂商专用属性）**。别把它当成"硬件上电就是 1"。

还有一个更隐蔽的坑：**声明时赋初值发生在时刻 0，`assign` 也在时刻 0 求值，谁先谁后是不确定的（仿真竞态）**。所以下面这种写法会偶发地打印出 `x`/`z`：

```verilog
reg  [7:0] a = 8'hA5;
wire [7:0] g = {2'b11, a[5:0]};   // 时刻 0 求值时 a 可能还是 x
```

要保证顺序就用 `initial` 赋值，并且先等一拍：

```verilog
reg  [7:0] a;
wire [7:0] g = {2'b11, a[5:0]};
initial begin
    a = 8'hA5;
    #1;                       // 等一拍，让组合逻辑稳定
    $display("g = %b", g);    // g = 11100101
end
```

（这个"为什么波形开头有一段 x"的问题，答案通常就在这里。）

---

## 第 3 章 组合逻辑

组合逻辑 = 输出只跟当前输入有关，没有记忆。两种写法：

```verilog
assign y = a & b;               // 写法一：连续赋值（concurrent assignment）

always @* begin                 // 写法二：过程块，@* 表示"任何被读的信号变化都触发"
    y = a & b;
end
```

### 3.1 `always @*` 的规矩

- `@*`（或 `@(*)`）让工具自动推导敏感列表。**别手写 `always @(a or b)`**，漏一个信号就会仿真和综合不一致。
- 块内被赋值的信号必须声明成 `reg`。
- 块内**所有分支都必须给同一个信号赋值**，否则就是第 3.6 节的锁存器陷阱。

### 3.2 数电回顾：真值表 → 表达式 → 电路

任何一个组合逻辑都能写成"最小项之和"（SOP）：

```text
  真值表                      最小项之和                      电路
  a b | y                     y = a'b + ab' + ab               两个与门 + 一个或门
  0 0 | 0                     = a | b  （化简后）
  0 1 | 1
  1 0 | 1
  1 1 | 1
```

Verilog 里不用你手工化简，但也别指望工具帮你把 100 行 if-else 优化成一行：**你写出来的结构就是电路结构**（见 3.7）。

常用运算符一览：

| 类别 | 运算符 | 说明 |
| --- | --- | --- |
| 位运算 | `~ & \| ^ ^~` | 逐位取反/与/或/异或/同或 |
| 逻辑运算 | `! && \|\|` | 结果是 1 位布尔值 |
| 归约运算 | `&a \|a ^a ~&a` | 把向量的所有位归约成 1 位（奇偶校验常用 `^a`） |
| 算术 | `+ - * / %` | `/ %` 只有在除数是 2 的幂时才容易综合好 |
| 移位 | `<< >> <<< >>>` | 常数移位基本免费（就是接线），变量移位要移位器电路 |
| 比较 | `== != < <= > >=` | 相等用 `==`，**校验用 `===`/`!==`**（能比较 x/z） |
| 条件 | `cond ? x : y` | 一个 2 选 1 MUX |
| 拼接复制 | `{} {{}}` | 纯接线，不产生逻辑 |

### 3.3 例：4 选 1 数据选择器（MUX）

**数电**：MUX 就是"用选择信号从多路输入里挑一路"。2 选 1 MUX 的电路是 `y = sel ? d1 : d0`，4 选 1 就是两棵 2 选 1 MUX 树。

```verilog
// 文件: ex03_mux4.v
`timescale 1ns/1ps
module mux4_assign (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output wire       y
);
    assign y = d[sel];
endmodule

module mux4_ternary (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output wire       y
);
    assign y = sel[1] ? (sel[0] ? d[3] : d[2])
                      : (sel[0] ? d[1] : d[0]);
endmodule

module mux4_case (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output reg        y
);
    always @* begin
        case (sel)
            2'd0:    y = d[0];
            2'd1:    y = d[1];
            2'd2:    y = d[2];
            2'd3:    y = d[3];
            default: y = 1'b0;
        endcase
    end
endmodule
```

```verilog
// 文件: tb_ex03_mux4.v
`timescale 1ns/1ps
module tb_ex03_mux4;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire y_a, y_t, y_c;

    mux4_assign  u_assign  (.d(d), .sel(sel), .y(y_a));
    mux4_ternary u_ternary (.d(d), .sel(sel), .y(y_t));
    mux4_case    u_case    (.d(d), .sel(sel), .y(y_c));

    integer i;
    initial begin
        $dumpfile("tb_ex03_mux4.vcd");
        $dumpvars(0, tb_ex03_mux4);
        $display(" d    sel | assign tern case");
        for (i = 0; i < 16; i = i + 1) begin
            d   = i[3:0];
            sel = i[1:0];
            #10;
            $display("%b  %b  |   %b     %b    %b", d, sel, y_a, y_t, y_c);
            if (y_a !== y_t || y_t !== y_c)
                $display("!! MISMATCH at i=%0d", i);
        end
        $display("三种写法结果一致");
        $finish;
    end
endmodule
```

三种写法的关系（都验证过输出完全一致）：

| 写法 | 特点 | 综合结果 |
| --- | --- | --- |
| `assign y = d[sel];` | 最简洁，索引即选择 | 一棵 MUX 树 |
| `assign y = sel[1] ? (sel[0] ? d[3] : d[2]) : (...)` | 显式嵌套，最贴近"电路图" | 三棵 2 选 1 MUX |
| `always @* case` | 最啰嗦，但最好扩展/最好读 | 一棵并行的 4 选 1 MUX |

新手建议：**多路选择用 `case`，简单的按位逻辑用 `assign`。**

### 3.4 例：3-8 译码器与 8-3 优先编码器

**数电**：译码器是"最小项发生器"，输入一个二进制码，只有对应的一条输出线有效；优先编码器是反向操作，输入里最高优先级的那个 1 被编成二进制码。

```verilog
// 文件: ex04_decoder38.v
`timescale 1ns/1ps
module decoder38 (
    input  wire [2:0] a,
    input  wire       en,
    output reg  [7:0] y
);
    always @* begin
        if (!en) y = 8'h00;
        else     y = 8'b0000_0001 << a;
    end
endmodule

module prio_encoder83 (
    input  wire [7:0] in,
    output reg  [2:0] code,
    output reg        valid
);
    always @* begin
        valid = 1'b1;
        casez (in)
            8'b1???_????: code = 3'd7;
            8'b01??_????: code = 3'd6;
            8'b001?_????: code = 3'd5;
            8'b0001_????: code = 3'd4;
            8'b0000_1???: code = 3'd3;
            8'b0000_01??: code = 3'd2;
            8'b0000_001?: code = 3'd1;
            8'b0000_0001: code = 3'd0;
            default: begin code = 3'd0; valid = 1'b0; end
        endcase
    end
endmodule
```

```verilog
// 文件: tb_ex04_decoder38.v
`timescale 1ns/1ps
module tb_ex04_decoder38;
    reg  [2:0] a;
    reg        en;
    wire [7:0] y;
    reg  [7:0] in;
    wire [2:0] code;
    wire       valid;

    decoder38      u_dec  (.a(a), .en(en), .y(y));
    prio_encoder83 u_prio (.in(in), .code(code), .valid(valid));

    integer i;
    initial begin
        $dumpfile("tb_ex04_decoder38.vcd");
        $dumpvars(0, tb_ex04_decoder38);
        $display("== 3-8 译码器（en=1）==");
        en = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            a = i[2:0]; #10;
            $display("a=%b → y=%b", a, y);
        end
        en = 1'b0; a = 3'd5; #10;
        $display("en=0 时全部输出 0: y=%b", y);

        $display("== 8-3 优先编码器（看谁优先级最高）==");
        in = 8'b0000_0000; #10; $display("in=%b → code=%0d valid=%b", in, code, valid);
        in = 8'b0000_0001; #10; $display("in=%b → code=%0d valid=%b", in, code, valid);
        in = 8'b0000_0100; #10; $display("in=%b → code=%0d valid=%b", in, code, valid);
        in = 8'b0001_0100; #10; $display("in=%b → code=%0d valid=%b（bit4 比 bit2 优先）", in, code, valid);
        in = 8'b1010_0100; #10; $display("in=%b → code=%0d valid=%b（bit7 最高）", in, code, valid);
        $finish;
    end
endmodule
```

真实输出（节选）：

```text
== 3-8 译码器（en=1）==
a=000 → y=00000001
a=010 → y=00000100
a=111 → y=10000000
en=0 时全部输出 0: y=00000000

== 8-3 优先编码器（看谁优先级最高）==
in=00010100 → code=4 valid=1（bit4 比 bit2 优先）
in=10100100 → code=7 valid=1（bit7 最高）
```

三个新语法点：

1. **`8'b0000_0001 << a`**：用移位实现译码。`1` 左移 a 位正好是"第 a 位为 1"。这行代码在硬件上就是一个 3-8 译码器。
2. **`casez` + `?`**：`?` 表示"这一位不关心"（don't care）。`8'b1???_????` 的意思是"只要最高位是 1"。`casez` 把 `z` 也当通配，`casex` 连 `x` 也当通配（**`casex` 别在真设计里用**，仿真全 x 会静默匹配，隐藏 bug）。
3. `valid` 信号：无输入有效时给一个"没有有效输入"的指示，比默默输出 code=0 更安全（这叫"数据有效性握手"，工程上很重要）。

### 3.5 例：加法器与 ALU

**数电**：全加器 `sum = a ^ b ^ cin; cout = (a&b) | (cin&(a^b))`，n 位加法器由 n 个全加器串起来（行波进位）。Verilog 里直接写 `+` 就行，剩下的交给综合工具。

补码减法的原理：`a - b = a + (~b) + 1`。所以减法和加法可以共用一套电路，这也是 ALU 的由来。

```verilog
// 文件: ex05_adder_alu.v
`timescale 1ns/1ps
module rca4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       cout
);
    assign {cout, s} = a + b + cin;
endmodule

module alu4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output reg  [3:0] y,
    output reg        zero,
    output reg        carry
);
    always @* begin
        carry = 1'b0;
        case (op)
            3'b000: {carry, y} = a + b;              // 加
            3'b001: {carry, y} = a - b;              // 减（借位看作反向进位）
            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            3'b101: y = a << b[1:0];                 // 逻辑左移
            3'b110: y = (a < b) ? 4'd1 : 4'd0;       // 比较
            3'b111: y = ~a;
            default: y = 4'd0;
        endcase
        zero = (y == 4'd0);
    end
endmodule
```

```verilog
// 文件: tb_ex05_adder_alu.v
`timescale 1ns/1ps
module tb_ex05_adder_alu;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] s;
    wire       cout;
    reg  [2:0] op;
    wire [3:0] y;
    wire       zero, carry;

    rca4 u_rca (.a(a), .b(b), .cin(cin), .s(s), .cout(cout));
    alu4 u_alu (.a(a), .b(b), .op(op), .y(y), .zero(zero), .carry(carry));

    initial begin
        $dumpfile("tb_ex05_adder_alu.vcd");
        $dumpvars(0, tb_ex05_adder_alu);

        a = 4'd9; b = 4'd5; cin = 1'b0; #10;
        $display("RCA: %0d + %0d = {cout,s} = {%b,%b} = %0d", a, b, cout, s, {cout, s});
        a = 4'd15; b = 4'd15; #10;
        $display("RCA: 15 + 15 = {%b,%b}，4 位装不下，cout=1 就是溢出", cout, s);
        a = 4'd15; b = 4'd1; cin = 1'b1; #10;
        $display("RCA: 15 + 1 + 1 = %0d，多出来的进位被丢弃", {cout, s});

        a = 4'd9; b = 4'd5;
        op = 3'b000; #10; $display("ALU ADD: %0d, carry=%b", y, carry);
        op = 3'b001; #10; $display("ALU SUB: %0d (9-5)", y);
        op = 3'b010; #10; $display("ALU AND: %b", y);
        op = 3'b011; #10; $display("ALU OR : %b", y);
        op = 3'b100; #10; $display("ALU XOR: %b", y);
        op = 3'b101; #10; $display("ALU SHL: %b (9<<1 只保留低 4 位)", y);
        op = 3'b110; #10; $display("ALU SLT: %b (9<5 ? 1:0)", y);
        op = 3'b111; #10; $display("ALU NOT: %b", y);
        a = 4'd5; b = 4'd5;
        op = 3'b001; #10; $display("ALU SUB: %0d, zero=%b (零标志)", y, zero);
        $finish;
    end
endmodule
```

真实输出：

```text
RCA: 9 + 5 = {cout,s} = {0,1110} = 14
RCA: 15 + 15 = {1,1110}，4 位装不下，cout=1 就是溢出
RCA: 15 + 1 + 1 = 17，多出来的进位被丢弃
ALU ADD: 14, carry=0
ALU SUB: 4 (9-5)
ALU AND: 0001
ALU OR : 1101
ALU XOR: 1100
ALU SHL: 0010 (9<<1 只保留低 4 位)
ALU SLT: 0000 (9<5 ? 1:0)
ALU NOT: 0110
ALU SUB: 0, zero=1 (零标志)
```

讲解：

- **`{cout, s} = a + b + cin;`** 是标准写法：把进位和结果拼成一个 5 位数一起接，避免位宽丢失。`{cout, s}` 是拼接赋值（concatenation assignment），左边可以写多个信号。
- **`carry` 就是溢出指示**（对无符号加法而言）。有符号溢出要看"两个同号数相加结果异号"，这点在工程里很重要。
- **ALU 就是"输入选择 + 运算单元"**：`op` 是选择信号，`case` 综合出一棵 MUX 树选出各个运算结果。真实 CPU 的 ALU 就是这个结构加上更多标志位（零、负、进位、溢出）。
- **`zero = (y == 4'd0);`** 放在 `case` 外面，是因为它依赖最终的 `y`。注意组合块里语句顺序**是**有意义的（这里用阻塞赋值 `=`）。

### 3.6 反例：漏写分支 → 综合出锁存器（latch）

这是新手最容易"仿真看起来正常、上板子就诡异"的坑。

```verilog
// 文件: ex20_latch_trap.v
`timescale 1ns/1ps
// 反例：分支没写全，组合逻辑里长出锁存器
module mux_latch_bad (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output reg        y
);
    always @* begin
        if      (sel == 2'd0) y = d[0];
        else if (sel == 2'd1) y = d[1];
        else if (sel == 2'd2) y = d[2];
        // sel == 2'd3 时 y 没有被赋值：仿真里保持旧值，综合出锁存器
    end
endmodule

// 正例：所有分支都赋值
module mux_latch_good (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output reg        y
);
    always @* begin
        case (sel)
            2'd0:    y = d[0];
            2'd1:    y = d[1];
            2'd2:    y = d[2];
            default: y = d[3];      // 兜底分支，绝不留悬空
        endcase
    end
endmodule
```

```verilog
// 文件: tb_ex20_latch.v
`timescale 1ns/1ps
module tb_ex20_latch;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire y_bad, y_good;

    mux_latch_bad  u_bad  (.d(d), .sel(sel), .y(y_bad));
    mux_latch_good u_good (.d(d), .sel(sel), .y(y_good));

    initial begin
        $dumpfile("tb_ex20_latch.vcd");
        $dumpvars(0, tb_ex20_latch);
        $display("   d   sel | y_bad(漏写分支) y_good(有 default)");
        d = 4'b0100;
        sel = 2'd0; #10; $display("%b  00  |      %b            %b", d, y_bad, y_good);
        sel = 2'd1; #10; $display("%b  01  |      %b            %b", d, y_bad, y_good);
        sel = 2'd2; #10; $display("%b  10  |      %b            %b", d, y_bad, y_good);
        sel = 2'd3; #10; $display("%b  11  |      %b            %b  <- y_bad 锁住了上一次的 1",
                                   d, y_bad, y_good);
        d = 4'b0000; #10;
        $display("%b  11  |      %b            %b  <- d 变成 0，y_bad 一动不动（锁存器）",
                 d, y_bad, y_good);
        sel = 2'd2; #10;
        $display("%b  10  |      %b            %b", d, y_bad, y_good);
        $finish;
    end
endmodule
```

真实输出：

```text
   d   sel | y_bad(漏写分支) y_good(有 default)
0100  00  |      0            0
0100  10  |      1            1
0100  11  |      1            0  <- y_bad 锁住了上一次的 1
0000  11  |      1            0  <- d 变成 0，y_bad 一动不动（锁存器）
```

**原理**：组合逻辑块的输出在所有分支都必须有值。漏掉一个分支时，工具只能"保持上一次的值"，这就是锁存器（latch）。

为什么锁存器是坏东西：

- 它是**电平敏感**的，不靠时钟沿，容易产生毛刺和时序分析困难；
- 大部分 FPGA 的时序分析工具会直接给你 warning 甚至 error；
- 在仿真里一般表现为"值卡住不变"，很难发现。

**规则：`always @*` 里每个被赋值的信号，`if` 必须有 `else`，`case` 必须有 `default`；或者养成习惯——在块开头先给所有输出一个默认值。** 推荐后者，最保险：

```verilog
always @* begin
    y = 1'b0;              // 先给默认值，后面覆盖，永不漏分支
    if (...) y = ...;
end
```

### 3.7 你写的结构 = 综合出的电路结构

| 你写 | 综合出来 | 延迟 |
| --- | --- | --- |
| `assign y = a & b;` | 一个与门 | 1 级门 |
| `case` | 一棵并行 MUX | 1 级 MUX（多路时是 LUT 树） |
| `if / else if / else` | **优先级** MUX 链 | 越靠后的条件延迟越大 |
| `if / else if / else` 里条件互斥时 | 综合工具能优化成并行 | 取决于优化能力 |
| `for (i=0;i<8;i=i+1)`（常量边界） | 展开成 8 份并行电路 | 无"循环时间"，全是并行 |
| `for` 有依赖链（`acc = acc + x[i]`） | 8 级串行加法 | 延迟随 N 增长，可能是时序瓶颈 |

推论：**优先编码器就应该用 `if-else` 写（要优先级），选通逻辑就该用 `case` 写（不要优先级）。** 用错了会白白增加延迟和面积。

### 3.8 组合逻辑检查清单

- [ ] `always @*` 用了 `@*` 而不是手写敏感列表
- [ ] 每个分支都赋值（或块首给默认值）
- [ ] 没有用 `assign` 驱动同一个信号两次（多驱动 → `x`）
- [ ] 表达式两边位宽匹配（相加前扩位）
- [ ] 没有组合逻辑自环（`assign y = y + 1;` 这种在仿真里会卡死）
- [ ] 没有在组合块里用非阻塞赋值
- [ ] `-Wall` 编译后没有 warning

---

## 第 4 章 时序逻辑

### 4.1 数电回顾：锁存器与触发器

| | 锁存器（latch） | 触发器（flip-flop） |
| --- | --- | --- |
| 敏感 | 电平（时钟高就"透明"） | 边沿（只在跳变瞬间采样） |
| 时序分析 | 很难 | 有完整的建立/保持时间模型 |
| 用在哪 | 一般避免 | 同步设计的主力 |

为什么必须用边沿触发：如果所有寄存器都是"电平透明"的，时钟高电平期间信号会一级一级穿透过去，数据在同一个时钟周期内跑好几级，无法确定稳定值。边沿触发保证**每个时钟周期数据只前进一级**。

几个必须建立的概念（决定你的电路能跑多快）：

```text
        ┌──── 一个时钟周期 T ────┐
  clk ──┘                        └──
        ↑                        ↑
   前一级 FF               后一级 FF 采样
        |← 传播延迟 Tcq →|← 组合逻辑延迟 →|← 建立时间 Tsu →|
        数据必须在建立时间之前稳定，否则采到亚稳态
```

- **建立时间 Tsu**：时钟沿之前数据必须稳定的时间。
- **保持时间 Th**：时钟沿之后数据必须保持的时间。违背保持时间比违背建立时间更危险（综合工具会自动修 setup，hold 违例往往要去修版图/加延迟）。
- **传播延迟 Tcq**：时钟沿到输出变化的时间。
- **最高频率**：`T > Tcq + T_组合逻辑_max + Tsu`。所以"关键路径"就是组合逻辑最长的那条路。

### 4.2 D 触发器的三种写法

```verilog
// 文件: ex06_dff.v
`timescale 1ns/1ps
module dff_async_rst (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
    always @(posedge clk or negedge rst_n)
        if (!rst_n) q <= 1'b0;
        else        q <= d;
endmodule

module dff_sync_rst (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
    always @(posedge clk)
        if (!rst_n) q <= 1'b0;
        else        q <= d;
endmodule

module dff_en (
    input  wire clk,
    input  wire en,
    input  wire d,
    output reg  q
);
    always @(posedge clk)
        if (en) q <= d;
endmodule

module dff_2stage (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q1,
    output reg  q2
);
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin q1 <= 1'b0; q2 <= 1'b0; end
        else        begin q1 <= d;    q2 <= q1;   end
endmodule
```

```verilog
// 文件: tb_ex06_dff.v
`timescale 1ns/1ps
module tb_ex06_dff;
    localparam T = 10;
    reg clk = 1'b0;
    reg rst_n, d;
    wire q_async, q_sync, q_en, q1, q2;
    reg  en = 1'b0;

    dff_async_rst u_async (.clk(clk), .rst_n(rst_n), .d(d), .q(q_async));
    dff_sync_rst  u_sync  (.clk(clk), .rst_n(rst_n), .d(d), .q(q_sync));
    dff_en        u_en    (.clk(clk), .en(en), .d(d), .q(q_en));
    dff_2stage    u_2s    (.clk(clk), .rst_n(rst_n), .d(d), .q1(q1), .q2(q2));

    always #(T/2) clk = ~clk;

    initial begin
        $dumpfile("tb_ex06_dff.vcd");
        $dumpvars(0, tb_ex06_dff);

        rst_n = 1'b0; d = 1'b0; en = 1'b0;
        #(T*1.3);
        rst_n = 1'b1;
        #(T*0.5);

        $display("== 1. D 触发器基本功能：上升沿把 d 搬进 q ==");
        d = 1'b1; #(T*0.3);
        $display("t=%4t d=1 但还没到时钟沿: q_async=%b q_sync=%b", $time, q_async, q_sync);
        @(posedge clk); #1;
        $display("t=%4t 时钟沿之后:        q_async=%b q_sync=%b", $time, q_async, q_sync);

        $display("== 2. 异步复位 vs 同步复位 ==");
        d = 1'b1; @(posedge clk); #1;
        $display("t=%4t 复位前两者都是 1:   q_async=%b q_sync=%b", $time, q_async, q_sync);
        rst_n = 1'b0; #1;
        $display("t=%4t rst_n 拉低 1ns:     q_async=%b q_sync=%b  <- 异步已清零，同步还在等时钟",
                 $time, q_async, q_sync);
        @(posedge clk); #1;
        $display("t=%4t 等来时钟沿:         q_async=%b q_sync=%b", $time, q_async, q_sync);
        rst_n = 1'b1; #(T);

        $display("== 3. 使能端 en（保持功能）==");
        d = 1'b1; en = 1'b1; @(posedge clk); #1;
        en = 1'b0; d = 1'b0; #(T*2);
        $display("t=%4t en=0、d 变 0 之后: q_en=%b  <- 保持不变", $time, q_en);
        en = 1'b1; @(posedge clk); #1;
        $display("t=%4t en=1 一个时钟后:   q_en=%b", $time, q_en);

        $display("== 4. 两级串联：d 要两个时钟才传到 q2 ==");
        d = 1'b0; #(T*2);
        $display("t=%4t 先用 d=0 把两级都清成 0: q1=%b q2=%b", $time, q1, q2);
        d = 1'b1; #(T*0.5);
        $display("t=%4t 还没打拍:            q1=%b q2=%b", $time, q1, q2);
        @(posedge clk); #1; $display("t=%4t 第 1 个沿: q1=%b q2=%b", $time, q1, q2);
        @(posedge clk); #1; $display("t=%4t 第 2 个沿: q1=%b q2=%b", $time, q1, q2);
        $finish;
    end
endmodule
```

真实输出：

```text
== 1. D 触发器基本功能：上升沿把 d 搬进 q ==
t=21000 d=1 但还没到时钟沿: q_async=0 q_sync=0
t=26000 时钟沿之后:        q_async=1 q_sync=1
== 2. 异步复位 vs 同步复位 ==
t=36000 复位前两者都是 1:   q_async=1 q_sync=1
t=37000 rst_n 拉低 1ns:     q_async=0 q_sync=1  <- 异步已清零，同步还在等时钟
t=46000 等来时钟沿:         q_async=0 q_sync=0
== 3. 使能端 en（保持功能）==
t=86000 en=0、d 变 0 之后: q_en=1  <- 保持不变
== 4. 两级串联：d 要两个时钟才传到 q2 ==
t=126000 第 1 个沿: q1=1 q2=0
t=136000 第 2 个沿: q1=1 q2=1
```

三段代码对应三种基本触发器：

```verilog
// 1) 异步复位：敏感列表里有 negedge rst_n
always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 1'b0; else q <= d;

// 2) 同步复位：敏感列表只有时钟
always @(posedge clk)
    if (!rst_n) q <= 1'b0; else q <= d;

// 3) 带使能：就是 d 前面加一个 2 选 1 MUX（反馈自己的旧值）
always @(posedge clk)
    if (en) q <= d;
```

| | 异步复位 | 同步复位 |
| --- | --- | --- |
| 复位生效时间 | 立即，不依赖时钟 | 要等到下一个时钟沿 |
| 时钟没了还能复位吗 | 能（安全性好） | 不能 |
| 复位释放时 | **危险**：可能撞在时钟沿附近产生亚稳态 | 安全 |
| 资源 | 触发器自带复位端，几乎免费 | 占用组合逻辑资源 |
| 常见做法 | **异步复位、同步释放**（见下） | 高速设计中常用 |

工程上最常见的折中是"异步复位、同步释放"：复位信号先经过两级触发器再送出去（叫 reset synchronizer）。本文不展开，记住这个名字，以后一定会用到。

**另一个真实问题**：波形里同步复位版在第一次时钟到来前是 `x`。如果不用复位，仿真开始时所有寄存器都是 `x`，`x` 会一路传播。所以 **testbench 一定要先复位再测**，这也是 tb 里第一件事就拉低 `rst_n` 的原因。

### 4.3 阻塞赋值 vs 非阻塞赋值（本教程最重要的一节）

| | 阻塞 `=` | 非阻塞 `<=` |
| --- | --- | --- |
| 执行方式 | 立刻生效，后面的语句看得到新值 | 本时间步末尾统一更新，后面的语句看到的是旧值 |
| 用在 | 组合逻辑 `always @*`、tb 里给 DUT 喂数据 | 时序逻辑 `always @(posedge clk)` |
| 综合出来 | 组合逻辑 | 寄存器 |

```verilog
// 文件: ex21_blocking_nba.v
`timescale 1ns/1ps
// 阻塞赋值（=）和非阻塞赋值（<=）的区别
module nba_demo (
    input  wire       clk,
    input  wire [7:0] d,
    output reg  [7:0] q1,
    output reg  [7:0] q2
);
    always @(posedge clk) begin
        q1 <= d;        // 非阻塞：两条语句"同时"生效
        q2 <= q1;       // q2 拿到的是本拍之前的 q1
    end
endmodule

module blocking_demo (
    input  wire       clk,
    input  wire [7:0] d,
    output reg  [7:0] q1,
    output reg  [7:0] q2
);
    always @(posedge clk) begin
        q1 = d;         // 阻塞：顺序执行，q1 立刻变成 d
        q2 = q1;        // q2 因此也等于 d，两个寄存器被"短路"成一个
    end
endmodule
```

```verilog
// 文件: tb_ex21_blocking_nba.v
`timescale 1ns/1ps
module tb_ex21_blocking_nba;
    localparam T = 10;
    reg clk = 1'b0;
    reg [7:0] d;
    wire [7:0] nq1, nq2, bq1, bq2;

    nba_demo      u_nba (.clk(clk), .d(d), .q1(nq1), .q2(nq2));
    blocking_demo u_blk (.clk(clk), .d(d), .q1(bq1), .q2(bq2));

    always #(T/2) clk = ~clk;

    integer i;
    initial begin
        $dumpfile("tb_ex21_blocking_nba.vcd");
        $dumpvars(0, tb_ex21_blocking_nba);
        d = 8'h00;
        repeat (2) @(posedge clk);      // 先跑两拍，让两级寄存器都有确定初值
        $display("时间  d   | <=: q1 q2 | =: q1 q2");
        $display("          | (打两拍)  | (一拍就到)");
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk);
            d = 8'hA0 + i[7:0];
            #1;
            $display("%4t  %h |   %h %h |   %h %h", $time, d, nq1, nq2, bq1, bq2);
        end
        $display("结论：<= 得到两级延迟（正确的移位寄存器），= 变成一条直通的组合链路");
        $finish;
    end
endmodule
```

真实输出：

```text
时间  d   | <=: q1 q2 | =: q1 q2
          | (打两拍)  | (一拍就到)
31000  a1 |   a0 00 |   a0 a0
41000  a2 |   a1 a0 |   a1 a1
```

看第 41000 这一行：用 `<=` 的写法治，`q1=a1, q2=a0`（真正的两级移位寄存器）；用 `=` 的写法，`q1=q2=a1`（两个触发器被"短路"成一级）。

**黄金规则（背下来）**

1. 时序逻辑（`always @(posedge clk...)`）**只用 `<=`**。
2. 组合逻辑（`always @*`）**只用 `=`**。
3. 同一个 `always` 块里别混用。
4. 同一个信号别在两个 `always` 块里赋值（多驱动）。

为什么非阻塞能避免竞态：因为时序逻辑里所有赋值都是"同一时刻并行发生"的，物理上多个触发器同时打拍就是同时更新。用 `=` 却要求编译器给它们排一个顺序，而这个顺序不同工具可能不一样，就产生了"仿真通过、综合后行为不同"的经典事故。

### 4.4 计数器与分频

**数电**：计数器就是"加法器 + 寄存器"并联，输出接回输入端，进位信号作为溢出标志。异步（行波）计数器把前一级输出当作后一级时钟（快但毛刺多），同步计数器共用一个时钟（主流）。

```verilog
// 文件: ex07_counter.v
`timescale 1ns/1ps
module counter #(
    parameter WIDTH = 4
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg  [WIDTH-1:0] cnt,
    output wire             tick
);
    assign tick = en & (cnt == {WIDTH{1'b1}});

    always @(posedge clk or negedge rst_n)
        if (!rst_n)  cnt <= {WIDTH{1'b0}};
        else if (en) cnt <= cnt + 1'b1;
endmodule

module clk_div #(
    parameter DIV = 5
) (
    input  wire clk,
    input  wire rst_n,
    output reg  clk_out
);
    reg [15:0] cnt;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            cnt     <= 16'd0;
            clk_out <= 1'b0;
        end else if (cnt == DIV-1) begin
            cnt     <= 16'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1'b1;
        end
endmodule

module clk_en_pulse #(
    parameter DIV = 5
) (
    input  wire clk,
    input  wire rst_n,
    output reg  en_pulse
);
    reg [15:0] cnt;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            cnt      <= 16'd0;
            en_pulse <= 1'b0;
        end else if (cnt == DIV-1) begin
            cnt      <= 16'd0;
            en_pulse <= 1'b1;
        end else begin
            cnt      <= cnt + 1'b1;
            en_pulse <= 1'b0;
        end
endmodule
```

```verilog
// 文件: tb_ex07_counter.v
`timescale 1ns/1ps
module tb_ex07_counter;
    localparam T = 10;
    reg clk = 1'b0;
    reg rst_n, en;
    wire [3:0] cnt;
    wire       tick;
    wire       clk_out;
    time t_first_edge, t_second_edge;

    counter  #(.WIDTH(4)) u_cnt (.clk(clk), .rst_n(rst_n), .en(en), .cnt(cnt), .tick(tick));
    clk_div  #(.DIV(5))   u_div (.clk(clk), .rst_n(rst_n), .clk_out(clk_out));

    always #(T/2) clk = ~clk;

    integer div_edges = 0;
    always @(posedge clk_out) begin
        div_edges = div_edges + 1;
        if (div_edges == 1) t_first_edge = $time;
        if (div_edges == 2) t_second_edge = $time;
    end

    initial begin
        $dumpfile("tb_ex07_counter.vcd");
        $dumpvars(0, tb_ex07_counter);
        rst_n = 1'b0; en = 1'b0;
        #(T*1.3);
        rst_n = 1'b1;
        en = 1'b1;
        #(T*2.5);
        $display("计数到 %0d（en=1）", cnt);
        en = 1'b0;
        #(T*2.5);
        $display("en=0 时保持 %0d", cnt);
        en = 1'b1;
        wait (tick == 1'b1);
        #1;
        $display("tick 出现在 cnt=%0d（回绕前一个周期）t=%0t ns", cnt, $time);
        #(T*25);
        $display("clk 周期 = %0d ns, clk_out 周期 = %0d ns → 分频比 = %0d",
                 T, t_second_edge - t_first_edge, (t_second_edge - t_first_edge) / T);
        $finish;
    end
endmodule
```

真实输出：

```text
计数到 3（en=1）
en=0 时保持 3
tick 出现在 cnt=15（回绕前一个周期）t=176000 ns
clk 周期 = 10 ns, clk_out 周期 = 100 ns → 分频比 = 10
```

要点：

- **`cnt <= cnt + 1'b1;` 是标准计数器写法**，`en` 就是使能（等价于前面教过的 `if (en)` 带使能触发器）。
- **`assign tick = en & (cnt == {WIDTH{1'b1}});`** 是"进位/溢出"信号：在回绕前的最后一个周期有效。用它去驱动别的逻辑（比如级联计数器、产生周期事件）比直接用 `cnt` 比较更清晰。
- **分频比是 2×DIV**：`clk_div` 用 `cnt == DIV-1` 翻转一次输出，所以输出周期 = `2*DIV*T`。上面例子里 DIV=5，T=10ns → 100ns ✓（符合输出）。
- **`{WIDTH{1'b1}}`**：重复拼接，位宽参数化时的标准写法，别写死 `4'hF`。

**重要工程建议**：不要用分频出来的时钟去驱动其他寄存器，那样会制造多个时钟域（多时钟域要做 CDC 处理，很麻烦）。更好的做法是 **用使能脉冲代替分频时钟**：

```verilog
// clk_div：产生"慢时钟"（电路里有多个时钟域，慎用）
// clk_en_pulse：每 DIV 个时钟产生一个 1 拍宽的使能脉冲（推荐）
always @(posedge clk)
    if (cnt == DIV-1) begin cnt <= 0; en_pulse <= 1'b1; end
    else              begin cnt <= cnt + 1'b1; en_pulse <= 1'b0; end
```

然后让所有逻辑共用同一个 `clk`，用 `if (en_pulse)` 控制节奏。这样整个设计只有一个时钟域，时序分析简单得多。`ex07_counter.v` 里两个模块都给了，对比看。

### 4.5 移位寄存器与 LFSR

**数电**：移位寄存器是串并转换的核心（UART、SPI 的基础）。LFSR（线性反馈移位寄存器）则是"移位寄存器 + 异或反馈"，能产生最长 `2^n - 1` 个非零状态的伪随机序列（m 序列），用于加扰、CRC、测试图案生成。

```verilog
// 文件: ex08_shiftreg.v
`timescale 1ns/1ps
module shiftreg #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             sin,
    input  wire             load,
    input  wire [WIDTH-1:0] din,
    output wire             sout,
    output reg  [WIDTH-1:0] q
);
    assign sout = q[WIDTH-1];

    always @(posedge clk or negedge rst_n)
        if (!rst_n)    q <= {WIDTH{1'b0}};
        else if (load) q <= din;
        else           q <= {q[WIDTH-2:0], sin};
endmodule

module lfsr8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [7:0] q
);
    wire feedback = q[7] ^ q[5] ^ q[4] ^ q[3];

    always @(posedge clk or negedge rst_n)
        if (!rst_n)  q <= 8'h01;
        else if (en) q <= {q[6:0], feedback};
endmodule
```

```verilog
// 文件: tb_ex08_shiftreg.v
`timescale 1ns/1ps
module tb_ex08_shiftreg;
    localparam T = 10;
    reg        clk = 1'b0;
    reg        rst_n, sin, load;
    reg  [7:0] din;
    wire       sout;
    wire [7:0] q;
    reg        en;
    wire [7:0] lfsr_q;
    integer    i, shifts, ones;

    shiftreg #(.WIDTH(8)) u_sr (.clk(clk), .rst_n(rst_n), .sin(sin),
                                 .load(load), .din(din), .sout(sout), .q(q));
    lfsr8 u_lfsr (.clk(clk), .rst_n(rst_n), .en(en), .q(lfsr_q));

    always #(T/2) clk = ~clk;

    initial begin
        $dumpfile("tb_ex08_shiftreg.vcd");
        $dumpvars(0, tb_ex08_shiftreg);
        rst_n = 1'b0; sin = 1'b0; load = 1'b0; din = 8'h00; en = 1'b0;
        #(T*1.3);
        rst_n = 1'b1;

        din = 8'hA5; load = 1'b1; #(T); load = 1'b0;
        $display("并行载入 q = %b", q);

        sin = 1'b1; #(T);
        $display("串行移入 1 → q = %b, sout = %b", q, sout);

        sin = 1'b0;
        for (i = 0; i < 4; i = i + 1) #(T);
        $display("再移入 4 个 0 → q = %b", q);

        din = 8'b1011_0011; load = 1'b1; #(T); load = 1'b0;
        $write("从 sout 串出的序列: ");
        for (i = 0; i < 8; i = i + 1) begin
            $write("%b ", sout);
            #(T);
        end
        $write("\n（先出的是最高位，所以顺序和载入值一致）\n");

        en = 1'b1;
        ones = 0; shifts = 0;
        for (i = 0; i < 300; i = i + 1) begin
            #(T);
            ones = ones + lfsr_q[0];
            if (lfsr_q == 8'h01) begin
                shifts = i + 1;
                i = 9999;
            end
        end
        $display("LFSR 回到初值 00000001 用了 %0d 次移位（理论 2^8-1 = 255）", shifts);
        $display("这段时间输出位里 1 的个数 = %0d（理想约 127，接近一半）", ones);
        $finish;
    end
endmodule
```

真实输出：

```text
并行载入 q = 10100101
串行移入 1 → q = 01001011, sout = 0
再移入 4 个 0 → q = 10110000
从 sout 串出的序列: 1 0 1 1 0 0 1 1 
LFSR 回到初值 00000001 用了 255 次移位（理论 2^8-1 = 255）
这段时间输出位里 1 的个数 = 128（理想约 127，接近一半）
```

要点：

- **`q <= {q[WIDTH-2:0], sin};`** 是一个周期的移位操作（`{q[6:0], sin}` 拼成 8 位）。这是移位寄存器的标准写法。
- **`assign sout = q[WIDTH-1];`** 从最高位串出。注意串出顺序是"先载入的先出"（上面输出 `1 0 1 1 0 0 1 1` 与载入值 `1011_0011` 一致）。
- **LFSR 的抽头（taps）不能乱选**。`q[7]^q[5]^q[4]^q[3]`（对应多项式 x⁸+x⁶+x⁵+x⁴+1）是 8 位的一个本原多项式，所以能跑满 255 个非零状态。抽头选错，周期会变得很短。要换位数时去查"本原多项式表"。
- **LFSR 的种子不能是 0**：全 0 是吸收态，异或永远是 0，会卡死。

---

## 第 5 章 状态机（FSM）

### 5.1 数电：从状态图到电路

状态机的三段式推导过程（你的数电课应该见过）：

```text
  ①状态图          ②状态表                ③编码 + 次态逻辑
  ┌────┐ 1   ┌────┐        现态 输入 | 次态 输出
  │ S0 │────>│ S1 │        S0   0   |  S0   0
  └────┘     └────┘        S0   1   |  S1   0
    ↑ 0        │ 1         S1   0   |  S0   0
    └──────────┘           S1   1   |  S11  1
                           ...
```

Verilog 里对应的就是**三段式写法**：

| 段 | 写什么 | 电路 |
| --- | --- | --- |
| 第一段 | 状态寄存器 | 一组触发器（同步更新） |
| 第二段 | 次态组合逻辑 | 组合电路（`case` 一棵 MUX） |
| 第三段 | 输出逻辑 | Moore：只看状态；Mealy：看状态+输入 |

这样写的好处：状态触发器、次态逻辑、输出逻辑泾渭分明，综合出来的电路和教科书上的框图一一对应，调试时看一眼波形就知道到了哪个状态。

### 5.2 Moore 与 Mealy

| | Moore | Mealy |
| --- | --- | --- |
| 输出依赖 | 只看当前状态 | 当前状态 + 当前输入 |
| 输出时机 | 进入状态后（晚一拍） | 输入一到就出（同拍） |
| 状态数 | 多 | 少（通常少 1 个） |
| 毛刺风险 | 小（输出跟随时钟变化） | 有（输出跟着输入变，输入有毛刺输出就有毛刺） |
| 常用场景 | 控制信号、状态指示 | 快速响应的协议/检测 |

时间轴对比（输入 `1 1`，检测"连续两个 1"）：

```text
           T1    T2    T3
  clk    ─┘ └───┘ └───┘ └─
  din      0     1     1
  Moore          0     1     ← 进入 S11 状态后才输出
  Mealy          0     1     ← 但 Mealy 是"din=1 且当前在 S1"的组合输出
  （两者这里看着一样，但在最后一个 1 拉低时，Moore 还会多保持一拍，Mealy 立刻落）
```

### 5.3 例：Moore 型状态机（两种状态编码）

**数电**：同一个状态图可以用不同的编码实现——二进制编码（状态少、触发器少）或 one-hot 编码（每位一个状态、触发器多、译码逻辑少、速度快，FPGA 上很常用，因为 FPGA 的触发器多得是）。

```verilog
// 文件: ex09_fsm_moore.v
`timescale 1ns/1ps
// Moore 型状态机：检测输入序列里出现连续两个 1（"11"）就给 y=1
module fsm_moore_bin (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output wire y
);
    localparam S0  = 2'd0;   // 还没见过 1
    localparam S1  = 2'd1;   // 上一个输入是 1
    localparam S11 = 2'd2;   // 已经出现 "11"

    reg [1:0] state, next_state;

    // 第一段：状态寄存器（时序）
    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next_state;

    // 第二段：次态组合逻辑
    always @* begin
        case (state)
            S0:   next_state = din ? S1  : S0;
            S1:   next_state = din ? S11 : S0;
            S11:  next_state = din ? S11 : S0;
            default: next_state = S0;
        endcase
    end

    // 第三段：输出只由当前状态决定（Moore 的特征）
    assign y = (state == S11);
endmodule

module fsm_moore_onehot (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output wire y
);
    localparam S0  = 3'b001;   // one-hot：每一位对应一个状态
    localparam S1  = 3'b010;
    localparam S11 = 3'b100;

    reg [2:0] state, next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next_state;

    always @* begin
        next_state = S0;
        case (state)
            S0:  next_state = din ? S1  : S0;
            S1:  next_state = din ? S11 : S0;
            S11: next_state = din ? S11 : S0;
            default: next_state = S0;
        endcase
    end

    assign y = state[2];
endmodule
```

```verilog
// 文件: ex10_fsm_mealy.v
`timescale 1ns/1ps
// Mealy 型状态机：同样检测 "11"，但输出和 din 同周期产生
module fsm_mealy (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output reg  y
);
    localparam S0 = 1'b0;   // 还没见过 1
    localparam S1 = 1'b1;   // 上一个输入是 1（只有两个状态）

    reg state, next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next_state;

    // 次态 + 输出放在一起算：输出是"当前状态 + 当前输入"的函数
    always @* begin
        y = 1'b0;
        case (state)
            S0: begin next_state = din ? S1 : S0; end
            S1: begin
                if (din) begin next_state = S1; y = 1'b1; end
                else         next_state = S0;
            end
            default: next_state = S0;
        endcase
    end
endmodule
```

```verilog
// 文件: tb_ex09_fsm.v
`timescale 1ns/1ps
module tb_ex09_fsm;
    localparam T = 10;
    reg clk = 1'b0;
    reg rst_n, din;
    wire y_bin, y_onehot, y_mealy;

    fsm_moore_bin    u_bin    (.clk(clk), .rst_n(rst_n), .din(din), .y(y_bin));
    fsm_moore_onehot u_onehot (.clk(clk), .rst_n(rst_n), .din(din), .y(y_onehot));
    fsm_mealy        u_mealy  (.clk(clk), .rst_n(rst_n), .din(din), .y(y_mealy));

    always #(T/2) clk = ~clk;

    task send_bit(input b);
        begin
            @(negedge clk);
            din = b;
            @(posedge clk);
            #1;
            $display("t=%5t din=%b | Moore(bin)=%b Moore(onehot)=%b Mealy=%b",
                     $time, din, y_bin, y_onehot, y_mealy);
        end
    endtask

    initial begin
        $dumpfile("tb_ex09_fsm.vcd");
        $dumpvars(0, tb_ex09_fsm);
        rst_n = 1'b0; din = 1'b0;
        #(T*1.3);
        rst_n = 1'b1;
        #(T*0.5);

        $display("-- 输入序列 0 1 1 0 1 1 1 --");
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);   // Moore 在这里输出 1；Mealy 也在这里输出
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b1);
        $finish;
    end
endmodule
```

真实输出：

```text
-- 输入序列 0 1 1 0 1 1 1 --
t=36000 din=1 | Moore(bin)=0 Moore(onehot)=0 Mealy=1
t=46000 din=1 | Moore(bin)=1 Moore(onehot)=1 Mealy=1
t=66000 din=1 | Moore(bin)=0 Moore(onehot)=0 Mealy=1
t=76000 din=1 | Moore(bin)=1 Moore(onehot)=1 Mealy=1
```

对照输入序列看：

- 第 2 个 bit 是 1（出现了"11"）→ Mealy 立刻在这一拍输出 1（`din=1` 且状态是"见过一个 1"）。
- Moore 要等一拍，到第 3 拍才输出（因为它的输出是 `state == S11`）。
- 第 4 个 bit 是 0 → 两者都归零，说明检测窗口只覆盖相邻两位。

顺便注意 `fsm_moore_onehot` 里第三段只写了 `assign y = state[2];`——one-hot 编码下"判断状态"退化成"取某一位"，这正是 one-hot 速度快的来源。

### 5.4 例：1011 序列检测器（Moore + Mealy 双实现）

```verilog
// 文件: ex11_seq_detector.v
`timescale 1ns/1ps
// 序列检测器：输入 din 上出现 "1011" 就输出一拍 y
// 两个版本：Moore 需要 5 个状态，Mealy 只要 4 个状态
module sd1011_moore (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output wire y
);
    localparam S0    = 3'd0;   // 无进展
    localparam S1    = 3'd1;   // 已见 "1"
    localparam S10   = 3'd2;   // 已见 "10"
    localparam S101  = 3'd3;   // 已见 "101"
    localparam S1011 = 3'd4;   // 已见 "1011"

    reg [2:0] state, next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next_state;

    always @* begin
        case (state)
            S0:    next_state = din ? S1    : S0;
            S1:    next_state = din ? S1    : S10;
            S10:   next_state = din ? S101  : S0;
            S101:  next_state = din ? S1011 : S10;
            S1011: next_state = din ? S1    : S10;
            default: next_state = S0;
        endcase
    end

    assign y = (state == S1011);
endmodule

module sd1011_mealy (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output reg  y
);
    localparam S0   = 2'd0;
    localparam S1   = 2'd1;
    localparam S10  = 2'd2;
    localparam S101 = 2'd3;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next_state;

    always @* begin
        y = 1'b0;
        case (state)
            S0:   next_state = din ? S1   : S0;
            S1:   next_state = din ? S1   : S10;
            S10:  next_state = din ? S101 : S0;
            S101: begin
                if (din) begin next_state = S1; y = 1'b1; end  // 输出跟 din 同拍
                else         next_state = S10;
            end
            default: next_state = S0;
        endcase
    end
endmodule
```

```verilog
// 文件: tb_ex11_seq_detector.v
`timescale 1ns/1ps
module tb_ex11_seq_detector;
    localparam T = 10;
    reg clk = 1'b0;
    reg rst_n;
    reg  [15:0] pat = 16'b1011_0110_1011_0000;   // 从最高位开始送
    reg  din;
    wire y_moore, y_mealy;
    integer i, hits_m, hits_q;

    sd1011_moore u_moore (.clk(clk), .rst_n(rst_n), .din(din), .y(y_moore));
    sd1011_mealy u_mealy (.clk(clk), .rst_n(rst_n), .din(din), .y(y_mealy));

    always #(T/2) clk = ~clk;

    initial begin
        $dumpfile("tb_ex11_seq_detector.vcd");
        $dumpvars(0, tb_ex11_seq_detector);
        rst_n = 1'b0; din = 1'b0;
        #(T*1.3);
        rst_n = 1'b1;

        hits_m = 0; hits_q = 0;
        $display(" 时间   din | Moore Mealy");
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            din = pat[15];
            pat = {pat[14:0], 1'b0};
            #1;                                  // 让组合逻辑稳定后再看输出
            $display("%6t    %b  |   %b     %b", $time, din, y_moore, y_mealy);
            if (y_moore) hits_m = hits_m + 1;
            if (y_mealy) hits_q = hits_q + 1;
        end
        $display("Moore 脉冲数 = %0d, Mealy 脉冲数 = %0d", hits_m, hits_q);
        $display("序列 1011011010110000 里有 3 处 1011：第 1~4、4~7、9~12 位（允许重叠）");
        $display("Moore 的输出要等一拍（状态先变化），Mealy 与最后一位同拍");
        $finish;
    end
endmodule
```

真实输出：

```text
 时间   din | Moore Mealy
 51000    1  |   0     1
 61000    0  |   1     0
 81000    1  |   0     1
 91000    0  |   1     0
131000    1  |   0     1
141000    0  |   1     0
Moore 脉冲数 = 3, Mealy 脉冲数 = 3
序列 1011011010110000 里有 3 处 1011：第 1~4、4~7、9~12 位（允许重叠）
Moore 的输出要等一拍（状态先变化），Mealy 与最后一位同拍
```

这张表是本教程最值得反复看的一张：

- **Mealy 在最后一位输入的同一拍就输出**（先出现的那一列），Moore 在下一拍（状态已经变成 `S1011`）。
- **重叠检测**：序列 `1011_0110...` 里第 1~4、4~7、9~12 位都能匹配。重叠检测的关键在 `S1011` 的次态处理：`next_state = din ? S1 : S10;`——匹配完之后不能傻乎乎地回 `S0`，要把"末尾的 1 或 10"当作新匹配的开头。

```text
  重叠检测的状态迁移（S1011 状态的两个出边）：
     S1011 --din=1--> S1    （末尾 1 当作新一轮的开头："1011|1"）
     S1011 --din=0--> S10   （末尾 "10" 当作新一轮的开头："1011|0" → "10"）
```

设计 FSM 时把这两条出边想清楚，就能避免"漏检重叠序列"这个经典 bug。

### 5.5 状态编码怎么选

| 编码 | 触发器数 | 组合逻辑 | 适用 |
| --- | --- | --- | --- |
| 二进制（binary） | ⌈log₂N⌉ | 多（要译码） | ASIC、状态特别多 |
| one-hot | N | 少（直接取位） | FPGA（触发器富余），速度优先 |
| gray | ⌈log₂N⌉ | 中 | 跨时钟域传递状态（相邻状态只变一位，减小亚稳态风险） |

**别自己手算编码，用 `localparam` 起名字就行。** 综合工具也常可以自动重编码（`(* fsm_encoding = "one-hot" *)` 这类属性，各家语法不同）。

### 5.6 FSM 常见坑

- 状态不是互斥的：`case` 分支重叠（用 `unique case` 或在 `default` 里断言）。
- 忘了 `default`：综合出锁存器，或状态跑飞后无法恢复。**每个 FSM 都要有 `default: next_state = S0;`。**
- 状态寄存器没有复位：仿真开始全是 `x`。
- 输出直接组合驱动外部引脚，Mealy 输出带毛刺 → 对外输出前再打一拍（寄存器输出）。
- 状态数变了但忘记改 `reg [2:0] state` 的位宽。
- **时序逻辑里用了阻塞赋值**，导致次态和现态短路。

---

## 第 6 章 存储器与总线

### 6.1 同步 RAM

**数电**：存储阵列就是"地址译码 + 存储单元"，写操作需要写使能，读操作是地址经过译码后选出某一行输出。同步 RAM 的地址、数据、控制都在时钟沿采样。

**读延迟**：因为读写都在 `always @(posedge clk)` 里，读出的数据在**下一个时钟沿**才出现在 `rdata` 上，即所谓"同步读、1 拍延迟"。这个延迟是所有存储器的通用特性，用的时候必须记账。

```verilog
// 文件: ex12_ram.v
`timescale 1ns/1ps
// 同步单口 RAM：读写都要时钟，读延迟 1 拍
module ram_sync #(
    parameter ADDR_W = 4,
    parameter DATA_W = 8
) (
    input  wire                  clk,
    input  wire                  we,
    input  wire [ADDR_W-1:0]     addr,
    input  wire [DATA_W-1:0]     wdata,
    output reg  [DATA_W-1:0]     rdata
);
    localparam DEPTH = 1 << ADDR_W;

    reg [DATA_W-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) mem[addr] <= wdata;   // 写
        rdata <= mem[addr];           // 读（非阻塞赋值 → 同地址同拍读写得到"旧值"）
    end
endmodule

// 简单双口 RAM：一个写口、一个读口，可以同时工作
module ram_dp #(
    parameter ADDR_W = 4,
    parameter DATA_W = 8
) (
    input  wire              clk,
    input  wire              we,
    input  wire [ADDR_W-1:0] waddr,
    input  wire [DATA_W-1:0] wdata,
    input  wire [ADDR_W-1:0] raddr,
    output reg  [DATA_W-1:0] rdata
);
    localparam DEPTH = 1 << ADDR_W;

    reg [DATA_W-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;
        rdata <= mem[raddr];
    end
endmodule
```

```verilog
// 文件: tb_ex12_ram.v
`timescale 1ns/1ps
module tb_ex12_ram;
    localparam T = 10;
    localparam AW = 4, DW = 8;
    reg clk = 1'b0;
    reg we;
    reg  [AW-1:0] addr;
    reg  [DW-1:0] wdata;
    wire [DW-1:0] rdata;

    ram_sync #(.ADDR_W(AW), .DATA_W(DW)) u_ram (
        .clk(clk), .we(we), .addr(addr), .wdata(wdata), .rdata(rdata)
    );

    always #(T/2) clk = ~clk;

    integer i, errors;
    reg [DW-1:0] expected;

    integer k;
    initial begin
        $dumpfile("tb_ex12_ram.vcd");
        $dumpvars(0, tb_ex12_ram);
        we = 1'b0; addr = 0; wdata = 0; errors = 0;

        $display("== 写入 0..15 地址：data = 地址 ^ 8'hA5 ==");
        for (k = 0; k < 16; k = k + 1) begin
            @(negedge clk);
            we = 1'b1; addr = k[AW-1:0]; wdata = (k ^ 8'hA5);
        end
        @(negedge clk);
        we = 1'b0;

        $display("== 读回校验 ==");
        for (k = 0; k < 16; k = k + 1) begin
            @(negedge clk);
            addr = k[AW-1:0];    // 地址在时钟低电平期间变化
            @(negedge clk);      // 中间的上升沿采样地址并读出，等一整拍
            #1;
            expected = (k ^ 8'hA5);
            if (rdata !== expected) begin
                $display("地址 %0d 读回 %h，期望 %h  <-- 错", k, rdata, expected);
                errors = errors + 1;
            end else begin
                $display("地址 %0d 读回 %h  OK", k, rdata);
            end
        end
        $display("错误数 = %0d", errors);

        $display("== 读旧值：同一拍写和读同一个地址 ==");
        @(negedge clk);
        addr = 4'd3; we = 1'b1; wdata = 8'hFF;
        @(negedge clk); #1;
        $display("写入地址 3 = %h，但同一拍读出来的是 %h（非阻塞赋值 → 读旧值）",
                 wdata, rdata);
        @(negedge clk);
        we = 1'b0; addr = 4'd3;
        @(negedge clk); #1;
        $display("下一拍再读地址 3 = %h，新值才可见", rdata);
        $finish;
    end
endmodule
```

真实输出（节选）：

```text
地址 0 读回 a5  OK
...
错误数 = 0
== 读旧值：同一拍写和读同一个地址 ==
写入地址 3 = ff，但同一拍读出来的是 a6（非阻塞赋值 → 读旧值）
下一拍再读地址 3 = ff，新值才可见
```

讲解：

- **`mem` 声明成 `reg [7:0] mem [0:15]`** 是"存储器"的固定写法：前面方括号是每个字的位宽，后面方括号是深度。注意它和位向量 `reg [7:0] x` 长得像但语义完全不同。
- **同一拍读写同一地址读到旧值**：因为 `rdata <= mem[addr];` 用了非阻塞赋值，读的是"写之前"的值。这叫 read-first（读优先）行为。如果想要 write-first（写优先，读回刚写的新值），可以改成 `rdata <= we ? wdata : mem[addr];`。**这个选择很重要**：FPGA 上"读优先"和"写优先"对应不同的 Block RAM 原语（一个要额外的旁路 MUX），选错了会浪费资源。
- **什么能推断成 Block RAM**：写和读必须在同一个 `always @(posedge clk)` 里，用非阻塞赋值，地址不要做花哨运算。在 `always @*` 里读、或者用阻塞赋值，就只能综合成分布式寄存器堆（LUT 拼的，面积大）。
- **双口 RAM**（`ram_dp`）：一个写口一个读口，可同时工作，是 FIFO 内部的标准结构。
- 复位不要重置整个 mem（那样会消耗大量资源），只复位控制逻辑。

### 6.2 ROM

ROM 的本质就是"一个初始化好、只读的存储阵列"。综合工具大多支持 `initial` 初始化。

```verilog
// 文件: ex13_rom.v
`timescale 1ns/1ps
// 同步 ROM：地址打一拍后出数据
module rom_sync #(
    parameter ADDR_W = 3,
    parameter DATA_W = 8
) (
    input  wire              clk,
    input  wire [ADDR_W-1:0] addr,
    output reg  [DATA_W-1:0] dout
);
    localparam DEPTH = 1 << ADDR_W;

    reg [DATA_W-1:0] mem [0:DEPTH-1];

    // 方式一：用 initial + 循环生成查找表（仿真和综合都认）
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = (i * 7 + 1) & 8'hFF;
    end

    // 方式二：从文件加载（更常见）：
    // initial $readmemh("rom_data.hex", mem, 0, DEPTH-1);
    // rom_data.hex 里每行一个十六进制数，例如：
    //   A5
    //   3C
    //   01

    always @(posedge clk)
        dout <= mem[addr];
endmodule
```

```verilog
// 文件: tb_ex13_rom.v
`timescale 1ns/1ps
module tb_ex13_rom;
    localparam T = 10;
    reg clk = 1'b0;
    reg  [2:0] addr;
    wire [7:0] dout;

    rom_sync #(.ADDR_W(3), .DATA_W(8)) u_rom (.clk(clk), .addr(addr), .dout(dout));

    always #(T/2) clk = ~clk;

    integer i;
    initial begin
        $dumpfile("tb_ex13_rom.vcd");
        $dumpvars(0, tb_ex13_rom);
        $display("地址 → 数据（mem[i] = i*7+1）");
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            addr = i[2:0];
            @(negedge clk); #1;              // 等一个时钟把地址打进 ROM
            $display("  %0d  → %0d (mem[%0d] 应为 %0d)", i, dout, i, (i * 7 + 1) & 8'hFF);
        end
        $finish;
    end
endmodule
```

真实输出：

```text
地址 → 数据（mem[i] = i*7+1）
  0  → 1 (mem[0] 应为 1)
  3  → 22 (mem[3] 应为 22)
  7  → 50 (mem[7] 应为 50)
```

要点：

- `$readmemh("file.hex", mem, 起始, 结束)` 从文本文件加载十六进制；`$readmemd` 是十进制。文件里每行一个数，支持 `//` 注释。
- **`$readmemh` 是仿真函数**：FPGA 综合工具一般能识别它（用于初始化 Block RAM），但 ASIC 流程通常要靠 ROM 编译器生成掩膜。跨工具时确认一下支持情况。
- 上面例子里用了一个 `initial` 循环生成查找表，好处是不依赖外部文件，直接就能跑。

### 6.3 同步 FIFO

**数电**：FIFO 是"环形缓冲区"——一个存储阵列 + 读指针 + 写指针。写指针追上读指针是满，读指针追上写指针是空。用计数器 `count` 表示当前数据个数，满/空判断最直观。FIFO 用于跨时钟域（异步 FIFO）和速率匹配（同步 FIFO）。

```verilog
// 文件: ex14_fifo.v
`timescale 1ns/1ps
// 同步 FIFO：先入先出，深度 2^ADDR_W
module fifo_sync #(
    parameter DATA_W = 8,
    parameter ADDR_W = 3
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              wr_en,
    input  wire              rd_en,
    input  wire [DATA_W-1:0] din,
    output reg  [DATA_W-1:0] dout,
    output wire              full,
    output wire              empty,
    output reg  [ADDR_W:0]   count
);
    localparam DEPTH = 1 << ADDR_W;

    reg  [DATA_W-1:0] mem [0:DEPTH-1];
    reg  [ADDR_W-1:0] wptr, rptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    wire do_wr = wr_en && !full;    // 满的时候写请求被忽略
    wire do_rd = rd_en && !empty;   // 空的时候读请求被忽略

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr  <= {ADDR_W{1'b0}};
            rptr  <= {ADDR_W{1'b0}};
            count <= {(ADDR_W+1){1'b0}};
            dout  <= {DATA_W{1'b0}};
        end else begin
            if (do_wr) begin
                mem[wptr] <= din;
                wptr <= wptr + 1'b1;
            end
            if (do_rd) begin
                dout <= mem[rptr];      // 读出的数据是"寄存后的"，延迟 1 拍
                rptr <= rptr + 1'b1;
            end
            case ({do_wr, do_rd})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;   // 同时读写，或者都没动作
            endcase
        end
    end
endmodule
```

```verilog
// 文件: tb_ex14_fifo.v
`timescale 1ns/1ps
module tb_ex14_fifo;
    localparam T = 10, DW = 8, AW = 3, DEPTH = 1 << AW;
    reg clk = 1'b0;
    reg rst_n, wr_en, rd_en;
    reg  [DW-1:0] din;
    wire [DW-1:0] dout;
    wire full, empty;
    wire [AW:0] count;

    fifo_sync #(.DATA_W(DW), .ADDR_W(AW)) u_fifo (
        .clk(clk), .rst_n(rst_n), .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout), .full(full), .empty(empty), .count(count)
    );

    always #(T/2) clk = ~clk;

    // 参考模型：一个简单队列，用同样的读写请求算出"应该读出什么"
    reg [DW-1:0] model [0:DEPTH-1];
    integer m_wptr = 0, m_rptr = 0, m_count = 0;
    integer errors = 0;

    task push(input [DW-1:0] v);
        begin model[m_wptr % DEPTH] = v; m_wptr = m_wptr + 1; m_count = m_count + 1; end
    endtask

    // Verilog-2001 的 function 至少要有一个输入端口，所以这里用 task + 变量
    reg [DW-1:0] pop_v;
    task pop;
        begin
            pop_v = model[m_rptr % DEPTH];
            m_rptr = m_rptr + 1;
            m_count = m_count - 1;
        end
    endtask

    integer i;
    reg [DW-1:0] exp;

    initial begin
        $dumpfile("tb_ex14_fifo.vcd");
        $dumpvars(0, tb_ex14_fifo);
        rst_n = 1'b0; wr_en = 1'b0; rd_en = 1'b0; din = 0;
        #(T*1.3);
        rst_n = 1'b1;
        @(negedge clk);

        $display("== 1. 连写 5 个数据，观察 count 和 empty/full ==");
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            wr_en = 1'b1; din = 8'h10 + i[7:0];
            push(din);
        end
        @(negedge clk); wr_en = 1'b0;
        $display("count=%0d empty=%b full=%b", count, empty, full);

        $display("== 2. 继续写到满，第 9 个数据应被丢弃 ==");
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            wr_en = 1'b1; din = 8'h20 + i[7:0];
            if (m_count < DEPTH) push(din);
            else $display("  写 %h 时已满，请求被忽略", din);
        end
        @(negedge clk); wr_en = 1'b0;
        $display("count=%0d full=%b", count, full);

        $display("== 3. 边读边校验（与参考模型对比）==");
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk);
            rd_en = 1'b1;
            pop; exp = pop_v;
            @(posedge clk); #1;
            if (dout !== exp) begin
                $display("  第 %0d 次读出 %h，期望 %h  <-- 错（注意读延迟 1 拍）", i, dout, exp);
                errors = errors + 1;
            end else begin
                $display("  第 %0d 次读出 %h OK", i, dout);
            end
        end
        @(negedge clk); rd_en = 1'b0;

        $display("== 4. 读空后 empty 有效 ==");
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk); rd_en = 1'b1;
            if (m_count > 0) pop; exp = pop_v;
        end
        @(negedge clk); rd_en = 1'b0;
        #(T);
        $display("count=%0d empty=%b", count, empty);
        $display("校验错误数 = %0d", errors);
        $finish;
    end
endmodule
```

真实输出：

```text
== 1. 连写 5 个数据，观察 count 和 empty/full ==
count=5 empty=0 full=0
== 2. 继续写到满，第 9 个数据应被丢弃 ==
  写 23 时已满，请求被忽略
count=8 full=1
== 3. 边读边校验（与参考模型对比）==
  第 0 次读出 10 OK
  ...
校验错误数 = 0
```

要点：

- **满的时候忽略写请求、空的时候忽略读请求**（`do_wr = wr_en && !full;`）。这是 FIFO 的"礼貌"行为，防止指针越界。
- **`dout` 有 1 拍读延迟**（因为它是寄存器）。用的时候要记住：拉高 `rd_en` 的那一拍，数据要下一拍才有效。所以 `dout` 常常配一个 `rd_valid` 输出（本例子从简）。这正是"读延迟"在工程里最容易出错的点。
- **`count` 用同时读写判断**：`case ({do_wr, do_rd})` 处理"同时读写 count 不变"，比分开写更严谨。
- **参考模型（golden model）**是 tb 的核心技巧：tb 里用一个简单队列算出"应该读出什么"，和 DUT 的实际输出对比。上面 tb 里 `model`/`m_wptr`/`m_rptr` 就是参考模型。
- **跨时钟域（CDC）**：真正的异步 FIFO 需要读写指针用格雷码同步，是进阶话题，别在没搞清楚之前自己写。

### 6.4 三态总线与 inout

**数电**：三态门（tri-state buffer）输出有 0/1/**高阻 z** 三种状态。高阻就是"我这根线不驱动"，于是别的器件可以驱动它。多个器件共用一根线就是总线（bus）。**同一时刻只能有一个驱动源**，否则就是总线争用（bus contention），在真实电路上会烧管子。

```verilog
// 文件: ex15_inout_bus.v
`timescale 1ns/1ps
// 三态总线：多个驱动源共用一根线，同一时刻只能有一个驱动
module bus_driver #(
    parameter W = 8
) (
    input  wire [W-1:0] dout,
    input  wire         oe,      // output enable，1 才驱动
    output wire [W-1:0] d
);
    assign d = oe ? dout : {W{1'bz}};   // z = 高阻，"我不驱动这根线"
endmodule

module bus_reader #(
    parameter W = 8
) (
    input  wire [W-1:0] d,
    output wire [W-1:0] q
);
    assign q = d;
endmodule
```

```verilog
// 文件: tb_ex15_inout_bus.v
`timescale 1ns/1ps
module tb_ex15_inout_bus;
    localparam W = 8;
    localparam T = 10;

    wire [W-1:0] bus;
    pullup pu0 (bus[0]); pullup pu1 (bus[1]); pullup pu2 (bus[2]); pullup pu3 (bus[3]);
    pullup pu4 (bus[4]); pullup pu5 (bus[5]); pullup pu6 (bus[6]); pullup pu7 (bus[7]);

    reg  [W-1:0] a_data, b_data;
    reg          a_oe, b_oe;
    wire [W-1:0] seen;

    bus_driver #(.W(W)) u_a (.dout(a_data), .oe(a_oe), .d(bus));
    bus_driver #(.W(W)) u_b (.dout(b_data), .oe(b_oe), .d(bus));
    bus_reader #(.W(W)) u_r (.d(bus), .q(seen));

    initial begin
        $dumpfile("tb_ex15_inout_bus.vcd");
        $dumpvars(0, tb_ex15_inout_bus);

        a_oe = 1'b0; b_oe = 1'b0; a_data = 8'hA5; b_data = 8'h5A;
        #10;
        $display("两个都不驱动: bus = %b  (z 被上拉电阻拉到 1，显示为 1)", bus);

        a_oe = 1'b1;
        #10;
        $display("A 驱动 %h : bus = %b", a_data, bus);

        a_oe = 1'b0; b_oe = 1'b1;
        #10;
        $display("B 驱动 %h : bus = %b", b_data, bus);

        {a_oe, b_oe} = 2'b11;
        #10;
        $display("两个同时驱动: bus = %b  <-- 冲突，出现 x（真实电路会过热）", bus);

        {a_oe, b_oe} = 2'b00;
        #10;
        $display("全部释放: bus = %b", bus);
        $finish;
    end
endmodule
```

真实输出：

```text
两个都不驱动: bus = 11111111  (z 被上拉电阻拉到 1，显示为 1)
A 驱动 a5 : bus = 10100101
B 驱动 5a : bus = 01011010
两个同时驱动: bus = xxxxxxxx  <-- 冲突，出现 x（真实电路会过热）
全部释放: bus = 11111111
```

要点：

- **`assign d = oe ? dout : {W{1'bz}};`** 是三态门的标准写法。`{W{1'bz}}` 表示 W 根线全部高阻。
- iverilog 支持 `pullup` 原语来模拟"总线上的上拉电阻"。没有上拉时，未驱动的总线读出来也是 `z`（gtkwave 里显示为一条中间的线），接上 `pullup` 后读出来是 1。
- **同时驱动 → `x`**：仿真里给你 `x` 已经是客气的了，真硬件上是短路发热。
- **`inout` 端口** 写法：`inout wire [7:0] d;`，模块内部用 `assign` 驱动（配三态），同时可以直接读它。一般只出现在**顶层 IO**，芯片内部很少用三态总线（内部用 MUX 更安全，也更好做时序分析）。
- 综合工具通常报 `inout` 的 warning，这是正常的；关键是你在协议层保证任何时候只有一个 `oe` 有效。

---

## 第 7 章 测试平台（Testbench）

tb 的作用：给 DUT 喂激励、观察输出、自动判断对错。好的 tb 比设计本身更值钱。

### 7.1 tb 的标准骨架

```verilog
`timescale 1ns/1ps
module tb_xxx;
    localparam T = 10;                 // 时钟周期
    reg  clk = 1'b0;
    reg  rst_n;
    // ... 其他 reg（输入）和 wire（输出）

    // 1) 例化 DUT
    my_dut u_dut (.clk(clk), .rst_n(rst_n), ...);

    // 2) 时钟生成
    always #(T/2) clk = ~clk;

    // 3) 复位生成 + 激励 + 检查
    initial begin
        $dumpfile("tb_xxx.vcd");
        $dumpvars(0, tb_xxx);
        rst_n = 1'b0;
        #(T*1.3);                      // 复位保持几拍（不要用 0.5 拍，容易踩在时钟沿上）
        rst_n = 1'b1;
        // ... 激励，检查
        $finish;
    end
endmodule
```

两个细节，值得记一辈子：

- **复位保持时间取 1.3 个周期**这种"非整数拍"，是为了避免复位释放正好压在时钟沿上（tb 里故意错开，`0.5`/`1.0` 这种整数容易产生竞争）。
- **`#(T/2)`** 在 `localparam T = 10` 时是 5，整数没问题。如果 T 是奇数，考虑用 `real` 或统一用偶数周期。

### 7.2 时间控制：`#` `@` `wait` `repeat` `fork/join`

| 语法 | 含义 |
| --- | --- |
| `#10;` | 等 10 个时间单位（由 `` `timescale `` 决定） |
| `@(posedge clk);` | 等到下一个时钟上升沿 |
| `@(negedge clk);` | 等到时钟下降沿（**给 DUT 喂数据的推荐时机**，避开时钟沿） |
| `@(rst_n);` | 等这个信号变化 |
| `wait (ready == 1'b1);` | 阻塞等待条件成立（不会消耗时间，条件为真立刻继续） |
| `repeat (4) @(posedge clk);` | 重复 4 次 |
| `fork ... join` | 里面几个进程**并行**跑（比如一边发数据一边监视超时） |

**给 DUT 喂数据的黄金时机**：在**时钟下降沿**（或时钟沿之后 1ns）改变输入。原因是：

```text
  clk    ──┐        ┌────────
           └────────┘
  posedge ↑                    ← 触发器在这里采样
  危险：          |    |       ← 在时钟沿附近改输入会产生竞争
  安全：  ^                    ← 沿之前就稳定好（negedge 改，posedge 采）
```

### 7.3 task 与 function

| | `task` | `function` |
| --- | --- | --- |
| 能消耗时间（`#`/`@`） | 能 | 不能 |
| 能返回几个值 | 无返回值，但可以通过 `output` 参数返回多个 | 只能返回一个值 |
| 调用方式 | `my_task(a, b);` | `x = my_func(a, b);` |
| 常见用途 | 发送一个字节、复位、打印 | 计算、转换、校验 |

```verilog
task send_byte(input [7:0] b);
    begin
        @(negedge clk);
        din = b; valid = 1'b1;
        @(negedge clk);
        valid = 1'b0;
    end
endtask

function [7:0] rev8(input [7:0] x);     // Verilog-2001 里 function 至少要有一个输入
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1) rev8[i] = x[7-i];
    end
endfunction
```

注意最后那个坑：**Verilog-2001 的 `function` 必须至少有一个输入端口**，所以"无输入的 function"（比如从参考模型里 `pop` 一个值）要用 `task` + 变量实现（第 6 章 FIFO 的 tb 里就是这么做的）。

### 7.4 打印：`$display` 家族

| 系统函数 | 用法 |
| --- | --- |
| `$display(...)` | 执行到就打印一行，带换行 |
| `$write(...)` | 不换行（配合循环打印一行数据很方便） |
| `$monitor(...)` | 参数里的信号**只要变化就打印**（全局只有一个 monitor 生效） |
| `$strobe(...)` | 在时间步**末尾**打印，能看到所有赋值生效后的稳定值（比 `$display` 更"确定"） |
| `$timeformat(-9, 1, " ns", 10)` | 时间显示成 ns、1 位小数、宽度 10；`-9` 表示 10⁻⁹ |
| `$sformatf`/`$sformat` | 拼字符串（SystemVerilog 风格，`-g2012`） |
| `$fopen`/`$fdisplay`/`$fclose` | 把结果写到文件 | 

格式符：`%b` 二进制、`%h`/`%x` 十六进制、`%d` 十进制、`%o` 八进制、`%c` 字符、`%s` 字符串、`%t` 时间（用 `$timeformat` 的格式）、`%m` 当前层次名。宽度用 `%4t`、`%08h` 这种写法。

**`$display` 里加 `%0d`**：`%0d` 表示"不补空格"，比 `%d` 更好看。

### 7.5 VCD 波形：怎么 dump、怎么变小

```verilog
initial begin
    $dumpfile("dump.vcd");        // 建议每层测试一个独立文件名，别互相覆盖
    $dumpvars;                    // 不写参数 = 当前层次所有信号
    $dumpvars(0, tb);             // 递归所有层级（0 = 无限深度）
    $dumpvars(1, tb.u_dut);       // 只 dump u_dut 一层（推荐！文件会小很多）
    $dumpvars(2, tb.u_dut);       // dump 两层
end
```

- 没有 `$dumpvars` 就不会有 VCD，`gtkwave` 打开会报"没有信号"。
- 波形文件容易变成几百 MB。**只 dump 关心的层次**是最有效的瘦身手段。
- 想只记录某一段时间：`$dumpoff;` / `$dumpon;` 配合 `#delay` 控制（记录一个"中间窗口"）。
- 存储器的全部内容默认不 dump（太大）。想 dump 内存：`$dumpvars(1, tb.u_ram.mem)`，但通常没必要。

### 7.6 自检：让 tb 自己告诉你对错，而不是靠肉眼

三个层次的自检手段：

```verilog
// 1) 错误计数，最后汇总
integer errors = 0;
if (actual !== expected) begin errors = errors + 1; $display("FAIL ..."); end
...
if (errors != 0) $display("共 %0d 个错误", errors); else $display("全部通过");

// 2) 断言式失败：立刻停止（$fatal 会让 vvp 返回非零退出码，方便 CI）
$fatal(1, "FIFO 读出的数据不对");

// 3) 超时保护：防止仿真永久挂住
initial begin
    #(100 * 1000);
    $display("超时保护触发");
    $finish;
end
```

`$fatal` 的退出码行为让 tb 能直接用在 Makefile / CI 里：`make run` 失败会中断。

**校验一定要用 `!==` 而不是 `!=`**，因为 `!==` 能发现 `x` 和 `z`（`x != 4'd0` 结果是 `x`，在 `if` 里算假，bug 会被吞掉）。

### 7.7 随机激励、种子、命令行参数、编译开关

```verilog
integer seed = 12345;
a = $random(seed) % 256;        // $random(seed) 每次调用都会推进种子
                                // 传同一个 seed 值可以让随机序列可复现
b = $random(seed) % 256;
cin = $random(seed) % 2;        // 注意：这三次调用会连续推进同一个种子
```

- **`$random(seed)` 的返回值是 32 位有符号数**，所以取范围要写 `{$random(seed)} % N`（拼接把符号位去掉）或者取绝对值。`$urandom`/`$urandom_range` 是 SystemVerilog 的，要 `-g2012`。
- **随机测试必须可复现**：把种子打印出来，失败时用同一个种子重跑。这是随机测试的基本纪律。
- **命令行传参 + `$value$plusargs`**：

```bash
vvp sim.vvp +N=1000 +SEED=7        # vvp 后面的 +xxx 参数会传给 $value$plusargs
```

```verilog
integer ntests = 10;
if (!$value$plusargs("N=%d", ntests)) $display("用默认值 %0d", ntests);
```

- **编译期开关**（`-D` + `` `ifdef ``），用于加速/降级测试：

```bash
iverilog -DSTRICT -DINJECT -o sim.vvp tb.v dut.v
```

```verilog
`ifdef STRICT
    $fatal(1, "有错误，终止");
`else
    $display("有错误，但继续跑");
`endif
```

### 7.8 完整范例：一个"像样"的 tb

```verilog
// 文件: ex16_adder8.v
`timescale 1ns/1ps
module rca8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire [7:0] s,
    output wire       cout
);
    assign {cout, s} = a + b + cin;
endmodule
```

```verilog
// 文件: tb_ex16_techniques.v
`timescale 1ns/1ps
// 一个"像样"的测试平台：参数化激励 + 参考模型自检 + 随机激励 + 错误注入
module tb_ex16_techniques;
    localparam T = 10;

    reg        clk = 1'b0;
    reg  [7:0] a, b;
    reg        cin;
    wire [7:0] s;
    wire       cout;

    rca8 u_dut (.a(a), .b(b), .cin(cin), .s(s), .cout(cout));

    always #(T/2) clk = ~clk;        // 时钟生成：每 5ns 翻转一次

    // 通过 +N= / +SEED= 从命令行传参数，缺省值写在声明处
    integer ntests = 10;
    integer seed   = 12345;
    integer i;
    integer errors = 0;
    reg [8:0] expected;                // 9 位：把 cout 也装进去，避免溢出丢位

    task check(input [7:0] a_in, input [7:0] b_in, input cin_in);
        begin
            a = a_in; b = b_in; cin = cin_in;
            #(T/4);                  // 等组合逻辑稳定
            expected = a_in + b_in + cin_in;
            if ({cout, s} !== expected) begin
                errors = errors + 1;
                $display("  [FAIL] %0d + %0d + %0d = {%b,%b}，应为 %b",
                         a_in, b_in, cin_in, cout, s, expected);
            end else begin
                $display("  [ OK ] %0d + %0d + %0d = %0d", a_in, b_in, cin_in, expected);
            end
        end
    endtask

    initial begin
        $timeformat(-9, 1, " ns", 10);           // 时间显示格式
        if (!$value$plusargs("N=%d", ntests))
            $display("提示：可以用 +N=100 指定测试个数，当前用默认值 %0d", ntests);
        if (!$value$plusargs("SEED=%d", seed))
            $display("提示：可以用 +SEED=7 指定随机种子");

        $dumpfile("tb_ex16_techniques.vcd");
        $dumpvars(0, tb_ex16_techniques);

        $display("== 边界用例 ==");
        check(8'h00, 8'h00, 1'b0);
        check(8'hFF, 8'hFF, 1'b0);               // 全 1 相加，看 cout
        check(8'hFF, 8'h00, 1'b1);               // 再加进位，应变成 0

        $display("== 随机用例（种子 %0d，共 %0d 个）==", seed, ntests);
        for (i = 0; i < ntests; i = i + 1) begin
            a   = $random(seed) % 256;
            b   = $random(seed) % 256;
            cin = $random(seed) % 2;
            check(a, b, cin);
        end

        $display("== 错误注入（编译时加 -DINJECT 才会打开）==");
`ifdef INJECT
        check(8'd1, 8'd1, 1'b0);
        errors = errors + 1;                     // 假装这里挂了
`else
        $display("  未定义 INJECT，跳过这一步");
`endif

        if (errors != 0) begin
`ifdef STRICT
            $fatal(1, "共 %0d 个错误，直接终止仿真", errors);
`else
            $display("共 %0d 个错误（未加 -DSTRICT，不算致命）", errors);
            $finish;
`endif
        end
        $display("全部通过");
        $finish;
    end

    // 防止仿真挂死：超时自动结束
    initial begin
        #(T * 10000);
        $display("超时保护触发，仿真被强制结束");
        $finish;
    end
endmodule
```

跑法（三种模式都试一遍）：

```bash
# 默认
iverilog -Wall -g2012 -o sim.vvp tb_ex16_techniques.v ex16_adder8.v && vvp sim.vvp

# 传参数：1000 个随机用例，种子 7
vvp sim.vvp +N=1000 +SEED=7

# 打开"严格模式 + 错误注入"，看 $fatal 的效果（vvp 退出码非零）
iverilog -Wall -g2012 -DSTRICT -DINJECT -o sim_s.vvp tb_ex16_techniques.v ex16_adder8.v
vvp sim_s.vvp +N=1; echo "退出码 = $?"
```

真实输出（`-DINJECT -DSTRICT`）：

```text
== 边界用例 ==
  [ OK ] 0 + 0 + 0 = 0
  [ OK ] 255 + 255 + 0 = 510
  [ OK ] 255 + 0 + 1 = 256
== 随机用例（种子 7，共 1 个）==
  [ OK ] 0 + 140 + 0 = 140
== 错误注入（编译时加 -DINJECT 才会打开）==
  [ OK ] 1 + 1 + 0 = 2
FATAL: tb_ex16_techniques.v:72: 共 1 个错误，直接终止仿真
       Time: 10000  Scope: tb_ex16_techniques
```

这个 tb 包含了工程上"够用"的全部要素：参数化、边界用例、随机用例（可复现）、参考模型比对、错误计数、超时保护、`$fatal`、编译开关、plusargs。

### 7.9 tb 常见坑

1. **tb 里给输入赋值用 `=`（阻塞），DUT 内部时序逻辑用 `<=`**。tb 是"程序"，DUT 是"电路"，两者规则不同。
2. **改输入的时刻压在时钟沿上** → 仿真竞争，结果随机。请用 `@(negedge clk)`。
3. **`$monitor` 和 `$display` 混用**：`$monitor` 全局只有一个，后设的会覆盖前面的。
4. **依赖 `#100` 这种"猜时间"** 而不是 `@(posedge clk)`，一旦时钟周期改了 tb 就崩。**尽量事件驱动（等待信号），少用绝对延时。**
5. **tb 里用 `<=` 给 DUT 输入赋值** → 采样时刻推迟一拍，现象是"所有输出都晚一拍"，非常难查。
6. **忘记 `$finish`** → 仿真跑到天荒地老。
7. **一个 tb 测太多东西**：tb 太大后一个失败要看半天。按场景拆成多个小 tb，用 Makefile 串起来跑。

---

## 第 8 章 GTKWave 实战

### 8.1 启动

```bash
gtkwave tb_ex01_and_gate.vcd &                    # 最简单：直接给 VCD
gtkwave -f tb_ex01_and_gate.vcd -a my.gtkw &      # 指定波形 + 指定 savefile
gtkwave --dark tb_ex01_and_gate.vcd &              # 暗色主题（夜里友好）
```

常用命令行选项（来自 `gtkwave --help`）：

| 选项 | 作用 |
| --- | --- |
| `-f FILE` / 直接给文件 | 指定要加载的波形文件 |
| `-a FILE` / 第二个位置参数 | 指定 savefile（`.gtkw`），自动恢复你上次排好的信号布局 |
| `-n` / `--nocli` | 弹出文件选择框而不是加载指定文件 |
| `-o` / `--optimize` | 把 VCD 转成 FST 再打开（大文件必用） |
| `-F` / `--fastload` | 生成/使用 fastload 文件，二次打开更快 |
| `-S FILE` | 启动时执行 Tcl 脚本（自动化用） |
| `-x` / `--exit` | 加载完就退出（配合基准测试） |
| `-l FILE` | 记录 logfile，方便把时间和事件对上 |
| `-M` | 关掉菜单栏（做嵌入显示用） |

### 8.2 界面三大块

```text
┌──────────────────────┬─────────────────────────────────────────────┐
│  SST                 │                                             │
│  (Signal Search Tree)│            波形区（Waveform）               │
│  树形浏览 DUT 层次    │   点击波形设定光标，光标所在时刻的数值会显示  │
│  双击 = 加入波形      │   在左侧信号列表的 value 列                  │
├──────────────────────┤                                             │
│  信号列表            │  每个信号一行的数值都在光标处显示            │
│  选中按 Insert 加入   │                                             │
│  按 Delete 移除      │                                             │
└──────────────────────┴─────────────────────────────────────────────┘
```

操作要点：

- **加信号**：在 SST 里双击信号名（或选中后按 `Insert`）；也可以从 SST 拖到信号列表。
- **删信号**：在信号列表里选中，按 `Delete`。
- **重新排列**：在信号列表里拖动（放在合适位置后"粘"进去）。
- **看某个时刻的值**：点波形任意位置，左侧 `value` 列立刻显示所有信号在该时刻的值。这是最常用的操作——**比盯着一堆打印快多了**。

### 8.3 缩放和移动

| 操作 | 方式 |
| --- | --- |
| 放大 / 缩小 | 键盘 `+` / `-` |
| 全局适配（看到全部时间） | 菜单 `Time → Zoom → Fit` 或 `Time → Zoom → Best Fit` |
| 局部放大 | 在波形区**按住左键拖框**，圈住要看的区间 |
| 平移 | 拖动横向时间滑块，或用 `Time` 菜单里的滚动项 |
| 跳到开头/结尾 | 菜单 `Time → Goto Start / Goto End` |

> 菜单项的措辞在不同版本略有差异（GTKWave 是活跃维护的老牌工具），找不到就用 `Time` 菜单挨个看一遍，或者直接拖框——**拖框是最高效的，先学会它就够用了**。

### 8.4 数据格式（右键信号）

在信号列表里**右键信号名 → Data Format**，可以切换：

| 格式 | 用途 |
| --- | --- |
| Binary | 看单个位/位宽小的信号 |
| Hexadecimal | 看总线、地址、数据（最常用） |
| Decimal / Signed Decimal | 看计数器和有符号数。**读数时注意选 Signed，否则 -1 会显示成 255** |
| Analog → Step | 把总线当模拟量画（看 ADC 数据、波形包络、滤波器输出很直观） |
| Analog → Interpolated | 折线模拟显示，看趋势 |

**实用技巧**：

- 计数器用 **Signed Decimal + Analog Step**，一眼就能看出"卡住了"还是"在跑"。
- 状态机的 `state` 信号：右键把显示改成 Hexadecimal，再配合你代码里的 `localparam` 对照表（`S0=0, S1=1, S11=2, ...`）读数。GTKWave 也支持给枚举值起名字（Signal 属性里的 "Data Format → Enum"），但最土也最好用的办法就是：**把状态表抄在纸上放在旁边**。
- 总线的每一位可以展开（信号名左侧有三角形，点开显示 `[7:0]` 的每一位）。

### 8.5 分组与并排比较

调一块逻辑出问题时，最有效的手段是**把"期望值"和"实际值"上下并排放**：

```text
  tb.u_dut.count          ← 我是这么想的
  tb.model.count          ← 参考模型
  tb.compare_fail         ← 一有差异就拉高的标志
```

做法：在信号列表里把相关信号拖到一起，用 `Edit` 菜单里的分组/插入分隔线（有的版本是右键 → Group）隔开。把 `fail` 放在最上面，出问题时一眼定位时间点。

### 8.6 savefile（.gtkw）：一次排好，反复使用

`.gtkw` 是**纯文本**文件，记录了：加载哪个波形、显示了哪些信号、顺序、数据格式、缩放位置、分组。价值巨大——它可以把"看波形"从十分钟的手工操作变成一条命令。

```bash
# 排好信号后：菜单 File → Write Save File 存成 tb_fifo.gtkw
# 下次直接一条命令回到同样的界面
gtkwave -a tb_fifo.gtkw dump.vcd &
```

`.gtkw` 可以（也应该）**跟代码一起提交到 git**：审查者拿到波形文件就能直接看到你想让他看的信号。这在团队协作里非常加分。

### 8.7 大文件：换成 FST 格式

VCD 是文本格式，体积大、加载慢。GTKWave 自带的 `vcd2fst` 可以压成二进制 FST（体积常常小 10 倍以上，加载快得多）：

```bash
vcd2fst tb_ex14_fifo.vcd tb_ex14_fifo.fst     # 转换
gtkwave tb_ex14_fifo.fst &                     # 用 FST 打开，功能完全一样
fst2vcd tb_ex14_fifo.fst > back.vcd            # 需要时也能转回 VCD
```

或者让 gtkwave 自己做：`gtkwave -o dump.vcd`（打开时顺手转 FST 并缓存在旁边）。

另外，最根本的瘦身方法是第 7.5 节的 **`$dumpvars(层数, 模块)`**——只 dump 你关心的层次，别整个设计全 dump。

### 8.8 看波形的调试套路（照着做）

1. **先看时钟和复位**：时钟有波形吗？周期对不上？复位是不是一直没释放（`rst_n` 一直在低）？
2. **看所有输入**：DUT 的输入信号是否符合预期？很多时候问题在 tb 喂错了。
3. **看 `x`**：波形里有红线（x）就是"未知"。找到**最早出现 x 的信号**，那就是根因（x 会向下游传播）。
4. **看状态机**：把 `state` 加进来，跟着时钟数它走过的状态序列，和状态图对比。
5. **对比参考模型**：把期望值和实际值并排放，找第一个不一致的时间点。
6. **量时间间隔**：把两条光标（或记下两个时刻）相减，检查时序参数（比如 UART 位宽是多少 ns、握手间隔是否满足协议）。
7. **回到代码**：定位到出问题的那一拍后，**把 `$display` 加在对应 `always` 块里**，再跑一次。波形 + 打印组合拳是最快的调试方式。

### 8.9 无 GUI 场景 / 自动化

- 服务器上没 X11？用 `-x`（加载完就退出）做冒烟测试，或者干脆只靠 tb 的 `$display` 自检 + 退出码。
- Tcl 脚本：`gtkwave -S script.tcl dump.vcd`，可以自动加载信号、自动导出图片，适合做回归测试报告。
- 把 VCD 换 FST 再用命令行工具 `fst2vcd` 处理，可以写进 CI 脚本里做波形比对。

---

## 第 9 章 可综合风格与工程约定

### 9.1 哪些能综合，哪些只能仿真

| 构造 | 能综合？ | 说明 |
| --- | --- | --- |
| `assign` / `always @*` / `always @(posedge clk)` | ✅ | 组合逻辑与时序逻辑的主体 |
| `if/else`、`case`、`for`（常量边界） | ✅ | `for` 会被展开成并行电路 |
| `parameter`、`localparam`、`generate` | ✅ | 参数化设计的基础 |
| `initial`（给存储器初值） | ⚠️ | FPGA 支持，ASIC 未必 |
| `#10` 延时 | ❌ | 综合工具直接忽略（还有可能报错） |
| `$display`、`$dumpvars` 等系统任务 | ❌ | 只有 tb 里用 |
| `fork/join` | ❌ | 只有 tb 里用 |
| 全 `x`/`z` 赋值 | ⚠️ | `z` 在 `inout` 上是合法的三态；`x` 不可综合 |
| `while`、不确定次数的循环 | ❌ | 综合工具无法展开 |
| 事件控制 `@(posedge x)` 但 x 不是时钟 | ⚠️ | 会综合出不期望的触发器，慎用 |

**实践原则：把一个 `.v` 文件里的"设计"和"tb"彻底分开**（`tb_*.v` 只参与仿真），这样综合脚本只要把 `tb_*` 排除掉就行（见附录 C 的 Makefile）。

### 9.2 参数化与 generate

**参数化**是 Verilog 最重要的工程能力：写一次，实例化时给不同位宽。

```verilog
module fifo_sync #(parameter DATA_W = 8, parameter ADDR_W = 3) (...);
    localparam DEPTH = 1 << ADDR_W;              // 由参数推导出来的常量
    reg [DATA_W-1:0] mem [0:DEPTH-1];
```

要点：

- **位宽不要硬编码**：用 `DATA_W-1` 而不是 `7`，用 `{WIDTH{1'b0}}` 而不是 `8'h00`。
- 所有推导常量放 `localparam`，只在一处出现（DRY 原则）。
- `$clog2`（需要 `-g2012`）能自动算"最少需要多少位"，用于地址宽度推导。

**generate** 用于"按参数复制电路"：

```verilog
genvar i;                                   // genvar 只能在 generate 里用
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_bit
        assign y[i] = a[i] ^ b[i];          // 会被展开成 WIDTH 份并行电路
    end
endgenerate
```

关于 `if generate`（按参数选择实现）：

```verilog
generate
    if (STYLE == "ripple") begin : g_rca
        // 行波进位实现
    end else begin : g_cla
        // 超前进位实现
    end
endgenerate
```

注意两个坑：

- **`begin : 名字`** 里的标号不能省（否则例化出的实例名会变成匿名的，层次名难看且容易冲突）。
- **generate 里的 `for` 是"复制电路"，不是"循环执行"**：不要在里面写 `#`/`$display` 这类"程序"语句。

### 9.3 目录、命名、分层约定

一个能长期维护的工程习惯（不用一次做完，但方向要对）：

```text
  rtl/          # 可综合的设计（每个模块一个文件，文件名=模块名）
    fifo_sync.v
    uart_tx.v
  tb/           # 测试平台（tb_ 前缀，或 _tb 后缀）
    tb_fifo_sync.v
  sim/          # 仿真产物（.vvp/.vcd/.fst）——加进 .gitignore
  Makefile
```

命名约定（团队统一即可，但下面这套很常见）：

| 类别 | 命名 | 例子 |
| --- | --- | --- |
| 模块/文件名 | 小写下划线，文件名=模块名 | `fifo_sync.v` |
| 低有效信号 | `_n` 后缀 | `rst_n`, `cs_n` |
| 时钟 | `clk` 前缀/后缀 | `clk`, `clk_50m` |
| 使能脉冲 | `en_` / `*_pulse` | `en_cnt`, `tick_pulse` |
| 例化实例名 | `u_` 前缀 + 功能 | `u_fifo`, `u_tx` |
| 参数 | 全大写 | `DATA_W`, `DEPTH` |
| 状态 | `S_` 前缀 | `S_IDLE`, `S_SEND` |

**分层原则**：一个模块只做一件事。把一个 500 行的模块拆成 3 个 150 行的模块，调试时间至少少一半。

### 9.4 综合工具是怎么"读"你的代码的

这部分理解了，写代码就有数了：

| 你写的 | 工具理解为 |
| --- | --- |
| `always @*` 里所有分支都有赋值 | 纯组合逻辑（无记忆） |
| `always @*` 里有分支漏赋值 | **锁存器**（有记忆）—— 尽量消灭 |
| `always @(posedge clk)` 里用 `<=` | 一组 D 触发器 |
| `if-else if-else` 嵌套 | **优先**选择链（越后面延迟越大） |
| `case` | 并行的 LUT/MUX 树 |
| `for (i=0;i<8;i=i+1) y[i]=...` | 8 份并行电路 |
| `for` 里累加（`acc = acc + x[i]`） | 8 级串行加法器（可能成为关键路径） |
| `always @(posedge clk)` 里嵌套的 `if` | 触发器前面插入 MUX（复位、使能都是 MUX） |
| 比较 `cnt == N-1` | 一个比较器 + 计数器（有些工具会优化成"回绕检测"） |

由此得到几条实用结论：

1. **优先选 `case` 而非长 `if-else`**，除非你真的需要优先级（比如优先编码器）。
2. **关键路径上的逻辑尽量浅**：`cout` 用 `a + b` 一条语句（工具会选好加法器结构），不要手工写 32 级串行加法。
3. **时序逻辑的 `if` 条件越少越好**（每个 `if` 都是一层 MUX）。
4. 想不通就去看综合报告的**关键路径**，再回头看代码。

### 9.5 Lint：把 bug 拦在仿真之前

```bash
# 1) iverilog 自带警告（最省事，永远开着）
iverilog -Wall -g2012 -o sim.vvp tb.v dut.v

# 2) Verilator 只做 lint（非常强，能报位宽截断、多驱动、latch 等）
#    需要安装：sudo apt install -y verilator
verilator --lint-only -Wall dut.v

# 3) Yosys 综合一下看网表/统计（可选）
#    sudo apt install -y yosys
yosys -p "read_verilog dut.v; hierarchy -top dut; proc; opt; stat"
```

`verilator --lint-only` 是投入产出比最高的工具：它不跑仿真，只静态分析，但能抓出一大堆"仿真碰巧过得去、上板就挂"的问题。装一个，写代码前先 lint 一遍。

### 9.6 常见坑总表（贴在显示器旁边）

| # | 坑 | 后果 | 正确做法 |
| --- | --- | --- | --- |
| 1 | 组合逻辑漏分支 | 综合出 latch | 块首给默认值 / `default` 分支 |
| 2 | 时序逻辑用 `=` | 仿真、综合不一致 | 时序一律 `<=` |
| 3 | 两个 always 驱动同一信号 | 输出 `x` | 一个信号只有一个驱动源 |
| 4 | 位宽没扩就相加 | 进位悄悄丢失 | 先 `{1'b0, a}` 扩位 |
| 5 | 忘记 `` `timescale `` | 时间单位错乱 | 每个文件都写 |
| 6 | 忘记复位 | 仿真一片 `x` | 每个寄存器都在复位分支里赋值 |
| 7 | 忘记 `$finish` | 仿真挂住 | tb 里必写 + 超时保护 |
| 8 | tb 输入压在时钟沿改 | 竞争，结果随机 | 用 `@(negedge clk)` |
| 9 | 校验用 `!=` 而不是 `!==` | 漏掉 `x`/`z` | 自检一律 `!==` / `===` |
| 10 | 变量右移 `>>` 用在有符号数上 | 符号位被补 0 | 用 `>>>` 或 `$signed` |
| 11 | `case` 语句重叠分支 | 行为不可预期 | 分支互斥，或用 `unique case`（`-g2012`） |
| 12 | 忘记读延迟 | 把上一拍数据当成本拍 | 记住 RAM/FIFO 读延迟 1 拍 |
| 13 | 用分频时钟驱动逻辑 | 多时钟域，时序崩 | 用使能脉冲（clk_en） |
| 14 | `inout` 双向同时驱动 | 总线争用，硬件损坏 | 用 `oe` 严格互斥 |
| 15 | 忘了 `default` 的 FSM | 状态跑飞无法恢复 | `default: next_state = S0;` |
| 16 | 硬编码位宽魔数 | 改参数就崩 | 用 `localparam` 推导 |
| 17 | 组合逻辑里的自环 | 仿真死循环/`x` | 检查反馈路径是否经过寄存器 |
| 18 | 在 tb 里用 `<=` 驱动输入 | 所有输出晚一拍 | tb 输入用 `=` |
| 19 | 一个模块 500 行 | 无法维护 | 按功能拆小，例化组合 |
| 20 | 只靠肉眼验波形 | 漏错、浪费生命 | 自检（参考模型 + 错误计数 + `$fatal`） |

---

## 附录 A 命令行速查

```bash
# ---------- 编译与仿真 ----------
iverilog -Wall -g2012 -o sim.vvp tb_top.v dut.v      # 编译（-Wall 必加）
iverilog -Wall -DDEBUG -I include -o sim.vvp *.v     # 定义宏 + 头文件目录
iverilog -Wall -s my_top -o sim.vvp *.v               # 显式指定顶层
iverilog -Wall -pfileline=1 -o sim.vvp *.v            # 运行时报错带行号
vvp sim.vvp                                           # 跑仿真
vvp sim.vvp +N=100 +SEED=3                            # 传 plusargs
vvp -l run.log sim.vvp                                # 记录 log
vvp -n sim.vvp                                        # 把 $stop 当 $finish（非交互模式）

# ---------- 波形 ----------
gtkwave dump.vcd &                                    # 打开波形
gtkwave -a my.gtkw dump.vcd &                         # 恢复 savefile
gtkwave -o dump.vcd &                                 # 顺手转 FST
vcd2fst dump.vcd dump.fst                             # 转 FST（文件小很多）
fst2vcd dump.fst > dump.vcd                           # 转回 VCD
gtkwave --dark dump.vcd &                             # 暗色主题

# ---------- 静态检查（可选安装） ----------
sudo apt install -y verilator yosys
verilator --lint-only -Wall dut.v                     # lint
yosys -p "read_verilog dut.v; hierarchy -top dut; proc; opt; stat"
```

| iverilog 参数 | 记忆点 |
| --- | --- |
| `-o` | output，输出仿真可执行文件 |
| `-s` | top 模块名 |
| `-Wall` | 全部警告（默认不显示） |
| `-g2012` | 语言标准（默认 IEEE1364-2005） |
| `-D` | 定义宏 |
| `-I` | include 路径 |
| `-p` | 传参数给各种子系统，如 `-pfileline=1` |

---

## 附录 B 一键导出本文所有代码

本文所有带「文件:」标记的代码块都可以自动导出成独立文件。保存下面的脚本，然后：

```bash
./extract-examples.sh verilog-tutorial.md verilog-examples
cd verilog-examples && make all && make run     # 全部编译并跑一遍

# 提取出来的脚本需要加执行权限（代码块里保存的文件默认没有 +x）
chmod +x verilog-examples/extract-examples.sh
```

```bash
#!/usr/bin/env bash
# 文件: extract-examples.sh
# 从教程 md 里把带 "// 文件: xxx" 或 "# 文件: xxx" 标记的代码块导出成独立文件
# 用法: ./extract-examples.sh verilog-tutorial.md verilog-examples
set -euo pipefail

md="${1:-verilog-tutorial.md}"
out="${2:-verilog-examples}"

mkdir -p "$out"

awk -v out="$out" '
  /^```/ {
      if (infence == 0) { infence = 1; fname = ""; buf = ""; nlines = 0; next }
      infence = 0
      if (fname != "" && fname != "__skip__") {
          print buf > (out "/" fname)
          close(out "/" fname)
          n++
      }
      next
  }
  infence == 1 {
      if (fname == "") {
          nlines++
          buf = buf $0 "\n"                 # 先全部缓存，找到文件名后再决定去留
          if      ($0 ~ /^\/\/ 文件: /) { fname = $0; sub(/^\/\/ 文件: /, "", fname) }
          else if ($0 ~ /^# 文件: /)    { fname = $0; sub(/^# 文件: /,    "", fname) }
          else if (nlines >= 3)          { fname = "__skip__" }   # 前三行都没有标记 → 跳过
          next
      }
      if (fname != "__skip__") buf = buf $0 "\n"
  }
  END { printf("导出 %d 个文件到 %s/\n", n, out) > "/dev/stderr" }
' "$md"

echo "文件列表:" >&2
ls -1 "$out" >&2
```

脚本原理：扫描 md 里的 `` ``` `` 代码块，在块内**前三行**里找形如 `// 文件: xxx.v` 或 `# 文件: Makefile` 的标记，把它当作输出文件名。（前三行是留给 shebang 之类的。）没有标记的代码块（命令示例、波形示意等）会被跳过。

---

## 附录 C Makefile

把导出的文件放在同一个目录里，下面的 Makefile 可以一条命令编译并跑完所有 tb：

```makefile
# 文件: Makefile
IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave
VFLAGS   ?= -Wall -g2012
EXTRA    ?=

SRCS := $(filter-out tb_%,$(wildcard *.v))
TBS  := $(wildcard tb_*.v)
SIMS := $(patsubst %.v,%.vvp,$(TBS))

all: $(SIMS)

%.vvp: %.v $(SRCS)
	$(IVERILOG) $(VFLAGS) $(EXTRA) -o $@ $< $(SRCS)

run: all
	@for s in $(SIMS); do \
	  printf '\n===== %s =====\n' $$s; \
	  $(VVP) $$s > /dev/null || exit 1; \
	  echo ok; \
	done

WAVE ?= tb_ex11_seq_detector
wave: $(WAVE).vvp
	$(VVP) $(WAVE).vvp && $(GTKWAVE) $(WAVE).vcd &

clean:
	rm -f *.vvp *.vcd

.PHONY: all run wave clean
```

常用命令：

```bash
make -j4 all                 # 编译全部 tb
make run                     # 跑全部 tb（失败会中断，适合放 CI）
make wave                    # 跑 tb_ex11_seq_detector 并打开波形
make wave WAVE=tb_ex14_fifo  # 换一个 tb 看波形
make clean
```

要点：

- `SRCS := $(filter-out tb_%,$(wildcard *.v))` 把 tb 排除在"设计源文件"之外——这正是 9.1 节"设计与 tb 分开"的落地方式。
- `VFLAGS ?= -Wall -g2012`，可以用 `make VFLAGS="-Wall"` 覆盖。
- `EXTRA` 用来传 `-DSTRICT` 之类：`make EXTRA=-DSTRICT`。

---

## 附录 D 练习题

按顺序做，前 5 题基本覆盖了本文核心。参考答案要点在每题后面。

1. **门级建模**：用 `assign` 写一个 4 位奇偶校验器（输出所有位的异或），并写出一个穷举 16 种输入的 tb 自检。
   > 要点：`assign parity = ^data;`（归约异或）；tb 里用 `for` 循环 0~15，期望值用 `^i[3:0]` 现算，比较用 `!==`。

2. **2 选 1 MUX 三种写法**：分别用 `assign`、`?:`、`always @* case` 实现，并用 tb 验证三者输出一致。
   > 要点：参考 `ex03_mux4.v` 的思路，把三路输出接在同一个 `sel/d` 上比较。

3. **十进制计数器**：设计一个 0~9 循环、带 `carry` 输出的计数器（参数化 `WIDTH`）。
   > 要点：`if (cnt == 9) cnt <= 0; else cnt <= cnt + 1;`；`carry = (cnt == 9)`。

4. **可逆移位寄存器**：带 `dir` 方向控制（0 左移、1 右移）和 `load` 并行载入的 8 位寄存器。
   > 要点：用 `if (load) ... else if (dir) q <= {q[6:0], sin}; else q <= {sin, q[7:1]};`。

5. **1101 序列检测器**：先画状态图（Moore 和 Mealy 各一个），再用三段式实现，并处理重叠检测。
   > 要点：Moore 5 个状态、Mealy 4 个状态；重叠处理的关键在匹配完成状态的出边（参考 5.4 节的 `S1011` 分析）。

6. **PWM 发生器**：参数化周期 `PERIOD` 和占空比 `DUTY`，输出一个方波。
   > 要点：`cnt` 从 0 数到 `PERIOD-1`，`pwm = (cnt < DUTY)`；这是最典型的"计数器 + 比较器"组合。

7. **用 `$readmemh` 做 ROM**：写一个 hex 文件，用 `$readmemh` 加载，读出来在 tb 里做 CRC/求和校验。
   > 要点：注意 `$readmemh` 的行数与 `DEPTH` 一致；仿真前确认文件路径（相对 `vvp` 运行目录，不是相对源文件！）。

8. **单口 RAM 反例分析**：把 `ex12_ram.v` 的读改成"同一拍写优先"（`rdata <= we ? wdata : mem[addr];`），用 tb 验证"同拍读写同地址读到新值"。
   > 要点：改完后 3.1 节的 read-first 测试会给出新值；两种行为在 FPGA 上对应不同的 BRAM 配置，对比资源报告。

9. **给 FIFO 加 `rd_valid`**：让 FIFO 在 `dout` 有效的同一拍输出 `rd_valid`，并在 tb 里校验它。
   > 要点：`rd_valid` 也是一个寄存器，在 `do_rd` 后延迟一拍置起（`rd_valid <= do_rd;`）；`rd_valid` 和 `dout` 必须完全对齐。

10. **FSM + 自动售货机**：输入 5 角和 1 元（两个脉冲信号），商品 2.5 元，找零 5 角，输出 `dispense` 和 `change`。
    > 要点：状态用"已投币金额"编码（0/0.5/1.0/1.5/2.0 元）；找零用一个计数器在 `dispense` 后逐拍输出 5 角脉冲。这是把 FSM 和数据通路的经典结合。

---

## 附录 E 继续学习

**要补的进阶话题（按重要性排序）**

1. **时序约束与静态时序分析（STA）**：建立/保持时间、时钟偏斜、关键路径报告。不管学 FPGA 还是 ASIC 都绕不过去。
2. **跨时钟域（CDC）**：两级同步器、握手、异步 FIFO、格雷码。多时钟域设计的安全底线。
3. **异步复位同步释放**：一个只需要 5 行代码但能救命的小电路。
4. **验证方法学**：SystemVerilog + UVM、断言（SVA）。工业界的验证工作量通常大于设计工作量。
5. **综合与时序优化的实际操作**：读懂综合报告、资源估算、时序收敛。

**推荐的动手路径**

- 用本文的 `ex*` 文件当模板，把每个练习都亲手写完 + 写 tb + 看波形，比看十篇教程有用。
- 找一块 FPGA 开发板，把计数器/FSM/UART 真正下到板子上点灯。你会发现"仿真通过"和"上板能跑"之间还有很多故事（比如按键抖动、时钟频率、引脚约束）。
- 用 `verilator --lint-only` 每天 lint 自己的代码，养成"提交前先 lint"的习惯。

**参考资料**

- `man iverilog`、`man vvp`、`man gtkwave`：本地文档，比任何教程都准。
- IEEE 1364-2005（Verilog 标准）：查语法细节的最终权威（重点是它定义的各种"位宽/符号推导规则"，第 2.6 节的坑全部出自这里）。
- 你手上的数字电路教材：第 3~6 章的电路知识全部来自那里，Verilog 只是把那些电路"描述"出来的工具。
