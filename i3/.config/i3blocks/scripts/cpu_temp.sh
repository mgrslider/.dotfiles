#!/usr/bin/env bash
temp=$(sensors -u k10temp-pci-00c3 2>/dev/null | awk '/temp1_input/{printf "%.0f", $2; exit}')
[ -z "$temp" ] && temp=0
if   [ "$temp" -ge 70 ]; then color="#FF0000"
elif [ "$temp" -ge 60 ]; then color="#FFAA00"
else color="#00FF00"
fi
printf '%s °C\n%s °C\n%s\n' "$temp" "$temp" "$color"
