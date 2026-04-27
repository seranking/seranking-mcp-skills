#!/usr/bin/env bash
# extensions/firecrawl/uninstall.sh — remove firecrawl-mcp from Claude Code settings.
#
# Removes the mcpServers.firecrawl-mcp entry only. Other mcpServers entries are
# preserved. Does NOT remove the npm package cache (run `npm cache clean` for a
# deeper purge).

set -euo pipefail

SETTINGS_FILE="${CLAUDE_SETTINGS_FILE:-$HOME/.claude/settings.json}"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "No settings file at $SETTINGS_FILE; nothing to uninstall."
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: 'python3' not found on PATH (used to edit settings.json safely)." >&2
  exit 1
fi

python3 - "$SETTINGS_FILE" <<'PYEOF'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])

try:
    settings = json.loads(settings_path.read_text())
except json.JSONDecodeError as exc:
    print(f"Error: {settings_path} is not valid JSON ({exc}).", file=sys.stderr)
    sys.exit(1)

mcp_servers = settings.get("mcpServers", {})
if "firecrawl-mcp" not in mcp_servers:
    print("firecrawl-mcp not present in mcpServers; nothing to uninstall.")
    sys.exit(0)

del mcp_servers["firecrawl-mcp"]
settings_path.write_text(json.dumps(settings, indent=2) + "\n")
print(f"Removed mcpServers.firecrawl-mcp from {settings_path}.")
PYEOF

echo "Restart Claude Code (or run /mcp) to pick up the change."
