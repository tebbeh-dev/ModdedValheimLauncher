#!/bin/bash

# This script will match 'manifest.json' data with whats actually
# exist in the root Valheim BepInEx Plugin folder and whats currently
# on Thunderstore. If there is differences it will update automaticly.

# Its was orignially created for me and my friends but might be useful
# for others aswell.

# I will be working on a Dedicated Server side solution aswell in the
# future.

# INSTALLATION:
# Everything you need to know will be in the README file but to be honest
# there should not be very advanced, then its not good enough!

# TODO:
# - Seperate mods from manifest.json to be able to update original mods if you want to play with me and my friends
# - Clear code and optimize

# DONE:
# - Remove mod if not included in the manifest.json from BepInEx/plugins
# - Check if mod unpacked files includes other zip files
# - Implement version in manifest.json instead of main file to make check if current runned version is latest to automaticlly update files
# - Make a check that system are windows
# - Make a check Powershell are using version 7+
# - Optimize version check directly by compare whats installed and whats on thunderstore directly
# - Make Loop downloaded mods a function instead of reuse stupid code.
# - When checking for version on installed mods, if bad structure manifest will be outside plugins folder.

# Load version and author info
VERSION=$(jq -r '.version' version.json)
AUTHOR="tebbeh"
LAST_UPDATED=$(jq -r '.lastUpdated' version.json)

#####################
## Welcome Message ##
#####################

cat << 'EOF'
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
EOF

echo -e "\e[35mLauncher information\e[0m"
echo -e "\e[32mVersion: \e[36m$VERSION"
echo -e "\e[32mAuthor: \e[36m$AUTHOR"
echo -e "\e[32mLast update: \e[36m$LAST_UPDATED"
echo ""

######################
## Global Variables ##
######################

# Import manifest.json
manifest=$(jq '.' ../manifest.json)
if [[ -z "$manifest" ]]; then
    manifest=$(jq '.' "$(dirname "$0")/../manifest.json")
fi


############################
## Check if running Linux ##
############################

echo -n -e "\e[33mTesting if running in Linux... \e[0m"
if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "\e[31mERROR\e[0m"
    echo -e "\e[36mYou cannot currently run this launcher in other OS than Linux.\e[0m"
    exit 1
else
    echo -e "\e[32mOK\e[0m"
fi

##########################
## Check if jq is installed ##
##########################

echo -n -e "\e[33mTesting if jq is installed... \e[0m"
if ! command -v jq &> /dev/null; then
    echo -e "\e[31mERROR\e[0m"
    echo -e "\e[36mYou need to install jq. Please install it using your package manager.\e[0m"
    exit 1
else
    echo -e "\e[32mOK\e[0m"
fi

######################################
## Check Installed Paths if correct ##
######################################

# Steam
echo -n -e "\e[33mTesting Steam install path... \e[0m"
steam_path=$(echo "$manifest" | jq -r '.installPaths.steampath')
if [[ ! -d "$steam_path" ]]; then
    echo -e "\e[31mERROR\e[0m"
    echo -e "\e[36mTip! Check 'manifest.json' if installPaths is correct.\e[0m"
    echo -e "\e[36mRemember path needs to be with double '\\' as the example.\e[0m"
    exit 1
else
    echo -e "\e[32mOK\e[0m"
fi

# Valheim
echo -n -e "\e[33mTesting Valheim install path... \e[0m"
valheim_path=$(echo "$manifest" | jq -r '.installPaths.valheimpath')
if [[ ! -d "$valheim_path" ]]; then
    echo -e "\e[31mERROR\e[0m"
    echo -e "\e[36mTip! Check 'manifest.json' if installPaths is correct.\e[0m"
    echo -e "\e[36mRemember path needs to be with double '\\' as the example.\e[0m"
    exit 1
else
    echo -e "\e[32mOK\e[0m"
fi

echo ""

###############################
## Check if game is running  ##
###############################

echo -n -e "\e[33mChecking if game already running... \e[0m"
if pgrep -x "valheim" > /dev/null; then
    echo -e "\e[31mRUNNING\e[0m"
    echo ""
    echo -e "\e[36mGame needs to be closed to run the launcher!\e[0m"

    read -p "Do you wish to close the game? (Y/N): " user_input
    user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')
    case $user_input in
        y|yes)
            echo -e "\e[32mClosing the game...\e[0m"
            pkill -x "valheim"
            ;;
        n|no)
            echo -e "\e[33mGame will not be closed.\e[0m"
            echo -e "\e[33mYou cannot run this launcher before you close the game...\e[0m"
            sleep 3
            exit 1
            ;;
        *)
            echo -e "\e[31mInvalid input. Please enter 'Y' or 'N'.\e[0m"
            exit 1
            ;;
    esac
else
    echo -e "\e[32mOK\e[0m"
fi

######################
## Compare Versions ##
######################

