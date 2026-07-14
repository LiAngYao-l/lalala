#!/usr/bin/env bash
# Copy personal analysis scripts from a local HeemskerkLab working copy
# into this personal repo (lalala). READ-ONLY toward the lab folder:
# never runs git commit/push inside the source tree.
#
# Usage (on the medical-school Mac):
#   bash scripts/migrate_from_lab_mac.sh "/Users/liangyao/Documents/Data/00 HeemskerkLab"
#
set -euo pipefail

SRC="${1:-/Users/liangyao/Documents/Data/00 HeemskerkLab}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT="$ROOT/MIGRATION_REPORT.md"
STAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source directory not found: $SRC" >&2
  echo "Run this script on the Mac that has the local lab workspace." >&2
  exit 1
fi

# Refuse to operate if we somehow are inside a path that looks like we might
# write to a remote named HeemskerkLab — this script only copies OUT.
if [[ "$(basename "$ROOT")" == "HeemskerkLab" ]]; then
  echo "ERROR: refuse to treat HeemskerkLab as the destination repo." >&2
  exit 1
fi

mkdir -p \
  "$ROOT/imaging/overview" \
  "$ROOT/imaging/segmentation" \
  "$ROOT/imaging/quantification" \
  "$ROOT/imaging/micropattern" \
  "$ROOT/imaging/video_tracking" \
  "$ROOT/scrnaseq/integration" \
  "$ROOT/scrnaseq/analysis" \
  "$ROOT/molecular/qpcr" \
  "$ROOT/stats_figures/boxplots" \
  "$ROOT/projects/imported_unclassified"

copied=0
skipped=0

copy_one() {
  local from="$1"
  local to_dir="$2"
  local base
  base="$(basename "$from")"
  mkdir -p "$to_dir"
  if [[ -e "$to_dir/$base" ]]; then
    # keep both if contents differ
    if ! cmp -s "$from" "$to_dir/$base" 2>/dev/null; then
      local dest="$to_dir/${base%.*}_from_lab.${base##*.}"
      cp -n "$from" "$dest" 2>/dev/null || cp "$from" "$dest"
      echo "| \`$from\` | \`$dest\` | renamed (collision) |" >>"$REPORT"
      copied=$((copied + 1))
    else
      echo "| \`$from\` | (identical exists) | skipped |" >>"$REPORT"
      skipped=$((skipped + 1))
    fi
  else
    cp "$from" "$to_dir/$base"
    echo "| \`$from\` | \`$to_dir/$base\` | copied |" >>"$REPORT"
    copied=$((copied + 1))
  fi
}

classify() {
  local f="$1"
  local rel lower
  rel="${f#$SRC/}"
  lower="$(echo "$rel" | tr '[:upper:]' '[:lower:]')"

  case "$lower" in
    *micropattern*|*/scattermicropattern*)
      echo "$ROOT/imaging/micropattern" ;;
    *segment*)
      echo "$ROOT/imaging/segmentation" ;;
    *quantif*|*measure*|*intensity*)
      echo "$ROOT/imaging/quantification" ;;
    *track*|*video*|*timelapse*|*livecell*)
      echo "$ROOT/imaging/video_tracking" ;;
    *overview*|*montage*|*inspect*|*preview*)
      echo "$ROOT/imaging/overview" ;;
    *scrna*|*seurat*|*scanpy*|*integration*|*harmony*|*scvi*)
      # prefer integration vs analysis by keyword
      if echo "$lower" | grep -Eq 'integrat|harmony|scvi|merge'; then
        echo "$ROOT/scrnaseq/integration"
      else
        echo "$ROOT/scrnaseq/analysis"
      fi
      ;;
    *qpcr*|*q-pcr*|*deltact*|*delta_ct*|*qrt*pcr*|*rt-pcr*|*rtpcr*)
      echo "$ROOT/molecular/qpcr" ;;
    *boxplot*|*ggplot*|*stats*|*wilcox*|*anova*|*figure*)
      echo "$ROOT/stats_figures/boxplots" ;;
    *)
      echo "$ROOT/projects/imported_unclassified" ;;
  esac
}

{
  echo "# Migration report"
  echo
  echo "- Generated: \`$STAMP\`"
  echo "- Source (read-only copy): \`$SRC\`"
  echo "- Destination: \`$ROOT\`"
  echo "- Lab remote: **not touched**"
  echo
  echo "| Source file | Destination | Action |"
  echo "|-------------|-------------|--------|"
} >"$REPORT"

# Collect candidate scripts / notebooks only (not giant data)
# Extend extensions here if needed.
while IFS= read -r -d '' f; do
  # skip common junk / deps / git
  case "$f" in
    */.git/*|*/.git) continue ;;
    */slprj/*|*/.DS_Store) continue ;;
    */node_modules/*|*/.venv/*|*/venv/*) continue ;;
  esac
  dest="$(classify "$f")"
  copy_one "$f" "$dest"
done < <(find "$SRC" -type f \( \
    -name '*.m' -o -name '*.mlx' -o -name '*.py' -o -name '*.ipynb' \
    -o -name '*.R' -o -name '*.r' -o -name '*.Rmd' -o -name '*.jl' \
    -o -name '*.sh' -o -name '*.ijm' -o -name '*.groovy' \
  \) -print0 2>/dev/null)

{
  echo
  echo "## Summary"
  echo
  echo "- Copied: **$copied**"
  echo "- Skipped: **$skipped**"
  echo
  echo "## Next steps"
  echo
  echo "1. Review \`projects/imported_unclassified/\` and move files into the right modules."
  echo "2. Delete anything that is lab-shared infrastructure you do not own/need."
  echo "3. Commit and push **only** to \`LiAngYao-l/lalala\`."
  echo "4. Tell Cursor Cloud to tidy READMEs and remove hardcoded Mac paths."
} >>"$REPORT"

echo "Done. Copied=$copied Skipped=$skipped"
echo "Report: $REPORT"
echo "Remember: do NOT push to the shared HeemskerkLab remote."
