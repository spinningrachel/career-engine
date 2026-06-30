---
name: career-engine-intake
description: >
  Intake pipeline for Hold roles. Two modes: **Inline** (user provides a URL or JD
  directly in chat — no Notion fetch; runs JD acquisition and career coach; output
  conversationally) and **Notion-fetch** (queries Hold roles from Notion; runs JD
  acquisition and career coach; writes back to Notion; updates Status to Researched).
  The career coach runs for roles not already coach-complete; all-complete queues skip the coach spawn.
  Trigger with: "run intake", "build the CV queue", "prep my Hold roles", "run the
  intake", or any variant asking to research Hold roles.
  Does NOT write CVs or cover letters.
---

# Intake Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill covers Steps 0 through 0.9 of the intake pipeline. Two modes:

- **Inline mode** — the user provides a URL or JD text directly in chat. No Notion fetch. Run JD acquisition and the career coach. Deliver output conversationally. Use when the user says something like "coach me on this role" and pastes a URL or JD, outside of the batch Notion-fetch flow.
- **Notion-fetch mode** — queries the Notion database for Hold roles, runs JD acquisition and the career coach for each, writes all results to Notion, and updates Status to Researched. This is the standard "run intake" path.

The career coach runs for every role that is not already coach-complete. If all roles in the queue are coach-complete, the coach spawn is skipped and the pipeline proceeds directly to Step 0.9 using existing values. The goal of this pipeline is to give the career coach complete information — full JD data for every role — before it makes any prioritization or writing decisions.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

## Step −0.5 — CAREER_DATA self-locate (standalone invocation only)

