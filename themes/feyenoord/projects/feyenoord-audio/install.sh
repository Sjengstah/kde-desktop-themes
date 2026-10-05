#!/usr/bin/env bash
# Install the FEYENOORD audio overlay for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"

data="${XDG_DATA_HOME:-$HOME/.local/share}"
bin="$HOME/.local/bin"

mkdir -p "$data/feyenoord-audio/fonts" "$bin" "$data/applications"
cp Overlay.qml "$data/feyenoord-audio/"
cp fonts/* "$data/feyenoord-audio/fonts/"
install -m755 feyenoord-audio "$bin/feyenoord-audio"
sed "s|@BIN@|$bin/feyenoord-audio|" feyenoord-audio.desktop > "$data/applications/feyenoord-audio.desktop"
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

echo "FEYENOORD Audio installed."
if (( ${#missing[@]} )); then
    echo
    echo "Missing: ${missing[*]}"
    echo "  Fedora:        sudo dnf install qt6-qtdeclarative layer-shell-qt plasma-pa kf6-kirigami"
    echo "                 (if the QML runtime is still missing: dnf provides '*/qt6/bin/qml')"
    echo "  Arch/CachyOS:  sudo pacman -S qt6-declarative layer-shell-qt plasma-pa kirigami"
fi
echo
echo "Set a shortcut: System Settings > Keyboard > Shortcuts > Add New > Application > FEYENOORD Audio."
echo "(Meta+G is used by KWin's Grid View by default; clear that first if you want Meta+G.)"
