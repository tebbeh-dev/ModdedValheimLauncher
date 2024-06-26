#!/bin/bash

QUIET="-s"

echo -n "Downloading latest version... "

# Download files using curl
curl $QUIET -o source/main.sh https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/source/main.sh
curl $QUIET -o source/version.json https://raw.githubusercontent.com/tebbeh-dev/ModdedValheimLauncher/main/source/version.json

echo -e "\033[0;32mOK\033[0m"

echo -e "\033[0;36mRestarting launcher, you don't need to do anything!\033[0m"

sleep 5

bash ./start_game.sh
