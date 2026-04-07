#!/usr/bin/env bash
# Ulak OS — @import chain validator
# Walks all .md files, finds @path/file.md references, verifies target exists.

set -euo pipefail

ERRORS=0
ROOT="${1:-.}"

echo "Validating @import chains under: $ROOT"

while IFS= read -r -d '' mdfile; do
  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    # Match lines that start with @ followed by a path ending in .md
    if [[ "$line" =~ ^@(.+\.md)[[:space:]]*$ ]]; then
      target="${BASH_REMATCH[1]}"
      # Resolve relative to repo root (where mdfile lives)
      target_path="$ROOT/$target"
      if [[ ! -f "$target_path" ]]; then
        echo "❌ $mdfile:$line_num → @$target (file not found)"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done < "$mdfile"
done < <(find "$ROOT" -name "*.md" -type f -print0)

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAIL: $ERRORS broken @import reference(s) found."
  exit 1
fi

echo "✓ All @import references valid."
exit 0
