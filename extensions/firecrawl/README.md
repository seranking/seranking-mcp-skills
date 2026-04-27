# Firecrawl extension for `seo-skills`

Optional Firecrawl MCP integration that powers JS-rendering, raw-`<head>` access, JSON-LD parsing, and full-site crawling across `seo-skills`. Without it, eight Firecrawl-using skills emit `(skipped — Firecrawl not installed)` notes for the affected steps and degrade gracefully.

## What this enables

| Skill | What Firecrawl unlocks |
|---|---|
| `seo-page` | OG / Twitter / canonical / robots / JSON-LD recovery in `PAGE.md` "Page basics" |
| `seo-schema` | Real JSON-LD parse on the target URL + top-10 SERP competitors |
| `seo-geo` | `/llms.txt` + RSL discovery + JSON-LD-backed schema check |
| `seo-technical-audit` | JS-render canonical/noindex divergence, X-Robots-Tag, AI-crawler robots rules |
| `seo-sitemap` | Mode-2 URL discovery via `firecrawl_map` for sites with broken/missing sitemaps |
| `seo-content-audit` | Real Article schema + DOM byline (powers AI-content YMYL veto) |
| `seo-content-brief` | Top-3 SERP winners' real `<head>` for on-page benchmark |
| `seo-competitor-pages` | Bulk on-page-element extraction for the comparison-page CSV |
| `seo-sxo` | Optional rendered screenshots of top SERP winners |
| `seo-backlinks-profile` | Optional verification that backlink sources still link + with the expected `rel` |
| `seo-drift` | Full `<head>` + JSON-LD content in URL-mode snapshots |
| `seo-firecrawl` | Ad-hoc scrape / map / crawl / search interface |

## Requirements

- Node 20 or newer (`node -v`).
- `npx` (ships with npm).
- `python3` (used by the install script to merge `~/.claude/settings.json` safely).
- A Firecrawl API key from <https://firecrawl.dev>. Free tier is **500 credits/month**.

## Install

```bash
bash extensions/firecrawl/install.sh
```

The script:

1. Verifies Node 20+, `npx`, and `python3`.
2. Prompts for `FIRECRAWL_API_KEY` (or reads from your environment).
3. Adds `mcpServers.firecrawl-mcp = { command: "npx", args: ["-y", "firecrawl-mcp"], env: { FIRECRAWL_API_KEY } }` to `~/.claude/settings.json`. Existing `mcpServers` entries are preserved.
4. Pre-warms the npm package.
5. Prints the available tool names.

Restart Claude Code (or run `/mcp`) so the server registers. Verify with `/mcp` — `firecrawl-mcp` should appear as connected.

## Uninstall

```bash
bash extensions/firecrawl/uninstall.sh
```

Removes the `mcpServers.firecrawl-mcp` entry only. Other MCP servers are preserved.

## Free-tier credit math

A user on the 500-credit free tier can comfortably run:

- `seo-page` ~500 times (1 credit each).
- `seo-schema` ~50 times if step 7 (competitor benchmark) runs (11 credits each); ~500 times without step 7.
- `seo-geo` ~150 times (3 credits each).
- `seo-technical-audit` ~83 times (6 credits each).
- `seo-content-audit` ~10 full audits at the default 50-page cap (50 credits each).
- `seo-drift` URL baseline + monthly compare ~250 cycles (1 credit per snapshot).

Heavy operations (`seo-sitemap` Mode-2 on a 200-page site, `seo-content-audit` at hard cap 200, `seo-firecrawl` `crawl` mode) burn through fast — every Firecrawl-using skill surfaces credit estimates in step 1 so you can opt out (`--no-firecrawl`) when budget matters more than completeness.

## Tool prefix

After install, the tools are exposed as:

- `mcp__firecrawl-mcp__firecrawl_scrape`
- `mcp__firecrawl-mcp__firecrawl_map`
- `mcp__firecrawl-mcp__firecrawl_crawl`
- `mcp__firecrawl-mcp__firecrawl_check_crawl_status`
- `mcp__firecrawl-mcp__firecrawl_search`
- `mcp__firecrawl-mcp__firecrawl_extract` (skills don't use this)
- `mcp__firecrawl-mcp__firecrawl_deep_research` (skills don't use this)

If `/mcp` reports a different prefix on your install, the `seo-skills` SKILL.md references will silently mis-fire — open an issue at <https://github.com/seranking/seo-skills> with the actual prefix.

## Troubleshooting

- **`/mcp` doesn't show firecrawl-mcp:** restart Claude Code after `install.sh`. The settings file is read at session start.
- **`mcp__firecrawl-mcp__firecrawl_scrape` returns auth errors:** rerun `install.sh` and re-enter the API key. The previous one may have been revoked.
- **Free-tier credits exhausted:** every Firecrawl-using skill in `seo-skills` accepts `--no-firecrawl` to opt out and run in degraded mode. Or upgrade at <https://firecrawl.dev/pricing>.
- **Cloudflare / WAF blocking:** Firecrawl is up-front about target sites that block its scraper. The error surfaces cleanly in `seo-firecrawl` output; defeating WAFs is out of scope.

## License

MIT, same as the parent plugin.
