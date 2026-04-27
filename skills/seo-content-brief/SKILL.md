---
name: seo-content-brief
description: Generate a writer-ready SEO content brief from a target domain and topic. Pulls domain overview, competitors, keyword gaps, SERP analysis, related and question keywords, AI Search citations, and existing internal-link sources, then synthesises a complete editorial brief a freelance writer can start from immediately. Use when the user asks for a content brief, blog brief, article outline, editor brief, or wants to capture organic traffic their competitors have.
---

# Content Brief

Turn a domain plus a topic intent into a complete content editor brief: target keyword, title options, H2/H3 structure, content gaps the current top results miss, internal linking plan, AI search angle, and estimated traffic potential.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- Claude's `WebFetch` tool available (used for top-3 content teardown).
- User has provided: (a) target domain, (b) market/country (default: `us`), and optionally (c) a seed topic or intent. If no seed topic is given, discover the best opportunity from the keyword-gap step.

## Process

1. **Domain overview** `DATA_getDomainOverviewWorldwide`, `DATA_getDomainKeywords`
   - Pull organic traffic, top countries, and top 100 organic keywords in the target market.
   - Save the raw JSON and a human summary.

2. **Competitor discovery** `DATA_getDomainCompetitors`
   - Identify the top 5 organic competitors by shared keywords in the target market.
   - Save a one-line positioning note per competitor.
   - **Note:** the upstream API does not support `limit`/`offset`, so this call returns the full set (~60KB for popular domains) and the MCP harness writes it to a file. Read that file path, parse the `{data: [...]}` JSON, sort by `common_keywords` desc, and take the top 5.

3. **Keyword gap analysis** `DATA_getDomainKeywordsComparison`
   - Pull keywords the competitors rank for that the target domain does not.
   - Filter: informational intent, search volume > 1,000/mo, keyword difficulty < 40.
   - Save the filtered gap list sorted by volume.

4. **Pick the best topic cluster**
   - From the gaps, select one topic. Justify the pick with: traffic potential, difficulty, relevance to the target domain's product. Surface reasoning to the user before proceeding.

5. **SERP and keyword deep-dive for the chosen topic**
   - `DATA_getSerpResults` for the top 10 organic + SERP features (AIO, PAA, Featured Snippet, Video).
   - `DATA_getRelatedKeywords` and `DATA_getSimilarKeywords` for expansion.
   - `DATA_getKeywordQuestions` for People-Also-Ask and question-based variations.
   - `DATA_getAiOverview` + `DATA_getAiOverviewLeaderboard` to see which brands LLMs cite today for the topic.

6. **Top 3 content analysis** `WebFetch` (always) + `mcp__firecrawl-mcp__firecrawl_scrape` (when available)
   - **WebFetch first** (free, instant): pull markdown for the top 3 ranking URLs. Extract H1/H2/H3 spine, word count per article, shared subtopics, gaps, and prose-level formatting patterns.
   - **Firecrawl second** (3 Firecrawl credits — 1 per top-3 winner) — recovers what WebFetch's markdown can't show:
     - From `metadata`: `<title>` length (the real string, not markdown's first heading), meta description length, `og:title`, `og:description`, `og:image`, `twitter:card`.
     - From the returned `html`: every `<script type="application/ld+json">` block. Parse and list `@type`s per winner (Article, FAQPage, BreadcrumbList, Product, etc.) — these become the "schema baseline" for the new article.
     - On-page signals: hero-image presence, byline structure (`<a rel="author">`, `<meta name="author">`), table count, code-block count.
   - **If Firecrawl unavailable (or `--no-firecrawl` passed):** WebFetch portion runs unchanged. The brief's "Top 3 winners — on-page benchmark" subsection (see Output) emits `(skipped — Firecrawl required for schema/og:* on competitor pages)`.

7. **Internal linking plan**
   - `DATA_getDomainKeywords` filtered to the target domain plus WebFetch of 5 high-ranking pages on topically adjacent queries.
   - For each: propose an anchor text and the section of the new post it belongs in.

8. **Synthesise the brief** (see Output Format).

## Output format

Create a folder `seo-content-brief-{target-slug}-{YYYYMMDD}/` with one file per step plus the final `BRIEF.md`:

```
seo-content-brief-{target-slug}-{YYYYMMDD}/
├── 01-domain-overview.md
├── 02-competitors.md
├── 03-keyword-gaps.md
├── 04-serp-and-keywords.md
├── 05-content-analysis.md
├── 06-internal-links.md
└── BRIEF.md
```

`BRIEF.md` follows this shape:

```markdown
# Content Brief: {proposed title}

## Target keyword
- Primary: {kw} ({volume}/mo, KD {kd}, intent: informational)
- Secondary: {kw1} ({volume}), {kw2} ({volume}), {kw3} ({volume})

## Title options
1. {title option 1}
2. {title option 2}
3. {title option 3}

## Meta description (150-160 chars)
{draft}

## Suggested structure

### H1: {proposed H1}

#### H2: {section 1}
Cover: {bullets of what to include}
Cite: {sources to link out to}

#### H2: {section 2}
...

## Gaps the current top 3 miss
- {gap 1, with evidence}
- {gap 2, with evidence}
- {gap 3, with evidence}

## Top 3 winners — on-page benchmark (Firecrawl)

| Signal | Winner 1 | Winner 2 | Winner 3 | Required for parity |
|---|---|---|---|---|
| `<title>` length (chars) | {n} | {n} | {n} | {target} |
| Meta description length | {n} | {n} | {n} | {target} |
| `og:image` present | {✓/✗} | {✓/✗} | {✓/✗} | {yes/no} |
| `twitter:card` | {value} | {value} | {value} | {value} |
| JSON-LD types | {Article, …} | {…} | {…} | {must include} |
| Byline structure (DOM) | {✓/✗} | {✓/✗} | {✓/✗} | {yes/no} |
| Word count (rendered) | {n} | {n} | {n} | {target range} |

(Or: `Top-3 on-page benchmark: skipped — Firecrawl not installed.`)

## Internal linking plan
| From existing page | Anchor text | Target section |
|---|---|---|
| {url} | {anchor} | {section} |

## AI Search angle
- LLMs currently cite {brands} for this query.
- To earn mentions: {specific actions, e.g., add a comparison table, cite a primary study, include a structured data block}.

## Deliverables
- Word count target: {n}
- Tone and voice: {guidance from domain overview}
- Required assets: {images, schema, examples}

## Traffic potential
- Conservative: ~{n}/mo at position 5
- Target: ~{n}/mo at position 1-3

## Raw data references
- 01-domain-overview.md
- 02-competitors.md
- 03-keyword-gaps.md
- 04-serp-and-keywords.md
- 05-content-analysis.md
- 06-internal-links.md
```

## Tips

- Respect SE Ranking Data API rate limit: 10 requests per second. Iterate sequentially, do not fan out across 20 keywords in parallel.
- **Firecrawl cost.** Step 6's competitor benchmark adds 3 Firecrawl credits per run (1 per top-3 winner). Pass `--no-firecrawl` to skip it (the brief still ships, just without the on-page benchmark table).
- If the user only provides a domain and no topic, run step 3 first and present the top 3 gap opportunities before deciding.
- Keep the brief self-contained. A freelance writer should not need to open the raw-data files unless they want to double-check something.
- Do not hallucinate keyword difficulty or volume. If an endpoint returns null, mark the field unknown in the brief rather than guessing.
- If the topic triggers AI Overviews, the AI Search angle section is mandatory, not optional. Growth in this era requires being citable by LLMs.
