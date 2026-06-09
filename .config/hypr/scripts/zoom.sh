#!/usr/bin/env bash
# Screen zoom (follows the cursor). Usage: zoom.sh in|out|reset

STEP=0.5
cur="$(hyprctl getoption cursor:zoom_factor -j 2>/dev/null | jq -r '.float')"
[ -z "$cur" ] && cur=1

case "$1" in
    in)    new="$(awk -v c="$cur" -v s="$STEP" 'BEGIN{print c+s}')" ;;
    out)   new="$(awk -v c="$cur" -v s="$STEP" 'BEGIN{n=c-s; if(n<1)n=1; print n}')" ;;
    reset) new=1 ;;
    *) exit 1 ;;
esac

hyprctl eval "hl.config({ cursor = { zoom_factor = $new } })" >/dev/null 2>&1
