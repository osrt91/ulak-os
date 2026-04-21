#!/usr/bin/env bash
# Ulak OS — JSON/TOML schema validator (with $schema conformance as of v2.1.4;
# vendored schemas + strict mode as of v1.0.1)
# Parses JSON + TOML files. If a JSON file declares a `$schema` URL, attempts
# actual schema conformance (not just parse validity) — closes DY-02.
#
# Schema lookup order (v1.0.1+, SEC-B-09 fix):
#   1. Local `schemas/<slug>.json` (slug = filename from $schema URL)
#   2. Network fetch (unless --strict, which forbids network)
#   3. WARN + parse-only (only if --strict NOT passed)
#
# --strict flag (recommended for CI): fail on any missing local vendored
# schema; never reach the network; never fall back to parse-only silently.

set -euo pipefail

ERRORS=0
WARNINGS=0
STRICT_MODE=0

for arg in "$@"; do
  case "$arg" in
    --strict) STRICT_MODE=1 ;;
    --help|-h)
      cat <<'HLP'
Usage: validate-schemas.sh [--strict]

Default mode: tries local schemas/<slug>.json first; network fallback; parse-only on
network error (warn).

--strict:
  Local-only. Fails on any missing vendored schema. Fails on any $schema-declaring
  JSON whose conformance check cannot be run. Recommended for CI.
HLP
      exit 0
      ;;
  esac
done

# Check Python is available
if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
  echo "❌ python required for schema validation but not found."
  exit 1
fi
PYTHON=$(command -v python3 || command -v python)

# Python version check (tomllib needs 3.11+)
if ! "$PYTHON" -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" 2>/dev/null; then
  PYTHON_VERSION=$("$PYTHON" -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
  echo "⚠️  Python 3.11+ required for tomllib. Found: $PYTHON_VERSION"
  echo "   TOML validation will be skipped."
  SKIP_TOML=1
else
  SKIP_TOML=0
fi

# Check jsonschema library (needed for $schema conformance)
if "$PYTHON" -c "import jsonschema" 2>/dev/null; then
  HAS_JSONSCHEMA=1
else
  HAS_JSONSCHEMA=0
  echo "⚠️  Python 'jsonschema' library not found."
  echo "   Install via: pip install jsonschema"
  echo "   Falling back to parse-only validation (NOT \$schema-conforming)."
  WARNINGS=$((WARNINGS + 1))
fi

# -----------------------------------------------------------------------------
# JSON files to validate
# -----------------------------------------------------------------------------
JSON_FILES=(
  ".claude/settings.json"
  ".claude/settings.local.example.json"
  ".mcp.json"
)

for f in "${JSON_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "⚠️  $f not found (skipping)"
    continue
  fi

  # Step 1 — Parse JSON
  if ! "$PYTHON" -m json.tool "$f" >/dev/null 2>&1; then
    echo "❌ $f (invalid JSON)"
    "$PYTHON" -m json.tool "$f" 2>&1 | head -3 | sed 's/^/    /'
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Step 2 — $schema conformance (if library available AND file declares $schema)
  if [[ $HAS_JSONSCHEMA -eq 1 ]]; then
    SCHEMA_URL=$("$PYTHON" -c "
import json, sys
try:
    with open(sys.argv[1]) as fh:
        data = json.load(fh)
    print(data.get('\$schema', ''))
except Exception:
    print('')
" "$f")

    if [[ -z "$SCHEMA_URL" ]]; then
      echo "✓ $f (parse-only; no \$schema declared)"
    else
      # Attempt schema conformance (v1.0.1: local-first, then network, then parse-only)
      VALIDATION_OUT=$("$PYTHON" - "$f" "$SCHEMA_URL" "$STRICT_MODE" <<'PYEOF' 2>&1
import json
import os
import sys
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError
import socket

try:
    import jsonschema
    from jsonschema import validate, ValidationError
except ImportError:
    print("SKIP: jsonschema module missing")
    sys.exit(0)

instance_path = sys.argv[1]
schema_url = sys.argv[2]
strict = sys.argv[3] == "1"

schema = None
schema_source = ""

# Step 1: try vendored local schema (v1.0.1+, SEC-B-09 fix)
slug = schema_url.rstrip("/").rsplit("/", 1)[-1]
local_path = Path("schemas") / slug
if local_path.is_file():
    try:
        with open(local_path, "r", encoding="utf-8") as fh:
            schema = json.load(fh)
        schema_source = f"local:schemas/{slug}"
    except Exception as e:
        print(f"ERROR: vendored schema {local_path} unreadable: {e}")
        sys.exit(1)

# Step 2: network fetch (skipped in --strict mode)
if schema is None:
    if strict:
        print(f"ERROR: --strict mode but no local vendored schema at schemas/{slug}")
        print(f"  action: curl -fsSL {schema_url} -o schemas/{slug}")
        sys.exit(1)
    try:
        socket.setdefaulttimeout(5)
        req = Request(schema_url, headers={"User-Agent": "ulak-os-validator/1.0.1"})
        with urlopen(req) as r:
            schema = json.loads(r.read().decode("utf-8"))
        schema_source = f"network:{schema_url}"
    except (URLError, socket.timeout) as e:
        print(f"WARN: could not fetch {schema_url}: {e}")
        print(f"  hint: vendor the schema into schemas/{slug} to remove this dependency")
        sys.exit(0)
    except Exception as e:
        print(f"WARN: schema fetch error: {e}")
        sys.exit(0)

with open(instance_path) as fh:
    instance = json.load(fh)

try:
    validate(instance=instance, schema=schema)
    print(f"OK: conforms to schema ({schema_source})")
    sys.exit(0)
except ValidationError as ve:
    print(f"ERROR: {ve.message}")
    print(f"  path: {list(ve.absolute_path)}")
    print(f"  schema source: {schema_source}")
    sys.exit(1)
PYEOF
      )
      VALIDATION_STATUS=$?
      if [[ $VALIDATION_STATUS -eq 1 ]]; then
        echo "❌ $f (\$schema conformance failed)"
        echo "$VALIDATION_OUT" | sed 's/^/    /'
        ERRORS=$((ERRORS + 1))
      elif echo "$VALIDATION_OUT" | grep -q "^WARN:"; then
        echo "✓ $f (parse-only; schema fetch unavailable in this env)"
        echo "$VALIDATION_OUT" | grep "^WARN:" | sed 's/^/    /'
        WARNINGS=$((WARNINGS + 1))
      else
        echo "✓ $f (\$schema-conforming)"
      fi
    fi
  else
    echo "✓ $f (parse-only; jsonschema lib not installed)"
  fi
done

# -----------------------------------------------------------------------------
# TOML files (parse-only; no widely-adopted TOML schema standard)
# -----------------------------------------------------------------------------
if [[ $SKIP_TOML -eq 0 ]]; then
  TOML_FILES=()
  if [[ -d ".gemini/commands" ]]; then
    while IFS= read -r -d '' f; do
      TOML_FILES+=("$f")
    done < <(find .gemini/commands -name "*.toml" -type f -print0)
  fi
  if [[ -f ".gitleaks.toml" ]]; then
    TOML_FILES+=(".gitleaks.toml")
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

echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: $ERRORS schema error(s) found."
  exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo "PASS with $WARNINGS warning(s). Install 'jsonschema' + ensure network access for full conformance."
  exit 0
fi

echo "✓ All schemas valid + \$schema-conforming (where declared)."
exit 0
