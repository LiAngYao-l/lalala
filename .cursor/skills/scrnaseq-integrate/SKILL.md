---
name: scrnaseq-integrate
description: Integrate and analyze single-cell RNA-seq datasets (Seurat/scanpy-style workflows). Use when the user asks for batch integration, Harmony/scVI/CCA, clustering, markers, or scRNA-seq QC plots.
---

# scRNA-seq integration & analysis

## When to use
Multi-dataset integration or downstream single-cell analysis.

## Hard rules
- Integration code → `scrnaseq/integration/`
- Downstream (clusters, markers, plots) → `scrnaseq/analysis/`
- Do **not** commit large `.h5ad` / `.rds` / raw matrices (gitignored). Keep paths in project notes or untracked `paths.local.md`.
- Record key parameters: batch key, dims, resolution, integration method.
- Never modify shared HeemskerkLab remotes.

## Standard pipeline
1. QC / filter per dataset (document thresholds).
2. Normalize + feature selection.
3. Integrate (`scrnaseq/integration/`) with explicit batch key.
4. Cluster + markers + UMAP (`scrnaseq/analysis/`).
5. Export small summary tables / plot scripts; leave big objects on disk.

## Agent checklist
- [ ] Batch column documented
- [ ] Seeds / versions noted when practical
- [ ] Project README lists data location (not committed blobs)
- [ ] Thin wrapper in `projects/<name>/` calling reusable modules
