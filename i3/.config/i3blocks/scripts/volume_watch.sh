#!/bin/bash
pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
    now=$(date +%s%3N)
    if [ $(( now - ${last:-0} )) -ge 200 ]; then
        pkill -RTMIN+10 i3blocks
        last=$now
    fi
done
