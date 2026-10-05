#!/usr/bin/env bash
# Install the RBR global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/RBR" "$data/plasma/look-and-feel/RBR" \
       "$data/aurorae/themes/RBR" "$data/wallpapers/RBR"
cp -r desktoptheme/RBR "$data/plasma/desktoptheme/"
cp -r look-and-feel/RBR "$data/plasma/look-and-feel/"
cp -r aurorae/RBR "$data/aurorae/themes/"
cp -r wallpapers/RBR "$data/wallpapers/"
cp color-schemes/RBR.colors "$data/color-schemes/"
cp look-and-feel/RBR/contents/splash/fonts/BarlowCondensed-SemiBoldItalic.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_RBR*.kcache

echo "RBR installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a RBR"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/RBR\""
