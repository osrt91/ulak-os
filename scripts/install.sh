#!/usr/bin/env sh
# Ulak OS — one-liner installer (POSIX: macOS + Linux)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/osrt91/ulak-os/main/scripts/install.sh | sh
#   curl -fsSL ... | sh -s -- --dry-run
#
# Installation model:
#   - Clones (or pulls) the Ulak OS repo into $ULAK_HOME (default: $HOME/.ulak-os)
#   - Symlinks $HOME/bin/ulak (or the first writable dir on $PATH) to
#     $ULAK_HOME/bin/ulak, the repo-provided shell wrapper.
#   - The `ulak` command then dispatches: `ulak init <dir>` seeds CLAUDE.md in
#     <dir> with an absolute @-import pointing at $ULAK_HOME/prompts/core/.
#
# Idempotent: running twice converges to the same state (pulls instead of
# re-cloning, verifies the symlink target, preserves existing CLAUDE.md).
#
# Safety:
#   - No sudo calls, no system-wide writes. Everything is under $HOME.
#   - No eval; attacker-controlled env vars never reach the shell parser.
#     Every invocation uses argv directly (hardening per SEC-B-02).
#   - ULAK_* env vars validated against strict regex allowlists before use.
#   - Rollback rm only ever runs when ULAK_HOME resolves to a fresh clone
#     directory we just created under $HOME (hardening per SEC-B-13).

set -eu

ULAK_REPO_URL="${ULAK_REPO_URL:-https://github.com/osrt91/ulak-os.git}"
ULAK_HOME="${ULAK_HOME:-$HOME/.ulak-os}"
ULAK_BRANCH="${ULAK_BRANCH:-main}"
DRY_RUN=0

log() { printf '[ulak] %s\n' "$*"; }
err() { printf '[ulak] ERROR: %s\n' "$*" >&2; }
hint() { printf '[ulak] Hint: %s\n' "$*" >&2; }

# ---------- Arg parsing ----------
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --help|-h)
      cat <<'HLP'
Usage: install.sh [--dry-run] [--help]

Env:
  ULAK_HOME      Install directory (default: $HOME/.ulak-os)
  ULAK_REPO_URL  Git URL (default: https://github.com/osrt91/ulak-os.git)
  ULAK_BRANCH    Branch to track (default: main)
HLP
      exit 0
      ;;
    *) err "unknown argument: $arg"; exit 2 ;;
  esac
done

# ---------- Env-var sanitization (SEC-B-02 hardening) ----------
# Validate every caller-controlled value against a strict regex. A value that
# fails the regex is rejected, not quoted: quoting cannot close every shell
# escape path, but an allowlist can refuse exotic input up front.
validate() {
  # $1 = name, $2 = value, $3 = regex
  name="$1"; value="$2"; pattern="$3"
  if ! printf '%s' "$value" | grep -Eq "^${pattern}$"; then
    err "$name has an invalid value: $value"
    hint "expected regex: ^${pattern}\$"
    exit 1
  fi
}

# ULAK_REPO_URL: https(s) git URL ending .git, OR ssh (git@host:path.git), no spaces/quotes
validate ULAK_REPO_URL "$ULAK_REPO_URL" '(https?://[A-Za-z0-9._\/~:?&=+-]+\.git|git@[A-Za-z0-9.-]+:[A-Za-z0-9._\/~-]+\.git)'

# ULAK_HOME: POSIX-safe absolute path, no shell metacharacters
validate ULAK_HOME "$ULAK_HOME" '/[A-Za-z0-9._/-]+'

# ULAK_BRANCH: git ref — alphanumeric + a small set of separators, no whitespace
validate ULAK_BRANCH "$ULAK_BRANCH" '[A-Za-z0-9._/-]+'

# run() dispatches to argv-positional shell calls with no eval.
run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[ulak][dry-run]'
    for a in "$@"; do printf ' %s' "$a"; done
    printf '\n'
  else
    "$@"
  fi
}

# ---------- Trap: clean partial install (hardened rm path) ----------
_cleanup() {
  status=$?
  if [ "$status" -ne 0 ] && [ "${ULAK_PARTIAL:-0}" = "1" ] && [ "$DRY_RUN" = "0" ]; then
    # Only rm if ULAK_HOME is under $HOME AND basename is .ulak-os or starts with
    # .ulak-os-. Refuses to delete anything else — even with a hostile env.
    resolved_home="$ULAK_HOME"
    case "$resolved_home" in
      "$HOME"/.ulak-os|"$HOME"/.ulak-os-*)
        err "install failed (exit $status); rolling back partial clone at $resolved_home"
        rm -rf "$resolved_home"
        ;;
      *)
        err "install failed (exit $status); REFUSING to roll back because ULAK_HOME is outside expected pattern"
        err "partial clone may remain at: $resolved_home — inspect manually"
        ;;
    esac
  fi
  exit "$status"
}
trap _cleanup INT TERM EXIT

