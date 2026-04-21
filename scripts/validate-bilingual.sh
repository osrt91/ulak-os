#!/usr/bin/env bash
# validate-bilingual.sh
# Enforces docs/governance/localization-governance.md bilingual policy.
# Exit code 0 = PASS, 1 = FAIL. Prints missing pairs and malformed frontmatter.

set -euo pipefail

# Resolve repo root (script lives at <root>/scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

FAIL_COUNT=0
WARN_COUNT=0
MISSING=()
WARNINGS=()

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  MISSING+=("$1")
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  WARNINGS+=("$1")
}

# --- Rule 1: Root bilingual pairs ---
ROOT_PAIRS=(
  "README.md:README.en.md"
  "AGENTS.md:AGENTS.en.md"
  "CLAUDE.md:CLAUDE.en.md"
  "GEMINI.md:GEMINI.en.md"
)

for pair in "${ROOT_PAIRS[@]}"; do
  tr_file="${pair%%:*}"
  en_file="${pair##*:}"
  if [ -f "$tr_file" ] && [ ! -f "$en_file" ]; then
    fail "Rule1: $tr_file present but $en_file missing"
  fi
  if [ -f "$en_file" ] && [ ! -f "$tr_file" ]; then
    fail "Rule1: $en_file present but $tr_file missing"
  fi
done

# --- Rule 1b: User manual TR/EN parallel structure ---
# TR and EN filenames differ by convention (01-giris.md vs 01-introduction.md).
# We enforce: same count + same leading numeric prefix (01-, 02-, ...) across both dirs.
TR_MANUAL="docs/user-manual/tr"
EN_MANUAL="docs/user-manual/en"

if [ -d "$TR_MANUAL" ] && [ -d "$EN_MANUAL" ]; then
  # Only numeric-prefixed manual pages participate. README.md and other non-numbered
  # files are per-directory table-of-contents and are checked separately (they should
  # exist in both, but content/name may differ).
  tr_prefixes=$(ls "$TR_MANUAL"/*.md 2>/dev/null | sed -nE 's|.*/([0-9]+)-.*|\1|p' | sort -u || true)
  en_prefixes=$(ls "$EN_MANUAL"/*.md 2>/dev/null | sed -nE 's|.*/([0-9]+)-.*|\1|p' | sort -u || true)

  for p in $tr_prefixes; do
    if ! echo "$en_prefixes" | grep -q "^$p$"; then
      fail "Rule1b: TR manual has prefix $p but EN manual does not"
    fi
  done
  for p in $en_prefixes; do
    if ! echo "$tr_prefixes" | grep -q "^$p$"; then
      fail "Rule1b: EN manual has prefix $p but TR manual does not"
    fi
  done

  # Check README.md exists in both if exists in either
  if [ -f "$TR_MANUAL/README.md" ] && [ ! -f "$EN_MANUAL/README.md" ]; then
    fail "Rule1b: $TR_MANUAL/README.md present but $EN_MANUAL/README.md missing"
  fi
  if [ -f "$EN_MANUAL/README.md" ] && [ ! -f "$TR_MANUAL/README.md" ]; then
    fail "Rule1b: $EN_MANUAL/README.md present but $TR_MANUAL/README.md missing"
  fi
fi

# --- Rule 1c: Runbooks need TR/EN pair OR lang: frontmatter marker ---
RUNBOOK_DIR="docs/runbooks"
if [ -d "$RUNBOOK_DIR" ]; then
  for f in "$RUNBOOK_DIR"/*.md; do
    [ -e "$f" ] || continue
    base=$(basename "$f" .md)
    # Skip *.en.md files; we only anchor on the TR candidate
    if [[ "$base" == *.en ]]; then continue; fi
    en_variant="$RUNBOOK_DIR/$base.en.md"
    # Accept if a .en.md pair exists, OR if the file has a `lang:` frontmatter line
    has_lang=$(head -20 "$f" | grep -E '^lang:' || true)
    if [ ! -f "$en_variant" ] && [ -z "$has_lang" ]; then
      warn "Rule1c: $f has no EN pair and no 'lang:' frontmatter marker"
    fi
  done
fi

# --- Rule 4: Slash commands must have non-empty description frontmatter ---
CMD_DIR=".claude/commands"
if [ -d "$CMD_DIR" ]; then
  for f in "$CMD_DIR"/*.md; do
    [ -e "$f" ] || continue
    desc=$(head -20 "$f" | grep -E '^description:' | head -1 || true)
    if [ -z "$desc" ]; then
      fail "Rule4: $f missing 'description:' frontmatter"
    fi
    # description_en is a soft expectation (warn only)
    desc_en=$(head -20 "$f" | grep -E '^description_en:' | head -1 || true)
    if [ -z "$desc_en" ]; then
      warn "Rule4: $f missing optional 'description_en:' frontmatter (recommended)"
    fi
  done
fi

# --- Report ---
echo "=================================="
echo "  validate-bilingual.sh report"
echo "=================================="
echo "Failures: $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "--- MISSING / BROKEN (hard fail) ---"
  for m in "${MISSING[@]}"; do echo "  - $m"; done
  echo ""
fi

if [ "$WARN_COUNT" -gt 0 ]; then
  echo "--- WARNINGS (soft) ---"
  for w in "${WARNINGS[@]}"; do echo "  - $w"; done
  echo ""
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
fi

echo "RESULT: PASS"
exit 0
