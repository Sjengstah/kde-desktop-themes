#!/usr/bin/env bash
# MVV Audio: uninstaller
#
# What it does:
#   Removes everything install.sh put in place, for the current user (no sudo):
#   1. Closes the overlay if it is open
#   2. Deletes ~/.local/share/mvv-audio/, ~/.local/bin/mvv-audio and the menu entry
#      ~/.local/share/applications/mvv-audio.desktop
#   3. Refreshes KDE's menu cache
#   Your keyboard shortcut is NOT removed: delete it yourself in System Settings >
#   Keyboard > Shortcuts.
#
# How to run:  bash uninstall.sh
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/mvv-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/mvv-audio"
rm -f "$HOME/.local/bin/mvv-audio" "$data/applications/mvv-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "MVV Audio removed."
