#!/usr/bin/env bash
# Cycles the focused monitor's scaling: 1 → 1.25 → 1.5 → 2 → 1

INFO="$(hyprctl monitors -j | jq -r '.[] | select(.focused==true)')"
NAME="$(echo "$INFO" | jq -r '.name')"
W="$(echo "$INFO" | jq -r '.width')"
H="$(echo "$INFO" | jq -r '.height')"
R="$(echo "$INFO" | jq -r '.refreshRate | round')"
CUR="$(echo "$INFO" | jq -r '.scale')"

SCALES=(1 1.25 1.5 2)
# index closest to the current scaling
IDX="$(awk -v s="$CUR" -v list="${SCALES[*]}" 'BEGIN{n=split(list,a," ");b=0;bd=1e9;for(i=1;i<=n;i++){d=s-a[i];if(d<0)d=-d;if(d<bd){bd=d;b=i-1}}print b}')"
NEW="${SCALES[$(( (IDX + 1) % ${#SCALES[@]} ))]}"

hyprctl eval "hl.monitor({ output = \"$NAME\", mode = \"${W}x${H}@${R}\", position = \"auto\", scale = $NEW })" >/dev/null 2>&1
notify-send -u low "󰍹  Scaling" "${NAME}: ${NEW}x" 2>/dev/null
