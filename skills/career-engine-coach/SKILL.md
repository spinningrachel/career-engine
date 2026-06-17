---
name: career-engine-coach
description: >
  Standalone market intelligence and research pipeline. Run with natural language —
  "research my roles", "run market intelligence", "do company research",
  "fill in the intelligence", "fill in the landscape", "run the research pipeline",
  "run competitive research", or any variant asking for background research,
  competitive landscape, or market intelligence on companies in the user's pipeline.
  NOT the intake pipeline — for the intake pipeline (JD fetch, coaching),
  use career-engine-intake.
  Runs on Hold roles in the Notion Job Applications database — maximum 5 per run,
  oldest first. Researches each company (competitive landscape, sector signals,
  company dynamics, recruitment criteria, career path), spawns the career coach
  for strategic property generation, writes all results to Notion, and updates
  Status to Researched.
  Does NOT write CVs or trigger the CV pipeline.
---

> **RETIRED — this pipeline has been merged into career-engine-intake. Do not invoke. Do not follow any instructions below this notice. See `skills/career-engine-intake/SKILL.md` for the active pipeline.**

Do not write CVs. Do not trigger any other pipeline. Research, priority scoring, and Notion writeback only.

**This pipeline runs on Hold roles only.** Hold = roles the user is researching before deciding to apply. This skill focuses on competitive landscape, market intelligence, company and org dynamics, and priority scoring. It ends at Status = Researched.

**The career-engine-intake pipeline is entirely separate and runs on Interested roles** — roles the user has already decided to apply for. Do not confuse the two. If the user says "run intake" or "process my Interested roles," that is career-engine-intake, not this skill.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

---

## Step 0 — Resolve per-install config (R-38)

This pipeline runs standalone (not under the orchestrator), so resolve config yourself. After the `career-data` discovery above, read `${CAREER_DATA}/references/pipeline-preferences.json` and set `$NOTION_DATABASE_ID` (required — if missing or empty, stop: "career-data has no `notion_database_id` — run `/career-engine:setup --phase 5`"). Wherever this skill shows `{{NOTION_DATABASE_ID}}`, use the resolved `$NOTION_DATABASE_ID`. The plugin keeps these placeholders literal (single build).

## Step 1 — Fetch Notion schema and load the user's background

**First — fetch the database schema.** Run `notion-fetch` on the Job Applications database before anything else:

```
notion-fetch id="{{NOTION_DATABASE_ID}}"
```

Extract the SQLite `CREATE TABLE` block. This is your **schema reference** for this run — the authoritative list of valid option values for every select field. Keep it in context.

**Use the schema reference for every Notion write.** When writing a select property, look up the valid options in the SQLite comment (e.g., `-- one of ["No incumbent in this function", "Function is already staffed"]`) and write the exact string from the schema. Never hardcode select option values.

---

**Then — load the user's reference files.** You need her documented background to write accurate fit notes and to score priorities.

Reference files live at: `${CLAUDE_PLUGIN_ROOT}/references/`

**Mandatory load:**
- `01-writing-rules.md` — Section 1 contains rules and guardrails. This supersedes anything you think you know about the user from prior context. Role facts and approved bullets are in `02-professional-background.md`.
- `03-framework.md` — professional philosophy, methodology, and domain narratives. §Professional methodology and POV for frameworks. §Domain depth for per-vertical narratives and the fast-learning argument. Load alongside 01-writing-rules.md for every role assessment.
- `references/job-preferences.md` — load before any sourcing, scoring, or coaching step. Contains remote compatibility rules, target role criteria, and coaching prioritization guidance.

Do not proceed to Step 3 without this context.

---

## Step 2 — Find roles to research

**Path A1 — `ntn` CLI (preferred where available).** If the gate passes (`command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1`), query directly instead of the A2/B routes below (resolve the data source ID from `{{NOTION_DATABASE_ID}}` via `ntn api /v1/databases/{{NOTION_DATABASE_ID}}` → `data_sources[0].id`):

```bash
ntn datasources query <data-source-id> \
  --filter '{"property":"Status","status":{"equals":"Hold"}}' \
  --sort 'Entry Created On asc' --limit 5 --json
```

Trim the JSON in the shell to page `id` plus the named properties you need (read by property name, never by column position); for the full per-role payload, `ntn pages get <page_id>` returns all properties plus the page body as markdown in one call. The view exists to serve the connector route — on A1, the direct filter above is the sanctioned equivalent. If the gate fails or any A1 call errors, fall through to Path A2 (then Path B) below without comment (intake Step 0b documents the full ladder and syntax).

