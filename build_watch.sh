#!/bin/env sh

tools/inotifywait.exe -m -r ./src/ ./inc/ ./Makefile | 
    while read -r date time dir file;
        do
        flag=$((1-flag))
        # Only build once every other time.
        # For some reason saving a file generates two modify
        if ((flag))
        then
            clear;
            if make; then
                echo "build success"
            else
                echo "build failed"
            fi
        fi
    done
