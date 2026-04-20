#!/usr/bin/env bash
# Ulak OS — @import chain validator (with cycle detection as of v2.1.4)
# Walks all .md files, finds @path/file.md references, verifies target exists,
# AND detects import cycles via DFS traversal (DY-01 closure).

set -euo pipefail

ERRORS=0
ROOT="${1:-.}"

echo "Validating @import chains under: $ROOT"

# -----------------------------------------------------------------------------
# Step 1 — File existence check (existing behavior preserved)
# -----------------------------------------------------------------------------

while IFS= read -r -d '' mdfile; do
  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    # Match lines that start with @ followed by a path ending in .md
    if [[ "$line" =~ ^@(.+\.md)[[:space:]]*$ ]]; then
      target="${BASH_REMATCH[1]}"
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

# -----------------------------------------------------------------------------
# Step 2 — Cycle detection (new in v2.1.4, DY-01)
# -----------------------------------------------------------------------------
# Build import graph in Python, run DFS, report cycles.
# Python is already required by validate-schemas.sh, so assume available.

if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
  echo "⚠️  Python not found; skipping cycle detection (file-existence check only)."
  echo "✓ All @import references valid (cycle detection skipped)."
  exit 0
fi

PYTHON=$(command -v python3 || command -v python)

CYCLE_OUTPUT=$("$PYTHON" - "$ROOT" <<'PYEOF'
import os
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
graph = {}

# Build adjacency list: file → set of @imported targets
for md in root.rglob("*.md"):
    rel = str(md.relative_to(root)).replace("\\", "/")
    graph.setdefault(rel, set())
    try:
        with open(md, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                m = re.match(r"^@(.+\.md)\s*$", line.rstrip())
                if m:
                    target = m.group(1)
                    graph[rel].add(target)
    except Exception:
        continue

# DFS cycle detection
WHITE, GRAY, BLACK = 0, 1, 2
color = {node: WHITE for node in graph}
parent = {}
cycles = []

def dfs(node, path):
    if node not in graph:
        return
    color[node] = GRAY
    for neighbor in graph[node]:
        if neighbor not in color:
            continue  # external/unknown
        if color[neighbor] == GRAY:
            # Cycle — reconstruct
            cycle_start = path.index(neighbor)
            cycle = path[cycle_start:] + [neighbor]
            cycles.append(cycle)
        elif color[neighbor] == WHITE:
            dfs(neighbor, path + [neighbor])
    color[node] = BLACK

for node in list(graph.keys()):
    if color[node] == WHITE:
        dfs(node, [node])

if cycles:
    print(f"CYCLE_COUNT:{len(cycles)}")
    seen = set()
    for cyc in cycles:
        key = tuple(sorted(cyc))
        if key in seen:
            continue
        seen.add(key)
        print("CYCLE: " + " → ".join(cyc))
    sys.exit(1)

print("NO_CYCLES")
sys.exit(0)
PYEOF
) && CYCLE_STATUS=0 || CYCLE_STATUS=$?

if [[ $CYCLE_STATUS -ne 0 ]]; then
  echo ""
  echo "❌ Import cycle(s) detected:"
  echo "$CYCLE_OUTPUT" | grep "^CYCLE" | sed 's/^/  /'
  echo ""
  echo "FAIL: @import graph contains cycle(s). Break the cycle before merging."
  exit 1
fi

echo "✓ All @import references valid."
echo "✓ No import cycles."
exit 0
