#!/usr/bin/env bash
# MAASTRICHT Audio: uninstaller
#
# What it does:
#   Removes everything install.sh put in place, for the current user (no sudo):
#   1. Closes the overlay if it is open
#   2. Deletes ~/.local/share/maastricht-audio/, ~/.local/bin/maastricht-audio and the menu entry
#      ~/.local/share/applications/maastricht-audio.desktop
#   3. Refreshes KDE's menu cache
#   Your keyboard shortcut is NOT removed: delete it yourself in System Settings >
#   Keyboard > Shortcuts.
#
# How to run:  bash uninstall.sh
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/maastricht-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/maastricht-audio"
rm -f "$HOME/.local/bin/maastricht-audio" "$data/applications/maastricht-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "MAASTRICHT Audio removed."
