---
name: ai-search-share-of-voice
description: Measure AI Search share of voice for a target domain versus competitors across ChatGPT, Perplexity, Gemini, Google AI Overview, and AI Mode. Pulls the AIO leaderboard, then samples prompts where each domain appears as a source or brand mention, and analyses topic clusters each brand owns. Use when the user asks for AI Search share of voice, LLM visibility tracking, AEO/GEO analysis, AI Overview competitive analysis, or wants to know which brands LLMs cite in their category.
---

# AI Search Share of Voice

Compare AI-search visibility for a target brand against competitors across every major LLM engine, then analyse the topic clusters each brand owns and where gaps exist.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- User provides: (a) target domain and its brand name, (b) list of competitor domains and brand names, (c) country (default: `us`), and (d) optionally, which engines to analyse (default: all supported: `ai-overview`, `chatgpt`, `perplexity`, `gemini`, `ai-mode`).

## Process

1. **Leaderboard snapshot** `DATA_getAiOverviewLeaderboard`
   - Pull the AIO leaderboard for the target domain's category in the target country.
   - Capture mention counts and share percentages per engine, per domain.

2. **Heatmap table**
   - Build a table: rows = domains (target + competitors), columns = engines, cells = % share of voice.
   - Highlight the leader per engine and the worst performer.

3. **Prompt sampling per domain** `DATA_getAiPromptsByBrand`, `DATA_getAiPromptsByTarget`
   - For each domain (target and each competitor):
     - Pull 10 ChatGPT prompts where the domain appears as a source (link mention).
     - Pull 10 ChatGPT prompts where the brand is mentioned by name.
   - Save query text and the exact sources cited so the user can validate.

4. **Topic clustering**
   - Group prompts by theme (e.g., pricing, feature comparison, tutorials, alternatives, reviews).
   - For each brand, note which clusters it dominates and which it is absent from.

5. **Gap and recommendation synthesis**
   - Identify 3 to 5 topic clusters where the target underperforms competitors despite having relevant content.
   - Recommend specific actions: new content angles, structured data additions, partnerships with frequently-cited sources, comparison pages, FAQ/How-To schema.

## Output format

Create a folder `ai-sov-{target-slug}/` with:

```
ai-sov-{target-slug}/
├── 01-leaderboard.md         # raw leaderboard per engine
├── 02-heatmap.md             # visual heatmap table
├── 03-prompts-{domain}.md    # one file per domain with 20 sampled prompts
├── 04-topic-clusters.md      # cluster membership per brand
└── REPORT.md                 # executive summary
```

`REPORT.md` follows this shape:

```markdown
# AI Search Share of Voice: {target brand} vs competitors

## Summary
- Target: {target} ({share}% across all engines)
- Leader: {leader brand} ({share}%)
- Target rank: {n} of {total}

## Heatmap

| Domain | AI Overview | ChatGPT | Perplexity | Gemini | AI Mode |
|---|---|---|---|---|---|
| {target} | {%} | {%} | {%} | {%} | {%} |
| {comp1} | ... | ... | ... | ... | ... |

## Who owns what

### {target brand}
Strong in: {cluster 1}, {cluster 2}
Absent from: {cluster 3}, {cluster 4}

### {competitor 1 brand}
...

## Topic cluster ownership

| Cluster | Leader | Share | Target position | Gap |
|---|---|---|---|---|
| Pricing | {brand} | {%} | {n} | {% behind} |
| Alternatives | {brand} | {%} | {n} | {% behind} |
| Tutorials | {brand} | {%} | {n} | {% behind} |

## Top 5 actions to close gaps
1. {action with target cluster}
2. ...
```

## Tips

- Do not hallucinate citation counts. If the API returns zero prompts for a given domain/engine, report zero, do not estimate.
- For each competitor, validate the brand-name match in the prompt text. Sometimes "Wix" appears in a sentence about "wiktionary" or a person's name. Flag ambiguous matches in the raw-prompt file.
- `base_domain` scope is the default; do not narrow to `subdomain` unless the user asks.
- Respect Data API rate limit: 10 requests per second. With 5 domains and 2 prompt queries per engine per domain, pace the loop.
- The report is not a one-time artefact. Recommend the user re-run monthly and diff results to see ranking momentum.
