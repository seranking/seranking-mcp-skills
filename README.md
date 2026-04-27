# Claude SEO Skills

Production-ready [Claude Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) for SEO, powered by the [SE Ranking remote MCP](https://seranking.com/api/integrations/mcp). Each skill turns raw API data into a finished SEO deliverable — content briefs, AI Search share of voice, page intelligence, structured data, drift monitoring, SXO diagnostics, competitive analysis, and more.

These Claude Skills are designed to work with the SE Ranking MCP server, but they document every API call explicitly so they can also be adapted to other SEO data providers.

## Skills

| Skill | What it produces | Primary triggers |
|---|---|---|
| [`seo-content-brief`](skills/seo-content-brief/SKILL.md) | Writer-ready editor brief from a domain and topic, with keyword research, SERP analysis, competitor content teardown, internal linking plan, and AI Search angle | "content brief", "blog brief", "article outline", "editor brief" |
| [`seo-ai-search-share-of-voice`](skills/seo-ai-search-share-of-voice/SKILL.md) | Share-of-voice heatmap across ChatGPT, Perplexity, Gemini, Google AI Overview, and AI Mode, plus topic-cluster ownership per brand | "AI Search share of voice", "LLM visibility", "AEO", "GEO analysis", "AI Overview competitive analysis" |
| [`seo-backlink-gap`](skills/seo-backlink-gap/SKILL.md) | Prospect list of referring domains linking to multiple competitors but not to your site, enriched with authority, anchor samples, and outreach angles | "backlink gap", "link building opportunities", "competitor backlink intersection", "link prospecting" |
| [`seo-keyword-cluster`](skills/seo-keyword-cluster/SKILL.md) | Intent-grouped clusters with pillar plus spokes architecture and H1/H2 suggestions per spoke | "keyword clustering", "topical map", "pillar content strategy", "content calendar from keywords" |
| [`seo-competitor-gap-analysis`](skills/seo-competitor-gap-analysis/SKILL.md) | Keywords competitors rank for that the target does not, filtered by intent, volume, KD, and scored for priority | "competitor gap", "keyword gap", "organic content gap", "missing keyword opportunities" |
| [`seo-agency-landing-page`](skills/seo-agency-landing-page/SKILL.md) | Demand-gen landing page for an SEO agency with a free-audit lead magnet, grounded in real niche data | "SEO agency landing page", "lead-gen page", "free-audit landing page" |
| [`seo-page`](skills/seo-page/SKILL.md) | URL-level keyword & traffic intelligence with keep / refresh / consolidate / kill verdict for one page | "analyze this page", "page SEO performance", "what does this URL rank for", "should I refresh this page" |
| [`seo-schema`](skills/seo-schema/SKILL.md) | JSON-LD detect, validate, generate. Six bundled templates (Article / Product / LocalBusiness / FAQPage / HowTo / BreadcrumbList) | "schema markup", "structured data", "JSON-LD", "rich results", "schema validation" |
| [`seo-drift`](skills/seo-drift/SKILL.md) | Git for SEO — baseline, compare, history. Severity-coded regression report across authority, traffic, keywords, backlinks, page fingerprint | "SEO drift", "did anything break", "deployment check", "baseline this site", "SEO regression" |
| [`seo-sxo`](skills/seo-sxo/SKILL.md) | Read SERPs backwards to find page-type mismatches. Scores the page from 4 personas; produces a wireframe for the SERP-winning page type | "why isn't this page ranking", "SXO", "page type mismatch", "intent mismatch", "search experience" |
| [`seo-technical-audit`](skills/seo-technical-audit/SKILL.md) | One-shot technical audit: crawlability, indexability, security, mobile, structured data, JS rendering. Top-10 fix list ranked by impact × effort | "technical audit", "site audit", "audit my site", "crawl issues", "indexation issues" |
| [`seo-content-audit`](skills/seo-content-audit/SKILL.md) | E-E-A-T (60-item) + CITE (30-item) audit for existing content with publish / publish-with-fixes / no-publish verdict and citation-readiness analysis | "content quality audit", "E-E-A-T check", "is this content good", "review this article", "AI search readiness" |
| [`seo-sitemap`](skills/seo-sitemap/SKILL.md) | Compare a domain's XML sitemap to the most recent SE Ranking audit. Surfaces missing-from-sitemap, orphans, broken entries, lastmod issues | "sitemap analysis", "check my sitemap", "missing pages", "orphan pages", "sitemap health" |
| [`seo-competitor-pages`](skills/seo-competitor-pages/SKILL.md) | Generate "X vs Y" / "alternatives to X" / "best X for Y" landing pages with feature matrix, schema, balanced verdict, and CTA flow | "comparison page", "vs page", "alternatives page", "X vs Y", "alternative to X" |
| [`seo-backlinks-profile`](skills/seo-backlinks-profile/SKILL.md) | Full backlink profile audit (vs gap-only `seo-backlink-gap`): authority distribution, anchor diversity, IP/subnet concentration, growth/decay, toxic-candidate flagging | "backlink profile", "link profile audit", "anchor distribution", "toxic links", "disavow candidates" |
| [`seo-subdomain`](skills/seo-subdomain/SKILL.md) | Subdomain ownership map. Lists subdomains, topic ownership, fragmentation/cannibalization flags, consolidate / split recommendations | "subdomain analysis", "subdomain ownership", "blog vs main domain", "should I consolidate subdomains" |
| [`seo-geo`](skills/seo-geo/SKILL.md) | URL-level Generative Engine Optimization analysis. AIO citation footprint per primary keyword + page passage-level audit + recommendations to improve LLM citability | "GEO for this page", "AIO citation analysis", "AI search readiness for URL", "why isn't this page cited" |
| [`seo-ads`](skills/seo-ads/SKILL.md) | Paid-search competitive intelligence. Domain ad footprint, bidding landscape per keyword, ad-copy patterns, SERP shopping/ad-pack visibility, recommended bid-keyword shortlist | "paid search analysis", "competitor ads", "PPC competitive", "who bids on this keyword", "shopping pack" |
| [`seo-keyword-niche`](skills/seo-keyword-niche/SKILL.md) | Mine longtail + question keywords for niche content opportunities. Outputs a content-tier plan with template spec, URL pattern, sample pages, and thin-content quality gates | "longtail keywords", "question keywords", "niche content", "content opportunities at scale", "programmatic SEO" |

## Prerequisites

- [Claude Code](https://code.claude.com), the Claude API, or [Claude.ai](https://claude.ai) with Skills enabled.
- The [SE Ranking remote MCP](https://seranking.com/api/integrations/mcp) connected to your Claude workspace. In Claude Code: `claude mcp add --transport http se-ranking https://api.seranking.com/mcp`, then run `/mcp` in a session and sign in via OAuth — no API token to manage.
- An SE Ranking account with API access enabled. [Sign up](https://seranking.com/api.html) if you don't already have one.

## Install

### Option 1: Claude Code plugin marketplace (recommended)

This repo is a Claude Code plugin marketplace. Add the marketplace once, install the plugin, and Claude Code handles updates for you.

```bash
# Add the SE Ranking marketplace
/plugin marketplace add seranking/seo-skills

# Install the plugin
/plugin install seo-skills@seranking
```

Skills are namespaced under the plugin. Trigger them with:

```
/seo-skills:seo-content-brief
/seo-skills:seo-ai-search-share-of-voice
```

To update the marketplace later: `/plugin marketplace update seranking`.

### Option 2: Local plugin development mode

```bash
# Clone the repo
git clone https://github.com/seranking/seo-skills.git

# Load the plugin directly from the cloned directory
claude --plugin-dir ./seo-skills
```

### Option 3: Copy individual skills

```bash
# Clone the repo
git clone https://github.com/seranking/seo-skills.git

# Copy a single skill to your user-scoped skills directory
cp -r seo-skills/skills/seo-content-brief ~/.claude/skills/

# Or copy all of them
cp -r seo-skills/skills/* ~/.claude/skills/
```

Skills copied this way are not namespaced. Trigger them directly by description match.

### Option 4: Project-scoped install

Copy into a specific project's `.claude/skills/` directory to make the skills available only when Claude Code runs in that project.

```bash
cp -r seo-skills/skills/* /path/to/your/project/.claude/skills/
```

### Option 5: Claude API

Upload any skill as a zip to the Claude API via the `/v1/skills` endpoints. See [Anthropic's Skills API guide](https://platform.claude.com/docs/en/build-with-claude/skills-guide).

## How these skills work

Each skill is a single `SKILL.md` file with YAML frontmatter. Claude loads the frontmatter at startup to know when to use the skill, then loads the body only when triggered, then reads any bundled reference files only when needed. This is Anthropic's [progressive disclosure](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work) pattern.

A typical skill run produces:

1. A set of numbered raw-data markdown files (`01-domain-overview.md`, `02-competitors.md`, etc.) for auditability.
2. Optionally, a CSV for spreadsheet work.
3. A final synthesised deliverable (`BRIEF.md`, `REPORT.md`, or `PLAN.md`) written in a format a human reviewer or downstream stakeholder can consume directly.

The skills chain naturally. A typical agency workflow:

1. Run `seo-competitor-gap-analysis` to see what opportunities exist.
2. Run `seo-keyword-cluster` on the gap output to plan content.
3. Run `seo-content-brief` on each cluster's pillar topic.
4. Run `seo-backlink-gap` to identify link targets for the new content.
5. Run `seo-ai-search-share-of-voice` quarterly to track LLM visibility.

## Repository layout

```
seo-skills/
├── .claude-plugin/
│   ├── marketplace.json                # Claude Code marketplace manifest
│   └── plugin.json                     # Plugin manifest
├── skills/
│   ├── seo-content-brief/
│   │   └── SKILL.md
│   ├── seo-ai-search-share-of-voice/
│   │   └── SKILL.md
│   ├── seo-backlink-gap/
│   │   └── SKILL.md
│   ├── seo-keyword-cluster/
│   │   └── SKILL.md
│   ├── seo-competitor-gap-analysis/
│   │   └── SKILL.md
│   ├── seo-agency-landing-page/
│   │   └── SKILL.md
│   ├── seo-page/
│   │   └── SKILL.md
│   ├── seo-schema/
│   │   ├── SKILL.md
│   │   ├── templates/                  # 6 JSON-LD starter templates
│   │   └── references/google-rich-results.md
│   ├── seo-drift/
│   │   ├── SKILL.md
│   │   └── references/drift-thresholds.md
│   ├── seo-sxo/
│   │   ├── SKILL.md
│   │   └── references/                 # page-type patterns + persona rubrics
│   ├── seo-technical-audit/
│   │   ├── SKILL.md
│   │   └── references/severity-mapping.md
│   ├── seo-content-audit/
│   │   ├── SKILL.md
│   │   ├── references/                 # core-eeat (60 items) + cite (30 items)
│   │   └── templates/verdict.md
│   ├── seo-sitemap/
│   │   └── SKILL.md
│   ├── seo-competitor-pages/
│   │   └── SKILL.md
│   ├── seo-backlinks-profile/
│   │   └── SKILL.md
│   ├── seo-subdomain/
│   │   └── SKILL.md
│   ├── seo-geo/
│   │   └── SKILL.md
│   ├── seo-ads/
│   │   └── SKILL.md
│   └── seo-keyword-niche/
│       └── SKILL.md
├── examples/                           # Real, end-to-end runs against public targets
│   └── seo-ai-search-share-of-voice-wix-com-20260427/
├── CHANGELOG.md
├── LICENSE
└── README.md
```

The repo is a Claude Code marketplace whose single plugin is the repo itself (marketplace `plugins[0].source` is `"./"`). This keeps skill folders visible at the top level rather than buried two layers deep.

Every skill writes its output to a folder named `{skill-slug}-{target-slug}-{YYYYMMDD}/` (e.g., `seo-content-brief-example-com-20260427/`). The date stamp keeps re-runs non-destructive and makes it easy to diff outputs over time. Browse [`examples/`](./examples/) to see what a finished run looks like before installing.

## Rate limits and costs

The SE Ranking MCP server has two namespaces with different rate limits:

- **Data API** (`DATA_*`): 10 requests per second. Charges API credits per call.
- **Project API** (`PROJECT_*`): 5 requests per second. Retrieval and management calls do not charge; writes consume quota slots.

Every skill in this repo is designed to pace sequentially inside these limits. The largest skills (`seo-competitor-gap-analysis` with full keyword dumps, `seo-keyword-cluster` with 20 seeds) can consume thousands of credits on large domains. Check `DATA_getCreditBalance` before running on production accounts, and use the `ceiling` parameters the skills document to cap cost.

## Contributing

This repo is the official Skills catalogue for the SE Ranking MCP server. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the skill-authoring template, required structure, MCP tool conventions, and PR checklist.

- **Bug reports** — open an issue with the skill name, the input, and the unexpected output.
- **New skills** — PRs welcome. Use the template in `CONTRIBUTING.md`.
- **Improvements** — PRs welcome. Include a before/after example run in the PR description.

## Links

- SE Ranking: https://seranking.com
- SE Ranking API: https://seranking.com/api.html
- SE Ranking remote MCP: https://seranking.com/api/integrations/mcp
- Claude Agent Skills: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude Code Plugins: https://code.claude.com/docs/en/plugins

## License

MIT. See [LICENSE](LICENSE).
