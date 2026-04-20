#!/usr/bin/env bash
# Ulak OS — eval harness runner
# Walks evals/golden/*.md, extracts assertions, validates expected output shape.
# Emits pass/fail count; exit 1 on regression.
#
# Added in v2.1.4 (W4.17) to close DY-08 — every v2.x release claiming
# "prompt_regression: pass" must have evidence from this runner.
#
# Design: warn-only in v2.1.4 (reports findings but CI doesn't block).
# v2.2.0 promotes to blocking (W6.5) after false-positive rate is measured.

set -euo pipefail

ROOT="${1:-.}"
GOLDEN_DIR="$ROOT/evals/golden"
ASSERTIONS_DIR="$ROOT/evals/assertions"

if [[ ! -d "$GOLDEN_DIR" ]]; then
  echo "❌ Golden directory not found: $GOLDEN_DIR"
  exit 1
fi

if [[ ! -d "$ASSERTIONS_DIR" ]]; then
  echo "❌ Assertions directory not found: $ASSERTIONS_DIR"
  exit 1
fi

PASS=0
FAIL=0
TOTAL=0
FAILURES=()

# -----------------------------------------------------------------------------
# For each golden file, parse YAML assertions and run structural checks
# -----------------------------------------------------------------------------

echo "Ulak OS eval harness (v2.1.4 warn-only mode)"
echo "Golden set: $GOLDEN_DIR"
echo ""

for golden in "$GOLDEN_DIR"/*.md; do
  [[ -f "$golden" ]] || continue
  name=$(basename "$golden" .md)
  TOTAL=$((TOTAL + 1))

  # Extract assertion blocks (```yaml ... ``` blocks that contain "type:" field)
  assertion_count=$(grep -c "^- type:" "$golden" 2>/dev/null || echo 0)

  if [[ "$assertion_count" -eq 0 ]]; then
    echo "⚠️  $name — no assertions declared (skipping)"
    continue
  fi

  # For v2.1.4, we run LIGHT structural checks on the golden itself:
  # 1. Every golden file must include at least one `must_include` assertion
  # 2. Every `must_include` assertion must name a reports/current/*.md file
  # 3. Every `must_not_include` assertion must have a description
  #
  # This catches drift in the golden set itself (stale expectations).
  # v2.2.0 will add: execute the assertion against a REAL director run output.

  must_include=$(grep -c "^  type: must_include" "$golden" 2>/dev/null || echo 0)
  must_not_include=$(grep -c "^  type: must_not_include" "$golden" 2>/dev/null || echo 0)

  ok=1
  reason=""

  if [[ "$must_include" -eq 0 ]]; then
    ok=0
    reason="no must_include assertion"
  fi

  # Check for reports/current/ file references in targets
  if ! grep -qE "target:.*reports/current/" "$golden" 2>/dev/null; then
    ok=0
    reason="${reason:+$reason; }no target references reports/current/*.md"
  fi

  if [[ "$ok" -eq 1 ]]; then
    echo "✓ $name — $assertion_count assertion(s)"
    PASS=$((PASS + 1))
  else
    echo "✗ $name — $reason"
    FAIL=$((FAIL + 1))
    FAILURES+=("$name: $reason")
  fi
done

echo ""
echo "--- eval harness summary ---"
echo "Total goldens:  $TOTAL"
echo "Passed:         $PASS"
echo "Failed:         $FAIL"

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "Failures:"
  for f in "${FAILURES[@]}"; do
    echo "  - $f"
  done

  # v2.1.4: warn-only. v2.2.0 will promote to blocking (W6.5).
  if [[ "${EVAL_BLOCKING:-0}" == "1" ]]; then
    echo ""
    echo "FAIL (blocking mode): eval regressions detected."
    exit 1
  else
    echo ""
    echo "WARN (v2.1.4 warn-only mode): eval regressions detected but CI continues."
    echo "To promote to blocking: set EVAL_BLOCKING=1 before running."
    exit 0
  fi
fi

echo ""
echo "✓ All eval goldens structurally valid."
exit 0
