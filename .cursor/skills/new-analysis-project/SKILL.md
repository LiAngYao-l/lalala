---
name: new-analysis-project
description: Start a new experimental or paper project folder with the repo template and wire it to reusable modules. Use when the user starts a new experiment, paper figure set, or wants project scaffolding.
---

# New analysis project

## When to use
User starts a new experiment, manuscript figure set, or wants a clean project folder.

## Hard rules
- Copy from `projects/_template/` → `projects/<YYYY>-<short-name>/`.
- Reusable logic stays in `imaging/`, `scrnaseq/`, `molecular/`, `stats_figures/` — project scripts are thin wrappers.
- Machine-specific paths go in untracked `paths.local.md` (do not commit).
- Never modify shared HeemskerkLab remotes.

## Steps
1. Create `projects/<name>/` from the template.
2. Fill README: scientific question, entry scripts, status checkboxes.
3. Add `scripts/` that call existing skills/modules (imaging-batch, scrnaseq-integrate, etc.).
4. Create gitignored `output/` for results.
5. Optionally open a branch `project/<name>` for longer work.

## Naming
Prefer `2026-micropattern-xyz`, `2026-scrna-integration`, `paper-xxx-figures`.
