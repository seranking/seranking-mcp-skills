#!/usr/bin/env bash
# install.sh — top-level installer for seo-skills.
#
# Two jobs:
#   1. Make sure a working clone of the repo exists (clones if needed).
#   2. Optionally run the extension installers (firecrawl + google).
#
# Designed to be safe under `curl ... | bash`: no interactive prompts when
# stdin is not a TTY. Pass flags to control non-interactive behavior.
#
# Usage:
#   bash install.sh                       # interactive (prompts for extensions)
#   bash install.sh --all                 # clone + install all extensions
#   bash install.sh --firecrawl --google  # explicit
#   bash install.sh --no-extensions       # clone only
#   bash install.sh --target /some/path   # custom clone target
#
#   curl -fsSL https://raw.githubusercontent.com/seranking/seo-skills/main/install.sh | bash
#
# Idempotent. Re-running updates an existing clone (git pull --ff-only) and
# re-runs whichever extension installers you ask for.

set -euo pipefail

REPO_URL="${SEO_SKILLS_REPO_URL:-https://github.com/seranking/seo-skills.git}"
DEFAULT_TARGET="${HOME}/.local/share/seo-skills"

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
dim()    { printf '\033[2m%s\033[0m\n' "$*"; }

# --- 1. Parse flags ----------------------------------------------------------

TARGET=""
INSTALL_FIRECRAWL=0
INSTALL_GOOGLE=0
NO_EXTENSIONS=0
INTERACTIVE=auto   # auto | yes | no

while [ $# -gt 0 ]; do
  case "$1" in
    --target)        TARGET="$2"; shift 2 ;;
    --target=*)      TARGET="${1#*=}"; shift ;;
    --all)           INSTALL_FIRECRAWL=1; INSTALL_GOOGLE=1; shift ;;
    --firecrawl)     INSTALL_FIRECRAWL=1; shift ;;
    --google)        INSTALL_GOOGLE=1; shift ;;
    --no-extensions) NO_EXTENSIONS=1; shift ;;
    --non-interactive) INTERACTIVE=no; shift ;;
    --interactive)   INTERACTIVE=yes; shift ;;
    -h|--help)
      sed -n '2,22p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      red "Unknown flag: $1"
      echo "Run 'bash install.sh --help' for usage."
      exit 1
      ;;
  esac
done

# Resolve interactive mode if 'auto'
if [ "$INTERACTIVE" = "auto" ]; then
  if [ -t 0 ] || [ -t 1 ]; then
    INTERACTIVE=yes
  else
    INTERACTIVE=no
  fi
fi

# --- 2. Base dependencies ----------------------------------------------------

command -v git >/dev/null 2>&1 || { red "Error: 'git' not found on PATH (required to clone the repo)."; exit 1; }
command -v python3 >/dev/null 2>&1 || { red "Error: 'python3' not found on PATH (required by both extensions)."; exit 1; }

PY_OK="$(python3 -c 'import sys; print(1 if sys.version_info >= (3, 10) else 0)')"
if [ "$PY_OK" != "1" ]; then
  PY_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
  red "Error: Python $PY_VER detected; seo-skills extensions require Python 3.10+."
  exit 1
fi

# --- 3. Find or clone the repo ----------------------------------------------

REPO_DIR=""
if [ -f "$(pwd)/.claude-plugin/plugin.json" ]; then
  REPO_DIR="$(pwd)"
  green "✓ Running from existing clone at $REPO_DIR"
