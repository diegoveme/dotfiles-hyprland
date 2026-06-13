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

# Apply and persist. swaybg covers every monitor (incl. external); restart it
# to swap the image.
ln -sf "$WP" "$CURRENT"
pkill -x swaybg 2>/dev/null
setsid swaybg -i "$WP" -m fill >/dev/null 2>&1 &
