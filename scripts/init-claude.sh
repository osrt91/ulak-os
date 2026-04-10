#!/usr/bin/env bash
# Ulak OS — Claude Code init
# Verifies prerequisites and prepares the workspace for Claude Code.

set -euo pipefail

BANNER="━━━ Ulak OS → Claude Code init ━━━"
echo ""
echo "$BANNER"
echo ""

WARN_COUNT=0

# 1. Binary check
if ! command -v claude >/dev/null 2>&1; then
  echo "❌ 'claude' binary not found in PATH."
  echo "   Install Claude Code: https://claude.com/claude-code"
  exit 1
fi
echo "✓ claude binary found: $(command -v claude)"

# 2. Required files check
REQUIRED_FILES=(
  "CLAUDE.md"
  "prompts/core/ulak-os-core-contract-2.0.0.md"
  ".claude/settings.json"
)
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ Required file missing: $f"
    echo "   Are you running this from the ulak-os repo root?"
    exit 1
  fi
done
echo "✓ All required files present"

# 3. MCP env var check (optional, warn only)
MCP_VARS=(GITHUB_MCP_URL GITHUB_TOKEN JIRA_MCP_URL JIRA_TOKEN FIGMA_MCP_URL FIGMA_TOKEN)
MISSING_MCP=()
for v in "${MCP_VARS[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    MISSING_MCP+=("$v")
  fi
done
if [[ ${#MISSING_MCP[@]} -gt 0 ]]; then
  echo "⚠️  MCP env vars not set: ${MISSING_MCP[*]}"
  echo "   MCP connectors will be disabled. See README.md for setup."
  WARN_COUNT=$((WARN_COUNT + 1))
fi

# 4. Reports directory
mkdir -p reports/current
echo "✓ reports/current/ ready"

# 5. Next command
echo ""
echo "━━━ Setup complete ━━━"
echo ""
echo "Next steps:"
echo "  1. Start Claude Code:    claude"
echo "  2. Verify memory loaded:  /memory"
echo "  3. Run first command:    /director komple"
echo ""
if [[ $WARN_COUNT -gt 0 ]]; then
  echo "(Completed with $WARN_COUNT warning(s) — see above.)"
  exit 2
fi
exit 0
