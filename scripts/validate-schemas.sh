#!/usr/bin/env bash
# Ulak OS — JSON/TOML schema validator
# Validates all known config files for parse errors.

set -euo pipefail

ERRORS=0

# Check Python is available
if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
  echo "❌ python required for schema validation but not found."
  exit 1
fi
PYTHON=$(command -v python3 || command -v python)

# Python version check (tomllib needs 3.11+)
if ! "$PYTHON" -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" 2>/dev/null; then
  PYTHON_VERSION=$("$PYTHON" -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
  echo "❌ Python 3.11+ required for tomllib. Found: $PYTHON_VERSION"
  echo "   TOML validation will be skipped. Install Python 3.11 or newer for full validation."
  SKIP_TOML=1
else
  SKIP_TOML=0
fi

# JSON files to validate
JSON_FILES=(
  ".claude/settings.json"
  ".mcp.json"
)

for f in "${JSON_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    if "$PYTHON" -m json.tool "$f" >/dev/null 2>&1; then
      echo "✓ $f"
    else
      echo "❌ $f (invalid JSON)"
      "$PYTHON" -m json.tool "$f" 2>&1 | head -3 | sed 's/^/    /'
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "⚠️  $f not found (skipping)"
  fi
done

# TOML files to validate (only if Python 3.11+ available)
if [[ $SKIP_TOML -eq 0 ]]; then
  TOML_FILES=()
  if [[ -d ".gemini/commands" ]]; then
    while IFS= read -r -d '' f; do
      TOML_FILES+=("$f")
    done < <(find .gemini/commands -name "*.toml" -type f -print0)
  fi

  for f in "${TOML_FILES[@]}"; do
    if "$PYTHON" -c "import sys, tomllib; tomllib.load(open(sys.argv[1], 'rb'))" "$f" 2>/dev/null; then
      echo "✓ $f"
    else
      echo "❌ $f (invalid TOML)"
      "$PYTHON" -c "import sys, tomllib; tomllib.load(open(sys.argv[1], 'rb'))" "$f" 2>&1 | tail -3 | sed 's/^/    /'
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "FAIL: $ERRORS schema error(s) found."
  exit 1
fi

echo ""
echo "✓ All schemas valid."
exit 0
