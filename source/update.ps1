$ProgressPreference = 'SilentlyContinue' # Do not show download progress

Write-Host "Downloading latest version..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/main.ps1" -OutFile main_test.ps1 

Read-Host "Press enter to close"