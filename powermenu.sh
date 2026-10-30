#!/usr/bin/env bash
# ============================================================================
# POWER-MENÜ (Rechts oben unter der Waybar via Fuzzel)
# ============================================================================

if pgrep -x "fuzzel" > /dev/null; then
    pkill -x "fuzzel"
    exit 0
fi

options="󰐥  Herunterfahren\n󰜉  Neu starten\n󰤄  Standby\n󰌾  Bildschirm sperren\n󰍃  Abmelden (TTY)"

chosen="$(printf "%b" "$options" | fuzzel --dmenu \
    --anchor=top-right \
    --x-margin=0 \
    --y-margin=26 \
    --width=22 \
    --lines=5 \
    --hide-prompt)"

case "$chosen" in
    *"Herunterfahren"*)
        systemctl poweroff
        ;;
    *"Neu starten"*)
        systemctl reboot
        ;;
    *"Standby"*)
        systemctl suspend
        ;;
    *"Bildschirm sperren"*)
        hyprlock
        ;;
    *"Abmelden"*)
        hyprctl dispatch 'hl.dsp.exit()'
        ;;
esac
