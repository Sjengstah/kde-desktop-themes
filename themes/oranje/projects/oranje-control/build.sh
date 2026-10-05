#!/usr/bin/env bash
# Copy the shared ORANJE components into both widgets and build the .plasmoid files.
#   ./build.sh            build only
#   ./build.sh install    build and install/upgrade both widgets for this user
set -euo pipefail
cd "$(dirname "$0")"

for widget in control notify; do
    cp shared/*.qml shared/qmldir "$widget/contents/ui/"
    mkdir -p "$widget/contents/ui/fonts"
    cp shared/fonts/* "$widget/contents/ui/fonts/"
    rm -f "oranje-$widget.plasmoid"
    (cd "$widget" && bsdtar --format zip -cf "../oranje-$widget.plasmoid" metadata.json contents)
    echo "built oranje-$widget.plasmoid"
done

if [[ "${1:-}" == "install" ]]; then
    for widget in control notify; do
        kpackagetool6 -t Plasma/Applet -u "oranje-$widget.plasmoid" 2>/dev/null \
            || kpackagetool6 -t Plasma/Applet -i "oranje-$widget.plasmoid"
    done
    echo "Installed. Restart Plasma to load changes in widgets already on a panel:"
    echo "  systemctl --user restart plasma-plasmashell"
fi
