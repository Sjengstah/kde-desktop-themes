#!/usr/bin/env bash
# Install the STARGATE global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/STARGATE" "$data/plasma/look-and-feel/STARGATE" \
       "$data/aurorae/themes/STARGATE" "$data/wallpapers/STARGATE"
cp -r desktoptheme/STARGATE "$data/plasma/desktoptheme/"
cp -r look-and-feel/STARGATE "$data/plasma/look-and-feel/"
cp -r aurorae/STARGATE "$data/aurorae/themes/"
cp -r wallpapers/STARGATE "$data/wallpapers/"
cp color-schemes/STARGATE.colors "$data/color-schemes/"
cp look-and-feel/STARGATE/contents/splash/fonts/Rajdhani-SemiBold.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_STARGATE*.kcache

echo "STARGATE installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a STARGATE"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/STARGATE\""
