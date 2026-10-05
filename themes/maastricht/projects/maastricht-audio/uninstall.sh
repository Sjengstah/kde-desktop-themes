#!/usr/bin/env bash
# Remove the MAASTRICHT audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/maastricht-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/maastricht-audio"
rm -f "$HOME/.local/bin/maastricht-audio" "$data/applications/maastricht-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "MAASTRICHT Audio removed."
