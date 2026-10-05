#!/usr/bin/env python3
"""Generate the RBR wallpaper as SVG for a given resolution (render with rsvg-convert).

Abstract F1 livery: matte navy with a carbon weave, diagonal speed stripes in the
team colours, a fading chequered band and the chamfered RBR frame pieces. No logos.

Usage: make-wallpaper.py WIDTH HEIGHT [SCALE] [TOP_PANEL] [BOTTOM_PANEL] > out.svg

The labelled frame pieces are kept clear of the top and bottom panels. Panel
heights are in logical px (default 34, as in the kit's layout) and SCALE is the
display scale; when omitted it is guessed generously from the height, so a
laptop running at 125-200 % still has its labels clear of the panels.
"""
import sys

W, H = int(sys.argv[1]), int(sys.argv[2])
SCALE = float(sys.argv[3]) if len(sys.argv) > 3 else max(1.25, H / 900)
TOP_PANEL = float(sys.argv[4]) if len(sys.argv) > 4 else 34
BOTTOM_PANEL = float(sys.argv[5]) if len(sys.argv) > 5 else 34
u = H / 100  # layout unit, 1% of height
FLOAT_GAP = 10  # floating panels sit a few logical px off the edge

RED, YELLOW, WHITE, SILVER = "#DB0A40", "#FFC906", "#E8EDF7", "#A9B4CC"
BLUE, LIGHT, STEEL, CORAL = "#3671C6", "#8FAEF5", "#6C7FA8", "#FF5A5F"
NAVY0, NAVY1, NAVY2 = "#050A1E", "#0B1433", "#121E45"

out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
out.append(f"""<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="{NAVY1}"/><stop offset="0.55" stop-color="{NAVY0}"/><stop offset="1" stop-color="#03061A"/>
  </linearGradient>
  <pattern id="carbon" width="{0.8*u}" height="{0.8*u}" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
    <rect width="{0.4*u}" height="{0.4*u}" fill="#ffffff" fill-opacity="0.022"/>
    <rect x="{0.4*u}" y="{0.4*u}" width="{0.4*u}" height="{0.4*u}" fill="#ffffff" fill-opacity="0.022"/>
  </pattern>
  <linearGradient id="fadeL" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0.2" stop-color="#fff" stop-opacity="0"/><stop offset="0.5" stop-color="#fff" stop-opacity="1"/>
  </linearGradient>
  <mask id="stripeFade"><rect width="{W}" height="{H}" fill="url(#fadeL)"/></mask>
  <linearGradient id="fadeR" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#fff" stop-opacity="0.5"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>
  </linearGradient>
  <mask id="flagFade"><rect width="{W}" height="{H}" fill="url(#fadeR)"/></mask>
  <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0" stop-color="{BLUE}" stop-opacity="0.18"/><stop offset="1" stop-color="{BLUE}" stop-opacity="0"/>
  </radialGradient>
</defs>""")
out.append(f'<rect width="{W}" height="{H}" fill="url(#bg)"/>')
out.append(f'<rect width="{W}" height="{H}" fill="url(#carbon)"/>')
out.append(f'<ellipse cx="{W*0.62}" cy="{H*0.6}" rx="{W*0.45}" ry="{H*0.5}" fill="url(#glow)"/>')

# Speed stripes: parallelograms sweeping up to the right across the lower half.
RISE = 42 * u  # how much a stripe climbs from the left edge to the right edge


def band(y_left, thickness, color, opacity):
    """A band crossing the whole screen, rising to the right."""
    y_right = y_left - RISE
    return (f'<polygon points="0,{y_left:.1f} {W},{y_right:.1f} {W},{y_right + thickness:.1f} 0,{y_left + thickness:.1f}" '
            f'fill="{color}" fill-opacity="{opacity}"/>')


stripes = [  # (left edge y in u, thickness in u, colour, opacity)
    (92, 9.0, NAVY2, 0.9),
    (101.6, 5.2, RED, 0.85),
    (107.4, 1.1, YELLOW, 0.9),
    (109.1, 2.4, BLUE, 0.6),
    (112.2, 0.5, SILVER, 0.35),
]
out.append('<g mask="url(#stripeFade)">')
for y, t, c, o in stripes:
    out.append(band(y * u, t * u, c, o))
out.append("</g>")

