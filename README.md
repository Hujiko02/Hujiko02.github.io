# HuJi Notes

纯手写 HTML + [tufte-css](https://edwardtufte.github.io/tufte-css/)，**没有构建步骤**，改完推送即上线。

线上地址：<https://hujiko02.github.io>

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `index.html` | 首页 |
| `about/index.html` | 关于我 |
| `diary/` | 日记，按年份分页（`2026.html`） |
| `tutorial/` | 教程：`latex` / `markdown` / `matplotlib` / `pico` / `verilog` |
| `ohush-privacy/index.html` | **Ohush 应用的隐私政策。应用商店里填的就是这个 URL，不要删、不要改名** |
| `assets/tufte/tufte.css` | 官方样式表，保持原样不动 |
| `assets/tufte/local.css` | 本地覆写层：中文回退链、表格三线、h4~h6 |
| `assets/katex/` | KaTeX，本地自托管。目前只有 `tutorial/katex_test.html` 在用 |
| `assets/images/` | 图片 |
| `BingSiteAuth.xml` | Bing 站点验证文件，**必须留在根目录** |
| `.nojekyll` | 关掉 GitHub Pages 的 Jekyll 处理，别删 |

## 部署

GitHub Pages 设置为 **Deploy from a branch → `main` → `/ (root)`**。
没有 GitHub Actions，没有构建，`./push.sh` 推上去大约半分钟生效。

## 写内容时的注意

教程页和 `ohush-privacy/` 是由 markdown 生成的（**源 markdown 不在本仓库里**，
已迁移完成后移除，另有备份）。所以改文字就是直接改 HTML。

排版方面有一条容易踩的规则：tufte 的边注（`.sidenote` / `.marginnote`）靠
「`<p>` 是 `<section>` 的直接子元素」来定位，也不能把块级元素塞进带边注的 `<p>`
里，否则边注会飞出屏幕。

样式规则只写在 `assets/tufte/local.css`，官方 `tufte.css` 保持与上游一致。
