# Figure templates

Shared MATLAB helpers used by LiAng publication figures (see `makeCombinedFigures.m`):

| File | Role |
|------|------|
| `cleanSubplot.m` | Axes font / tick / box styling (`fs` default 26) |
| `figurePosition.m` | Centered figure `Position` from `[width height]` |
| `savefigure.m` | Save current figure (creates folders; PNG @ 300 dpi default) |

```matlab
addpath(fullfile('stats_figures','templates'));
figure('Position', figurePosition([630 630]));
% ... plot ...
cleanSubplot(26);
savefigure(fullfile('output','my_boxplot.png'));
```

If the lab workspace already defines identically named functions, prefer the lab versions on the path; these copies exist so the personal `lalala` repo is self-contained on a home laptop.
