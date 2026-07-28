#!/bin/bash

case "$BLOCK_BUTTON" in
    1) amixer -D pulse set Master toggle > /dev/null ;;   # LMB – mute/unmute
    3) pavucontrol & ;;                                     # PPM – otwórz mixer
    4) amixer -D pulse set Master 5%+ > /dev/null ;;        # scroll góra
    5) amixer -D pulse set Master 5%- > /dev/null ;;        # scroll dół
esac

vol=$(amixer -D pulse get Master | awk -F'[][]' '/Left:/ {print $2}')
muted=$(amixer -D pulse get Master | grep -o "off" | head -1)

if [ "$muted" = "off" ]; then
    echo "muted"
else
    echo "$vol"
fi
