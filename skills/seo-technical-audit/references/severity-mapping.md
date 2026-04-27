# Audit issue severity mapping

Maps SE Ranking's audit issue codes (and common issue names) to severity, suggested fix, and effort estimate. Used by `seo-technical-audit` to score impact × effort and produce the top-10 fix list.

## Severity scale

- **Critical** — site-breaking or major-traffic-loss potential. Fix today.
- **High** — significant ranking or indexation risk. Fix this week.
- **Medium** — quality-signal issue. Fix this month.
- **Low** — best-practice nudge. Fix when convenient.

## Effort scale

- **S** — config or template change, <1 hour.
- **M** — content or template work across multiple pages, <1 day.
- **L** — engineering work or content rewrite at scale, multiple days.

## Mapping

### Crawlability

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| robots.txt blocking important resources (CSS/JS/images) | Critical | Allow CSS, JS, image directories in robots.txt | S |
| robots.txt 5xx error | Critical | Fix server config; ensure robots.txt returns 200 or 404 (never 5xx) | S |
| XML sitemap missing | High | Generate and submit sitemap; reference in robots.txt | M |
| XML sitemap not in robots.txt | Medium | Add `Sitemap:` directive to robots.txt | S |
| JS rendering blocking critical content | High | Server-side render critical content; ensure crawler-accessible | L |
| Crawl depth >5 for important pages | Medium | Add internal links from higher-traffic pages | M |
| Internal redirect chain >2 hops | Medium | Update internal links to final destination | S |

### Indexability

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| Important page noindexed | Critical | Remove `noindex` from meta robots and X-Robots-Tag | S |
| Canonical points to different URL than self | High | Fix canonical to self-reference; or confirm intentional consolidation | S |
| Canonical to a 404 page | Critical | Update or remove canonical | S |
| Multiple canonicals on one page | High | Consolidate to one canonical tag | S |
| Hreflang return-tag mismatch | Medium | Ensure each hreflang variant points back to the original | M |
| Pagination noindexed (when shouldn't be) | Medium | Use rel=next/prev or self-canonical paginated pages | S |
| Orphan pages (no internal links) | Medium | Add internal links from relevant parent pages | M |

### Security

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| HTTP page (not HTTPS) | Critical | Redirect HTTP → HTTPS site-wide; update internal links | M |
| Mixed content (HTTPS page loading HTTP resources) | High | Update resource URLs to HTTPS or //protocol-relative | S |
| Missing HSTS header | Medium | Add `Strict-Transport-Security` header | S |
| Expired or self-signed certificate | Critical | Renew certificate via the CA | S |
| Mixed-case domain in canonical | Low | Normalise to lowercase | S |

### Mobile

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| Viewport meta missing | High | Add `<meta name="viewport" content="width=device-width, initial-scale=1">` | S |
| Tap targets too small | Medium | Increase button/link size to 44×44 px minimum | S |
| Text too small to read | Medium | Increase base font size to ≥ 16px | S |
| Content wider than screen | Medium | Fix responsive layout; avoid fixed widths | M |

### Structured data

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| Schema parse error | High | Fix JSON-LD syntax (commas, quotes, braces) | S |
| Required field missing | High | Add the required field per `schema.org` spec for the type | S |
| Schema describes hidden content | Medium | Remove the schema OR make the content visible | S |
| Multiple competing types on one page | Low | Use one primary `@type` per `<script>` block | S |

### Content

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| Title tag missing | Critical | Add unique, descriptive `<title>` 50–60 chars | S |
| Title tag duplicate across pages | High | Make each title unique per page | M |
| Title tag too long (>60 chars) | Low | Trim to 50–60 chars; keep keyword in first 50 | S |
| Meta description missing | Medium | Add 150–160 char description | S |
| Meta description duplicate across pages | Medium | Make unique per page | M |
| H1 missing | High | Add exactly one descriptive H1 per page | S |
| Multiple H1s | Medium | Consolidate to one H1; demote others to H2 | S |
| H2-H6 hierarchy skipped levels | Low | Use levels in order (H1 → H2 → H3, no skipping) | S |
| Thin content (<300 words) on indexable page | Medium | Expand or noindex/consolidate | M |
| Duplicate content (>80% similarity across pages) | High | Consolidate; canonical to the primary; or differentiate | L |

### Performance

| Issue | Severity | Fix | Effort |
|---|---|---|---|
| Slow LCP (>2.5s on mobile) | High | Optimise hero image; reduce render-blocking JS | L |
| Slow INP (>200ms) | High | Reduce main-thread blocking; defer non-critical JS | L |
| Layout shift (CLS >0.1) | Medium | Set explicit width/height on images; reserve space for ads | M |
| Render-blocking JS in head | Medium | Defer or async non-critical scripts | S |
| Uncompressed images | Medium | Compress and convert to WebP/AVIF | M |
| Missing caching headers | Low | Add `Cache-Control` to static assets | S |

## Priority scoring

`priority_score = severity_weight × affected_pages / effort_weight`

- severity_weight: Critical=4, High=3, Medium=2, Low=1
- effort_weight: S=1, M=3, L=5

Top-10 fixes are the highest priority_score across all categories.
