---
name: seo-sxo
description: Diagnose why a page is not ranking by reading the SERP backwards. Identifies the page type Google rewards for the target keyword, scores the candidate page against that pattern from multiple persona perspectives, and recommends the page format that would win the SERP. Use when the user asks "why isn't this page ranking", "page type mismatch", "SXO", "search experience optimization", "intent mismatch", or wants a wireframe.
---

# SEO SXO — Search Experience Optimization

Diagnose why a "well-optimized" page doesn't rank. Reads the actual SERP for the target keyword, infers the page type Google is rewarding, scores the candidate page against that pattern from multiple persona perspectives, and recommends the page format that would win the SERP.

> **Acknowledgements:** SXO-as-a-skill framework originated in `claude-seo` by AgriciDaniel (with the original concept credited to Florian Schmitz, Pro Hub Challenge). MIT-licensed both directions; this implementation is independent but the framing is theirs.

## Prerequisites

- SE Ranking MCP server connected.
- Claude's `WebFetch` tool available.
- User provides: (a) target page URL, (b) target keyword the page is meant to rank for, optionally (c) target country (default `us`).

## Process

1. **Validate inputs.** Both URL and keyword are required. If keyword missing, ask the user — don't infer.

2. **Pull the SERP** `DATA_getSerpResults` and `DATA_getSerpTaskAdvancedResults`
   - Top 10 organic results with URL, title, snippet.
   - SERP features: AI Overview presence, People Also Ask, image carousel, video carousel, shopping pack, Twitter pack, Featured Snippet, etc.
   - **Mode selection (cost driver — read this).** SERP feature data (AIO/PAA/carousels) only comes back when the task runs with `result_type=advanced`. That is also the most expensive single call this skill makes (≈ 700 credits per keyword on heavily-trafficked terms in the 2026-04 validation run).
     - **Default — `mode=full`:** runs `result_type=advanced`. Returns features + organic. Use when persona scoring needs PAA / AIO / pack signals (most cases).
     - **`mode=lite` (`result_type=standard`):** organic top-10 only, no SERP features, ≈ 50–100 credits. Use when (a) the user is screening many keywords and SERP features aren't load-bearing, (b) credits are constrained, (c) the user explicitly asks for a cheap pass. The persona scoring still runs but the SERP-features row in `SXO-REPORT.md` will read `(skipped — lite mode)` and the dominant-pattern detection will rely on URL/title heuristics alone.
     - Surface the chosen mode + estimated cost up front. If the user didn't specify and the keyword looks ad-heavy or commercial-high-volume, recommend `mode=lite` first and re-run with `mode=full` only if dominant-pattern confidence is low.

3. **Pull AIO context** `DATA_getAiOverview`
   - If AIO is present for the keyword, capture the answer text and citation list.
   - Note which top-10 organic results are also cited in the AIO.

4. **Fetch user's page + top 3 winners** `WebFetch` (always) + `mcp__firecrawl-mcp__firecrawl_scrape` (when available)
   - **WebFetch first** (free): pull markdown for the user's page + top 3 winners. Extract `<title>`, all H-tags, primary content structure (numbered list / table / prose / Q&A), word count, image mentions, comparison-table presence, CTA mentions.
   - **Firecrawl second** (4 Firecrawl credits typical — 1 per page) — recovers what WebFetch can't show:
     - JSON-LD `@type`s per page (Product, FAQPage, BreadcrumbList, Article, Review, ItemList, etc.) — these are **load-bearing** for page-type classification in step 5. WebFetch's markdown can't see schema.
     - `og:title` / `og:image` / `twitter:card` from `metadata`.
     - Real `<title>` length (the markdown first-heading is sometimes wrong).
   - **`--screenshots` flag (opt-in, +4 Firecrawl credits):** when passed, also call `firecrawl_scrape` with `formats: ["screenshot"]` on the user's page + top 3 winners. Save as `screenshots/{page}.png`. Reference in the wireframe (step 8) to ground recommendations in the visual layout, not just the text outline.
   - **If Firecrawl unavailable (or `--no-firecrawl` passed):** WebFetch portion runs. Page-type classification in step 5 falls back to URL/title heuristics + content-structure heuristics only — schema-based classification is skipped. Note in `02-page-type-classification.md`: `Schema-based classification: skipped — Firecrawl required.` Confidence in dominant-pattern detection drops accordingly.

5. **Classify each top-10 result by page type**
   - Use the heuristics in `references/page-type-patterns.md`.
   - For each: assign one of {comparison, alternatives, listicle, how-to, definition, product, editorial, forum, video}.
   - Note signals that informed the classification (URL pattern, title pattern, schema, content structure).

6. **Detect the dominant pattern**
   - Count types in top 10. If one type ≥ 6, that's dominant.
   - If two tie at 4–4, the SERP is "split intent" — both work; commercial vs informational angle determines which to choose.
   - Cross-reference with SERP features: video carousel → expect ≥ 2 video results; PAA → expect informational results; shopping pack → commercial intent dominant; AIO → informational consensus.

