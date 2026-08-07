#!/bin/bash
chosen=$(printf "󰐥 Poweroff\n󰜉 Reboot\n󰍃 Logout\nLock" | \
    rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    *Poweroff) systemctl poweroff ;;
    *Reboot)   systemctl reboot ;;
    *Logout)   i3-msg exit ;;
    *Lock)     i3lock -c 000000 -i /home/mgrslider/arch0.jpg && sleep 1 ;;
esac
