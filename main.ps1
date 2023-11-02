<#

    This script will match 'manifest.json' data with whats actually
    exist in the root Valheim BepInEx Plugin folder and whats currently
    on Thunderstore. If there is differences it will update automaticly.

    Its was orignially created for me and my friends but might be useful
    for others aswell.

    I will be working on a Dedicated Server side solution aswell in the
    future.

    INSTALLATION:
    Everything you need to know will be in the README file but to be honest
    there should not be very advanced, then its not good enough!

    TODO:
    - Implement version in manifest.json instead of main file to make check if current runned version is latest to automaticlly update files
    - Check if mod unpacked files includes other zip files
    - Remove mod if not included in the manifest.json from BepInEx/plugins
    - Clear code and optimize
    
    DONE:
    - Make a check that system are windows
    - Make a check Powershell are using version 7+
    - Optimize version check directly by compare whats installed and whats on thunderstore directly
    - Make Loop downloaded mods a function instead of reuse stupid code.
    - When checking for version on installed mods, if bad structure manifest will be outside plugins folder.
#>

$Version = "1.0"
$Author = "tebbeh"
$LastUpdated = "2023-11-02"

#####################
## Welcome Message ##
#####################

Write-Host @"
 _       __       __                                 __            _    __        __ __           _          
| |     / /___   / /_____ ____   ____ ___   ___     / /_ ____     | |  / /____ _ / // /_   ___   (_)____ ___ 
| | /| / // _ \ / // ___// __ \ / __  __ \ / _ \   / __// __ \    | | / // __  // // __ \ / _ \ / // __  __ \
| |/ |/ //  __// // /__ / /_/ // / / / / //  __/  / /_ / /_/ /    | |/ // /_/ // // / / //  __// // / / / / /
|__/|__/ \___//_/ \___/ \____//_/ /_/ /_/ \___/   \__/ \____/     |___/ \__,_//_//_/ /_/ \___//_//_/ /_/ /_/ 
    __                               __                   __              __         __     __           __  
   / /   ____ _ __  __ ____   _____ / /_   ___   _____   / /_   __  __   / /_ ___   / /_   / /_   ___   / /_ 
  / /   / __  // / / // __ \ / ___// __ \ / _ \ / ___/  / __ \ / / / /  / __// _ \ / __ \ / __ \ / _ \ / __ \
 / /___/ /_/ // /_/ // / / // /__ / / / //  __// /     / /_/ // /_/ /  / /_ /  __// /_/ // /_/ //  __// / / /
/_____/\__,_/ \__,_//_/ /_/ \___//_/ /_/ \___//_/     /_.___/ \__, /   \__/ \___//_.___//_.___/ \___//_/ /_/ 
                                                             /____/                                                                            
"@ -ForegroundColor Green

Write-Host "Launcher information" -ForegroundColor Magenta
Write-Host "Version: " -NoNewline -ForegroundColor Green; Write-Host $Version -ForegroundColor Cyan
Write-Host "Author: " -NoNewline -ForegroundColor Green; Write-Host $Author -ForegroundColor Cyan
Write-Host "Last update: " -NoNewline -ForegroundColor Green; Write-Host $LastUpdated -ForegroundColor Cyan
Write-Host ""

######################
## Global Variables ##
######################

$ProgressPreference = 'SilentlyContinue' # Do not show download progress

##########################
## Import manifest.json ##
##########################

$manifest = Get-Content .\manifest.json | ConvertFrom-Json

# Check if runned on Windows system
Write-Host "Testing if running in Windows... " -NoNewline -ForegroundColor Yellow
if (-not ($env:OS -like 'Windows_*')) {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "You cannot currently run this launcher in other OS than Windows." -ForegroundColor Cyan
    break
}
else {
    Write-Host "OK" -ForegroundColor Green
}

# Check if Powershell is correct version
Write-Host "Testing Powershell verison... " -NoNewline -ForegroundColor Yellow
if (-not ($PSVersionTable.PSVersion.Major -ge 7)) {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "You need to run a Powershell version newer than 7." -ForegroundColor Cyan
    Write-Host "Follow this link to upgrade (https://github.com/PowerShell/PowerShell/releases)." -ForegroundColor Cyan
    break
}
else {
    Write-Host "OK" -ForegroundColor Green
}

