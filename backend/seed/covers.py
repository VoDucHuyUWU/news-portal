"""
Generated cover illustrations: Art Deco gold line art on black, one motif per section.

Covers are deterministic (seeded by the article slug) and regenerated automatically
when COVER_VERSION changes, so existing databases pick up new artwork without a reset.
"""
from __future__ import annotations

import math
import random
from pathlib import Path

from sqlalchemy import select

from app.config import settings
from app.models import Document

COVER_VERSION = "deco-3"
GOLD, LIGHT, DEEP = "#C9A227", "#E9D7A0", "#8A6D10"
W, H = 1200, 630


def _sunburst(cx: float, cy: float, rng: random.Random) -> str:
    rays = []
    n = rng.choice([28, 36, 44])
    for i in range(n):
        a = math.pi * 2 * i / n
        x2, y2 = cx + math.cos(a) * 1400, cy + math.sin(a) * 1400
        op = 0.07 if i % 2 else 0.13
        rays.append(f'<line x1="{cx:.0f}" y1="{cy:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="{GOLD}" stroke-opacity="{op}" stroke-width="1.2"/>')
    rings = "".join(f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="{r}" fill="none" stroke="{GOLD}" stroke-opacity="0.16" stroke-width="1"/>'
                    for r in (150, 230, 320))
    return "".join(rays) + rings


def _frame() -> str:
    corners = []
    for x, y in ((28, 28), (W - 28, 28), (28, H - 28), (W - 28, H - 28)):
        corners.append(f'<path d="M{x} {y - 9} L{x + 9} {y} L{x} {y + 9} L{x - 9} {y} Z" fill="{GOLD}"/>')
    return (f'<rect x="28" y="28" width="{W - 56}" height="{H - 56}" fill="none" stroke="{GOLD}" stroke-width="1.6"/>'
            f'<rect x="40" y="40" width="{W - 80}" height="{H - 80}" fill="none" stroke="{GOLD}" stroke-opacity="0.45" stroke-width="0.8"/>'
            + "".join(corners))


def _g(cx: float, cy: float, s: float, rot: float, body: str) -> str:
    return (f'<g transform="translate({cx:.0f} {cy:.0f}) rotate({rot:.0f}) scale({s:.2f})" fill="none" stroke="{GOLD}" '
            f'stroke-width="3" stroke-linecap="round" stroke-linejoin="round">{body}</g>')


def _technology(rng: random.Random) -> str:
    parts = ['<rect x="-80" y="-80" width="160" height="160" rx="10"/>',
             f'<rect x="-46" y="-46" width="92" height="92" rx="4" fill="{GOLD}" fill-opacity="0.18"/>']
    for side in range(4):
        for k in range(6):
            off = -62 + k * 25
            length = rng.choice([30, 55, 80, 105])
            bend = rng.choice([-1, 1]) * rng.choice([0, 18, 30])
            pts = [(80, off), (80 + length, off), (80 + length + 22, off + bend)]
            rot = side * 90
            c, s_ = math.cos(math.radians(rot)), math.sin(math.radians(rot))
            tp = [(x * c - y * s_, x * s_ + y * c) for x, y in pts]
            d = " ".join(f"{x:.0f},{y:.0f}" for x, y in tp)
            parts.append(f'<polyline points="{d}" stroke-width="2"/>')
            parts.append(f'<circle cx="{tp[-1][0]:.0f}" cy="{tp[-1][1]:.0f}" r="5" fill="{GOLD}"/>')
    return "".join(parts)


def _science(rng: random.Random) -> str:
    base = rng.randint(0, 60)
    parts = [f'<circle r="20" fill="{GOLD}"/>', f'<circle r="34" stroke-opacity="0.5"/>']
    for i in range(3):
        a = base + i * 60
        parts.append(f'<ellipse rx="210" ry="74" transform="rotate({a})"/>')
        t = rng.random() * math.tau
        ex, ey = 210 * math.cos(t), 74 * math.sin(t)
        r = math.radians(a)
        parts.append(f'<circle cx="{ex * math.cos(r) - ey * math.sin(r):.0f}" cy="{ex * math.sin(r) + ey * math.cos(r):.0f}" r="9" fill="{LIGHT}" stroke="none"/>')
    return "".join(parts)


def _health(rng: random.Random) -> str:
    heart = '<path d="M0 40 C-130 -40 -95 -155 0 -95 C95 -155 130 -40 0 40 Z" stroke-width="3.5"/>'
    pts, x = [], -330
    while x <= 330:
        if -90 < x < 90 and rng.random() < 0.9:
            pts += [(x, 120), (x + 14, 50 - rng.randint(0, 30)), (x + 28, 165), (x + 42, 120)]
            x += 60
        else:
            pts.append((x, 120))
            x += 30
    ecg = "<polyline points=\"" + " ".join(f"{a:.0f},{b:.0f}" for a, b in pts) + f'" stroke="{LIGHT}" stroke-width="2.5"/>'
    return heart + ecg


