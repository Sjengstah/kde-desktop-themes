#!/usr/bin/env bash
# Install the LCARS global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/LCARS" "$data/plasma/look-and-feel/LCARS" \
       "$data/aurorae/themes/LCARS" "$data/wallpapers/LCARS"
cp -r desktoptheme/LCARS "$data/plasma/desktoptheme/"
cp -r look-and-feel/LCARS "$data/plasma/look-and-feel/"
cp -r aurorae/LCARS "$data/aurorae/themes/"
cp -r wallpapers/LCARS "$data/wallpapers/"
cp color-schemes/LCARS.colors "$data/color-schemes/"
cp look-and-feel/LCARS/contents/splash/fonts/Antonio.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_LCARS*.kcache

echo "LCARS installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a LCARS"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/LCARS\""
