#!/usr/bin/env bash
# Remove the audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/kde-audio-overlay/Overlay.qml" 2>/dev/null || true
rm -rf "$data/kde-audio-overlay"
rm -f "$HOME/.local/bin/kde-audio-overlay" "$data/applications/kde-audio-overlay.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "Audio Overlay removed."
