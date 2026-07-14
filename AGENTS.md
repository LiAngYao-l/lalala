# AGENTS.md

## Cursor Cloud specific instructions

This repository is **data-only**. It contains no application, build system, source
code, tests, lint config, or dependency manifests. The full contents are:

- `kinesin1_Results.csv`, `kinesin3_Results.csv` — ImageJ/Fiji measurement tables
  (columns: `Area, Mean, Min, Max, Angle, IntDen, RawIntDen, Length`), each 21 data rows.
- `README.md` — placeholder.

Implications for future agents:

- There is nothing to install, build, lint, or serve. Do not go looking for a
  `package.json`, `requirements.txt`, or a dev server — none exist.
- The VM already has Python 3.12 and Node 22 available. The CSVs load with the
  Python stdlib, e.g.:
  `python3 -c "import csv; print(len(list(csv.DictReader(open('kinesin1_Results.csv')))))"`
- If asked to add analysis/tooling, introduce the relevant dependency manifest
  yourself; the repo does not currently declare one.
