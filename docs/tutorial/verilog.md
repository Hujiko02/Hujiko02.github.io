# Verilog 零基础学习教程（Linux + iverilog + gtkwave + VSCode）

> 本文档配套项目目录：`/home/wuji/Projects/verilog-learn/`
> 学习方法主线：**边写边仿真边看波形**，不做题海战术，不啃大部头。

---

## 目录

1. [工具安装](#1-工具安装)
2. [核心概念：先搞懂 4 件事](#2-核心概念先搞懂-4-件事)
3. [完整工作流（一天 5 分钟记住它）](#3-完整工作流一天-5-分钟记住它)
4. [学习路线：从逻辑门到小 CPU](#4-学习路线从逻辑门到小-cpu)
5. [Verilog 必会语法清单](#5-verilog-必会语法清单)
6. [编译报错排查三板斧](#6-编译报错排查三板斧)
7. [常见坑与避坑指南](#7-常见坑与避坑指南)
8. [免费学习资源](#8-免费学习资源)

---

## 1. 工具安装

### 1.1 仿真工具（Debian/Ubuntu 系）

```bash
sudo apt update
sudo apt install -y iverilog gtkwave
```

安装后自动获得 3 个命令：

| 命令 | 作用 | 类比 |
|---|---|---|
| `iverilog` | 把 Verilog 源码编译成 `.vvp` 文件 | 相当于 gcc（编译） |
| `vvp` | 执行仿真，打印输出、生成波形 | 相当于运行程序 |
| `gtkwave` | 图形界面查看 `.vcd` 波形 | 相当于调试器 |

> 说明：`vvp` 不需要单独安装，装 `iverilog` 就自动带上了。

### 1.2 VS Code 插件

```bash
code --install-extension mshr-h.verilog-hdl
code --install-extension teros-technology.teroshdl
```

- **Verilog-HDL/SystemVerilog**：语法高亮、代码补全、格式化
- **TerosHDL**：lint 检查（写错立刻报）、一键生成测试平台模板

### 1.3 验证安装

```bash
iverilog -V        # 有版本号 = OK
gtkwave --version  # 有版本号 = OK
```

---

## 2. 核心概念：先搞懂 4 件事

学 Verilog 最大的误区是把它当 C 语言写。**它描述的是硬件**，先建立这 4 个心智模型：

### ① 模块（module）= 一个电路

```verilog
module 名字 ( 端口 );
    // 电路内部
endmodule
```

- 一个 `.v` 文件就是一个"电路图纸"
- `module` 和 `endmodule` 必须成对出现

### ② input / output = 引脚

```verilog
module gates (
    input  wire a,      // 输入引脚
    output wire y       // 输出引脚
);
```

- 对外连接的叫 **引脚（port）**
- 列表里两个声明之间用 **逗号** 隔开

### ③ assign = 一根连线

```verilog
assign y = a & b;   // 把 y 接到"a 与 b"的结果上
```

- 组合逻辑（没有记忆的电路）用 `assign` 描述
- 这是一条**语句**，结尾必须写 **分号 `;`**

### ④ 时序逻辑 = 有记忆的电路

```verilog
always @(posedge clk) begin
    q <= q + 1;     // 每个时钟上升沿执行一次
end
```

- 计数器、寄存器、状态机都属于这类
- 只在**时钟边沿**触发，用 `<=`（非阻塞赋值）

---

## 3. 完整工作流（一天 5 分钟记住它）

```
写 .v 文件 → iverilog 编译 → vvp 仿真 → 生成 .vcd → gtkwave 看波形
```

```bash
# ① 编译（把源码编译成可仿真文件）
iverilog -o 仿真名.vvp 设计.v 测试平台.v

# ② 仿真（运行，打印输出 + 生成 .vcd 波形）
vvp 仿真名.vvp

# ③ 看波形（打开图形界面，把信号拖到右侧）
gtkwave 波形.vcd
```

**改一行代码 → 重新编译 → 重新仿真 → 看波形**，这就是你的开发闭环。

---

## 4. 学习路线：从逻辑门到小 CPU

> 每个阶段都要动手写 + 仿真验证，不要只读。

### 阶段 0：逻辑门（第 1~2 天）✅ 已完成
- 与 `&`、或 `|`、非 `~`、异或 `^`
- 掌握 `module` / `input` / `output` / `assign`
- 练习：写一个 3 输入的门电路，打印真值表
- 项目：`01_gates/gates.v`

### 阶段 1：组合逻辑（第 3~5 天）
- 多路选择器（MUX）：`assign y = sel ? b : a;`
- 全加器：`sum = a ^ b ^ cin;` `cout = a&b | a&cin | b&cin;`
- 译码器、比较器
- 练习：用 `assign` 组合出门电路，实现 1 位全加器

### 阶段 2：时序逻辑（第 1~2 周）
- 触发器、寄存器（`reg`）
- 计数器、分频器
- 阻塞赋值 `=` vs 非阻塞赋值 `<=`（最大坑，详见第 7 节）
- 练习：8 位计数器 + 复位（项目：`01_counter/`）

### 阶段 3：状态机 FSM（第 2~3 周）
- 三段式写法：状态转移 + 次态逻辑 + 输出逻辑
- 练习：序列检测器（检测 "101"）

### 阶段 4：实用小模块（第 3~5 周）
- 同步 FIFO、UART 收发、SPI、按键消抖、数码管驱动
- 练习：UART 发送器，能连到串口调试助手

### 阶段 5：小 CPU（进阶，1~2 个月）
- 简单 RISC-V 核（可参考开源项目 PicoRV32、serv）
- 或学习 Yosys 综合 + FPGA 开发板（Tang Nano 9K 约 60~100 元）

---

## 5. Verilog 必会语法清单

### 数据类型
| 类型 | 用途 | 说明 |
|---|---|---|
| `wire` | 导线，组合逻辑连线 | 由 assign 驱动 |
| `reg` | 变量，有记忆 | 在 always 里赋值；也用作测试平台输入端 |

### 运算符
| 运算符 | 含义 | 示例 |
|---|---|---|
| `&` `\|` `~` `^` | 与 / 或 / 非 / 异或 | `assign y = a & b;` |
| `&&` `\|\|` `!` | 逻辑与 / 或 / 非 | `if (a && b)` |
| `==` `!=` | 等于 / 不等于 | `if (sel == 1)` |
| `+` `-` | 加减 | `q <= q + 1;` |
| `<<` `>>` | 移位 | `q <= q << 1;` |
| `? :` | 三目（多路选择） | `assign y = sel ? b : a;` |

### 常用语句
```verilog
assign 连续赋值;              // 组合逻辑
always @(*)                  // 组合逻辑过程块
always @(posedge clk)        // 时序逻辑（时钟上升沿）
if / else
case ... endcase
```

### 测试平台必备模板
```verilog
`timescale 1ns/1ps
module xxx_tb;
    reg  clk = 0;             // 输入端用 reg
    wire out;                 // 输出端用 wire

    xxx dut (.in(in), .out(out));   // 例化被测模块

    always #5 clk = ~clk;     // 产生 10ns 时钟
    initial begin
        $dumpfile("wave.vcd");      // 导出波形
        $dumpvars;
        // 在这里写测试激励...
        $finish;
    end
endmodule
```

---

## 6. 编译报错排查三板斧

### 第一斧：只看第一条报错
```
gates.v:13: syntax error
```
**永远从第一条报错看起**，后面的报错基本都是连锁反应（一个错把解析搞乱，后面全报错）。

### 第二斧：看报错指向的行号
`gates.v:13` = gates.v 第 13 行。打开文件，看那一行和上一行。

### 第三斧：对照常见错误表
| 报错 | 原因 | 修复 |
|---|---|---|
| `syntax error` | 漏了标点 | 查逗号/分号 |
| `...has already been declared` | 名字重复声明 | 换名字，或检查是否拼错 |
| `Unable to bind wire/reg` | 信号没连上 | 检查例化时接线名 |
| `Syntax error in continuous assignment` | assign 缺分号 | 在末尾补 `;` |
| `Errors in port declarations` | 端口列表漏逗号 | 两个声明之间加 `,` |

### 标点三规则（背下来）
1. **列表**（端口、例化接线）用逗号 `,`
2. **语句**（assign、赋值）用分号 `;`
3. **最后一个不带**（最后一个声明/连接后不写标点）

---

## 7. 常见坑与避坑指南

### 坑 1：时序逻辑用 `=`，组合逻辑用 `<=`
```verilog
// ❌ 错：时序逻辑用了阻塞赋值
always @(posedge clk) q = q + 1;

// ✅ 对：时序逻辑用非阻塞赋值
always @(posedge clk) q <= q + 1;
```
> 记法：**时序（clk）用 `<=`，组合（assign / always @*）用 `=`**

### 坑 2：组合逻辑漏 else / default → 产生锁存器
```verilog
// ❌ 错：if 没有 else，组合逻辑会生成锁存器（latch）
always @(*) begin
    if (sel) y = a;
end

// ✅ 对：补上 else
always @(*) begin
    if (sel) y = a;
    else     y = b;
end
```

### 坑 3：`always @(posedge clk)` 里面写了不该写的
- 时序块里**不要**用 `#延迟`
- 一个 `always` 块里尽量只写一个电路

### 坑 4：位宽不匹配
- `8 位 + 8 位` 结果可能溢出到 9 位
- 加法时给结果留够位宽：`output reg [8:0] sum;`

### 坑 5：仿真通过 ≠ 能综合
- 可综合：`assign`、`always`、`if/case`、`+ - & | ~ ^`
- 不可综合（只能仿真用）：`$display`、`#延迟`、`initial` 里的复杂循环

---

## 8. 免费学习资源

| 资源 | 用途 |
|---|---|
| **HDLBits**（hdlbits.01xz.net） | 在线刷题，从语法到状态机，强烈推荐 |
| 本项目 `01_gates/`、`01_counter/` | 动手实践，看波形 |
| 《数字设计和计算机体系结构》（Harris） | 数字电路 + 体系结构教材 |
| 《Verilog HDL 高级数字设计》 | 中文经典参考书 |
| ZipCPU 博客（zipcpu.com） | 实战风格的 Verilog/CPU 教程 |
| GitHub：PicoRV32、serv | 开源 RISC-V 实现，进阶阅读 |

---

## 附：每日练习节奏建议

- **每天 30~60 分钟**，只做 1 个小目标
- 每个小目标都走完整闭环：**写 → 编译 → 仿真 → 看波形**
- 真值表、波形图就是你的"运行结果"，学会了"看波形"才算真学会
- 卡住超过 30 分钟就换一个练，第二天再回头看

> 学习顺序永远是：**先跑通最简单的 → 加一点复杂度 → 再跑通 → 再加**。不要一次写很多代码，一次加一个功能。
