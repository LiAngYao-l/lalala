---
name: qpcr-analysis
description: Analyze qPCR / qRT-PCR data (delta-Ct, delta-delta-Ct, plate maps, bar/box plots). Use when the user mentions qpcr, Ct values, reference genes, or fold-change from plate exports.
---

# qPCR analysis

## When to use
Plate exports, ΔCt / ΔΔCt calculations, and related plots.

## Hard rules
- Put reusable code in `molecular/qpcr/`.
- Project-specific plate maps / one-off analyses → `projects/<name>/`.
- Keep gene / sample naming consistent; document reference gene(s).
- Never modify shared HeemskerkLab remotes.

## Workflow
1. Ingest plate export (CSV/xlsx) with explicit sample and gene columns.
2. Compute ΔCt (target − reference) and optional ΔΔCt vs control group.
3. Summarize by biological replicate; plot with `stats_figures/` helpers when useful.
4. Export a tidy results table for downstream stats.

## Agent checklist
- [ ] Reference gene(s) and control group are parameters, not hardwired
- [ ] Example command in `molecular/qpcr/README.md`
- [ ] No raw identifiable clinical metadata committed
