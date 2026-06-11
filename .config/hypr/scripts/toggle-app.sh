#!/usr/bin/env bash
# Toggle a window by its app class: if one is open, close it; otherwise launch it.
# Used by the waybar modules so clicking a module opens its window and clicking
# again closes it — and spamming never opens more than one window.
#
#   toggle-app.sh <class> <launch-command-string>
#
# Race fix: a per-class NON-BLOCKING flock. While a toggle is mid-flight, extra
# clicks are dropped (debounced) instead of queued, so fast spamming stays clean
# and can never open two windows. Each branch waits only until the window has
# actually appeared/disappeared, then releases the lock — so the very next click
# already sees the correct state.

class="$1"
launch="$2"

exec 9>"/tmp/toggle-app-${class}.lock"
flock -n 9 || exit 0          # a toggle is already in progress -> ignore this click

count() { hyprctl clients -j | jq --arg c "$class" '[.[] | select(.class==$c)] | length'; }

if [ "$(count)" -gt 0 ]; then
    # open -> close it (all of them, just in case)
    hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .pid' \
        | while read -r p; do kill "$p" 2>/dev/null; done
    for _ in $(seq 1 20); do [ "$(count)" -eq 0 ] && break; sleep 0.05; done
else
    # closed -> launch (detached). 9>&- closes the lock fd in the child so the
    # launched app does NOT inherit and hold the flock while it runs (that would
    # block every later click). Hold the lock only until the window appears.
    setsid bash -c "$launch" 9>&- >/dev/null 2>&1 &
    for _ in $(seq 1 40); do [ "$(count)" -gt 0 ] && break; sleep 0.05; done
fi
