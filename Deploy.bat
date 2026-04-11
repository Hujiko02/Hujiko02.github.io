@echo off
chcp 65001 >nul
echo ========================================
echo    MkDocs Deploy Script
echo ========================================
echo.

if not exist "mkdocs.yml" (
    echo [ERROR] Run this script in the directory containing mkdocs.yml!
    pause
    exit /b 1
)

echo [1/3] Staging changes...
git add .
set /p commit_msg="Enter commit message (or press Enter for auto): "
if "%commit_msg%"=="" set commit_msg=Auto update %date% %time%
git commit -m "%commit_msg%"
if errorlevel 1 (
    echo [INFO] Nothing to commit or commit failed.
)

echo [2/3] Syncing with remote...
git pull origin main --rebase --autostash
git push origin main
if errorlevel 1 (
    echo [ERROR] Push failed.
    pause
    exit /b 1
)

echo [3/3] Building and deploying...
REM Use 'py' instead of 'python' for Windows
py -m mkdocs gh-deploy --force
if errorlevel 1 (
    echo [ERROR] Deployment failed. Check MkDocs configuration.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Website will be available soon at:
echo https://Hujiko02.github.io
echo ========================================
timeout /t 5