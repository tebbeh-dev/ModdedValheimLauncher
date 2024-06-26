# Modded Valheim Launcher
A game launcher made for modded Valheim. **This require a fresh Valheim folder**.

**ATTENTION**
manifest.json (https://github.com/tebbeh-dev/ModdedValheimLauncher/blob/main/manifest.json) will always be up to date with what me and my friends are using. Make sure to change those values to what you prefer (Make sure to read https://github.com/tebbeh-dev/ModdedValheimLauncher#how-to-use).

# Requirements
**Windows**
- Runs on PowerShell and requires PowerShell version 7+ (https://github.com/PowerShell/PowerShell/releases).

**Linux**
- Runs on Shell so no actions needed.

# How to Use
- To configure 'manifest.json,' follow these steps:

1. Set the Steam path.
2. Set the Valheim path.
3. Set 'updateBepInEx' to true (false doesn't work for now).
4. Set 'mods' -> git -> to true or false. If its true script will always use mods that I push for me and my friends here (https://github.com/tebbeh-dev/ModdedValheimLauncher/blob/main/mods.json). If its false you can edit the mods.json file your own and script will check for those mods instead.
5. Set 'mods' -> custom -> to true or false. If its true script will check if git is set to true and append those mods in custommods.json to the list of mods.json that are in git (https://github.com/tebbeh-dev/ModdedValheimLauncher/blob/main/mods.json).

**Windows**
- Run 'start_game.bat'

**Linux**
- Run 'start_game.sh' (Make sure you have permission to run this file ``chmod +x start_game.sh``)

# How It Works
- It will simply check if you have BepInEx installed or not.
- If you have BepInEx, it will check if it's the latest version; otherwise, it will download the latest version and then download every mod if it's outdated or doesn't exist based on your 'manifest.json.'.
- When everything appears fine, it will automatically start Valheim along with all your mods. It's as simple as that!

# Future
- I will create a Server Mod updater similar to this launcher for both Linux and Windows Dedicated Hosted Servers for those who dont rent a server on a hosting company.
- I will PROBABLY make this a GUI version aswell but my knowledge about design is very limited (Maybe a contributor/designer want to cooperate?).

# Features done
- I will create a similar launcher for the small audience that use and play Valheim on Linux (Including myself ofcourse).

# Greetings
Thanks to:
- Astro
- thebo
- Backi
- Gawith

for bug and beta testing!
