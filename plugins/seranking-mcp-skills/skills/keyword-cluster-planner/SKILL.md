---
name: keyword-cluster-planner
description: Turn a list of seed keywords into intent-grouped clusters with search volume, a pillar plus spokes content architecture, and H1/H2 suggestions per cluster. Use when the user asks for keyword clustering, content cluster planning, topical map, pillar content strategy, keyword grouping by intent, or wants to plan a content calendar from a keyword list.
---

# Keyword Cluster Planner

Transform seed keywords into a prioritised cluster plan: each cluster grouped by search intent and theme, with volume totals, a pillar concept, spoke articles, and suggested H1/H2 for each spoke.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- User provides: (a) 3 to 20 seed keywords, (b) target market country (default: `us`), and optionally (c) minimum volume threshold (default: 100/mo), (d) maximum KD (default: 60).

## Process

1. **Expand seeds** `DATA_getRelatedKeywords`, `DATA_getSimilarKeywords`, `DATA_getLongTailKeywords`
   - For each seed, pull related + similar + long-tail variants in the target country.
   - Target at least 100 candidate keywords per seed; de-duplicate across seeds.

2. **Question-based expansion** `DATA_getKeywordQuestions`
   - Pull question-intent keywords for the top 5 seeds.
   - These usually become spoke articles with PAA/featured-snippet potential.

3. **Clean and filter**
   - Remove keywords below min volume and above max KD.
   - Strip branded terms the target does not own.
   - Tag each keyword with detected intent: informational, commercial, transactional, navigational.

4. **Cluster**
   - Group by theme using semantic similarity (token overlap + entity match).
   - Target 5 to 12 clusters. Each cluster gets a name, primary keyword, secondary keywords, total volume, weighted KD.
   - Classify each cluster as pillar-worthy (broad, high volume, informational) or spoke-only (narrow, specific).

5. **Pillar plus spokes architecture**
   - For each pillar cluster, nominate 3 to 7 spoke articles (each one from a sub-cluster or question).
   - For each spoke, draft an H1 and 3 to 5 H2s.
   - Map internal-link structure: pillar links to all spokes, spokes link back to pillar, spokes cross-link where topically adjacent.

6. **Prioritise**
   - Score each cluster: volume (40%) + inverse KD (30%) + commercial intent weighting (30%).
   - Output a prioritised build order.

## Output format

Create a folder `keyword-cluster-planner-{target-slug}-{YYYYMMDD}/` with:

```
keyword-cluster-planner-{target-slug}-{YYYYMMDD}/
├── 01-seed-expansion.md
├── 02-filtered-keywords.md
├── 03-cluster-assignment.md
├── keywords.csv
└── PLAN.md
```

`PLAN.md` follows this shape:

```markdown
# Cluster Plan: {topic}
Market: {country}
Seeds: {seed list}

## Summary
- Keywords analysed: {n}
- Clusters formed: {n}
- Estimated combined monthly volume: {n}
- Pillars: {n}, spokes: {n}

## Build order

### Cluster 1: {cluster name} [PILLAR]
- Primary keyword: {kw} ({volume}/mo, KD {kd})
- Secondary: {list}
- Total volume: {n}/mo
- Priority score: {n}

#### Pillar page
- H1: {H1}
- H2s: {list}

#### Spoke articles
1. **{spoke title}**
   - H1: {H1}
   - H2s: {list}
   - Target keyword: {kw} ({volume})
2. **{spoke title}** ...

### Cluster 2: {cluster name} [SPOKE-ONLY]
...

## Internal linking map
- Pillar A links to: spokes A1, A2, A3
- Spoke A1 links back to: pillar A, and cross-links to spoke B2 (topical overlap)
...

## Raw data
- keywords.csv: full enriched keyword list
- 03-cluster-assignment.md: every keyword and its cluster
```

`keywords.csv` columns:
`keyword,volume,kd,cpc,intent,cluster,role_in_cluster`

## Tips

- Respect Data API rate limit: 10 requests per second. With 20 seeds and 3 expansion endpoints, this is ~60 calls; pace sequentially.
- Call `DATA_getCreditBalance` before running. A full pass on 10 seeds typically consumes 30–80 credits; 20 seeds can exceed 150.
- Do not lump different intents into the same cluster even if the keywords are semantically similar. "Best X" (commercial) and "What is X" (informational) deserve separate content.
- Pillar pages fail when they try to rank for too narrow a query. The primary keyword of a pillar cluster should have volume > 1,000/mo and be broad enough to justify a 3,000+ word article.
- The priority score is a starting point, not a mandate. Ask the user to review the top 3 clusters before committing a quarter of content.
- If two clusters share more than 60% of their keywords, merge them.
