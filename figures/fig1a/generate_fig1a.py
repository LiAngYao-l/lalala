#!/usr/bin/env python3
"""
Figure 1A — hPGCLC induction + timed germ-layer competency assay.

Minimalist B&W timeline sized for the wide panel-A slot in Fig. 1.

Phases:
  d0–0.5   CA          (CHIR + Activin A)
  d0.5–2.5 BMP4
  d2.5–7.5 BMP + SCF + EGF

Outputs:
  fig1a_pgc_induction.pptx  — native PowerPoint shapes (edit here)
  fig1a_pgc_induction.svg
  fig1a_pgc_induction.png

Regenerate:  python3 generate_fig1a.py
"""

from __future__ import annotations

from pathlib import Path

from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_CONNECTOR, MSO_SHAPE
from pptx.enum.text import PP_ALIGN
from pptx.oxml import parse_xml
from pptx.util import Inches, Pt
from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).resolve().parent
BLACK = RGBColor(0x00, 0x00, 0x00)
GRAY = RGBColor(0x33, 0x33, 0x33)

SLIDE_W = 7.6
SLIDE_H = 3.95

Y_MAIN = 0.88
LINE_THIN = Pt(1.1)
LINE_MED = Pt(1.45)
DOT_R = 0.042
X_MARK = 0.070

DAY_MIN, DAY_MAX = 0.0, 7.5
X_LEFT, X_RIGHT = 0.85, 7.25

# Protocol phase boundaries
DAY_CA_END = 0.5
DAY_BMP4_END = 2.5

FIX_DAYS = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5]
ARM_START_DAYS = [1.5, 2.5, 3.5, 4.5, 5.5]
ARM_DURATION = 2.0
# Arms start below the rotated day labels
ARM_YS = [1.85, 2.22, 2.59, 2.96, 3.30]

# Day-label rotation: −45° (PPT uses clockwise degrees → 315)
LABEL_ROTATION = 315.0
PANEL_TITLE = "hPGCLC induction and timed germ-layer competency assay."


def day_x(day: float) -> float:
    return X_LEFT + (day - DAY_MIN) / (DAY_MAX - DAY_MIN) * (X_RIGHT - X_LEFT)


def _dash(shape, dash="dash"):
    ln = shape.line._ln
    for child in list(ln):
        if child.tag.endswith("}prstDash"):
            ln.remove(child)
    ln.append(
        parse_xml(
            f'<a:prstDash xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
            f'val="{dash}"/>'
        )
    )


def _fill_black(shape):
    shape.fill.solid()
    shape.fill.fore_color.rgb = BLACK
    shape.line.fill.background()


def add_text(slide, left, top, width, height, text, size=10, bold=False,
             align=PP_ALIGN.CENTER, color=BLACK, font_name="Arial", rotation=0.0):
    box = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    tf = box.text_frame
    tf.word_wrap = False
    tf.auto_size = None
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = color
    run.font.name = font_name
    if rotation:
        box.rotation = rotation
    return box


def add_hline(slide, x1, x2, y, weight=LINE_THIN, dash=None):
    shape = slide.shapes.add_connector(
        MSO_CONNECTOR.STRAIGHT, Inches(x1), Inches(y), Inches(x2), Inches(y)
    )
    shape.line.color.rgb = BLACK
    shape.line.width = weight
    if dash:
        _dash(shape, dash)
    return shape


def add_vline(slide, x, y1, y2, weight=LINE_THIN, dash=None):
    shape = slide.shapes.add_connector(
        MSO_CONNECTOR.STRAIGHT, Inches(x), Inches(y1), Inches(x), Inches(y2)
    )
    shape.line.color.rgb = BLACK
    shape.line.width = weight
    if dash:
        _dash(shape, dash)
    return shape


def add_dot(slide, x, y, r=DOT_R):
    oval = slide.shapes.add_shape(
        MSO_SHAPE.OVAL, Inches(x - r), Inches(y - r), Inches(2 * r), Inches(2 * r)
    )
    _fill_black(oval)
    return oval


