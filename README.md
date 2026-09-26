# HuJi Notes

## 关于本站

这是使用 Zensical 和 Material 主题（modern 变体）构建的静态个人网站。

[https://hujiko02.github.io](https://hujiko02.github.io "一个网站")

**用于记录所思所想**

## 构建与预览

配置仍是 `mkdocs.yml`（Zensical 原生读取），但里面已使用 Zensical 命名空间，
**`mkdocs build` 不再可用**；MkDocs 作为回退路径已放弃，需要时回退 emoji 命名空间即可。

```bash
# 首次：本地虚拟环境（Zensical 0.0.x，alpha，按需升版本号）
python3 -m venv .venv
.venv/bin/pip install -i https://pypi.tuna.tsinghua.edu.cn/simple zensical==0.0.65 ghp-import

# 预览：http://localhost:8000
.venv/bin/zensical serve

# 构建产物写到 site/
.venv/bin/zensical build

# 提交 + 部署到 gh-pages
./push.sh "提交信息"
```

## 与原 MkDocs 版的差异

| 项 | 改动 |
| --- | --- |
| 主题 | 新增 `theme.variant: modern`（新外观；换 `classic` 即回到 Material 原样） |
| 站点目录 | 显式 `site_dir: site`（Zensical 不支持 `--site-dir` 参数） |
| 图标 | emoji 命名空间改为 `zensical.extensions.emoji.*`，并显式声明 `options.custom_icons` 才能用 `overrides/.icons/huji.svg` |
| 搜索 | 移除 `search.suggest`：Zensical 搜索是自研引擎，没有 Lunr 的 suggest；保留 `search.highlight` |
| `not_in_nav` | Zensical 会静默忽略（页面照常生成），保留该行只为语义清楚 |
| 部署 | 没有 `mkdocs gh-deploy`，`push.sh` 改为 `zensical build` + `ghp-import -n -p -f site` |
| CSS | 删掉滚动条偏移修正（`scrollbar-gutter: stable`），只保留字体链 |
