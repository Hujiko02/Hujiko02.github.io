# HuJi Notes

本站由 HTML 和 [Tufte CSS](https://edwardtufte.github.io/tufte-css/) 制作。

线上地址：<https://hujiko02.github.io>

## 目录

- `assets/` —— 样式、图片、第三方 JS（KaTeX）与自托管字体
- `assets/fonts/` —— 宋体与等宽的 woff2 子集，**生成方式见该目录的 README**
- `tools/build-fonts.py` —— 重新切字体的脚本（正文出现新汉字后重跑一次）
- `push.sh` —— 提交并推送；GitHub Pages 直接从 main 分支根目录发布，没有构建步骤

字体改动（加字、换字体、调 `unicode-range`）要看 `assets/fonts/README.md`，
里面写了字符集、体积、源字体路径和需要同步改的 CSS 位置。
