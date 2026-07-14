# Boxplots (LiAng MATLAB style)

Canonical reference script:

- `makeCombinedFigures.m` — full SMAD/BMP combined figures including boxplots, ratio plots, ANOVA heatmaps, and matching time series.

Style summary (enforced by `.cursor/skills/figure-boxplot/SKILL.md`):

- Black unfilled `boxplot`, no default outlier symbols
- Jittered well-level scatter on top (`rng(0)`, size 60, black edge)
- Multi-experiment markers `o/s/^/d`
- Dual export: `*.png` + `*_noleg.png`
- Helpers: `../templates/cleanSubplot.m`, `figurePosition.m`, `savefigure.m`

```matlab
addpath(genpath('stats_figures/templates'));
% then run or adapt makeCombinedFigures.m with local data folders
```
