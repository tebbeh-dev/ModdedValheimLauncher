# Modded Valheim Launcher
A game launcher made for modded Valheim. I would recommend using this in a fresh Valheim folder.

**ATTENTION**
manifest.json (https://github.com/tebbeh-dev/ModdedValheimLauncher/blob/main/manifest.json) will always be up to date with what me and my friends are using. Make sure to change those values to what you prefer (Make sure to read https://github.com/tebbeh-dev/ModdedValheimLauncher#how-to-use).

# Requirements
- Runs on PowerShell and requires PowerShell version 7+ (https://github.com/PowerShell/PowerShell/releases).
- Currently available only for Windows clients.

# How to Use
- To configure 'manifest.json,' follow these steps:

1. Set the Steam path.
2. Set the Valheim path.
3. Set 'updateBepInEx' to true (false doesn't work for now).
4. For the 'mods' section, add your specific mods exactly as I did. Each mod is pulled from the Thunderstore API, so we need to use Thunderstore. All the mods in the current list are the ones that my friends and I are currently using, along with some specific configurations.

- Run 'start_game.bat'

# How It Works
- It will simply check if you have BepInEx installed or not.
- If you have BepInEx, it will check if it's the latest version; otherwise, it will download the latest version and then download every mod if it's outdated or doesn't exist based on your 'manifest.json.'.
- When everything appears fine, it will automatically start Valheim along with all your mods. It's as simple as that!

# Future
- I will create a similar launcher for the small audience that use and play Valheim on Linux (Including myself ofcourse).
- I will create a Server Mod updater similar to this launcher for both Linux and Windows Dedicated Hosted Servers for those who dont rent a server on a hosting company.
- I will PROBABLY make this a GUI version aswell but my knowledge about design is very limited (Maybe a contributor/designer want to cooperate?).

# Greetings
Thanks to:
- thebo
- Backi
- Gawith
- Astro

for bug and beta testing!