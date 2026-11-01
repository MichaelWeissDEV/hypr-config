#!/usr/bin/env bash
# Bereich auswählen, als PNG speichern/kopieren und optional mit Satty bearbeiten.
set -euo pipefail
umask 077

usage() {
    printf 'Usage: screenshot [region|window|monitor|full]\n  region   Bereich auswählen (Standard)\n  window   Aktives Fenster aufnehmen\n  monitor  Aktiven Bildschirm aufnehmen\n  full     Alle Bildschirme aufnehmen\n\nAufnahmen werden gespeichert, kopiert und mit Satty geöffnet.\nSCREENSHOT_DIR überschreibt den Speicherort (Standard: ~/Downloads).\n'
}

case "${1:-region}" in
    region|window|monitor|full) mode="${1:-region}" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac
if (( $# > 1 )); then
    usage >&2
    exit 2
fi

required=(grim wl-copy)
if [[ "$mode" == region ]]; then
    required+=(slurp)
elif [[ "$mode" == window || "$mode" == monitor ]]; then
    required+=(hyprctl jq)
fi
for cmd in "${required[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Screenshot: %s fehlt (Pakete: grim slurp wl-clipboard hyprland jq).\n' "$cmd" >&2
        exit 1
    fi
done

args=()
if [[ "$mode" == region ]]; then
    # Escape/Abbruch darf weder einen Screenshot noch eine leere Datei erzeugen.
    geometry="$(slurp -b 1e1e2e99 -c 89b4faff -s 00000000 -w 2)" || exit 0
    [[ -n "$geometry" ]] || exit 0
    args=(-g "$geometry")
elif [[ "$mode" == window ]]; then
    geometry="$(hyprctl -j activewindow | jq -er '
        select(.mapped == true and .hidden != true and .size[0] > 0 and .size[1] > 0)
        | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
    ')" || { printf 'Screenshot: Kein aktives Fenster verfügbar.\n' >&2; exit 1; }
    args=(-g "$geometry")
elif [[ "$mode" == monitor ]]; then
    monitor="$(hyprctl -j monitors | jq -er '.[] | select(.focused == true) | .name | select(length > 0)')" \
        || { printf 'Screenshot: Kein aktiver Bildschirm verfügbar.\n' >&2; exit 1; }
    args=(-o "$monitor")
fi

output_dir="${SCREENSHOT_DIR:-$HOME/Downloads}"
mkdir -p -- "$output_dir"
file="$(mktemp "$output_dir/screenshot-$(date +%Y%m%d-%H%M%S)-XXXXXX.png")"
if ! grim "${args[@]}" "$file"; then
    rm -f -- "$file"
    printf 'Screenshot: Aufnahme fehlgeschlagen.\n' >&2
    exit 1
fi

if ! wl-copy --type image/png < "$file"; then
    printf 'Screenshot gespeichert: %s (Zwischenablage fehlgeschlagen).\n' "$file" >&2
    exit 1
fi

if command -v satty >/dev/null 2>&1; then
    satty_args=()
    satty_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/satty.toml"
    if [[ -f "$satty_config" ]]; then
        satty_args+=(--config "$satty_config")
    else
        # Auch ohne aktivierte Defaults bleibt der bisherige Workflow verfügbar.
        satty_args+=(--copy-command 'wl-copy --type image/png' --save-after-copy \
            --early-exit all --initial-tool arrow)
    fi
    # Enter/Strg+C kopiert die bearbeitete Version und speichert sie zusätzlich.
    exec satty "${satty_args[@]}" --filename "$file" --output-filename "$file"
fi

printf 'Screenshot gespeichert und kopiert: %s\n' "$file"
printf 'Für Pfeile, Text und Markierungen: sudo pacman -S --needed satty\n' >&2
