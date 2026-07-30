#!/bin/bash
SINK="@DEFAULT_AUDIO_SINK@"

case "$BLOCK_BUTTON" in
    1) wpctl set-mute "$SINK" toggle ;;         # LMB – mute/unmute
    3) pavucontrol & ;;                        # PPM – otwórz mixer
    4) wpctl set-volume "$SINK" 5%+ ;;         # scroll góra
    5) wpctl set-volume "$SINK" 5%- ;;         # scroll dół
esac

# Get volume state from wpctl
# Output example: "Volume: 0.45" or "Volume: 0.45 [MUTED]"
status=$(wpctl get-volume "$SINK")

if echo "$status" | grep -q "MUTED"; then
    echo "muted"
else
    # Converts 0.45 into 45% using awk arithmetic
    echo "$status" | awk '{print int($2 * 100)"%"}'
fi
