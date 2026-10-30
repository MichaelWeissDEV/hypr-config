#!/usr/bin/env bash
# ============================================================================
# FENSTER- & POSITIONS-SWITCHER (Über alle Bildschirme & Workspaces via Fuzzel)
# Tastenkombination: SUPER + G (oder SUPER + # / ALT + F1)
# ============================================================================
set -euo pipefail

if pgrep -x "fuzzel" > /dev/null; then
    pkill -x "fuzzel"
    exit 0
fi

clients_json="$(hyprctl clients -j)"
monitors_json="$(hyprctl monitors -j)"

# Alle sichtbaren/gemappten Fenster aufbereiten:
# Sortierung:
#   1. Zuletzt aktives Fenster (focusHistoryID == 1) ganz oben (Sofort-Enter!)
#   2. Weitere Fenster nach Fokus-Historie (focusHistoryID >= 2)
#   3. Aktuell fokussiertes Fenster (focusHistoryID == 0) am Ende
menu_data="$(jq -r --argjson mons "$monitors_json" '
    (reduce $mons[] as $m ({}; .[($m.id | tostring)] = $m.name)) as $mon_names |
    [ .[] | select(.mapped == true) ] |
    sort_by(
        if .focusHistoryID == 1 then 0
        elif .focusHistoryID > 1 then .focusHistoryID
        else 9999
        end
    ) |
    to_entries[] |
    .key as $idx |
    .value as $w |
    ([ $w.tags[]? | select(startswith("slot_")) | ltrimstr("slot_") ]) as $slots |
    (
        if ($slots | length) > 0 then "Pos " + $slots[0]
        elif $w.focusHistoryID == 1 then "Letztes"
        elif $w.focusHistoryID == 0 then "Aktiv"
        else "#" + (($idx + 1) | tostring)
        end
    ) as $badge |
    ($mon_names[($w.monitor | tostring)] // ("Mon " + ($w.monitor | tostring))) as $mon |
    (
        if ($w.workspace.name | startswith("special:")) then "Scratchpad"
        else "WS " + $w.workspace.name
        end
    ) as $ws |
    (($w.class // "App") | sub("^.*\\."; "")) as $app |
    (($w.title // $app) | gsub("[\r\n\t]"; " ") | if length > 52 then .[0:49] + "..." else . end) as $title |
    "\($w.address)\t[\($badge)]  \($app) — \($title)   (\($mon) · \($ws))"
' <<< "$clients_json")"

if [[ -z "$menu_data" ]]; then
    exit 0
fi

display_lines="$(cut -f2- <<< "$menu_data")"
line_count="$(wc -l <<< "$display_lines")"
if (( line_count > 12 )); then
    line_count=12
fi

chosen="$(printf "%s\n" "$display_lines" | fuzzel --dmenu \
    --prompt="󰖯  Springe zu: " \
    --placeholder="Fenster, Position (Pos 1..9), Programm oder Bildschirm..." \
    --width=72 \
    --lines="$line_count")" || exit 0

if [[ -z "$chosen" ]]; then
    exit 0
fi

# Zugehörige Fenster-Adresse ermitteln
target_addr="$(awk -F'\t' -v sel="$chosen" '$2 == sel { print $1; exit }' <<< "$menu_data")"

if [[ -n "$target_addr" ]]; then
    # Falls das Fenster im Scratchpad (special workspace) liegt und dieser unsichtbar ist, einblenden
    ws_name="$(jq -r --arg addr "$target_addr" '.[] | select(.address == $addr) | .workspace.name // ""' <<< "$clients_json")"
    if [[ "$ws_name" == special:* ]]; then
        special_name="${ws_name#special:}"
        active_special="$(jq -r --arg ws "$ws_name" '.[] | select(.activeSpecialWorkspace.name == $ws) | .name' <<< "$monitors_json")"
        if [[ -z "$active_special" ]]; then
            hyprctl dispatch "hl.dsp.workspace.toggle_special(\"${special_name}\")" >/dev/null 2>&1 || true
        fi
    fi

    hyprctl dispatch "hl.dsp.focus({ window = \"address:${target_addr}\" })" >/dev/null 2>&1
    hyprctl dispatch "hl.dsp.window.alter_zorder({ mode = \"top\", window = \"address:${target_addr}\" })" >/dev/null 2>&1 || true
fi
