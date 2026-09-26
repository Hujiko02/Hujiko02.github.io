#!/bin/bash
# Zensical 版部署脚本（Zensical 没有 mkdocs 的 gh-deploy 子命令）

set -e

# 无论从哪里调用，都切回仓库根目录
cd "$(dirname "$0")"

# 本项目用的是本地虚拟环境，先激活（没建 venv 就依赖 PATH 里的命令）
if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

git add .

# 如果有命令行参数就直接用，否则询问用户
if [ -n "$1" ]; then
    commit_msg="$1"
else
    read -p "请输入提交信息（回车为自动信息）: " commit_msg
fi

# 没有暂存改动时 git commit 会返回 1，在 set -e 下会直接中断脚本（后面就不构建、不部署了）
if git diff --cached --quiet; then
    echo "没有需要提交的改动，跳过 commit"
else
    # 如果仍然为空（用户按了回车），使用默认值
    git commit -m "${commit_msg:-Auto update $(date '+%Y-%m-%d %H:%M:%S')}"
fi

git pull origin main --rebase --autostash
git push origin main

# 构建静态站点（site_dir: site，见 mkdocs.yml）
zensical build

# 发布到 gh-pages 分支，等价于原来的 mkdocs gh-deploy
# ghp-import 与 mkdocs gh-deploy 的底层实现相同：把 site/ 提交到 gh-pages 并推送
ghp-import -n -p -f site
