#!/bin/bash
sudo ls /etc/openvpn/client/ 2>/dev/null | grep '\.conf$' | sed 's/\.conf$//' > ~/.config/polybar/vpn.list