else
  TARGET="${TARGET:-$DEFAULT_TARGET}"
  if [ -d "$TARGET/.claude-plugin" ] && [ -d "$TARGET/.git" ]; then
    bold "→ Updating existing clone at $TARGET"
    git -C "$TARGET" fetch --depth 1 origin main >/dev/null 2>&1 || true
    git -C "$TARGET" pull --ff-only >/dev/null || yellow "  (pull --ff-only failed; continuing with current state)"
    REPO_DIR="$TARGET"
    green "✓ Updated $TARGET"
  elif [ -d "$TARGET" ] && [ "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    red "Error: target directory '$TARGET' exists and is not empty."
    echo "Pass --target <dir> to choose a different location, or remove the directory first."
    exit 1
  else
    bold "→ Cloning $REPO_URL → $TARGET"
    mkdir -p "$(dirname "$TARGET")"
    git clone --depth 1 "$REPO_URL" "$TARGET"
    REPO_DIR="$TARGET"
    green "✓ Cloned to $TARGET"
  fi
fi

# --- 4. Decide which extensions to install -----------------------------------

if [ "$NO_EXTENSIONS" -eq 1 ]; then
  INSTALL_FIRECRAWL=0
  INSTALL_GOOGLE=0
elif [ "$INSTALL_FIRECRAWL" -eq 0 ] && [ "$INSTALL_GOOGLE" -eq 0 ]; then
  # No extension flags passed — ask interactively, or default to "skip" non-interactive.
  if [ "$INTERACTIVE" = "yes" ]; then
    echo ""
    bold "Optional extensions:"
    echo "  • Firecrawl  — wires firecrawl-mcp into Claude Code (raw HTML, JSON-LD, JS rendering)."
    echo "                 Used by 11 SE Ranking skills + the seo-firecrawl orchestrator."
    echo "  • Google     — pip-installs Google API libs + sets up ~/.config/seo-skills/."
    echo "                 Required by seo-google."
    echo ""
    # Read from /dev/tty so it works under curl|bash with a real terminal.
    TTY_DEV="/dev/tty"
    [ -e "$TTY_DEV" ] || TTY_DEV=""

    prompt_yn() {
      local q="$1" default="$2" answer
      local hint
      if [ "$default" = "y" ]; then hint="[Y/n]"; else hint="[y/N]"; fi
      printf '%s %s ' "$q" "$hint"
      if [ -n "$TTY_DEV" ]; then
        read -r answer < "$TTY_DEV" || answer=""
      else
        read -r answer || answer=""
      fi
      answer="${answer:-$default}"
      case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
      esac
    }

    if prompt_yn "Install Firecrawl extension?" "y"; then INSTALL_FIRECRAWL=1; fi
    if prompt_yn "Install Google APIs extension?" "y"; then INSTALL_GOOGLE=1; fi
  else
    yellow "Non-interactive mode (no TTY): skipping extensions. Re-run with --all (or --firecrawl / --google) to install them."
  fi
fi

# --- 5. Run extension installers --------------------------------------------

if [ "$INSTALL_FIRECRAWL" -eq 1 ]; then
  echo ""
  bold "→ Installing Firecrawl extension..."
  if [ -f "$REPO_DIR/extensions/firecrawl/install.sh" ]; then
    bash "$REPO_DIR/extensions/firecrawl/install.sh" || red "  Firecrawl install returned a non-zero exit. See messages above."
  else
    red "  $REPO_DIR/extensions/firecrawl/install.sh not found."
  fi
fi

if [ "$INSTALL_GOOGLE" -eq 1 ]; then
  echo ""
  bold "→ Installing Google APIs extension..."
  if [ -f "$REPO_DIR/extensions/google/install.sh" ]; then
    bash "$REPO_DIR/extensions/google/install.sh" || red "  Google install returned a non-zero exit. See messages above."
  else
    red "  $REPO_DIR/extensions/google/install.sh not found."
  fi
fi

# --- 6. Next steps -----------------------------------------------------------

echo ""
green "✓ seo-skills setup complete."
echo ""
bold "Next steps:"
echo ""
echo "  1. Install the plugin in Claude Code (skill files + slash commands):"
echo ""
echo "     /plugin marketplace add seranking/seo-skills"
echo "     /plugin install seo-skills@seranking"
echo ""
echo "     Or for local development against this clone:"
echo "     claude --plugin-dir $REPO_DIR"
echo ""
echo "  2. Connect the SE Ranking remote MCP (powers most skills):"
echo ""
echo "     claude mcp add --transport http se-ranking https://api.seranking.com/mcp"
echo "     # then run /mcp in a session and sign in via OAuth"
echo ""

if [ "$INSTALL_GOOGLE" -eq 1 ]; then
  echo "  3. Fill in your Google API credentials:"
  echo ""
  echo "     Edit ~/.config/seo-skills/google-api.json"
  echo "     Walkthrough: $REPO_DIR/skills/seo-google/references/auth-setup.md"
  echo "     Verify:      python3 $REPO_DIR/scripts/google_auth.py --check"
  echo ""
fi

if [ "$INSTALL_FIRECRAWL" -eq 0 ] && [ "$NO_EXTENSIONS" -eq 0 ]; then
  dim "Skipped Firecrawl. To install later: bash $REPO_DIR/extensions/firecrawl/install.sh"
fi
if [ "$INSTALL_GOOGLE" -eq 0 ] && [ "$NO_EXTENSIONS" -eq 0 ]; then
  dim "Skipped Google APIs. To install later: bash $REPO_DIR/extensions/google/install.sh"
fi

echo ""
bold "Repo: $REPO_DIR"
