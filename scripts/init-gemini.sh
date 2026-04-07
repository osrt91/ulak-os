#!/usr/bin/env bash
# Ulak OS — Gemini CLI init

set -euo pipefail

BANNER="━━━ Ulak OS → Gemini CLI init ━━━"
echo ""
echo "$BANNER"
echo ""

WARN_COUNT=0

# 1. Binary check
if ! command -v gemini >/dev/null 2>&1; then
  echo "❌ 'gemini' binary not found in PATH."
  echo "   Install Gemini CLI: https://github.com/google-gemini/gemini-cli"
  exit 1
fi
echo "✓ gemini binary found: $(command -v gemini)"

# 2. Required files check
REQUIRED_FILES=(
  "GEMINI.md"
  "prompts/core/ulak-os-core-contract-1.0.0.md"
  "docs/adapters/gemini-cli.md"
)
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ Required file missing: $f"
    exit 1
  fi
done
echo "✓ All required files present"

# 3. Gemini commands directory check
if [[ ! -d ".gemini/commands" ]]; then
  echo "❌ .gemini/commands/ directory missing"
  exit 1
fi
TOML_COUNT=$(find .gemini/commands -name "*.toml" -type f | wc -l)
if [[ $TOML_COUNT -lt 1 ]]; then
  echo "⚠️  No .toml command files found in .gemini/commands/"
  WARN_COUNT=$((WARN_COUNT + 1))
fi
echo "✓ Found $TOML_COUNT TOML command(s)"

# 4. Reports directory
mkdir -p reports/current
echo "✓ reports/current/ ready"

# 5. Next command
echo ""
echo "━━━ Setup complete ━━━"
echo ""
echo "Next steps:"
echo "  1. Start Gemini CLI:      gemini"
echo "  2. Reload memory:         /memory reload"
echo "  3. Reload commands:       /commands reload"
echo "  4. Run first command:    /director komple"
echo ""
if [[ $WARN_COUNT -gt 0 ]]; then
  exit 2
fi
exit 0
