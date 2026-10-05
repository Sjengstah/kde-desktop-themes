#!/usr/bin/env bash
# Remove the STARGATE audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/stargate-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/stargate-audio"
rm -f "$HOME/.local/bin/stargate-audio" "$data/applications/stargate-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "STARGATE Audio removed."