compareVersions() {
    local manifest="$1"
    local mods
    local custom_json="$custom_json_path"

    echo -n -e "\e[33mChecking if BepInEx is installed... \e[0m"

    if [ ! -d "$valheim_path/BepInEx/plugins" ]; then
        echo -e "\e[33mBepInEx not found, installing... \e[0m"
        downloadBepInEx
    else
        echo -e "\e[32mBepInEx is installed.\e[0m"
    fi

    echo -n -e "\e[33mChecking where mods should get info from... \e[0m"

    if [[ $(echo "$manifest" | jq -r '.mods.git') == "true" ]]; then
        mods=$(curl -s "https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/mods.json" | jq -r '.mods')
        echo -e "\e[32mGit\e[0m"
    else
        mods=$(jq -r '.mods' mods.json)
        if [[ -z "$mods" ]]; then
            mods=$(jq -r '.mods' "$(dirname "$0")/../mods.json")
        fi
        echo -e "\e[32mmods.json\e[0m"
    fi

    echo -n -e "\e[33mChecking custom JSON file if exist... \e[0m"
    if [[ -f "$custom_json" ]]; then
        customJson=$(jq -r '.mods' "$custom_json")
        echo -e "\e[32mOK\e[0m"
    else
        echo -e "\e[32mNot found.\e[0m"
    fi

    echo ""
    echo -e "\e[32mComparing versions of mods...\e[0m"

    while IFS= read -r mod; do
        url=($(echo "$mod" | sed 's/"//g'))
        parts=($(echo "$mod" | sed 's/"//g' | tr '/' '\n'))
        pluginAuthor="${parts[-2]}"
        pluginName="${parts[-1]}"

        # Fetch package information from Thunderstore API
        result=$(curl -s "https://thunderstore.io/api/experimental/package/$pluginAuthor/$pluginName/" | jq -r '.latest')

        # Create and print the custom object
        name=$(echo "$result" | jq -r '.name')
        author=$(echo "$result" | jq -r '.namespace')
        totalDownloads=$(echo "$result" | jq -r '.downloads')
        latestVersion=$(echo "$result" | jq -r '.version_number')
        description=$(echo "$result" | jq -r '.description')
        downloadURL=$(echo "$result" | jq -r '.download_url')

        modName=$pluginName
        modVersion=$latestVersion
        modUrl=$url

        echo -e "\e[32mChecking mod: $modName\e[0m"

        modManifest=$(find "$valheim_path/BepInEx/plugins/$modName/" -type f -name "manifest.json")
        if [ -f "$modManifest" ]; then
            currentVersion=$(jq -r '.version_number' $valheim_path/BepInEx/plugins/$modName/manifest.json)
        fi

        if [[ -z "$currentVersion" ]]; then
            echo -e "\e[33mMod not installed, downloading...\e[0m"
            downloadMod "$modName" "$downloadURL"
        elif [[ "$modVersion" != "$currentVersion" ]]; then
            echo -e "\e[33mMod version mismatch (current: $currentVersion, expected: $modVersion), updating...\e[0m"
            downloadMod "$modName" "$downloadURL"
        else
            echo -e "\e[32mMod is up-to-date.\e[0m"
        fi
        
    done <<< "$(echo "$mods" | jq -c '.[]')"
}

######################
## Download BepInEx ##
######################
downloadBepInEx() {
    echo -e "\e[35m[BepInEx] \e[0m"

    # Check if BepInEx directory exists
    if [ ! -d "$valheim_path/BepInEx" ]; then
        echo "Creating BepInEx directory: $valheim_path/BepInEx"
        mkdir -p "$valheim_path/BepInEx"
    fi

    tempFolder="$valheim_path/temp"
    mkdir -p "$tempFolder/core" "$tempFolder/main"

    # Download BepInEx.zip
    bepInExInfo_latest_download_url=$(curl -s "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/" | jq -r '.latest.download_url')

    echo "Downloading BepInEx from $bepInExInfo_latest_download_url to $tempFolder/core/BepInEx.zip"
    curl -L "$bepInExInfo_latest_download_url" -o "$tempFolder/core/BepInEx.zip"

    # Unpack BepInEx.zip
    echo -e "\e[33mUnpacking files to $tempFolder/main/...\e[0m"
    unzip -o "$tempFolder/core/BepInEx.zip" -d "$tempFolder/main/"

    mv $tempFolder/main/BepInExPack_Valheim/* $valheim_path

    chmod +x $valheim_path/start_game_bepinex.sh

    ## Move manifest.json and BepInExPack_Valheim
    bepInExManifest=$(find "$tempFolder/main/" -type f -name "manifest.json")
    if [ -f "$bepInExManifest" ]; then
        mv "$bepInExManifest" "$valheim_path/BepInEx/"
    fi
    
    # Clean up
    rm -rf "$tempFolder"

    echo -e "\e[32mDONE\e[0m"
}


##############################
## Download Mod Function    ##
##############################

downloadMod() {
    local modName="$1"
    local modUrl="$2"

    echo -e "\e[32mDownloading mod: $modName from $modUrl\e[0m"

    tempDir=$(mktemp -d)
    downloadPath="$tempDir/$modName"

    # Download the mod file
    curl -L "$modUrl" -o "$downloadPath" || { echo "Failed to download $modName from $modUrl"; exit 1; }

    # Verify the downloaded file
    ls -lh "$downloadPath"

    # Unzip the mod file
    unzip "$downloadPath" -d "$valheim_path/BepInEx/plugins/$modName" || { echo "Failed to unzip $modName"; exit 1; }

    # Clean up temporary directory
    rm -rf "$tempDir"

    echo -e "\e[32mMod $modName downloaded and installed.\e[0m"
}


#########################
## Start Game Function ##
#########################

startGame() {
    echo -e "\e[32mStarting Valheim...\e[0m"
    steam -applaunch 892970 &
    echo -e "\e[32mGame started.\e[0m"
}

##############################
## Main Script Execution    ##
##############################

compareVersions "$manifest"

echo -e "\e[32mAll mods are up-to-date.\e[0m"

read -p "Do you want to start Valheim now? (Y/N): " start_input
start_input=$(echo "$start_input" | tr '[:upper:]' '[:lower:]')
case $start_input in
    y|yes)
        startGame
        ;;
    n|no)
        echo -e "\e[32mYou chose not to start the game.\e[0m"
        ;;
    *)
        echo -e "\e[31mInvalid input. Please enter 'Y' or 'N'.\e[0m"
        ;;
esac
