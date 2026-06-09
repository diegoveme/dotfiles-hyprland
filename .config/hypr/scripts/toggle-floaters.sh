#!/usr/bin/env bash
# Hides/shows ALL floating windows in the current workspace.
# Sends them to a stash (special:stash) and brings them back in place.
# Useful when working tiled and floaters cover the windows.

WS="$(hyprctl activeworkspace -j | jq -r '.name')"

# Floaters visible in the current workspace
mapfile -t floaters < <(hyprctl clients -j | jq -r --arg ws "$WS" \
    '.[] | select(.workspace.name==$ws and .floating==true) | .address')

if [ "${#floaters[@]}" -gt 0 ]; then
    # HIDE: move each floater to the stash
    for a in "${floaters[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$a\", workspace = \"special:stash\", follow = false })" >/dev/null 2>&1
    done
else
    # SHOW: bring back whatever is in the stash
    mapfile -t stashed < <(hyprctl clients -j | jq -r \
        '.[] | select(.workspace.name=="special:stash" and .floating==true) | .address')
    for a in "${stashed[@]}"; do
        hyprctl dispatch "hl.dsp.window.move({ window = \"address:$a\", workspace = \"$WS\", follow = false })" >/dev/null 2>&1
    done
fi
