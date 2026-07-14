---
name: video-tracking
description: Timelapse video preprocessing and cell tracking analysis. Use when the user asks for cell tracking, trajectories, live-cell movies, track QC, or motility/speed metrics from videos.
---

# Video & cell tracking

## When to use
Timelapse movies, tracking, trajectory QC, and motility metrics.

## Hard rules
- Code lives in `imaging/video_tracking/` (reusable) or `projects/<name>/` (experiment-specific).
- Do not commit raw movies (`.tif` stacks, `.nd2`, large `.avi`/`.mp4`) — gitignored.
- Export track tables (CSV) and small QC plots only.
- Never modify shared HeemskerkLab remotes.
- Paths must be portable (no `/Users/liangyao/...` hardcoding).

## Workflow
1. Preprocess (register / crop / stabilize) if needed.
2. Segment or detect objects per frame (reuse `imaging/segmentation/` when possible).
3. Link tracks; QC (track length, gaps, swaps).
4. Quantify (speed, persistence, displacement) → tidy CSV for `stats_figures/`.

## Agent checklist
- [ ] Input movie folder + output dir are arguments
- [ ] Track ID and time columns documented
- [ ] Example command in module or project README
