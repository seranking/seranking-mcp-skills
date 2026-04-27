---
name: seo-content-audit
description: E-E-A-T + CITE quality audit for an EXISTING piece of content. Scores Experience, Expertise, Authoritativeness, Trustworthiness, and citation-readiness for AI search; surfaces veto items that block publication; produces a publish / publish-with-fixes / no-publish verdict. Distinct from `seo-content-brief` (produces a NEW article from a topic) and from `seo-page` (URL-level keyword/traffic intelligence). Use when the user asks "content quality audit", "E-E-A-T check", "is this content good", "review this article", "content audit", "citation readiness", or "AI search readiness".
---

# Content Quality Audit

Score an existing piece of content against modern E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness) and CITE (Clear answer, Include primary stats, Timestamp, Entity authority) rubrics. Surface veto items that block publication regardless of overall score. Produce a clear publish / publish-with-fixes / no-publish verdict with the top 5 fixes.

## Prerequisites

- SE Ranking MCP server connected.
- Claude's `WebFetch` tool available.
- User provides: (a) the URL of an existing piece of content (or pasted content + intended URL), (b) target keyword the content is meant to rank for. Optional: target country (default `us`).

## Process

1. **Fetch content** `WebFetch`
   - Pull the page HTML.
   - Extract: byline, publish date, last-updated date, schema types (especially `Article`/`BlogPosting`/`Person`), word count, H-tag hierarchy, source citations (links to authorities, numbered references), images, tables, code blocks, comment thread (if present).

2. **AIO context** `DATA_getAiOverview` and `DATA_getAiOverviewLeaderboard`
   - For the target keyword: is there an AIO?
   - Who is cited in the AIO?
   - Is the candidate URL cited?
   - What patterns characterise the cited sources (publication tier, freshness, structure)?

3. **AIO prompt sampling** `DATA_getAiPromptsByTarget`
   - Sample LLM prompts where the target URL's domain appears as a source.
   - Cross-reference with the candidate URL — does it show up in any sampled prompts?

4. **Score E-E-A-T** using `references/core-eeat.md`
   - 60-item rubric across 4 dimensions (15 items each).
   - Per-item: yes/no/partial. Compute dimension scores (0–100% each).
   - Apply 3 veto checks (anonymous author on YMYL topic / no sources on factual claims / undisclosed affiliate links). Any veto = no-publish.

5. **Score CITE** using `references/cite.md`
   - 30-item CITE rubric (Clear answer in 1st 200 words, Include primary stats, Timestamp freshness, Entity authority).
   - Per-item: yes/no/partial. Compute dimension scores.
   - Apply 3 veto checks (no answer in first 300 words / no datestamp on time-sensitive content / no entity disambiguation for proper-noun queries).

6. **Cross-check against AIO winners**
   - For the patterns characteristic of cited sources (from step 2), evaluate the candidate against each: does it have what the cited sources have?
   - Surface specific gaps.

7. **Synthesise verdict** using `templates/verdict.md`
   - **Publish:** E-E-A-T ≥ 75%, CITE ≥ 70%, no vetoes triggered.
   - **Publish with fixes:** E-E-A-T 60–74% OR CITE 55–69%, no vetoes. Top 5 fixes specified.
   - **No publish:** any veto triggered, OR E-E-A-T < 60%, OR CITE < 55%. Substantial rewrite needed.

## Output format

Create a folder `seo-content-audit-{target-slug}-{YYYYMMDD}/` with:

```
seo-content-audit-{target-slug}-{YYYYMMDD}/
├── 01-content-snapshot.md       (HTML extracts + page metadata)
├── 02-aio-context.md            (AIO presence, citations, patterns)
├── 03-eeat-scoring.md           (60-item rubric scored)
├── 04-cite-scoring.md           (30-item rubric scored)
├── 05-aio-winner-comparison.md  (gap vs cited sources)
└── VERDICT.md                   (publish / publish-with-fixes / no-publish)
```

`VERDICT.md` follows this shape (also see `templates/verdict.md`):

```markdown
# Content Audit: {URL or title}

> Audited {YYYY-MM-DD} · Target keyword: "{keyword}" · Country: {country}

## Verdict: {PUBLISH | PUBLISH WITH FIXES | NO PUBLISH}

{One sentence summary of why}

## Scores

| Dimension | Score | Threshold | Status |
|---|---|---|---|
| Experience | {n}% | 75% | {✓/✗} |
| Expertise | {n}% | 75% | {✓/✗} |
| Authoritativeness | {n}% | 75% | {✓/✗} |
| Trustworthiness | {n}% | 75% | {✓/✗} |
| **E-E-A-T composite** | {n}% | 75% | {✓/✗} |
| Clear answer | {n}% | 70% | {✓/✗} |
| Include stats | {n}% | 70% | {✓/✗} |
| Timestamp | {n}% | 70% | {✓/✗} |
| Entity authority | {n}% | 70% | {✓/✗} |
| **CITE composite** | {n}% | 70% | {✓/✗} |

## Veto checks

- {Veto 1}: {triggered / not triggered}
- {Veto 2}: {triggered / not triggered}
- {Veto 3}: {triggered / not triggered}
- ...

## AI Search readiness
- AIO present for "{keyword}": {yes/no}
- Top citation patterns: {list}
- Candidate URL cited in any sampled AIO: {yes/no}
- Gap vs cited sources: {bulleted gaps}

## Top 5 fixes

1. {Specific fix linked to a low-scored item or veto}
2. ...
5. ...

## Detailed scoring

See:
- 03-eeat-scoring.md (item-by-item E-E-A-T)
- 04-cite-scoring.md (item-by-item CITE)
- 05-aio-winner-comparison.md (gap analysis)
```

## Tips

- Respect rate limit. AIO + AIO-prompts queries are ~5–10 calls; plenty of headroom.
- Call `DATA_getCreditBalance` before running. ~10–15 credits typical.
- The thresholds (75% E-E-A-T, 70% CITE) are starting points. Tune per domain — a YMYL site (medical, financial) should require higher (85%/80%); a general-interest blog can run lower (65%/60%).
- The veto checks are not negotiable. A piece with anonymous authorship on a YMYL topic doesn't pass regardless of score.
- For pieces that score "publish with fixes," the top-5 list is the deliverable. Hand it to the writer; re-audit after fixes.
- Pair with `seo-content-brief` for the new-article counterpart: this skill audits existing content, content-brief produces new content.
- Pair with `seo-sxo` if the page has technical/page-type issues — that's a different diagnosis.
- The 60-item E-E-A-T rubric and 30-item CITE rubric are in `references/`. They are opinionated — adjust for your domain's editorial standards.
