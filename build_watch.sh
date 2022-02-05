#!/bin/env sh

tools/Windows/inotifywait.exe -m -r ./src ./example ./CMakeLists.txt | 
    while read -r date time dir file;
        do
        flag=$((1-flag))
        # Only build once every other time.
        # For some reason saving a file generates two modify
        if ((flag))
        then
            # clear;
            echo '================= Building ================='
            if (cmake --build --preset default --config RelWithDebInfo); then
                echo "build success"
            else
                echo "build failed"
            fi
        fi
    done
