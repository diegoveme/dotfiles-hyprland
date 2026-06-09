#!/usr/bin/env bash
# Screenshot helper.
#   screenshot.sh region   -> select an area
#   screenshot.sh full     -> whole screen
# Saves to ~/Pictures/Screenshots, copies to the clipboard and notifies.

mode="${1:-region}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$mode" in
    region)
        geom="$(slurp)" || exit 0          # Esc / right-click cancels: do nothing
        grim -g "$geom" "$file" || exit 1
        ;;
    full)
        grim "$file" || exit 1
        ;;
    *)
        echo "usage: screenshot.sh region|full" >&2
        exit 1
        ;;
esac

wl-copy < "$file"
notify-send -i "$file" "Screenshot" "Saved to ${file/#$HOME/~} · copied to clipboard"
