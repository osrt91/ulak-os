#!/usr/bin/env bash
# Ulak OS — awesome-design-md fetch helper
# Downloads a specific brand's DESIGN.md from VoltAgent/awesome-design-md
# into reports/current/design-references/<brand>/

set -euo pipefail

UPSTREAM_BASE="https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main"
TARGET_DIR="reports/current/design-references"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <brand>"
  echo ""
  echo "Examples:"
  echo "  $0 stripe"
  echo "  $0 linear"
  echo "  $0 vercel"
  echo ""
  echo "Browse available brands: https://github.com/VoltAgent/awesome-design-md"
  exit 1
fi

BRAND="$1"
BRAND_LOWER=$(echo "$BRAND" | tr '[:upper:]' '[:lower:]')

if ! command -v curl >/dev/null 2>&1; then
  echo "❌ curl required but not found."
  exit 1
fi

mkdir -p "$TARGET_DIR/$BRAND_LOWER"

echo "Fetching DESIGN.md for $BRAND from awesome-design-md..."

# Try common path patterns (the upstream repo organizes by brand directory)
URLS=(
  "$UPSTREAM_BASE/$BRAND_LOWER/DESIGN.md"
  "$UPSTREAM_BASE/sites/$BRAND_LOWER/DESIGN.md"
  "$UPSTREAM_BASE/brands/$BRAND_LOWER/DESIGN.md"
)

FOUND=0
for url in "${URLS[@]}"; do
  if curl -sfL "$url" -o "$TARGET_DIR/$BRAND_LOWER/DESIGN.md" 2>/dev/null; then
    FOUND=1
    echo "✓ Downloaded from: $url"
    break
  fi
done

if [[ $FOUND -eq 0 ]]; then
  echo "❌ Could not find DESIGN.md for '$BRAND' at any expected upstream path."
  echo "   Browse the repo manually: https://github.com/VoltAgent/awesome-design-md"
  echo "   Then download the file directly to: $TARGET_DIR/$BRAND_LOWER/DESIGN.md"
  rmdir "$TARGET_DIR/$BRAND_LOWER" 2>/dev/null || true
  exit 1
fi

# Try to fetch the preview HTML files too (best-effort, no fail)
for preview in preview.html preview-dark.html; do
  for url in \
    "$UPSTREAM_BASE/$BRAND_LOWER/$preview" \
    "$UPSTREAM_BASE/sites/$BRAND_LOWER/$preview" \
    "$UPSTREAM_BASE/brands/$BRAND_LOWER/$preview"; do
    if curl -sfL "$url" -o "$TARGET_DIR/$BRAND_LOWER/$preview" 2>/dev/null; then
      echo "✓ Bonus: $preview"
      break
    fi
  done
done

echo ""
echo "✓ Design reference for '$BRAND' written to: $TARGET_DIR/$BRAND_LOWER/"
echo ""
echo "Use it with your AI agent:"
echo "  'Read $TARGET_DIR/$BRAND_LOWER/DESIGN.md and apply this design to the new component.'"
exit 0