**Skip this step if `${CAREER_DATA}` is already set** (set by the orchestrator's preflight before calling intake).

If intake is invoked directly (standalone), locate `career-data` now:

1. Search for a directory named `career-data` (or containing `career-data-marker.json`) under `~/.claude/skills/` and under the Desktop app skill paths.
2. Confirm `career-data-marker.json` is present inside it.
3. If found and healthy: set `${CAREER_DATA}` to that directory path. Continue to Step −1.
4. If found but damaged (marker missing or unreadable): stop and report — "career-data skill found but appears damaged. Re-install it from your `.skill` file via Customize → Skills."
5. If not found: stop and report — "career-data skill is required but was not found. Install it via Customize → Skills in the Desktop app."

Never fall back to blank plugin templates if `career-data` is absent for a configured user.

---

## Step −0.4 — Load the writing rules (every invocation — standalone AND orchestrator-driven)

**This step runs on every invocation. It is NOT part of the standalone-only Step −0.5 above — do not skip it when `${CAREER_DATA}` is already set.** Read `01-writing-rules.md` — the fabrication rule and attribution constraints enforced at Step 0.8.5; it must be in context before the gatekeeper runs. Resolve it like every personal-data file (R-37), same ordering discipline as the gap_handling resolution at Step −1:

1. `${CAREER_DATA}/references/01-writing-rules.md` — the user's **real** writing rules (`${CAREER_DATA}` is resolved by the orchestrator preflight, or in Step −0.5 when standalone). **Authoritative source.**
2. `${CLAUDE_PLUGIN_ROOT}/references/01-writing-rules.md` — the plugin's **blank template**, used **only** when `${CAREER_DATA}` is unset (a genuinely new user with no career-data installed).

A **configured** user's missing/unreachable career-data is a hard stop per the R-37 block above — never silently fall back to the blank template for them; that loads empty rules and is the exact failure R-37 prevents.

---

## Step −1 — Gap handling mode

Read `gap_handling` (use the Read tool) in this resolution order — **the user's career-data config is the authority, exactly as for every other config key (R-37)**:

1. `${CAREER_DATA}/references/pipeline-preferences.json` → `gap_handling` — the user's real config (resolved in Step −0.5). **This is the authoritative source.**
2. `~/.claude/settings.json` → `gap_handling` (legacy location, reachable only in Claude Code on the user's own machine).
3. `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json` → `gap_handling` — the plugin's **blank template**. Always present in every environment (including Cowork), but it ships the shipped default — a last-resort fallback only, **never** the authority.

Set `gap_handling_mode` as follows:
- `"gap_handling": "disabled"` → `gap_handling_mode = disabled`
- `"gap_handling": "enabled"` → `gap_handling_mode = enabled`
- Key missing/empty at a source → try the next source in order. Never treat an unreadable file as an error.
- Missing or any other value at every source → `gap_handling_mode = enabled` (default).

> **Why career-data first, not the plugin file:** the plugin's `references/pipeline-preferences.json` is the single-build **blank template** — it always ships `"gap_handling": "enabled"`. Reading it first silently ignores a user who set `disabled` in career-data, so the coach does gap analysis the user turned off. Every other config key (`database_id`, `location_compatibility`, `screening_answers`, `favorite_brands`) reads from `${CAREER_DATA}`; gap handling must too.

Do not ask the user about this. The preference was set during setup (Phase 5). If she wants to change the default, she updates `gap_handling` in her **career-data** config (`${CAREER_DATA}/references/pipeline-preferences.json`) — or re-runs setup Phase 5, which writes it there. To suppress gap handling for a single run without changing the setting, she can add "no gap handling" to her prompt — check for that phrase in the current prompt and override to `disabled` if found.

**If `gap_handling_mode = disabled`:**
- Instruct the coach (in Step 0.8) to skip the `Gap handling` property entirely — do not populate it, do not write `N/A`.
- Skip the `Gap handling` writeback in Step 0.9a.
- The `coach-complete` check in Step 0.8 must NOT require `Gap handling` to be populated for this run.

**If `gap_handling_mode = enabled`:** proceed normally — gap handling is required for every role as documented.

---

## Step 0 — Fetch Notion schema and roles

**Guard — resolve the database ID and view URLs from the career-data config (R-38).** The plugin keeps `{{NOTION_DATABASE_ID}}` literal by design (single build); the literal placeholder is **not** a sign of incomplete setup — do not abort on it. Resolve from `${CAREER_DATA}/references/pipeline-preferences.json`:
- `$NOTION_DATABASE_ID` ← `database_id` (legacy `notion_database_id`). **Stop only if missing or empty:** "Your career-data config has no `database_id`. Run `/career-engine:setup --phase 5`."
- `$NOTION_HOLD_VIEW_URL` ← `database_hold_view_url` (optional fast-path; empty string if absent).

The database ID for this run: `$NOTION_DATABASE_ID` (resolved from the career-data config; any `{{NOTION_DATABASE_ID}}` token in this skill is a literal placeholder, not a value).

---

**Step 0a — Read the schema reference (via the database adapter).** This is a database operation. **Load `${CLAUDE_PLUGIN_ROOT}/skills/database-notion/SKILL.md`** — the Notion adapter, mandatory whenever `database_backend` is `notion` (the default) — and follow its **§1 Schema read**: fetch the schema, extract the SQLite `CREATE TABLE` block as the run's authoritative schema reference (property names + valid select-option values), keep it in context (intake writes from it in Step 0.9a, validating every Select/multi-select value against the live option list), and pass it to the career coach as a "Notion schema reference" section so the coach RETURNS select values that match the live options. If the schema fetch fails, stop and report. (If `database_backend` is ever not `notion`, load that backend's adapter instead — the operation is the same.)

---

**Step 0b — Fetch the Hold queue (via the database adapter).** Target status: `Hold`. Following `skills/database-notion/SKILL.md` (loaded in Step 0a) → **§2 Read ladder**, query the queue for `Status = Hold` (A1 → A2 → B; falling down the ladder is sanctioned routing, never a reportable failure). **Both intake modes use the same ladder.** On Path B: if `$NOTION_HOLD_VIEW_URL` is non-empty, use it directly as the view URL (skips the DB discovery fetch); otherwise the adapter resolves the "Hold" view via **§3 view discovery**. The rendered view is **discovery-only** → per-page `notion-fetch`; **every downstream read in this run** — Step 0.6 priorities, the Step 0.8 coach-complete check, the Step 0.9a write-only-to-empty rule — uses those per-page property sets, never a rendered table. If every rung fails, stop and report — never treat it as zero results, and never improvise `notion-search` to enumerate the queue (R-39). The adapter also carries the all-paths rules (no view creation, no Bash/Grep on A2/B results, target-status filtering).

Skip any entry where neither a Job URL nor job description details in the RTF body of the record are populated.

**If Position is empty:** do not skip. Instead, attempt to infer the position title from the Notion page title (the `Name` property):
- If the page title clearly contains a role signal (words like "Head", "VP", "Director", "Manager", "Lead", "PMM", "Marketing", "Engineer", "Designer", "Product", "Content", "Technical", or a similar job-title word), use it as the Position value for this run and flag the role in the Step 0.9b briefing: "Position inferred from page title — update the Position field in Notion to confirm."
- If the page title looks like a company name only (identical to the Company field, or contains only a company name with no role title signal), process the role with Position = "(unknown)" and flag it in Step 0.9b: "Position field is empty and could not be inferred from the page title — update in Notion."

**Data quality skip condition:** Skip any entry where Company is empty, "Unknown", or appears to contain a job title embedded in the company name field (e.g., "VP Marketing @ Company") AND Position is also empty AND the page title provides no usable signal — flag these in the Step 0.9b briefing as data quality issues requiring correction before they can be processed.

**Hold roles are processed fresh each intake run** — JD fetched (or read from JD Body if already populated), coach spawned unless already coach-complete. Hold roles that are already coach-complete are likely holdovers from a prior intake run where Status writeback to Researched failed — the pipeline completes their Status update in Step 0.9d.

For each matching entry, capture the full row payload including:
- Page ID
- Company name
- Position title (use inferred value if Position field is empty, per the rules above)
- Job URL
- Every other property set on the row (notes, tags, source, and any existing priority value) — pass these through verbatim; do not interpret them yet

Report the count to the user: "Found N roles in Hold status." If the count is 0, stop and report that. If the query call returns a tool error or an unparseable response rather than a result array, stop and report the error to the user — do not treat it as zero results. Do not wait for a response — proceed immediately to the next step.

## Step 0.4 — Establish `$PIPE` (Notion-fetch mode only)

**Skip this step in Inline mode** — a single ad hoc role processed conversationally has no batch-size pressure; pass its JD content directly to the coach as before, no `$PIPE` apparatus needed.

**Notion-fetch mode:** before Step 0.5 writes anything, create the run's own scratch directory for intermediate artifacts — `$PIPE/queue.md` (Step 0.5), `$PIPE/coach-output.md` (Step 0.8), gatekeeper violation files (Step 0.8.5), and `$PIPE/writeback-status.md` (Step 0.9a). Unlike the New Application pipeline, where `$PIPE` is one directory per role/company (`<output_dir>/<company_dir>/_pipeline/`), intake processes a **batch** of up to 5 roles in a single run, so `$PIPE` here is run-scoped, not per-company:

- Resolve `output_folder` from `${CAREER_DATA}/references/pipeline-preferences.json` (same resolution order as every other config key, R-37) — this is the required key every pipeline already depends on, even though intake itself writes no deliverables there. **Stop only if missing or empty:** "Your career-data config has no `output_folder`. Run `/career-engine:setup --phase 5`." (The orchestrator's preflight already guards this for orchestrator-driven runs; this guard exists for standalone intake invocations, which bypass that preflight per Step −0.5.)
- Set `$PIPE` = `<output_folder>/_intake_pipeline/<run-timestamp>/` (e.g. `_intake_pipeline/20260630_151047/`) — timestamped so a concurrent or immediately-prior run never collides.
- On Path A use `mkdir -p`; on Path B create it through the host file tool (R-30).

`_intake_pipeline/` is intermediate only — like New Application's `_pipeline/`, it is never a deliverable and is never written to Notion. Proceed immediately to Step 0.5.

## Step 0.5 — Prepare JD content for the coach

Before passing roles to the coach, check each role's Notion row for existing JD content and normalise it inline.

**Always attempt the URL.** For every role that has a Job URL, fetch it — regardless of whether `JD Body` is already populated. The live posting may contain updated requirements, application instructions, salary information, recruiter name, or other signals not present in a manually copied JD Body. If the fetch succeeds, pass both the fetched content and the existing JD Body to the coach; the coach uses whichever is more complete or resolves any differences.

For each role:

1. **Job URL is present** — attempt `WebFetch` on the URL.
   - **Fetch succeeds with usable JD content:** mark `url-fetched`. Pass fetched content to the coach alongside any existing `JD Body`. "Usable JD content" means the returned page actually contains the job description — at minimum the role title plus requirements or responsibilities text. A page that returns without that (a JavaScript-rendered shell, a cookie/consent wall, a redirect stub, or navigation chrome only) is **not** a successful fetch — treat it exactly like a fetch failure and continue below.
   - **Fetch fails on a LinkedIn URL (`linkedin.com` in the URL):** LinkedIn blocks plain `WebFetch` with an auth wall. Do not mark as unfetchable yet — use the LinkedIn MCP as a fallback:
     1. Extract the numeric job ID from the URL. LinkedIn job URLs follow the pattern `linkedin.com/jobs/view/JOBID` — extract the trailing number.
     2. Call `mcp__linkedin-mcp__get_job_details` with that job ID.
     3. If the tool returns job description content, mark `url-fetched-via-linkedin-mcp`.
     4. If the LinkedIn MCP tool is unavailable, errors, or returns only metadata (applicant stats, seniority breakdown) with no description text, continue to the universal fallback ladder below — its first rung (rendering-capable extraction) is confirmed to work on LinkedIn auth walls, and the LinkedIn keyword search follows at rung 2.
   - **Fetch fails on an Indeed URL (`indeed.com` in the URL):** Indeed's authentication wall blocks plain `WebFetch` for all Indeed job postings. Do not mark as unfetchable yet — use the Indeed connector as a fallback. Do NOT attempt to extract or pass a `jk` job key from the URL — `jk` values from email-tracking redirect URLs are not valid API job IDs and will error. Go directly to keyword search:
     1. Call the Indeed connector's `search_jobs` tool with `keyword` = "[Position title] [Company name]" (use the values captured from the Notion row).
     2. Scan the results for a title + company match. If a matching result is found, use its job description content — mark `url-fetched-via-connector`.
     3. If the Indeed connector is unavailable, errors, or returns no title + company match, continue to the universal fallback ladder below.
   - **Universal fallback ladder — mandatory for every failed fetch, regardless of URL domain.** This applies to company career pages, JavaScript-rendered sites, unknown job boards, and LinkedIn/Indeed roles whose domain-specific fallback above also failed. Most postings are mirrored somewhere fetchable — a role must never be marked `needs-manual` until every rung below has been attempted. Stop at the first rung that returns usable JD text:
     1. **Rendering-capable extraction on the original URL.** Plain `WebFetch` is the weakest fetcher in any session. Before searching for mirrors, check the session for stronger extraction tools with `ToolSearch` (search keywords: `extract`, `crawl`, `scrape`, `fetch`, `browser`). Server-side extractors — e.g. a Tavily extract tool called with `extract_depth: "advanced"`, or an Exa fetch tool — render and parse pages that defeat `WebFetch`, including JavaScript-rendered career pages and LinkedIn auth-walled postings (both confirmed in live runs). Call the strongest available extractor on the original Job URL. If usable JD text returns, mark `url-fetched-via-extraction` and stop. A JavaScript shell or auth wall is a signal to switch fetcher, not a dead end. If `ToolSearch` surfaces no stronger or rendering-capable extractor than plain `WebFetch` (none available this session), skip to rung 2 — do not stop here.
     2. **LinkedIn MCP search** — call `mcp__linkedin-mcp__search_jobs` with `keyword` = "[Position title] [Company name]". Scan results for a company + title match; on a match, call `mcp__linkedin-mcp__get_job_details` with that result's job ID. If description content comes back, mark `url-fetched-via-linkedin-mcp` and record the LinkedIn URL alongside the original.
     3. **Company careers page** — `WebSearch` for `<company name> careers <role title>`, then fetch the most promising hit on the company's own domain.
     4. **Job board and ATS mirrors** — `WebSearch` for `"<role title>" "<company name>" site:greenhouse.io OR site:lever.co OR site:comeet.com OR site:workable.com OR site:ashbyhq.com OR site:glassdoor.com`. The `site:` list is a starting point, not a boundary — postings are also mirrored on investor career boards (the company's lead VC often lists portfolio jobs, e.g. team8.vc), BuiltIn city boards, and regional aggregators. Run one additional open search (`"<role title>" "<company name>"`) and try any mirror that surfaces. Fetch up to 3 matching results.
     5. **Exact title + company search** — `WebSearch` for `"<role title>" "<company name>" job description` to catch aggregator mirrors and public posting previews.
     - **Fetcher rule (all rungs):** fetch candidate URLs with the strongest extractor found in rung 1, not plain `WebFetch`. A mirror that returns a JavaScript shell to `WebFetch` will usually yield its full content to a rendering-capable extractor.
     - **Match guard (all rungs):** accepted content must match both the company and the position title on the Notion row. Never substitute a similar-but-different posting (different seniority, different location, or a different open role at the same company). Log near-misses in the revision log and keep going.
     - Any rung that succeeds via search: mark `url-fetched-via-search` (unless a more specific marker above applies), record the alternate source URL in the run-level revision log, and pass the content to the coach noting that the source URL differs from the saved Job URL.
   - **Every rung failed:** log the failure, listing which fallbacks were attempted (direct fetch, domain connector, rendering-capable extraction, LinkedIn MCP search, careers page, board mirrors, exact-title search). If `JD Body` is populated, mark `content-exists` and proceed on that. If `JD Body` is also empty, mark `needs-manual` and log to the run-level revision log — do not drop the role yet, flag it for the user to resolve. A `needs-manual` flag whose log entry does not list the attempted fallbacks is invalid — the Step 0.9b briefing must show that the full ladder was exhausted.

2. **No Job URL — `JD Body` property is populated** — mark `content-exists`. Pass it to the coach as-is.

3. **No Job URL and no JD content anywhere** — mark `needs-fetch`. Log to the run-level revision log. Drop from this run.

**Cross-version capture for location and First Advertised.** The fallback ladder above stops at the first rung that returns usable JD *content*, but `First Advertised` and location compatibility cannot be set reliably from a single version of a posting (a board's location field is often a forced artifact, and its posting date resets on every re-post). So: whenever the ladder surfaces a second version of the same role — a board mirror, an ATS/careers listing, a LinkedIn posting — capture that version's **location field (verbatim)** and its **posting/"posted X ago" date** even after you already have usable content, and pass every captured version's URL, location field, and date to the coach alongside the JD. Do not fetch full mirrors solely for this where the ladder already succeeded on rung 1 — but record any version that does come into view during the search. The coach corroborates across these versions per `skills/career-coach/coach-research.md` → Location & eligibility deep-scan and → `Date first advertised`.

**Notion-fetch mode: write the full row payload to `$PIPE/queue.md` as each role's JD prep completes — do not hold it in memory for inline passing (R-41).** A queue of even 5 roles, each carrying full JD text plus captured alternate versions, is large enough to bloat the spawn prompt and the orchestrator's own context if held inline; it must live on disk. `$PIPE` was created in Step 0.4. Append one section per role, in this format:

````markdown
---
## ROLE — <Company> — <Position>

**Page ID:** <page_id>
**Job URL:** <url, or "none">
**Fetch marker:** <content-exists / url-fetched / url-fetched-via-linkedin-mcp / url-fetched-via-connector / url-fetched-via-extraction / url-fetched-via-search / needs-manual>
**Existing Notion properties:** <every other property captured in Step 0 — notes, tags, source, existing priority value — verbatim>

### JD content
<the full JD text — fetched content, existing JD Body, or both if both exist>

### Alternate versions captured (location/date corroboration)
<for each captured alternate version: source URL, location field verbatim, posting/"posted X ago" date — omit this subsection if none were captured>
````

On Path A use the `Write` tool (first role) then `Edit`/append for subsequent roles; on Path B use Desktop Commander `write_file` / append, same R-30 pattern as other `$PIPE/` writes. Once a role's section is written, drop its JD text from working memory — the file is now the record. Proceed immediately to Step 0.6 once every role in the queue has been written.

**Inline mode:** no `$PIPE`, no `queue.md` — there is exactly one role and no batch-size pressure, so the JD content prepared above passes directly to the coach in the spawn prompt as it always has.

## Step 0.6 — Check existing priorities

For every role that passed Step 0.5, read the `Priority` property from the Notion row data collected in Step 0. This is the coach's scoring of each role — it is the sole queue ordering signal. Flag each role as either:
- `scored` — `Priority` is set to a value
- `unscored` — `Priority` is empty or null

Record the counts. Proceed immediately to Step 0.7.

## Step 0.7 — Build the processing queue

**Hard cap: 5 roles reach Step 0.8, never more.** This is not a soft preference — a 25-role batch reaching the coach in one spawn has caused a real production failure: the coach hit the model's hard output-token ceiling mid-generation and crashed, the run never recovered, and hours of completed analysis for the other roles was stranded without ever reaching Notion. Apply the cap here, before Step 0.8, with no exceptions.

**If there are 5 or fewer roles:** process all of them. The cap is not reached, so priority ordering is irrelevant — skip queue selection and proceed immediately to Step 0.8 with all roles.

**If there are more than 5 roles:** select the top 5 using the priority order below. All others are deferred — they remain in Hold and are picked up by the next intake run. Never widen the batch to "save a trip" or because the user said "run intake" without a number — 5 is the ceiling regardless of how many Hold roles exist or how the run was triggered.

**Queue selection order (Hold roles):** Unscored roles take priority. The intake pipeline's purpose is to coach and score fresh Hold roles. Already-scored roles have been through intake before and are in Hold only because their Status writeback to Researched failed — they fill any remaining slots and receive a Status cleanup in Step 0.9d.

1. `unscored` roles — up to 5 slots. If there are more unscored roles than available slots, choose randomly among them.
2. Remaining slots (if any) — filled with `scored` coach-complete roles ordered `1` → `2` → `3` → `4` → `5` → `6`. Ties at the same Priority level are broken randomly.

**Open Application hard floor:** Any role identifiable as an open application, unsolicited application, or speculative application where no specific listing is posted must always slot at `6` (Fifth) in the queue, regardless of any Priority value already set. If the coach has not yet run and a pre-set priority above `6` is found on such a role, treat it as `6` for queue ordering. The coach will correct the Notion value in Step 0.8.

All roles not selected are deferred. Proceed immediately to Step 0.8.

## Step 0.8 — Career coach

**Pre-coach filter — run before any coach-complete check:** Remove any role marked `needs-manual` from the coach queue. A role with no usable JD content cannot be meaningfully analysed by the coach. Log the removal in the revision log: "[Company] — [Position]: removed from coach queue, JD content unavailable (needs-manual). Resolve manually then re-run intake." Do not send a `needs-manual` role to the coach under any circumstances. A `needs-manual` role is removed from the **processing queue entirely** — it is excluded from all of Step 0.9, including the 0.9d Status writeback. Its Status stays unchanged so it reappears in the next intake run once the JD is resolved.

The career coach runs for every role that is not already coach-complete. If all roles in the queue are coach-complete, the coach spawn is skipped entirely and the pipeline proceeds directly to Step 0.9 using existing values.

Before spawning, check each remaining role in the queue: a role is `coach-complete` only if all required fields are populated. The required count depends on `gap_handling_mode`:
- **When `gap_handling_mode = enabled` (default):** all nine fields must be populated — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Culture`, and `Landscape`.
- **When `gap_handling_mode = disabled`:** eight fields — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Culture`, and `Landscape`. `Gap handling` is NOT required and must NOT block coach-complete status.

Partial population (any required field missing) is not coach-complete and the role must be sent to the coach. `Landscape` and `Culture` are always required — the coach must populate both for every role, even if only to confirm no intelligence was found.

- **All roles are `coach-complete`:** skip the coach spawn entirely. Proceed directly to Step 0.9 using existing values.
- **Any role has one or more fields missing:** spawn the coach with every role that is not fully complete. Carry existing values forward for coach-complete roles only.
- **No roles are `coach-complete`:** spawn the coach with all 5 roles as normal.

**Defensive re-check before spawning — count the roles about to be sent.** If more than 5 roles are queued for the coach at this point, Step 0.7's cap was not applied upstream (or roles were added after it ran). Do not spawn an oversized batch to "keep moving" — stop, re-apply the Step 0.7 selection to bring the queue down to 5, log the correction, and only then spawn.

Spawn `career-coach` with the applicable roles. Pass:
- **`$PIPE/queue.md`** — the file path only, not the content (R-41). The coach reads its own role data from this file (written in Step 0.5) — full JD text, fetched content, and captured alternate versions for every queued role. Do not paste any of that content into the spawn prompt; passing it inline defeats the purpose of writing the file and is the exact pattern that bloated past runs. **Exclude the `JD proof` property value entirely from what's in `queue.md`** — even if populated, the coach must derive a fresh verbatim quote from the JD text. Passing the existing `JD proof` value would undermine the anti-fabrication guardrail.
- `$NOTION_DATABASE_ID` (resolved from career-data config) — for reference only; **intake** performs all Notion writes in Step 0.9a, the coach does not write
- `${CAREER_DATA}` (the resolved career-data root) — the coach needs this to read references
- `$PIPE` (the pipeline directory for this run) — the coach writes its full analysis to `$PIPE/coach-output.md` (R-41), **writing incrementally — appending each role's section as soon as that role's analysis is complete, rather than composing the full multi-role output in memory and writing it once at the end.** A single large generation covering 5 roles of deep research (Landscape, outreach map, WIWTR questions, etc.) risks the model's output-token ceiling; incremental per-role writes avoid that and leave a usable partial file if the run is interrupted. The coach returns a 1-line status when done; intake reads the file in Step 0.9a.
- The SQLite schema reference from Step 0a (as a "Notion schema reference" section) — the coach uses it to RETURN Select / multi-select values that exactly match the live option list (intake writes them; every returned value must be an existing option)

After the coach returns its 1-line status, read `$PIPE/coach-output.md` **once** to obtain the full analysis. The file persists through context compression; inline returns bloat context O(roles), and re-reading the same file in repeated chunked passes bloats it just as badly — read it in a single pass and hold the parsed result, not the file. The analysis contains — **intake writes ALL of these in Step 0.9a; the coach does not write Notion:**
- Priority scores for all roles (Part 0 of the coach's output) — always
- Batch analysis and per-role writing guidance (Part 1)
- **Every strategic Notion property (Part 2), each as a named value:** `Priority`, `Priority Reason`, `Role emphasis`, `Role summary`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Culture`, `Landscape`, `Company Stage`, `JD proof`, `JD Body` / `JD Fetch Status` (when fetched), the location-compatibility result (when configured), the job's `Location` (the role's stated location, when the DB has a `Location` property), `First Advertised` / `Date first advertised`, and the research-derived properties (`Hiring Manager's Name`, `Recent news`, `Funding context`, etc.)
- The **`Why I Want This Role` coach context block** (intake prepends it in Step 0.9a)
- The **outreach map** (intake writes it to the page body in Step 0.9e)
- Patterns and notes for the user (Part 3)

Proceed immediately to Step 0.8.5.

## Step 0.8.5 — Coach output check (fabrication + field-fit)

Spawn `gatekeeper` with `option=coach-output`. This gate runs BOTH the fabrication check (traceability) and the **field-fit/format checks** (wrong-field content, length caps, disabled-feature leak) — the latter catch the recurring coach defects the fabrication check structurally cannot. Pass:
- **`$PIPE/coach-output.md`** — the gatekeeper reads the full coach analysis from this file. All fields (`Role emphasis`, `Role summary`, `Culture`, `Keywords`, `Landscape`, `Strategy`, `Gap handling`, the `Why I Want This Role` coach context block, and the outreach map) are in this file.
- **`OUTPUT_PATH=$PIPE/gatekeeper-coach-output-<round>.md`** (round starts at 1, increments each pass) — per the gatekeeper's own R-41 protocol, it writes the complete violation list here and returns only `FAIL: <n> violations → <OUTPUT_PATH>` (or `PASS`).
- **Whether gap handling is disabled this run** (`gap_handling_mode`), so the gatekeeper can run the gap-leak check.
- `CAREER_DATA=${CAREER_DATA}` — so the gatekeeper reads `01/02/03` from career-data for the fabrication check (rather than relying on its self-locate fallback).
- `01-writing-rules.md` is already in memory — confirm it is loaded before spawning.

**If PASS:** proceed to Step 0.9.

**If FAIL:** re-spawn the coach, passing **`OUTPUT_PATH`** (the violation-list file path the gatekeeper just returned) for it to read — never copy the violation text into the coach's spawn prompt yourself. Instruct it: "Read the violations at `<OUTPUT_PATH>`. Fix each item. For unverifiable claims: remove or correct them; do not substitute alternative fabrications. For field/format violations: move the content to the correct field, cut to the cap, or remove the leaked gap framing as stated. Revise only the affected properties and roles named in the file — append your fix directly to `$PIPE/coach-output.md` in place." Increment the round counter for the next gatekeeper pass.

> **⛔ Named anti-pattern: hand-editing `coach-output.md` instead of re-spawning the coach.** A real production run hit a FAIL on pass 1 (36 violations across 25 roles — itself downstream of the Step 0.7 cap not being applied), and instead of re-spawning the coach as instructed above, the orchestrator edited `coach-output.md` directly — 77 raw `Edit` calls across 5 more FAIL/fix rounds, with reasoning recorded in that session as: *"The violations are well-specified and mostly mechanical. I'll fix them directly in the merged file rather than re-running the coach — faster and the gatekeeper was clear about exactly what to change."* This is the same rationalization pattern CLAUDE.md names for `career-data` direct writes (the "June-18 direct-write rationalization" — "faster/safer to do it myself" bypassing the designated owner) — applied here to a `$PIPE` file instead of career-data, but the same failure mode. `coach-output.md` is the coach's content; **only the coach edits it.** The gatekeeper's job is to find violations and name them precisely enough that the coach can fix them — not to hand the orchestrator a punch list to apply itself. If gatekeeper output looks "mechanical enough to just fix directly," that is not authorization to skip the coach — re-spawn it with the violations as instructed, every time, with no exception for how small or obvious the fix looks.

**Cap: 2 revision passes.** If still failing after pass 2: strip unverifiable claims (replace with `[UNVERIFIABLE — removed]`), and for unresolved field/format violations apply the stated fix mechanically (move or trim the content; clear a leaked transfer-note gap inventory). Log everything removed or moved in the run-level revision log under `## Coach Output Check — Unresolved`, flag for the user in final delivery, and proceed to Step 0.9. **This mechanical fallback is the only sanctioned exception to "only the coach edits `coach-output.md`"** — it fires solely after the cap is reached, is scoped to exactly the items the gatekeeper named, and is logged. It is not a license to hand-edit pre-emptively on pass 1 or 2.

## Step 0.9 — Writeback and briefing

This step is mechanical and runs end-to-end without pausing.

### 0.9a — Write coach outputs to Notion (intake is the SOLE writer)

**Intake is the single authoritative writer of every coach-produced property.** The career coach WRITES its analysis to `$PIPE/coach-output.md` (R-41) and does NOT write Notion itself (it has no write tool). Intake reads the coach's analysis from `$PIPE/coach-output.md` (Step 0.8) and writes everything below to Notion — a property the coach produced reaches Notion only here. **This step always runs after the coach** (and after Step 0.8.5); it is never skipped on the assumption the coach already wrote. This is the fix for the past failure where `Role summary` and `Priority Reason` were silently dropped in the gap between two writers.

**Process and confirm one role completely before moving to the next role.** Do not write every role's properties first and only confirm the whole batch at the end — a session interruption between the write phase and the confirmation phase has previously stranded a fully-completed, gatekeeper-passed coach analysis on disk with nothing written to Notion at all (24 of 25 roles lost in one real run). Run this role's writes, run this role's confirmation pass (below), then move to the next role. This makes the run resumable by construction: if interrupted, every role already processed is fully written and confirmed in Notion, the role in progress is whatever the next `notion-fetch` shows (re-confirm it on the next intake run rather than assuming partial writes landed), and every role not yet reached is untouched and still on Hold — exactly the state the next intake run already expects (Step 0b re-fetches Hold roles; a role whose Status write to Researched never landed surfaces again per Step 0.9d). Property writes for a single role may still go out in parallel (per the per-property batching rule below) — the sequencing requirement is role-to-role, not property-to-property within a role.

**Maintain `$PIPE/writeback-status.md` as the run's own progress ledger — do not rely on re-fetching Notion pages to reconstruct what was already written.** Before the first role's writes, write one line per queued role: `- [ ] <Company> — <Position>`. The instant a role's writes and confirmation pass both complete, flip its line to `- [x] <Company> — <Position>` (append-in-place edit, not a rewrite of the whole file). This is cheap — a few bytes per role — and it is the recovery mechanism: if this run is interrupted (compaction, crash, connection drop), the ledger on disk is the authoritative record of exactly which roles are done, with no need to re-fetch Notion pages to infer state by inspection. If this step resumes mid-run (the ledger already exists with some lines checked), skip every checked role and continue from the first unchecked one — do not redo completed roles and do not skip unchecked ones on the assumption they were "probably fine."

**Rule: write only to empty properties** (the two always-writes — `JD proof` and the `Why I Want This Role` coach context block — are the named exceptions below). For every other property, check the current Notion value first. If already populated — skip it. Do not overwrite any existing value. `N/A` counts as populated.

**Write to the EXISTING property of that exact name — never create a property or a numbered variant** (the "Strategy 1" bug came from an agent that couldn't write `Strategy` cleanly and made a duplicate). If a property is missing or rejects the write, report it in the briefing — do not invent a field. **Write to properties only, never to the page body** (the sole sanctioned body write is the outreach map in Step 0.9e).

**Most-skipped, treat as mandatory:** the **location-compatibility property** and **`First Advertised`** are the two writes agents most often drop. When the coach produced a value (including a `[LOW]`/range/`Unknown`), these MUST be written — do not finish a role with either left empty. Same for `Role emphasis` (with its Mandate + Likely KPIs lines) and `Landscape` (sectioned format). **The location-compatibility MUST-write obligation applies only when the property name is configured** (`location_compatibility.database_property`, legacy `notion_property`, is present in `pipeline-preferences.json`) — when it is not configured, skip the write entirely, exactly as the per-property rule below states. The two are not in conflict: "mandatory" means "do not drop it when configured," not "write it even when unconfigured."

Write through the database adapter (`skills/database-notion/SKILL.md` → §4 Writeback): where Path A1 (the `ntn` CLI) is active this run, property writes may go through `ntn api /v1/pages/<page_id> -X PATCH` (same write-only-to-empty rule, same parallelism); otherwise use `notion-update-page`. The property list and write-if-empty rules below are intake's contract; the adapter provides the mechanism (including the never-create-a-property guard). **Validate every Select / multi-select value against the live schema option list from Step 0a before writing** — a value that is not an existing option is reported in the briefing, never sent as a write (an invalid select value errors the call and, in a batch, silently drops the other properties — that was a cause of the past data loss). **Write per property (or in small validated batches) so one rejected property can never drop the others.**

For each role in the processing queue, apply this rule to:
- `Priority` — **Select field** (not a number field; values are the strings `"1"` through `"6"`). Validate the coach's returned value against the live schema option list before writing. Write only if currently empty. If the role was coach-skipped (already coach-complete per Step 0.8), do not write at all — leave unchanged. In a mixed batch, apply per role individually.
- `Priority Reason` — write the coach's one-sentence reason if currently empty. Written for every role the coach touches (both triage-exit roles and full-research roles).
- Location compatibility property (name resolved from `location_compatibility.database_property`, legacy `notion_property`, in `pipeline-preferences.json`) — write if empty and if the property name is configured. Skip entirely if not configured.
- `Location` (the job's stated location, e.g. "Tel Aviv, Israel / Hybrid") — write if empty, **only if a `Location` property exists in the Step 0a schema** (validate the name against the schema). Skip entirely and note in the briefing if no such property exists. This is the literal job location — **distinct from the location-compatibility property above** (the verdict).
- `Role emphasis`, `Keywords`, `Strategy`, `Relationship type`, `Role summary`, `Person who Advertised Role (if not Hiring Manager)` — write if empty. (Triage-exit roles skip these — only full-research roles write them.)
- `JD proof` — **always overwrite**, even if already populated. The coach's fresh verbatim quote from the current JD text supersedes any prior value (anti-fabrication guardrail). (Full-research roles only.)
- `Hiring manager's role`, `Manager role confirmed`, `No incumbents in this function` — write if empty. (Full-research roles only.)
- `First Advertised` — write if empty. **Use the coach's corroborated `Date first advertised` value, not a single page scan.** This is a Date property, so it always holds a clean `YYYY-MM-DD` and never appended text. A posting date from one site is low-confidence: boards reset the displayed date on re-post and syndication, so the same role shows different ages on different sites. Always write the **earliest** corroborated date seen across sources (re-posts only ever move the date later), formatted `YYYY-MM-DD`. When the coach marked it `[HIGH]` (primary source, or ≥2 independent sources agree), write it as the confident value. When the coach's value is `[LOW]` (one source only, or sources disagree), still write the earliest date as the best estimate, but carry the uncertainty in the Step 0.9b briefing — list it as "First Advertised: <date> — unconfirmed, earliest of N sources / sources disagreed." If no date was findable on any source, leave the property empty and note "First Advertised: unknown" in the briefing. Never guess or approximate a date from one page.
- `JD Body` — write if empty AND the role was marked with any `url-fetched*` marker in Step 0.5 — `url-fetched`, `url-fetched-via-linkedin-mcp`, `url-fetched-via-connector`, `url-fetched-via-extraction`, or `url-fetched-via-search` (i.e., a live fetch succeeded on the original URL or via any fallback rung and returned usable JD content). Copy the fetched JD text verbatim into this property. Do NOT overwrite an existing `JD Body` value. Do NOT write if the role was marked `content-exists` (already has JD Body) or `needs-manual` (no usable JD available). Purpose: persisting the fetched JD avoids re-fetching on every subsequent edit run; if the job listing expires, the edit pipeline has the content it needs without re-fetching.
- `JD Fetch Status` — write the coach's returned value (e.g. `Fetched`, `Unfetchable`) if empty. Validate against the schema option list (Step 0a).
- `Gap handling` — write if empty. If gap_handling_mode = disabled, skip entirely.
- `Why I Want This Role` — **two writes, in order:**

  **Write A — coach context block (always-write):** the block (Screen 1/2/3 + optional transfer note) that the coach **returned** in its output. **Intake prepends it** to the field above any existing content (existing content is the normal case and is never a reason to skip — this is an always-write, not write-only-to-empty), keeping `---` as the separator: the block on top, then `---`, then the existing content verbatim (or just the block if the field was empty). If the coach returned no block for a full-research role, report it by name in the briefing.

  **Write B — coaching prompts (write-only-to-empty):** the `wiwtr_questions` block the coach returned. Check the **pre-write WIWTR value** from the `notion-fetch` in Step 0b (before this run's writes). If that value was **empty** (the field had no content before intake ran): after writing the coach context block (Write A), also append a second `---` separator and the coaching prompts block. If the pre-write value had **any content** (user notes, a prior coach context block, prior coaching prompts, anything at all): do NOT write the prompts. Existing content of any kind means the user has either written their own motivation or coaching prompts were already added on a prior run — both cases are preserved as-is. Do not write coaching prompts for triage-exit roles (Priority 5–6) — the coach returns none for them.

  Format of the prompts block as appended:
  ```
  [COACH PROMPTS — write your answers below each question, then delete this header and the questions]

  [coaching questions from the coach's wiwtr_questions return, one per line with a blank line between them]

  ---
  ```
- `Company Stage` — write if empty. Exact option values: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`, `Stealth`, or `N/A`.
- `Role Type` — write if empty. Multi-select exact values: `Builder`, `Scaler`, `Specialist`, `Leader`, or `N/A`.
- `Culture` — write if empty. Skip entirely if already has content.
- `Landscape` — if empty, write the full section-format content. If already populated, prepend the new content above the existing content separated by a `---` divider (per the career-coach output format).

**Confirmation pass — run immediately after this role's writes, before moving to the next role (this closes the past silent-drop; see the per-role sequencing rule above).** Re-read this role's properties (one `notion-fetch`). For every MANDATORY property that the coach produced a value for — `Role emphasis`, `Role summary`, `Priority`, `Priority Reason`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Culture`, `Landscape`, `Gap handling` (unless `gap_handling_mode = disabled`), the location-compatibility property (only when configured), `Location` (only when the DB has a `Location` property), `First Advertised` (only when the coach produced a value), and the `Why I Want This Role` coach context block — that is **still empty** after the write, attempt the write once more from the coach's returned output. The `wiwtr_questions` coaching prompts are write-only-to-empty and are not retried if skipped (the pre-write content took precedence). If it is still empty afterward (or the coach genuinely produced no value), name the property and role in the 0.9b briefing under **"⚠ Unwritten mandatory fields"**. **No mandatory property may end the run silently empty** — every miss is either written on retry or surfaced by name. (Triage-exit roles are confirmed only on their reduced set: `Priority`, `Priority Reason`, `JD Fetch Status`, `Role Type`, `Relationship type`, and location when configured.)

Confirm in chat: "Writeback complete: K roles updated, M properties skipped (already populated), N flagged unwritten (see briefing)."

### 0.9b — Brief the user

Report to the user:
- Queue list: company, title, priority source (existing / generated), and coach's reason for each.
- Batch analysis and base CV recommendation from the coach.
- Per-role Strategy and focus recommendations from the coach.
- Patterns and notes from the coach.

This is the one moment the user sees the coach's reasoning before per-role processing begins. Do not wait for a response — proceed immediately to Step 0.9d.

### 0.9d — Status writeback

For every role in the processing queue, write `Status = Researched` **through the database adapter** (`skills/database-notion/SKILL.md` → §4 Writeback): where Path A1 (the `ntn` CLI) is active this run the write may go through `ntn api /v1/pages/<page_id> -X PATCH`; otherwise use `notion-update-page`. Run all writes in parallel. **Never write Researched to a `needs-manual` role** — it was removed from the processing queue in Step 0.8 and must keep its current Status so it surfaces again after the JD is resolved.

**Per-role failure path:** a Status write may fail for one role while others succeed. Do not let one failure abort the batch or silently drop the role. Collect any per-role write failures, continue writing the remaining roles, and report the failures in the chat confirmation (a failed role keeps its current Status and surfaces again on the next intake run, completing per Step 0).

After all writes complete, confirm in chat: "Status updated to Researched for N roles." If any writes failed, append: "M roles could not be updated: [Company — Position, …] — Status unchanged; they will be retried on the next intake run."

### 0.9e — Outreach map (runs in main intake context)

**This step always runs for full-research roles — the LinkedIn MCP is not a gate.** This was the bug: the outreach map was being skipped whenever the LinkedIn MCP was absent, so networking insights never reached Notion. The coach produces an outreach map either way (research dimension 12): with the LinkedIn MCP, contacts carry verified degree/reachability; **without it, the coach builds the same map from web OSINT** (HM via the non-LinkedIn ladder, one advocate from the company Team/About page or a Google search), every row tagged `[LOW]` with the action "Find on LinkedIn and connect." **Write whichever map the coach produced.** Only genuinely skip a role when it is a triage exit (Priority 5–6) or was flagged `ROLE MAY BE CLOSED` — never skip solely because the MCP is absent. If the LinkedIn MCP is connected, attempt `search_people` and use the verified path; otherwise proceed with the web-OSINT map.

For each role in the processing queue that completed **full research** (Priority 1–4, not a triage exit), run the outreach contact research and write the result to the Notion page body.

**Follow the research procedure and output format defined in `skills/career-coach/coach-research.md` → Research Phase dimension 12 and `skills/career-coach/coach-output.md` → Outreach map format exactly.** Key rules repeated for clarity:

- Priority ladder: HM candidate first (already identified by the coach in dimension 10; use the value from `Hiring Manager's Name` if populated, otherwise search / web-OSINT) → one internal advocate → skip everything else.
- Maximum 3 rows in the table. Note angles only for actionable rows. Email / WhatsApp section always present.
- Confidence: `[HIGH]` named and confirmed; `[MEDIUM]` inferred from org/title; `[LOW]` hypothesis only.
- Skip roles where `ROLE MAY BE CLOSED` was flagged in Step 0.5 or 0.9b.

**Write to Notion page body** using `notion-update-page` on each role's page ID:
- Write the outreach map as the **first block** in the page body, using heading `## Outreach — <Company>` followed by the table, note angles, and Email / WhatsApp section.
- If the page already has content, prepend above it separated by a `---` divider. Never delete existing content.
- If no actionable contacts were found after the full search, write: `## Outreach — <Company>\n\nNo reachable contacts identified.`

Run all roles in parallel. After all writes complete, confirm in chat: "Outreach maps written for N roles." (If N is 0, it means every full-research role was a triage exit or flagged `ROLE MAY BE CLOSED` — never because the LinkedIn MCP was absent; without the MCP the maps are built from web OSINT and still written.)

Intake is complete.