######################################
## Check Installed Paths if correct ##
######################################

# Steam
Write-Host "Testing Steam install path... " -NoNewline -ForegroundColor Yellow
if (-not (Test-Path $manifest.installPaths.steampath)) {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "Tip! Check 'manifest.json' if installPaths is correct." -ForegroundColor Cyan
    Write-Host "Remember path need to be with double '\\' as the example." -ForegroundColor Cyan
    break
}
else {
    Write-Host "OK" -ForegroundColor Green
}

# Valheim
Write-Host "Testing Valheim install path... " -NoNewline -ForegroundColor Yellow
if (-not (Test-Path $manifest.installPaths.steampath)) {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "Tip! Check 'manifest.json' if installPaths is correct." -ForegroundColor Cyan
    Write-Host "Remember path need to be with double '\\' as the example." -ForegroundColor Cyan
    break
}
else {
    Write-Host "OK" -ForegroundColor Green
}

Write-Host ""

Write-Host "Checking if game already running... " -NoNewline -ForegroundColor Yellow
if (Get-Process "valheim" -ErrorAction SilentlyContinue) {
    Write-Host "RUNNING" -ForegroundColor Red
    Write-Host ""
    Write-Host "Game needs to be closed to run the launcher!" -ForegroundColor Cyan
    
    $acceptedAnswers = @("y", "yes", "n", "no")
    
    $user_input = ""
    while ($user_input -notin $acceptedAnswers) {
        $user_input = (Read-Host "Do you wish to close the game? (Y/N)").ToLower()
        
        if ($user_input -notin $acceptedAnswers) {
            Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
        }
    }
    
    if ($user_input -in @("y", "yes")) {
        Write-Host "Closing the game..." -ForegroundColor Green
        Get-Process "valheim" | Stop-Process
    }
    else {
        Write-Host "Game will not be closed." -ForegroundColor Yellow
        Write-Host "You cannot run this launcher before you close the game..." -ForegroundColor Yellow
        Start-Sleep 3
        break
    }
}
else {
    Write-Host "OK" -ForegroundColor Green
}

function compareVersions {
    
    Write-Host "Getting information from all mods in 'manifest.json'... " -ForegroundColor Yellow -NoNewline

    # Manifest Mods
    $ManifestMods = foreach ($ManifestMod in $manifest.mods) {
        $pluginAuthor = (($ManifestMod.split("/") | Where-Object { $_ -ne '' }).Trim())[-2]
        $pluginName = (($ManifestMod.split("/") | Where-Object { $_ -ne '' }).Trim())[-1]
        $result = (Invoke-WebRequest -Uri "https://thunderstore.io/api/experimental/package/$pluginAuthor/$pluginName/").Content | ConvertFrom-Json

        [PSCustomObject]@{
            Name           = $result.latest.name
            Author         = $result.latest.namespace
            TotalDownloads = $result.latest.downloads
            LatestVersion  = $result.latest.version_number
            Description    = $result.latest.description
            DownloadURL    = $result.latest.download_url
        }
    }

    Write-Host "OK" -ForegroundColor Green; Write-Host ""

    Write-Host "Checking if BepInEx exists... " -ForegroundColor Yellow -NoNewline

    # Installed Mods
    if (Test-Path "$($manifest.installPaths.valheimpath)\BepInEx\plugins") {

        Write-Host "OK" -ForegroundColor Green; Write-Host ""

        Write-Host "Checking installed mods... " -ForegroundColor Yellow -NoNewline

        $InstalledMods = foreach ($InstalledMod in (Get-ChildItem "$($manifest.installPaths.valheimpath)\BepInEx\plugins")) {
            Get-ChildItem $InstalledMod | Where-Object { $_.Name -eq "manifest.json" } | Get-Content | ConvertFrom-Json
        }

        Write-Host "OK" -ForegroundColor Green; Write-Host ""

        $Compares = foreach ($Mod in $ManifestMods) {

            try {
                $InstalledModObject = $InstalledMods | Where-Object { $_.Name -eq $Mod.Name }

                $ModObject = [PSCustomObject]@{
                    BepInExInstalled = $true
                    Name             = $Mod.Name
                    Version          = $Mod.LatestVersion
                    CurrentVersion   = $InstalledModObject.version_number
                    DownloadURL      = $Mod.DownloadURL
                }

                if ($Mod.LatestVersion -ne $InstalledModObject.version_number) {
                    $ModObject | Add-Member -MemberType NoteProperty -Name "Outdated" -Value $true
                }
                else {
                    $ModObject | Add-Member -MemberType NoteProperty -Name "Outdated" -Value $false
                }

                $ModObject
            }
            catch {
                Write-Host "Something went wrong with compare $($Mod.Name) from manifest to Installed mod"
            }
        }

        [PSCustomObject]@{
            BepInExInstalled = $true
            compares         = $Compares
        }
        
        Write-Host ""
    }
    else {

        Write-Host "DONT EXIST" -ForegroundColor Red

        # BepInEx is not installed so return False
        [PSCustomObject]@{
            BepInExInstalled = $false
            ManifestMods     = $ManifestMods
        }
    }
}

