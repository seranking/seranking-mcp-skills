---
name: seo-firecrawl
description: Ad-hoc web scraping, site mapping, and full-site crawling via Firecrawl MCP. Returns raw HTML, parsed metadata (og:*, twitter:*, JSON-LD, canonical, robots), JS-rendered DOM, and screenshots that WebFetch cannot. Distinct from the SE Ranking skills (which give keyword/traffic/SERP data) and from WebFetch (which gives markdown prose only). Use when the user says "scrape this page", "crawl this site", "map this site", "find all pages on", "get the OG tags", "get the JSON-LD", "render this JS-heavy page", or any task where raw `<head>` metadata, structured-data scripts, or post-JS DOM are the actual deliverable. Also invoked as a sub-step from other skills that need raw HTML.
---

# Firecrawl Orchestrator

A direct interface to Firecrawl MCP for tasks that fall outside the data-driven SE Ranking skills. Use when:

- You need raw HTML, `<head>` metadata, JSON-LD, or post-JS DOM that WebFetch's markdown conversion strips.
- You need a list of all URLs on a domain without pulling each one.
- You need to crawl a site and audit each page's metadata.
- You need to search within a known domain.
- A higher-level skill (`seo-page`, `seo-schema`, `seo-content-audit`, etc.) called you as a sub-step.

## Prerequisites

- **Required:** the `firecrawl-mcp` MCP server. If `mcp__firecrawl-mcp__firecrawl_scrape` is unavailable, abort with the install command — `bash extensions/firecrawl/install.sh` from this plugin repo, plus the firecrawl.dev signup URL (free tier 500 credits/month). Don't attempt fallbacks; this skill exists for the cases WebFetch can't cover.
- User provides: a target URL or domain, plus optionally a mode (`scrape` / `map` / `crawl` / `search`). If mode unspecified, infer from input shape (single URL → `scrape`, single domain → `map`).

## Process

1. **Preflight.** Confirm `firecrawl-mcp` is connected. If not, surface the install command and stop.
2. **Mode selection.** Resolve user intent into one of:
   - `scrape` — single URL, full data (default if user supplies one URL).
   - `map` — single domain, list of URLs only (cheap reconnaissance).
   - `crawl` — single domain, fetch each discovered page (expensive; require explicit confirm).
   - `search` — query within a domain.
3. **Cost estimation + confirmation.**
   - `scrape` (1 credit), `map` (~0.5 credit per discovered URL — estimate using a `map` first if scope unclear), `crawl` (1 credit per page crawled), `search` (1 credit per result returned).
   - For `crawl` and for `map` of >50 expected URLs, surface the estimate and require explicit go-ahead before calling.
   - Always read remaining credits implicitly via Firecrawl's response metadata (`creditsUsed` / `creditsRemaining` in `metadata`).
4. **Execute.** Call the matching `mcp__firecrawl-mcp__firecrawl_*` tool.
   - `scrape`: pass `formats: ["markdown", "html"]` by default (markdown for prose, html for `<head>` + JSON-LD). Add `formats: ["screenshot"]` only if the deliverable visibly uses one. SPAs: pass `waitFor: 2000` (or a CSS selector) so the JS-rendered DOM is captured. Default `onlyMainContent: true` to drop nav/footer noise — override only on explicit request.
   - `map`: default `limit: 500` (hard cap). Pass `excludePaths: ["/admin/*", "/api/*", "/wp-admin/*", "/feed/*"]` as a sane default.
   - `crawl`: default `limit: 50` (default cap), hard cap `limit: 200`. Always pass `excludePaths` to prune. Poll `firecrawl_check_crawl_status` if the job returns asynchronously.
   - `search`: default `limit: 20`.
5. **Parse + structure output.** Don't dump the raw API response. Per-mode:
   - `scrape` → `RAW.md` (markdown body), `META.md` (og / twitter / canonical / robots / headers + parsed JSON-LD `@type` list with hashes), `links.csv`, optional `screenshot.png`.
   - `map` → `URLS.md` with pattern-grouped list (e.g., `/blog/* — 128 (37%)`, `/products/* — 84 (24%)`), plus `urls.csv`.
   - `crawl` → folder per page under `pages/{slugified-url}/` with `RAW.md` + `META.md`, plus a top-level `INDEX.md` summarising every page (URL, status, key signals).
   - `search` → `MATCHES.md` with hit excerpts + URLs ranked by relevance.
6. **Synthesise** `FIRECRAWL.md` at the root: target, mode, credits used, key findings (5 bullets max), open loops, recommended next skill.

## Output format

Folder `seo-firecrawl-{slug}-{YYYYMMDD}/`:

### Mode = scrape
```
seo-firecrawl-{slug}-{YYYYMMDD}/
├── RAW.md            (markdown body)
├── META.md           (og / twitter / canonical / robots / headers + parsed JSON-LD)
├── links.csv         (every <a href> on the page)
├── screenshot.png    (optional; only if requested)
└── FIRECRAWL.md      (synthesis + handoff payload)
```

