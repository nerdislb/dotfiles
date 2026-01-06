#!/bin/bash

# Define Theme Paths
THEME_NAME="TokyoNight"
THEME_DIR="$HOME/.config/themes/$THEME_NAME"
HYPR_DIR="$HOME/.config/hypr"
WALLPAPER_SOURCE="$HOME/Downloads/wallpaper/City-Night.png"
WALLPAPER_DEST="$HYPR_DIR/wallpaper.png"

# 1. Apply Hyprlock Config
if [ -f "$THEME_DIR/hyprlock.conf" ]; then
    echo "Updating Hyprlock config..."
    cp "$THEME_DIR/hyprlock.conf" "$HYPR_DIR/hyprlock.conf"
else
    echo "Warning: No hyprlock.conf found in $THEME_DIR"
fi

# 2. Set Wallpaper (for Hyprlock and Desktop if needed)
if [ -f "$WALLPAPER_SOURCE" ]; then
    echo "Updating Wallpaper..."
    cp "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
    
    # Update running wallpaper daemon (swww)
    if pgrep -x "swww-daemon" > /dev/null; then
        swww img "$WALLPAPER_DEST" --transition-type grow --transition-pos 0.9,0.5 --transition-step 90
    fi
else
    echo "Warning: Wallpaper not found at $WALLPAPER_SOURCE"
fi

# 3. Notify User
notify-send "Theme Applied" "Activated $THEME_NAME Theme"