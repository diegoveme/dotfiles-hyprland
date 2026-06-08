#!/usr/bin/env bash
# Toggles between extending and mirroring the internal screen onto the external one.

STATE="$HOME/.config/hypr/.mirror-state"
INTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")).name' | head -1)"
EXTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")|not).name' | head -1)"

if [ -z "$EXTERNAL" ]; then
    notify-send -u low "󰍹  Mirror" "No external monitor connected" 2>/dev/null
    exit 1
fi

if [ -f "$STATE" ]; then
    # Was mirroring → go back to extending
    hyprctl eval "hl.monitor({ output = \"$EXTERNAL\", mode = \"preferred\", position = \"auto\", scale = 1 })" >/dev/null 2>&1
    rm -f "$STATE"
    notify-send -u low "󰍹  Screens extended" "$EXTERNAL" 2>/dev/null
else
    # Enable mirroring of the internal onto the external
    hyprctl eval "hl.monitor({ output = \"$EXTERNAL\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"$INTERNAL\" })" >/dev/null 2>&1
    touch "$STATE"
    notify-send -u low "󰍹  Mirror enabled" "$EXTERNAL ← $INTERNAL" 2>/dev/null
fi
