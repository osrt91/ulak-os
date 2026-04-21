#!/usr/bin/env bash
# Ulak OS — sync-gemini-commands.sh
# Source: .claude/commands/*.md
# Target: .gemini/commands/*.toml
#
# Reads each Claude-side slash command, parses YAML frontmatter (description,
# description_en), keeps the markdown body as the prompt, and emits a
# Gemini-CLI native TOML command file.
#
# Rules:
#   - Idempotent: re-running produces byte-identical output when sources
#     have not changed.
#   - Non-destructive for hand-authored originals: commands listed in
#     SKIP_ORIGINALS are never overwritten. These are the 7 TOML files that
#     predate this sync (director, final-verdict, intake, market-scan,
#     pack-gap-audit, ulak-design-ref, ulak-intake) — they were hand-tuned
#     for Gemini and must survive the sync untouched.
#   - Safe TOML: description goes into a double-quoted string with escapes;
#     prompt body goes into a triple-quoted TOML string. The script refuses
#     to write a file whose body contains a literal triple quote (would
#     break TOML parsing).
#
# Usage:
#   bash scripts/sync-gemini-commands.sh          # from repo root
#   bash scripts/sync-gemini-commands.sh /path    # explicit root

set -euo pipefail

ROOT="${1:-.}"
SRC_DIR="$ROOT/.claude/commands"
DST_DIR="$ROOT/.gemini/commands"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: source dir not found: $SRC_DIR" >&2
  exit 2
fi
mkdir -p "$DST_DIR"

# Hand-authored Gemini TOML files that must never be overwritten.
SKIP_ORIGINALS=(
  "director"
  "final-verdict"
  "intake"
  "market-scan"
  "pack-gap-audit"
  "ulak-design-ref"
  "ulak-intake"
)

is_skipped() {
  local name="$1"
  local s
  for s in "${SKIP_ORIGINALS[@]}"; do
    [[ "$name" == "$s" ]] && return 0
  done
  return 1
}

# Escape a string for use inside a double-quoted TOML value.
toml_escape_dq() {
  # backslash first, then double quote, then control chars (newline -> \n, tab -> \t, CR -> \r)
  printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' \
          -e 's/"/\\"/g' \
          -e ':a;N;$!ba;s/\n/\\n/g' \
    | tr -d '\r'
}

written=0
skipped=0
total=0

for md in "$SRC_DIR"/*.md; do
  [[ -e "$md" ]] || continue
  total=$((total + 1))
  name=$(basename "$md" .md)

  if is_skipped "$name"; then
    skipped=$((skipped + 1))
    continue
  fi

  # Parse frontmatter: lines between the first two "---" markers.
  # Extract description + description_en (fallback description_en=description).
  desc=$(awk '
    BEGIN { in_fm=0; count=0 }
    /^---[[:space:]]*$/ { count++; if (count==1){in_fm=1;next} else {exit} }
    in_fm && /^description:[[:space:]]/ {
      sub(/^description:[[:space:]]*/, "")
      print
      exit
    }
  ' "$md")

  desc_en=$(awk '
    BEGIN { in_fm=0; count=0 }
    /^---[[:space:]]*$/ { count++; if (count==1){in_fm=1;next} else {exit} }
    in_fm && /^description_en:[[:space:]]/ {
      sub(/^description_en:[[:space:]]*/, "")
      print
      exit
    }
  ' "$md")

  [[ -z "$desc_en" ]] && desc_en="$desc"

  if [[ -z "$desc" ]]; then
    # No YAML frontmatter description — fall back to first H1 line.
    desc=$(awk '/^# / { sub(/^# /, ""); print; exit }' "$md")
    desc_en="$desc"
  fi

  # Body = everything after the second "---" marker (the frontmatter close).
  body=$(awk '
    BEGIN { in_fm=0; count=0; started=0 }
    {
      if (!started) {
        if ($0 ~ /^---[[:space:]]*$/) {
          count++
          if (count==1) { in_fm=1; next }
          else if (count==2) { in_fm=0; started=1; next }
        } else if (count==0) {
          # File has no frontmatter at all — print everything.
          started=1
        }
      }
      if (started) print
    }
  ' "$md")

  # Strip leading blank lines from body (makes output tidier).
  body=$(printf '%s\n' "$body" | awk 'NF||p{p=1;print}')

  if printf '%s' "$body" | grep -q '"""'; then
    echo "SKIP: $name contains triple-quote literal — would break TOML" >&2
    skipped=$((skipped + 1))
    continue
  fi

  desc_esc=$(toml_escape_dq "$desc")

  out="$DST_DIR/${name}.toml"
  {
    printf '# Auto-generated from .claude/commands/%s.md\n' "$name"
    printf '# Do not edit manually — run scripts/sync-gemini-commands.sh to regenerate.\n'
    printf '# Source of truth: .claude/commands/%s.md\n' "$name"
    printf '\n'
    printf 'description = "%s"\n' "$desc_esc"
    printf '\n'
    printf 'prompt = """\n'
    printf '%s\n' "$body"
    printf '"""\n'
  } > "$out"

  written=$((written + 1))
done

echo ""
echo "sync-gemini-commands.sh summary:"
echo "  scanned  = $total"
echo "  written  = $written"
echo "  skipped  = $skipped  (hand-authored originals + unsafe bodies)"
echo "  dest     = $DST_DIR"
