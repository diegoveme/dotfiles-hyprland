#!/usr/bin/env bash
# Turns the laptop panel (eDP) on/off. Only allows turning it off if there is
# an active external monitor (so you don't end up with no screen).
# Usage: monitor-internal.sh [on|off|toggle]

INTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")).name' | head -1)"
EXTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")|not).name' | head -1)"
STATE="$HOME/.config/hypr/.internal-off"

on() {
    hyprctl eval "hl.monitor({ output = \"$INTERNAL\", mode = \"1920x1080@144\", position = \"0x0\", scale = 1 })" >/dev/null 2>&1
    rm -f "$STATE"
    notify-send -u low "󰍹  Laptop screen on" 2>/dev/null
}

off() {
    if [ -z "$EXTERNAL" ]; then
        notify-send -u low "󰍹  Can't turn off the only active screen" 2>/dev/null
        exit 1
    fi
    hyprctl eval "hl.monitor({ output = \"$INTERNAL\", disabled = true })" >/dev/null 2>&1
    touch "$STATE"
    notify-send -u low "󰍹  Laptop screen off" 2>/dev/null
}

case "${1:-toggle}" in
    on)  on ;;
    off) off ;;
    toggle) [ -f "$STATE" ] && on || off ;;
esac
