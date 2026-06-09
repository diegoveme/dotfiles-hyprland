#!/usr/bin/env bash
# Behavior when closing/opening the laptop lid.
# Usage: lid.sh close|open

INTERNAL="eDP-1"
EXTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")|not).name' | head -1)"

case "$1" in
    close)
        if [ -n "$EXTERNAL" ]; then
            # External monitor present → keep using it, turn off only the internal panel
            hyprctl eval "hl.monitor({ output = \"$INTERNAL\", disabled = true })" >/dev/null 2>&1
        else
            # No external → lock and suspend
            loginctl lock-session
            systemctl suspend
        fi
        ;;
    open)
        hyprctl eval "hl.monitor({ output = \"$INTERNAL\", mode = \"1920x1080@144\", position = \"0x0\", scale = 1 })" >/dev/null 2>&1
        ;;
esac