### Mode = map
```
seo-firecrawl-{slug}-{YYYYMMDD}/
├── URLS.md           (pattern-grouped URL list)
├── urls.csv          (every URL with discovery depth, if available)
└── FIRECRAWL.md
```

### Mode = crawl
```
seo-firecrawl-{slug}-{YYYYMMDD}/
├── INDEX.md          (every page + status code + key signals)
├── pages/
│   ├── {slug-1}/RAW.md
│   ├── {slug-1}/META.md
│   ├── {slug-2}/RAW.md
│   └── ...
└── FIRECRAWL.md
```

### Mode = search
```
seo-firecrawl-{slug}-{YYYYMMDD}/
├── MATCHES.md        (hit excerpts + URLs ranked by relevance)
└── FIRECRAWL.md
```

`FIRECRAWL.md` follows this shape:

```markdown
# Firecrawl: {target}

> Run dated {YYYY-MM-DD} · Mode: {scrape | map | crawl | search} · Credits used: {n}

## Summary

{One-paragraph what-came-back. Example: "Scraped https://example.com/article. og:title and og:image present, JSON-LD Article schema with author + datePublished. 12 outbound links. Page is server-rendered (no JS-render divergence). Robots: index,follow."}

## Key findings

1. {Finding anchored in concrete data}
2. ...
5. ...

## Open loops

- {What this run did NOT answer}
- ...

## Recommended next step

{One of: `seo-page` (when a single URL was scraped and now wants performance analysis) | `seo-schema` (when JSON-LD audit needs follow-up generation) | `seo-technical-audit` (when crawl revealed broken pages) | `seo-content-audit` (when crawl produced a corpus to audit) | `seo-drift baseline` (when the user wants to track this URL over time) | "this completes the user's ask".}

## Handoff payload

- **Produced by:** seo-firecrawl
- **Target:** {url or domain}
- **Mode:** {scrape | map | crawl | search}
- **Credits used:** {n}
- **Key findings:** {5 bullets — e.g., "twitter:card present (summary_large_image)", "JSON-LD types: Article + Organization + BreadcrumbList", "robots: index,follow", "canonical self-referencing", "404s: 0 of 50 pages crawled"}
- **Open loops:** {what this didn't answer}
- **Recommended next skill:** {seo-page | seo-schema | seo-technical-audit | seo-content-audit | …} — {one-line why}
```

## Tips

- **Free tier 500 cr/month.** `map` is 0.5 cr/URL; `scrape` is 1 cr each; `crawl` 1 cr/page. Surface cost up front; warn when a single run will eat >100 credits.
- **Default `onlyMainContent: true`** for `scrape` to drop nav/footer noise. Override only if the user explicitly asks for full-page DOM.
- **Use `waitFor`** (CSS selector or ms) for SPAs that lazy-load content. 2000ms is a sensible default; selectors are more reliable than time waits.
- **`firecrawl_map` before `firecrawl_crawl`** when crawl scope is unclear — discover first, decide what to crawl, then crawl. Saves credits.
- **`includePaths` / `excludePaths`** dramatically cut crawl cost. Always pass `excludePaths: ["/admin/*", "/api/*", "/wp-admin/*", "/feed/*"]` as a default.
- **Don't request `formats: ["screenshot"]`** unless the deliverable visibly uses it. It doubles per-page cost.
- **Don't use `firecrawl_extract` or `firecrawl_deep_research`.** Both overlap with our own LLM analysis; `firecrawl_extract` has opaque pricing on the free tier; both are explicitly out of scope for `seo-skills`.
- **Cloudflare / anti-bot:** some sites (especially e-commerce, banking) block Firecrawl's scraper. Surface the error cleanly; defeating WAFs is not a goal of this skill.
- **Sub-step usage.** When invoked from another skill (`seo-page`, `seo-schema`, etc.), drop the `FIRECRAWL.md` synthesis — the caller wants the raw `META.md` / `RAW.md`. Skip mode-2's `URLS.md` summary too if the caller wants the raw `urls.csv`.
- **This is the entry point** when you need raw HTML and don't have a more specific skill in mind. If you do — `seo-page` for keyword/traffic verdicts on one URL, `seo-schema` for JSON-LD work, `seo-technical-audit` for crawl-wide issues — use those instead. They orchestrate Firecrawl plus SE Ranking data automatically.

## Works well with

- **Predecessors:** none (entry point) or invoked as a sub-step from another skill.
- **Successors:**
  - `seo-page` — when a single URL was scraped and now wants keyword/traffic verdicts.
  - `seo-schema` — when JSON-LD audit produced gaps that need generation.
  - `seo-technical-audit` — when a crawl revealed broken pages or noindex issues at scale.
  - `seo-content-audit` — when a crawl produced a corpus to E-E-A-T-audit.
  - `seo-drift baseline` — when the user wants to track this URL or domain over time.
