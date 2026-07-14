# Skill: scrnaseq-integrate

When integrating scRNA-seq datasets:

1. Put integration code in `scrnaseq/integration/`, downstream in `scrnaseq/analysis/`.
2. Do not commit large `.h5ad` / `.rds`; keep pointers in project README.
3. Record key parameters (dims, batch key, resolution) in the project notes.
4. Never modify shared lab repositories.
