# Changelog

All notable changes to this project will be documented in this file. Format based on Keep a Changelog.

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
