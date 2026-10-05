#!/usr/bin/env python3
"""Detect this machine's hardware via ksystemstats and bake it into a theme's widgets.

Usage: detect-hardware.py <theme dir> [--dry-run]
Patches the default settings of the theme's System Monitor (GPU, CPU temperature
sensor, disks) and the popup offsets of the Notification Center and audio overlay
(from the captured top panel height). Prints what it found.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

payload = Path(sys.argv[1])
tid = next(payload.glob("projects/*-monitor")).name[:-len("-monitor")]
dry = "--dry-run" in sys.argv


def sensors():
    try:
        out = subprocess.run(["kstatsviewer", "--list"], capture_output=True, text=True, timeout=30).stdout
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return {}
    found = {}
    for line in out.splitlines():
        sid, _, name = line.partition(" ")
        found[sid] = name.strip()
    return found


s = sensors()
if not s:
    print("  ! ksystemstats not available; keeping generic defaults")
    s = {}

gpus = sorted({m.group(1) for sid in s if (m := re.fullmatch(r"gpu/(gpu\d+)/usage", sid))})
gpu = gpus[0] if gpus else "gpu0"

if "cpu/all/maximumTemperature" in s:
    cpu_temp = "cpu/all/maximumTemperature"
else:
    candidates = [sid for sid in s if re.fullmatch(r"lmsensors/(k10temp|coretemp|zenpower)[^/]*/temp\d+", sid)]
    cpu_temp = sorted(candidates)[0] if candidates else "cpu/all/maximumTemperature"

disks = []
for sid in s:
    m = re.fullmatch(r"disk/([^/]+)/usedPercent", sid)
    if not m or m.group(1) == "all":
        continue
    did = m.group(1)
    name = s.get(f"disk/{did}", did)
    label = "SYSTEM" if name.lower() in ("root", "/") else re.sub(r"[,=]", " ", name).upper()
    disks.append((0 if label == "SYSTEM" else 1, did, label))
disks.sort()
disk_setting = ",".join(f"{did}={label}" for _, did, label in disks)

layout = json.loads((payload / "layout.json").read_text())
top = [p for p in layout["panels"] if p["location"] == "top"]
top_height = top[0].get("props", {}).get("height", top[0]["thickness"]) if top else 0

print(f"  GPU            : {gpu}  {s.get(f'gpu/{gpu}', '')}")
print(f"  CPU temperature: {cpu_temp}")
print(f"  Disks          : {disk_setting or '(all disks combined)'}")
print(f"  Top panel      : {top_height} px")
if dry:
    sys.exit(0)


def set_default(xml, entry, value):
    text = xml.read_text()
    pattern = re.compile(r'(<entry name="%s" type="\w+">\s*<default>)(.*?)(</default>)' % entry, re.S)
    if not pattern.search(text):
        print(f"  ! {entry} not found in {xml}")
        return
    xml.write_text(pattern.sub(lambda m: m.group(1) + value + m.group(3), text, count=1))


monitor = payload / f"projects/{tid}-monitor/package/contents/config/main.xml"
set_default(monitor, "gpu", gpu)
set_default(monitor, "cpuTempSensor", cpu_temp)
set_default(monitor, "disks", disk_setting)

notify = payload / f"projects/{tid}-control/notify/contents/config/main.xml"
set_default(notify, "popupTopMargin", str(top_height + 8))

# The overlay exists twice: standalone (Meta+G) and inside the theme's Audio widget.
for overlay in (payload / f"projects/{tid}-audio/Overlay.qml",
                payload / f"projects/{tid}-audio/plasmoid/contents/ui/Overlay.qml"):
    if overlay.exists():
        text = overlay.read_text()
        overlay.write_text(re.sub(r"(readonly property int topPanelHeight: )\d+", rf"\g<1>{top_height}", text, count=1))
print("  Widget defaults updated for this machine.")
