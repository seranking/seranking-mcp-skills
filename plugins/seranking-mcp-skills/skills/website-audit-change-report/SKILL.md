---
name: website-audit-change-report
description: Diff this month's website audit against last month's snapshot and deliver a client-ready change report: new issues, resolved issues, severity-weighted prioritisation, traffic-at-risk per issue, and suggested fixes. Use when the user asks for an audit change report, audit diff, month-over-month audit comparison, regression report, or wants to review what got worse/better since the last audit.
---

# Website Audit Change Report

Compare the latest audit against the previous snapshot for a domain and produce a client-ready report that focuses on what changed, not just what is broken.

## Prerequisites

- SE Ranking MCP server connected with a valid `DATA_API_TOKEN`.
- User provides: (a) target domain or audit_id, (b) optionally the comparison window (default: previous audit run).

## Process

1. **Locate the audit** `DATA_listAudits`
   - If the user provided a domain, find the latest audit for it.
   - If no audit exists, surface that to the user and stop; do not silently create one.

2. **Pull audit history** `DATA_getAuditHistory`
   - Retrieve the list of historical runs for the audit_id.
   - Select the latest two runs (current and previous). If the user specified a date window, honour it.

3. **Pull full reports for both runs** `DATA_getAuditReport`
   - Current run: full issue breakdown with severities and page counts.
   - Previous run: same structure.

4. **Compute the diff**
   - New issues: issue_codes present in current but not previous.
   - Resolved issues: issue_codes present in previous but not current.
   - Worsened: issue_codes in both runs but with higher page count in current.
   - Improved: issue_codes in both runs with lower page count in current.

5. **Enrich with impacted pages** `DATA_getAuditPagesByIssue`, `DATA_getIssuesByUrl`
   - For each new or worsened issue, pull the top 10 affected URLs.
   - For each affected URL, look up organic keywords and estimated traffic from `DATA_getDomainPages`. Flag URLs that rank in positions 1-20 as traffic-at-risk.

6. **Prioritise by traffic-at-risk**
   - Rank new/worsened issues by sum of estimated monthly traffic on affected URLs.
   - Group into: Critical (revenue/traffic at risk), High (indexation risk), Medium (UX/quality), Low (cosmetic).

7. **Synthesise the report** (see Output Format).

## Output format

Create a folder `website-audit-change-report-{target-slug}-{YYYYMMDD}/` with:

```
website-audit-change-report-{target-slug}-{YYYYMMDD}/
├── 01-current-snapshot.md
├── 02-previous-snapshot.md
├── 03-diff-raw.md           # full diff, not prioritised
└── REPORT.md                # client-ready
```

`REPORT.md` follows this shape:

```markdown
# Audit Change Report: {domain}
Window: {previous_date} to {current_date}

## TL;DR
- New issues: {n} ({n critical})
- Resolved issues: {n}
- Traffic-at-risk: ~{n} monthly visits on {m} URLs
- Overall audit score: {previous} then {current} ({delta})

## Critical new issues

### Issue: {issue name} ({issue_code})
- Severity: Critical
- Pages affected: {n} (previously: {n})
- Traffic-at-risk: ~{n}/mo
- SEO impact: {2-3 line explanation of why this hurts rankings/traffic}
- Top affected URLs:
  - {url1} (ranks for {kw}, pos {n}, ~{n}/mo)
  - {url2} ...
- Recommended fix: {specific, testable action}
- Effort: {low/medium/high}
- Priority: {P0/P1/P2}

### Issue: {next critical issue}
...

## Resolved since last audit
| Issue | Pages cleaned | Previous severity |
|---|---|---|
| {issue name} | {n} | {severity} |

## Worsened (same issue, more pages)
| Issue | Previous pages | Current pages | Delta |
|---|---|---|---|
| {issue name} | {n} | {n} | +{n} |

## Next actions (recommended order)
1. {highest-priority fix}
2. {next}
3. {next}

## Appendix
- Full diff: 03-diff-raw.md
- Current snapshot: 01-current-snapshot.md
- Previous snapshot: 02-previous-snapshot.md
```

## Tips

- If only one audit run exists, the skill cannot produce a change report. Tell the user clearly and offer to produce a first-run baseline instead.
- Never auto-trigger a new audit with `DATA_recheckAudit` without explicit user confirmation; it consumes credits.
- Do not invent SEO impact explanations for obscure issue codes. If unsure, state the issue definition verbatim from the audit payload and suggest the user consult SE Ranking docs.
- Traffic-at-risk is an estimate based on `DATA_getDomainPages` traffic attribution. Present as a range, not a point estimate.
- Respect Data API rate limit: 10 requests per second.
