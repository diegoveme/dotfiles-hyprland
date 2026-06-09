#!/usr/bin/env bash
# Record the screen with wf-recorder (toggle): if already recording, stop and save;
# if not, select a region and start recording with system audio.
# Usage: screenrecord.sh [region|full]

DIR="$HOME/Videos"
mkdir -p "$DIR"

# --- If already recording: stop and notify ---
if pidof wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send -u low "Recording stopped" "Saved in ~/Videos" 2>/dev/null
    exit 0
fi

# --- System audio: monitor of the default sink ---
SINK="$(pactl get-default-sink 2>/dev/null)"
AUDIO="${SINK:+--audio=${SINK}.monitor}"

OUT="$DIR/grabacion-$(date +%Y%m%d-%H%M%S).mp4"

MODE="${1:-region}"
if [ "$MODE" = "full" ]; then
    notify-send -u low "Recording full screen" "Press the shortcut again to stop" 2>/dev/null
    wf-recorder $AUDIO -f "$OUT" >/dev/null 2>&1 &
else
    GEO="$(slurp)" || exit 0   # cancelled
    notify-send -u low "Recording region" "Press the shortcut again to stop" 2>/dev/null
    wf-recorder -g "$GEO" $AUDIO -f "$OUT" >/dev/null 2>&1 &
fi
