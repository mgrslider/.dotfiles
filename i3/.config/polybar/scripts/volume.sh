#!/bin/bash
SINK="@DEFAULT_AUDIO_SINK@"

print_vol() {
    status=$(wpctl get-volume "$SINK")
    if echo "$status" | grep -q "MUTED"; then
        echo "volume muted"
    else
        echo "$status" | awk '{print "volume "int($2 * 100)"%"}'
    fi
}

case "$1" in
    mute)   wpctl set-mute "$SINK" toggle ; exit 0 ;;
    mixer)  setsid pavucontrol >/dev/null 2>&1 & exit 0 ;;
    up)     wpctl set-volume -l 1.5 "$SINK" 5%+ ; exit 0 ;; #-l 1.5 limit na 150%
    down)   wpctl set-volume "$SINK" 5%- ; exit 0 ;;
    watch)
        trap 'kill 0' EXIT INT TERM
        print_vol
        pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
            print_vol
        done
        exit 0 ;;
esac

print_vol
