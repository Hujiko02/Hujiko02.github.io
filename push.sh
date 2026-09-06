#!/bin/bash

git add .

# 如果有命令行参数就直接用，否则询问用户
if [ -n "$1" ]; then
    commit_msg="$1"
else
    read -p "请输入提交信息（回车为自动信息）: " commit_msg
fi

# 如果仍然为空（用户按了回车），使用默认值
git commit -m "${commit_msg:-Auto update $(date '+%Y-%m-%d %H:%M:%S')}"

git pull origin main --rebase --autostash
git push origin main
venv/bin/python -m mkdocs gh-deploy --force
