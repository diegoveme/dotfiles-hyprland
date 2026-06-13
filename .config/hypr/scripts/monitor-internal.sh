#!/usr/bin/env bash
# Toggle the laptop panel (eDP) off/on. Refuses to turn off the only screen.
# Usage: monitor-internal.sh [on|off|toggle]
#
# NOTE: on Hyprland 0.55 a `disabled` monitor rule sticks — re-enabling with
# hl.monitor does NOT bring the panel back. The reliable way to turn it back ON
# is `hyprctl reload` (the config has eDP enabled), so that's what `on` does.
# State is read live from Hyprland (no state file → never desyncs).

INTERNAL="$(hyprctl monitors all -j | jq -r '.[] | select(.name|contains("eDP")).name' | head -1)"

panel_is_off() {
    [ "$(hyprctl monitors all -j | jq -r --arg m "$INTERNAL" \
        '.[] | select(.name==$m) | .disabled')" = "true" ]
}
has_external() {
    [ -n "$(hyprctl monitors all -j | jq -r \
        '.[] | select(.name|contains("eDP")|not) | select(.disabled==false).name' | head -1)" ]
}

on() {
    hyprctl reload >/dev/null 2>&1
    notify-send -u low "󰍹  Laptop screen on" 2>/dev/null
}

off() {
    if ! has_external; then
        notify-send -u low "󰍹  Can't turn off the only active screen" 2>/dev/null
        exit 1
    fi
    hyprctl eval "hl.monitor({ output = \"$INTERNAL\", disabled = true })" >/dev/null 2>&1
    notify-send -u low "󰍹  Laptop screen off" "Showing on the external only" 2>/dev/null
}

case "${1:-toggle}" in
    on)     on ;;
    off)    off ;;
    toggle) if panel_is_off; then on; else off; fi ;;
esac
