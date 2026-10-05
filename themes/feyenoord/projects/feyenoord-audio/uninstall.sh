#!/usr/bin/env bash
# Remove the FEYENOORD audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/feyenoord-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/feyenoord-audio"
rm -f "$HOME/.local/bin/feyenoord-audio" "$data/applications/feyenoord-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "FEYENOORD Audio removed."