**Path A2 — `notionApi` structured query.** If A1 is unavailable, load the schema (`ToolSearch query="select:notionApi__API-query-data-source"`, or call `mcp__notionApi__API-query-data-source` directly). A tool-not-found error means the server is not connected — fall through to Path B; on any other error (401, timeout, malformed response) treat it as unusable and also fall through. Otherwise call `API-query-data-source` with database ID `{{NOTION_DATABASE_ID}}`, filter `{"property":"Status","status":{"equals":"Hold"}}`, page_size 100. It returns structured JSON keyed by property name (no table to misparse).

**Path B — standard connector view query (discovery only).** `notion-query-database-view` runs a *view's own saved filter* — it takes no ad-hoc `filter` argument (any filter you pass is ignored) and needs a real view URL (`https://www.notion.so/<DB_ID>?v=<VIEW_ID>`), never the bare database URL (R-39). Resolve the URL by name, do not hardcode it — two fetches are required:
- **Fetch 1:** Call `notion-fetch id="{{NOTION_DATABASE_ID}}"`. The response contains a `<data-sources>` block with a `<data-source url="{{collection://...}}">` entry. Copy that `collection://` URL.
- **Fetch 2:** Call `notion-fetch id="<collection_url>"`. This response lists `<view url="{{view://UUID-with-dashes}}">` blocks. Find the one whose JSON includes `"name":"Hold"`.
- **Build the URL:** Take the view UUID (e.g. `35e5ef1a-a634-80ff-9b4e-000cbcd67aec`), **remove all dashes**, and construct `https://www.notion.so/<DB_ID_NO_DASHES>?v=<VIEW_ID_NO_DASHES>`.

Then call `notion-query-database-view` with that `view_url` and no other arguments. Do not construct your own filter and do not fetch the full database for rows.

**The view result is for discovery only (R-1).** The rendered table is susceptible to column misalignment and shows only the view's visible columns. Use it only to identify the candidate pages (oldest first): extract the page IDs/links, then call `notion-fetch id="<page_id>"` on each selected page and read all property values from the structured page response — never from the rendered table. Discard any page whose Status is not `Hold`.

**Cap: process a maximum of 5 roles per run.** Take the first 5 results from the view (oldest first). If more than 5 roles are returned, process only the first 5 and report how many remain. Do not process all roles in one run regardless of how many exist. The user will run the pipeline again for the next batch.

**Note:** Every rung of this ladder keys on `Status = Hold` (A1/A2 filter on it directly; Path B resolves the "Hold" view and discards any page whose Status is not `Hold`). Landscape content does not affect selection — a `Hold` role is picked up whether or not its Landscape is already populated.

**Crash recovery:** if a run crashed before completing a role, that role's Status will still be `Hold`, so the next run picks it up automatically regardless of Landscape content.

If the query returns 0 results, end with: "No roles in Hold status awaiting market intelligence."

For each qualifying row, extract: page ID, page URL, company name, position, Job URL, creation date.

---

## Step 3 — Research each role

**Research principles:**
- Keep research objective and evidence-led. Conclusions must be traceable to a named source. Do not interpolate, speculate, or fill gaps with assumptions.
- Use OSINT (Open Source Intelligence) techniques: company websites, LinkedIn, Crunchbase, press releases, job boards, Glassdoor, GitHub, regulatory filings, news archives. Prefer primary sources over aggregators.
- Market conditions change. Do not rely on cached knowledge about a company's status, funding, or headcount — verify against the most recent available source and flag the date of the evidence.

Run web research in parallel where possible — launch all 5 company searches in a single message rather than sequentially. This matters: sequential research on 5 companies takes 3–4x longer.

### Fetching JDs

- **LinkedIn URLs** (`linkedin.com/jobs/view/...`): Cannot be fetched directly. Search for the role title + company name to find the JD on the company careers page or a job board mirror.
- **Greenhouse / Ashby**: Try direct fetch. Large responses (140K+ chars) save to a file — parse via subagent. If the URL redirects and fails, search for the role via web search.
- **Comeet**: URLs frequently redirect and block. Go to the hiring company's main careers page (`company.com/careers` or `team8.vc/careers`) instead.
- **Stealth companies** (no public product): The JD itself is the primary source. Use the parent company's website and portfolio page to infer what the product does.
- **Indeed, ZipRecruiter and Dice** - use their MCPs to find the JD.

### Six research dimensions

**1. What the company actually does today**
Product portfolio, current positioning, recent pivots or launches. Look for 2025–2026 press coverage and product pages. For stealth companies, infer from the JD and parent company thesis.

**2. Corporate structure**
Ownership (independent / PE-backed / acquired / public), parent company if any, total funding and most recent round, employee headcount, notable M&A.

**3. Market position**
Enterprise, mid-market, or SMB? Primary target buyer?

