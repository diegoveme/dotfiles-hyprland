#!/usr/bin/env bash
# Toggles the external monitor between EXTENDING and MIRRORING the internal one.
# State is read from Hyprland itself (the monitor's `mirrorOf` field), so it
# stays correct even after unplugging/replugging — no stale state file.

INTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")).name' | head -1)"
EXTERNAL="$(hyprctl monitors -j | jq -r '.[] | select(.name|contains("eDP")|not).name' | head -1)"

if [ -z "$EXTERNAL" ]; then
    notify-send -u low "󰍹  Mirror" "No external monitor connected" 2>/dev/null
    exit 1
fi

# Is the external currently mirroring something? (mirrorOf != "none")
MIRRORING="$(hyprctl monitors -j | jq -r --arg ext "$EXTERNAL" \
    '.[] | select(.name==$ext) | .mirrorOf')"

if [ "$MIRRORING" != "none" ] && [ -n "$MIRRORING" ]; then
    # Currently mirroring → extend (clear mirror, place it next to the internal)
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,none" >/dev/null 2>&1
    notify-send -u low "󰍹  Screens extended" "$EXTERNAL is now a separate screen" 2>/dev/null
else
    # Currently extending → mirror the internal onto the external
    hyprctl eval "hl.monitor({ output = \"$EXTERNAL\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"$INTERNAL\" })" >/dev/null 2>&1
    notify-send -u low "󰍹  Mirror enabled" "$EXTERNAL ← $INTERNAL" 2>/dev/null
fi
