#!/usr/bin/env python3
"""Generate the LCARS wallpaper as SVG for a given resolution (render with rsvg-convert)."""
import math
import random
import sys

W, H = int(sys.argv[1]), int(sys.argv[2])
rnd = random.Random(1701)  # fixed seed: same starfield every time
u = H / 100  # layout unit, 1% of height

ORANGE, GOLD, TAN, PEACH = "#FF9900", "#FFCC66", "#FFCC99", "#FF9966"
VIOLET, LILAC, BLUE, RED = "#CC99CC", "#9999FF", "#6699CC", "#CC6666"

out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
out.append("""<defs>
  <radialGradient id="neb1"><stop offset="0" stop-color="#6644aa" stop-opacity="0.35"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient>
  <radialGradient id="neb2"><stop offset="0" stop-color="#ff9900" stop-opacity="0.12"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient>
  <radialGradient id="neb3"><stop offset="0" stop-color="#3366aa" stop-opacity="0.25"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient>
  <radialGradient id="planet" cx="0.35" cy="0.3" r="0.8"><stop offset="0" stop-color="#2a3550"/><stop offset="0.6" stop-color="#101626"/><stop offset="1" stop-color="#05070c"/></radialGradient>
  <linearGradient id="atmo" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#99CCFF" stop-opacity="0.55"/><stop offset="0.5" stop-color="#99CCFF" stop-opacity="0.05"/></linearGradient>
</defs>""")
out.append(f'<rect width="{W}" height="{H}" fill="#000"/>')

# Nebula glows
out.append(f'<ellipse cx="{W*0.72}" cy="{H*0.32}" rx="{W*0.35}" ry="{H*0.45}" fill="url(#neb1)"/>')
out.append(f'<ellipse cx="{W*0.25}" cy="{H*0.7}" rx="{W*0.3}" ry="{H*0.35}" fill="url(#neb3)"/>')
out.append(f'<ellipse cx="{W*0.55}" cy="{H*0.55}" rx="{W*0.25}" ry="{H*0.3}" fill="url(#neb2)"/>')

# Starfield, density scaled to area
for _ in range(int(W * H / 2600)):
    x, y = rnd.uniform(0, W), rnd.uniform(0, H)
    r = rnd.choice([0.5, 0.6, 0.7, 0.8, 1.0, 1.2, 1.6]) * (H / 1080)
    o = rnd.uniform(0.25, 1.0)
    c = rnd.choice(["#ffffff"] * 8 + ["#ffe8cc", "#cce0ff", "#ffd9b3"])
    out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r:.2f}" fill="{c}" fill-opacity="{o:.2f}"/>')

# Planet rising from the lower right
pr = H * 0.9
pcx, pcy = W * 0.86, H * 1.55
out.append(f'<circle cx="{pcx}" cy="{pcy}" r="{pr}" fill="url(#planet)"/>')
out.append(f'<circle cx="{pcx}" cy="{pcy}" r="{pr}" fill="none" stroke="url(#atmo)" stroke-width="{0.6*u}"/>')

# LCARS frame accents, kept dim so windows and widgets stay the focus
def elbow(x, y, sw, bh, w, h, R, r, color, flip_x=False, flip_y=False, opacity=0.55):
    sx, sy = (-1 if flip_x else 1), (-1 if flip_y else 1)
    d = (f"M0,{h} L0,{R} A{R},{R} 0 0 1 {R},0 L{w},0 L{w},{bh} L{sw+r},{bh} "
         f"A{r},{r} 0 0 0 {sw},{bh+r} L{sw},{h} Z")
    return (f'<path d="{d}" fill="{color}" fill-opacity="{opacity}" '
            f'transform="translate({x},{y}) scale({sx},{sy})"/>')

def text(x, y, s, size, color, anchor="start", opacity=0.6):
    return (f'<text x="{x}" y="{y}" font-family="Antonio" font-weight="600" font-size="{size}" '
            f'fill="{color}" fill-opacity="{opacity}" text-anchor="{anchor}" letter-spacing="{size*0.04}">{s}</text>')

m = 3 * u  # margin from screen edge
sw, bh = 7 * u, 1.8 * u
# Top-right elbow with a bar running left and a label
out.append(elbow(W - m, m, sw, bh, 34 * u, 18 * u, 4 * u, 1.6 * u, ORANGE, flip_x=True))
out.append(f'<rect x="{W - m - 34*u - 22*u}" y="{m}" width="{20*u}" height="{bh}" fill="{VIOLET}" fill-opacity="0.5"/>')
out.append(text(W - m - 34*u - 23.5*u, m + bh * 0.95, "LCARS 47", 2.6 * u, ORANGE, "end"))
for i, (c, hh) in enumerate([(PEACH, 6), (LILAC, 10), (BLUE, 5)]):
    y0 = m + 18 * u + 0.6 * u + sum([6, 10, 5][:i]) * u + i * 0.6 * u
    out.append(f'<rect x="{W - m - sw}" y="{y0}" width="{sw}" height="{hh*u}" fill="{c}" fill-opacity="0.45"/>')
    out.append(text(W - m - 0.6*u, y0 + hh*u - 0.7*u, f"{(i+1)*11:02d}-{rnd.randint(1000,9999)}", 1.5 * u, "#000", "end", 0.9))

# Bottom-left elbow with bar and stardate-style code
out.append(elbow(m, H - m, sw, bh, 30 * u, 14 * u, 3.5 * u, 1.4 * u, TAN, flip_y=True, opacity=0.45))
out.append(f'<rect x="{m + 30*u + 0.8*u}" y="{H - m - bh}" width="{8*u}" height="{bh}" fill="{RED}" fill-opacity="0.45"/>')
out.append(f'<rect x="{m + 39.6*u}" y="{H - m - bh}" width="{24*u}" height="{bh}" fill="{GOLD}" fill-opacity="0.35"/>')
out.append(text(m + 65*u, H - m - bh * 0.05, "UNITED FEDERATION OF PLANETS", 2.4 * u, TAN, "start", 0.5))

# Faint sensor grid ticks along the top-right bar
for i in range(12):
    x = W - m - 34*u + i * 2.4 * u
    out.append(f'<rect x="{x}" y="{m + bh + 1*u}" width="{0.25*u}" height="{(1.2 if i % 3 else 2.2)*u}" fill="{ORANGE}" fill-opacity="0.35"/>')

out.append("</svg>")
sys.stdout.write("\n".join(out))
