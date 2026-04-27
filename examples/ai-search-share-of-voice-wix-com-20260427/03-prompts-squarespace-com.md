# Prompt sample — squarespace.com

Sampled as the closest design-led competitor to Wix. Squarespace is the only competitor within striking distance on ChatGPT (4,105 brand mentions vs Wix 5,262 — 78% of Wix's count) and consistently lands the "professional / sleek / creative" descriptor in LLM answers.

## Squarespace brand mentions (AI Overview, US)

Source: `mcp__claude_ai_SE_Ranking__DATA_getAiPromptsByBrand` · 5 prompts · sort by volume desc · total available: 57,378

| # | Prompt | Volume | Type | Notes |
|---:|---|---:|---|---|
| 1 | logo | 135,000 | Brand | Squarespace mentioned as a logo creator alongside Wix, Canva, Adobe Express |
| 2 | 414 area (Milwaukee phone area code) | 90,500 | Brand | False positive — `burnerapp.squarespace.com` is cited but the prompt is about a phone area code. Not a real Squarespace mention |
| 3 | web building | 49,500 | Brand | Squarespace described as "known for sleek, professional, and creative templates" — strongest positioning anchor in the dataset |
| 4 | websites | 49,500 | Brand | Squarespace listed as "another top builder" alongside Wix |
| 5 | content management software | 47,500 | Brand | Squarespace grouped with Wix as user-friendly SaaS CMS |

**Pattern observation:** Squarespace's 57,378 total prompt count is roughly half of Wix's 124,597. The two brands appear together in nearly every general-audience website-builder query. The differentiator LLMs surface is Squarespace = design quality, Wix = breadth + free option. **For a Squarespace-perspective version of this report, "design-led" would be their moat.**

The "414 area" false positive is interesting: a separate site `burnerapp.squarespace.com` (a Squarespace-hosted blog about burner phones) gets cited for area-code queries, which inflates the Squarespace brand-mention count. Same disambiguation problem as the Wix / WIX Filters case — confirms the SKILL.md's validation tip is necessary infrastructure, not a nice-to-have.

## Implications for Wix

1. **Squarespace is the only competitor that earns "professional" / "sleek" descriptors.** If Wix wants to defend the design-conscious user segment, it needs LLM answers to call out Wix Studio specifically (today they don't).
2. **ChatGPT differential is the alarm.** Squarespace at 78% of Wix on ChatGPT (vs ~50% on AI Overview, ~60% on AI Mode) means the conversational "design-first" query is where Squarespace converts curiosity into citations. Wix's content strategy should over-index on conversational design tutorials to defend.
3. **The "two brands appear together" pattern is durable.** Almost every "best website builder" answer lists Wix and Squarespace as the two SaaS leaders. Don't try to displace Squarespace from these lists; instead, ensure Wix is named first (volume of citations + page authority on `wix.com/` matters here).
