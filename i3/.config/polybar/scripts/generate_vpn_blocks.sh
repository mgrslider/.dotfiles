#!/bin/bash
OUT="$HOME/.config/polybar/vpn.ini"
SCRIPTS="~/.config/polybar/scripts"
VPN_LIST=$(sudo ls /etc/openvpn/client/ 2>/dev/null | grep '\.conf$' | sed 's/\.conf$//')

{
    echo "[vpn]"
    echo -n "list ="
    for vpn in $VPN_LIST; do echo -n " vpn_$vpn"; done
    echo -e "\n"
    for vpn in $VPN_LIST; do
        echo "[module/vpn_$vpn]"
        echo "type = custom/script"
        echo "exec = $SCRIPTS/vpn_generic.sh $vpn"
        echo "interval = 3"
        echo "click-left = $SCRIPTS/vpn_generic.sh $vpn toggle"
        echo "click-right = $SCRIPTS/vpn_generic.sh $vpn info"
        echo ""
    done
} > "$OUT"

polybar-msg cmd restart 2>/dev/null
