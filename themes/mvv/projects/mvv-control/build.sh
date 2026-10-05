#!/usr/bin/env bash
# Copy the shared MVV components into both widgets and build the .plasmoid files.
#   ./build.sh            build only
#   ./build.sh install    build and install/upgrade both widgets for this user
set -euo pipefail
cd "$(dirname "$0")"

for widget in control notify; do
    cp shared/*.qml shared/qmldir "$widget/contents/ui/"
    mkdir -p "$widget/contents/ui/fonts"
    cp shared/fonts/* "$widget/contents/ui/fonts/"
    rm -f "mvv-$widget.plasmoid"
    (cd "$widget" && bsdtar --format zip -cf "../mvv-$widget.plasmoid" metadata.json contents)
    echo "built mvv-$widget.plasmoid"
done

if [[ "${1:-}" == "install" ]]; then
    for widget in control notify; do
        kpackagetool6 -t Plasma/Applet -u "mvv-$widget.plasmoid" 2>/dev/null \
            || kpackagetool6 -t Plasma/Applet -i "mvv-$widget.plasmoid"
    done
    echo "Installed. Restart Plasma to load changes in widgets already on a panel:"
    echo "  systemctl --user restart plasma-plasmashell"
fi
