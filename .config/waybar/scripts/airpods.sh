#!/usr/bin/env bash
# airpods.sh — waybar custom module. Reads /tmp/airpods.json (written by the
# airstatus user service) and prints waybar JSON. Empty text when the AirPods
# are absent or the data is stale, so the module collapses to nothing.
F=/tmp/airpods.json
[ -r "$F" ] || { echo '{"text":""}'; exit 0; }

now=$(date +%s)
jq -cn --argjson now "$now" --slurpfile d "$F" '
  ($d[0] // {status:0}) as $a
  | if ($a.status != 1) or (($now - ($a.ts // 0)) > 40) then
      {text: ""}
    else
      ([$a.left, $a.right] | map(select(. >= 0))) as $buds
      | (if ($buds | length) > 0 then ($buds | min) else -1 end) as $low
      | (($a.charging_left // false) or ($a.charging_right // false)) as $chg
      | (if $chg then "󰂄 " else "󰋋 " end) as $icon
      | {
          text: ($icon + (if $low >= 0 then "\($low)%" else "--" end)),
          tooltip: (
            ($a.model // "AirPods")
            + "\nLeft: "  + (if $a.left >= 0 then "\($a.left)%" + (if $a.charging_left then " 󰂄" else "" end) else "—" end)
            + "\nRight: " + (if $a.right >= 0 then "\($a.right)%" + (if $a.charging_right then " 󰂄" else "" end) else "—" end)
            + "\nCase: "  + (if $a.case >= 0 then "\($a.case)%" + (if $a.charging_case then " 󰂄" else "" end) else "—" end)
          ),
          class: (if $low >= 0 and $low <= 20 then "low" elif $chg then "charging" else "ok" end)
        }
    end'
