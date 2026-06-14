#!/usr/bin/env bash
# waybar custom module (streaming): shows which monitor has keyboard focus.
# Updates INSTANTLY via Hyprland's event socket (socket2) — emits a new line
# whenever the focused monitor changes. Collapses (empty) with a single monitor.

sig="$HYPRLAND_INSTANCE_SIGNATURE"
sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$sig/.socket2.sock"

emit() {
    local mons n f icon label cls
    mons="$(hyprctl monitors -j 2>/dev/null)"
    n="$(echo "$mons" | jq 'length' 2>/dev/null)"
    if [ -z "$n" ] || [ "$n" -le 1 ]; then
        echo '{"text":"","tooltip":""}'
        return
    fi
    f="$(echo "$mons" | jq -r '.[] | select(.focused) | .name')"
    case "$f" in
        *eDP*) icon="󰌢"; label="Laptop";   cls="laptop"   ;;
        *)     icon="󰍹"; label="External"; cls="external" ;;
    esac
    printf '{"text":"%s %s","tooltip":"Keyboard focus is on %s","class":"%s"}\n' \
        "$icon" "$label" "$f" "$cls"
}

emit  # initial state

# Stream Hyprland events; re-emit on anything that can change the focused monitor.
if command -v socat >/dev/null 2>&1 && [ -S "$sock" ]; then
    socat -u "UNIX-CONNECT:$sock" - 2>/dev/null | while read -r line; do
        case "$line" in
            focusedmon*|monitoradded*|monitorremoved*|monitorremovedv2*) emit ;;
        esac
    done
fi
