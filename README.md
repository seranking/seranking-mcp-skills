# SE Ranking MCP Skills

Production-ready [Claude Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) for the [SE Ranking remote MCP](https://seranking.com/api/integrations/mcp). Each skill turns raw API data into a finished SEO deliverable: a content brief, a share-of-voice report, an audit change log, a backlink prospect list, a cluster plan, a gap analysis, a demand-gen landing page.

These skills are designed to work with the SE Ranking MCP server, but they document every API call explicitly so they can also be adapted to other SEO data providers.

## Skills

| Skill | What it produces | Primary triggers |
|---|---|---|
| [`content-brief`](skills/content-brief/SKILL.md) | Writer-ready editor brief from a domain and topic, with keyword research, SERP analysis, competitor content teardown, internal linking plan, and AI Search angle | "content brief", "blog brief", "article outline", "editor brief" |
| [`ai-search-share-of-voice`](skills/ai-search-share-of-voice/SKILL.md) | Share-of-voice heatmap across ChatGPT, Perplexity, Gemini, Google AI Overview, and AI Mode, plus topic-cluster ownership per brand | "AI Search share of voice", "LLM visibility", "AEO", "GEO analysis", "AI Overview competitive analysis" |
| [`website-audit-change-report`](skills/website-audit-change-report/SKILL.md) | Month-over-month audit diff: new issues, resolved issues, worsened issues, and traffic-at-risk prioritisation | "audit change report", "audit diff", "month-over-month audit", "regression report" |
| [`backlink-gap`](skills/backlink-gap/SKILL.md) | Prospect list of referring domains linking to multiple competitors but not to your site, enriched with authority, anchor samples, and outreach angles | "backlink gap", "link building opportunities", "competitor backlink intersection", "link prospecting" |
| [`keyword-cluster-planner`](skills/keyword-cluster-planner/SKILL.md) | Intent-grouped clusters with pillar plus spokes architecture and H1/H2 suggestions per spoke | "keyword clustering", "topical map", "pillar content strategy", "content calendar from keywords" |
| [`competitor-gap-analysis`](skills/competitor-gap-analysis/SKILL.md) | Keywords competitors rank for that the target does not, filtered by intent, volume, KD, and scored for priority | "competitor gap", "keyword gap", "organic content gap", "missing keyword opportunities" |
| [`agency-landing-page`](skills/agency-landing-page/SKILL.md) | Demand-gen landing page for an SEO agency with a free-audit lead magnet, grounded in real niche data | "SEO agency landing page", "lead-gen page", "free-audit landing page" |

## Prerequisites

- [Claude Code](https://code.claude.com), the Claude API, or [Claude.ai](https://claude.ai) with Skills enabled.
- The [SE Ranking remote MCP](https://seranking.com/api/integrations/mcp) connected to your Claude workspace. In Claude Code: `claude mcp add --transport http se-ranking https://api.seranking.com/mcp`, then run `/mcp` in a session and sign in via OAuth — no API token to manage.
- An SE Ranking account with API access enabled. [Sign up](https://seranking.com/api.html) if you don't already have one.

## Install

### Option 1: Claude Code plugin marketplace (recommended)

This repo is a Claude Code plugin marketplace. Add the marketplace once, install the plugin, and Claude Code handles updates for you.

```bash
# Add the SE Ranking marketplace
/plugin marketplace add seranking/seranking-mcp-skills

# Install the plugin
/plugin install seranking-mcp-skills@seranking
```

Skills are namespaced under the plugin. Trigger them with:

```
/seranking-mcp-skills:content-brief
/seranking-mcp-skills:ai-search-share-of-voice
```

To update the marketplace later: `/plugin marketplace update seranking`.

### Option 2: Local plugin development mode

```bash
# Clone the repo
git clone https://github.com/seranking/seranking-mcp-skills.git

# Load the plugin directly from its subdirectory
claude --plugin-dir ./seranking-mcp-skills/plugins/seranking-mcp-skills
```

### Option 3: Copy individual skills

```bash
# Clone the repo
git clone https://github.com/seranking/seranking-mcp-skills.git

# Copy a single skill to your user-scoped skills directory
cp -r seranking-mcp-skills/plugins/seranking-mcp-skills/skills/content-brief ~/.claude/skills/

# Or copy all of them
cp -r seranking-mcp-skills/plugins/seranking-mcp-skills/skills/* ~/.claude/skills/
```

Skills copied this way are not namespaced. Trigger them directly by description match.

### Option 4: Project-scoped install

Copy into a specific project's `.claude/skills/` directory to make the skills available only when Claude Code runs in that project.

```bash
cp -r seranking-mcp-skills/plugins/seranking-mcp-skills/skills/* /path/to/your/project/.claude/skills/
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

1. Run `competitor-gap-analysis` to see what opportunities exist.
2. Run `keyword-cluster-planner` on the gap output to plan content.
3. Run `content-brief` on each cluster's pillar topic.
4. Run `backlink-gap` to identify link targets for the new content.
5. Run `website-audit-change-report` monthly to catch regressions.
6. Run `ai-search-share-of-voice` quarterly to track LLM visibility.

## Repository layout

```
seranking-mcp-skills/
├── .claude-plugin/
│   └── marketplace.json               # Claude Code plugin marketplace manifest
├── plugins/
│   └── seranking-mcp-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json            # Plugin manifest
│       └── skills/
│           ├── content-brief/
│           │   └── SKILL.md
│           ├── ai-search-share-of-voice/
│           │   └── SKILL.md
│           ├── website-audit-change-report/
│           │   └── SKILL.md
│           ├── backlink-gap/
│           │   └── SKILL.md
│           ├── keyword-cluster-planner/
│           │   └── SKILL.md
│           ├── competitor-gap-analysis/
│           │   └── SKILL.md
│           └── agency-landing-page/
│               └── SKILL.md
├── LICENSE
└── README.md
```

Every skill writes its output to a folder named `{skill-slug}-{target-slug}-{YYYYMMDD}/` (e.g., `content-brief-example-com-20260427/`). The date stamp keeps re-runs non-destructive and makes it easy to diff outputs over time.

## Rate limits and costs

The SE Ranking MCP server has two namespaces with different rate limits:

- **Data API** (`DATA_*`): 10 requests per second. Charges API credits per call.
- **Project API** (`PROJECT_*`): 5 requests per second. Retrieval and management calls do not charge; writes consume quota slots.

Every skill in this repo is designed to pace sequentially inside these limits. The largest skills (`competitor-gap-analysis` with full keyword dumps, `keyword-cluster-planner` with 20 seeds) can consume thousands of credits on large domains. Check `DATA_getCreditBalance` before running on production accounts, and use the `ceiling` parameters the skills document to cap cost.

## Contributing

This repo is the official Skills catalogue for the SE Ranking MCP server. We welcome issues and PRs:

- **Bug reports**: open an issue with the skill name, the input, and the unexpected output.
- **New skills**: PRs welcome. Follow the structure of existing skills (frontmatter + Prerequisites + Process + Output format + Tips). Keep each `SKILL.md` under 300 lines.
- **Improvements**: PRs welcome. Include a before/after example run in the PR description.

## Links

- SE Ranking: https://seranking.com
- SE Ranking API: https://seranking.com/api.html
- SE Ranking remote MCP: https://seranking.com/api/integrations/mcp
- Claude Agent Skills: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude Code Plugins: https://code.claude.com/docs/en/plugins

## License

MIT. See [LICENSE](LICENSE).
