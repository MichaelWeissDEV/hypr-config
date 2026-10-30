#!/usr/bin/env bash
exec fuzzel --dmenu --password \
    --prompt="󰌾  Passwort: " \
    --placeholder="Sudo-Passwort für zsh & tmux..." \
    --width=38 \
    --lines=0
