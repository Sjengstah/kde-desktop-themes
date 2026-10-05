#!/usr/bin/env bash
# Install the audio overlay for the current user (no root needed).
set -euo pipefail
cd "$(dirname "$0")"

data="${XDG_DATA_HOME:-$HOME/.local/share}"
bin="$HOME/.local/bin"

mkdir -p "$data/kde-audio-overlay" "$bin" "$data/applications"
cp Overlay.qml "$data/kde-audio-overlay/"
install -m755 kde-audio-overlay "$bin/kde-audio-overlay"
sed "s|@BIN@|$bin/kde-audio-overlay|" kde-audio-overlay.desktop > "$data/applications/kde-audio-overlay.desktop"
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

echo "Audio Overlay installed."
if (( ${#missing[@]} )); then
    echo
    echo "Missing: ${missing[*]}"
    echo "  Fedora:        sudo dnf install qt6-qtdeclarative layer-shell-qt plasma-pa kf6-kirigami"
    echo "                 (if the QML runtime is still missing: dnf provides '*/qt6/bin/qml')"
    echo "  Arch/CachyOS:  sudo pacman -S qt6-declarative layer-shell-qt plasma-pa kirigami"
fi
echo
echo "Set a shortcut: System Settings > Keyboard > Shortcuts > Add New > Application > Audio Overlay."
echo "(Meta+G is used by KWin's Grid View by default; clear that first if you want Meta+G.)"
