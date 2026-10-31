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

### Lokale Monitore und Tastenkombinationen

`~/.config/hypr/monitors.local.lua` ist für rechnerbezogene Monitorregeln vorgesehen und wird nicht paketiert. Die Vorlage `monitors.example.lua` zeigt das Format; `hyprctl monitors all` zeigt Anschlüsse. `Super + S` blendet den Scratchpad-Workspace ein oder aus; `Super + Shift + S` verschiebt das aktive Fenster dorthin. Nach Änderungen `hyprctl reload` und `hyprctl configerrors` ausführen.

Eigene Änderungen in der aktivierten Benutzerkopie bleiben bei der Synchronisierung erhalten; neue abweichende Vorgaben erscheinen als `.pacnew`. Siehe [Update und Wiederherstellung](https://arch-dotfiles.readthedocs.io/en/latest/verification/).

[![Package safety](https://github.com/MichaelWeissDEV/hypr-config/actions/workflows/package.yml/badge.svg)](https://github.com/MichaelWeissDEV/hypr-config/actions/workflows/package.yml)

[MIT-Lizenz](LICENSE).