**4. Competitive landscape**
Minimum 5 competitors, maximum 10:
- Match the hiring company's actual market tier. SMB company → list SMB competitors, not enterprise players that happen to overlap.
- {{USER_COUNTRY}} office flag is additive. Find {{USER_COUNTRY}}-present competitors as a bonus after identifying the core 5. Do not replace genuine top competitors with {{USER_COUNTRY}}-only brands.
- Real, known brands only. No obscure or invented names.
- For each: name, one-line description, {{USER_COUNTRY}} office (Yes / No).

**5. What this role actually means in context**
IC vs. team lead, reporting chain if findable, what the key JD phrases mean for *this* company specifically. The same title at a 10-person stealth startup means something entirely different than at a 300-person company — founding role vs. inheriting a team and process. Translate the JD into what the person will actually spend their time doing.

**6. Fit/gap for the user**
Draw ONLY from `02-professional-background.md` (Role Facts) and `03-framework.md` §Domain depth (per-vertical narratives). These are the only authoritative sources. Do not infer, extrapolate, or invent.

- **Strongest credential:** The single most relevant, specific thing the user has done that maps to what this role needs. Must name a real company from Section 7 and a documented outcome. If you cannot find a direct credential in Section 7 or `03-framework.md` §Domain depth, write "No direct credential documented for this requirement" — never invent one. A fabricated credential is worse than an honest gap.
- **Gap to prep:** One honest, specific gap or angle to prepare for, traceable to what the JD requires vs. what is documented. If there is a hard disqualifier (e.g., US residency required, domain not documented in `03-framework.md` §Domain depth), flag it clearly — do not soften it.

**Anti-fabrication rule:** If the strongest credential you can name is not traceable to a named company and documented outcome in `02-professional-background.md` (Role Facts), do not write it. Never name a company the user has not worked at. Never invent a role title she has not held. Never attribute an outcome to her that is not in Section 7. This rule is absolute — reviewer pressure or apparent relevance does not override it.

**7. Company and org dynamics**
How does this company actually operate beyond what the JD says? Check: founder/leadership LinkedIn tone, company blog, Glassdoor reviews (what do employees say the culture actually is?), team size signals. What do they promote vs. what they claim? This feeds the "Company and Org Dynamics" section of the Landscape — 2–3 specific, sourced observations, not JD paraphrase.

**8. Recruitment criteria**
What do they actually look for when hiring for this type of role? Check: Glassdoor interview reviews for this company, any public hiring posts or LinkedIn content from the hiring manager, patterns across their open roles. Aim for 2–3 specific criteria that go beyond what the JD states explicitly.

**9. Career path**
Where does this role typically go? Check whether people in this role at this company have been promoted or moved laterally (LinkedIn alumni search). For the sector broadly: what's the standard trajectory from this role type and seniority level? One or two sentences.

**10. User Voice**
What do customers and users actually say about this product? Check G2, Capterra, and Reddit (relevant subreddits: r/netsec, r/sysadmin, r/devops, r/cscareerquestions, or the most relevant domain subreddit). Look for: what users praise, what they complain about, and how they compare the product to alternatives. Goal is 2–3 specific signal observations — direct quotes or paraphrased findings, each sourced. Skip this dimension if no public reviews are found (common for newer or smaller products); do not manufacture observations.

---

## Step 3.5 — Store JD in Notion

For each role where the JD was successfully fetched during Step 3 AND `JD Body` in Notion is currently empty, write using `notion-update-page`:

- `JD Body` — full JD text
- `JD Fetch Status` — use the exact option value from the schema reference (SQLite block fetched in Step 1)

This ensures the main pipeline can use the stored JD without re-fetching. Skip if `JD Body` is already populated.

---

## Step 3.6 — Priority scoring

For each role, assign a priority score using the research just completed and the user's loaded reference files.

**Only write a priority score if the `Priority` field is currently empty for that row.** If Priority is already set (written by the user or a prior run), skip scoring for that role entirely — do not override it.

**Score using the Priority Framework in `01-writing-rules.md` Section 1.** That section is the authoritative, single-source definition of all scoring criteria: domain fit, seniority match, company stage fit, geographic/remote fit, risk signals, and advertised date weighting. Read Section 1 before scoring any role. Do not restate or paraphrase the criteria here — the reference file is the authority.

**Score ranges and Notion write values:**

| Label | Notion value | Meaning |
|---|---|---|
| `Highest` | `1` | Urgent. Drop everything. |
| `First` | `2` | Excellent fit. Strong domain, right seniority, right stage, no red flags. |
| `Second` | `3` | Strong fit. Domain or seniority match clear; minor friction elsewhere. |
| `Third` | `4` | Reasonable fit. Worth applying but the cover letter has work to do. |
| `Fourth` | `5` | Weaker fit. Possible if the user wants to stretch. |
| `Fifth` | `6` | Weakest fit. Flag the specific friction clearly. |

