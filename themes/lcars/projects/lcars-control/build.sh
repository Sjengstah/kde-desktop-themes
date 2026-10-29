#!/usr/bin/env bash
# lcars control widgets: build script
#
# What it does:
#   The lcars theme has two Plasma widgets that share code: "control" (the panel
#   control centre) and "notify" (notifications). This script:
#   1. Copies the shared QML files and fonts from shared/ into both widgets
#   2. Packs each widget into a lcars-control.plasmoid / lcars-notify.plasmoid file
#      (a zip), next to this script
#   3. Only with "install": installs both into Plasma for the current user, or
#      upgrades them if they're already installed (kpackagetool6)
#   No sudo. Widgets already on a panel only pick up changes after a Plasma restart
#   (it prints the command).
#
# Copy the shared LCARS components into both widgets and build the .plasmoid files.
#   ./build.sh            build only
#   ./build.sh install    build and install/upgrade both widgets for this user
set -euo pipefail
cd "$(dirname "$0")"

for widget in control notify; do
    cp shared/*.qml shared/qmldir "$widget/contents/ui/"
    mkdir -p "$widget/contents/ui/fonts"
    cp shared/fonts/* "$widget/contents/ui/fonts/"
    rm -f "lcars-$widget.plasmoid"
    (cd "$widget" && bsdtar --format zip -cf "../lcars-$widget.plasmoid" metadata.json contents)
    echo "built lcars-$widget.plasmoid"
done

if [[ "${1:-}" == "install" ]]; then
    for widget in control notify; do
        kpackagetool6 -t Plasma/Applet -u "lcars-$widget.plasmoid" 2>/dev/null \
            || kpackagetool6 -t Plasma/Applet -i "lcars-$widget.plasmoid"
    done
    echo "Installed. Restart Plasma to load changes in widgets already on a panel:"
    echo "  systemctl --user restart plasma-plasmashell"
fi
