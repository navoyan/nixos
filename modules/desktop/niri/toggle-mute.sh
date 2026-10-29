#!/usr/bin/env bash

mute_sound="$HOME/.local/share/sounds/mute.mp3"
unmute_sound="$HOME/.local/share/sounds/unmute.mp3"

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    sound="$mute_sound"
else
    sound="$unmute_sound"
fi

# node.virtual=true streams are excluded from vesktop audio capture,
# when "Ignore Virtual" setting is on:
pw-play --properties '{ node.virtual=true }' --volume 0.35 "$sound"