function startGame {
    ################
    ## Start Game ##
    ################

    if (Test-Path "$($manifest.installPaths.valheimpath)\temp") {
        Remove-Item -Path "$($manifest.installPaths.valheimpath)\temp" -Recurse -Force
    }

    Write-Host "Checks done, starting " -ForegroundColor Yellow -NoNewline; Write-Host "Valheim" -ForegroundColor Green

    Start-Process -FilePath "$($manifest.installPaths.steampath)\steam.exe" -ArgumentList "steam://run/892970"

    Write-Host "Thanks for using my Game Launcher for modded Valheim" -ForegroundColor Green
    Write-Host "Best regards, " -ForegroundColor Magenta -NoNewline; Write-Host "tebbeh" -ForegroundColor Green; Write-Host ""

    Write-Host @"
    ###############
    ## THANKS TO ##
    ###############

    thebo
    Backi
    Gawith

    For bug testing!
"@ -ForegroundColor Cyan; Write-Host ""

    Read-Host "Press a key to close this window"
}

Write-Host ""

## If updateBepInEx is True ##
if ($manifest.core.updateBepInEx -eq "true") {

    <#
        Since BepInEx need to be updated I simply unpack and arrange all files from the BepInEx
        core files directly. If we dont need to update BepInEx but mods versions has differences
        it will be handled in the else down below.
    #>

    $Compares = $null
    $Compares = compareVersions
    
    $bepInExInfo = (Invoke-WebRequest -Uri "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/").Content | ConvertFrom-Json
    
    function downloadBepInEx {

        Write-Host "[BepInEx] " -ForegroundColor Magenta -NoNewline

        if (-not (Test-Path "$($manifest.installPaths.valheimpath)\temp\core")) {
            $tempFolder = "$($manifest.installPaths.valheimpath)\temp"
            New-Item -Path "$tempFolder\core" -ItemType Directory | Out-Null
        }

        Invoke-WebRequest -Uri $bepInExInfo.latest.download_url -OutFile "$tempFolder\core\BepInEx.zip"

        # Unpack BepInEx Files
        Write-Host "Unpack files to $tempFolder\main\... " -ForegroundColor Yellow -NoNewline
        Expand-Archive -Path "$tempFolder\core\BepInEx.zip" -DestinationPath "$tempFolder\main\"

        $PreviousFiles = Get-ChildItem "$tempFolder\main\"
        $bepInExManifest = Get-ChildItem "$tempFolder\main\" | Where-Object { $_.Name -eq "manifest.json" }
        Get-ChildItem "$tempFolder\main\BepInExPack_Valheim" | Move-Item -Destination "$tempFolder\main\"
        Move-Item -Path $bepInExManifest -Destination "$tempFolder\main\BepInEx"

        Remove-Item $PreviousFiles -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$tempFolder\core" -Recurse -Force

        Write-Host "✅"
    }
    
    function downloadManifestMods {

        if (-not (Test-Path "$($manifest.installPaths.valheimpath)\temp")) {
            $tempFolder = "$($manifest.installPaths.valheimpath)\temp"
            New-Item -Path $tempFolder -ItemType Directory | Out-Null
        }

        # If BepInEx is not installed then download all mods in manifest
        if (-not ($Compares.BepInExInstalled)) {

            foreach ($Mod in $Compares.ManifestMods) {
                Write-Host "[$($Mod.Name)] " -ForegroundColor Magenta -NoNewline

                Write-Host "Downloading new mod... " -ForegroundColor Yellow -NoNewline
                Invoke-WebRequest -Uri $Mod.DownloadURL -OutFile "$($manifest.installPaths.valheimpath)\temp\$($Mod.Name).zip"
                Write-Host "✅"
            }
        }
        else {
            foreach ($Mod in $Compares.compares | Where-Object { $_.OutDated }) {

                Write-Host "[$($Mod.Name)] " -ForegroundColor Magenta -NoNewline

                if ($null -eq $Mod.CurrentVersion -or $Mod.CurrentVersion -eq '') {
                    Write-Host "Downloading new mod... " -ForegroundColor Yellow -NoNewline
                    Invoke-WebRequest -Uri $Mod.DownloadURL -OutFile "$($manifest.installPaths.valheimpath)\temp\$($Mod.Name).zip"
                    Write-Host "✅"
                }
                else {
                    Write-Host "Downloading and updating mod... " -ForegroundColor Yellow -NoNewline
                    Invoke-WebRequest -Uri $Mod.DownloadURL -OutFile "$($manifest.installPaths.valheimpath)\temp\$($Mod.Name).zip"
                    Write-Host "✅"
                }
            }
        }
    }

    # If BepInEx do or do not exist
    if ($Compares.BepInExInstalled) {
        $bepInExCurrentInstalledVersion = ((Get-ChildItem "$($manifest.installPaths.valheimpath)\BepInEx" | Where-Object { $_.Name -eq "manifest.json" }) | Get-Content | ConvertFrom-Json).version_number

        # Download Manifest Mods
        downloadManifestMods
    }
    else {

        # Download BepInEx
        downloadBepInEx

        # Download Manifest Mods
        downloadManifestMods
    }

    $DownloadedMods = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp" -ErrorAction SilentlyContinue | Where-Object { -not ($_.PSIsContainer) }

    if ($bepInExCurrentInstalledVersion -ne $bepInExInfo.latest.version_number) {

        # Loop downloaded plugins and unpack to BepInEx
        $Mod = $null

        foreach ($Mod in $DownloadedMods) {

            $pluginFiles = $null
            $Folder = $null
            $pluginManifest = $null

            $ModName = $null
            $ModName = ($Mod.Name).Split(".zip")[0]

            Write-Host $ModName -ForegroundColor Cyan -NoNewline
            Write-Host " Unpacking... " -ForegroundColor Yellow -NoNewline

            Expand-Archive -Path $Mod -DestinationPath "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName"
            
            # Check if unpack contains bad structure and get the actual Plugin files
            if ((Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName").name -contains "Plugins") {

                $pluginFiles = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName\plugins"
                $pluginManifest = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName" | Where-Object { $_.Name -eq "manifest.json" }
                $Folder = New-Item -Path "$($manifest.installPaths.valheimpath)\temp\main\BepInEx\plugins\$ModName" -ItemType Directory
                Move-Item -Path $pluginFiles -Destination $Folder
                Move-Item -Path $pluginManifest -Destination $Folder

            }
            else {

                $pluginFiles = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName"
                $Folder = New-Item -Path "$($manifest.installPaths.valheimpath)\temp\main\BepInEx\plugins\$ModName" -ItemType Directory
                Get-ChildItem $pluginFiles | Move-Item -Destination $Folder
            }

            # Remove empty folders in temp\unpack
            Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\" | Where-Object { $_.name -eq $ModName } | Remove-Item -Recurse -Force

            Write-Host "✅"
        }

        $BepInExInstalledUpdate = $True
    }
    else {
        if ($Compares.compares | Where-Object { $_.Outdated -eq $true }) {

            # Create plugin folder in \temp\
            New-Item -Path "$($manifest.installPaths.valheimpath)\temp\plugins" -ItemType Directory | Out-Null

            # Loop downloaded plugins and unpack to BepInEx
            $Mod = $null

            foreach ($Mod in $DownloadedMods) {

                $pluginFiles = $null
                $Folder = $null

                $ModName = $null
                $ModName = ($Mod.Name).Split(".zip")[0]

                Write-Host $ModName -ForegroundColor Cyan -NoNewline
                Write-Host " Unpacking... " -ForegroundColor Yellow -NoNewline

                Expand-Archive -Path $Mod -DestinationPath "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName"
            
                # Check if unpack contains bad structure and get the actual Plugin files
                if ((Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName").name -contains "Plugins") {

                    $pluginFiles = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName\plugins"
                    $pluginManifest = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName" | Where-Object { $_.Name -eq "manifest.json" }
                    $Folder = New-Item -Path "$($manifest.installPaths.valheimpath)\temp\plugins\$ModName" -ItemType Directory
                    Move-Item -Path $pluginFiles -Destination $Folder
                    Move-Item -Path $pluginManifest -Destination $Folder

                }
                else {

                    $pluginFiles = Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\$ModName"
                    $Folder = New-Item -Path "$($manifest.installPaths.valheimpath)\temp\plugins\$ModName" -ItemType Directory
                    Get-ChildItem $pluginFiles | Move-Item -Destination $Folder
                }

                # Remove empty folders in temp\unpack
                Get-ChildItem "$($manifest.installPaths.valheimpath)\temp\Unpack\" | Where-Object { $_.name -eq $ModName } | Remove-Item -Recurse -Force

                Write-Host "✅"
            }

            $BepInExInstalledUpdate = $False
        }
        else {
            Write-Host "Everything up to date!" -ForegroundColor Green; Write-Host ""
            startGame
            break
        }
    }
}

# If $BepInExInstalledUpdate is True then move from a different folder structure
if ($BepInExInstalledUpdate) {
    $sourcePath = "$($manifest.installPaths.valheimpath)\temp\main"
    $destinationPath = $manifest.installPaths.valheimpath
    
    # Get all items in the source directory
    $items = Get-ChildItem -Path $sourcePath | Where-Object { $_.PSIsContainer -or $_.PSIsContainer -eq $false }
    
    # Loop through each item and move it to the destination
    foreach ($item in $items) {
        $destinationItemPath = Join-Path $destinationPath $item.Name
    
        if ($item -is [System.IO.FileInfo]) {
            # If it's a file, use Move-Item to move and replace if necessary
            Move-Item -Path $item.FullName -Destination $destinationItemPath -Force
        }
        elseif ($item -is [System.IO.DirectoryInfo]) {
            # If it's a directory, use Robocopy to recursively copy and replace files
            robocopy $item.FullName $destinationItemPath /E /IS /IT /XO | Out-Null
        }
    }

    Get-ChildItem -Path $manifest.installPaths.valheimpath | Where-Object { $_.Name -eq "temp" } | Remove-Item -Recurse -Force
}
else {
    $sourcePath = "$($manifest.installPaths.valheimpath)\temp\plugins"
    $destinationPath = "$($manifest.installPaths.valheimpath)\BepInEx\plugins"
    $items = Get-ChildItem -Path $sourcePath | Where-Object { $_.PSIsContainer -or $_.PSIsContainer -eq $false }

    foreach ($item in $items) {
        $destinationItemPath = Join-Path $destinationPath $item.Name
    
        if ($item -is [System.IO.FileInfo]) {
            # If it's a file, use Move-Item to move and replace if necessary
            Move-Item -Path $item.FullName -Destination $destinationItemPath -Force
        }
        elseif ($item -is [System.IO.DirectoryInfo]) {
            # If it's a directory, use Robocopy to recursively copy and replace files
            robocopy $item.FullName $destinationItemPath /E /IS /IT /XO | Out-Null
        }
    }

    Get-ChildItem -Path $manifest.installPaths.valheimpath | Where-Object { $_.Name -eq "temp" } | Remove-Item -Recurse -Force
}

Write-Host ""

startGame