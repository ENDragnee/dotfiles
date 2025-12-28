#!/bin/env bash

if ! command -v wl-copy &> /dev/null; then
    echo "wl-copy is not installed. Please install it to use this script."
    exit 1
fi

cliphist list | fuzzel --config ~/.config/fuzzel/configs/fuzzel-clipboard.ini --dmenu | cliphist decode | wl-copy