# ---------- Prerequisite checks ----------
log "checking prerequisites"

if ! command -v git >/dev/null 2>&1; then
  err "git is required but not found on PATH"
  hint "install git (macOS: 'xcode-select --install'; Debian: 'sudo apt install git'; Fedora: 'sudo dnf install git')"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  err "neither curl nor wget is available"
  hint "install one of: curl, wget"
  exit 1
fi

# ---------- Pick a PATH-writable bin dir ----------
pick_bin_dir() {
  # Prefer $HOME/bin, then $HOME/.local/bin, then any writable dir on PATH.
  for candidate in "$HOME/bin" "$HOME/.local/bin"; do
    case ":$PATH:" in *":$candidate:"*) echo "$candidate"; return 0 ;; esac
  done
  # Not on PATH yet — still prefer $HOME/bin and let the user add it.
  echo "$HOME/bin"
}

BIN_DIR="$(pick_bin_dir)"
log "target bin directory: $BIN_DIR"

if [ ! -d "$BIN_DIR" ]; then
  log "creating $BIN_DIR"
  run mkdir -p "$BIN_DIR"
fi

if [ "$DRY_RUN" = "0" ] && [ ! -w "$BIN_DIR" ]; then
  err "bin directory is not writable: $BIN_DIR"
  hint "either pass a writable BIN_DIR (e.g. BIN_DIR=\$HOME/.local/bin) or fix perms"
  exit 1
fi

# ---------- Clone or update ----------
if [ -d "$ULAK_HOME/.git" ]; then
  log "existing install detected at $ULAK_HOME — pulling latest"
  run git -C "$ULAK_HOME" fetch --tags --prune origin
  run git -C "$ULAK_HOME" checkout "$ULAK_BRANCH"
  run git -C "$ULAK_HOME" pull --ff-only origin "$ULAK_BRANCH"
elif [ -d "$ULAK_HOME" ]; then
  err "$ULAK_HOME exists but is not a git checkout"
  hint "move it aside or set ULAK_HOME to a fresh path"
  exit 1
else
  log "cloning $ULAK_REPO_URL into $ULAK_HOME"
  ULAK_PARTIAL=1
  run git clone --branch "$ULAK_BRANCH" --depth 50 "$ULAK_REPO_URL" "$ULAK_HOME"
  ULAK_PARTIAL=0
fi

# ---------- Ensure bin/ulak wrapper is executable ----------
WRAPPER="$ULAK_HOME/bin/ulak"
if [ "$DRY_RUN" = "0" ] && [ ! -f "$WRAPPER" ]; then
  err "wrapper missing: $WRAPPER"
  hint "the repo may be incomplete; try: rm -rf '$ULAK_HOME' && re-run the installer"
  exit 1
fi
run chmod +x "$WRAPPER"

# ---------- Symlink ----------
LINK="$BIN_DIR/ulak"
if [ -L "$LINK" ] || [ -f "$LINK" ]; then
  log "refreshing symlink: $LINK -> $WRAPPER"
  run rm -f "$LINK"
fi
run ln -s "$WRAPPER" "$LINK"

# ---------- PATH hint ----------
case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *)
    log "NOTE: $BIN_DIR is not on your PATH."
    hint "add to your shell rc:  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

# ---------- Adapter detection ----------
log "detecting installed AI coding CLIs"
for cli in claude codex gemini; do
  if command -v "$cli" >/dev/null 2>&1; then
    log "  found: $cli ($(command -v "$cli"))"
  else
    log "  not found: $cli"
  fi
done

cat <<'NEXT'

[ulak] Installed. Next steps:

  1. Verify:
       ulak --version

  2. Seed a project with Ulak OS governance:
       cd /path/to/your-project
       ulak init .

  3. Open your AI coding CLI in that project:
       claude        # Claude Code (primary)
       codex         # Codex / Copilot adapter (AGENTS.md)
       gemini        # Gemini CLI adapter

  4. Run a full audit:
       /director komple

Docs: https://github.com/osrt91/ulak-os
NEXT

trap - INT TERM EXIT
exit 0
