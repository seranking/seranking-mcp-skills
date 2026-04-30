---
name: seo-page
description: URL-level SEO intelligence — which keywords this page ranks for, traffic captured, position history, SERP context, and AI Search citation status. Produces a keep / refresh / consolidate / kill verdict for one page. Distinct from `seo-technical-audit` (which checks technical health, not keyword/traffic performance) and from `seo-content-brief` (which produces a NEW article from a topic). Use when the user asks "analyze this page", "page SEO performance", "what does this URL rank for", "page traffic", "should I refresh this page", or provides a single URL for analysis.
---

# Page Intelligence

Show what a single URL ranks for, what traffic it captures, where its weak and strong points are, and what to do about it. The deliverable is an opinionated verdict — **KEEP**, **REFRESH**, **CONSOLIDATE**, or **KILL** — anchored in objective signals from SE Ranking's URL-level data.

## Prerequisites

- SE Ranking MCP server connected.
- Claude's `WebFetch` tool available (for the page-level HTML sense-check).
- User provides: (a) a target URL, optionally (b) target market country (default: `us`), (c) primary topical keyword (auto-inferred from `<title>` + `<h1>` if not supplied).

## Process

1. **Validate & preflight**
   - Confirm the URL is fetchable; derive parent domain.
   - `DATA_getCreditBalance` — surface remaining credits and the estimated cost (~10–15 credits typical).
   - **Firecrawl availability check.** If `mcp__firecrawl-mcp__firecrawl_scrape` is available, step 6 recovers `og:*`, `twitter:*`, canonical, robots meta, JSON-LD types, and hreflang count from the raw `<head>` (1 Firecrawl credit). Without Firecrawl those fields can't be populated — WebFetch returns markdown only and strips them. The skill still runs; the affected lines emit `(skipped — Firecrawl not installed)` in `PAGE.md`. User may pass `--no-firecrawl` to skip Firecrawl even when available (treats it as "not installed" for credit conservation).
   - If the user supplied a primary keyword, use it. Otherwise infer it in step 3.

2. **URL-level overview** `DATA_getUrlOverviewWorldwide`
   - Pull keyword count, organic traffic estimate, paid keyword count, paid traffic estimate, top regions.
   - Note: traffic estimates are directional — they don't replace Google Search Console.

3. **Ranking keywords** `DATA_getDomainKeywords` (use the `url` param for exact match — not `filter_url`)
   - Pull every keyword the URL ranks for in the target country, with positions.
   - Sort by traffic-weighted score: `volume × CTR-by-position` (use a standard CTR curve: 1=28%, 2=15%, 3=11%, 4=8%, 5=7%, 6=5%, 7=4%, 8=3%, 9=2%, 10=2%, 11+=1%).
   - Take the top 3–5 as the URL's "primary keywords" for SERP work in step 5.

4. **Page authority** `DATA_getPageAuthority` + `DATA_getPageAuthorityHistory`
   - Current PA score and its 12-month trajectory.
   - Flag any drop > 5 points in the last 90 days.

5. **SERP context** `DATA_getSerpResults` and `DATA_getAiOverview`
   - For each of the 3–5 primary keywords:
     - Top 10 organic results (URL, title, snippet).
     - SERP features present (PAA, image carousel, video, shopping, etc.).
     - AIO presence and citations — is this URL cited in the AIO?

