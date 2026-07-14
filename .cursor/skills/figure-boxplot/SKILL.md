---
name: figure-boxplot
description: Build MATLAB publication boxplots and related stats figures in LiAng's makeCombinedFigures style (black unfilled boxes, jittered well-level points, dual legend/noleg export). Use when the user asks for boxplots, ratio plots, ANOVA/Tukey figures, SMAD/BMP combined figures, or publication-style stats plots.
---

# Figure / boxplot skill (LiAng style)

Canonical reference: `stats_figures/boxplots/makeCombinedFigures.m`

## When to use
Boxplots, ratio boxplots, multi-experiment combined plots, ANOVA heatmaps, and matching time-series style from the SMAD/BMP figure pipeline.

## Hard rules — visual style (from makeCombinedFigures.m)

### Boxplot
- Use MATLAB `boxplot` (not ggplot / seaborn unless the user explicitly asks).
- Black outlines, **no fill**: after `boxplot`, run:
  - `set(findobj(gca,'Type','line'),  'Color','k','LineWidth',2)`
  - `set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',2,'FaceColor','none')`
- `'Symbol',''` (suppress default outlier marks — points come from scatter).
- `'Widths', 0.5`.
- Overlay **jittered individual points** (well / position replicates):
  - `rng(0)` for reproducible jitter
  - `xjit = k + 0.15*(rand(size(pts))-0.5)`
  - `scatter(..., 60, color, 'filled', 'MarkerEdgeColor','k', 'LineWidth',0.5)`
- Multi-experiment marker shapes: `{'o','s','^','d'}` keyed by experiment date/id.
- For ratio plots: `yline(1,'--k','LineWidth',1)`.
- Figure size ~ `figurePosition([630 630])`; axes inset `Position = [0.22 0.22 0.60 0.60]`.
- `xtickangle(45)`; for unitless ratios, sparse y tick labels (show `0` and `1`, blank middles) when matching the reference.
- Always call `cleanSubplot(fs)` with `fs = 26` (legend font `lfs = 18`).

### Export
- Save **two** PNGs when a legend exists: with legend, then hide legend and save `*_noleg.png`.
- Use `savefigure(...)` from `stats_figures/templates/`.
- Do not commit large PNG/PDF outputs unless asked; write under a local `figures_combined/` or project `output/` (gitignored).

### Statistics (default with these figures)
- Prefer **well/position-level** values as the statistical unit (not pooled cell noise).
- `anova1` + Tukey `multcompare` when comparing ≥3 groups.
- Optional Tukey p heatmap: `imagesc(-log10(p))` with `*/**/***/ns` text (as in the reference).

### Time series (same visual language)
- Line width `3`; colors from `lines(7)` by ligand identity; `ctrl` = black.
- `+ActA` → dashed; `+GDF11` → dotted; single gray dummy legend entries for modifiers.
- Error band = **std across positions (wells)**, `FaceAlpha=0.2`, no edge.
- Shared square axes via `figurePosition([560 560])` / `axis square` as in reference.

## Required helpers (reuse, do not reinvent)

Always put these on the MATLAB path (or `addpath` them):

| Function | Path |
|----------|------|
| `cleanSubplot` | `stats_figures/templates/cleanSubplot.m` |
| `figurePosition` | `stats_figures/templates/figurePosition.m` |
| `savefigure` | `stats_figures/templates/savefigure.m` |

New plotting scripts should call these three rather than ad-hoc font/`print` settings.

## Workflow
1. Prefer adapting patterns from `stats_figures/boxplots/makeCombinedFigures.m` over inventing a new style.
2. Put reusable plot helpers in `stats_figures/boxplots/`; shared theme helpers in `stats_figures/templates/`.
3. Put experiment-specific drivers under `projects/<name>/`.
4. Keep paths portable (no `/Users/liangyao/...` hardcoding).
5. Never modify shared HeemskerkLab remotes.

## Expected deliverable
- MATLAB script that produces the boxplot(+jitter) in this style
- Dual PNG export when legends are used
- Printed ANOVA/Tukey summary when group comparisons are requested
- README note listing any extra dependencies beyond the three templates
