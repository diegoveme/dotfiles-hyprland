#!/usr/bin/env bash
# Behavior when closing/opening the laptop lid.
# Usage: lid.sh close|open
#
# With an external monitor connected, systemd-logind already ignores the lid
# switch (built-in: it won't suspend when another display is attached), so here
# we just blank the internal panel and keep using the external. With no external
# we lock and suspend.

INTERNAL="eDP-1"
has_external() {
    [ -n "$(hyprctl monitors all -j | jq -r \
        '.[] | select(.name|contains("eDP")|not) | select(.disabled==false).name' | head -1)" ]
}
panel_is_off() {
    [ "$(hyprctl monitors all -j | jq -r --arg m "$INTERNAL" \
        '.[] | select(.name==$m) | .disabled')" = "true" ]
}

case "$1" in
    close)
        if has_external; then
            # Keep the external alive, turn off only the internal panel.
            hyprctl eval "hl.monitor({ output = \"$INTERNAL\", disabled = true })" >/dev/null 2>&1
        else
            loginctl lock-session
            systemctl suspend
        fi
        ;;
    open)
        # Re-enable the panel if it was off. hl.monitor can't clear a `disabled`
        # rule on Hyprland 0.55, so reload (config has eDP enabled).
        if panel_is_off; then
            hyprctl reload >/dev/null 2>&1
        fi
        ;;
esac
