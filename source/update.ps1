$ProgressPreference = 'SilentlyContinue' # Do not show download progress

Write-Host "Downloading latest version... " -ForegroundColor Yellow -NoNewline

#Invoke-RestMethod -Uri "https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/source/main.ps1" -OutFile "source/main.ps1"
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/source/version.json" -OutFile "source/version.json"

Write-Host "OK" -ForegroundColor Green

Write-Host "Restarting launcher, you dont need to do anything!" -ForegroundColor Cyan

Start-Sleep 5

Start-Process (((Get-Location).Path).Split("source")[0] + "\start_game.bat")

break