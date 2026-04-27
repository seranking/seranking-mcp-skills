# CITE rubric (30 items)

CITE = Clear answer, Include primary stats, Timestamp freshness, Entity authority. Tuned for AI-search citation readiness — passages from pages with high CITE scores are the ones LLMs cite.

## Veto items (any one triggers automatic NO PUBLISH)

1. **No clear answer in the first 300 words.** LLMs scan early paragraphs; if the answer isn't there, the page won't be cited.
2. **No datestamp on time-sensitive content.** "Best X 2024" published in 2026 with no last-updated indicator gets passed over.
3. **No entity disambiguation for proper-noun queries.** A page about "Apple" that doesn't specify whether it's Apple Inc. (computers) or Apple Corp (Beatles) loses to clearer pages.

---

## 1. Clear answer (8 items)

The answer is findable, fast, and direct.

1. The primary question / topic of the piece is answered in the first 200 words.
2. The first paragraph is ≤ 60 words and stands alone as a TL;DR.
3. The answer is stated in declarative sentences, not buried in prose ("X is …", not "many people wonder whether X might be…").
4. Headings preview the answer ("How long does X take?" → "X takes 4–6 weeks", not "Let's explore the timeline").
5. Lists, tables, or step blocks present the answer in scannable form where applicable.
6. Numbers, dates, and named entities appear in the answer (specifics that LLMs can extract).
7. The answer is followed by supporting context, not the other way round.
8. No clickbait deferral ("read on to find out…"). The answer is given, then explained.

## 2. Include primary stats (8 items)

The piece references concrete data, with attribution.

1. At least one statistic, percentage, or number cited in the first half.
2. Sources are linked inline next to the stat (not a footnote pile at the end).
3. Sources are primary (the original study, government data, the company's own report) — not aggregator sites.
4. Date of the data is stated near the stat ("per the 2025 X report").
5. Multiple stats triangulate the same claim where possible (one source, then a corroborating source).
6. Methodology of cited data is briefly contextualised (sample size, population, time window).
7. Original data the author generated (survey, analysis, A/B test) is presented with methodology.
8. Where data is contested, that's acknowledged; the piece doesn't cherry-pick.

## 3. Timestamp freshness (7 items)

The reader (and LLM) can tell when this piece is from.

1. Original publish date visible on the page.
2. Last-updated date visible (and different from publish date if updated).
3. Year appears in title, URL, or first H1 if the topic is time-sensitive.
4. Schema.org `datePublished` and `dateModified` populated correctly (ISO 8601).
5. Time-sensitive claims (e.g., "current pricing," "best as of") have explicit dates.
6. Updates log visible if the piece has been substantively revised.
7. Old data points (>2 years) are flagged or replaced.

## 4. Entity authority (7 items)

Proper nouns, brands, people, places are disambiguated and authoritative.

1. The primary entity (brand, product, person, place) is named with full identifier (e.g., "Apple Inc.", not just "Apple") at first mention.
2. Wikipedia / Wikidata disambiguation is referenced or implicit through context.
3. Schema.org markup includes the entity (`Organization`, `Person`, `Product`, `Place`) with `sameAs` links to authoritative profiles.
4. Author byline links to a profile that establishes the author's expertise on this entity.
5. Brand name is consistent across the piece (no informal abbreviations that confuse LLMs).
6. Related entities are introduced with their own brief disambiguation (especially for B2B / niche topics).
7. Citations include canonical entity references (e.g., DOI for papers, official URLs for products).

---

## How to score

For each item, mark ✓ (1), ~ (0.5), or ✗ (0). Dimension score = sum / item-count × 100%. CITE composite = average of 4 dimensions.

## Threshold

- CITE composite ≥ 70% AND no veto = pass for citation-readiness.
- 55–69% = "publish with fixes" — improve the lowest-scoring dimension first.
- < 55% OR any veto = the piece will likely not be cited by AI search; substantial rework needed.

## Why this matters in 2026

LLM citation behavior consistently rewards passage-level extractability. Pages that score well on Clear answer + Include primary stats are the ones that get pulled into AIO, Perplexity, ChatGPT, and Gemini answers. CITE is a working approximation of what those models prefer; it's not a guarantee, but the correlation is strong.

## Calibration tips

- For news content, Timestamp freshness items 1, 2, 3, 5 should all be ✓ — undated news is dead.
- For evergreen topics, Timestamp items 5–7 are about confirming the freshness window, not chasing dates.
- For brand-monitoring content (where citation matters most), Entity authority should be ≥ 80%.
- For commercial content, Include primary stats lifts pieces from "marketing-fluff" to "decision-grade" — invest here.
