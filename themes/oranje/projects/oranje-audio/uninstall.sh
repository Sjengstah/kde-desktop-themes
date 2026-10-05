#!/usr/bin/env bash
# Remove the ORANJE audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/oranje-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/oranje-audio"
rm -f "$HOME/.local/bin/oranje-audio" "$data/applications/oranje-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "ORANJE Audio removed."
