#!/bin/bash
VPN_NAME="$1"
ACTION="$2"
SERVICE="openvpn-client@${VPN_NAME}"

case "$ACTION" in
    toggle)
        if systemctl is-active --quiet "$SERVICE"; then
            sudo systemctl stop "$SERVICE"
        else
            sudo systemctl start "$SERVICE"
        fi
        exit 0 ;;
    info)
        notify-send "VPN: $VPN_NAME" "$(systemctl is-active "$SERVICE")"
        exit 0 ;;
esac

if systemctl is-active --quiet "$SERVICE"; then
    ACTIVE_IFACE=$(ip -4 addr show 2>/dev/null | \
                   grep -E '^[0-9]+: (tun|tap)' -A 2 | \
                   grep -E 'inet ' | head -n1 | \
                   awk -F': ' '{print $1}' | awk '{print $2}' | cut -d@ -f1)
    if [[ -n "$ACTIVE_IFACE" ]]; then
        echo "%{F#a6e3a1}󰒃 $VPN_NAME%{F-}"
    else
        echo "%{F#f9e2af}󰒃 $VPN_NAME...%{F-}"
    fi
else
    echo "%{F#6c7086}󰒄 $VPN_NAME%{F-}"
fi