def add_x_mark(slide, x, y, size=X_MARK, weight=LINE_MED):
    s = size / 2
    for x1, y1, x2, y2 in (
        (x - s, y - s, x + s, y + s),
        (x - s, y + s, x + s, y - s),
    ):
        c = slide.shapes.add_connector(
            MSO_CONNECTOR.STRAIGHT, Inches(x1), Inches(y1), Inches(x2), Inches(y2)
        )
        c.line.color.rgb = BLACK
        c.line.width = weight


def add_phase_bracket(slide, x1, x2, label, label_size=9):
    """Short bar just above the timeline with a centered phase label above it."""
    bar_y = Y_MAIN - 0.10
    add_hline(slide, x1, x2, bar_y, weight=LINE_THIN)
    add_vline(slide, x1, bar_y, Y_MAIN - DOT_R - 0.01, weight=LINE_THIN)
    add_vline(slide, x2, bar_y, Y_MAIN - DOT_R - 0.01, weight=LINE_THIN)
    add_text(
        slide, x1 - 0.05, Y_MAIN - 0.34, (x2 - x1) + 0.10, 0.20,
        label, size=label_size, bold=True,
    )


def build_pptx(path: Path) -> None:
    prs = Presentation()
    prs.slide_width = Inches(SLIDE_W)
    prs.slide_height = Inches(SLIDE_H)
    slide = prs.slides.add_slide(prs.slide_layouts[6])

    add_text(slide, 0.10, 0.04, 0.26, 0.24, "A", size=13, bold=True, align=PP_ALIGN.LEFT)
    add_text(
        slide, 0.34, 0.05, 7.0, 0.22,
        PANEL_TITLE, size=10, bold=True, align=PP_ALIGN.LEFT,
    )

    x0 = day_x(0)
    x_ca = day_x(DAY_CA_END)
    x_bmp4 = day_x(DAY_BMP4_END)
    x_end = day_x(DAY_MAX)

    # Day-0 vertical bar
    add_vline(slide, x0, Y_MAIN - 0.18, Y_MAIN + 0.18, weight=LINE_MED)
    add_text(slide, x0 - 0.50, Y_MAIN - 0.52, 1.0, 0.18, "hPSCs", size=9, bold=True)

    add_hline(slide, x0, x_end, Y_MAIN, weight=LINE_MED)

    # Phases above the line
    add_phase_bracket(slide, x0, x_ca, "CA", label_size=8)
    add_phase_bracket(slide, x_ca, x_bmp4, "BMP4", label_size=9)
    add_text(
        slide, x_bmp4 + 0.05, Y_MAIN - 0.34, x_end - x_bmp4 - 0.05, 0.20,
        "BMP + SCF + EGF", size=10, bold=True,
    )
    # light bar under cocktail label for continuity with other phase bars
    add_hline(slide, x_bmp4, x_end, Y_MAIN - 0.10, weight=LINE_THIN)
    add_vline(slide, x_bmp4, Y_MAIN - 0.10, Y_MAIN - DOT_R - 0.01, weight=LINE_THIN)
    add_vline(slide, x_end, Y_MAIN - 0.10, Y_MAIN - DOT_R - 0.01, weight=LINE_THIN)

    # Fix dots + 45° day labels ("1.5 days")
    # Textbox is rotated about its center; place so the top of the text sits near the dot.
    label_w, label_h = 0.95, 0.22
    for d in FIX_DAYS:
        xd = day_x(d)
        add_dot(slide, xd, Y_MAIN)
        # Offset so after −45° rotation the label reads cleanly under the tick
        # (anchor near the dot, text extending down-right).
        add_text(
            slide,
            xd - 0.08,
            Y_MAIN + 0.06,
            label_w,
            label_h,
            f"{d:g} days",
            size=7.5,
            align=PP_ALIGN.LEFT,
            rotation=LABEL_ROTATION,
        )

    # Divert arms
    for d0, yb in zip(ARM_START_DAYS, ARM_YS):
        xs, xe = day_x(d0), day_x(d0 + ARM_DURATION)
        add_vline(slide, xs, Y_MAIN + DOT_R + 0.012, yb, weight=LINE_THIN, dash="dash")
        add_hline(slide, xs, xe, yb, weight=LINE_MED)
        add_x_mark(slide, xs, yb)
        add_dot(slide, xe, yb)

    # Bottom legend
    ly = 3.55
    add_dot(slide, 0.22, ly + 0.06, r=0.032)
    add_text(slide, 0.32, ly - 0.02, 1.05, 0.18, "fix & stain", size=7, align=PP_ALIGN.LEFT, color=GRAY)

    add_text(slide, 1.40, ly - 0.02, 1.35, 0.18,
             "CA  CHIR + Activin A", size=7, align=PP_ALIGN.LEFT, color=GRAY)

    add_text(slide, 2.85, ly - 0.02, 0.70, 0.18,
             "BMP4", size=7, bold=True, align=PP_ALIGN.LEFT, color=GRAY)

    add_x_mark(slide, 3.65, ly + 0.06, size=0.060)
    add_text(
        slide, 3.77, ly - 0.08, 3.7, 0.40,
        "Ecto  d0–2 SB+LDN    "
        "Meso  d1 CHIR+Activin A+FGF; d2 BMP+SB+FGF    "
        "Endo  FGF+Activin A",
        size=7, align=PP_ALIGN.LEFT, color=GRAY,
    )

    prs.save(str(path))
    print(f"Wrote {path}")