def _environment(rng: random.Random) -> str:
    leaf = ('<path d="M0 -160 C120 -80 120 80 0 160 C-120 80 -120 -80 0 -160 Z"/>'
            '<line x1="0" y1="-140" x2="0" y2="185" stroke-width="2.5"/>')
    veins = "".join(f'<path d="M0 {y} Q {side * 45} {y - 25} {side * 78} {y - 60}" stroke-width="1.8"/>'
                    for y in range(-80, 120, 40) for side in (-1, 1))
    sx, sy = rng.choice([(190, -150), (-200, -140)])
    sun = f'<circle cx="{sx}" cy="{sy}" r="34" fill="{GOLD}" fill-opacity="0.25"/>' + "".join(
        f'<line x1="{sx + 48 * math.cos(a):.0f}" y1="{sy + 48 * math.sin(a):.0f}" x2="{sx + 68 * math.cos(a):.0f}" '
        f'y2="{sy + 68 * math.sin(a):.0f}" stroke-width="2"/>' for a in [i * math.tau / 12 for i in range(12)])
    waves = "".join(f'<path d="M-260 {200 + k * 18} q 32 -14 65 0 t 65 0 t 65 0 t 65 0 t 65 0 t 65 0 t 65 0 t 65 0" '
                    f'stroke-width="1.6" stroke-opacity="{0.8 - k * 0.25:.2f}"/>' for k in range(3))
    return leaf + veins + sun + waves


def _business(rng: random.Random) -> str:
    heights = sorted(rng.sample(range(50, 230), 5))
    bars = "".join(f'<rect x="{-190 + i * 80}" y="{120 - h}" width="48" height="{h}" fill="{GOLD}" fill-opacity="{0.12 + i * 0.07:.2f}"/>'
                   for i, h in enumerate(heights))
    tops = [(-166 + i * 80, 120 - h - 30) for i, h in enumerate(heights)]
    line = "<polyline points=\"" + " ".join(f"{x},{y}" for x, y in tops) + f'" stroke="{LIGHT}" stroke-width="3"/>'
    ex, ey = tops[-1]
    arrow = f'<path d="M{ex - 22} {ey - 4} L{ex} {ey - 24} L{ex + 6} {ey + 4}" stroke="{LIGHT}" stroke-width="3"/>'
    coins = "".join(f'<ellipse cx="240" cy="{110 - k * 22}" rx="48" ry="14" fill="#0b0b0b"/>' for k in range(rng.randint(3, 6)))
    return '<line x1="-230" y1="122" x2="300" y2="122"/>' + bars + line + arrow + coins


def _education(rng: random.Random) -> str:
    book = ('<path d="M0 -60 C-60 -95 -160 -95 -230 -70 L-230 120 C-160 95 -60 95 0 130 Z"/>'
            '<path d="M0 -60 C60 -95 160 -95 230 -70 L230 120 C160 95 60 95 0 130 Z"/>'
            '<line x1="0" y1="-60" x2="0" y2="130"/>')
    lines = "".join(f'<path d="M{side * 30} {y} C {side * 80} {y - 18} {side * 150} {y - 18} {side * 200} {y - 8}" stroke-width="1.6" stroke-opacity="0.7"/>'
                    for y in range(-30, 100, 22) for side in (-1, 1))
    sx = rng.choice([-120, 0, 120])
    star = (f'<path d="M{sx} -205 L{sx + 10} -172 L{sx + 44} -168 L{sx + 18} -146 L{sx + 26} -112 L{sx} -130 L{sx - 26} -112 '
            f'L{sx - 18} -146 L{sx - 44} -168 L{sx - 10} -172 Z" fill="{GOLD}" fill-opacity="0.3"/>')
    return book + lines + star


MOTIFS = {"technology": _technology, "science": _science, "health": _health, "environment": _environment,
          "business-money": _business, "education": _education}


def cover_svg(slug: str, category_slug: str | None) -> str:
    rng = random.Random(slug)
    cx = rng.choice([420, 600, 780])
    cy = rng.choice([300, 330])
    motif = MOTIFS.get(category_slug or "", _science)(rng)
    bg = rng.choice(["#0B0B0B", "#111111", "#0E0D0A"])
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">'
            f'<rect width="{W}" height="{H}" fill="{bg}"/>{_sunburst(cx, cy, rng)}{_frame()}'
            f'{_g(cx, cy, rng.uniform(1.05, 1.2), rng.choice([0, 0, -6, 6]), motif)}</svg>')


def write_cover(slug: str, category_slug: str | None) -> str:
    folder = settings.media_dir / "covers"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{slug}.svg").write_text(cover_svg(slug, category_slug), encoding="utf-8")
    return f"/media/covers/{slug}.svg"


def ensure_covers(db) -> int:
    """(Re)generate generated covers that are missing or from an older COVER_VERSION."""
    folder: Path = settings.media_dir / "covers"
    marker = folder / ".version"
    outdated = not marker.exists() or marker.read_text().strip() != COVER_VERSION
    count = 0
    for doc in db.execute(select(Document)).unique().scalars():
        url = doc.cover_image_url or ""
        if not url.startswith("/media/covers/"):
            continue  # uploaded or external images are never touched
        slug = url.rsplit("/", 1)[-1].removesuffix(".svg")
        if outdated or not (folder / f"{slug}.svg").exists():
            write_cover(slug, doc.category.slug if doc.category else None)
            count += 1
    folder.mkdir(parents=True, exist_ok=True)
    marker.write_text(COVER_VERSION)
    return count