6. **HTML sense-check** `WebFetch` (always) + `mcp__firecrawl-mcp__firecrawl_scrape` (when available)
   - **WebFetch first** (free, instant): extract `<title>`, meta description, all `<h1..h6>`, lang, word count, internal-link count, image count. WebFetch returns markdown so anything in `<head>` beyond `<title>` is lost — the next bullet recovers it.
   - **Firecrawl second** (1 Firecrawl credit; pass `formats: ["rawHtml"]`) — recovers what WebFetch can't see. Pin the format to `rawHtml`; the default `html` is post-processed and silently strips canonical, hreflang, and `<script type="application/ld+json">` blocks on many sites. If those head fields come back zero on a site that obviously has them (any major SaaS homepage), you forgot the `rawHtml` flag — re-run.
     - From `metadata`: `og:title`, `og:description`, `og:image`, `twitter:card`, `viewport`, robots meta, canonical URL.
     - From the returned `rawHtml`: every `<script type="application/ld+json">` block. Parse each as JSON, list detected `@type`s (Article, BreadcrumbList, Organization, Product, etc.). Note any block that fails to parse.
     - hreflang: count `<link rel="alternate" hreflang="…">` occurrences in `rawHtml`.
   - **If Firecrawl unavailable:** the WebFetch portion still runs; populate Page basics' OG / Twitter / canonical / robots / JSON-LD / hreflang lines as `(skipped — Firecrawl not installed)`. Don't infer from markdown.
   - **Sense-check:** does the page actually talk about its top-ranking keyword in title and H1? If a page ranks for keywords it doesn't address textually, that's a strong consolidation signal.

7. **Domain context** `DATA_getDomainOverviewWorldwide` (parent domain)
   - Light-weight: parent DA, total keywords, total traffic. Used to contextualise the page's PA against its domain.

8. **Cannibalization check** `DATA_getDomainPages`
   - Pull the parent domain's pages ranked by organic traffic. Cap at the top 50 — that's where the cannibalization risk concentrates.
   - For the candidate URL's top-3 traffic-weighted keywords (from step 3), scan the peer-page list: does any other URL on the same domain rank in the top 20 for any of those keywords?
   - **Cannibalization signal:** any peer URL ranking ≤ 20 for the candidate's top-3 keywords. Record peer URL, keyword, peer position vs candidate position, peer traffic.
   - **Cheaper than the old approach.** Previous versions cross-checked via `DATA_getDomainKeywords` on the parent domain — that endpoint can return tens of thousands of rows on large sites and is unnecessarily heavy for this question. `DATA_getDomainPages` ranked by traffic surfaces the high-impact peers directly.
   - If no peer URL competes, this signal is "no cannibalization detected" — pass through to step 9.

9. **Synthesise verdict**
   - Apply the verdict heuristic (see Tips) to produce KEEP / REFRESH / CONSOLIDATE / KILL.
   - For REFRESH, identify the top 3 specific changes (e.g., "add an H2 on 'alternatives' which 7 of 10 SERP winners use").
   - Write `PAGE.md` (output spec below).

## Output format

Create a folder `seo-page-{target-slug}-{YYYYMMDD}/` with:

```
seo-page-{target-slug}-{YYYYMMDD}/
├── 01-url-overview.md       (raw DATA_getUrlOverviewWorldwide)
├── 02-keywords.md           (raw DATA_getDomainKeywords filtered)
├── 03-authority.md          (PA + history)
├── 04-serp-context.md       (top 10 + AIO for top 3–5 keywords)
├── 05-page-snapshot.md      (HTML extracts)
├── 06-cannibalization.md    (peer pages on the same domain competing for the top-3 keywords)
├── keywords.csv             (full keyword list with positions)
└── PAGE.md                  (synthesised verdict + plan)
```

`PAGE.md` follows this shape:

