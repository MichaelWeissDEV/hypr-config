#!/usr/bin/env bash
# Bereich auswählen, als PNG speichern/kopieren und optional mit Satty bearbeiten.
set -euo pipefail
umask 077

usage() {
    printf 'Usage: screenshot [region|full]\n  region  Bereich auswählen und bearbeiten (Standard)\n  full    Alle Bildschirme aufnehmen und bearbeiten\n'
}

case "${1:-region}" in
    region|full) mode="${1:-region}" ;;
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
fi
for cmd in "${required[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Screenshot: %s fehlt (Pakete: grim slurp wl-clipboard).\n' "$cmd" >&2
        exit 1
    fi
done

args=()
if [[ "$mode" == region ]]; then
    # Escape/Abbruch darf weder einen Screenshot noch eine leere Datei erzeugen.
    geometry="$(slurp)" || exit 0
    [[ -n "$geometry" ]] || exit 0
    args=(-g "$geometry")
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
    # Enter/Strg+C kopiert die bearbeitete Version und speichert sie zusätzlich.
    exec satty --filename "$file" --output-filename "$file" \
        --copy-command 'wl-copy --type image/png' --save-after-copy \
        --early-exit all --initial-tool arrow
fi

printf 'Screenshot gespeichert und kopiert: %s\n' "$file"
printf 'Für Pfeile, Text und Markierungen: sudo pacman -S --needed satty\n' >&2
