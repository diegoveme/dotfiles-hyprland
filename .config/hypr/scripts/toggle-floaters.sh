#!/usr/bin/env bash
# Hides/shows ALL floating windows in the current workspace.
# Sends them to a stash (special:stash) and brings them back in place.
# Useful when working tiled and floaters cover the windows.
#
# Toggle with feedback: a stashed floater is invisible, so each branch sends a
# low-urgency notification — otherwise you can forget windows are hidden, or
# press the shortcut on an empty workspace and wonder why nothing happened.

WS="$(hyprctl activeworkspace -j | jq -r '.name')"

# Floaters visible in the current workspace
mapfile -t floaters < <(hyprctl clients -j | jq -r --arg ws "$WS" \
    '.[] | select(.workspace.name==$ws and .floating==true) | .address')

if [ "${#floaters[@]}" -gt 0 ]; then
    # HIDE: move each floater to the stash
    for a in "${floaters[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$a\", workspace = \"special:stash\", follow = false })" >/dev/null 2>&1
    done
    notify-send -u low "Floaters hidden" \
        "${#floaters[@]} window(s) stashed · press Super+H to restore" 2>/dev/null
else
    # SHOW: bring back whatever is in the stash
    mapfile -t stashed < <(hyprctl clients -j | jq -r \
        '.[] | select(.workspace.name=="special:stash" and .floating==true) | .address')
    for a in "${stashed[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$a\", workspace = \"$WS\", follow = false })" >/dev/null 2>&1
    done
    if [ "${#stashed[@]}" -gt 0 ]; then
        notify-send -u low "Floaters restored" "${#stashed[@]} window(s) back" 2>/dev/null
    else
        notify-send -u low "No floating windows" "Nothing to hide or restore here" 2>/dev/null
    fi
fi
