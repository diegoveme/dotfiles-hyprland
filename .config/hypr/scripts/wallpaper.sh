#!/usr/bin/env bash
# Starts hyprpaper and applies the current wallpaper (via IPC).
# The active wallpaper is the ~/.config/hypr/current-wallpaper link.

CURRENT="$HOME/.config/hypr/current-wallpaper"
WP="$(readlink -f "$CURRENT")"

# If there is no valid link, use the first one in the library.
if [ -z "$WP" ] || [ ! -f "$WP" ]; then
    WP="$(find "$HOME/.config/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | head -1)"
    ln -sf "$WP" "$CURRENT"
fi

pidof hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 &)

sleep 0.2
for i in $(seq 1 20); do
    hyprctl hyprpaper wallpaper "eDP-1,$WP" >/dev/null 2>&1 && exit 0
    sleep 0.3
done
