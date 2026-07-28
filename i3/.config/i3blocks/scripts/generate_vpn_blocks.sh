#!/bin/bash
CONFIG="$HOME/.config/i3blocks/config"
MARKER_START="# BEGIN VPN AUTOGEN"
MARKER_END="# END VPN AUTOGEN"

# Usuń stary blok między markerami (jeśli istnieje)
sed -i "/$MARKER_START/,/$MARKER_END/d" "$CONFIG"

# Znajdź wszystkie configi openvpn@*
VPN_LIST=$(systemctl list-units --type=service --all --no-legend | grep -oP '(?<=openvpn@)[^. ]+(?=\.service)')

{
    echo "$MARKER_START"
    for vpn in $VPN_LIST; do
        echo "[vpn_$vpn]"
        echo "command=~/.config/i3blocks/scripts/vpn_generic.sh $vpn"
        echo "interval=3"
        echo ""
    done
    echo "$MARKER_END"
} >> "$CONFIG"

# Przeładuj i3blocks
pkill -SIGUSR1 i3blocks 2>/dev/null || killall -HUP i3blocks 2>/dev/null
