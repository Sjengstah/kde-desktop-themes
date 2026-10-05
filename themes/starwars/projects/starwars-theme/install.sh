#!/usr/bin/env bash
# Install the STARWARS global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/STARWARS" "$data/plasma/look-and-feel/STARWARS" \
       "$data/aurorae/themes/STARWARS" "$data/wallpapers/STARWARS"
cp -r desktoptheme/STARWARS "$data/plasma/desktoptheme/"
cp -r look-and-feel/STARWARS "$data/plasma/look-and-feel/"
cp -r aurorae/STARWARS "$data/aurorae/themes/"
cp -r wallpapers/STARWARS "$data/wallpapers/"
cp color-schemes/STARWARS.colors "$data/color-schemes/"
cp look-and-feel/STARWARS/contents/splash/fonts/Orbitron-Variable.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_STARWARS*.kcache

echo "STARWARS installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a STARWARS"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/STARWARS\""
