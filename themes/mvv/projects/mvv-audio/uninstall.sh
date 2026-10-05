#!/usr/bin/env bash
# Remove the MVV audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/mvv-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/mvv-audio"
rm -f "$HOME/.local/bin/mvv-audio" "$data/applications/mvv-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "MVV Audio removed."
