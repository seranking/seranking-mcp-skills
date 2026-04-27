---
name: seo-technical-audit
description: Focused one-shot technical SEO audit for a domain. Crawlability, indexability, security, mobile, structured data, JS rendering — single-pass deliverable, not a diff. Distinct from `seo-drift` (which tracks changes over time) and from `seo-page` (which audits keywords/traffic for one URL, not technical health). Use when the user asks "technical audit", "site audit", "audit my site", "crawl issues", "indexation issues", or "technical SEO check".
---

# Technical Audit

A one-shot technical SEO audit for a domain. Pulls SE Ranking's audit data, categorizes findings by area (crawlability, indexability, security, mobile, structured data, etc.), severity-sorts within each, and produces a top-10 fix list ranked by impact × effort.

## Prerequisites

- SE Ranking MCP server connected.
- Claude's `WebFetch` tool available (used for sense-checking robots.txt and sitemap presence).
- User provides: a target domain (e.g. `example.com`). Optional: target country (default `us`), audit-page-limit override (default: rely on the existing audit's limit).

## Process

1. **Validate target & preflight**
   - Normalise domain (strip protocol, trailing slash).
   - `DATA_getCreditBalance` — surface remaining credits. A re-check of an existing audit is cheap; creating a new audit is significantly more expensive (cost varies by page count). Surface the cost before deciding.

2. **Find or create the audit** `DATA_listAudits`
   - List audits for the domain.
   - If a recent audit exists (<30 days old), use it.
   - If older than 30 days, run `DATA_recheckAudit` to refresh.
   - If none exists, ask the user before creating a new one with `DATA_createStandardAudit` (it consumes credits).
   - Wait for `DATA_getAuditStatus` to report `done` before pulling the report.

3. **Pull the audit report** `DATA_getAuditReport`
   - Top-line metrics: pages crawled, health score, total issues by severity.
   - Issues grouped by category (crawlability, indexability, mobile, security, structured data, etc.).

4. **Pull per-issue page lists** `DATA_getAuditPagesByIssue`
   - For each significant issue (severity ≥ medium, count ≥ 5), pull the affected URLs.
   - This produces the actionable fix list.

5. **Cross-reference key URLs** `DATA_getIssuesByUrl`
   - For the top 5 pages by traffic (from `DATA_getDomainKeywords`'s page aggregation, or homepage + key landing pages if no keyword data), pull all issues for those specific URLs.
   - This catches cases where one important page concentrates many issues.

6. **Sense-check** `WebFetch`
   - Fetch `/robots.txt` and `/sitemap.xml` directly.
   - Confirm the audit's findings match reality on these critical files (audits sometimes lag behind same-day deploys).

7. **Categorize and prioritize** using `references/severity-mapping.md`
   - Map each issue code to severity, fix, and effort estimate.
   - Score each finding: severity × affected-page-count / effort.
   - Build the top-10 fix list.

8. **Synthesise** `TECH-AUDIT.md`

## Output format

Create a folder `seo-technical-audit-{target-slug}-{YYYYMMDD}/` with:

```
seo-technical-audit-{target-slug}-{YYYYMMDD}/
├── 01-audit-summary.md         (DATA_getAuditReport top-line)
├── 02-issues-by-category/
│   ├── crawlability.md
│   ├── indexability.md
│   ├── security.md
│   ├── mobile.md
│   ├── structured-data.md
│   └── content.md
├── 03-key-pages-issues.md       (top 5 traffic pages, all their issues)
├── 04-robots-sitemap-snapshot.md (raw fetched files)
├── issues.csv                   (every issue: code, severity, count, fix, effort)
└── TECH-AUDIT.md                (synthesised: top-10 fix list + category summary)
```

`TECH-AUDIT.md` follows this shape:

```markdown
# Technical Audit: {domain}

> Audit date {YYYY-MM-DD} · Pages crawled: {n} · Health score: {n}/100

## Summary

| Severity | Count |
|---|---|
| Critical | {n} |
| High | {n} |
| Medium | {n} |
| Low | {n} |

## Top 10 fixes (impact × effort)

| Rank | Issue | Severity | Pages | Fix | Effort |
|---|---|---|---|---|---|
| 1 | {issue name} | {severity} | {n} | {one-line fix} | {S/M/L} |
| ... |

## By category

### Crawlability ({n} issues)
- {issue name} ({n} pages) — {fix}
- ...

### Indexability ({n} issues)
- ...

### Security ({n} issues)
- ...

### Mobile ({n} issues)
- ...

### Structured data ({n} issues)
- ...

### Content ({n} issues)
- ...

## Key-page deep dives

### {URL with most issues}
{n} issues found. Top fixes:
1. ...
2. ...

## Recommended cadence
Re-run this skill monthly to catch regressions, or wire `seo-drift` to baseline + diff between audits.
```

`issues.csv` columns: `category,issue_code,issue_name,severity,affected_pages,suggested_fix,effort,priority_score`

## Tips

- Respect rate limit: 10 req/sec.
- Reuse existing audits when possible — creating a new audit is the most expensive operation.
- A fresh audit on a 1k-page site can take 10–30 minutes to complete. The skill polls `DATA_getAuditStatus` until `done` — be patient.
- The severity scale comes from SE Ranking's audit (not arbitrary). Map them via `references/severity-mapping.md` so impact × effort scoring is consistent run-to-run.
- For sites with >10k pages, consider auditing critical sections separately (set audit URL filters in SE Ranking) rather than crawling the whole site every time.
- Pair with `seo-drift` for regression tracking: this skill is the snapshot, drift is the diff.
- Pair with `seo-sitemap` for orphan/missing-page analysis (it consumes this skill's audit data).
- Don't auto-apply fixes. The skill diagnoses; humans decide which fixes to ship and in what order.
