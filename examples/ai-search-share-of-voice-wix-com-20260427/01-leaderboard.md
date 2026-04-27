# Leaderboard — raw

Source: `mcp__claude_ai_SE_Ranking__DATA_getAiOverviewLeaderboard`
Region: US · Engines: ai-overview, chatgpt, perplexity, gemini, ai-mode
Primary: wix.com (Wix) · Competitors: weebly.com (Weebly), hostinger.com (Hostinger), squarespace.com (Squarespace), webflow.com (Webflow)

## Combined share of voice

| Rank | Domain | Brand mentions | Link mentions | SoV |
|---:|---|---:|---:|---:|
| 1 | **wix.com** | 112,810 | 226,747 | **36.1%** |
| 2 | weebly.com | 47,073 | 188,329 | 22.3% |
| 3 | hostinger.com | 60,740 | 119,798 | 19.3% |
| 4 | squarespace.com | 63,690 | 90,591 | 17.5% |
| 5 | webflow.com | 17,404 | 26,059 | 4.9% |

## Per-engine breakdown

### AI Overview
| Domain | Brand presence | Link presence |
|---|---:|---:|
| **wix.com** | **77,463** | **205,437** |
| hostinger.com | 50,783 | 105,945 |
| weebly.com | 42,057 | 166,941 |
| squarespace.com | 39,146 | 80,524 |
| webflow.com | 13,751 | 23,893 |

### ChatGPT
| Domain | Brand presence | Link presence |
|---|---:|---:|
| **wix.com** | **5,262** | 5 |
| squarespace.com | 4,105 | 2 |
| weebly.com | 1,065 | 1 |
| webflow.com | 397 | 1 |
| hostinger.com | 339 | 5 |

### Perplexity
| Domain | Brand presence | Link presence |
|---|---:|---:|
| **wix.com** | **3,128** | 209 |
| squarespace.com | 1,725 | 55 |
| hostinger.com | 826 | 192 |
| weebly.com | 281 | 201 |
| webflow.com | 187 | 13 |

### Gemini
| Domain | Brand presence | Link presence |
|---|---:|---:|
| **wix.com** | **5,508** | 65 |
| squarespace.com | 4,352 | 13 |
| hostinger.com | 1,609 | 47 |
| weebly.com | 426 | 11 |
| webflow.com | 298 | 1 |

### AI Mode
| Domain | Brand presence | Link presence |
|---|---:|---:|
| **wix.com** | **21,449** | 21,031 |
| squarespace.com | 14,362 | 9,997 |
| hostinger.com | 7,183 | 13,609 |
| weebly.com | 3,244 | 21,175 |
| webflow.com | 2,771 | 2,151 |

Bold row per engine = engine winner. Note that `link_presence` and `brand_presence` are independent metrics — Hostinger and Weebly often outrank Wix on `link_presence` for an engine while Wix wins `brand_presence`. The combined SoV calculation in the API weighs both.

## Raw API response (truncated)

```json
{
  "leaderboard": [
    {"domain": "wix.com", "is_primary_target": true, "share_of_voice": 0.361, "rank": 1, "brand_presence": 112810, "link_presence": 226747},
    {"domain": "weebly.com", "is_primary_target": false, "share_of_voice": 0.2225, "rank": 2, "brand_presence": 47073, "link_presence": 188329},
    {"domain": "hostinger.com", "is_primary_target": false, "share_of_voice": 0.1926, "rank": 3, "brand_presence": 60740, "link_presence": 119798},
    {"domain": "squarespace.com", "is_primary_target": false, "share_of_voice": 0.1751, "rank": 4, "brand_presence": 63690, "link_presence": 90591},
    {"domain": "webflow.com", "is_primary_target": false, "share_of_voice": 0.0488, "rank": 5, "brand_presence": 17404, "link_presence": 26059}
  ]
}
```
