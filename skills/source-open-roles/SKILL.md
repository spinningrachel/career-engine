---
name: source-open-roles
description: Logic for sourcing open roles across LinkedIn, remote-focused boards, startup boards, general job boards, and freelance platforms. Defines search modes, site-by-site fetch methods, scoring rubric, and deduplication rules. Load before running any source-open-roles search.
---

# Source Open Roles — Search Logic

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

---

## What This Skill Is For

Sourcing surfaces open roles that match the user's preferences — it is the top-of-funnel step that feeds the application pipeline. It does not research, coach, write, or score fit. Its job is to return a ranked list of roles that are (a) worth looking at and (b) not already in the pipeline.

---

## Preferences Schema

Preferences are stored in `~/.career-engine-job-prefs.json`. The full schema:

```json
{
  "preferences": {
    "targetTitles": ["Head of Marketing", "VP Marketing"],
    "minSalary": "no minimum",
    "remotePreference": "remote only",
    "excludePatterns": ["junior", "intern", "contract"],
    "defaultTimeRange": "last week",
    "location": "City, Country",
    "notionDatabaseId": "<your-notion-database-id>"
  }
}
```

`notionDatabaseId` is set during setup. If absent, deduplication against Notion is skipped and the agent notes this.

---

## Search Modes

The mode determines which sources are searched. It is resolved in this order:
1. Explicit override in the invocation prompt (e.g., "quick", "remote", "startup", "broad", "ai", "full", "contract")
2. Default derived from `remotePreference`:
   - `remote only` → `remote`
   - `hybrid` → `broad`
   - `open to all` → `broad`

| Mode | Sources searched |
|---|---|
| `quick` | LinkedIn only |
| `remote` | LinkedIn + all Remote-focused sites |
| `startup` | LinkedIn + all Startup/tech sites |
| `broad` | LinkedIn + General boards + HN Who's Hiring + ATS/company career pages |
| `ai` | LinkedIn + AI/tech-specific sites |
| `full` | All sources across all categories |
| `contract` | Upwork + BeBee |

---

## Site Catalog

### LinkedIn (MCP)

**Gate:** Requires `mcp__linkedin-mcp__search_jobs` to be connected. If unavailable, skip and report.

For each target title:
```
search_jobs(
  keywords = "[title]",
  location = preferences.location,
  date_posted = [map: "last week"→"past_week", "2 weeks"→"past_month", "month"→"past_month"],
  work_type = [map: "remote only"→"remote", "hybrid"→"hybrid", "open to all"→null],
  sort_by = "date"
)
```
Collect all `job_ids`. Deduplicate across title searches. Fetch up to 30 job details via `get_job_details(job_id)`. A result is usable only if it contains role requirements or responsibilities — metadata-only responses (applicant stats only) are not usable.

---

### Remote-focused sites

All fetched via `WebSearch` using the pattern: `site:<domain> "[title]" [time signal]` where time signal is "posted this week" or "new" depending on the site. Extract all listings that contain at minimum a title, company, and apply URL or description.

| Site | Fetch method |
|---|---|
| Working Nomads | `WebFetch("https://www.workingnomads.com/jobs?category=marketing&tag=[title-slug]")` |
| TrulyRemote | `WebSearch("site:trulyremote.co [title]")` |
| RemoteJobs.org | `WebSearch("site:remotejobs.org [title]")` |
| WeAreDistributed | `WebFetch("https://wearedistributed.org/remote-jobs/")` — parse listings on page |
| OpenToWorkRemote | `WebFetch("https://www.opentoworkremote.com/")` — WebSearch `site:opentoworkremote.com [title]` if direct fetch is sparse |
| WorkEW | `WebSearch("site:workew.com [title]")` |
| JobRack | `WebFetch("https://jobrack.eu/jobs?q=[title-urlencoded]")` |
| Jobgether | `WebFetch("https://jobgether.com/remote-jobs")` — parse listings, then `WebSearch("site:jobgether.com [title] remote")` for deeper coverage |
| PitchMeAI | `WebFetch("https://pitchmeai.com/jobs")` — filter by title after fetch |

---

### Startup / tech sites

| Site | Fetch method |
|---|---|
| startup.jobs | `WebFetch("https://startup.jobs/?q=[title-urlencoded]&remote=true")` |
| BuiltIn | `WebSearch("site:builtin.com [title] remote")` — BuiltIn blocks direct fetch |
| MoaiJobs | `WebFetch("https://www.moaijobs.com/")` + `WebSearch("site:moaijobs.com [title]")` |
| CareerVault | `WebFetch("https://careervault.io/")` + `WebSearch("site:careervault.io [title]")` |

---

### General boards

| Site | Fetch method |
|---|---|
| Indeed | `WebSearch("site:indeed.com [title] [location or remote] job")` — do not attempt direct WebFetch (auth wall). If `mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__search_jobs` is connected, prefer it. |
| ZipRecruiter | `WebSearch("site:ziprecruiter.com [title] remote")` |
| BeBee | `WebSearch("site:bebee.com [title]")` |
| Workable Jobs | `WebSearch("site:jobs.workable.com [title]")` |
| Hacker News Who's Hiring | WebSearch for `"Ask HN: Who is hiring?" site:news.ycombinator.com [current month] [current year]`. Fetch thread via `https://hacker-news.firebaseio.com/v0/item/{THREAD_ID}.json`. Fetch up to 100 comment items. Parse `text` field of each. Filter by title fuzzy-match. |

---

### ATS / company career pages

Use these to surface roles posted directly on company career pages via their ATS. These often appear earlier than aggregators and are not always indexed on general boards.

