# Heatmap

Visualisation of share of voice and per-engine concentration.

## Combined share of voice

```
wix.com       ████████████████████████████████████  36.1%
weebly.com    ██████████████████████                22.3%
hostinger.com ███████████████████                   19.3%
squarespace   █████████████████                     17.5%
webflow.com   ████                                   4.9%
```

## Brand mentions × engine

Cell colour code: 🟢 = engine winner · 🟡 = within 30% of winner · ⚪ = follower · ⬛ = laggard.

| Domain | AI Overview | ChatGPT | Perplexity | Gemini | AI Mode |
|---|---|---|---|---|---|
| wix.com | 🟢 77,463 | 🟢 5,262 | 🟢 3,128 | 🟢 5,508 | 🟢 21,449 |
| squarespace.com | ⚪ 39,146 | 🟡 4,105 | 🟡 1,725 | 🟡 4,352 | 🟡 14,362 |
| hostinger.com | 🟡 50,783 | ⬛ 339 | ⚪ 826 | ⚪ 1,609 | ⚪ 7,183 |
| weebly.com | ⚪ 42,057 | ⚪ 1,065 | ⬛ 281 | ⬛ 426 | ⬛ 3,244 |
| webflow.com | ⬛ 13,751 | ⬛ 397 | ⬛ 187 | ⬛ 298 | ⬛ 2,771 |

## Reading the heatmap

- **Wix is dominant on every engine.** No competitor wins a single engine column. This is rare — usually the leader splits engines with one or two competitors.
- **Squarespace is the credible runner-up everywhere except hostinger-friendly engines.** It's "yellow" (within 30%) on all 5 engines — the only competitor that consistent.
- **Hostinger over-indexes on AI Overview specifically.** It ranks 2nd there (50,783) but collapses to bottom-3 elsewhere. This pattern often means a single category page is doing all the work — likely Hostinger's "Most Visited Websites" hub which racks up AI Overview citations.
- **Weebly's AI Overview number is misleading.** It has 42,057 brand mentions on AI Overview (decent) but its other engines are at noise floor (281, 426, 1,065). Weebly is essentially an AI Overview-only brand in 2026.
- **Webflow is in the laggard column on every engine.** This is consistent with its designer-only positioning — high quality, low surface area.

## Why the SoV percentages don't simply mirror brand-mention counts

The SoV calculation in `getAiOverviewLeaderboard` weighs both `brand_presence` (when the brand is mentioned by name in an LLM answer) and `link_presence` (when the domain is cited as a source). Weebly ranks 2nd in SoV (22.3%) despite having lower brand mentions than Hostinger or Squarespace because Weebly has very high `link_presence` on AI Overview (166,941) — the Weebly site is cited as a source even when not name-mentioned. Wix wins on both metrics, decisively.
