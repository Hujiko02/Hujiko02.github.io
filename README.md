# HuJi Notes

## 关于本站

这是使用 Zensical 和 Material 主题（modern 变体）构建的静态个人网站。

[https://hujiko02.github.io](https://hujiko02.github.io "一个网站")

**用于记录所思所想**

## 日常工作流

改 `docs/` 里的 Markdown，然后（桌面和 Termux 完全一样）：

```bash
./push.sh "本次改动说明"
```

`push.sh` **只做 git 操作**（提交 → 拉取 --rebase → 推送）。构建和部署交给 GitHub Actions：
push 到 `main` 后云端自动跑 `zensical build --clean --strict`，再把产物强推到 `gh-pages` 分支
（GitHub Pages 仍从这个分支发布，仓库设置无需变更）。

- 进度和日志：仓库的 **Actions** 标签页
- 一般 push 后 30~60 秒生效，失败会有邮件通知

## 本地预览（可选，只有桌面需要）

```bash
cd ~/Desktop/site
.venv/bin/zensical serve        # http://localhost:8000
```

换新机器时重建环境：

```bash
python3 -m venv .venv
.venv/bin/pip install -i https://pypi.tuna.tsinghua.edu.cn/simple zensical==0.0.65
```

## Termux / 手机端

只写文档、只 `git push`，**不需要装任何 python 包**。

Zensical 目前只发 glibc(manylinux) 和 musl 轮子，没有 Android/bionic 轮子，
Termux 里装不上，构建一律交给 Actions。

## 配置文件

配置仍叫 `mkdocs.yml`（Zensical 的配置发现机制认这个名字，不是遗留没删）。

## 与原 MkDocs 版的差异

| 项 | 改动 |
| --- | --- |
| 主题 | 新增 `theme.variant: modern`（新外观；换 `classic` 即回到 Material 原样） |
| 站点目录 | 显式 `site_dir: site`（Zensical 不支持 `--site-dir` 参数） |
| 图标 | emoji 命名空间改为 `zensical.extensions.emoji.*`，并显式声明 `options.custom_icons` 才能用 `overrides/.icons/huji.svg` |
| 搜索 | 移除 `search.suggest`：Zensical 搜索是自研引擎，没有 Lunr 的 suggest；保留 `search.highlight` |
| `not_in_nav` | Zensical 会静默忽略（页面照常生成），保留该行只为语义清楚 |
| 部署 | 没有 `mkdocs gh-deploy`，改由 `.github/workflows/docs.yml` 用 `zensical build` + `ghp-import` 发布 |
| CSS | 删掉滚动条偏移修正（`scrollbar-gutter: stable`），Zensical 主题已内置；只保留字体链 |

## 已知差异

- **中文搜索**：Zensical 忽略 `search.lang` / `jieba_dict`，没有 jieba 分词，只按空白和标点切词，
  中文长句的召回率可能低于 Material。
- **Safari < 18.2**：不支持 `scrollbar-gutter`，换页时可能有横向抖动（Zensical 未提供兜底）。
