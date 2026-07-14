# Skill: imaging-batch

When the user asks to run or extend imaging analysis:

1. Prefer code under `imaging/{overview,segmentation,quantification,micropattern,video_tracking}/`.
2. Do not hardcode `/Users/liangyao/...`; use relative paths or config.
3. Never push to or modify HeemskerkLab remotes.
4. Write small CSV/figure outputs under a project `output/` (gitignored).
5. Document MATLAB toolboxes or Python deps in the module README.
