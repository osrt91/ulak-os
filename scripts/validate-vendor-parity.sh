#!/usr/bin/env bash
# Ulak OS — vendor parity validator
# Ensures each slash command / skill / agent exists across all shipped vendor adapters.
# Fails if a command exists for Claude Code but not Gemini CLI / Codex (or vice versa).
# Output: parity matrix + exit 1 if any cell is missing without declared exemption.
#
# Added in v2.1.4 (W4.16) to resolve DY-03 vendor-parity silent-drift finding.

set -euo pipefail

ROOT="${1:-.}"
EXIT_CODE=0

declare -A CLAUDE_COMMANDS
declare -A GEMINI_COMMANDS
declare -A CODEX_COMMANDS

# -----------------------------------------------------------------------------
# Discover commands per vendor
# -----------------------------------------------------------------------------

if [[ -d "$ROOT/.claude/commands" ]]; then
  while IFS= read -r -d '' f; do
    name=$(basename "$f" .md)
    CLAUDE_COMMANDS["$name"]=1
  done < <(find "$ROOT/.claude/commands" -name "*.md" -type f -print0 2>/dev/null)
fi

if [[ -d "$ROOT/.gemini/commands" ]]; then
  while IFS= read -r -d '' f; do
    name=$(basename "$f" .toml)
    name=${name%.md}
    GEMINI_COMMANDS["$name"]=1
  done < <(find "$ROOT/.gemini/commands" \( -name "*.toml" -o -name "*.md" \) -type f -print0 2>/dev/null)
fi

if [[ -d "$ROOT/.codex/commands" ]]; then
  while IFS= read -r -d '' f; do
    name=$(basename "$f" .md)
    CODEX_COMMANDS["$name"]=1
  done < <(find "$ROOT/.codex/commands" -name "*.md" -type f -print0 2>/dev/null)
fi

# -----------------------------------------------------------------------------
# Load exemptions — commands intentionally not shipped for a specific vendor
# -----------------------------------------------------------------------------
declare -A EXEMPT_CLAUDE EXEMPT_GEMINI EXEMPT_CODEX
EXEMPT_FILE="$ROOT/.github/vendor-parity-exemptions.txt"

if [[ -f "$EXEMPT_FILE" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    vendor=$(echo "$line" | cut -d: -f1)
    cmd=$(echo "$line" | cut -d: -f2)
    case "$vendor" in
      claude)  EXEMPT_CLAUDE["$cmd"]=1 ;;
      gemini)  EXEMPT_GEMINI["$cmd"]=1 ;;
      codex)   EXEMPT_CODEX["$cmd"]=1 ;;
    esac
  done < "$EXEMPT_FILE"
fi

# -----------------------------------------------------------------------------
# Build union of all command names
# -----------------------------------------------------------------------------
declare -A ALL_COMMANDS
for name in "${!CLAUDE_COMMANDS[@]}"; do ALL_COMMANDS["$name"]=1; done
for name in "${!GEMINI_COMMANDS[@]}"; do ALL_COMMANDS["$name"]=1; done
for name in "${!CODEX_COMMANDS[@]}"; do ALL_COMMANDS["$name"]=1; done

# -----------------------------------------------------------------------------
# Emit parity matrix + check missing
# -----------------------------------------------------------------------------
printf "\n%-30s %-8s %-8s %-8s %s\n" "command" "claude" "gemini" "codex" "status"
printf "%-30s %-8s %-8s %-8s %s\n" "------------------------------" "--------" "--------" "--------" "------"

MISSING=0

for cmd in $(echo "${!ALL_COMMANDS[@]}" | tr ' ' '\n' | sort); do
  c_mark="-"
  g_mark="-"
  x_mark="-"
  status="OK"

  [[ -n "${CLAUDE_COMMANDS[$cmd]:-}" ]] && c_mark="✓"
  [[ -n "${GEMINI_COMMANDS[$cmd]:-}" ]] && g_mark="✓"
  [[ -n "${CODEX_COMMANDS[$cmd]:-}" ]] && x_mark="✓"

  # Check missing unless exempt
  if [[ "$c_mark" == "-" && -z "${EXEMPT_CLAUDE[$cmd]:-}" ]]; then
    status="MISSING(claude)"
    MISSING=$((MISSING + 1))
  fi
  if [[ "$g_mark" == "-" && -z "${EXEMPT_GEMINI[$cmd]:-}" ]]; then
    if [[ "$status" == "OK" ]]; then status="MISSING(gemini)"; else status="${status},gemini"; fi
    MISSING=$((MISSING + 1))
  fi
  # Codex is optional — not all projects ship codex commands. Only flag if explicitly exempt declared OR codex folder exists.
  if [[ -d "$ROOT/.codex/commands" ]]; then
    if [[ "$x_mark" == "-" && -z "${EXEMPT_CODEX[$cmd]:-}" ]]; then
      if [[ "$status" == "OK" ]]; then status="MISSING(codex)"; else status="${status},codex"; fi
      MISSING=$((MISSING + 1))
    fi
  fi

  printf "%-30s %-8s %-8s %-8s %s\n" "$cmd" "$c_mark" "$g_mark" "$x_mark" "$status"
done

echo ""
if [[ $MISSING -gt 0 ]]; then
  echo "FAIL: $MISSING vendor-parity gap(s) without exemption."
  echo ""
  echo "To add an exemption, append to $EXEMPT_FILE:"
  echo "  # <reason>"
  echo "  <vendor>:<command_name>"
  echo "  # e.g.  gemini:ulak-design-ref   — Figma MCP not ported to Gemini CLI yet"
  exit 1
fi

echo "✓ Vendor parity maintained across all commands."
exit 0
