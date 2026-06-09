---
name: job-search
description: Search for jobs across LinkedIn (via LinkedIn MCP) and Hacker News Who's Hiring. Scores and ranks results against saved preferences. Use when the user wants to find jobs, search for positions, or explore open roles. Requires the LinkedIn MCP (stickerdaniel/linkedin-mcp-server) for LinkedIn results.
allowed-tools: Read, Write, Bash, WebSearch, WebFetch, mcp__linkedin-mcp__search_jobs, mcp__linkedin-mcp__get_job_details, mcp__linkedin-mcp__get_company_profile, mcp__linkedin-mcp__search_people
---

# Job Search

Multi-source job search across LinkedIn and Hacker News Who's Hiring. Scores results against your saved preferences, surfaces hiring manager signals, and saves structured output.

---

## Phase 1 — Load Preferences

Read `~/.career-engine-job-prefs.json`. Check for a `preferences` key.

**If no preferences found**, say:

> No search preferences saved. Let me set them up now — this takes about 2 minutes and you only do it once.

Then run the preference Q&A below. **Do not continue without preferences.**

**Preference Q&A:**

Ask the following in sequence. Collect all answers before saving.

1. **Target titles** — "What job titles are you targeting? List them all." (Free-form — accept a list.)
2. **Minimum salary** — "What's your minimum acceptable base salary? (e.g., $150K, €80K — or 'no minimum')"
3. **Remote preference** — "Remote only, hybrid, or open to all?"
4. **Exclude patterns** — "Any words that should automatically exclude a role? (e.g., 'junior', 'intern', 'contract' — or 'none')"
5. **Default time range** — "How far back should searches look by default? (last week / 2 weeks / month)"
6. **Primary location** — "What location should be used for LinkedIn searches? (city and country, e.g., 'Tel Aviv, Israel' or 'London, UK')"

Save to `~/.career-engine-job-prefs.json`:

```json
{
  "preferences": {
    "targetTitles": ["Title 1", "Title 2"],
    "minSalary": "$150K",
    "remotePreference": "remote only",
    "excludePatterns": ["junior", "intern"],
    "defaultTimeRange": "last week",
    "location": "Tel Aviv, Israel"
  }
}
```

Confirm: "Preferences saved. Starting search now."

---

## Phase 2 — Parse Overrides

The user may pass arguments when invoking:
- Time range override: `last week`, `2 weeks`, `month`
- Source filter: `linkedin`, `hn` (default: both)
- Extra keywords: any additional words to include alongside target titles

Display the active search config before proceeding:

> **Searching with:**
> - Titles: [list]
> - Salary floor: [value]
> - Remote: [value]
> - Time range: [value]
> - Sources: [LinkedIn / HN / both]

---

## Phase 3a — LinkedIn Search (LinkedIn MCP)

**Gate:** If the LinkedIn MCP is not connected (tools named `mcp__linkedin-mcp__search_jobs` are unavailable), skip this phase entirely and report: "LinkedIn MCP not connected — skipping LinkedIn search. Connect stickerdaniel/linkedin-mcp-server to enable this source."

**For each target title, run:**

```
search_jobs(
  keywords = "[title]",
  location = preferences.location,
  max_pages = 3,
  date_posted = [map time range: "last week" → "past_week", "2 weeks" → "past_month", "month" → "past_month"],
  work_type = [map remotePreference: "remote only" → "remote", "hybrid" → "hybrid", "open to all" → null],
  sort_by = "date"
)
```

Collect all `job_ids` from results. Deduplicate across title searches.

**For each job_id (up to 30 total):**

Run `get_job_details(job_id)`. Extract:
- Title, company, location, work type
- Posted date (derive approximate days-ago from "X days ago" text if present)
- Applicant count if present
- Hiring manager name and URL if present in references
- Easy Apply flag if mentioned

**Exclude any result** where the title text matches any `excludePatterns` (case-insensitive substring match).

---

## Phase 3b — Hacker News Who's Hiring (WebSearch + WebFetch)

