#!/bin/bash
pw-mon | grep --line-buffered -E "mod.client|changed" | while read -r _; do
    pkill -RTMIN+10 i3blocks
done
