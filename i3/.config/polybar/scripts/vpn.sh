#!/bin/bash
SELF="$HOME/.config/polybar/scripts/vpn.sh"
LIST="$HOME/.config/polybar/vpn.list"

# --refresh: odświeżenie listy VPN-ów (uruchamiane ręcznie, wymaga sudo)
if [[ "$1" == "--refresh" ]]; then
    sudo ls /etc/openvpn/client/ | grep '\.conf$' | sed 's/\.conf$//' > "$LIST"
    cat "$LIST"
    exit 0
fi

# Obsługa kliknięć: $1 = nazwa VPN, $2 = akcja
if [[ -n "$1" ]]; then
    SERVICE="openvpn-client@$1"
    case "$2" in
        toggle)
            if systemctl is-active --quiet "$SERVICE"; then
                sudo systemctl stop "$SERVICE"
            else
                sudo systemctl start "$SERVICE"
            fi
            ;;
        info)
            notify-send "VPN: $1" "$(systemctl is-active "$SERVICE")"
            ;;
    esac
    exit 0
fi

# Wyświetlanie statusów
[[ -r "$LIST" ]] || exit 0
mapfile -t vpns < "$LIST"

out=()
for vpn in "${vpns[@]}"; do
    [[ -n "$vpn" ]] || continue
    if systemctl is-active --quiet "openvpn-client@$vpn"; then
        since=$(systemctl show -p ActiveEnterTimestamp --value "openvpn-client@$vpn")
        iface=$(journalctl -u "openvpn-client@$vpn" --since "${since:--5min}" --no-pager 2>/dev/null \
                | grep -oE '(net_iface_new: add|TUN/TAP device|device) ([a-z0-9]+)' \
                | awk '{print $NF}' | tail -1)
        if [[ -n "$iface" ]] && ip -4 addr show "$iface" 2>/dev/null | grep -q 'inet '; then
            color="#a6e3a1"; label="󰒃 $vpn"
        else
            color="#f9e2af"; label="󰒃 $vpn..."
        fi
    else
        color="#6c7086"; label="󰒄 $vpn"
    fi
    out+=("%{A1:$SELF $vpn toggle:}%{A3:$SELF $vpn info:}%{F$color}$label%{F-}%{A}%{A}")
done

echo "${out[*]}"
