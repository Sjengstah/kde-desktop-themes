#!/usr/bin/env bash
# Remove the RBR audio overlay. Remove its shortcut in System Settings afterwards.
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f -- "$data/rbr-audio/Overlay.qml" 2>/dev/null || true
rm -rf "$data/rbr-audio"
rm -f "$HOME/.local/bin/rbr-audio" "$data/applications/rbr-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true
echo "RBR Audio removed."