def build_svg(path: Path) -> None:
    W, H = int(SLIDE_W * 100), int(SLIDE_H * 100)

    def ix(v):
        return v * 100

    def iy(v):
        return v * 100

    y = iy(Y_MAIN)
    r = DOT_R * 100
    x0 = ix(day_x(0))
    x_ca = ix(day_x(DAY_CA_END))
    x_bmp4 = ix(day_x(DAY_BMP4_END))
    x_end = ix(day_x(DAY_MAX))

    def phase_bar(x1, x2, label, cls="t"):
        return [
            f'<text x="{(x1+x2)/2}" y="{y-24}" class="{cls}" text-anchor="middle" font-weight="700">{label}</text>',
            f'<line class="thin" x1="{x1}" y1="{y-10}" x2="{x2}" y2="{y-10}"/>',
            f'<line class="thin" x1="{x1}" y1="{y-10}" x2="{x1}" y2="{y-r-1}"/>',
            f'<line class="thin" x1="{x2}" y1="{y-10}" x2="{x2}" y2="{y-r-1}"/>',
        ]

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
        '<rect width="100%" height="100%" fill="white"/>',
        "<style>"
        "text{font-family:Arial,Helvetica,sans-serif;fill:#000}"
        ".b{font-size:13px;font-weight:700}.h{font-size:11px;font-weight:700}"
        ".t{font-size:10px}.s{font-size:8.5px;fill:#333}.d{font-size:8.5px}"
        "line{stroke:#000;stroke-linecap:square;fill:none}"
        ".thin{stroke-width:1.1}.med{stroke-width:1.45}.dash{stroke-dasharray:3.5 2.5}"
        "</style>",
        f'<text x="{ix(0.10)}" y="{iy(0.20)}" class="b">A</text>',
        f'<text x="{ix(0.34)}" y="{iy(0.20)}" class="h">{PANEL_TITLE}</text>',
        f'<line class="med" x1="{x0}" y1="{y-18}" x2="{x0}" y2="{y+18}"/>',
        f'<text x="{x0}" y="{y-36}" class="t" text-anchor="middle" font-weight="700">hPSCs</text>',
        f'<line class="med" x1="{x0}" y1="{y}" x2="{x_end}" y2="{y}"/>',
    ]
    parts += phase_bar(x0, x_ca, "CA", "t")
    parts += phase_bar(x_ca, x_bmp4, "BMP4", "t")
    parts += phase_bar(x_bmp4, x_end, "BMP + SCF + EGF", "h")

    for d in FIX_DAYS:
        xd = ix(day_x(d))
        parts.append(f'<circle cx="{xd}" cy="{y}" r="{r}" fill="#000"/>')
        # −45° rotation about a point just under the dot
        parts.append(
            f'<text x="{xd + 4}" y="{y + 14}" class="d" transform="rotate(-45 {xd + 4} {y + 14})">'
            f"{d:g} days</text>"
        )

    for d0, yb_in in zip(ARM_START_DAYS, ARM_YS):
        xs, xe, yb = ix(day_x(d0)), ix(day_x(d0 + ARM_DURATION)), iy(yb_in)
        s = X_MARK * 100 / 2
        parts += [
            f'<line class="thin dash" x1="{xs}" y1="{y+r+1}" x2="{xs}" y2="{yb}"/>',
            f'<line class="med" x1="{xs}" y1="{yb}" x2="{xe}" y2="{yb}"/>',
            f'<line class="med" x1="{xs-s}" y1="{yb-s}" x2="{xs+s}" y2="{yb+s}"/>',
            f'<line class="med" x1="{xs-s}" y1="{yb+s}" x2="{xs+s}" y2="{yb-s}"/>',
            f'<circle cx="{xe}" cy="{yb}" r="{r}" fill="#000"/>',
        ]

    ly = iy(3.62)
    parts += [
        f'<circle cx="{ix(0.22)}" cy="{ly}" r="3.5" fill="#000"/>',
        f'<text x="{ix(0.32)}" y="{ly+3}" class="s">fix &amp; stain</text>',
        f'<text x="{ix(1.40)}" y="{ly+3}" class="s">CA  CHIR + Activin A</text>',
        f'<text x="{ix(2.85)}" y="{ly+3}" class="s" font-weight="700">BMP4</text>',
        f'<line class="med" x1="{ix(3.65)-4}" y1="{ly-4}" x2="{ix(3.65)+4}" y2="{ly+4}"/>',
        f'<line class="med" x1="{ix(3.65)-4}" y1="{ly+4}" x2="{ix(3.65)+4}" y2="{ly-4}"/>',
        f'<text x="{ix(3.77)}" y="{ly+3}" class="s">'
        "Ecto  d0–2 SB+LDN &nbsp;&nbsp; "
        "Meso  d1 CHIR+Activin A+FGF; d2 BMP+SB+FGF &nbsp;&nbsp; "
        "Endo  FGF+Activin A</text>",
        "</svg>",
    ]
    path.write_text("\n".join(parts), encoding="utf-8")
    print(f"Wrote {path}")


