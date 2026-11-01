# Hyprland configuration

Hyprland-Desktop mit Fenster-/Slot-Wechsel, Screenshots, Menüs und Multi-Monitor-Unterstützung.

**[Vollständige Dokumentation und Keybindings](https://arch-dotfiles.readthedocs.io/en/latest/hyprland/)** ·
[Komponenten](https://arch-dotfiles.readthedocs.io/en/latest/components/#hyprland) ·
[Installation und Sicherheit](https://arch-dotfiles.readthedocs.io/en/latest/arch-package/)

```bash
curl -fsSL https://raw.githubusercontent.com/MichaelWeissDEV/dotfiles/main/install.sh | bash -s -- hypr
```

Paket: `arch-dotfiles-hypr`. Einstieg: `~/.config/hypr/hyprland.lua`.
Rechnerabhängige Monitorregeln gehören in die nicht verteilte `monitors.local.lua`.
Desktop-Komponenten werden als Paketabhängigkeiten installiert; es wird keine
laufende Sitzung automatisch neugestartet.

In diesem Repository entwickeln und auf `main` pushen. Nach erfolgreichem
Registry-Build mit `sudo pacman -Syu` aktualisieren. [PACKAGING.md](PACKAGING.md).

### Screenshot / Snipping Tool

`grim`, `slurp`, `wl-clipboard` und Satty werden mit dem Hyprland-Paket installiert.
Im Launcher steht **Screenshot (Ausschneiden)** bereit; im Terminal: `screenshot`.

| Taste | Aufnahme |
| --- | --- |
| `Druck` oder `Super + Shift + P` | Bereich auswählen |
| `Alt + Druck` | Aktives Fenster |
| `Shift + Druck` | Aktiver Monitor |
| `Super + Druck` | Alle Monitore |

Die PNG-Datei wird in `~/Downloads` gespeichert und sofort in die Zwischenablage
kopiert. Satty öffnet sich schwebend zum Beschriften mit Pfeilen, Text und
Markierungen. `Enter` / `Strg+C` kopiert und speichert die bearbeitete Version;
`Strg+S` speichert. Danach schließt sich der Editor. Bei aktiver Texteingabe
bestätigt `Enter` zunächst den Text. `Esc` bricht die Auswahl ab; im Editor bleibt
die bereits gespeicherte Originalaufnahme erhalten.

Die Vorgaben liegen in `~/.config/hypr/satty.toml` (Farben passend zum Desktop,
Pfeilwerkzeug, sichtbare Werkzeugleisten). Eigene Anpassungen bleiben wie andere
Benutzereinstellungen bei Updates erhalten. `SCREENSHOT_DIR` überschreibt den
Speicherort, z. B. `SCREENSHOT_DIR="$HOME/Pictures/Screenshots" screenshot region`.
Weitere Modi: `screenshot window`, `screenshot monitor`, `screenshot full`.
Ohne Satty funktioniert weiterhin die Aufnahme samt Speichern und Kopieren.
Fensteraufnahmen zeigen den sichtbaren Bildschirmausschnitt, keine verdeckten
Fensterinhalte. Es läuft kein zusätzlicher Hintergrunddienst.

### Lokale Monitore und Tastenkombinationen

Neue Monitore werden standardmäßig mit bevorzugter Auflösung und Skalierung `1`
automatisch rechts neben den vorhandenen angeordnet (`auto-right`). Explizite
lokale Monitorregeln haben Vorrang; bestehende individuelle Layouts bleiben erhalten.

`~/.config/hypr/monitors.local.lua` ist für rechnerbezogene Monitorregeln vorgesehen und wird nicht paketiert. Die Vorlage `monitors.example.lua` zeigt das Format; `hyprctl monitors all` zeigt Anschlüsse. `Super + S` blendet den Scratchpad-Workspace ein oder aus; `Super + Shift + S` verschiebt das aktive Fenster dorthin. Nach Änderungen `hyprctl reload` und `hyprctl configerrors` ausführen.

Eigene Änderungen in der aktivierten Benutzerkopie bleiben bei der Synchronisierung erhalten; neue abweichende Vorgaben erscheinen als `.pacnew`. Siehe [Update und Wiederherstellung](https://arch-dotfiles.readthedocs.io/en/latest/verification/).

[![Package safety](https://github.com/MichaelWeissDEV/hypr-config/actions/workflows/package.yml/badge.svg)](https://github.com/MichaelWeissDEV/hypr-config/actions/workflows/package.yml)

[MIT-Lizenz](LICENSE).
