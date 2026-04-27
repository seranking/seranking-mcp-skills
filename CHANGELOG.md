# Changelog

All notable changes to this project will be documented in this file. Format based on Keep a Changelog.

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
