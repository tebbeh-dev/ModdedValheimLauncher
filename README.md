# ModdedValheimLauncher
A game launcher made for modded Valheim.
I would recommend to use this in a fresh Valheim folder.

# Requirements
- Runs on Powershell and specific Powershell version 7+ (https://github.com/PowerShell/PowerShell/releases)
- Only on Windows clients right now

# How to use
Configure 'manifest.json' by:
1. Set Steam path
2. Set Valheim path
3. updateBepInEx = true (false doesnt work for now)
4. mods = add your specific mods exactly as I did. Each mod are pulled by Thunderstore API so in this case we need to use Thunderstore. All mods in current list are what me and my friends currently use together with some specific configuration.

Run Launcher.bat

# How it works
- It will simply do checks if you have BepInEx or not
- If you have BepInEx it will check if its latest version, otherwise it will download and then download every mod if its outdated or not exist based on your manifest.json.
- When everything seems fine it will start Valheim automaticly together with all your mods.
Simple as that!