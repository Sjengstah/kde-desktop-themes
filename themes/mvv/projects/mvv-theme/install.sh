#!/usr/bin/env bash
# Install the MVV global theme for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$data/plasma/desktoptheme" "$data/plasma/look-and-feel" "$data/aurorae/themes" \
         "$data/color-schemes" "$data/wallpapers" "$data/fonts"

rm -rf "$data/plasma/desktoptheme/MVV" "$data/plasma/look-and-feel/MVV" \
       "$data/aurorae/themes/MVV" "$data/wallpapers/MVV"
cp -r desktoptheme/MVV "$data/plasma/desktoptheme/"
cp -r look-and-feel/MVV "$data/plasma/look-and-feel/"
cp -r aurorae/MVV "$data/aurorae/themes/"
cp -r wallpapers/MVV "$data/wallpapers/"
cp color-schemes/MVV.colors "$data/color-schemes/"
cp look-and-feel/MVV/contents/splash/fonts/ArchivoNarrow-Variable.ttf "$data/fonts/"
fc-cache -f "$data/fonts" >/dev/null 2>&1 || true
rm -f "$HOME"/.cache/plasma_theme_MVV*.kcache

echo "MVV installed. Apply it with:"
echo "  plasma-apply-lookandfeel -a MVV"
echo "  plasma-apply-wallpaperimage \"$data/wallpapers/MVV\""
