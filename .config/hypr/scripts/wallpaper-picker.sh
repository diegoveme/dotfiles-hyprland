#!/usr/bin/env bash
# Wallpaper picker with rofi. Shows the library with thumbnails,
# applies the choice instantly and makes it persistent.

DIR="$HOME/.config/wallpapers"
CURRENT="$HOME/.config/hypr/current-wallpaper"

# Builds the list for rofi: each entry with icon = the image itself (thumbnail).
gen() {
    find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | while read -r f; do
        printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$f"
    done
}

choice="$(gen | rofi -dmenu -i -p "Wallpaper" -theme-str 'listview { columns: 3; lines: 3; } element-icon { size: 5em; } element-text { enabled: false; }')"
[ -z "$choice" ] && exit 0

WP="$DIR/$choice"
[ -f "$WP" ] || exit 1

# Apply and persist
ln -sf "$WP" "$CURRENT"
pidof hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 & sleep 1)
hyprctl hyprpaper wallpaper "eDP-1,$WP" >/dev/null 2>&1
