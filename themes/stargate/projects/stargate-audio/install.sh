#!/usr/bin/env bash
# STARGATE Audio: installer
#
# What it does:
#   Installs the STARGATE audio overlay (a pop-up for volume and audio output, in the
#   STARGATE style) for the current user only. No root/sudo needed.
#   1. Copies Overlay.qml and its fonts to ~/.local/share/stargate-audio/
#   2. Installs the launcher script as ~/.local/bin/stargate-audio
#   3. Writes a menu entry (~/.local/share/applications/stargate-audio.desktop) and refreshes
#      KDE's menu cache (kbuildsycoca6), so it shows up in the app menu
#   4. Checks whether the Qt 6 QML runtime and the KDE QML modules the overlay needs
#      (layer-shell, Plasma volume, Kirigami) are installed; if not, it prints the
#      package names to install (Fedora and Arch/CachyOS)
#
# How to run:  bash install.sh   (from this folder; running it again updates the files)
# Afterwards:  give it a shortcut in System Settings > Keyboard > Shortcuts > Add New >
#              Application > STARGATE Audio
# Undo:        bash uninstall.sh
set -euo pipefail
cd "$(dirname "$0")"

data="${XDG_DATA_HOME:-$HOME/.local/share}"
bin="$HOME/.local/bin"

mkdir -p "$data/stargate-audio/fonts" "$bin" "$data/applications"
cp Overlay.qml "$data/stargate-audio/"
cp fonts/* "$data/stargate-audio/fonts/"
install -m755 stargate-audio "$bin/stargate-audio"
sed "s|@BIN@|$bin/stargate-audio|" stargate-audio.desktop > "$data/applications/stargate-audio.desktop"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true

missing=()
runtime_found=false
for runtime in qml6 qml-qt6 /usr/lib64/qt6/bin/qml /usr/lib/qt6/bin/qml; do
    command -v "$runtime" >/dev/null 2>&1 && runtime_found=true && break
done
$runtime_found || missing+=("Qt 6 QML runtime")
for module in org/kde/layershell org/kde/plasma/private/volume org/kde/kirigami; do
    found=false
    for base in /usr/lib64/qt6/qml /usr/lib/qt6/qml /usr/lib/x86_64-linux-gnu/qt6/qml; do
        [[ -d "$base/$module" ]] && found=true && break
    done
    $found || missing+=("$module")
done

echo "STARGATE Audio installed."
if (( ${#missing[@]} )); then
    echo
    echo "Missing: ${missing[*]}"
    echo "  Fedora:        sudo dnf install qt6-qtdeclarative layer-shell-qt plasma-pa kf6-kirigami"
    echo "                 (if the QML runtime is still missing: dnf provides '*/qt6/bin/qml')"
    echo "  Arch/CachyOS:  sudo pacman -S qt6-declarative layer-shell-qt plasma-pa kirigami"
fi
echo
echo "Set a shortcut: System Settings > Keyboard > Shortcuts > Add New > Application > STARGATE Audio."
echo "(Meta+G is used by KWin's Grid View by default; clear that first if you want Meta+G.)"
