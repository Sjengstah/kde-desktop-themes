#!/usr/bin/env bash
# Install the FEYENOORD global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/FEYENOORD" "$data/plasma/look-and-feel/FEYENOORD" \
       "$data/aurorae/themes/FEYENOORD" "$data/wallpapers/FEYENOORD"
cp -r desktoptheme/FEYENOORD "$data/plasma/desktoptheme/"
cp -r look-and-feel/FEYENOORD "$data/plasma/look-and-feel/"
cp -r aurorae/FEYENOORD "$data/aurorae/themes/"
cp -r wallpapers/FEYENOORD "$data/wallpapers/"
cp color-schemes/FEYENOORD.colors "$data/color-schemes/"
cp look-and-feel/FEYENOORD/contents/splash/fonts/Teko-Variable.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_FEYENOORD*.kcache

echo "FEYENOORD installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a FEYENOORD"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/FEYENOORD\""