1. Use `WebSearch` to find: `"Ask HN: Who is hiring?" site:news.ycombinator.com [current month] [current year]`
2. Extract the thread ID from the result URL (format: `https://news.ycombinator.com/item?id=XXXXXXXX`)
3. Fetch the thread data: `WebFetch("https://hacker-news.firebaseio.com/v0/item/{THREAD_ID}.json")`
4. Parse the `kids` array (up to first 100 comment IDs)
5. For each comment ID, fetch: `WebFetch("https://hacker-news.firebaseio.com/v0/item/{COMMENT_ID}.json")`
   - Pause briefly between API calls to avoid rate limiting
6. Parse each comment's `text` field. HN postings typically follow: `Company | Role | Location | Remote | Salary`
7. Extract: company, title, location, remote status, salary (if present), apply URL

**Filter against preferences:**
- Title must fuzzy-match at least one `targetTitles` entry (partial match acceptable)
- Exclude if text contains any `excludePatterns`
- Exclude if "remote only" preference and posting does not mention "remote"
- Skip if salary is listed and is below `minSalary`

---

## Phase 4 — Scoring

Score every result (LinkedIn and HN) on a 0–100 scale.

### Scoring rubric

| Signal | Points | Notes |
|---|---|---|
| Title — exact match | 20 | Case-insensitive exact match to a target title |
| Title — partial match | 12 | Substring match |
| Salary meets/exceeds floor | 10 | Only when salary is listed |
| Remote match | 10 | Matches `remotePreference` exactly |
| Recency — posted ≤3 days ago | 5 | |
| Recency — posted 4–7 days ago | 3 | |
| Low competition — <50 applicants | 5 | LinkedIn only |
| Hiring manager identified | 20 | LinkedIn only — name present in job details |
| Easy Apply | 5 | LinkedIn only |
| Salary explicitly listed | 10 | HN only |
| Apply URL present | 10 | HN only |

**Normalize to 0–100:**
- LinkedIn max possible: 75. Score = `raw / 75 × 100`
- HN max possible: 60. Score = `raw / 60 × 100`

Round to nearest integer. Sort descending.

---

## Phase 5 — Output

### Terminal display

```
=================================================================
  Job Search Results
=================================================================
  Titles: [list]  |  Sources: LinkedIn ([N]), HN ([N])
  Filters: [remote] | [time range] | Salary >= [floor]
  Total: [N] results
=================================================================

Score | Source   | Title                     | Company       | Location       | Notes
----- | -------- | ------------------------- | ------------- | -------------- | -----
  94  | LinkedIn | Senior Product Manager    | Acme Corp     | Remote         | HM identified, Easy Apply
  81  | HN       | Product Manager (Senior)  | CoolStartup   | Remote ($180K) | Salary listed, Apply URL
  ...

=================================================================
  [N] with hiring managers  |  [N] with salary listed
=================================================================
```

### Save to file

Save full results to `{{OUTPUT_FOLDER}}/job-searches/search-[YYYY-MM-DD].md`:

```markdown
# Job Search — [date]

## Parameters
- Titles: [list]
- Salary floor: [value]
- Remote: [value]
- Time range: [value]

## Results (ranked)

### 1. [Title] — [Company] (Score: [N])
- **Source:** LinkedIn | HN
- **Location:** [value]
- **Salary:** [value or "not listed"]
- **Posted:** [value]
- **Hiring Manager:** [name and LinkedIn URL, or "not identified"]
- **Apply:** [URL or "Easy Apply" or "see HN thread"]
- **Applicants:** [N or "not shown"]
```

Create the `{{OUTPUT_FOLDER}}/job-searches/` directory if it doesn't exist.

### High-score prompt

If any results scored 75+, ask:

> **[N] jobs scored 75+. Add them to your intake queue?** (yes / no)

If yes: prompt the user to add the role URLs to the intake flow via `/career-engine:intake`.

**Never add to the Notion database directly** — that is the intake skill's job.

---

## Usage Examples

```
/career-engine:job-search
→ loads preferences, searches both sources, displays results

/career-engine:job-search 2 weeks
→ uses 2-week time range instead of default

/career-engine:job-search hn
→ searches Hacker News only

/career-engine:job-search linkedin
→ searches LinkedIn only (requires LinkedIn MCP)
```

---

## Safety Rules

1. Never enter credentials in any form
2. Never click Apply — this skill searches only
3. Max 30 LinkedIn job_ids, 100 HN comments per run
4. If a source fails, skip it and continue — report which sources succeeded
5. Never write to the Notion database directly
