# lalala agent rules

- Target repo: personal `LiAngYao-l/lalala` only.
- Never commit, push, or otherwise modify shared HeemskerkLab remotes.
- Prefer organizing reusable code under `imaging/`, `scrnaseq/`, `molecular/`, `stats_figures/`; project-specific under `projects/`.
- Do not commit large binary data (tif, h5ad, fastq, etc.).
- Prefer Chinese for user-facing docs when the user writes in Chinese; keep code comments bilingual or English as appropriate.
- When Mac-only paths are needed, document them in untracked local files; make scripts path-configurable.
- Project skills live in `.cursor/skills/*/SKILL.md` (not only under `skills/`). When the user asks to "save this as a skill" or "固化成 skill", create/update a proper SKILL.md there and keep `skills/README.md` in sync.
- Existing skills: imaging-batch, video-tracking, scrnaseq-integrate, figure-boxplot, qpcr-analysis, new-analysis-project.
