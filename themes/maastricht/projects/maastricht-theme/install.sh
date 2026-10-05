#!/usr/bin/env bash
# Install the MAASTRICHT global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/MAASTRICHT" "$data/plasma/look-and-feel/MAASTRICHT" \
       "$data/aurorae/themes/MAASTRICHT" "$data/wallpapers/MAASTRICHT"
cp -r desktoptheme/MAASTRICHT "$data/plasma/desktoptheme/"
cp -r look-and-feel/MAASTRICHT "$data/plasma/look-and-feel/"
cp -r aurorae/MAASTRICHT "$data/aurorae/themes/"
cp -r wallpapers/MAASTRICHT "$data/wallpapers/"
cp color-schemes/MAASTRICHT.colors "$data/color-schemes/"
cp look-and-feel/MAASTRICHT/contents/splash/fonts/FjallaOne-Regular.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_MAASTRICHT*.kcache

echo "MAASTRICHT installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a MAASTRICHT"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/MAASTRICHT\""
