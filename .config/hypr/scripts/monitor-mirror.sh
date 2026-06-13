#!/usr/bin/env bash
# Toggles the external monitor between EXTENDING and MIRRORING the internal one.
# Reads the real state from Hyprland's `mirrorOf` field. NOTE: a mirroring
# monitor is hidden from `hyprctl monitors`, so we must query `monitors all`.

INTERNAL="$(hyprctl monitors all -j | jq -r '.[] | select(.name|contains("eDP")).name' | head -1)"
EXTERNAL="$(hyprctl monitors all -j | jq -r '.[] | select(.name|contains("eDP")|not).name' | head -1)"

if [ -z "$EXTERNAL" ]; then
    notify-send -u low "󰍹  Mirror" "No external monitor connected" 2>/dev/null
    exit 1
fi

# Is the external currently mirroring? mirrorOf is "none" when not mirroring,
# otherwise it holds the source monitor's id (e.g. "0").
MIRRORING="$(hyprctl monitors all -j | jq -r --arg ext "$EXTERNAL" \
    '.[] | select(.name==$ext) | .mirrorOf')"

if [ "$MIRRORING" != "none" ] && [ -n "$MIRRORING" ]; then
    # Currently mirroring → extend. Runtime `monitor` rules accumulate and can't
    # be removed individually, and `mirror,none` doesn't clear an active mirror
    # in Hyprland 0.55, so we reload the config (whose default is "extend").
    hyprctl reload >/dev/null 2>&1
    notify-send -u low "󰍹  Screens extended" "$EXTERNAL is now a separate screen" 2>/dev/null
else
    # Currently extending → mirror the internal onto the external.
    # This config uses the Lua parser, so `hyprctl keyword` is rejected — must
    # go through `hl.monitor` via eval.
    hyprctl eval "hl.monitor({ output = \"$EXTERNAL\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"$INTERNAL\" })" >/dev/null 2>&1
    notify-send -u low "󰍹  Mirror enabled" "$EXTERNAL ← $INTERNAL" 2>/dev/null
fi
