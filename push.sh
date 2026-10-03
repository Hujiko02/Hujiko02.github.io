#!/bin/bash
# 提交并推送。GitHub Pages 从 main 分支根目录直接发布，不需要本地构建，
# 也没有 GitHub Actions（见 README）。
# 桌面和 Termux 用同一个脚本。
# 用法：./push.sh [提交信息]（不传则用时间戳信息）
set -e
cd "$(dirname "$0")"

git add -A
git diff --cached --quiet ||
  git commit -m "${1:-docs: update $(date '+%F %T')}"

# 多机协作：远端可能已有新提交，先 rebase 再推
if ! git pull origin main --rebase --autostash; then
  cat >&2 <<'EOF'

    rebase 冲突：远端和你本地改了同一处内容（比如同一篇文章同时改了两边）。
    当前状态是「rebase 进行中」，你的本地提交还在，没有丢。
    解决：改好冲突文件 → git add <文件> → git rebase --continue → ./push.sh
    放弃这次 rebase（保留本地提交，回到推送前的样子）：git rebase --abort
EOF
  exit 1
fi

git push origin main
