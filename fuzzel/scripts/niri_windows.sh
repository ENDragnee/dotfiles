#!/bin/sh
windows=$(niri msg -j windows)
niri msg action focus-window --id $(echo "$windows" | jq ".[$(echo "$windows" | jq -r 'map("\(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' | fuzzel --config ~/.config/fuzzel/configs/fuzzel-windows.ini -d --index)].id")
