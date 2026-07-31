# LaTeX 入门教程（Overleaf 版）

> 本教程面向 **零基础** 读者，基于 **Overleaf**（在线 LaTeX 编辑器）编写。
> 你只需要一个浏览器和一个免费账号，无需在本地安装任何软件。

---

## 目录

1. [LaTeX 是什么](#1-latex-是什么)
2. [注册并创建第一个项目](#2-注册并创建第一个项目)
3. [LaTeX 源码的基本结构](#3-latex-源码的基本结构)
4. [中文支持](#4-中文支持)
5. [基础排版：字体、字号、段落](#5-基础排版字体字号段落)
6. [标题与章节](#6-标题与章节)
7. [列表](#7-列表)
8. [表格](#8-表格)
9. [插图](#9-插图)
10. [数学公式](#10-数学公式)
11. [交叉引用与超链接](#11-交叉引用与超链接)
12. [代码块（lstlisting）](#12-代码块lstlisting)
13. [页面设置与宏包](#13-页面设置与宏包)
14. [编译方式与常见错误排查](#14-编译方式与常见错误排查)
15. [推荐模板与下一步学习](#15-推荐模板与下一步学习)

---

## 1. LaTeX 是什么

**LaTeX** 是一种基于 TeX 的**排版系统**，特别擅长排版科技文档、论文、书籍。

它和 Word 的「所见即所得」完全不同，LaTeX 是「**所见即所想**」：

- 你写的是**纯文本源码**，内容与格式分离；
- 你通过**命令**告诉 LaTeX「这是标题、这是公式、这是引用」；
- 编译器（如 pdfLaTeX、XeLaTeX）自动生成精美排版的 PDF。

**优点：**

- 排版质量高，公式专业美观；
- 自动编号（章节、公式、图表、参考文献）；
- 自动生成目录、交叉引用；
- 免费、跨平台、纯文本便于版本管理（Git）；
- 学术界标准格式（论文模板、学位论文模板）。

**缺点：**

- 有学习门槛，需要记住命令；
- 不是即时的可视化，需先编译再查看。

> 一句话总结：**你把内容和结构写好，LaTeX 负责把它排得漂亮。**

---

## 2. 注册并创建第一个项目

### 2.1 注册

1. 打开官网：<https://www.overleaf.com>
2. 点击右上角 **Register**，可用邮箱注册（也支持 Google 等第三方登录）。
3. 注册后进入项目列表页面（Dashboard）。

### 2.2 新建项目

1. 点击 **New Project** → **Blank Project**。
2. 输入项目名，比如 `my-first-doc`，点击 **Create**。
3. Overleaf 会自动生成一个项目，包含两个面板：

```
────────────────────────────────────────────
  左侧：源码编辑区   │  右侧：编译预览区     
  main.tex           │  显示编译后的 PDF     
────────────────────────────────────────────
```

### 2.3 界面常用按钮

| 按钮 | 作用 |
|------|------|
| **Recompile**（或 Ctrl+Enter） | 重新编译，刷新 PDF |
| **Menu** | 设置编译器、主文档、字体大小等 |
| **Download** | 下载 PDF 或整个项目源码 |
| **Upload** | 上传本地文件（图片、`.bib`、`.sty` 等） |

> **第一次编译**：Overleaf 免费版默认的编译服务器足以应付学习阶段的文档，无需配置。

---

## 3. LaTeX 源码的基本结构

新建的 `main.tex` 打开后大概长这样：

```latex
\documentclass{article}

\usepackage[utf8]{inputenc}

\title{My first document}
\author{Your Name}

\begin{document}

\maketitle

\section{Introduction}

Hello world!

\end{document}
```

### 3.1 逐行解释

| 代码 | 含义 |
|------|------|
| `\documentclass{article}` | 声明文档类型（article = 文章）。最常用；还有 `report`（报告）、`book`（书）、`beamer`（幻灯片） |
| `\usepackage{...}` | 加载宏包，扩展 LaTeX 功能 |
| `\title{}` / `\author{}` | 定义文档标题和作者 |
| `\begin{document}` | **正文开始**，从这里到 `\end{document}` 之间的内容才会被编译输出 |
| `\maketitle` | 根据上面定义的标题、作者生成标题页（或标题区） |
| `\section{...}` | 一级章节标题 |
| `\end{document}` | **正文结束**，其后内容一律忽略 |

### 3.2 两条铁律

1. **所有命令以 `\` 开头**，后跟命令名（字母）或符号。
2. `\begin{...}` 必须配对 `\end{...}`（环境），漏掉会造成编译错误。

### 3.3 注释

以 `%` 开头的行为注释，不会被编译：

```latex
% 这是注释，不会出现在 PDF 里
\documentclass{article}
```

---

## 4. 中文支持

Overleaf 默认支持中文，推荐使用 **XeLaTeX** 编译器 + `ctex` 宏包。

### 4.1 设置编译器

1. 点击左上角 **Menu**。
2. **Compiler** 一栏选择 **XeLaTeX**。
3. 关闭菜单即可。

### 4.2 最小中文文档

```latex
\documentclass[UTF8]{article}
\usepackage{ctex}

\begin{document}

你好，世界！这是一份中文 LaTeX 文档。

\end{document}
```

> 注意：使用中文 **必须** 用 XeLaTeX 编译（用 `ctex` 宏包时）或改用其他支持中文的方式，否则中文会乱码或报错。

### 4.3 更正式的方案

`ctex` 宏包也支持 `ctexart` 文档类，直接指定字体：

```latex
\documentclass[UTF8, fontset=fandol]{ctexart}

\begin{document}
中文排版测试。
\end{document}
```

`fontset=fandol` 使用开源字体，适合没有中文字体的环境；Overleaf 上也可以不指定，它会自动检测系统字体。

### 4.4 中文缩进

LaTeX 默认段落首行不缩进。中文习惯首行缩进两格，可以用：

```latex
\usepackage{ctex}
\usepackage{indentfirst}   % 首段也缩进
\setlength{\parindent}{2em} % 缩进两个字符宽度
```

---

## 5. 基础排版：字体、字号、段落

### 5.1 段落

- 源码中的空行（一个或多个）产生一个**段落分隔**。
- 单个换行符**不会**换行，会被当成空格处理。

```latex
这是第一段。
    这还是第一段，前面的空格和换行都被忽略。

这是第二段，因为上面有空行。
```

如果想强制换行但不分段，用 `\\` 或 `\newline`：

```latex
第一行 \\ 第二行
```

### 5.2 字体命令

| 命令 | 效果 |
|------|------|
| `\textbf{文字}` | 粗体（bold） |
| `\textit{文字}` | 斜体（italic） |
| `\underline{文字}` | 下划线 |
| `\texttt{文字}` | 等宽字体（适合代码/路径） |
| `\emph{文字}` | 强调（通常在斜体与正体间切换） |
| `\textrm{文字}` | 罗马（正体）字体 |

示例：

```latex
\textbf{粗体}、\textit{斜体}、\underline{下划线}、\texttt{等宽}、\emph{强调}
```

### 5.3 字号

用命令切换字号（`\begin{Large}...\end{Large}` 或 `{\Large 文字}`）：

| 命令 | 字号 |
|------|------|
| `\tiny` | 极小 |
| `\scriptsize` | 脚注大小 |
| `\small` | 小 |
| `\normalsize` | 正常（默认） |
| `\large` | 大 |
| `\Large` | 更大 |
| `\LARGE` | 再大 |
| `\huge` | 很大 |
| `\Huge` | 最大 |

```latex
{\LARGE 这是很大的字} 后面恢复正常大小
```

### 5.4 行距

```latex
\usepackage{setspace}
\linespread{1.5}        % 全局行距 1.5 倍
% 或局部
\begin{spacing}{1.8}
这一段是 1.8 倍行距。
\end{spacing}
```

### 5.5 特殊符号

LaTeX 中 `% # & _ { } $` 是特殊字符，需要转义才能输出：

| 想输出 | 写法 |
|--------|------|
| `%` | `\%` |
| `#` | `\#` |
| `&` | `\&` |
| `_` | `\_` |
| `{` | `\{` |
| `}` | `\}` |
| `$` | `\$` |
| `\` | `\textbackslash` |
| `~` | `\textasciitilde` |

---

## 6. 标题与章节

### 6.1 章节层级（article 类）

```latex
\section{一级标题}
\subsection{二级标题}
\subsubsection{三级标题}
\paragraph{段落标题}
\subparagraph{子段落标题}
```

数字编号由 LaTeX 自动生成。如果不想编号：

```latex
\section*{不带编号的标题}
```

> `\section*` 不会出现在目录中，需要手动加目录项时用 `\addcontentsline`（见 6.3）。

### 6.2 标题页

```latex
\title{我的毕业论文}
\author{张三 \and 李四}
\date{2026 年 7 月}      % 不写则默认编译当天日期
\maketitle
```

`\date{}` 留空可隐藏日期。

### 6.3 生成目录

```latex
\tableofcontents
```

放在 `\begin{document}` 之后即可。**注意：** 目录需要编译 **两次** 才会完整显示（Overleaf 的 Recompile 按钮会自动多次编译，一般无感）。

---

## 7. 列表

### 7.1 无序列表 `itemize`

```latex
\begin{itemize}
  \item 第一项
  \item 第二项
  \item 第三项
\end{itemize}
```

### 7.2 有序列表 `enumerate`

```latex
\begin{enumerate}
  \item 第一步
  \item 第二步
  \item 第三步
\end{enumerate}
```

### 7.3 描述列表 `description`

```latex
\begin{description}
  \item[LaTeX] 一个排版系统
  \item[TeX] LaTeX 的底层引擎
\end{description}
```

### 7.4 嵌套列表

列表可以互相嵌套，会自动换符号或编号格式：

```latex
\begin{enumerate}
  \item 第一层
  \begin{itemize}
    \item 第二层无序
    \item 继续
  \end{itemize}
  \item 回到第一层
\end{enumerate}
```

---

## 8. 表格

### 8.1 基础表格（tabular 环境）

```latex
\begin{tabular}{|l|c|r|}
  \hline
  左对齐 & 居中 & 右对齐 \\
  \hline
  A & B & C \\
  D & E & F \\
  \hline
\end{tabular}
```

列格式说明：

| 参数 | 含义 |
|------|------|
| `l` | 左对齐列 |
| `c` | 居中列 |
| `r` | 右对齐列 |
| `|` | 竖直分隔线 |
| `p{2cm}` | 固定宽度、自动换行的段落列 |

行内用 `&` 分隔单元格，用 `\\` 结束一行，`\hline` 画水平线。

### 8.2 带标题、居中、跨列的表格

```latex
\begin{table}[htbp]
  \centering
  \caption{成绩表}
  \begin{tabular}{|c|c|c|}
    \hline
    姓名 & 科目 & 分数 \\
    \hline
    张三 & 数学 & 95 \\
    张三 & 语文 & 88 \\
    \hline
  \end{tabular}
\end{table}
```

- `\caption{...}` 给表格加编号与标题，标题会自动编号为「表 1」。
- 位置参数 `[htbp]`：`h` 在此处，`t` 页顶，`b` 页底，`p` 独立一页。LaTeX 会综合安排，多数情况用 `[htbp]` 或 `[ht]`。

### 8.3 合并单元格

需要 `multirow` 宏包：

```latex
\usepackage{multirow}

\begin{tabular}{|c|c|}
  \hline
  \multirow{2}{*}{跨两行} & 第一行 \\
                         & 第二行 \\
  \hline
\end{tabular}
```

`\multicolumn{列数}{格式}{内容}` 用于跨列：

```latex
\begin{tabular}{|c|c|c|}
  \hline
  \multicolumn{3}{|c|}{跨三列的标题行} \\
  \hline
  A & B & C \\
  \hline
\end{tabular}
```

### 8.4 更美观的表格

推荐 `booktabs` 宏包（学术论文常用，三线表）：

```latex
\usepackage{booktabs}

\begin{table}[htbp]
  \centering
  \caption{三线表示例}
  \begin{tabular}{lcr}
    \toprule
    姓名 & 科目 & 分数 \\
    \midrule
    张三 & 数学 & 95 \\
    李四 & 语文 & 88 \\
    \bottomrule
  \end{tabular}
\end{table}
```

---

## 9. 插图

### 9.1 上传图片

1. 点击 Overleaf 左侧文件列表的 **Upload**（上传）按钮；
2. 选择本地图片（推荐 **PDF / PNG / JPG** 格式）；
3. 图片会出现在文件列表中，与 `main.tex` 同目录。

### 9.2 插入图片

```latex
\usepackage{graphicx}

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.6\textwidth]{myimage.png}
  \caption{这里是图的标题}
  \label{fig:example}
\end{figure}
```

- `\includegraphics` 路径是图片文件名（含相对路径，如 `figures/logo.png`）。
- 可选参数调整尺寸：
  - `width=0.6\textwidth`：占页面宽度的 60%；
  - `height=3cm`：固定高度；
  - `scale=0.5`：按比例缩放；
  - `angle=90`：旋转。
- `\caption{}` 自动编号为「图 1」，`\label{}` 用于交叉引用（见第 11 节）。
- **注意**：不要把图放进 `[htbp]` 之外的裸位置，`figure` 是浮动体，会自动找合适位置。

> **经验**：图片太大时可写 `width=\textwidth`，太小时写 `width=0.4\textwidth`，避免溢出页面。

---

## 10. 数学公式

这是 LaTeX 的**杀手锏**，务必掌握。

### 10.1 行内公式

用 `$...$` 包裹：

```latex
欧拉公式 $e^{i\pi}+1=0$ 非常优美。
$a^2 + b^2 = c^2$ 是勾股定理。
```

### 10.2 行间公式（独立成行、自动编号）

用 `equation` 环境：

```latex
\begin{equation}
  E = mc^2
\end{equation}
```

带标签的编号公式（引用见 11 节）：

```latex
\begin{equation}
  x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}
  \label{eq:quadratic}
\end{equation}
```

不想编号用 `equation*` 或 `\[...\]`：

```latex
\[
  \int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
\]
```

### 10.3 多行公式（align）

```latex
\usepackage{amsmath}

\begin{align}
  2x + y &= 5 \\
  3x - y &= 0
\end{align}
```

`&` 是对齐位置，`\\` 换行。不带编号用 `align*`。

### 10.4 常用数学符号速查

| 写法 | 显示 | 写法 | 显示 |
|------|------|------|------|
| `x^2` | x² | `x_i` | xᵢ |
| `\frac{a}{b}` | a/b | `\sqrt{x}` | √x |
| `\sqrt[3]{x}` | ∛x | `\pm` | ± |
| `\times` | × | `\div` | ÷ |
| `\leq` | ≤ | `\geq` | ≥ |
| `\neq` | ≠ | `\approx` | ≈ |
| `\infty` | ∞ | `\alpha, \beta, \gamma` | α, β, γ |
| `\pi` | π | `\theta` | θ |
| `\sum_{i=1}^{n}` | 求和 | `\prod` | 连乘 |
| `\int_a^b` | 定积分 | `\partial` | ∂ |
| `\lim_{x \to 0}` | 极限 | `\rightarrow` | → |
| `\in` | ∈ | `\subset` | ⊂ |
| `\cup` | ∪ | `\cap` | ∩ |
| `\forall` | ∀ | `\exists` | ∃ |
| `\bar{x}` | x̄ | `\hat{x}` | x̂ |
| `\dot{x}` | ẋ | `\vec{v}` | v⃗ |
| `\text{文字}` | 公式中的文字 | `\,` | 小空格 |

### 10.5 常用结构示例

```latex
\begin{equation}
  \lim_{n \to \infty} \left( 1 + \frac{1}{n} \right)^n = e
\end{equation}
```

```latex
\begin{equation}
  P(A \mid B) = \frac{P(B \mid A) P(A)}{P(B)}
\end{equation}
```

`\left( ... \right)` 会自动调节括号大小（对应右括号用 `\right.` 可隐藏）。

### 10.6 数学字体

| 写法 | 含义 |
|------|------|
| `\mathbb{R}` | 黑板粗体（需要 `amsfonts`/`amssymb`） |
| `\mathcal{L}` | 花体 |
| `\mathbf{x}` | 粗体 |
| `\mathrm{d}x` | 正体（微分 d） |
| `\bm{x}` | 斜体粗体（需要 `bm` 宏包） |

---

## 11. 交叉引用与超链接

### 11.1 标签与引用

用 `\label{}` 打标记，用 `\ref{}` / `\pageref{}` 引用：

```latex
% 图表/章节
\section{方法}\label{sec:method}
如图 \ref{fig:example} 所示……
详见第 \ref{sec:method} 节（第 \pageref{sec:method} 页）。

% 公式
\begin{equation}
  E = mc^2 \label{eq:energy}
\end{equation}
公式 \ref{eq:energy} 是质能方程。
```

> **注意**：交叉引用需要 **编译两次** 才能显示正确编号，Overleaf 一般会自动处理。

### 11.2 超链接与书签

```latex
\usepackage{hyperref}
```

加载后，目录、引用、网址自动变成可点击的链接。自定义颜色：

```latex
\usepackage[colorlinks=true, linkcolor=blue, urlcolor=cyan]{hyperref}
```

插入网址：

```latex
\href{https://www.overleaf.com}{Overleaf 官网}
\url{https://www.overleaf.com}
```

> 强烈建议把 `hyperref` 放在**最后一个**宏包加载。

---

## 12. 代码块（lstlisting）

写编程教程、算法时用 `listings` 宏包展示代码：

```latex
\usepackage{listings}

\lstset{
  language=Python,
  basicstyle=\ttfamily\small,
  numbers=left,           % 行号在左侧
  numberstyle=\tiny,
  keywordstyle=\color{blue},
  commentstyle=\color{gray},
  frame=single,           % 外框
  breaklines=true         % 长行自动换行
}
```

正文中使用：

```latex
\begin{lstlisting}
def hello(name):
    print(f"Hello, {name}!")
\end{lstlisting}
```

需要**高亮颜色**时加载 `xcolor`：

```latex
\usepackage{xcolor}
```

更现代的方案是 `minted` 宏包（需要编译时联网安装 Python 的 Pygments，Overleaf 免费版可用，但编译较慢）：

```latex
\usepackage{minted}
\begin{minted}{python}
print("hello")
\end{minted}
```

---

## 13. 页面设置与宏包

### 13.1 页面边距

```latex
\usepackage{geometry}
\geometry{top=2.5cm, bottom=2.5cm, left=3cm, right=3cm}
% 或简便写法
\usepackage[margin=2.5cm]{geometry}
\usepackage[margin=2.5cm, a4paper]{geometry}
```

### 13.2 页眉页脚

```latex
\usepackage{fancyhdr}

\pagestyle{fancy}
\fancyhead[L]{左侧页眉}
\fancyhead[C]{居中页眉}
\fancyhead[R]{\thepage}
\fancyfoot[C]{页脚居中内容}
```

`\thepage` 输出当前页码。

### 13.3 常用宏包清单

| 宏包 | 用途 |
|------|------|
| `ctex` | 中文支持 |
| `amsmath` | 数学公式增强（必装） |
| `amssymb` | 数学符号 |
| `graphicx` | 插图 |
| `geometry` | 页面边距 |
| `hyperref` | 超链接、PDF 书签 |
| `fancyhdr` | 页眉页脚 |
| `setspace` | 行距 |
| `booktabs` | 三线表 |
| `multirow` | 表格合并 |
| `listings` / `minted` | 代码块 |
| `xcolor` | 颜色 |
| `titlesec` | 自定义标题格式 |
| `enumitem` | 自定义列表 |
| `caption` | 自定义图表标题 |
| `natbib` / `biblatex` | 参考文献 |

加载格式：`\usepackage[选项]{宏包名}`。

> 找不到某个宏包时，可在 Overleaf 左侧工具栏打开 **TexLive 宏包库** 搜索并点击安装（免费版可手动添加宏包）。

---

## 14. 编译方式与常见错误排查

### 14.1 选择编译器（Menu → Compiler）

| 编译器 | 适用场景 |
|--------|----------|
| **pdfLaTeX** | 默认，最通用，但直接写中文会出问题 |
| **XeLaTeX** | 中文文档首选，配合 `ctex` |
| **LuaLaTeX** | 类似 XeLaTeX，适合特殊字体/复杂排版 |

### 14.2 Overleaf 的编译行为

- 点 **Recompile** 后 Overleaf 自动执行多次编译（一次用于引用、一次用于目录），多数情况下你不用操心。
- 若改了主文件（比如把 `main.tex` 重命名），在 **Menu → Main document** 里重新指定。

### 14.3 常见错误与解决办法

| 报错示例 | 原因 | 解决 |
|----------|------|------|
| `! Undefined control sequence.` | 命令名拼错或宏包未加载 | 检查 `\` 命令拼写，加载对应宏包 |
| `! File not found.` | 图片/`.bib` 文件缺失或路径不对 | 上传文件或修正相对路径 |
| `! LaTeX Error: Environment xxx undefined.` | 用了未加载宏包的环境 | `\usepackage{对应宏包}` |
| `! Missing $ inserted.` | 数学符号写在了公式外 | 用 `$...$` 或 `\[...\]` 包裹 |
| `! Extra }, or forgotten $.` | 花括号/`$` 不配对 | 检查配对 |
| `! Not in outer par mode.` | 浮动体（figure/table）放在不当位置 | 用 `\begin{figure}[htbp]` |
| 中文乱码/方块 | 没用 XeLaTeX 或缺少 `ctex` | 切 XeLaTeX，加 `\usepackage{ctex}` |
| `! Package inputenc Error` | 源文件编码问题 | 改用 XeLaTeX + `ctex` |
| 引用显示为 `??` | 未编译两次 | 再编译一次 |
| 编译超时 | 图片过大、宏包过多 | 压缩图片，简化宏包 |

### 14.4 排查技巧

1. 把报错往上翻，**第一个** `!` 才是真正错误，后面的往往是连锁反应。
2. 注释掉报错行附近的代码（`%`），缩小范围。
3. 养成「改一点、编译一次」的习惯，方便定位问题。
4. 用日志区（Overleaf 下方 Logs）查找具体出错的行号。

---

## 15. 推荐模板与下一步学习

### 15.1 Overleaf 模板库

Overleaf 内置大量模板，全部免费使用：

1. 点击左上角 **New Project → 选择一个模板**（或访问 <https://www.overleaf.com/latex/templates>）。
2. 搜索：`Resume`（简历）、`Paper`、`Thesis`、`Beamer`（幻灯片）等。
3. 打开模板后 `Ctrl+C` / `Ctrl+V` 改内容即可。

### 15.2 常用文档类速览

| 文档类 | 用途 |
|--------|------|
| `article` | 文章、论文、作业 |
| `report` | 长报告、毕业论文 |
| `book` | 书籍、厚文档 |
| `beamer` | 幻灯片（PPT 的 LaTeX 版） |
| `ctexart` / `ctexbook` | 中文文章 / 中文书籍 |

### 15.3 下一步进阶方向

1. **参考文献**：学 `natbib` + BibTeX（`.bib` 文件），或 `biblatex`。
2. **TikZ 绘图**：用代码画流程图、电路图、拓扑图。
3. **Beamer 幻灯片**：用 LaTeX 做演示。
4. **自定义命令**：`\newcommand{\R}{\mathbb{R}}` 简化重复书写。
5. **CTeX 中文模板**：各高校学位论文模板通常基于 `ctexbook`。
6. **Git 集成**：Overleaf 支持连接 GitHub，方便版本管理。

### 15.4 学习资源

- 官方帮助文档：<https://www.overleaf.com/learn>
- 中文参考文档（lshort-zh-cn，含中文版教程）：<https://texdoc.org/>
- CTAN（宏包仓库）：<https://ctan.org/>
- TeX Stack Exchange：<https://tex.stackexchange.com/>

---

## 附录：一个完整可运行的示例

把下面的内容完整粘贴到 Overleaf 的 `main.tex`（记得在 **Menu** 中把编译器改为 **XeLaTeX**），点 Recompile 就能看到效果：

```latex
\documentclass[UTF8]{article}

\usepackage{ctex}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{geometry}
\geometry{margin=2.5cm}
\usepackage[colorlinks=true]{hyperref}

\title{\LaTeX{} 入门示例}
\author{张三}
\date{2026 年 7 月}

\begin{document}

\maketitle
\tableofcontents

\section{引言}
这是一份 \LaTeX{} 中文示例文档。
欧拉公式 $e^{i\pi}+1=0$ 被称为最美丽的数学公式。

\section{数学公式}
\begin{equation}
  \label{eq:gauss}
  \sum_{i=1}^{n} i = \frac{n(n+1)}{2}
\end{equation}

由公式 \eqref{eq:gauss} 可知，前 $n$ 个自然数之和如上式所示。

\section{表格与插图}
成绩表如表 \ref{tab:score} 所示。

\begin{table}[htbp]
  \centering
  \caption{成绩表}
  \label{tab:score}
  \begin{tabular}{lcc}
    \toprule
    姓名 & 数学 & 语文 \\
    \midrule
    张三 & 95 & 88 \\
    李四 & 92 & 97 \\
    \bottomrule
  \end{tabular}
\end{table}

\begin{figure}[htbp]
  \centering
  % 请先上传一张名为 example.png 的图片
  % \includegraphics[width=0.5\textwidth]{example.png}
  \caption{示例图片（上传后取消上面一行注释）}
  \label{fig:demo}
\end{figure}

\section{代码}
\begin{verbatim}
print("Hello, LaTeX!")
\end{verbatim}

\end{document}
```

> `\verb` / `verbatim` 环境可以原样输出代码而不解析 LaTeX 命令。

---

### 快速记忆卡

```
文档骨架   : \documentclass → \usepackage → \begin{document} → ... → \end{document}
注释       : %
中文       : XeLaTeX + \usepackage{ctex}
行内公式   : $...$
行间公式   : \[...\]  或  \begin{equation}
插图       : \usepackage{graphicx} + \includegraphics
表格       : tabular（无编号）/ table + caption（编号）
引用       : \label{xxx} ... \ref{xxx}
目录       : \tableofcontents（编译两次）
页码       : \thepage
```

祝你学习愉快，从此告别手调格式的烦恼！
