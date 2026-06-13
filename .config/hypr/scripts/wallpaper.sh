#!/usr/bin/env bash
# Sets the wallpaper with swaybg. swaybg covers ALL monitors automatically,
# including externally-connected ones (hyprpaper fails to bind hotplugged
# displays — it reports "Invalid monitor"). The active wallpaper is the
# ~/.config/hypr/current-wallpaper symlink.

CURRENT="$HOME/.config/hypr/current-wallpaper"
WP="$(readlink -f "$CURRENT")"

# If there is no valid link, use the first image in the library.
if [ -z "$WP" ] || [ ! -f "$WP" ]; then
    WP="$(find "$HOME/.config/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | head -1)"
    ln -sf "$WP" "$CURRENT"
fi

# Replace any running instance, then start fresh covering every output.
pkill -x swaybg 2>/dev/null
sleep 0.2
exec swaybg -i "$WP" -m fill
