# Figure 1A — hPGCLC protocol schematic

Minimalist black-and-white experimental timeline for the **panel A** slot in Fig. 1
(*Progressive restriction of endoderm competency during hPGCLC specification*).

## Files

| File | Use |
|------|-----|
| `fig1a_pgc_induction.pptx` | **Best for editing** — native PowerPoint shapes & text |
| `fig1a_pgc_induction.svg` | Vector backup |
| `fig1a_pgc_induction.png` | Preview |
| `generate_fig1a.py` | Regenerates all three |

## Design (v2)

- Day-scaled axis **0 → 7.5 d**; vertical bar at day 0 = hPSCs / treatment start
- **CA** (CHIR + Activin A) for d0–2, then **BMP + SCF + EGF**
- **•** fix & stain at **1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5 d**
- Five divert **X** arms from **1.5–5.5 d**, each **2 d** long (last ends at 7.5 d)
- Legend: CA, Ecto / Meso / Endo recipes, fix & stain

## Edit in PowerPoint

Open the `.pptx` — every line, circle, X, and label is a separate shape.

## Regenerate after tweaks

```bash
python3 generate_fig1a.py
```

Key constants at top of the script: `DAY_CA_END`, `FIX_DAYS`, `ARM_START_DAYS`, `ARM_DURATION`.
