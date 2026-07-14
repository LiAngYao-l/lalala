---
name: figure-boxplot
description: Build reusable statistical plots (box/violin/jitter) and related tests for experimental tables. Use when the user asks for boxplots, ggplot figures, group comparisons, or publication-style stats figures.
---

# Figure / boxplot skill

## When to use
Stats + publication figures from tidy tables (CSV), especially box / violin / jitter plots.

## Hard rules
- Reuse helpers in `stats_figures/boxplots/` and themes in `stats_figures/templates/`.
- Prefer tidy input: columns like `group`, `value`, optional `replicate`, `batch`.
- State the statistical test next to the plotting code (Wilcoxon / t-test / ANOVA / mixed model).
- Commit scripts and tiny example CSVs; avoid committing large PDF/PNG unless asked.
- Never modify shared HeemskerkLab remotes.

## Workflow
1. Confirm grouping variables and units with the user (or infer from column names).
2. Put reusable plotting functions in `stats_figures/boxplots/`.
3. Put shared theme/palette in `stats_figures/templates/`.
4. Put one-off paper figures under `projects/<name>/`.
5. Save figures to project `output/figures/` (gitignored) by default.

## Expected deliverable
- A script or notebook that runs from a CSV path argument
- Clear group aesthetics + optional significance annotations
- Short README note: packages (`ggplot2`, `ggpubr`, `seaborn`, etc.) and example command
