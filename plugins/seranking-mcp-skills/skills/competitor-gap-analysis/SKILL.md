---
name: competitor-gap-analysis
description: Compare a target domain to its top organic competitors and surface keywords the competitors rank for that the target does not, filtered by intent, volume, and difficulty. Use when the user asks for a competitor gap analysis, keyword gap, organic content gap, missing keyword opportunities, or wants to see what their competitors are ranking for that they are not.
---

# Competitor Gap Analysis

Identify the specific keywords your competitors rank for in the top 20 that your domain does not, ranked by commercial value and realistic capture difficulty.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- User provides: (a) target domain, (b) 3 to 5 competitor domains (or ask the skill to auto-discover them), (c) market country (default: `us`), and optionally filters (min volume, max KD, intent).

## Process

1. **Validate or discover competitors** `DATA_getDomainCompetitors`
   - If the user did not provide competitors, pull the top 5 organic competitors for the target in the target market.
   - Surface the list to the user and ask them to confirm or override before proceeding.

2. **Pull competitor keyword sets** `DATA_getDomainKeywords`
   - For each competitor, pull keywords where they rank in the top 20 of the target country.
   - Save per-competitor lists.

3. **Pull target keyword set** `DATA_getDomainKeywords`
   - For the target domain, pull all ranking keywords in the target country (any position).
   - This is the exclusion set.

4. **Compute the gap** `DATA_getDomainKeywordsComparison` (cross-check)
   - Keywords ranked by at least one competitor in the top 20 but not ranked by the target domain at all.
   - Use the comparison endpoint as a cross-check.

5. **Filter and segment**
   - Apply user-specified filters on volume, KD, and intent.
   - Segment by intent: informational, commercial, transactional, navigational.
   - Segment by competition: how many of the N competitors rank for each gap keyword.

6. **Score and prioritise**
   - Score each gap keyword: traffic potential (volume × CTR model) + intent weighting + inverse KD.
   - Surface the top 50 opportunities with reasoning per keyword.

7. **Map to content actions**
   - For each top opportunity, recommend: new article, expand existing page, refresh existing page, programmatic template.
   - Flag quick wins: competitors rank with thin content (detected by URL pattern and content-length heuristics).

## Output format

Create a folder `gap-{target-slug}/` with:

```
gap-{target-slug}/
├── 01-competitors.md
├── 02-competitor-keywords-{domain}.md   # one per competitor
├── 03-target-keywords.md
├── 04-gap-raw.md
├── gaps.csv
└── REPORT.md
```

`REPORT.md` follows this shape:

```markdown
# Competitor Gap: {target}
Market: {country}
Competitors analysed: {list}

## Summary
- Competitor keywords in top 20: {n}
- Target keywords overall: {n}
- Gap keywords (opportunities): {n}
- Gap traffic potential: ~{n}/mo

## Top 50 opportunities

### Informational intent
| # | Keyword | Volume | KD | Competitors ranking | Action | Score |
|---|---|---|---|---|---|---|
| 1 | {kw} | {n} | {n} | {3 of 5} | New article | {score} |
| 2 | ... | ... | ... | ... | ... | ... |

### Commercial intent
| # | Keyword | Volume | KD | Competitors ranking | Action | Score |
|---|---|---|---|---|---|---|
...

### Transactional intent
...

## Quick wins (top 10)
Keywords where competitors rank in positions 5 to 20 with thin content, low DT, or old dates.

| # | Keyword | Weakest competitor position | Suggested angle |
|---|---|---|---|
| 1 | {kw} | example.com at #14 (2022 article, 800 words) | Fresh, comprehensive guide |

## Recommended next steps
1. Run `content-brief` on the top 3 opportunities to generate writer-ready briefs.
2. Run `keyword-cluster-planner` on the full gap list to build a sequencing plan.
3. Add the gap keywords to an SE Ranking project for rank tracking once content ships.

## Files
- gaps.csv: full gap list for spreadsheet analysis
- 04-gap-raw.md: human-readable full gap list before filtering
```

`gaps.csv` columns:
`keyword,volume,kd,cpc,intent,competitors_ranking,top_competitor_position,target_position,action,score`

## Tips

- Data API rate limit: 10 requests per second. For large sites, `DATA_getDomainKeywords` may paginate heavily; set a ceiling (e.g., top 1,000 keywords per domain) unless the user explicitly asks for the full set.
- The `competitors_ranking` count is the best signal of realism. Keywords ranked by 4 of 5 competitors are validated opportunities; keywords ranked by only 1 may be noise.
- Do not recommend capturing branded competitor keywords unless the user explicitly asks. Pivoting to compete on "competitor brand review" is a viable strategy but only if the user opts in.
- When many gap keywords cluster around a theme, recommend a hub page plus cluster rather than 50 individual articles.
- Chain this skill with `content-brief` and `keyword-cluster-planner` naturally. Mention them in the Recommended next steps section of the output.
