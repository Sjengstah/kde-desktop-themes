#!/usr/bin/env bash
# Audio Overlay: uninstaller
#
# What it does:
#   Removes everything install.sh put in place, for the current user (no sudo):
#   1. Closes the overlay if it is open
#   2. Deletes ~/.local/share/kde-audio-overlay/, ~/.local/bin/kde-audio-overlay and the menu entry
#      ~/.local/share/applications/kde-audio-overlay.desktop
#   3. Refreshes KDE's menu cache
#   Your keyboard shortcut is NOT removed: delete it yourself in System Settings >
#   Keyboard > Shortcuts.
#
# How to run:  bash uninstall.sh
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/kde-audio-overlay/Overlay.qml" 2>/dev/null || true
rm -rf "$data/kde-audio-overlay"
rm -f "$HOME/.local/bin/kde-audio-overlay" "$data/applications/kde-audio-overlay.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "Audio Overlay removed."
