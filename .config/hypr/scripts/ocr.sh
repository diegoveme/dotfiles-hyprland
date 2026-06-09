#!/usr/bin/env bash
# OCR: select a region, extract the text and copy it to the clipboard.

TMP="$(mktemp /tmp/ocr-XXXXXX.png)"
trap 'rm -f "$TMP"' EXIT

GEO="$(slurp)" || exit 0          # cancelled
grim -g "$GEO" "$TMP" || exit 1

TEXT="$(tesseract "$TMP" - -l spa+eng 2>/dev/null)"

if [ -n "$TEXT" ]; then
    printf '%s' "$TEXT" | wl-copy
    notify-send -u low "Text copied " "$(printf '%s' "$TEXT" | head -c 120)" 2>/dev/null
else
    notify-send -u low "OCR" "No text detected" 2>/dev/null
fi
