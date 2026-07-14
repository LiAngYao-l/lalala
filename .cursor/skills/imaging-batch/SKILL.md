---
name: imaging-batch
description: Run or extend microscopy image analysis — overview, segmentation, quantification, and micropattern workflows in this repo. Use when the user asks for imaging QC, masks, intensity/morphology tables, micropattern analysis, or batch processing of microscopy folders.
---

# Imaging batch workflow

## When to use
Imaging overview, segmentation, quantification, or micropattern scripts under `imaging/`.

## Hard rules
- Only edit this personal repo (`lalala`). Never commit/push to shared HeemskerkLab.
- No hardcoded Mac paths (`/Users/liangyao/...`). Use CLI args, relative paths, or a small config file.
- Do not commit raw `.tif` / `.nd2` / large stacks (gitignored). Write CSV summaries and small QC previews only.

## Preferred code locations
| Step | Folder |
|------|--------|
| Quick look / montage / channel check | `imaging/overview/` |
| Masks (nuclei/cells/colonies) | `imaging/segmentation/` |
| Measurements → tables | `imaging/quantification/` |
| Micropattern-specific (e.g. scatterMicropattern) | `imaging/micropattern/` |
| Project-specific wrappers | `projects/<name>/scripts/` |

## Standard pipeline
1. **Overview** — confirm channels, scale, FOV; optional montage.
2. **Segmentation** — produce masks; save next to results or under project `output/` (gitignored).
3. **Quantification** — export tidy CSV (one row per object/FOV) for `stats_figures/`.
4. **Document** — note MATLAB toolboxes or Python deps in the module/project README.

## Agent checklist
- [ ] Entry script accepts input folder / file list
- [ ] Outputs land in project `output/` or an explicit `--outdir`
- [ ] Example command added to README
- [ ] No lab-remote git operations
