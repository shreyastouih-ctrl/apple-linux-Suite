@echo off
TITLE Apple-Linux-Suite One-Click GitHub Publisher
COLOR 0A
echo =================================================================
echo    🍏 APPLE-LINUX-SUITE ONE-CLICK GITHUB PUBLISHER 🐧
echo =================================================================
echo.

:: Check for Git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Git command not found in PATH. Attempting automatic installation via winget...
    winget install --id Git.Git -e --source winget
    if %errorlevel% neq 0 (
        echo [X] Winget unavailable or installation requires admin prompt.
        echo Please install Git from https://git-scm.com/downloads and run this script again.
        pause
        exit /b 1
    )
    :: Add Git to current session PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

echo [+] Initializing Git Repository...
git init

echo [+] Staging all project files and images...
git add .

echo [+] Creating Initial Commit...
git commit -m "Initial release of Apple-Linux-Suite with hardware drivers, OS recommender, offline self-healing, and guides"

echo [+] Setting remote branch to main...
git branch -M main

echo [+] Connecting to GitHub remote...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/shreyastouih-ctrl/apple-linux-Suite.git

echo.
echo =================================================================
echo Pushing repository to https://github.com/shreyastouih-ctrl/apple-linux-Suite.git
echo =================================================================
echo.

git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo =================================================================
    echo    SUCCESS! Apple-Linux-Suite is live on GitHub!
    echo    https://github.com/shreyastouih-ctrl/apple-linux-Suite
    echo =================================================================
) else (
    echo.
    echo [!] If prompted for login, enter your GitHub credentials or Personal Access Token.
)

pause
