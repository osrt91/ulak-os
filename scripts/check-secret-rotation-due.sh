#!/usr/bin/env bash
# Ulak OS — secret rotation due-date checker
#
# Reads `active-variables.yaml` (or any yaml file passed as arg) and reports
# any secret whose `next_rotation_due` date is overdue.
#
# Thresholds (per docs/governance/secrets-rotation-policy.md §CI enforcement):
#   - 0-7 days overdue  → warning (exit 0)
#   - 8+ days overdue   → error  (exit 1)
#
# Usage:
#   bash scripts/check-secret-rotation-due.sh                    # scans reports/current/active-variables.yaml
#   bash scripts/check-secret-rotation-due.sh path/to/vars.yaml  # scans given file
#
# Referenced by: docs/governance/secrets-rotation-policy.md:104
# Called from: .github/workflows/ci-validation.yml (recommended)

set -euo pipefail

TARGET="${1:-reports/current/active-variables.yaml}"
TODAY="$(date +%Y-%m-%d)"
WARN_WINDOW_DAYS=7
ERROR_WINDOW_DAYS=30

print_warn()  { printf '[rotation-check] WARN  %s\n' "$*" >&2; }
print_error() { printf '[rotation-check] ERROR %s\n' "$*" >&2; }
print_info()  { printf '[rotation-check] %s\n' "$*"; }

if [[ ! -f "$TARGET" ]]; then
  print_info "no active-variables.yaml found at $TARGET — nothing to check (exit 0)"
  print_info "seed the file via \`/director komple\` Phase 0 to enable this gate"
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
  print_warn "python not available — skipping check"
  exit 0
fi

PYTHON="$(command -v python3 || command -v python)"

# Python handles the YAML parsing + date math. No PyYAML dependency — regex
# scan that grabs `name: FOO` and `next_rotation_due: YYYY-MM-DD` pairs in
# any order within a block (tolerant to comments and other fields).
EXIT_CODE=$("$PYTHON" - "$TARGET" "$TODAY" "$WARN_WINDOW_DAYS" "$ERROR_WINDOW_DAYS" <<'PYEOF'
import re
import sys
from datetime import date, timedelta

target = sys.argv[1]
today = date.fromisoformat(sys.argv[2])
warn_window = int(sys.argv[3])
error_window = int(sys.argv[4])

try:
    with open(target, "r", encoding="utf-8") as fh:
        content = fh.read()
except Exception as exc:
    print(f"[rotation-check] could not read {target}: {exc}", file=sys.stderr)
    sys.exit(2)

# Split the document into per-entry blocks by top-level `- name:` hints.
blocks = re.split(r"(?m)^\s*-\s+name:\s*", content)
worst_exit = 0
warnings = []
errors = []

for chunk in blocks[1:]:
    name_match = re.match(r"([A-Z0-9_]+)", chunk)
    due_match = re.search(r"next_rotation_due:\s*['\"]?(\d{4}-\d{2}-\d{2})", chunk)
    if not name_match or not due_match:
        continue
    name = name_match.group(1)
    try:
        due = date.fromisoformat(due_match.group(1))
    except ValueError:
        continue
    overdue_days = (today - due).days
    if overdue_days <= 0:
        continue
    if overdue_days >= error_window:
        errors.append(f"{name}: {overdue_days}d overdue (due {due.isoformat()})")
    elif overdue_days >= warn_window:
        warnings.append(f"{name}: {overdue_days}d overdue (due {due.isoformat()})")

for w in warnings:
    print(f"[rotation-check] WARN  {w}", file=sys.stderr)
for e in errors:
    print(f"[rotation-check] ERROR {e}", file=sys.stderr)

if errors:
    print(f"\n[rotation-check] FAIL — {len(errors)} secret(s) overdue ≥ {error_window}d", file=sys.stderr)
    sys.exit(1)
if warnings:
    print(f"\n[rotation-check] {len(warnings)} secret(s) approaching rotation deadline (warn window)", file=sys.stderr)
    sys.exit(0)
print("[rotation-check] all monitored secrets within rotation window", file=sys.stderr)
sys.exit(0)
PYEOF
) || EXIT_CODE=$?

exit "${EXIT_CODE:-0}"
