# Prompt sample — wix.com

## Wix brand mentions (AI Overview, US)

Source: `mcp__claude_ai_SE_Ranking__DATA_getAiPromptsByBrand` · 10 prompts · sort by volume desc · total available: 124,597

| # | Prompt | Volume | Type | LLM citation pattern |
|---:|---|---:|---|---|
| 1 | logo | 135,000 | Brand | "Wix" listed alongside Canva and Adobe Express as a free logo creator |
| 2 | ecommerce and | 74,000 | Brand | Wix Blog cited for the e-commerce definition; `wix.com/blog/what-is-ecommerce` is one of the canonical sources |
| 3 | dropshipping | 60,500 | Brand | Wix recommended as a dropshipping platform alongside Shopify; `wix.com/blog/what-is-dropshipping` cited |
| 4 | free website builder | 60,500 | Brand | **Wix listed first** in the "top free website builders" answer — strongest moat in the dataset |
| 5 | oil filter | 60,500 | Brand | False positive — "Wix" matches the WIX Filters automotive parts brand, not wix.com. **Worth flagging in real runs** |
| 6 | web building | 49,500 | Brand | Wix listed first in popular website builders alongside Squarespace, Canva, GoDaddy |
| 7 | websites | 49,500 | Brand | Wix listed as a top builder; `wix.com/blog/what-is-a-website` cited |
| 8 | content management software | 47,500 | Brand | Wix grouped with Squarespace as "user-friendly, SaaS-based builders" |
| 9 | demographic definition | 47,500 | Brand | Wix Encyclopedia cited (`wix.com/encyclopedia/definition/demographics`) — the encyclopedia is a citation engine on its own |
| 10 | free portfolio website | 40,500 | Brand | Wix recommended #2 (after Canva); `wix.com/portfolio-website` cited |

**Disambiguation note:** "Wix" matches both wix.com and WIX Filters (automotive). The skill's Tip about validating brand-name matches in the prompt text is real and load-bearing — at 60,500 monthly volume, the "oil filter" false positive would inflate share-of-voice numbers for any naïve brand-only match.

## Wix domain citations (AI Overview, US)

Source: `mcp__claude_ai_SE_Ranking__DATA_getAiPromptsByTarget` · 10 prompts · sort by volume desc · total available: 163,564

| # | Prompt | Volume | Type | Cited URL |
|---:|---|---:|---|---|
| 1 | blue (color) | 550,000 | Link | `wix.com/wixel/colors/symbolism/light-blue` — Wixel content surfaces in design-adjacent answers |
| 2 | advertising | 450,000 | Link | `wix.com/blog/types-of-advertising` |
| 3 | com (TLD) | 450,000 | Link | `wix.com/blog/co-vs-com` and `wix.com/blog/what-is-com-domain` |
| 4 | enterprises | 301,000 | Link | `wix.com/encyclopedia/definition/enterprise` |
| 5 | guarantee | 246,000 | Link | `wix.com/encyclopedia/definition/guarantee` |
| 6 | who is | 246,000 | Link | `wix.com/domains/whois` |
| 7 | sho is (typo of "who is") | 246,000 | Link | Same `wix.com/domains/whois` page — typo variant captured separately |
| 8 | small business ideas for | 201,000 | Link | `wix.com/blog/business-ideas` |
| 9 | logo | 135,000 | Link | `wix.com/logo/maker` and `wix.com/blog/how-to-design-a-logo` |
| 10 | png | 110,000 | Link | `wix.com/wixel/resources/png-files` |

**Pattern:** Wix earns citations across three content properties: the blog (`wix.com/blog/*`), the encyclopedia (`wix.com/encyclopedia/*`), and the Wixel design tools site (`wix.com/wixel/*`). The encyclopedia in particular is a high-leverage asset — every "what is X" definitional query potentially cites it.

## Wix brand mentions (ChatGPT, US) — cross-engine spot-check

Source: `mcp__claude_ai_SE_Ranking__DATA_getAiPromptsByBrand` · 5 prompts · ChatGPT engine · total available: 39,926

| # | Prompt | Volume | Type | Notes |
|---:|---|---:|---|---|
| 1 | How to create a website? | 0 | Brand | ChatGPT recommends "Wix, Squarespace, Shopify, WordPress" in that order. Wix wins first mention |
| 2 | How to make a website for free? | 0 | Brand | ChatGPT lists "Wix, Weebly, WordPress.com, Google Sites" — Wix first again |
| 3 | How to start a blog? | 0 | Brand | Wix listed as a blogging platform alongside WordPress, Shopify |
| 4 | How to dropship? | 0 | Brand | Wix mentioned as "Good for simple stores with drag-and-drop" — distinct from Shopify's "best for e-commerce" framing |
| 5 | How to make your own website? | 0 | Brand | Wix listed as the #1 beginner option |

**Cross-engine pattern observation:** ChatGPT prompts are conversational ("How to..."), zero-volume in classic search-volume terms but high-intent. AI Overview prompts are template-style ("free website builder", "logo") with measurable monthly volume. Wix is mentioned in both formats but **consistently appears in the first 1-3 names listed** on ChatGPT — a stronger position than its raw 5,262-mention count suggests.

The 5 ChatGPT prompts above all have `volume: 0` because ChatGPT prompt volume is not a Google-search-volume metric — these are conversational queries that don't appear in keyword databases. The skill's `volume` field shouldn't be used to filter ChatGPT prompts the way it can be used for AI Overview.
