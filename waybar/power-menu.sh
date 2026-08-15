#!/bin/bash

choice=$(printf "  Lock\n󰤄  Suspend\n󰜉  Reboot\n  Power Off" | \
    wofi --dmenu \
		--prompt "Power" \
		--width 200 \
		--height 250)

case "$choice" in
    "  Lock")
        hyprlock
        ;;
    "󰤄  Suspend")
        systemctl suspend
        ;;
    "󰜉  Reboot")
        systemctl reboot
        ;;
    "  Power Off")
        systemctl poweroff
        ;;
esac