# Fading chequered band along the bottom right, like a finish line seen at speed.
sq = 1.6 * u
cols, rows = int(W * 0.42 / sq), 3
x0, y0 = W - cols * sq, H - rows * sq - 1.5 * u
out.append('<g mask="url(#flagFade)">')
for r in range(rows):
    for c in range(cols):
        if (r + c) % 2 == 0:
            out.append(f'<rect x="{x0 + c*sq:.1f}" y="{y0 + r*sq:.1f}" width="{sq:.1f}" height="{sq:.1f}" fill="{WHITE}" fill-opacity="0.16"/>')
out.append("</g>")


# RBR frame accents, kept dim so windows and widgets stay the focus
def elbow(x, y, sw, bh, w, h, R, r, color, flip_x=False, flip_y=False, opacity=0.55):
    """Corner piece with a 45° cut outer corner and a chamfered inner corner."""
    sx, sy = (-1 if flip_x else 1), (-1 if flip_y else 1)
    d = f"M0,{h} L0,{R} L{R},0 L{w},0 L{w},{bh} L{sw+r},{bh} L{sw},{bh+r} L{sw},{h} Z"
    return (f'<path d="{d}" fill="{color}" fill-opacity="{opacity}" '
            f'transform="translate({x},{y}) scale({sx},{sy})"/>')


def text(x, y, s, size, color, anchor="start", opacity=0.6):
    return (f'<text x="{x}" y="{y}" font-family="Barlow Condensed" font-style="italic" font-weight="600" font-size="{size}" '
            f'fill="{color}" fill-opacity="{opacity}" text-anchor="{anchor}" letter-spacing="{size*0.04}">{s}</text>')


m = 3 * u  # margin from the left and right screen edges
mt = (TOP_PANEL + FLOAT_GAP) * SCALE + 1.5 * u     # clear of the top panel
mb = (BOTTOM_PANEL + FLOAT_GAP) * SCALE + 1.5 * u  # clear of the bottom panel
sw, bh = 7 * u, 1.8 * u
# Top-right elbow with a bar running left and a label
out.append(elbow(W - m, mt, sw, bh, 34 * u, 18 * u, 4 * u, 1.6 * u, RED, flip_x=True))
out.append(f'<rect x="{W - m - 34*u - 22*u}" y="{mt}" width="{20*u}" height="{bh}" fill="{BLUE}" fill-opacity="0.5"/>')
out.append(text(W - m - 34*u - 23.5*u, mt + bh * 0.95, "RBR 01", 2.6 * u, RED, "end"))
for i, (c, hh, ink) in enumerate([(SILVER, 6, NAVY0), (LIGHT, 10, NAVY0), (STEEL, 5, "#ffffff")]):
    y0 = mt + 18 * u + 0.6 * u + sum([6, 10, 5][:i]) * u + i * 0.6 * u
    out.append(f'<rect x="{W - m - sw}" y="{y0}" width="{sw}" height="{hh*u}" fill="{c}" fill-opacity="0.45"/>')
    out.append(text(W - m - 0.6*u, y0 + hh*u - 0.7*u, f"SECTOR {i+1}", 1.5 * u, ink, "end", 0.9))

# Bottom-left elbow with bar and a race-operations label
out.append(elbow(m, H - mb, sw, bh, 30 * u, 14 * u, 3.5 * u, 1.4 * u, WHITE, flip_y=True, opacity=0.45))
out.append(f'<rect x="{m + 30*u + 0.8*u}" y="{H - mb - bh}" width="{8*u}" height="{bh}" fill="{CORAL}" fill-opacity="0.45"/>')
out.append(f'<rect x="{m + 39.6*u}" y="{H - mb - bh}" width="{24*u}" height="{bh}" fill="{YELLOW}" fill-opacity="0.35"/>')
out.append(text(m + 65*u, H - mb - bh * 0.05, "PIT WALL · RACE OPERATIONS", 2.4 * u, WHITE, "start", 0.5))

# Timing ticks along the top-right bar
for i in range(12):
    x = W - m - 34*u + i * 2.4 * u
    out.append(f'<rect x="{x}" y="{mt + bh + 1*u}" width="{0.25*u}" height="{(1.2 if i % 3 else 2.2)*u}" fill="{RED}" fill-opacity="0.35"/>')

out.append("</svg>")
sys.stdout.write("\n".join(out))
