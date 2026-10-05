#!/usr/bin/env bash
# Render the RBR wallpaper package images (needs rsvg-convert from librsvg).
# Extra sizes: ./render.sh 2880x1800 ...   Exact fit for one machine:
#   python3 make-wallpaper.py W H SCALE TOP_PANEL BOTTOM_PANEL | rsvg-convert -o out.png
set -euo pipefail
cd "$(dirname "$0")"
sizes=("$@")
[[ ${#sizes[@]} -gt 0 ]] || sizes=(1366x768 1600x900 1920x1080 1920x1200 2256x1504 2560x1440
                                   2560x1600 2880x1800 2880x1920 3000x2000 3440x1440 3840x2160)
mkdir -p RBR/contents/images
for s in "${sizes[@]}"; do
    python3 make-wallpaper.py "${s%x*}" "${s#*x}" | rsvg-convert -o "RBR/contents/images/$s.png"
    echo "  $s"
done
rsvg-convert -w 400 RBR/contents/images/1920x1080.png -o RBR/contents/screenshot.png 2>/dev/null \
    || python3 make-wallpaper.py 1920 1080 | rsvg-convert -w 400 -o RBR/contents/screenshot.png
