#!/usr/bin/env bash
# KDE desktop themes: remove everything install.sh put in your home folder. No sudo.
#
#   ./uninstall.sh          asks first
#   ./uninstall.sh --yes    no questions
#
# Before you run it: pick another Global Theme (e.g. Breeze) in System Settings and take
# the theme widgets off your panels, or Plasma shows empty placeholders where they were.
# Your panels, icons and fonts are left alone. Settings backups made by install.sh stay in
# ~/.config/desktop-themes-backup-*.
set -euo pipefail

DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN="$HOME/.local/bin"
STATE="$CONF/desktop-theme"
ALL=(lcars rbr oranje feyenoord mvv maastricht starwars stargate)

if [[ "${1:-}" != "--yes" && "${1:-}" != "-y" ]]; then
    sed -n '2,/^set -euo/{/^#/s/^# \{0,1\}//p}' "$0" | sed '$d'
    read -r -p "Remove all desktop themes now? [y/N] " answer
    [[ "$answer" =~ ^[Yy] ]] || { echo "Cancelled."; exit 0; }
fi

systemctl --user disable --now desktop-theme-sync.path >/dev/null 2>&1 || true
rm -f "$CONF/systemd/user/desktop-theme-sync.path" "$CONF/systemd/user/desktop-theme-sync.service"
systemctl --user daemon-reload || true

rm -f "$STATE/current"   # so the active theme can be removed too
for t in "${ALL[@]}"; do "$BIN/desktop-theme" remove "$t" 2>/dev/null || true; done

# GTK 4 colour blocks
python3 - "$CONF/gtk-4.0/gtk.css" "${ALL[@]}" <<'PY'
import re, sys, pathlib
css = pathlib.Path(sys.argv[1])
if css.exists():
    text = css.read_text()
    for t in sys.argv[2:]:
        text = re.sub(r"\n*/\* %s-BEGIN \*/.*?/\* %s-END \*/\n?" % (t.upper(), t.upper()), "\n", text, flags=re.S)
    css.write_text(text)
PY

kwriteconfig6 --file kglobalshortcutsrc --group services --group desktop-audio.desktop --key _launch --delete 2>/dev/null || true
rm -f "$DATA/applications/desktop-audio.desktop" "$BIN/desktop-theme" "$BIN/desktop-audio" \
      "$CONF/fish/completions/desktop-theme.fish" "$DATA/bash-completion/completions/desktop-theme"
rm -rf "$DATA/desktop-themes" "$STATE"
kbuildsycoca6 >/dev/null 2>&1 || true
echo "Removed. Restart Plasma (or log out) to finish: systemctl --user restart plasma-plasmashell"
