#!/usr/bin/env bash
# Ulak OS — awesome-design-md fetch helper
# Usage:
#   ./fetch-design-references.sh <brand>      — fetch one brand's DESIGN.md pointer
#   ./fetch-design-references.sh --all        — clone the full repo into vendor/awesome-design-md/
#   ./fetch-design-references.sh --list       — list locally-available brands (needs --all first)
#   ./fetch-design-references.sh --update     — git pull the full mirror

set -euo pipefail

UPSTREAM_REPO="https://github.com/VoltAgent/awesome-design-md.git"
UPSTREAM_RAW_BASE="https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main"
VENDOR_DIR="vendor/awesome-design-md"
TARGET_DIR="reports/current/design-references"

if [[ $# -lt 1 ]]; then
  cat <<EOF
Usage:
  $0 <brand>      Fetch one brand's design reference into $TARGET_DIR/
  $0 --all        Clone full awesome-design-md repo into $VENDOR_DIR/ (gitignored)
  $0 --list       List available brands (requires --all first)
  $0 --update     Update the local mirror (git pull)

Examples:
  $0 stripe
  $0 linear.app
  $0 --all
  $0 --list | head -20

Browse upstream: https://github.com/VoltAgent/awesome-design-md
EOF
  exit 1
fi

MODE="$1"

# --all: full clone
if [[ "$MODE" == "--all" ]]; then
  if [[ -d "$VENDOR_DIR/.git" ]]; then
    echo "Full mirror already exists at $VENDOR_DIR. Use --update to refresh."
    exit 0
  fi
  mkdir -p "$(dirname "$VENDOR_DIR")"
  echo "Cloning $UPSTREAM_REPO into $VENDOR_DIR ..."
  if ! command -v git >/dev/null 2>&1; then
    echo "❌ git required but not found."
    exit 1
  fi
  git clone --depth 1 "$UPSTREAM_REPO" "$VENDOR_DIR"
  echo ""
  echo "✓ Full mirror cloned. Browse: $VENDOR_DIR/design-md/"
  echo "   (Directory is gitignored per .gitignore)"
  exit 0
fi

# --update: git pull the mirror
if [[ "$MODE" == "--update" ]]; then
  if [[ ! -d "$VENDOR_DIR/.git" ]]; then
    echo "❌ No local mirror found. Run: $0 --all first."
    exit 1
  fi
  echo "Updating mirror at $VENDOR_DIR ..."
  (cd "$VENDOR_DIR" && git pull)
  exit 0
fi

# --list: enumerate available brands
if [[ "$MODE" == "--list" ]]; then
  if [[ ! -d "$VENDOR_DIR/design-md" ]]; then
    echo "❌ No local mirror found. Run: $0 --all first."
    exit 1
  fi
  # Print brand names (directory names) sorted
  ls -1 "$VENDOR_DIR/design-md/" | grep -v '^README' | sort
  exit 0
fi

# single-brand fetch
BRAND="$MODE"
BRAND_LOWER=$(echo "$BRAND" | tr '[:upper:]' '[:lower:]')

if ! command -v curl >/dev/null 2>&1; then
  echo "❌ curl required but not found."
  exit 1
fi

mkdir -p "$TARGET_DIR/$BRAND_LOWER"

echo "Fetching reference for $BRAND from awesome-design-md..."

# First, if we have a local mirror, copy from there (offline-friendly + faster)
if [[ -d "$VENDOR_DIR/design-md/$BRAND_LOWER" ]]; then
  cp -r "$VENDOR_DIR/design-md/$BRAND_LOWER/." "$TARGET_DIR/$BRAND_LOWER/"
  echo "✓ Copied from local mirror: $VENDOR_DIR/design-md/$BRAND_LOWER/"
  echo ""
  cat "$TARGET_DIR/$BRAND_LOWER/README.md" 2>/dev/null | head -5
  exit 0
fi

# Otherwise, try remote URL patterns
URLS=(
  "$UPSTREAM_RAW_BASE/design-md/$BRAND_LOWER/README.md"
  "$UPSTREAM_RAW_BASE/design-md/$BRAND_LOWER/DESIGN.md"
  "$UPSTREAM_RAW_BASE/$BRAND_LOWER/DESIGN.md"
  "$UPSTREAM_RAW_BASE/sites/$BRAND_LOWER/DESIGN.md"
  "$UPSTREAM_RAW_BASE/brands/$BRAND_LOWER/DESIGN.md"
)

FOUND=0
for url in "${URLS[@]}"; do
  if curl -sfL "$url" -o "$TARGET_DIR/$BRAND_LOWER/README.md" 2>/dev/null; then
    FOUND=1
    echo "✓ Downloaded from: $url"
    break
  fi
done

if [[ $FOUND -eq 0 ]]; then
  echo "❌ Could not find reference for '$BRAND' at any expected upstream path."
  echo ""
  echo "Suggestions:"
  echo "  - Run '$0 --all' to clone the full repo (offline access to all brands)"
  echo "  - Browse the repo manually: https://github.com/VoltAgent/awesome-design-md"
  echo "  - Check the upstream redirect: https://getdesign.md/$BRAND_LOWER/design-md/"
  rmdir "$TARGET_DIR/$BRAND_LOWER" 2>/dev/null || true
  exit 1
fi

echo ""
echo "✓ Design reference for '$BRAND' written to: $TARGET_DIR/$BRAND_LOWER/"
echo ""
echo "Next step — brief your frontend agent:"
echo "  'Read $TARGET_DIR/$BRAND_LOWER/README.md and apply this design to the UI.'"
echo ""
echo "Or re-run the scaffolder with design_reference=$BRAND to bake the DESIGN.md"
echo "into a new SaaS project from scratch."
exit 0
