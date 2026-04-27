---
name: seo-backlinks-profile
description: Full backlink profile for a domain — referring domains, anchor text distribution, authority distribution, IP and subnet diversity, growth/decay trend, toxic-candidate flagging. Distinct from `seo-backlink-gap` (which is gap-vs-competitor only). Produces a profile health score and reviewable disavow candidate list (never auto-disavow). Use when the user asks "backlink profile", "link profile audit", "anchor distribution", "toxic links", "disavow candidates", or "backlink health".
---

# Backlinks Profile

A complete backlink profile audit for a domain. Surfaces composition (where do links come from?), quality (what's the authority distribution?), diversity (concentrated in a few IPs/subnets, or spread out?), trajectory (growing or decaying?), and risk (which links look manipulative?). Output includes a health score and a reviewable disavow-candidate list — never an auto-disavow.

## Single-source by design

This skill consults **only the SE Ranking backlink index**. We don't blend Ahrefs / Moz / Majestic / DataForSEO / Common Crawl into the same report. That's a deliberate choice, not a limitation:

- **Internally consistent metrics.** Authority scores, anchor counts, and refdomain totals are computed against a single crawl. Multi-source blends produce numbers that look authoritative but actually average across crawls with different sampling, different freshness, and different definitions of "backlink" — the resulting ratios (e.g. dofollow %, anchor distribution) are noise.
- **Reproducible health scores.** The 100-point health score in this report can be re-run a quarter later against the same source and the deltas are meaningful. With multi-source blends, a score drift can mean *anything*: source A reweighted, source B refreshed, source C changed its toxic heuristic.
- **No data-source independence to model.** Any "do these sources agree?" question is unanswerable without a second backlink graph; we don't pretend to answer it. If you need cross-source confirmation (e.g. before legal disavow, before a high-stakes outreach campaign), pair this profile with a manual spot-check against Ahrefs/Majestic — that's a research task, not a skill output.

If your workflow specifically *requires* multi-source blending (large agencies, link-builders billing on link counts), this skill is the wrong tool — use a vendor that aggregates multiple indexes. For everyone else, single-source produces the more honest report.

## Prerequisites

- SE Ranking MCP server connected.
- User provides: a target domain.
- Claude's `WebFetch` tool optional (for spot-checking flagged toxic candidates).
- `mcp__firecrawl-mcp__firecrawl_scrape` optional (for the new step 8b — link-source verification).

## Process

1. **Validate & preflight**
   - Normalise domain.
   - `DATA_getCreditBalance` — surface remaining credits. Profile run is moderate cost.
   - **Firecrawl availability check.** If `mcp__firecrawl-mcp__firecrawl_scrape` is available, the optional step 8b (link-source verification) is offered — scrapes top-20 referring domains' linking pages to verify the link is still present and what `rel` attribute it carries (dofollow / nofollow / sponsored / UGC). Cost: 20 Firecrawl credits per run. Default off — opt in with `--verify-sources`. Pass `--no-firecrawl` to skip even if available.

2. **Profile summary** `DATA_getBacklinksSummary`
   - Total backlinks, total referring domains, dofollow/nofollow ratio, link-type distribution (text / image / form / frame), growth velocity over the last 30/90 days.

3. **Referring domains** `DATA_getBacklinksRefDomains`
   - Top N referring domains by authority. Pull authority score, link count per domain, domain TLD, country.

4. **Anchor distribution** `DATA_getBacklinksAnchors`
   - Top anchor texts by frequency.
   - Classify each anchor: branded (contains brand name), exact-match commercial (the target's primary commercial keyword), partial-match, generic ("click here", "read more", "this page"), naked URL, image-alt-derived.

5. **Authority distribution** `DATA_getBacklinksAuthority` and `DATA_getDistributionOfDomainAuthority`
   - Histogram of referring-domain authority: how many DA 0-9, 10-19, 20-29, etc.
   - A healthy profile has a long tail; an unhealthy profile is concentrated at DA<10.

6. **IP and subnet diversity** `DATA_getReferringIps`, `DATA_getReferringIpsCount`, `DATA_getReferringSubnetsCount`
   - Total unique IPs hosting referring domains.
   - Total unique /24 subnets.
   - Compute concentration ratio: `referring_domains / unique_subnets`. Healthy: ~3–10. Unhealthy: many domains share few subnets (PBN signal).

7. **Growth / decay trend** `DATA_getNewLostBacklinksCount`, `DATA_getNewLostRefDomainsCount`
   - Net new backlinks per month (last 6 months).
   - Net new referring domains per month.
   - Velocity changes — sharp spikes or sharp losses both deserve flags.

8. **Lost links list** `DATA_listNewLostBacklinks`, `DATA_listNewLostReferringDomains`
   - Sample recent losses. Are any high-authority losses?

8b. **Optional: live link-source verification** `mcp__firecrawl-mcp__firecrawl_scrape`
   - Triggered only when `--verify-sources` is passed (default off — credit-conscious).
   - For the top 20 referring domains by authority (from step 3), pick the highest-authority linking page per domain. Scrape each (20 Firecrawl credits typical).
   - For each scrape, parse the returned `html` for `<a href>` matching the target domain. Capture: link still present (`true`/`false`/`page-404`), `rel` attribute (`dofollow` if absent or empty, else the literal value: `nofollow`, `ugc`, `sponsored`, or combinations), surrounding context (anchor text + 50 chars before/after).
   - Surface mismatches against the SE Ranking-reported state in `08b-source-verification.md`:
     - Link gone — SE Ranking still reports it as live (lag/error).
     - `rel` attribute differs from what SE Ranking flagged.
     - Source page returns non-200.
   - Feeds into step 9: a verified-gone link or `rel=nofollow` discovered post-hoc upgrades the toxic-candidate signal for that referring domain.
   - **If Firecrawl unavailable (or flag not passed):** skip entirely. SE Ranking's flagged state remains the source of truth — the skill's "Single-source by design" framing already explains why that's a deliberate trade-off.

9. **Toxic candidate detection** (heuristic — see Tips for the rules)
   - Apply the toxic heuristic to the referring-domain list.
   - Flag candidates. Each row gets a `risk_score` and `triggers` (which heuristic rules fired).
   - **Never auto-disavow.** Output is a reviewable list, not an action.

10. **Synthesise** `PROFILE.md`

## Output format

Create a folder `seo-backlinks-profile-{target-slug}-{YYYYMMDD}/` with:

```
seo-backlinks-profile-{target-slug}-{YYYYMMDD}/
├── 01-summary.md              (DATA_getBacklinksSummary top-line)
├── 02-referring-domains.md    (top N with authority)
├── 03-anchors.md              (anchor distribution + classification)
├── 04-authority-distribution.md (histogram)
├── 05-diversity.md            (IPs + subnets + concentration)
├── 06-trend.md                (last 6 months new/lost)
├── 07-losses-sample.md        (recent lost backlinks)
├── 08b-source-verification.md (only if --verify-sources ran: live link + rel attribute checks for top-20 sources)
├── disavow-candidates.csv     (toxic-flagged rows for review)
└── PROFILE.md                 (synthesised report)
```

`PROFILE.md` follows this shape:

```markdown
# Backlinks Profile: {domain}

> Snapshot dated {YYYY-MM-DD}

## Health score: **{n}/100**

| Dimension | Score | Notes |
|---|---|---|
| Authority distribution | {n}/20 | {comment} |
| Anchor diversity | {n}/20 | {comment} |
| IP/subnet diversity | {n}/20 | {comment} |
| Growth trajectory | {n}/20 | {comment} |
| Toxic candidate ratio | {n}/20 | {comment} |

## Top-line numbers

| Metric | Value |
|---|---|
| Backlinks | {n} |
| Referring domains | {n} |
| Dofollow / nofollow | {n}% / {n}% |
| Unique IPs | {n} |
| Unique subnets | {n} |
| Domain : subnet ratio | {ratio} |
| New ref-domains last 30d | {n} |
| Lost ref-domains last 30d | {n} |
| Toxic candidates flagged | {n} ({% of total}) |

## Authority distribution

| DA bucket | Domains | % |
|---|---|---|
| 70+ | {n} | {%} |
| 50–69 | {n} | {%} |
| 30–49 | {n} | {%} |
| 10–29 | {n} | {%} |
| 0–9 | {n} | {%} |

## Anchor distribution

| Class | Count | % | Healthy range | Status |
|---|---|---|---|---|
| Branded | {n} | {%} | 30–60% | {✓/⚠} |
| Generic | {n} | {%} | 15–30% | {✓/⚠} |
| Naked URL | {n} | {%} | 10–25% | {✓/⚠} |
| Partial-match | {n} | {%} | 10–20% | {✓/⚠} |
| Exact-match commercial | {n} | {%} | <5% | {✓/⚠ over-optimised} |
| Image-alt-derived | {n} | {%} | <10% | {✓/⚠} |

## Trend (last 6 months)

| Month | New backlinks | Lost backlinks | Net |
|---|---|---|---|
| {M-5} | {n} | {n} | {n} |
| {M-4} | {n} | {n} | {n} |
| ... |

## Toxic candidates ({n} flagged)

See `disavow-candidates.csv`. Top 10 by risk_score:

| Domain | Authority | Triggers | Risk |
|---|---|---|---|
| {domain} | {DA} | {DA<10, sitewide>5, exact-match-anchor} | High |
| ... |

**⚠ NEVER AUTO-DISAVOW.** Hand this list to a human for review. Disavow a domain only after confirming the link is manipulative AND the domain is not delivering referral traffic AND removal requests have failed.

## Recommended next steps

1. {Action}
2. {Action}
3. {Action}
```

`disavow-candidates.csv` columns: `domain,authority,backlinks_count,sitewide_links,top_anchor,anchor_class,risk_score,triggers,sample_url`

## Tips

- Respect rate limit. The endpoints in steps 2–8 are ~15 calls; pace sequentially.
- Cost: ~25–40 SE Ranking credits typical for a full profile run. Optional step 8b adds 20 Firecrawl credits when `--verify-sources` is passed (one scrape per top-20 source domain).
- **Toxic heuristic rules** (any 2+ triggers = candidate):
  - Authority < 10 (low-trust source).
  - Sitewide link count > 5 (footer/sidebar links across many pages — manipulation signal).
  - Exact-match commercial anchor on >50% of links from this domain.
  - Hosted in known link-farm subnet (when unique IPs / unique subnets ratio is heavily concentrated).
  - Domain name is a non-pronounceable string of characters (very strong PBN signal).
  - TLD is in the high-spam list (`.xyz`, `.click`, `.work` historically; verify against current spam-domain reports).
- **Healthy anchor distribution**: branded should be the largest class (30–60%); exact-match commercial should be small (<5%) — over-optimised commercial anchors trigger Penguin-era penalties.
- **Healthy growth**: steady 10–20% YoY referring-domain growth is the goal. Sharp spikes (>50% in a month) often indicate paid links and trigger algorithmic suspicion.
- **Disavow conservatively.** Removing links via outreach is preferred. Disavow only as a last resort; never disavow domains that send referral traffic.
- Pair with `seo-backlink-gap` for prospecting (gap analysis vs competitors).
- Pair with `seo-drift` to track profile composition over time.