def _font(size, bold=False):
    cands = (
        ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]
        if bold
        else ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    )
    for n in cands:
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    return ImageFont.load_default()


def build_png(path: Path, scale: int = 3) -> None:
    W, H = int(SLIDE_W * 100 * scale), int(SLIDE_H * 100 * scale)
    im = Image.new("RGBA", (W, H), (255, 255, 255, 255))
    dr = ImageDraw.Draw(im)

    fb = _font(13 * scale, bold=True)
    fh = _font(11 * scale, bold=True)
    ft = _font(10 * scale)
    fs = _font(8 * scale)
    fd = _font(8 * scale)

    def px(v):
        return v * 100 * scale

    def line(x1, y1, x2, y2, w=1.4):
        dr.line([(px(x1), px(y1)), (px(x2), px(y2))], fill="black", width=max(1, int(w * scale)))

    def dash_v(x, y1, y2, w=1.1):
        yy, y_end = px(y1), px(y2)
        step, gap = 6 * scale, 4 * scale
        while yy < y_end:
            y2s = min(yy + step, y_end)
            dr.line([(px(x), yy), (px(x), y2s)], fill="black", width=max(1, int(w * scale)))
            yy = y2s + gap

    def dot(x, y, r=DOT_R):
        cx, cy, rr = px(x), px(y), r * 100 * scale
        dr.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill="black")

    def xmark(x, y, size=X_MARK):
        s = size / 2
        line(x - s, y - s, x + s, y + s, w=1.4)
        line(x - s, y + s, x + s, y - s, w=1.4)

    def centered(text, x, y, fnt, fill="black"):
        tw = dr.textlength(text, font=fnt)
        dr.text((px(x) - tw / 2, px(y)), text, font=fnt, fill=fill)

    def label_45(text, x, y, fnt):
        """Draw text at −45° with origin near (x, y) under the timeline."""
        pad = 2 * scale
        tw = int(dr.textlength(text, font=fnt)) + pad * 2
        th = int(fnt.size * 1.5) + pad * 2
        tmp = Image.new("RGBA", (tw, th), (255, 255, 255, 0))
        td = ImageDraw.Draw(tmp)
        td.text((pad, pad), text, font=fnt, fill=(0, 0, 0, 255))
        rot = tmp.rotate(45, expand=True, resample=Image.BICUBIC)
        ox = int(px(x)) - pad
        oy = int(px(y)) - pad
        im.paste(rot, (ox, oy), rot)

    dr.text((px(0.10), px(0.04)), "A", font=fb, fill="black")
    dr.text((px(0.34), px(0.05)), PANEL_TITLE, font=fh, fill="black")

    x0 = day_x(0)
    x_ca = day_x(DAY_CA_END)
    x_bmp4 = day_x(DAY_BMP4_END)
    x_end = day_x(DAY_MAX)

    line(x0, Y_MAIN - 0.18, x0, Y_MAIN + 0.18, w=1.45)
    centered("hPSCs", x0, Y_MAIN - 0.52, ft)
    line(x0, Y_MAIN, x_end, Y_MAIN, w=1.45)

    def phase(x1, x2, label, fnt):
        centered(label, (x1 + x2) / 2, Y_MAIN - 0.34, fnt)
        line(x1, Y_MAIN - 0.10, x2, Y_MAIN - 0.10, w=1.1)
        line(x1, Y_MAIN - 0.10, x1, Y_MAIN - DOT_R - 0.01, w=1.1)
        line(x2, Y_MAIN - 0.10, x2, Y_MAIN - DOT_R - 0.01, w=1.1)

    phase(x0, x_ca, "CA", ft)
    phase(x_ca, x_bmp4, "BMP4", ft)
    phase(x_bmp4, x_end, "BMP + SCF + EGF", fh)

    for d in FIX_DAYS:
        xd = day_x(d)
        dot(xd, Y_MAIN)
        label_45(f"{d:g} days", xd + 0.02, Y_MAIN + 0.08, fd)

    for d0, yb in zip(ARM_START_DAYS, ARM_YS):
        xs, xe = day_x(d0), day_x(d0 + ARM_DURATION)
        dash_v(xs, Y_MAIN + DOT_R + 0.012, yb)
        line(xs, yb, xe, yb, w=1.4)
        xmark(xs, yb)
        dot(xe, yb)

    ly = 3.62
    dot(0.22, ly, r=0.032)
    dr.text((px(0.32), px(ly - 0.06)), "fix & stain", font=fs, fill="#333333")
    dr.text((px(1.40), px(ly - 0.06)), "CA  CHIR + Activin A", font=fs, fill="#333333")
    dr.text((px(2.85), px(ly - 0.06)), "BMP4", font=fs, fill="#333333")
    xmark(3.65, ly, size=0.060)
    dr.text(
        (px(3.77), px(ly - 0.06)),
        "Ecto  d0–2 SB+LDN     Meso  d1 CHIR+Activin A+FGF; d2 BMP+SB+FGF     Endo  FGF+Activin A",
        font=fs, fill="#333333",
    )

    im.convert("RGB").save(path, "PNG")
    print(f"Wrote {path}")


def main():
    build_pptx(OUT_DIR / "fig1a_pgc_induction.pptx")
    build_svg(OUT_DIR / "fig1a_pgc_induction.svg")
    build_png(OUT_DIR / "fig1a_pgc_induction.png")


if __name__ == "__main__":
    main()
