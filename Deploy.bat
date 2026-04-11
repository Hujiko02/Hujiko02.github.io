@echo off
chcp 65001 >nul
echo ========================================
echo    MkDocs 一键部署程序
echo ========================================
echo.

REM 检查是否在项目根目录
if not exist "mkdocs.yml" (
    echo [错误] 请在包含 mkdocs.yml 的目录中运行此脚本！
    pause
    exit /b 1
)

REM 1. 提交源码更改
echo [1/3] 正在提交源码...
git add .
set /p commit_msg="请输入本次更新说明（直接回车则使用默认）: "
if "%commit_msg%"=="" set commit_msg=自动更新 %date% %time%
git commit -m "%commit_msg%"
if errorlevel 1 (
    echo [提示] 没有需要提交的更改，或提交失败。
)

REM 2. 拉取远程更新并推送
echo [2/3] 正在同步远程仓库...
git pull origin main --rebase --autostash
git push origin main
if errorlevel 1 (
    echo [错误] 推送失败，请检查网络或手动处理冲突。
    pause
    exit /b 1
)

REM 3. 部署到 GitHub Pages
echo [3/3] 正在构建并部署网站...
python -m mkdocs gh-deploy --force
if errorlevel 1 (
    echo [错误] 部署失败，请检查 MkDocs 配置。
    pause
    exit /b 1
)

echo.
echo ========================================
echo 部署成功！网站稍后即可访问：
echo https://Hujiko02.github.io
echo ========================================
timeout /t 5