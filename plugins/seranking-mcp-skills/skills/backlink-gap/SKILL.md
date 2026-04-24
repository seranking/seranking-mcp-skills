---
name: backlink-gap
description: Find referring domains that link to multiple competitors but not to your site, then enrich with authority, anchor samples, and outreach angle per row. Produces a prospect list an outreach team can start emailing tomorrow. Use when the user asks for backlink gap analysis, link building opportunities, competitor backlink intersection, link prospecting, or wants referring domains they are missing.
---

# Backlink Gap

Produce an actionable link-prospecting list: domains linking to your top competitors but not to you, filtered by authority and relevance, enriched with anchor samples and a suggested outreach angle.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- User provides: (a) target domain, (b) 3 to 5 competitor domains, and optionally (c) minimum Domain Trust (default: 25), (d) dofollow-only filter (default: true), (e) minimum intersection count (default: linked by at least 2 of the N competitors).

## Process

1. **Baseline target backlinks** `DATA_getBacklinksRefDomains`, `DATA_getBacklinksSummary`
   - Pull the target domain's existing referring domains to build an exclusion set.
   - Save count and summary metrics for the report.

2. **Per-competitor referring domains** `DATA_getBacklinksRefDomains`
   - For each competitor, pull referring domains with `dofollow_only=true` and `min_domain_trust={threshold}`.
   - Collect as a dict keyed by referring domain with the list of competitors linking to it.

3. **Intersection**
   - Retain referring domains that link to at least the minimum number of competitors.
   - Exclude any domain already in the target's backlink set.

4. **Enrichment** `DATA_getBacklinksAuthority`, `DATA_getBacklinksAnchors`
   - For each candidate, pull: Domain Trust, Page Trust of the linking page, linking-to-competitor anchor samples (top 3 anchors), and country if available.
   - Classify by link type: editorial, resource list, directory, forum/UGC.

5. **Relevance scoring**
   - Score each candidate on: (a) topical overlap (use domain homepage title/meta via WebFetch), (b) DT, (c) intersection count, (d) link-type preference.
   - Suggest an outreach angle per row: local fit, topical fit, competitive parity, resource-list inclusion, broken link, etc.

6. **Produce the prospect list** (see Output Format).

## Output format

Create a folder `backlink-gap-{target-slug}/` with:

```
backlink-gap-{target-slug}/
├── 01-target-baseline.md
├── 02-competitor-{domain}-refs.md   # one per competitor
├── 03-intersection-raw.md
├── prospects.csv                     # machine-readable output
└── REPORT.md
```

`REPORT.md` follows this shape:

```markdown
# Backlink Gap: {target} vs {competitors}

## Filters applied
- Dofollow only: yes
- Min Domain Trust: {n}
- Min intersection: links to at least {n} of {total} competitors

## Top 25 prospects

| # | Referring domain | DT | Links to | Sample anchor | Link type | Angle | Score |
|---|---|---|---|---|---|---|---|
| 1 | example.com | 68 | {3 of 5} | "best yoga studios" | Resource list | Topical fit | 92 |
| 2 | ... | ... | ... | ... | ... | ... | ... |

## Outreach brief
- Segment these prospects into 3 batches by link type and pitch each batch with a tailored template.
- For editorial links: pitch a unique-angle comparison or original research.
- For resource lists: suggest inclusion with a specific anchor.
- For directories: apply directly.
- For forums/UGC: engage before pitching; these are not cold-outreachable.

## Counts
- Total unique referring domains across competitors: {n}
- Passed filters: {n}
- Already linking to {target}: {n} (excluded)
- Final prospects: {n}

## Files
- prospects.csv: import to Hunter.io, Pitchbox, or your outreach tool
- Per-competitor raw data: 02-competitor-*.md
```

`prospects.csv` columns:
`rank,referring_domain,domain_trust,links_to_count,links_to_competitors,sample_anchor,link_type,outreach_angle,score`

## Tips

- Data API rate limit: 10 requests per second. With 5 competitors, expect 5-10 seconds of sequential API time plus enrichment.
- Do not include subdomains of already-linked domains in the prospect list. If news.example.com links to the target but blog.example.com links only to competitors, treat as already-linked unless the user asks otherwise.
- The "Angle" column is the most important output for outreach. Keep it specific: "Their 'best X tools' list from 2024 is out of date and doesn't include you" beats "topical fit".
- Exclude obvious spam/low-quality domains even if they pass DT thresholds. Use the WebFetch step to sanity-check any prospect scoring above 80.
- If the target already outranks all competitors for branded terms, prioritise non-branded editorial placements over parity directories.
