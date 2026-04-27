---
name: seo-sitemap
description: Pull a domain's XML sitemap (and sitemap-of-sitemaps), then compare against the most recent SE Ranking website audit. Surfaces (a) sitemap entries the crawler couldn't find (orphans from the sitemap), (b) audit pages missing from the sitemap (probably an oversight), (c) sitemap entries that are now 404, (d) lastmod inconsistencies. Use when the user asks for "sitemap analysis", "check my sitemap", "sitemap vs audit", "missing pages", "orphan pages", or "sitemap health".
---

# Sitemap Analysis

Compare a domain's XML sitemap against the most recent SE Ranking website audit. Surface what the sitemap claims vs what the crawler actually found, in both directions.

## Prerequisites

- SE Ranking MCP server connected.
- Claude's `WebFetch` tool available.
- User provides: a target domain. Optional: the sitemap URL if not at `/sitemap.xml` (auto-discovery from `robots.txt` is attempted first).
- **Predecessor:** `seo-technical-audit` (or any prior SE Ranking audit) on this domain. Without an existing audit, this skill has nothing to compare against — chain `seo-technical-audit` first.

## Process

1. **Validate target & confirm audit**
   - Normalise the domain.
   - `DATA_listAudits` → confirm an audit exists for this domain. If none, surface a clear message: "Run `seo-technical-audit` first; this skill compares the sitemap to that audit's crawl."
   - Use the most recent `done` audit by default.

2. **Fetch the sitemap** `WebFetch`
   - First try `https://{domain}/sitemap.xml`.
   - If that 404s, fetch `/robots.txt` and look for `Sitemap:` directives.
   - If still nothing, ask the user for the sitemap URL.
   - For sitemap-of-sitemaps (sitemap index), recursively fetch each child sitemap.
   - Build the canonical URL list from the sitemap.

3. **Pull the audit's crawled pages** `DATA_getCrawledPages`
   - All URLs the crawler found, with status codes, indexability flags, depth.

4. **Pull domain pages** `DATA_getDomainPages`
   - Domain-level page inventory (broader than the audit's crawl scope in some cases).

5. **Pull orphan-page issues** `DATA_getAuditPagesByIssue`
   - Filter for orphan-page and depth-related issues. These intersect with sitemap analysis.

6. **Compute the four diffs**
   - **Missing from sitemap:** URLs in `DATA_getCrawledPages` (status 200, indexable) that don't appear in the sitemap. Probably should be added.
   - **Orphans from sitemap:** URLs in the sitemap that the crawler didn't find via internal links (cross-ref `DATA_getAuditPagesByIssue` orphan flags). The sitemap is the only thing pointing at them — investigate whether they should be linked internally.
   - **Broken sitemap entries:** sitemap URLs that returned non-200 in the audit's crawl. Remove from sitemap or fix the URL.
   - **Lastmod issues:** sitemap entries where (a) all `<lastmod>` dates are identical (lazy generation) or (b) `<lastmod>` is older than the audit's crawl date for the page even though the page changed (stale).

7. **Validation**
   - URL count <50,000 per file (sitemap protocol limit). Flag if exceeded.
   - Sitemap referenced in `robots.txt`.
   - Encoding: each URL is XML-safe (ampersands escaped, etc.).
   - HTTPS consistency: sitemap URLs match the canonical protocol.
   - **Note:** `<priority>` and `<changefreq>` are ignored by Google in 2026. Don't bother validating them; flag their presence as low-signal noise.

8. **Synthesise** `SITEMAP.md`

## Output format

Create a folder `seo-sitemap-{target-slug}-{YYYYMMDD}/` with:

```
seo-sitemap-{target-slug}-{YYYYMMDD}/
├── 01-sitemap-raw.md           (fetched sitemap content, URL list extracted)
├── 02-audit-pages.md           (audit's crawled-pages list, DATA_getCrawledPages)
├── 03-missing-from-sitemap.md  (URLs found by crawler, not in sitemap)
├── 04-orphans-from-sitemap.md  (URLs in sitemap, not found by crawler)
├── 05-broken-entries.md        (sitemap URLs returning non-200)
├── 06-lastmod-issues.md        (stale or uniform lastmod dates)
├── recommended-sitemap-diff.md (proposed changes: add X, remove Y)
└── SITEMAP.md                  (synthesised report)
```

`SITEMAP.md` follows this shape:

```markdown
# Sitemap Analysis: {domain}

> Sitemap pulled {YYYY-MM-DD} · Audit reference {audit-date}

## Health summary

| Metric | Value | Status |
|---|---|---|
| Sitemap URLs | {n} | — |
| Audit crawled URLs (200, indexable) | {n} | — |
| Missing from sitemap (probable adds) | {n} | {🔴 if >5%} |
| Orphans from sitemap (probable cuts or link-ins) | {n} | {🟡 if >5} |
| Broken sitemap entries (non-200) | {n} | {🔴 if >0} |
| Lastmod issues | {n} | {🟡 if uniform; 🔴 if stale} |

## Recommended changes

### Add to sitemap ({n} URLs)
- {URL} — found by crawler at depth {n}, status 200, indexable.
- ...

### Remove from sitemap ({n} URLs)
- {URL} — returns {status code}.
- ...

### Investigate (orphan from sitemap, {n} URLs)
- {URL} — in sitemap but not reachable via internal links. Either link from {suggested parent} or remove from sitemap.
- ...

### Fix lastmod ({n} URLs)
- {URL} — lastmod is {date} but the audit crawled the page on {date} and detected changes since.
- ...

## Validation

- Total URL count: {n} ({✓ under 50k limit | ✗ exceeds — split into sitemap-of-sitemaps})
- Referenced in robots.txt: {✓/✗}
- HTTPS consistency: {✓/✗}
- Encoding: {✓/✗}

## Apply
- See `recommended-sitemap-diff.md` for the proposed sitemap.xml changes.
- After applying, re-run `seo-technical-audit` to refresh the crawl, then re-run this skill to verify.
```

## Tips

- Run `seo-technical-audit` first. Without an audit, this skill has nothing to compare.
- Re-run after deploys that change page inventory (new content, removed pages, URL restructures).
- Sitemap-of-sitemaps fan-out can be large for big sites — the skill recursively fetches all child sitemaps. For sites with 50+ child sitemaps, fetching dominates runtime; not credit cost.
- `<priority>` and `<changefreq>` are dead signals. Don't waste time tuning them.
- The "investigate orphans" list is often the highest-leverage finding — pages that exist but aren't linked are usually accidentally orphaned, and adding a couple of internal links can revive them.
- Pair with `seo-drift` to track sitemap composition over time (URL count, lastmod patterns).
- Cost: ~5–10 credits typical (mostly the `getCrawledPages` and `getDomainPages` calls).
