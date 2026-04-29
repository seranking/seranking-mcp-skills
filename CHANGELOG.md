# Changelog

All notable changes to this project will be documented in this file. Format based on Keep a Changelog.

## [2.5.1] — 2026-04-29

Adds a top-level `install.sh` so the cold-start install path is a single command, and clarifies the README's split between marketplace install (skills only — sufficient for 21 of 22 skills) and manual install (required for `seo-google` and the Firecrawl extension). Surfaced by a sharp question: the v2.5.0 walkthrough told users to `bash extensions/.../install.sh` without ever telling them to clone the repo first.

### Added
- **`install.sh`** at repo root. Detects whether it's running from inside a clone vs needing to clone (default target `~/.local/share/seo-skills`, override via `--target`). Verifies `git`, `python3` 3.10+. Runs the chosen extension installers. Interactive when stdin is a TTY (asks Y/N for Firecrawl + Google); non-interactive when piped (skips extensions unless `--firecrawl` / `--google` / `--all` is passed). Reads prompts from `/dev/tty` so `curl ... | bash` works under a real terminal. Idempotent (re-running pulls latest + re-runs requested extensions).
- README "Option 2: Manual install (required for `seo-google` and the Firecrawl extension)" section. Shows the `git clone + bash install.sh` form and a `<details>`-collapsed curl one-liner: `curl -fsSL .../install.sh | bash -s -- --all`. Mirrors the [`AgriciDaniel/claude-seo`](https://github.com/AgriciDaniel/claude-seo) install pattern.
- README install-path TL;DR table at the top of the Install section: marketplace install for SKILL.md-only skills, manual install for `seo-google` + extensions, both for users who want everything.

### Changed
- README install options renumbered: Cowork moved to Option 3 (was 2), Local plugin development to Option 4 (was 3), Copy individual skills to Option 5 (was 4), Project-scoped to Option 6 (was 5), Claude API to Option 7 (was 6). The new Option 2 slots in just after the marketplace install.
- README "Optional extensions" intro now points to the top-level `install.sh` as the fastest path; per-extension scripts remain documented for one-off installs.
- README repo-layout block now lists `install.sh` at the root.
- All three version strings bumped to 2.5.1.

### Why this is a 2.5.1 (not 2.6.0)
Pure docs + install ergonomics. No skill behavior changes, no new APIs, no config-shape changes. Existing users on 2.5.0 are unaffected unless they re-run the installer, which is idempotent.

## [2.5.0] — 2026-04-29

Adds `seo-google` — direct access to Google's own SEO data (GSC Search Analytics + URL Inspection + Sitemaps, PageSpeed Insights v5, CrUX field data + 25-week history, Indexing API v3, GA4 Data API, YouTube Data v3, Cloud Natural Language, Knowledge Graph Search, Web Risk, Google Ads Keyword Planner) plus a PDF/HTML/XLSX report generator. This is the catalogue's first Python-script skill — earlier skills are SKILL.md only.

**Adapted with attribution from [`AgriciDaniel/claude-seo`](https://github.com/AgriciDaniel/claude-seo) v1.9.6 (MIT).** All 11 Python scripts (`scripts/google_*.py`, `scripts/pagespeed_check.py`, `scripts/crux_history.py`, `scripts/gsc_*.py`, `scripts/indexing_notify.py`, `scripts/ga4_report.py`, `scripts/youtube_search.py`, `scripts/nlp_analyze.py`, `scripts/keyword_planner.py`, `scripts/google_report.py`), all 10 reference docs under `skills/seo-google/references/`, and 3 report templates under `skills/seo-google/assets/templates/` are forked verbatim. Two minimal adaptations only: (a) config path `~/.config/claude-seo/` → `~/.config/seo-skills/` for clean coexistence with the upstream plugin, (b) example service-account name `claude-seo` → `seo-skills` in `auth-setup.md`. Functional behaviour is otherwise unchanged. Upstream MIT copyright is preserved at `extensions/google/LICENSE-AgriciDaniel.txt`.

### Added
- **`skills/seo-google/SKILL.md`** — 21-command router. Subcommands: `setup`, `pagespeed`, `crux`, `crux-history`, `gsc`, `inspect`, `inspect-batch`, `sitemaps`, `index`, `index-batch`, `ga4`, `ga4-pages`, `youtube`, `youtube-video`, `nlp`, `entities`, `keywords`, `volume`, `entity`, `safety`, `quotas`, `report`. Each command shells out to a Python script with `--json` output.
- **`skills/seo-google/references/`** — 10 reference docs: `auth-setup.md` (8-step Google Cloud project setup walkthrough), `search-console-api.md`, `pagespeed-crux-api.md`, `ga4-data-api.md`, `indexing-api.md`, `keyword-planner-api.md`, `nlp-api.md`, `supplementary-apis.md` (Knowledge Graph + Web Risk), `youtube-api.md`, `rate-limits-quotas.md`.
- **`skills/seo-google/assets/templates/`** — 3 report templates: `cwv-audit-report.md`, `gsc-performance-report.md`, `indexation-status-report.md`.
- **`scripts/`** — new repo-root directory with 11 Python scripts (~235KB total).
- **`extensions/google/install.sh`** — pip-installs Google API libraries (`google-api-python-client`, `google-auth*`, `google-analytics-data`, `requests`) plus optional report libraries (`matplotlib`, `weasyprint`, `openpyxl`). Creates `~/.config/seo-skills/` (700) with a stub `google-api.json` (600) the user fills in. Runs the credential checker. Idempotent.
- **`extensions/google/uninstall.sh`** — removes config + token; preserves user's service-account JSON files and pip libraries (with instructions to remove them manually).
- **`extensions/google/README.md`** — full setup, troubleshooting, rate-limit table, credential-tier reference.
- **`extensions/google/LICENSE-AgriciDaniel.txt`** — preserves upstream MIT copyright per license requirement.
- README skills table extended to 22 rows (`seo-google` row, marked extension-required).
- README "Optional extensions" section gains "Google APIs" subsection with install command, tier model, and link to the extension README.
- README repo-layout block updated to show `scripts/`, `extensions/google/`, and the new `references/` + `assets/templates/` under `seo-google/`.
- Prerequisites bullet calling out the optional Google APIs extension.

### Credential tiers (key design borrowed from upstream)
- **Tier 0** (API key only): `pagespeed`, `crux`, `crux-history`, `youtube`, `youtube-video`, `nlp`, `entities`, `entity`, `safety`.
- **Tier 1** (+ service account, added as Full to GSC): adds `gsc`, `inspect`, `inspect-batch`, `sitemaps`, `index`, `index-batch`.
- **Tier 2** (+ GA4 property ID, service account added as Viewer): adds `ga4`, `ga4-pages`.
- **Tier 3** (+ Google Ads developer token + customer ID): adds `keywords`, `volume`.
Each tier is independently useful — Tier 0 alone unlocks real CWV field data via PSI + CrUX.

### Cross-skill upgrades enabled by `seo-google`
When `seo-google` is configured at the appropriate tier, several existing skills can swap *estimates* for *measurements*:
- **`seo-page`** — replace SE Ranking traffic estimate with real GSC `query,page` impressions/clicks (Tier 1); confirm indexation via URL Inspection (Tier 1).
- **`seo-drift`** — add 25-week CrUX history trend (Tier 0) and GSC delta tracking (Tier 1) to baseline/compare snapshots.
- **`seo-technical-audit`** — real CWV field data via PSI + CrUX (Tier 0); real indexation status via URL Inspection (Tier 1).
- **`seo-content-audit`** — NLP entity/sentiment analysis enhances E-E-A-T scoring (Tier 0); GSC confirms whether the page is earning impressions for its target keywords (Tier 1).
- **`seo-sitemap`** — GSC sitemap status shows which sitemaps Google has actually consumed and their error/warning counts (Tier 1).
- **`seo-geo`** — GSC `dimensions=searchAppearance` includes AI Overview impressions (Tier 1).
- **`seo-keyword-cluster`** / **`seo-keyword-niche`** — gold-standard Keyword Planner volumes (Tier 3) replace SE Ranking estimates when configured.
- **`seo-plan`** — Phase-1 baseline uses real impressions/clicks/conversions (Tier 1+2) instead of estimates.
These integrations are wired in the `seo-google` SKILL.md's "Cross-Skill Integration" section and `extensions/google/README.md`. The existing skills do not yet auto-detect Google credentials and prefer real data when present — that is a separate v1.5-track follow-up.

### Architectural notes
- First skill in the catalogue with bundled Python scripts (`scripts/` at repo root). All earlier skills were SKILL.md only and called MCP tools. The new pattern is documented in the repo-layout README block.
- Scripts use sibling-import style (`from google_auth import ...`) with try/except for path resolution — same pattern as upstream. Works whether the assistant invokes `python scripts/<name>.py` from the plugin root or via an absolute path.
- Two-extension pattern now established: `extensions/firecrawl/` (MCP server wiring) + `extensions/google/` (pip + config wiring). Future extensions can pick whichever fits.

### Deferred
- Wiring real-data preferences into the existing skills (e.g., `seo-page` auto-detecting GSC and using it instead of SE Ranking traffic estimates). Currently the cross-skill integrations exist as documented patterns in `seo-google`'s own SKILL.md, not as auto-detection in the consumer skills. Tracking for v2.6 / v3.0.
- Smoke-test on a clean profile install. The pip install path is well-trodden, but `weasyprint` system-dep fallout (cairo/pango on Linux, Xcode CLT on macOS) is the most likely real-world snag.

### Changed
- All three version strings bumped to 2.5.0.

## [2.4.0] — 2026-04-29

Adds `seo-plan` — the strategic-roadmap layer above the existing 20-skill catalogue. Surfaced by the 2026-04-28 head-to-head against `AgriciDaniel/claude-seo` v1.9.6, which had a `seo-plan` we lacked. This skill does not replace specialist skills — it composes their outputs into a phased site-level plan with sequencing, owners, metrics, and a critical path.

### Added
- **`skills/seo-plan/SKILL.md`** — phased SEO roadmap for a domain. Inputs: target domain (+ optional country, business type, planning horizon, constraints). Process: detect business type from homepage signals → baseline domain via `DATA_getDomainOverviewWorldwide` + history + DA + backlinks → competitive frame via `DATA_getDomainCompetitors` → ingest specialist-skill outputs (`seo-technical-audit`, `seo-content-audit`, `seo-competitor-gap-analysis`, `seo-ai-search-share-of-voice`, `seo-backlinks-profile`); if missing, queue them as Phase 0 → score four pillars (technical / content / topical / AI Search) → apply business-type template (saas / ecommerce / local / publisher / agency / b2b-services) → phase the plan into Foundations → Build → Compound+measure → pick metrics (one leading + one lagging per phase) → emit a critical-path dependency map. Output: `PLAN.md` + 8 numbered raw-data files. Deliberately distinct from `seo-keyword-cluster` (keyword architecture for one topic), `seo-content-brief` (one article), and `seo-keyword-niche` (longtail content tier).
- README skills table extended to 21 rows.
- README repo-layout block updated to show the new `seo-plan/` folder.

### Known scope gaps surfaced by `seo-plan` (deferred)
The skill explicitly flags two business-type templates with thin coverage in the current catalogue. These are not blockers — `seo-plan` degrades by recommending manual sub-steps — but they're real gaps worth tracking:
- **`local` template** — no `seo-local` skill exists yet (GBP optimisation, NAP consistency, citations, location pages, multi-location). `seo-plan` flags Phase 0 manual GBP audit when business type is `local`.
- **`ecommerce` template** — partial coverage. `seo-ads` reaches the Shopping pack via SERP-feature filters but does not cover Amazon marketplace, Merchant API data, product schema validation depth, or competitor pricing. A dedicated `seo-ecommerce` skill is the obvious follow-up if demand surfaces.

### Changed
- All three version strings bumped to 2.4.0.

## [2.3.1] — 2026-04-27

Documentation patch surfacing v2.3.0's Firecrawl integration in the README.

### Added
- `seo-firecrawl` row in the README skills table (marked as extension-required, anchor-linked to the new section).
- New "Optional extensions" section between "Install" and "How these skills work" — Firecrawl install command, what it unlocks, free-tier credit math, and links to the extension's own README.
- Prerequisites bullet calling out the optional Firecrawl extension.
- `extensions/firecrawl/` and `skills/seo-firecrawl/` entries in the Repository layout tree.

### Fixed
- README's `seo-schema` row no longer lists "HowTo" among bundled templates — the template was removed in v2.1.0 (Google retired HowTo rich results in September 2023). Count corrected from "Six" to "Five".

### Changed
- All three version strings bumped to 2.3.1.

## [2.3.0] — 2026-04-27

Completes the Firecrawl integration started in v2.2.0. Ships the install scaffold, the `seo-firecrawl` orchestrator skill, and four v1.5-track skill patches (`seo-content-brief`, `seo-competitor-pages`, `seo-sxo`, `seo-backlinks-profile`). Together with v2.2.0, every skill that genuinely benefits from Firecrawl is wired up — and the install path now actually ships in the plugin.

### Added
- **`extensions/firecrawl/`** install scaffold (`install.sh`, `uninstall.sh`, `README.md`) per plan §4. `install.sh` checks Node 20+/npx/python3, prompts for `FIRECRAWL_API_KEY`, idempotently merges `mcpServers.firecrawl-mcp` into `~/.claude/settings.json` via a Python step that preserves existing entries, pre-warms the npm package, prints the available tools. `uninstall.sh` removes the entry only. `README.md` is a one-page setup + free-tier credit math + tool-prefix reference + troubleshooting.
- **`skills/seo-firecrawl/SKILL.md`** — ad-hoc orchestrator skill per plan §7. Modes: `scrape` (single URL), `map` (domain → URL list), `crawl` (domain → all pages), `search` (within a domain). Cost-confirmation gates for `crawl` and large `map` runs. Per-mode output folders (`RAW.md` + `META.md` + `links.csv` for scrape, `URLS.md` + `urls.csv` for map, `INDEX.md` + per-page folders for crawl, `MATCHES.md` for search). Handoff payload routes follow-up to `seo-page` / `seo-schema` / `seo-technical-audit` / `seo-content-audit` / `seo-drift baseline`.

### Fixed (v1.5 broken claims — same WebFetch markdown problem as v2.2.0)
- **`seo-competitor-pages`** step 5 — claimed to extract "schema types" from WebFetch markdown. Fixed: WebFetch handles H2 outline / feature-matrix / CTA prose; Firecrawl recovers schema types + og:* / twitter:* on top-3 SERP winners. Schema generation in step 8 now falls back to a default `Product + BreadcrumbList + FAQPage` template when Firecrawl is absent rather than mirroring inference-from-markdown guesses.
- **`seo-sxo`** step 4 — claimed to extract "schema types" from WebFetch markdown. Fixed: WebFetch handles prose / H-tags / content-structure; Firecrawl recovers JSON-LD `@type`s per page, which are load-bearing for the page-type classification heuristic in step 5. Without Firecrawl the heuristic falls back to URL/title patterns + content-structure heuristics only — confidence drop noted in `02-page-type-classification.md`.

### Added (v1.5 — Firecrawl enhancements, opt-in or default-on graceful degrade)
- **`seo-content-brief`** step 6 — Firecrawl scrape on top-3 SERP winners (3 credits) recovers real `<title>` length, meta-description length, og:*, twitter:*, JSON-LD `@type`s, DOM byline structure, hero-image presence, table/code-block counts. New "Top 3 winners — on-page benchmark" table in `BRIEF.md` so the writer matches what's actually shipping in the SERP.
- **`seo-competitor-pages`** new step 5b — opt-in `--bulk-scrape <urls>` mode. Firecrawl-scrape each user-supplied competitor URL; emit `competitor-elements.csv` with title / og / twitter / JSON-LD / pricing-block / CTA-count / comparison-table / free-tier-mention columns. 1 Firecrawl credit per URL; refuses >50 without `--confirm-cost`.
- **`seo-sxo`** step 4 — opt-in `--screenshots` flag. Firecrawl scrape with `formats: ["screenshot"]` on candidate + top 3 winners (4 extra credits). Saved as `screenshots/{page}.png`. Wireframe in step 8 can reference the visual layout, not just text outline.
- **`seo-backlinks-profile`** new step 8b — opt-in `--verify-sources` flag. Firecrawl-scrape the highest-authority linking page per top-20 referring domain (20 credits). Verifies (a) link still present, (b) `rel` attribute (`dofollow` / `nofollow` / `sponsored` / `ugc`), (c) source page status. Mismatches against SE Ranking's reported state surface in `08b-source-verification.md` and feed step 9's toxic-candidate detection. Default off — keeps the "Single-source by design" framing intact unless the user opts in.

### Cost surfacing — new in v2.3.0
v2.2.0's cost table covers `seo-page` / `seo-schema` / `seo-geo` / `seo-technical-audit` / `seo-sitemap` / `seo-content-audit` / `seo-drift`. Added in v2.3.0:

| Skill | Firecrawl credits per run |
|---|---|
| `seo-content-brief` | 3 (top-3 SERP winners scrape) |
| `seo-competitor-pages` | 3 baseline + 1 per URL in `--bulk-scrape` (refuses >50 without `--confirm-cost`) |
| `seo-sxo` | 4 baseline + 4 if `--screenshots` |
| `seo-backlinks-profile` | 20 if `--verify-sources` (default off) |
| `seo-firecrawl` | user-driven; warn at >100, refuse >500 without `--confirm-cost` |

Every Firecrawl-using skill supports `--no-firecrawl` to opt out and run in degraded mode.

### Critical pre-ship check (still required before broad release)
Plan §10 risk: tool prefix `mcp__firecrawl-mcp__firecrawl_*` must be verified on a clean profile install. Run `bash extensions/firecrawl/install.sh`, then `/mcp` in Claude Code, confirm the registered prefix matches. If it differs, every reference in the 11 Firecrawl-using skills silently mis-fires.

### Changed
- All three version strings bumped to 2.3.0.

## [2.2.0] — 2026-04-27

Firecrawl integration ships across 7 skills, closing the "WebFetch can't see the `<head>`" correctness gap that v2.1.0 explicitly deferred. Each affected skill now uses `mcp__firecrawl-mcp__firecrawl_scrape` (or `firecrawl_map`) to recover `og:*`, `twitter:*`, canonical, robots, JSON-LD, and X-Robots-Tag content that WebFetch's markdown conversion strips. Firecrawl is treated as an optional enhancement: every Firecrawl-using step degrades gracefully — emitting an explicit `(skipped — Firecrawl not installed)` note in the deliverable — rather than failing the run.

**Install path (separate concern).** This release wires up the skills but does **not** ship the `extensions/firecrawl/` install scaffold or the `seo-firecrawl` orchestrator skill — both are referenced in degradation notes and arrive in a follow-up release. Users wanting Firecrawl today install it manually: export `FIRECRAWL_API_KEY` and add `mcpServers.firecrawl-mcp = { command: "npx", args: ["-y", "firecrawl-mcp"] }` to `~/.claude/settings.json`. Free tier is 500 credits/month.

### Fixed (correctness — claims WebFetch couldn't deliver)
- **`seo-page`** step 6 — claimed to extract canonical, robots, and JSON-LD via WebFetch. WebFetch returns markdown and strips all three. Fixed: WebFetch handles `<title>`/headings/prose; Firecrawl recovers `<head>` metadata + JSON-LD. New "Page basics" section in `PAGE.md` lists og/twitter/canonical/robots/JSON-LD types/hreflang count. KILL-verdict heuristic hardens when JSON-LD is also absent.
- **`seo-schema`** steps 1-2 — claimed to "Pull the page's HTML" via WebFetch and "Extract every `<script type='application/ld+json'>` block". Both impossible. Fixed: Firecrawl is now the primary fetch path; without it the skill becomes generate-only (steps 4-6) and skips detect/validate (2-3, 7) with explicit notice rather than producing markdown-inferred guesses.
- **`seo-schema`** step 7 — competitor benchmark "WebFetch their HTML, detect their schema types" was inferring from markdown. Fixed: Firecrawl scrape on top-10 SERP results, real JSON-LD parse, "schema types used by 6+ winners that this page is missing" emitted only when benchmark actually ran.
- **`seo-geo`** step 7 — "Re-parse the page's JSON-LD" had nothing to parse (step 5's WebFetch returned markdown). Fixed: Firecrawl scrape feeds the schema check; falls back to explicit `skipped — Firecrawl required` note rather than silently passing.
- **`seo-content-audit`** step 1 — claimed to extract schema types from WebFetch markdown. Fixed: Firecrawl recovers Article/BlogPosting/Person schema and the structural byline DOM. Veto check #4 (AI-on-YMYL with no human review) gains high-confidence inputs when Firecrawl is available and falls back to lower-confidence prose-only inspection without it (caveat surfaced in `VERDICT.md`).

### Added (Firecrawl-only capabilities)
- **`seo-geo`** new step 8 — `/llms.txt` and `/.well-known/rsl.json` (with `/RSL.txt` fallback) discovery via Firecrawl. New `07-ai-protocol-files.md` output and "AI-protocol files" section in `GEO.md` summarizing the domain's stance toward LLM training/citation.
- **`seo-technical-audit`** new step 8 — "Modern signals checklist". For 5 sample URLs from the SE Ranking audit, Firecrawl scrape detects (a) JS-rendered canonical vs initial-HTML canonical divergence, (b) JS-injected noindex, (c) X-Robots-Tag header. Plus one extra `firecrawl_scrape` on `/robots.txt` parses AI-crawler User-Agent rules — `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`, `ChatGPT-User`, `Bytespider`, `CCBot`. New `05-modern-signals.md` output and "Modern signals" subsection in `TECH-AUDIT.md`. SE Ranking's audit crawler can't see any of this.
- **`seo-sitemap`** Mode-2 — when no XML sitemap is reachable, or it returns < 10% of the audit's crawled-page count, or the user passes `--discover`, `firecrawl_map(limit=500)` enumerates URLs from the homepage + internal navigation. The four diffs (missing/orphans/broken/lastmod) run identically with discovered URLs substituting for declared sitemap URLs. New `01b-firecrawl-discovered.md` output. New "Mode" section in `SITEMAP.md` documents which mode ran.
- **`seo-drift`** URL-mode snapshots — Firecrawl captures `<head>` (canonical, robots, og:*, twitter:*) plus full JSON-LD content alongside the WebFetch markdown. Compare-mode diffs now detect schema additions/removals, canonical changes, robots-meta changes — none of which WebFetch could see. Without Firecrawl, those fields surface as `not comparable — Firecrawl-only fields missing from {baseline | current} snapshot` rather than as a green-pass. `--no-firecrawl` flag opts out for credit conservation.

### Cost surfacing
Every patched skill's preflight (step 1) surfaces estimated Firecrawl credit cost alongside `DATA_getCreditBalance`. Per-run estimates:

| Skill | Firecrawl credits per run |
|---|---|
| `seo-page` | 1 (target URL) |
| `seo-schema` | 1 + 10 if step 7 runs (top-10 SERP scrape) |
| `seo-geo` | 3 (target JSON-LD + `/llms.txt` + RSL) |
| `seo-technical-audit` | ~6 (5 sample URLs + `/robots.txt`) |
| `seo-sitemap` Mode-2 | ~50 typical, hard cap 250 |
| `seo-content-audit` | 1 per URL audited (default cap 50, hard cap 200) |
| `seo-drift` URL mode | 1 per snapshot capture |

### Deferred (planned follow-up)
- **`extensions/firecrawl/`** install scaffold (`install.sh`, `uninstall.sh`, `README.md`) — referenced in degradation notes; not shipped this release.
- **`seo-firecrawl`** orchestrator skill — ad-hoc scrape/map/crawl/search interface; ships alongside the install scaffold.
- **v1.5-track integrations** (per `docs/FIRECRAWL_INTEGRATION_PLAN.md` §6 v1.5) — `seo-content-brief` top-3 winners scrape, `seo-competitor-pages` bulk on-page CSV, `seo-sxo` screenshot mode, `seo-backlinks-profile` link-source verification.
- **Tool-prefix smoke test** — must run on a clean profile before broad release. Plan §10 risk: if the registered prefix differs from `mcp__firecrawl-mcp__firecrawl_*`, every reference in the 7 patched skills silently mis-fires.

### Changed
- All three version strings bumped to 2.2.0.

## [2.1.0] — 2026-04-27

Correctness pass — eight evidence-driven patches surfaced by the 2026-04-27 head-to-head against `AgriciDaniel/claude-seo` v1.9.6. No new dependencies; no Firecrawl yet (that ships in v2.2.0). Strictly better signal-to-noise across eight skills.

### Changed (correctness)
- **`seo-schema`** — removed HowTo from the active templates list; deleted `templates/how-to.json`. Google retired HowTo rich results in September 2023 (mobile + desktop); the skill no longer treats HowTo as a live option. SKILL.md description and step 5 updated; the deprecated entry remains documented in `references/google-rich-results.md` to explain *why* it's gone.
- **`seo-schema`** — `references/google-rich-results.md` now leads with a Type-lifecycle table (Active / Restricted / Deprecated with effective dates) covering Article/Product/LocalBusiness/BreadcrumbList/Video/Recipe/Event/JobPosting/Course/Movie/Organization/WebSite as Active; FAQPage and Q&APage as Restricted (gov/health since 2023-08); HowTo as Deprecated (2023-09); Sitelinks Search Box as Deprecated (2024-11). The HowTo subsection is rewritten as deprecated guidance.
- **`seo-content-audit`** — added an 8-item AI-content markers subsection in `references/core-eeat.md` (per the 2025-09 SQRG update) and a 4th veto in SKILL.md step 4: AI-generated YMYL content with no human-review markers. The veto fires only when ≥4 markers are present *and* the topic is YMYL *and* the page lacks all of: editor byline, "reviewed by" credit, "last reviewed"/"fact-checked on" date. AI assistance remains fine; the veto guards the YMYL accountability surface. `templates/verdict.md` updated with the new veto row.
- **`seo-sitemap`** — explicit note that `<priority>` and `<changefreq>` are ignored by Google (per Google's own sitemap docs). The skill no longer validates them; if present, they're flagged as low-signal noise the user can strip. `<lastmod>` remains validated — it's the only optional tag Google still consumes.
- **`seo-keyword-niche`** — new "Programmatic publishing — extra gates" subsection (step 9a) for tiers shipping 50+ pages: per-row uniqueness threshold (≥30% varying fields), min unique-fact count vs parent + sibling (≥5 facts), data-source independence (≥2 sources), index-bloat circuit-breaker (pause if GSC indexes <60% of submitted), crawl-budget honesty for sites >50k pages. Output `KEYWORD-NICHE-PLAN.md` template gates extended (rows 6–9).
- **`seo-backlinks-profile`** — added a "Single-source by design" framing section explaining the deliberate choice to consult only the SE Ranking backlink index (no Ahrefs/Moz/Majestic/DFS/Common Crawl blending). Internally consistent metrics + reproducible health scores are the trade-off; users needing multi-source confirmation are pointed to a manual cross-check rather than a faked blended report.
- **`seo-sxo`** — step 2 now surfaces a `mode=full` (default, `result_type=advanced`, ~750–900 cr/run) vs `mode=lite` (`result_type=standard`, ~80–150 cr/run) trade-off up front. `result_type=advanced` is required for AIO/PAA/pack data; `mode=lite` skips SERP-features and labels them in the output rather than reconstructing them from organic. Tips updated with concrete per-mode cost ranges.
- **`seo-page`** — replaced the cannibalization step. Was: cross-check via parent-domain `DATA_getDomainKeywords` (heavy on large sites). Now: dedicated step 8 using `DATA_getDomainPages` ranked by traffic, capped at top 50 peers, scanning for any peer URL ranking ≤20 for the candidate's top-3 traffic-weighted keywords. New `06-cannibalization.md` output file and a "Same-domain cannibalization" section in `PAGE.md`. CONSOLIDATE verdict heuristic rewritten to anchor on the new signal.

### Changed
- All three version strings bumped to 2.1.0.

## [2.0.0] — 2026-04-27

Repository rebrand for discoverability. The plugin is now `seo-skills` and the README leads with "Claude SEO Skills"; SE Ranking branding stays in the org (`seranking/seo-skills`), descriptions, and the underlying MCP context.

### Changed (breaking)
- **Plugin renamed** `seranking-mcp-skills` → `seo-skills`. Slash-command namespace flips from `/seranking-mcp-skills:seo-*` to `/seo-skills:seo-*`. Marketplace install command becomes `/plugin marketplace add seranking/seo-skills` and `/plugin install seo-skills@seranking`.
- **GitHub repo renamed** `seranking/seranking-mcp-skills` → `seranking/seo-skills`. GitHub auto-redirects the old URL for clones, links, and the marketplace registry, but anyone with the old slug hardcoded outside redirect-aware tooling should update.
- **README H1** `# SE Ranking MCP Skills` → `# Claude SEO Skills`. Lead paragraph repositioned around "Claude Agent Skills for SEO".
- **GitHub topics** added (previously empty): `claude`, `claude-code`, `claude-skills`, `anthropic`, `agent-skills`, `mcp`, `mcp-server`, `seo`, `seo-tools`, `seranking`.
- **GitHub description** rewritten to lead with the target query.
- All three version strings bumped to 2.0.0.

## [1.0.1] — 2026-04-27

Validation-driven patch. A v1.0.0 smoke test against the live SE Ranking MCP turned up four issues; this release fixes them.

### Fixed
- **`seo-ads`** — removed all `DATA_getAdsStats` references (the tool does not exist in the SE Ranking MCP). Step 7 re-scoped to "paid-keyword gap" using `DATA_getDomainKeywords` with the `type: 'adv'` enum switch (the documented way to access ads data on shared DATA_* tools). Output folder updated: `06-project-stats.md` → `06-paid-keyword-gap.md`. Prerequisites no longer mention project-namespace endpoints (DATA-only scope).
- **`seo-ads`** — Step 5 now explicitly names the SERP-feature filters (`tads`, `bads`, `sads`, `mads`) for ad-pack detection on `DATA_getSerpResults`.
- **`seo-page`** — added Tips entry covering the `DATA_getPageAuthorityHistory` all-zeros case (validation found that very high-authority URLs like Wikipedia paradoxically return flat-zero history). Skill now flags as "insufficient history" rather than synthesising a misleading trajectory.
- **`seo-drift`** — added the same all-zeros caveat for both `DATA_getPageAuthorityHistory` (URL mode) and `DATA_getDomainAuthorityHistory` (domain mode).
- **Manifests** — `marketplace.json` `plugins[0].description` and `plugin.json` `description` no longer say "Seven production SEO workflows" / list the original 7 deliverables. Both now describe the v1.0 19-skill scope abstractly (no count, no fixed list — won't drift again).

### Changed
- All three version strings bumped to 1.0.1.

## [1.0.0] — 2026-04-27

First production release. The catalogue covers **19 SEO skills** across keyword research, content briefing, page intelligence, technical and content audits, structured data, drift monitoring, SXO diagnostics, competitive analysis, paid search, AI-search optimization, sitemap analysis, subdomain mapping, and content opportunity mining — all powered by the [SE Ranking remote MCP](https://seranking.com/api/integrations/mcp).

### Added
- `CONTRIBUTING.md` at repo root with skill-authoring template, required structure, MCP tool conventions, and PR checklist.
- README finalised for v1.0 maturity.

### Changed
- All three version strings bumped to 1.0.0.

### Future work (planned for v1.x patch releases)
- **Frontmatter upgrade:** add `allowed-tools` and `when_to_use` to all 19 skills to eliminate mid-run permission prompts and improve trigger precision.
- **Handoff contract:** add `## Handoff` and `## Works well with` sections to every skill so chains across skills are explicit (catalog-specific convention).
- **Folder taxonomy:** group skills by stage in subdirs declared via the manifest's `skills` field (research / build / optimize / monitor / audit / competitive).
- **Examples:** add real, end-to-end runs for the most-requested skills (priority: `seo-page`, `seo-content-brief`, `seo-drift`, `seo-sxo`, `seo-technical-audit`).
- **Lint workflow:** GitHub Actions to validate `SKILL.md` frontmatter and MCP tool name accuracy on PRs.
- **`.mcp.json` decision:** decide whether to bundle the SE Ranking MCP via plugin-bundled `.mcp.json` (one-step install but tool-prefix changes) or keep external (no breaking change).

### Catalogue summary at v1.0.0

The 19 skills:

1. `seo-content-brief` — writer-ready brief from a domain + topic
2. `seo-ai-search-share-of-voice` — domain-level brand vs brand visibility across AI engines
3. `seo-backlink-gap` — domains linking to competitors but not to you
4. `seo-keyword-cluster` — content cluster plan (pillar + spokes architecture)
5. `seo-competitor-gap-analysis` — keywords competitors rank for that you don't
6. `seo-agency-landing-page` — demand-gen landing page for an SEO agency
7. `seo-page` — URL-level keyword & traffic intelligence with verdict
8. `seo-schema` — JSON-LD detect, validate, generate (6 templates)
9. `seo-drift` — git for SEO: baseline / compare / history
10. `seo-sxo` — read SERPs backwards to find page-type mismatches
11. `seo-technical-audit` — focused one-shot technical audit
12. `seo-content-audit` — E-E-A-T (60) + CITE (30) rubric for existing content
13. `seo-sitemap` — sitemap vs audit diff
14. `seo-competitor-pages` — "X vs Y" / "alternatives to X" page generator
15. `seo-backlinks-profile` — full backlink profile with toxic-candidate flagging
16. `seo-subdomain` — subdomain ownership map with cannibalization flags
17. `seo-geo` — URL-level Generative Engine Optimization
18. `seo-ads` — paid-search competitive intelligence
19. `seo-keyword-niche` — longtail + question keyword content opportunity mining

## [0.7.0] — 2026-04-27

### Added
- **`seo-geo`** — URL-level Generative Engine Optimization. Pulls per-keyword AIO presence and citation lists, audits page passages for citability, compares vs cited sources, surfaces page-level changes that improve LLM citation rates. Distinct from `seo-ai-search-share-of-voice` (domain-level brand vs brand) — this is one URL, deeper.
- **`seo-ads`** — Paid-search competitive intelligence. Two modes (domain mode for a brand's paid footprint, keyword mode for the bidding landscape on a single term). Uses `DATA_getDomainAdsByDomain` / `DATA_getDomainAdsByKeyword`, ad-copy clustering, SERP shopping/ad-pack visibility, optional project-level enrichment via `DATA_getAdsStats`. Output includes a recommended bid-keyword shortlist.
- **`seo-keyword-niche`** — Mine longtail + question keywords for niche content opportunities. Pulls `DATA_getLongTailKeywords` + `DATA_getKeywordQuestions` + related/similar at depth, clusters by intent, proposes a content tier (template, URL pattern, sample pages) with anti-thin-content quality gates. Pilot-first recommendation — 10 well-templated pages beat 1000 thin ones.

### Changed
- README skills table extended to 19 rows. **All 13 new skills now in place — every skill on the v0.4 → v0.7 build-out plan is implemented.**
- All three version strings bumped to 0.7.0.

## [0.6.0] — 2026-04-27

### Added
- **`seo-competitor-pages`** — Generate "X vs Y", "alternatives to X", and "best X for Y" landing pages targeting comparative-intent keywords. Pulls competitor data, comparative SERPs, top 3 SERP-winner page structures (via WebFetch). Produces a balanced page draft with feature matrix, PAA-derived FAQ, and paste-ready Product/Breadcrumb/FAQPage schema.
- **`seo-backlinks-profile`** — Full backlink profile (broader than `seo-backlink-gap`'s gap-only scope). Authority distribution, anchor classification, IP/subnet diversity, growth/decay trend, toxic-candidate heuristic. Output includes a 100-point profile health score and a reviewable disavow-candidate list (never auto-disavow).
- **`seo-subdomain`** — Subdomain ownership map. Uses `DATA_getDomainSubdomains` plus per-subdomain queries (overview, top keywords, competitors, backlinks). Surfaces topic-ownership matrix and cannibalization flags. Recommends consolidate / split / leave-alone with risk notes.

### Changed
- README skills table extended to 16 rows; repo-layout block updated.
- All three version strings bumped to 0.6.0.

## [0.5.0] — 2026-04-27

### Added
- **`seo-technical-audit`** — focused one-shot technical audit. Crawlability, indexability, security, mobile, structured data, JS rendering. Reuses an existing SE Ranking audit when present (cheap), creates one when needed (expensive — confirms with user). Severity × effort prioritisation in `references/severity-mapping.md`. Top-10 fix list as the deliverable.
- **`seo-content-audit`** — E-E-A-T + CITE quality audit for existing content. 60-item E-E-A-T rubric (Experience / Expertise / Authoritativeness / Trustworthiness, 15 each) at `references/core-eeat.md`; 30-item CITE rubric (Clear answer / Include stats / Timestamp / Entity authority) at `references/cite.md`. Veto checks (3 each) gate publication. Output: PUBLISH / PUBLISH WITH FIXES / NO PUBLISH verdict + top 5 fixes.
- **`seo-sitemap`** — XML sitemap analysis vs the most recent SE Ranking audit. Surfaces missing-from-sitemap, orphans-from-sitemap, broken sitemap entries, lastmod issues. Predecessor: `seo-technical-audit` (provides the audit baseline).

### Changed
- README skills table extended to 13 rows; repo-layout block updated for new skill folders.
- All three version strings bumped to 0.5.0.

## [0.4.0] — 2026-04-27

### Added
- **`seo-page`** — URL-level keyword & traffic intelligence. Pulls `DATA_getUrlOverviewWorldwide`, `DATA_getDomainKeywords` (URL-filtered), `DATA_getPageAuthority` + history, top SERPs and AIO citations for the URL's primary keywords. Output: keep / refresh / consolidate / kill verdict for one page.
- **`seo-schema`** — Schema.org JSON-LD detect, validate, generate. Six bundled templates (Article, Product, LocalBusiness, FAQPage, HowTo, BreadcrumbList) under `skills/seo-schema/templates/`; rich-results spec snapshot at `skills/seo-schema/references/google-rich-results.md`. Output: paste-ready `<script>` blocks.
- **`seo-drift`** — Git for SEO. Three subcommands (`baseline`, `compare`, `history`). Uses SE Ranking's history endpoints (`DATA_getDomainOverviewHistory`, `DATA_getCumulativeBacklinksHistory`, `DATA_getNewLost*`, etc.) plus `WebFetch` page fingerprinting. Severity thresholds at `skills/seo-drift/references/drift-thresholds.md`.
- **`seo-sxo`** — Reads SERPs backwards to detect page-type mismatches. Classifies each top-10 result by page type, scores the candidate page from 4 personas (Skimmer, Researcher, Buyer, Validator), and produces a wireframe for the SERP-winning page type when there's a mismatch. References under `skills/seo-sxo/references/`. Acknowledges Florian Schmitz (Pro Hub Challenge in `claude-seo`) for the SXO framework.

### Changed
- README skills table extended to 10 rows; intro line generalised; repo-layout block updated to show new skill folders + supporting files.
- All three version strings bumped to 0.4.0.

## [0.3.1] — 2026-04-27

### Removed
- `seo-website-audit-change-report` skill removed from the catalogue. A focused one-shot `seo-technical-audit` (planned for v0.4.0) will cover the audit-deliverable use case.

### Changed
- Renamed `seo-keyword-cluster-planner` → `seo-keyword-cluster`. Folder, frontmatter `name:`, output-folder slug pattern, and all README references updated. Description tightened to call out how the skill differs from `seo-content-brief` (single article) and the planned `seo-page` (existing URL) — this skill plans a content tier across many articles.

## [0.3.0] — 2026-04-27

### Changed
- Renamed all 7 skills with an `seo-` prefix so slash-command tab-completion groups them visually: `content-brief` → `seo-content-brief`, `agency-landing-page` → `seo-agency-landing-page`, and so on. Skills are now invoked as `/seranking-mcp-skills:seo-content-brief`. Folder names, frontmatter `name:` fields, and output-folder slug patterns (`seo-{skill}-{target-slug}-{YYYYMMDD}/`) all updated to match.
- Renamed the bundled example run from `examples/ai-search-share-of-voice-wix-com-20260427/` to `examples/seo-ai-search-share-of-voice-wix-com-20260427/` for parity with the new slug convention.

## [0.2.0] — 2026-04-27

### Changed
- Flattened the repo layout: skill folders are now at `skills/<name>/SKILL.md` (was `plugins/seranking-mcp-skills/skills/<name>/SKILL.md`). The marketplace's `plugins[0].source` is `"./"`, and `plugin.json` lives alongside `marketplace.json` under `.claude-plugin/`. Matches the single-plugin convention used by other community plugins (e.g. `AgriciDaniel/claude-seo`).
- Updated README install Options 2–4 to use the new flat paths. Users installing via `/plugin marketplace add seranking/seranking-mcp-skills` are unaffected; users using `--plugin-dir` or `cp -r` need to update their paths.

## [0.1.1] — 2026-04-27

### Changed
- Standardized output folder slugs to `{skill-slug}-{target-slug}-{YYYYMMDD}/` across all skills.
- Pointed README at the SE Ranking remote MCP (`https://seranking.com/api/integrations/mcp`). Install is now `claude mcp add --transport http se-ranking https://api.seranking.com/mcp` + OAuth sign-in. Removed the `DATA_API_TOKEN` env-var requirement and the `PROJECT_API_TOKEN` mention — OAuth covers auth, and one connection covers every skill.

### Added
- Rate-limit tip in `agency-landing-page` for parity with other skills.
- WebFetch declared in Prerequisites of `content-brief` and `backlink-gap`.
- Credit-budget notes in `competitor-gap-analysis` and `keyword-cluster-planner`.
- Form-endpoint note in `agency-landing-page` output.

### Fixed
- `content-brief` and `competitor-gap-analysis` now document the `DATA_getDomainCompetitors` overflow: that endpoint has no upstream `limit`/`offset` and returns ~60KB, so the MCP harness writes it to a file. Skills now instruct: read the file, parse `{data: [...]}`, sort by `common_keywords` desc, take top 5.

### Removed
- Empty `examples/` directory placeholder (replaced with a real example run, see Added).

### Examples
- Added [`examples/ai-search-share-of-voice-wix-com-20260427/`](examples/ai-search-share-of-voice-wix-com-20260427/) — an end-to-end run of `ai-search-share-of-voice` against Wix vs Weebly / Hostinger / Squarespace / Webflow. Includes leaderboard, heatmap, prompt samples, topic cluster ownership analysis, and a finished `REPORT.md`. Snapshot dated 2026-04-27.

## [0.1.0] — 2026-04-24

- Initial release: 7 skills covering content briefs, AI-search reports, audit diffs, backlink gaps, keyword clusters, competitor gaps, and agency landing pages.
