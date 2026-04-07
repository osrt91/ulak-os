#!/usr/bin/env bash
# Ulak OS — Codex/Copilot init
# Verifies prerequisites for OpenAI Codex, GitHub Copilot CLI, or compatible agents.

set -euo pipefail

BANNER="━━━ Ulak OS → Codex/Copilot init ━━━"
echo ""
echo "$BANNER"
echo ""

# 1. Binary check (try codex, then copilot, then gh)
FOUND_BINARY=""
for bin in codex copilot gh; do
  if command -v "$bin" >/dev/null 2>&1; then
    FOUND_BINARY="$bin"
    break
  fi
done
if [[ -z "$FOUND_BINARY" ]]; then
  echo "❌ No compatible binary found (tried: codex, copilot, gh)."
  echo "   Install one of:"
  echo "   - GitHub Copilot CLI: https://github.com/github/gh-copilot"
  echo "   - OpenAI Codex CLI:    https://github.com/openai/codex"
  exit 1
fi
echo "✓ Found agent binary: $FOUND_BINARY"

# 2. Required files check
REQUIRED_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  ".github/copilot-instructions.md"
  "docs/adapters/codex-cli.md"
  "docs/adapters/universal-runtime-contract.md"
)
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ Required file missing: $f"
    exit 1
  fi
done
echo "✓ All required files present"

# 3. Reports directory
mkdir -p reports/current
echo "✓ reports/current/ ready"

# 4. Next command
echo ""
echo "━━━ Setup complete ━━━"
echo ""
echo "Next steps:"
echo "  1. Start your agent ($FOUND_BINARY)"
echo "  2. Tell the agent:"
echo "     'Read AGENTS.md, CLAUDE.md, docs/adapters/codex-cli.md and"
echo "      docs/adapters/universal-runtime-contract.md, then run the"
echo "      appropriate program mode.'"
echo ""
exit 0
