# Figure 1A — PGC induction schematic

Minimalist black-and-white experimental timeline for a paper figure panel.

## Files

| File | Use |
|------|-----|
| `fig1a_pgc_induction.pptx` | **Best for editing** — native PowerPoint shapes & text boxes |
| `fig1a_pgc_induction.svg` | Vector; can Insert → Pictures into PPT / Illustrator |
| `fig1a_pgc_induction.png` | Quick preview / draft embedding |
| `generate_fig1a.py` | Re-generate all three after changing layout constants |

## How to edit in PowerPoint

1. Open `fig1a_pgc_induction.pptx`.
2. Every line, circle, X, and label is a separate shape or text box — select and move/restyle freely.
3. To change stroke weight: select a line → Shape Format → Shape Outline → Weight.
4. Copy the slide contents into your master figure deck when ready.

## Regenerating after script tweaks

```bash
python3 generate_fig1a.py
```

Geometry knobs live at the top of `generate_fig1a.py` (`X_BMP`, `DOTS_MAIN`, `BRANCH_YS`, etc.).
