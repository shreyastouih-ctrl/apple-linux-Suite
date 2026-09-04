# Apple-Linux-Suite PowerShell One-Click Publisher
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   🍏 APPLE-LINUX-SUITE ONE-CLICK GITHUB PUBLISHER 🐧" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

$gitCmd = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitCmd) {
    Write-Host "[!] Git not found. Installing Git via Winget..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget
    $env:Path += ";C:\Program Files\Git\cmd"
}

Write-Host "[+] Initializing Git Repository..." -ForegroundColor Green
git init

Write-Host "[+] Staging files and assets..." -ForegroundColor Green
git add .

Write-Host "[+] Committing..." -ForegroundColor Green
git commit -m "Initial release of Apple-Linux-Suite"

Write-Host "[+] Setting remote repository..." -ForegroundColor Green
git branch -M main
git remote remove origin 2>$null
git remote add origin https://github.com/shreyastouih-ctrl/apple-linux-Suite.git

Write-Host "[+] Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

Write-Host "`nSUCCESS! Published to https://github.com/shreyastouih-ctrl/apple-linux-Suite" -ForegroundColor Green
