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

## Search Selection Logic

**Before searching any built-in boards:** read `preferred_job_sites` and `local_job_sites` from `${CAREER_DATA}/references/pipeline-preferences.json`. Search these first, in order listed. User-specified sites always take priority over plugin-suggested boards. Only proceed to plugin defaults after exhausting the user's list. If the fields are empty arrays or absent, proceed directly to the tier system below.

Source selection is layered, not mode-based. Every run starts with the full Tier 1 core, then adds tiers based on preferences and career.

### Tier 1 — Always search (every run, no exceptions)

| Site | Category |
|---|---|
| LinkedIn Jobs | Core board (MCP) |
| Indeed | Core board |
| Glassdoor | Core board |
| BuiltIn | Core board |
| Crunchbase | Company intelligence |
| PitchBook | Company intelligence |
| Tracxn | Company intelligence |

### Tier 2 — Remote sites (when `remotePreference` includes "remote" or "remote only")

| Site |
|---|
| Remote.co |
| We Work Remotely |
| Remote OK |

### Tier 3 — Accelerator portfolio boards (every run — pick 2–3 most relevant)

Choose 2–3 from the list below. Selection criteria: portfolio overlap with the user's target company stage/sector, user's target function. Default when no signal: a16z + First Round.

a16z · First Round · Sequoia · Bessemer · NFX · Accel · Lightspeed · Index Ventures · General Catalyst

### Tier 4 — Career-specific boards (choose based on `USER_PROFESSION` and `USER_FUNCTION_SENIORITY_HIERARCHY`)

| Site | Relevant for |
|---|---|
| Product Marketing Alliance | Product marketing, PMM |
| Sharebird | Product marketing, PMM |
| Exit Five | Marketing broadly |
| Wellfound | Startup-focused roles, any function |
| Welcome to the Jungle | Startup-focused roles, any function |
| Y Combinator Jobs (Work at a Startup) | Startup-focused roles, any function |
| Techstars Jobs | Startup-focused roles, any function |

Read `USER_PROFESSION` and `USER_FUNCTION_SENIORITY_HIERARCHY` from `career-data` `01-writing-rules.md` §8 before selecting. Include all sites relevant to the user's function; include startup-focused sites when the user's target companies are predominantly early-stage.

### Explicit mode overrides

If the user specifies a mode keyword, apply it as an override on top of the tiers:

| Mode | Effect |
|---|---|
| `quick` | LinkedIn MCP only — skip all other sites including the rest of Tier 1 |
| `full` | All tiers + all career-specific sites + all accelerators |
| `contract` | Upwork + Fiverr (contract signals, not ranked roles) |

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

**Tier 2 remote sites (search when `remotePreference` includes remote):**

| Site | Fetch method |
|---|---|
| Remote.co | `WebFetch("https://remote.co/remote-jobs/")` — filter by title. If sparse: `WebSearch("site:remote.co [title] remote job")` |
| We Work Remotely | `WebSearch("site:weworkremotely.com [title]")` — blocks direct fetch reliably; use WebSearch. |
| Remote OK | `WebSearch("site:remoteok.com [title]")` or `WebFetch("https://remoteok.com/remote-[title-slug]-jobs")` |

**Additional remote boards:**

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
| MoaiJobs | `WebFetch("https://www.moaijobs.com/")` + `WebSearch("site:moaijobs.com [title]")` |
| CareerVault | `WebFetch("https://careervault.io/")` + `WebSearch("site:careervault.io [title]")` |

---

### General boards

| Site | Fetch method |
|---|---|
| Indeed | `WebSearch("site:indeed.com [title] [location or remote] job")` — do not attempt direct WebFetch (auth wall). If `mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__search_jobs` is connected, prefer it. |
| Glassdoor | `WebSearch("site:glassdoor.com/job-listing [title]")` — blocks direct WebFetch; use WebSearch only. |
| BuiltIn | `WebSearch("site:builtin.com [title] remote")` — blocks direct fetch; use WebSearch only. |
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

### Accelerator portfolio boards (Tier 3)

Pick 2–3 per run based on portfolio fit. Fetch the board and filter by title; `WebSearch("site:[domain] [title]")` as fallback when direct fetch is blocked or sparse.

| Accelerator | Fetch method |
|---|---|
| a16z | `WebFetch("https://jobs.a16z.com/")` — filter by title |
| First Round | `WebFetch("https://jobs.firstround.com/")` — filter by title |
| Sequoia | `WebFetch("https://www.sequoiacap.com/jobs/")` or `WebSearch("site:sequoiacap.com jobs [title]")` |
| Bessemer | `WebFetch("https://www.bvp.com/jobs")` or `WebSearch("site:bvp.com jobs [title]")` |
| NFX | `WebFetch("https://www.nfx.com/jobs")` or `WebSearch("site:nfx.com jobs [title]")` |
| Accel | `WebFetch("https://jobs.accel.com/")` — filter by title |
| Lightspeed | `WebFetch("https://jobs.lsvp.com/")` — filter by title |
| Index Ventures | `WebFetch("https://jobs.indexventures.com/")` — filter by title |
| General Catalyst | `WebFetch("https://www.generalcatalyst.com/jobs")` or `WebSearch("site:generalcatalyst.com jobs [title]")` |

---

### Career-specific boards (Tier 4)

Select based on `USER_PROFESSION` / `USER_FUNCTION_SENIORITY_HIERARCHY`.

