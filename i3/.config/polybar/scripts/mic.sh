#!/bin/bash
SRC="@DEFAULT_AUDIO_SOURCE@"

print_mic() {
    status=$(wpctl get-volume "$SRC")
    if echo "$status" | grep -q "MUTED"; then
        echo "%{F#6c7086}󰍭%{F-}"
    else
        echo "$status" | awk '{print "󰍬 "int($2 * 100)"%"}'
    fi
}

case "$1" in
    mute)  wpctl set-mute "$SRC" toggle ; exit 0 ;;
    up)    wpctl set-volume -l 1.0 "$SRC" 5%+ ; exit 0 ;;
    down)  wpctl set-volume "$SRC" 5%- ; exit 0 ;;
    watch)
        trap 'kill 0' EXIT INT TERM
        print_mic
        pactl subscribe 2>/dev/null | grep --line-buffered "source" | while read -r _; do
            print_mic
        done
        exit 0 ;;
esac

print_mic