```markdown
# Page Intelligence: {URL}

> Snapshot dated {YYYY-MM-DD} · Country: {country} · Primary keyword: {keyword}

## Snapshot
- Ranking keywords: {n}
- Estimated monthly organic traffic: {n}
- Page authority: {PA} ({↑/↓ trajectory over 90 days})
- Primary topic: {topic}
- AIO citations: {n} of {checked} primary-keyword AIOs cite this URL

## Page basics
- `<title>`: {value}
- meta description: {value | absent}
- `og:title`: {value | absent | skipped — Firecrawl required}
- `og:description`: {value | absent | skipped}
- `og:image`: {url | absent | skipped}
- `twitter:card`: {summary | summary_large_image | absent | skipped}
- `<link rel="canonical">`: {URL | self-referential | absent | skipped}
- meta robots: {index,follow | noindex,nofollow | absent | skipped}
- JSON-LD types detected: {Article, BreadcrumbList, Organization | none | skipped}
- hreflang variants: {n | skipped}

## What this page wins
- {keyword} — position {n}, ~{volume} monthly searches, ~{traffic} monthly clicks.
- ... (top 3–5)

## Almost-wins (page-2 refresh opportunities)
- {keyword} — position {n}, ~{volume} monthly searches. The top 3 SERP winners all do {pattern} that this page doesn't.
- ... (top 3 examples)

## What this page misses
- {keyword} — competitors {comp1}, {comp2} rank in top 5; this page is absent.
- ...

## Same-domain cannibalization
- {peer URL} — ranks position {n} for "{keyword}" (candidate ranks position {m}). Peer estimated traffic: {n}/mo.
- ... (only list rows where a peer URL ranks ≤ 20 for one of the candidate's top-3 keywords; if none, write "No same-domain cannibalization detected on top-3 keywords.")

## AI Search angle
- {n} of {checked} AIO queries on the URL's keywords cite this page.
- The AIOs that DON'T cite this page tend to cite {pattern} (e.g., comparison tables, step-by-step how-tos).
- Recommended GEO move: {one specific change}.

## Verdict: {KEEP | REFRESH | CONSOLIDATE | KILL}

Reasoning: {1–2 sentences anchored in objective signals from above}.

### If REFRESH — top 3 changes
1. {Specific change}
2. {Specific change}
3. {Specific change}

## Raw data
- keywords.csv — full enriched ranking-keyword list
- 04-serp-context.md — per-keyword SERP top-10 with AIO
- 05-page-snapshot.md — HTML extracts
```

`keywords.csv` columns: `keyword,volume,kd,position,intent,traffic_estimate,url`

## Tips

- Respect SE Ranking Data API rate limit: 10 requests per second. The 3–5 SERP queries in step 5 should be paced sequentially.
- Call `DATA_getCreditBalance` before running. ~10–15 credits is typical for one URL.
- Verdict heuristic:
  - **KEEP**: PA stable or up; traffic stable or up; top 3 keywords held in their positions; AIO citations present where AIO appears.
  - **REFRESH**: any of (PA dropped >5 in 90 days; traffic dropped >20%; a top-3 keyword fell to position 11+; AIO citations missing while competitors get cited).
  - **CONSOLIDATE**: cannibalization detected (step 8) — a peer URL on the same domain ranks ≤ 20 for one or more of the candidate's top-3 keywords. CONSOLIDATE harden when the peer outranks the candidate AND captures higher traffic; otherwise CONSOLIDATE recommendation is "merge into the candidate" rather than "kill the candidate."
  - **KILL**: PA <10 AND traffic <50/mo AND no top-10 keyword AND no internal links pointing to it. **Hardens** when JSON-LD schema is also absent (Firecrawl detected zero blocks) — the page has no signals for any crawler, organic or AI.
- Don't invent reasons. Anchor every claim in `PAGE.md` to a number from the raw data files.
- When between KEEP and REFRESH, default to REFRESH — small refreshes compound.
- The `keywords.csv` is the auditable trail. If a stakeholder questions the verdict, walk them through the CSV row by row.
- For pages with very low data (new pages, <5 ranking keywords), the verdict is unreliable. Flag as "insufficient data — re-run after 60 days" rather than forcing a verdict.
- **`DATA_getPageAuthorityHistory` all-zeros caveat:** if the endpoint returns `inlink_rank: 0` (or equivalent) for every date in the history window, treat as "insufficient history" — don't claim a drop or recommend REFRESH based on it. Often happens for very high-authority pages where the metric is saturated, or for URLs that haven't accumulated enough longitudinal data. Cross-check with `DATA_getPageAuthority` (current value) — if current PA is meaningful but history is flat-zero, flag the gap explicitly in `PAGE.md` rather than synthesising a trajectory.
