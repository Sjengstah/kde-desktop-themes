#!/usr/bin/env bash
# STARGATE global theme: installer
#
# What it does:
#   Installs the STARGATE look for KDE Plasma, for the current user only (no sudo):
#   1. Removes an older copy of the STARGATE theme parts first, so files from an older
#      version don't linger
#   2. Copies the Plasma style (desktoptheme), the global theme (look-and-feel), the
#      window decoration (aurorae), the colour scheme and the wallpapers to ~/.local/share/
#   3. Installs the splash-screen font and refreshes the font cache
#   4. Clears Plasma's cached copy of the theme, so the new files are really used
#   It does NOT switch your desktop to STARGATE: at the end it prints the two commands
#   that do that.
#
# How to run:  bash install.sh   (from this folder; running it again updates the theme)
# Undo:        delete the STARGATE folders in ~/.local/share/plasma/desktoptheme,
#              plasma/look-and-feel, aurorae/themes and wallpapers, and
#              ~/.local/share/color-schemes/STARGATE.colors; pick another theme first.
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
