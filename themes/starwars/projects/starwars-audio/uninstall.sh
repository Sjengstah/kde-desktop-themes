#!/usr/bin/env bash
# Remove the STARWARS audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/starwars-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/starwars-audio"
rm -f "$HOME/.local/bin/starwars-audio" "$data/applications/starwars-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "STARWARS Audio removed."
