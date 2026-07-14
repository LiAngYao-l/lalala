# Imaging analysis

MATLAB / ImageJ / Python tools for microscopy.

| Subfolder | Use |
|-----------|-----|
| `overview/` | Quick look, montages, QC previews |
| `segmentation/` | Nuclei / cell / colony masks |
| `quantification/` | Intensity, area, morphology tables |
| `micropattern/` | Micropattern-specific (e.g. `scatterMicropattern.m`) |
| `video_tracking/` | Timelapse, cell tracking |

**Convention:** scripts should accept an input folder argument (or a small config), not a hardcoded `/Users/liangyao/...` path.
