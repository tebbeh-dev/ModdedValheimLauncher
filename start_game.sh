#!/bin/bash

ensure_executable() {
    local file=$1

    if [ ! -f "$file" ]; then
        echo "File does not exist: $file"
        return 1
    fi

    if [ ! -x "$file" ]; then
        echo "File is not executable. Setting execute permission..."
        chmod +x "$file"
        
        if [ $? -eq 0 ]; then
            echo "Execute permission set successfully."
            echo "Game will start in 3 seconds!"
        else
            echo "Failed to set execute permission."
            return 1
        fi
    else
        echo "File is already executable '$file'."
    fi
}

ensure_executable "./source/main.sh"
ensure_executable "./source/update.sh"

cd source && ./main.sh