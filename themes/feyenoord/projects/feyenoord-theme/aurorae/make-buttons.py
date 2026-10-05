#!/usr/bin/env python3
"""Generate the FEYENOORD window buttons for the Aurorae decoration.

Each button is a flat tile in the theme's corner style, in five states
(active, hover, pressed, inactive, deactivated). Hover and pressed show the glyph.
Run from this folder: python3 make-buttons.py
"""
from pathlib import Path

OUT = Path(__file__).parent / "FEYENOORD"
NAVY, DIM = "#0B0B0E", "#4B4B53"
CORNER = "cut"  # round, cut or square

# name: (colour, pressed colour, glyph colour, glyph drawn on a 24×24 grid)
BUTTONS = {
    "close":       ("#E30613", "#AA040E", "#FFFFFF", '<path d="M8 8l8 8M16 8l-8 8"/>'),
    "maximize":    ("#5A5A68", "#3F3F49", "#FFFFFF", '<path d="M7.5 7.5h9v9h-9Z"/>'),
    "restore":     ("#5A5A68", "#3F3F49", "#FFFFFF", '<path d="M9.5 7h7.5v7.5M7 9.5h7.5V17H7Z"/>'),
    "minimize":    ("#F2C230", "#CEA529", "#0B0B0E", '<path d="M7 12h10"/>'),
    "keepabove":   ("#C9CDD6", "#8E929E", "#0B0B0E", '<path d="M7.5 14l4.5-4.5 4.5 4.5"/>'),
    "keepbelow":   ("#C9CDD6", "#8E929E", "#0B0B0E", '<path d="M7.5 10l4.5 4.5 4.5-4.5"/>'),
    "alldesktops": ("#E6E8EE", "#C9CDD6", "#0B0B0E", '<path d="M9.5 9.5h5v5h-5Z" fill="currentColor"/>'),
}


def tile(x, fill, opacity=1.0):
    if CORNER == "round":
        return f'<rect x="{x}" width="24" height="24" rx="12" fill="{fill}" fill-opacity="{opacity}"/>'
    if CORNER == "square":
        return f'<rect x="{x}" width="24" height="24" fill="{fill}" fill-opacity="{opacity}"/>'
    return f'<path d="M{x + 5} 0H{x + 24}V24H{x}V5Z" fill="{fill}" fill-opacity="{opacity}"/>'


def glyph(x, color, shape):
    return (f'<g transform="translate({x} 0)" fill="none" stroke="{color}" color="{color}" '
            f'stroke-width="2.4" stroke-linecap="square">{shape}</g>')


def button(color, pressed, ink, shape):
    states = [
        ("active-center", tile(0, color)),
        ("hover-center", tile(30, color) + glyph(30, ink, shape)),
        ("pressed-center", tile(60, pressed) + glyph(60, ink, shape)),
        ("inactive-center", tile(90, DIM)),
        ("deactivated-center", tile(120, DIM, 0.4)),
    ]
    body = "\n".join(f'  <g id="{sid}">{content}</g>' for sid, content in states)
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="144" height="24" viewBox="0 0 144 24">\n{body}\n</svg>\n'


for name, spec in BUTTONS.items():
    (OUT / f"{name}.svg").write_text(button(*spec))
print(f"{len(BUTTONS)} buttons written to {OUT}")