| Site | Fetch method |
|---|---|
| Greenhouse | `WebSearch("site:boards.greenhouse.io [title]")` + `WebSearch("site:job-boards.greenhouse.io [title]")` |
| Lever | `WebSearch("site:jobs.lever.co [title]")` |
| Workday | `WebSearch("site:myworkdayjobs.com [title] remote")` |
| Ashby | `WebSearch("site:jobs.ashbyhq.com [title]")` |
| Rippling | `WebSearch("site:job.rippling.com [title]")` |

---

### AI / tech-specific sites

| Site | Fetch method |
|---|---|
| MoaiJobs | See Startup section |
| CareerVault | See Startup section |
| PitchMeAI | See Remote section |
| TheirStack | Requires `mcp__theirstack__*` tools. Gate: if not connected, skip and note. |

---

### Contract / freelance

| Site | Fetch method |
|---|---|
| Upwork | Requires `mcp__1cb44f76-c627-45b2-8050-35e78e7f15c8__upwork_search_freelancers`. **Note:** Upwork searches for freelancers, not job postings — results represent active demand for this skill type, not open positions. Surface as "Contract signals" in a separate section, not as ranked roles. |

---

## Deduplication

Before scoring and displaying results, filter out any role that already exists in the Notion database.

**How to check:** If the `ntn` CLI gate passes (`command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1`), query the database with `ntn datasources query <data-source-id> --limit 100 --json` (resolve the data source ID once via `ntn api /v1/databases/<notionDatabaseId>` → `data_sources[0].id`; paginate with `--start-cursor` until `has_more` is false) and extract the `Company` + `Position` pairs in the shell. Otherwise query the Notion database using `notionApi` `API-query-data-source` with `notionDatabaseId` from preferences. If the `notionApi` server is also not connected in the current session (e.g. Cowork, which provides only the standard Notion connector), use `notion-query-database-view` on the database URL instead and extract the same pairs — but if the returned table is misaligned (row/column counts don't match, cells empty where neighbours are not), do not parse it: log a warning, skip dedup for this run, and note in the results that duplicates were not filtered. A skipped dedup is recoverable; a mispaired Company/Position exclusion silently hides a real role. Extract all `Company` + `Position` pairs. For each search result: if `(company name, role title)` matches any existing pair (case-insensitive, substring match on title), exclude it from results. Log the count of excluded duplicates.

If `notionDatabaseId` is not set, skip dedup and display a warning: "Notion deduplication skipped — no database ID configured. Run /career-engine:setup to configure."

---

## Scoring Rubric

Score every result (0–100) after deduplication.

| Signal | Points |
|---|---|
| Title — exact match to a target title | 20 |
| Title — partial / fuzzy match | 10 |
| Posted ≤ 3 days ago | 8 |
| Posted 4–7 days ago | 4 |
| Remote match (matches `remotePreference` exactly) | 10 |
| Salary meets or exceeds `minSalary` (only when listed) | 10 |
| Salary listed (any amount) | 5 |
| Applicant count < 50 (LinkedIn only) | 8 |
| Hiring manager identified (LinkedIn only) | 15 |
| Easy Apply available (LinkedIn only) | 4 |
| Apply URL present (non-LinkedIn sources) | 6 |

Cap at 100. Sort descending. Roles without a title match should not appear unless no matches exist.

---

## Verification Pass (mandatory before output)

Run on the ranked list after scoring — every result that will be displayed or offered for Notion add. Full verification applies to the top 20 by score; below that, run only item 2 on text already in hand (no extra fetches).

**1. Careers-page cross-check.** Locate the role on the company's own careers page (ATS fetch methods above, or `site:<company-domain>` search). Outcomes:
- **Listed** — capture any detail the board listing lacks (location nuance, salary, team, reporting line) and merge it into the result.
- **Not listed** — the role may be filled or pulled. Do not drop it; flag `[Not on careers page — verify before applying]`.
- **Listed with different terms** — the careers-page version wins; note the discrepancy.
While there, capture staleness signals: original posting date and re-post indicators (e.g. hiring posts months older than the board date). Flag roles open or re-posted 90+ days.

**2. Location deep-scan.** Location truth is rarely confined to the location field — clues hide in the full text and metadata and get overlooked. Scan the complete listing text plus metadata (structured data, board location tags, the careers-page entry, visible hiring posts) for: stated location or timezone requirements, the REASON given for them, work-authorization language, and operational clues (an EOR provider such as Deel or Oyster in the application flow, postings in multiple countries, distributed-team statements). Record what was found and where.

**3. Remote-geography rule.** A role advertised as remote is NEVER excluded for a geographic restriction found in its text (e.g. "US only", "primarily EST timezone"). Surface it in the ranked list and include it in the Notion-add offer regardless of score, with a one-line note carrying: the restriction as written, its stated reason, and any exception-path evidence from the deep-scan (EOR in place, hires outside the stated country, a timezone rationale the user's location satisfies as well or better). The user decides; the engine never silently hides a remote role over geography. Remote restrictions are often softer than written — this protects any user hunting remote roles from outside the restricted country.

---

## Exclusion Rules

**Geography is never an exclusion for remote roles.** A geographic restriction in a remote-advertised role's text is handled by the Verification Pass remote-geography rule above — noted, never excluded.

Exclude any result where:
- The title contains any `excludePatterns` value (case-insensitive substring match)
- The role is already in the Notion database (see Deduplication)
- The role was already surfaced in a previous search session saved to `{{OUTPUT_FOLDER}}/sourcing/` (check saved search files from the last 14 days — skip roles that appeared with the same company + title)

---

## What Is Not a Role

Do not surface:
- Aggregator "job alert" pages (no actual company or description)
- Roles with no company name
- Roles where the only content is a stub or redirect
- Upwork listings (surface separately as contract signals, never as ranked roles)
