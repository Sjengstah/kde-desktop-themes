#!/usr/bin/env bash
# ORANJE global theme: installer
#
# What it does:
#   Installs the ORANJE look for KDE Plasma, for the current user only (no sudo):
#   1. Removes an older copy of the ORANJE theme parts first, so files from an older
#      version don't linger
#   2. Copies the Plasma style (desktoptheme), the global theme (look-and-feel), the
#      window decoration (aurorae), the colour scheme and the wallpapers to ~/.local/share/
#   3. Installs the splash-screen font and refreshes the font cache
#   4. Clears Plasma's cached copy of the theme, so the new files are really used
#   It does NOT switch your desktop to ORANJE: at the end it prints the two commands
#   that do that.
#
# How to run:  bash install.sh   (from this folder; running it again updates the theme)
# Undo:        delete the ORANJE folders in ~/.local/share/plasma/desktoptheme,
#              plasma/look-and-feel, aurorae/themes and wallpapers, and
#              ~/.local/share/color-schemes/ORANJE.colors; pick another theme first.
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