| Site | Fetch method |
|---|---|
| Product Marketing Alliance | `WebFetch("https://productmarketingalliance.com/jobs")` — filter by title. Fallback: `WebSearch("site:productmarketingalliance.com jobs [title]")` |
| Sharebird | `WebSearch("site:sharebird.com jobs [title]")` |
| Exit Five | `WebFetch("https://jobs.exitfive.com/")` or `WebSearch("site:exitfive.com jobs [title]")` |
| Wellfound | `WebFetch("https://wellfound.com/jobs?query=[title-urlencoded]&remote=true")` or `WebSearch("site:wellfound.com [title]")` |
| Welcome to the Jungle | `WebFetch("https://www.welcometothejungle.com/en/jobs?query=[title-urlencoded]")` or `WebSearch("site:welcometothejungle.com [title]")` |
| Y Combinator Jobs | `WebFetch("https://www.workatastartup.com/jobs?query=[title-urlencoded]")` or `WebSearch("site:workatastartup.com [title]")` |
| Techstars Jobs | `WebFetch("https://www.techstars.com/job-board")` — filter by title. Fallback: `WebSearch("site:techstars.com job-board [title]")` |

---

### Company intelligence boards (Tier 1 — last three)

These surfaces list roles at funded/tracked companies not always indexed on general boards. Fetch the jobs or portfolio section and filter by title.

| Site | Fetch method |
|---|---|
| Crunchbase | `WebSearch("site:crunchbase.com [title] jobs")` — direct fetch requires login; use WebSearch for role-level results. Also surface as company research context (funding stage, team size) for scored results. |
| PitchBook | `WebSearch("site:pitchbook.com [title] jobs")` — primarily company intelligence; use to enrich context for discovered roles. |
| Tracxn | `WebSearch("site:tracxn.com [title] jobs")` — similar to PitchBook; use for company context enrichment. |

**Note on company intelligence sites:** These are less reliable as direct role sources and more useful as enrichment for roles found elsewhere. If a WebSearch returns direct apply links or job pages, add them to the ranked list. If results are company profiles only, use them to enrich the Company field (funding stage, investor list, headcount) for roles discovered via other sites — especially when scoring and building context for the user.

---

### Contract / freelance

| Site | Fetch method |
|---|---|
| Upwork | Requires `mcp__1cb44f76-c627-45b2-8050-35e78e7f15c8__upwork_search_freelancers`. **Note:** Upwork searches for freelancers, not job postings — results represent active demand for this skill type, not open positions. Surface as "Contract signals" in a separate section, not as ranked roles. |
| Fiverr | `WebSearch("site:fiverr.com [title] OR [skill-category]")` — surfaces active buyer demand (Fiverr Pro projects, service categories). **Note:** Like Upwork, Fiverr results represent demand signals, not open positions. Surface as "Contract signals" alongside Upwork results, not as ranked roles. |

---

## Deduplication

Before scoring and displaying results, filter out any role that already exists in the Notion database.

**How to check:** If the `ntn` CLI gate passes (`command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1`), query the database with `ntn datasources query <data-source-id> --limit 100 --json` (resolve the data source ID once via `ntn api /v1/databases/<notionDatabaseId>` → `data_sources[0].id`; paginate with `--start-cursor` until `has_more` is false) and extract the `Company` + `Position` pairs in the shell. Otherwise query the Notion database using `notionApi` `API-query-data-source` with `notionDatabaseId` from preferences. If the `notionApi` server is not connected or returns an Enterprise-gated response, fall through and use `notion-query-database-view` — but note its two constraints (R-39): it takes no ad-hoc `filter` argument and requires a real **view URL** (`...?v=<VIEW_ID>`), never the bare database URL. Resolve a view by name using a two-step fetch: (1) call `notion-fetch id="<notionDatabaseId>"` to get the `collection://` URL from the `<data-sources>` block; (2) call `notion-fetch id="<collection_url>"` to list views, find one named "All Active Applications" (or any broad view), take its UUID from the `view://UUID-with-dashes` format, **remove all dashes**, and construct `https://www.notion.so/<DB_ID_NO_DASHES>?v=<VIEW_ID_NO_DASHES>`; call `notion-query-database-view` with that `view_url` and extract the same pairs — but if the returned table is misaligned (row/column counts don't match, cells empty where neighbours are not), do not parse it: log a warning, skip dedup for this run, and note in the results that duplicates were not filtered. A skipped dedup is recoverable; a mispaired Company/Position exclusion silently hides a real role. Extract all `Company` + `Position` pairs. For each search result: if `(company name, role title)` matches any existing pair (case-insensitive, substring match on title), exclude it from results. Log the count of excluded duplicates.

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
| Screening conflict — a populated `screening_answers` field contradicts a stated JD requirement | −15 (down-rank, never exclude; attach a visible label) |

Cap at 100. Sort descending. Roles without a title match should not appear unless no matches exist.

**Standing screening answers (`screening_answers` from `${CAREER_DATA}/references/pipeline-preferences.json`).** If present, compare each *populated* field (travel / relocation / security_clearance / compensation_floor / availability) against the JD. A hard conflict (e.g. role explicitly requires relocation while `relocation` = "no") applies the −15 down-rank above **and** attaches a visible reason label to the row (`⚠ screening: relocation required vs your "no"`) so the user sees exactly why it ranked lower. **Never silently exclude on a screening conflict** — down-rank + label only, and log it in the run output. `compensation_floor` feeds the existing `minSalary` signal: when `minSalary` is not otherwise configured, use `screening_answers.compensation_floor` as `minSalary`. If `screening_answers` is absent or empty, skip this entirely (no labels, no down-ranks).

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

**A screening conflict is never an exclusion either.** A populated `screening_answers` field contradicting the JD is handled by the Scoring Rubric — down-ranked and labeled, never dropped. The user decides.

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
