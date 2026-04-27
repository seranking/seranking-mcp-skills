#!/usr/bin/env bash
# extensions/firecrawl/install.sh — wire firecrawl-mcp into Claude Code.
#
# What this does:
#   1. Verify Node 20+, npx, and python3.
#   2. Ask for FIRECRAWL_API_KEY (or read from environment).
#   3. Merge mcpServers.firecrawl-mcp into ~/.claude/settings.json (preserves
#      existing entries via a Python merge step).
#   4. Pre-warm the npm package.
#   5. Print the available tools.
#
# Idempotent: re-running updates the entry; existing mcpServers entries are
# preserved.

set -euo pipefail

SETTINGS_FILE="${CLAUDE_SETTINGS_FILE:-$HOME/.claude/settings.json}"
SETTINGS_DIR="$(dirname "$SETTINGS_FILE")"

red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# --- 1. Dependency checks -----------------------------------------------------

if ! command -v node >/dev/null 2>&1; then
  red "Error: 'node' not found on PATH."
  echo "Install Node 20+ from https://nodejs.org or via your package manager."
  exit 1
fi

NODE_MAJOR="$(node -v | sed -E 's/^v([0-9]+).*/\1/')"
if [ "$NODE_MAJOR" -lt 20 ]; then
  red "Error: Node $NODE_MAJOR detected; firecrawl-mcp requires Node 20+."
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  red "Error: 'npx' not found on PATH."
  echo "npx ships with npm (Node 20+ includes both). Re-install Node if missing."
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  red "Error: 'python3' not found on PATH (used to merge settings.json safely)."
  exit 1
fi

green "✓ Node $(node -v), npx $(npx --version), python3 $(python3 --version | awk '{print $2}')"

# --- 2. API key ---------------------------------------------------------------

if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
  bold "Enter your Firecrawl API key (https://firecrawl.dev — free tier is 500 credits/month):"
  read -r -s FIRECRAWL_API_KEY
  echo ""
  if [ -z "$FIRECRAWL_API_KEY" ]; then
    red "No API key entered. Aborting."
    exit 1
  fi
fi

# --- 3. Merge into settings.json ---------------------------------------------

mkdir -p "$SETTINGS_DIR"
[ -f "$SETTINGS_FILE" ] || echo '{}' > "$SETTINGS_FILE"

python3 - "$SETTINGS_FILE" "$FIRECRAWL_API_KEY" <<'PYEOF'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
api_key = sys.argv[2]

try:
    settings = json.loads(settings_path.read_text())
    if not isinstance(settings, dict):
        raise ValueError("settings.json root must be an object")
except json.JSONDecodeError as exc:
    print(f"Error: {settings_path} is not valid JSON ({exc}). Aborting.", file=sys.stderr)
    sys.exit(1)
except FileNotFoundError:
    settings = {}

mcp_servers = settings.setdefault("mcpServers", {})
existed = "firecrawl-mcp" in mcp_servers

mcp_servers["firecrawl-mcp"] = {
    "command": "npx",
    "args": ["-y", "firecrawl-mcp"],
    "env": {"FIRECRAWL_API_KEY": api_key},
}

settings_path.write_text(json.dumps(settings, indent=2) + "\n")
print(f"{'Updated' if existed else 'Added'} mcpServers.firecrawl-mcp in {settings_path}")
PYEOF

# --- 4. Pre-warm --------------------------------------------------------------

bold "Pre-warming firecrawl-mcp..."
npx -y firecrawl-mcp --version >/dev/null 2>&1 || true

# --- 5. Tools available -------------------------------------------------------

green "✓ firecrawl-mcp installed."
echo ""
bold "Available tools (prefix mcp__firecrawl-mcp__):"
cat <<'TOOLS'
  - firecrawl_scrape          (single URL → markdown + html + metadata + screenshot)
  - firecrawl_map             (single domain → URL list)
  - firecrawl_crawl           (single domain → all pages)
  - firecrawl_check_crawl_status  (poll long-running crawl jobs)
  - firecrawl_search          (search within a domain)
  - firecrawl_extract         (LLM extraction — out of scope for seo-skills)
  - firecrawl_deep_research   (out of scope for seo-skills)
TOOLS

echo ""
bold "Next steps:"
echo "  1. Restart Claude Code (or run /mcp to refresh)."
echo "  2. Verify: '/mcp' should list 'firecrawl-mcp' as connected."
echo "  3. Try: '/seo-skills:seo-firecrawl scrape https://example.com'"
echo ""
bold "Free tier: 500 credits/month. See https://firecrawl.dev/pricing for paid tiers."
