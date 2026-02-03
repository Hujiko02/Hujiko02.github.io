@echo off
echo 【MkDocs 一键部署程序】
echo.

REM 1. 检查是否在项目目录
if not exist "mkdocs.yml" (
    echo 错误：未在MkDocs项目根目录中。
    pause
    exit /b 1
)

REM 2. 提交所有更改到源码分支（默认为main）
echo 正在提交源码更改...
git add .
set /p commit_msg=请输入本次更新的说明：
git commit -m "%commit_msg%"
git push origin main
if errorlevel 1 (
    echo 注意：推送源码到GitHub时遇到问题，可能无需提交或无网络。
)
echo.

REM 3. 构建并部署到GitHub Pages
echo 正在构建并部署网站...
python -m mkdocs gh-deploy --force
echo.

REM 4. 完成
echo ============ 部署完成 ============
echo 请等待 1-2 分钟，然后访问您的网站：
echo https://Hujiko02.github.io
echo ==================================
timeout /t 5