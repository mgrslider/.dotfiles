#!/bin/bash
# Argument $1 = nazwa VPN
VPN_NAME="$1"
SERVICE="openvpn@${VPN_NAME}"

if [[ "$BLOCK_BUTTON" == "1" ]]; then
    if systemctl is-active --quiet "$SERVICE"; then
        sudo systemctl stop "$SERVICE"
    else
        sudo systemctl start "$SERVICE"
    fi
elif [[ "$BLOCK_BUTTON" == "3" ]]; then
    notify-send "VPN: $VPN_NAME" "$(systemctl is-active "$SERVICE")"
fi

if systemctl is-active --quiet "$SERVICE"; then
    ACTIVE_IFACE=$(ip -4 addr show 2>/dev/null | \
                   grep -E '^[0-9]+: (tun|tap)' -A 2 | \
                   grep -E 'inet ' | head -n1 | \
                   awk -F': ' '{print $1}' | awk '{print $2}' | cut -d@ -f1)
    if [[ -n "$ACTIVE_IFACE" ]]; then
        echo "󰒃 $VPN_NAME"
        echo "󰒃"
        echo "#a6e3a1"
    else
        echo "󰒃 $VPN_NAME..."
        echo "󰒃"
        echo "#f9e2af"
    fi
else
    echo "󰒄 $VPN_NAME"
    echo "󰒄"
    echo "#6c7086"
fi
