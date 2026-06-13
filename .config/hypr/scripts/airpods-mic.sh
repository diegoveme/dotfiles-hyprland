#!/usr/bin/env bash
# airpods-mic.sh — toggle the connected Bluetooth headset (AirPods) between:
#   - "music" mode: A2DP, high-fidelity stereo, NO headset mic (laptop mic used)
#   - "call"  mode: HFP, AirPods mic ON, but audio drops to mono phone quality
#
# Classic Bluetooth can't do both at once, so this lets you choose per moment.
# Default state is music (hi-fi); WirePlumber no longer auto-switches (see
# wireplumber.conf.d/50-bluetooth-no-autoswitch.conf).
ICON=audio-headphones

card=$(pactl list cards short | awk '/bluez_card/{print $2; exit}')
if [ -z "$card" ]; then
    notify-send -i "$ICON" "AirPods" "Not connected"
    exit 0
fi

active=$(pactl list cards | sed -n "/Name: $card/,/Active Profile/p" \
         | awk -F': ' '/Active Profile/{print $2; exit}')
laptop_mic=$(pactl list sources short | awk '/alsa_input/{print $2; exit}')

case "$active" in
    a2dp*)
        # music -> call: switch to HFP and make the AirPods the microphone
        pactl set-card-profile "$card" headset-head-unit 2>/dev/null \
            || pactl set-card-profile "$card" headset-head-unit-cvsd
        bt_mic=$(pactl list sources short | awk '/bluez_input/{print $2; exit}')
        [ -n "$bt_mic" ] && pactl set-default-source "$bt_mic"
        notify-send -i audio-input-microphone "AirPods → call mode" \
            "AirPods mic ON · audio drops to phone quality"
        ;;
    *)
        # call -> music: back to A2DP hi-fi, restore the laptop mic
        pactl set-card-profile "$card" a2dp-sink
        [ -n "$laptop_mic" ] && pactl set-default-source "$laptop_mic"
        notify-send -i "$ICON" "AirPods → music mode" \
            "Hi-Fi ON · microphone = laptop"
        ;;
esac
