# assets/fonts —— 自托管的字体子集

本站原来只靠 `local()` 用访客系统里的宋体（见 `assets/tufte/local.css` 的历史注释），
问题是每个人看到的字形其实不一样：macOS 上是 Songti SC，Windows 上只有 SimSun，
装过思源宋体的人才拿到 Noto。所以这里放三份切好的 woff2，由 `@font-face` 的 `url()`
优先加载，全站字形统一。

| 文件 | 内容 | 体积 |
| --- | --- | --- |
| `noto-serif-sc-400.woff2` | 正文宋体，常规 | 746 KB |
| `noto-serif-sc-700.woff2` | 正文宋体，加粗 | 784 KB |
| `jetbrains-maple-mono-400.woff2` | 代码等宽，只含拉丁与符号 | 37 KB |
| `LICENSE-OFL.txt` | 两份上游字体的 SIL OFL 1.1 许可证 | — |

## 字符集

**宋体两份一样**（合计 3939 字符）：

- GB2312 一级汉字，区 16–55，共 3755 字
- 本站 HTML 里实际用到、但不属于一级汉字的 13 个汉字（目前是 `啰嗦橘泾浏渲癖莓诠遢邋锏阱`），
  由脚本自动扫描 HTML 得出，避免这些字在句子里中途掉回系统字体
- 中文标点 `U+3000-303F`、全角标点 `U+FF01-FF5E` `U+FFE0-FFE6`

拉丁字母**不**切进宋体：正文拉丁走 tufte.css 自带的 et-book，所以 `@font-face` 的
`unicode-range` 也不含拉丁区。

**等宽**：ASCII、Latin-1、通用标点、箭头、框线/块元素/几何图形、杂项与装饰符号、
盲文点阵、Nerd Font 私有区（Powerline 等），保留 `liga` / `calt`，连字照常。
**不含汉字** —— 代码块里的中文由字体栈的下一个族（`Noto Sans Mono CJK SC` 等系统等宽）
逐字兜底。这份字体的 CN 版切上一级汉字会从 37 KB 涨到 953 KB，为几个中文注释不值。

子集里没有的字（例如没用到的二级汉字、emoji、`∛` `⌈` 这类 Noto 本身就没有的符号）
不会变成豆腐：浏览器按字体栈逐字回退，只有那几个字字形不一致。

## 重新生成

```bash
python3 tools/build-fonts.py            # 生成到 assets/fonts/
python3 tools/build-fonts.py --check    # 只报告字符集与缺字，不写文件
```

依赖 `fontTools`（含 `brotli`）：`pip install fonttools brotli`。
脚本会自动扫描仓库里所有 HTML 收集用字，所以**正文新出现的二级汉字只要重跑一次就会补进去**，
补完记得重新 `push`。

字体源在本机按以下顺序查找，找不到会报错并提示用环境变量指定：

| 用途 | 默认路径 | 环境变量 |
| --- | --- | --- |
| 宋体 400 | COMSOL 目录的 `NotoSerifSC-Regular.otf`（Google 静态版，切出来只有 TTC 的一半大） | `SITE_FONT_SERIF_400` |
| 宋体 700 | 同上 `-Bold.otf` | `SITE_FONT_SERIF_700` |
| 等宽 400 | `/usr/local/share/fonts/j/JetBrainsMapleMono_Regular.ttf` | `SITE_FONT_MONO` |

宋体源里也列了 `/usr/share/fonts/opentype/noto/NotoSerifCJK-{Regular,Bold}.ttc` 作为备选，
脚本会自动抽出第 2 面（`Noto Serif CJK SC`）。TTC 是 v2.003、Google 静态版是 v1.001，
实测两者 advance width 与 hhea 度量一致，可以互换；TTC 切出来约大 90%。

## 改了要同步的地方

- `assets/tufte/local.css` 里有三个 `@font-face`，`unicode-range` 与上面的字符集范围一一对应。
  改了 `tools/build-fonts.py` 里的 `SERIF_EXTRA_RANGES` / `MONO_RANGES`，CSS 里的
  `unicode-range` 也要跟着改。
- `size-adjust: 88%`（只在宋体的两个面上）是按 Noto 汉字字面 0.91em 调的，
  换成别的字体源要重新校准，否则中文字号会变。
- 12 个页面的 `<head>` 里有 `noto-serif-sc-400.woff2` 的 `preload`（只有 400，700 让它按需下）。
  新增页面时照抄那一行，路径前缀按层级写 `./` 或 `../`。
- `verilog.html` 用 `assets/tufte/homework.css`，那是打印作业的独立文档，
  刻意用 Times New Roman + 思源宋体，**不**吃这套 webfont，别顺手改。