7. **Score the user's page** against the dominant pattern × 4 personas
   - Use the rubrics in `references/persona-rubrics.md`.
   - 4 personas: Skimmer, Researcher, Buyer, Validator.
   - 0–10 per persona. Apply the intent-weighting profile (also in persona-rubrics.md) to get a single 0–100 SXO score.

8. **Synthesise verdict and wireframe**
   - If user's page type matches dominant: SXO score reflects how well it executes the pattern. Recommend specific persona-targeted improvements.
   - If user's page type does NOT match dominant: this is the "page-type mismatch" case. Output a wireframe for the dominant page type, anchored in observed patterns from the top 3 winners.
   - Write `SXO-REPORT.md`.

## Output format

Create a folder `seo-sxo-{target-slug}-{YYYYMMDD}/` with:

```
seo-sxo-{target-slug}-{YYYYMMDD}/
├── 01-serp-snapshot.md            (top 10 + features + AIO)
├── 02-page-type-classification.md (each top-10 result classified)
├── 03-user-page-fingerprint.md    (the candidate page's structure)
├── 04-persona-scores.md           (4 personas × current page)
├── 05-recommendation.md           (verdict + page-type-winning wireframe)
├── screenshots/                   (only if --screenshots ran: candidate.png + winner-1/2/3.png)
└── SXO-REPORT.md                  (executive summary deliverable)
```

`SXO-REPORT.md` shape:

```markdown
# SXO Report: {URL} for keyword "{keyword}"

> Snapshot dated {YYYY-MM-DD} · Country: {country}

## SERP profile
- Top 10 page types: {comparison: 4, listicle: 3, editorial: 2, video: 1}
- Dominant pattern: **{pattern}** ({n} of 10)
- SERP features: AIO ✓ ({n} citations), PAA ✓ ({n} questions), Image carousel ✗, Video carousel ✗, Shopping pack ✗
- Intent: {informational | commercial-investigation | transactional | navigational}

## Your page
- Page type: **{detected type}**
- Page-type match with dominant: **{✓ match | ✗ MISMATCH — see Verdict}**
- Word count: {n}
- Primary content structure: {prose | numbered-list | table | step-blocks | Q&A | mixed}

## SXO score: **{score}/100**

| Persona | Weight | Score | Notes |
|---|---|---|---|
| Skimmer | {%} | {n}/10 | {1-line note} |
| Researcher | {%} | {n}/10 | {1-line note} |
| Buyer | {%} | {n}/10 | {1-line note} |
| Validator | {%} | {n}/10 | {1-line note} |

## Verdict

{One paragraph. If page type matches: "Your page is the right type for this SERP. The score gap is {X} points — see persona-specific gaps below." If MISMATCH: "Your page is a {your type} but the SERP rewards {dominant type}. No amount of on-page optimization will close the gap; ship a {dominant type} page instead. Wireframe below."}

## If MISMATCH — wireframe for the winning page type

\`\`\`
{Page title pattern — e.g., "{Brand A} vs {Brand B}: 2026 Comparison"}

[Hero / TL;DR — first 200 words answer the comparative question]
[Comparison table — must be visually dominant]
[Section per dimension — each with H2 named after the dimension]
[Verdict / recommendation — explicit, justified]
[FAQ — top 3–5 PAA questions]
[Schema — Product (×2) + BreadcrumbList + FAQPage]
\`\`\`

## If MATCH — top 3 changes by persona

1. {Skimmer}: {specific change}
2. {Researcher}: {specific change}
3. {Buyer or Validator}: {specific change}

## Raw data
- 02-page-type-classification.md — every top-10 result, classified
- 03-user-page-fingerprint.md — your page's signals
- 04-persona-scores.md — full persona-by-persona breakdown
```

## Tips

- Respect rate limit: 10 req/sec. The SERP calls in step 2/3 are fast; WebFetch calls in step 4 dominate latency, not API.
- **Cost is mode-dependent.** `mode=full` is ~750–900 SE Ranking credits per run (the SERP-advanced call dominates). `mode=lite` is ~80–150 SE Ranking credits. Always call `DATA_getCreditBalance` before running and surface the estimate against remaining balance. Step 4 adds 4 Firecrawl credits when Firecrawl is available, +4 more if `--screenshots` is passed. Pass `--no-firecrawl` to skip both.
- **`result_type=advanced` is the only way to get AIO / PAA / pack data.** The standard SERP endpoint returns organic-only. Don't try to reconstruct SERP features from organic results — that's the cost the user is paying for.
- Page-type classification is a heuristic — `references/page-type-patterns.md` documents the signals so users can override. If the heuristic gets a result wrong, edit that file with the correction.
- The 4 personas are opinionated. They come from the framework's original source — don't invent more without good reason.
- The SXO score is directional. An 85/100 doesn't guarantee ranking; a 35/100 strongly suggests the page won't break through. Treat as a diagnostic, not a forecast.
- When the dominant pattern is split-intent (4-4), ship two pages — one per intent — rather than trying to make one page serve both. Google's SERPs reflect this split for a reason.
- The wireframe in MISMATCH mode is a starting point. The user still needs to write the content. This skill diagnoses; `seo-content-brief` produces the writer-ready brief.