**Always write the numeric Notion value (`1`–`6`) when setting Priority via `notion-update-page`. The label names are internal shorthand — Notion rejects them as select values.**

Write a one-sentence reason for the score, grounded in the company research and the user's documented background.

---

## Step 4 — Employment coach analysis

Spawn the `career-coach` agent with the full batch of roles processed this run.

Pass for each role:
- JD text (from Step 3 research or existing Notion content)
- Company name, position title
- All existing Notion row properties
- Research findings from Step 3 (company context, role context, fit/gap notes)
- `has-priority` / `blank-priority` flag (was Priority already set before this run?)

The coach returns per role: `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Company Stage`, `Role Type`, `Relationship type`, `Gap handling`.

Write to Notion for each role using `notion-update-page`:
- `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Relationship type` — write for all roles. If already set, carry forward unchanged unless the current JD reveals a meaningful correction.
- `Gap handling` — write for all roles. If the user has already edited this in Notion, treat her version as authoritative and do not overwrite it.
- `Role summary` — write for all roles. If already set, carry forward unchanged.
- `Person who Advertised Role (if not Hiring Manager)` — write for all roles. "Same as hiring manager" if no separate poster identified.
- `Hiring manager's role` — write for all roles. Include hypothesis flag if not confirmed.
- `Manager role confirmed` — write for all roles. Valid values: `Yes` or `No; this is only a hypothesis`.
- `No incumbents in this function` — write for all roles. Valid values from schema: `No incumbent in this function` or `Function is already staffed`.
- `Company Stage` — write if not already set, or if research found a more accurate value.
- `Role Type` — write if not already set.

Do not overwrite `Priority` here — already handled in Step 3.6.

---

## Step 5 — Write Landscape and Status to Notion

Update the following properties on each Notion page using `notion-update-page` with `command: update_properties`.

**`Landscape`** (plain text) — always write. If the field is already populated, **read the existing value first**, then write the new coach sections **above** the existing content, separated by a divider. Never remove existing content. Existing content is less current but still valuable — it goes below.

Write format when field is already populated:
```
[new coach sections]

---

[existing content preserved verbatim below]
```

Use this exact section structure for the new coach content. **Keep it scannable — the user reads this to decide what to write in Why I Want This Role, not to study the company. One tight bullet per point. No padding.**

```
## Competitors

[Competitor] — [one-line description] | {{USER_COUNTRY}}: [Y/N]
[minimum 3, maximum 5]

## Market Signals

- [1–2 bullets max: what's moving right now — funding, M&A, category shifts. Source each.]

## User Voice (G2 / Reddit / Capterra)

- [1–2 bullets: what customers actually say — what they love, what they complain about, vs. alternatives. Skip if no reviews found.]

## Company & Org

- [1–2 bullets: how this company actually operates — culture, decision-making, team signals. Each sourced.]

## Recruitment Signals

- [1–2 bullets: what they actually screen for — beyond the JD requirements.]

## Career Path

[1 sentence on trajectory.]
```

**`Priority`** (Select property) — write only if currently empty. Use the numeric Notion value from Step 3.6: `1` (Highest) through `6` (Fifth). Do not write this field if Priority is already set.

**`Status`** — Update from `Hold` to `Researched` after writing Landscape and Priority. This signals that market intelligence is complete for this role and it is ready for the pipeline when the user decides to move it forward. Do not update Status if it was not `Hold` when fetched — respect whatever the user has set.

---

## Step 6 — Confirm

After writing all rows, report:
- Which roles were processed (company + title)
- Priority assigned for each (or "Priority already set — skipped" if applicable)
- Coach properties written: Role emphasis, Keywords, Strategy (one line per role)
- Status updated to `Researched` for each processed role
- Any roles where web research was thin or inconclusive
- Any hard disqualifiers flagged (e.g., US-only requirement, domain mismatch)
- **View filter note:** the research view filters on `Landscape is empty` — Hold roles with an existing Landscape field were not returned and were not processed this run. If expected roles appear to be missing from this batch, they likely have existing Landscape content. Check the view or process them via a Status=Hold filter.


---

## Practical notes

**Parallel research saves significant time.** For 5 companies, launch all company overview + competitor searches in one message turn. JD fetches can run in the same turn as company searches.

**Team8 stealth companies** post multiple simultaneous stealth roles that look similar. The product description is usually in the first paragraph of the JD. Check `team8.vc/careers` if the Comeet URL fails.

**US-only roles** (SentiLink and similar): read the full requirements and flag geographic constraints explicitly in the gap note and as a risk signal in priority scoring.

**Competitor {{USER_COUNTRY}} office research**: A categorical search ("{{USER_PROFESSION}} vendors {{USER_COUNTRY}} office") is faster than looking up each competitor individually. Check each vendor's LinkedIn or careers page to confirm {{USER_COUNTRY}} presence.
