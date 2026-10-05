#!/usr/bin/env bash
# Remove the LCARS audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/lcars-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/lcars-audio"
rm -f "$HOME/.local/bin/lcars-audio" "$data/applications/lcars-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "LCARS Audio removed."
