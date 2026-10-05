#!/usr/bin/env bash
# Install the ORANJE global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/ORANJE" "$data/plasma/look-and-feel/ORANJE" \
       "$data/aurorae/themes/ORANJE" "$data/wallpapers/ORANJE"
cp -r desktoptheme/ORANJE "$data/plasma/desktoptheme/"
cp -r look-and-feel/ORANJE "$data/plasma/look-and-feel/"
cp -r aurorae/ORANJE "$data/aurorae/themes/"
cp -r wallpapers/ORANJE "$data/wallpapers/"
cp color-schemes/ORANJE.colors "$data/color-schemes/"
cp look-and-feel/ORANJE/contents/splash/fonts/Oswald-Variable.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_ORANJE*.kcache

echo "ORANJE installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a ORANJE"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/ORANJE\""
