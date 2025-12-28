#!/bin/bash

# The name of your bar in the Polybar config
BAR_NAME="workspace"

# Get the window state and check for fullscreen
FULLSCREEN=$(xdotool getactivewindow getwindowgeometry | grep -o 'Geometry: [0-9]*x[0-9]*')

if [ "$FULLSCREEN" == "Geometry: 1920x1080" ]; then
    # Hide Polybar if fullscreen
    polybar-msg cmd hide
else
    # Show Polybar if not fullscreen
    polybar-msg cmd show
fi
