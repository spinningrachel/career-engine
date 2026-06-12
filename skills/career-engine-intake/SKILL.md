---
name: career-engine-intake
description: >
  Dual-mode intake pipeline for the career engine. In **standalone mode** (triggered
  directly via "run intake" or similar): processes Hold roles — fetches JDs, runs the
  employment coach for strategic properties and priority scoring,
  writes all results to Notion, updates Status to Researched.
  In **orchestrator mode** (called by career-engine-orchestrator): processes Interested
  roles — same steps, but Status is managed by the
  orchestrator, not this skill.
  Run standalone with: "run intake", "build the CV queue", "prep my Hold roles",
  "run the intake", or any variant asking to research Hold roles.
  Does NOT write CVs or cover letters.
---

# New Application — Queue Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill covers Steps 0 through 0.9 of the career-engine pipeline. All of these steps run before any per-role CV work begins. The goal of this pipeline is to give the employment coach complete information — full JD data for every role — before it makes any prioritization or writing decisions.

**Before any step:** Read `${CLAUDE_PLUGIN_ROOT}/references/01-writing-rules.md`. This file contains the fabrication rule and attribution constraints enforced at Step 0.8.5. It must be in context before the gatekeeper runs — even when this skill runs in standalone mode.

---

## Step −1 — Gap handling mode

Read `gap_handling` from `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json` (use the Read tool — this file ships inside the plugin, so it is present in every environment, including Cowork). Set `gap_handling_mode` as follows:

- `"gap_handling": "disabled"` → `gap_handling_mode = disabled`
- `"gap_handling": "enabled"` → `gap_handling_mode = enabled`
- File or key missing → fall back to reading `gap_handling` from `~/.claude/settings.json` (legacy location, reachable only in Claude Code on the user's own machine); apply the same mapping.
- Key missing in both locations, or any other value → `gap_handling_mode = enabled` (default). Never treat an unreadable legacy file as an error — the plugin file is the authority.

Do not ask {{USER_FIRST_NAME}} about this. The preference was set during setup (Phase 5). If she wants to change the default, she updates `references/pipeline-preferences.json` (or re-runs setup Phase 5). To suppress gap handling for a single run without changing the setting, she can add "no gap handling" to her prompt — check for that phrase in the current prompt and override to `disabled` if found.

**If `gap_handling_mode = disabled`:**
- Instruct the coach (in Step 0.8) to skip the `Gap handling` property entirely — do not populate it, do not write `N/A`.
- Skip the `Gap handling` writeback in Step 0.9a.
- The `coach-complete` check in Step 0.8 must NOT require `Gap handling` to be populated for this run.

**If `gap_handling_mode = enabled`:** proceed normally — gap handling is required for every role as documented.

---

## Step 0 — Fetch Notion schema and roles

**Guard — check configuration first.** Look at the database ID value immediately below. If it still contains the characters `{{` and `}}` (an unreplaced setup placeholder), **stop immediately** and tell the user:

> "The Notion database ID has not been configured. Run `/career-engine:setup` (or `/career-engine:setup --phase 5`) to complete the database integration before running the pipeline."

Do not attempt to search for the database. Do not proceed.

The database ID for this installation: `{{NOTION_DATABASE_ID}}`

---

**Step 0a — Fetch the database schema.** Run `notion-fetch` on the configured database ID:

```
notion-fetch id="{{NOTION_DATABASE_ID}}"
```

If the schema fetch fails (tool error, empty response) or the response contains no `CREATE TABLE` block, stop immediately and report the error to {{USER_FIRST_NAME}} — do not proceed without a schema reference and do not improvise one.

Extract the SQLite `CREATE TABLE` block from the response. This is your **schema reference** for the entire run — the authoritative list of property names and valid select option values. Keep it in context.

**Use the schema reference for every Notion write in this run.** When writing a select field, look up the valid options in the SQLite comment for that column (e.g., `-- one of ["Yes", "Remote-only", "No"]`) and write the exact string from the schema. Never hardcode select option values. If any agent returns a value that does not match a schema option, map it to the closest matching option using the schema as the authority.

**Pass the SQLite block to the employment coach** in its prompt as a "Notion schema reference" section so it can write select values that exactly match the live Notion options.

---

**Step 0b — Fetch roles using a direct Status filter.**

Target status by mode:
- **Standalone mode:** Status = `Hold`
- **Orchestrator mode:** Status = `Interested`

Two query paths exist, and Path A has two rungs. Use **Path A1** (the `ntn` CLI) whenever its gate check passes; fall to **Path A2** (the `notionApi` server) when A1 is unavailable; use **Path B** when both A rungs are absent or unusable (e.g. a Cowork session with no CLI in its sandbox and no `notionApi` server — only the standard Notion connector). Falling down the ladder is sanctioned routing, never a reportable failure. Both intake modes use the same paths.

**Path A1 — `ntn` CLI structured query (preferred where available).** The official Notion CLI returns the same structured JSON as the API, but through Bash — so the result is trimmed in the shell and only the fields the pipeline needs ever enter context. The gate, not the environment label, decides: any runtime whose shell passes the gate — including a sandboxed session where the CLI is installed and a token is configured — uses A1; where the gate fails, the ladder falls to A2 without comment. The gate never installs the CLI and never prompts for credentials mid-run. Keychain auth requires an interactive login session; in headless or sandboxed shells auth comes from the `NOTION_API_TOKEN` environment variable (or `NOTION_KEYRING=0` file-based auth) — if neither is present, `ntn whoami` fails, and that is the gate working as designed.

Gate check (both conditions must pass):
```bash
command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1 && echo "Path A1 available"
```

Resolve the data source ID once per run from the database ID, then query:

```bash
ntn api /v1/databases/{{NOTION_DATABASE_ID}}   # read data_sources[0].id from the response
ntn datasources query <data-source-id> \
  --filter '{"property":"Status","status":{"equals":"Hold"}}' \
  --limit 100 --json
```

(orchestrator mode: `Interested` instead of `Hold`.) Trim the JSON in the shell (`python3` or `jq`) down to each row's page `id` plus the named properties this step needs — always read by property name, never by column position. If `has_more` is true, continue with `--start-cursor` until exhausted. For a full single-row read, `ntn pages get <page_id>` returns every property plus the page body as markdown in one call.

Better still, project at the source so bulk payloads never arrive at all: repeat the httpie-style query param `filter_properties==<property_id>` on a direct query call —

```bash
ntn api /v1/data_sources/<data-source-id>/query 'filter_properties==title' 'filter_properties==<property_id>' \
  -X POST -d '{"filter": {...}, "page_size": 100}'
```

— which returns only the named properties (verified: ~3KB for a projected batch vs ~120KB unprojected). `filter_properties` takes property IDs read from the data source schema, not property names.

Syntax notes for direct API calls: `ntn api` is httpie-style — the path is given directly with no get/post verb words (`ntn api /v1/pages/<page_id>`; method is inferred, override with `-X PATCH -d '{...}'`); query params are `name==value` inline inputs. When unsure of syntax, verify instead of guessing: `ntn api ls` lists supported endpoints, `ntn api <path> --docs` prints the official endpoint docs, and `--spec` prints the request/response schema.

If any A1 call errors after the gate passed (auth revoked mid-run, network failure), fall to Path A2 for the remainder of the run.

**Path A2 — `notionApi` structured query.** `notionApi` returns structured JSON keyed by property name. There is no column alignment to get wrong, no table to parse, no off-by-one risk.

The `notionApi` tools are deferred and their schemas are not pre-loaded. Before calling, run a ToolSearch to load the schema:
```
ToolSearch query="select:notionApi__API-query-data-source"
```
If ToolSearch returns a schema, proceed with Path A2. If it returns nothing, try the full tool name `mcp__notionApi__API-query-data-source` directly — deferred tools are still callable by their full name even if ToolSearch doesn't surface them. If the direct call returns a tool-not-found error, the `notionApi` server is not connected in this session — switch to Path B. If the Path A2 call returns any other error (auth failure such as a 401, malformed response, timeout), treat the `notionApi` server as unusable in this session and switch to Path B as well. In neither case report this as a failure; Path B is a sanctioned route, not a workaround. If Path B then also fails, apply the all-paths-fail rule at the end of this step.

Call `notionApi` `API-query-data-source` (full tool name: `mcp__notionApi__API-query-data-source`) with:
- database ID: `{{NOTION_DATABASE_ID}}`
- filter: `{"property": "Status", "status": {"equals": "Hold"}}` (standalone) or `{"property": "Status", "status": {"equals": "Interested"}}` (orchestrator)
- page_size: 100

This returns a JSON array of page objects. Each object has an `id` field and a `properties` object with named fields — read property values by name, not by column position.

**Path B — view query for discovery, per-page fetch for properties (only when the `notionApi` server is absent or unusable).** The standard Notion connector's `notion-query-database-view` returns a *rendered table*, which is susceptible to column misalignment (the R-1 failure: 17 companies, 16 status tags) and shows only the view's visible columns — never enough for the full row payload the pipeline needs. In Path B the rendered table is therefore used **only to discover candidate pages**; property values are always read per page. The rule that survives from R-1: **a misaligned rendered table must never be parsed** — and in Path B no rendered table is ever parsed for property values, aligned or not.

1. Call `notion-query-database-view` with:
   - url: `https://www.notion.so/{{NOTION_DATABASE_ID}}`
   - filter: `{"property": "Status", "status": {"equals": "Hold"}}` (standalone) or `{"property": "Status", "status": {"equals": "Interested"}}` (orchestrator)
2. **Use the result for discovery only.** Extract the page IDs/links from the result — these are unambiguous even in a misaligned table. Do not read any property value out of the rendered table.
3. **Fetch full properties per page:** call `notion-fetch id="<page_id>"` on each candidate page and read its complete property set from the structured page response. Discard pages whose Status does not match the target. Every downstream read in this run — Step 0.6 priorities, the Step 0.8 coach-complete check, the Step 0.9a write-only-to-empty rule — uses these per-page property sets, never the rendered table.

**Rules for all paths:**

**Never create, update, or modify Notion database views.** Do not call `create-database-view`, `update-database-view`, or any equivalent tool under any circumstance — not as a workaround, not to filter results, not to resolve misalignment.

**On Paths A2 and B, do not use Bash or Grep on the query result.** Process it directly from the tool response in context. On Path A1 the result arrives through the shell, and trimming it there (`python3`/`jq`) is the sanctioned mechanism — that is the point of the rung, not a violation of this rule.

The result should contain only rows matching the target status. If unfiltered rows appear, discard non-matching ones in memory and log a warning. Do not process any row whose Status does not match the target.

If all paths fail with tool errors or unparseable responses, stop immediately and report the error to {{USER_FIRST_NAME}} — do not treat it as zero results and do not improvise a query route outside the ladder.

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
- In orchestrator mode only: the pipeline {{USER_FIRST_NAME}} is running (New Applications) — from her chat command, not from a Notion property. Default is `New Applications` unless {{USER_FIRST_NAME}} specifies otherwise. Not applicable in standalone intake mode.

Report the count to {{USER_FIRST_NAME}}: "Found N roles in Hold status. Sending to the employment coach." If the count is 0, stop and report that. If the query call returns a tool error or an unparseable response rather than a result array, stop and report the error to {{USER_FIRST_NAME}} — do not treat it as zero results. Do not wait for a response — proceed immediately to the next step.

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
     3. If the connector returns no match or the tool call fails, continue to the universal fallback ladder below.
   - **Universal fallback ladder — mandatory for every failed fetch, regardless of URL domain.** This applies to company career pages, JavaScript-rendered sites, unknown job boards, and LinkedIn/Indeed roles whose domain-specific fallback above also failed. Most postings are mirrored somewhere fetchable — a role must never be marked `needs-manual` until every rung below has been attempted. Stop at the first rung that returns usable JD text:
     1. **Rendering-capable extraction on the original URL.** Plain `WebFetch` is the weakest fetcher in any session. Before searching for mirrors, check the session for stronger extraction tools with `ToolSearch` (search keywords: `extract`, `crawl`, `scrape`, `fetch`, `browser`). Server-side extractors — e.g. a Tavily extract tool called with `extract_depth: "advanced"`, or an Exa fetch tool — render and parse pages that defeat `WebFetch`, including JavaScript-rendered career pages and LinkedIn auth-walled postings (both confirmed in live runs). Call the strongest available extractor on the original Job URL. If usable JD text returns, mark `url-fetched-via-extraction` and stop. A JavaScript shell or auth wall is a signal to switch fetcher, not a dead end.
     2. **LinkedIn MCP search** — call `mcp__linkedin-mcp__search_jobs` with `keyword` = "[Position title] [Company name]". Scan results for a company + title match; on a match, call `mcp__linkedin-mcp__get_job_details` with that result's job ID. If description content comes back, mark `url-fetched-via-linkedin-mcp` and record the LinkedIn URL alongside the original.
     3. **Company careers page** — `WebSearch` for `<company name> careers <role title>`, then fetch the most promising hit on the company's own domain.
     4. **Job board and ATS mirrors** — `WebSearch` for `"<role title>" "<company name>" site:greenhouse.io OR site:lever.co OR site:comeet.com OR site:workable.com OR site:ashbyhq.com OR site:glassdoor.com`. The `site:` list is a starting point, not a boundary — postings are also mirrored on investor career boards (the company's lead VC often lists portfolio jobs, e.g. team8.vc), BuiltIn city boards, and regional aggregators. Run one additional open search (`"<role title>" "<company name>"`) and try any mirror that surfaces. Fetch up to 3 matching results.
     5. **Exact title + company search** — `WebSearch` for `"<role title>" "<company name>" job description` to catch aggregator mirrors and public posting previews.
     - **Fetcher rule (all rungs):** fetch candidate URLs with the strongest extractor found in rung 1, not plain `WebFetch`. A mirror that returns a JavaScript shell to `WebFetch` will usually yield its full content to a rendering-capable extractor.
     - **Match guard (all rungs):** accepted content must match both the company and the position title on the Notion row. Never substitute a similar-but-different posting (different seniority, different location, or a different open role at the same company). Log near-misses in the revision log and keep going.
     - Any rung that succeeds via search: mark `url-fetched-via-search` (unless a more specific marker above applies), record the alternate source URL in the run-level revision log, and pass the content to the coach noting that the source URL differs from the saved Job URL.
   - **Every rung failed:** log the failure, listing which fallbacks were attempted (direct fetch, domain connector, rendering-capable extraction, LinkedIn MCP search, careers page, board mirrors, exact-title search). If `JD Body` is populated, mark `content-exists` and proceed on that. If `JD Body` is also empty, mark `needs-manual` and log to the run-level revision log — do not drop the role yet, flag it for {{USER_FIRST_NAME}} to resolve. A `needs-manual` flag whose log entry does not list the attempted fallbacks is invalid — the Step 0.9b briefing must show that the full ladder was exhausted.

2. **No Job URL — `JD Body` property is populated** — mark `content-exists`. Pass it to the coach as-is.

3. **No Job URL and no JD content anywhere** — mark `needs-fetch`. Log to the run-level revision log. Drop from this run.

Pass the full row payload (including `JD Body` content and any fetched URL content) to the employment coach in Step 0.8. The coach writes `JD Body`, `JD Fetch Status`, and `Israel Compatibility`.

Hold all structured JD data in memory. Proceed immediately to Step 0.6.

## Step 0.6 — Check existing priorities

For every role that passed Step 0.5, read the `Priority` property from the Notion row data collected in Step 0. This is the coach's scoring of each role — it is the sole queue ordering signal. Flag each role as either:
- `scored` — `Priority` is set to a value
- `unscored` — `Priority` is empty or null

Record the counts. Proceed immediately to Step 0.7.

## Step 0.7 — Build the processing queue

**If there are 5 or fewer roles:** process all of them. The cap is not reached, so priority ordering is irrelevant — skip queue selection and proceed immediately to Step 0.8 with all roles.

**If there are more than 5 roles:** select the top 5 using the priority order below. All others are deferred.

Queue selection order differs between standalone and orchestrator modes:

**Standalone intake mode (Hold roles — default):** Unscored roles take priority. The intake pipeline's purpose is to coach and score fresh Hold roles. Already-scored roles have been through intake before and are in Hold only because their Status writeback to Researched failed — they fill any remaining slots and receive a Status cleanup in Step 0.9d.

1. `unscored` roles — ordered by Notion creation date, earliest first (oldest un-coached roles run before newer ones). Fill up to 5 slots.
2. Remaining slots (if any) — filled with `scored` coach-complete roles ordered `1` → `2` → `3` → `4` → `5` → `6`.

**Orchestrator mode (Interested roles):** Scored roles take priority. The full pipeline should process the highest-priority ready-to-apply roles first.

1. `scored` roles ordered `1` → `2` → `3` → `4` → `5` → `6`
2. Remaining slots filled with `unscored` roles — the coach will score them in Step 0.8.

**Open Application hard floor (both modes):** Any role identifiable as an open application, unsolicited application, or speculative application where no specific listing is posted must always slot at `6` (Fifth) in the queue, regardless of any Priority value already set. If the coach has not yet run and a pre-set priority above `6` is found on such a role, treat it as `6` for queue ordering. The coach will correct the Notion value in Step 0.8.

All roles not selected are deferred. Proceed immediately to Step 0.8.

## Step 0.8 — Employment coach

**Pre-coach filter — run before any coach-complete check:** Remove any role marked `needs-manual` from the coach queue. A role with no usable JD content cannot be meaningfully analysed by the coach. Log the removal in the revision log: "[Company] — [Position]: removed from coach queue, JD content unavailable (needs-manual). Resolve manually then re-run intake." Do not send a `needs-manual` role to the coach under any circumstances. A `needs-manual` role is removed from the **processing queue entirely** — it is excluded from all of Step 0.9, including the 0.9d Status writeback. Its Status stays unchanged so it reappears in the next intake run once the JD is resolved.

Before spawning, check each remaining role in the queue: a role is `coach-complete` only if all required fields are populated. The required count depends on `gap_handling_mode`:
- **When `gap_handling_mode = enabled` (default):** all eight fields must be populated — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, and `Landscape`.
- **When `gap_handling_mode = disabled`:** seven fields — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, and `Landscape`. `Gap handling` is NOT required and must NOT block coach-complete status.

Partial population (any required field missing) is not coach-complete and the role must be sent to the coach. `Landscape` is always required — the coach must populate it for every role, even if only to confirm no new landscape intelligence exists.

- **All roles are `coach-complete`:** skip the coach spawn entirely. Proceed directly to Step 0.9 using existing values.
- **Any role has one or more fields missing:** spawn the coach with every role that is not fully complete. Carry existing values forward for coach-complete roles only.
- **No roles are `coach-complete`:** spawn the coach with all 5 roles as normal.

Spawn `employment-coach` with the applicable roles. Pass full JD data and the complete Notion row properties for each role.

The coach returns:
- Priority scores for all roles (Part 0 of the coach's output) — always
- Batch analysis and per-role writing guidance (Part 1)
- Strategic Notion properties: Role emphasis, JD proof, Keywords, Strategy, Company Stage, Role Type, Relationship type, Gap handling (Part 2)
- Patterns and notes for {{USER_FIRST_NAME}} (Part 3)

Hold the coach output in memory. Proceed immediately to Step 0.8.5.

## Step 0.8.5 — Coach output fact check

Spawn `gatekeeper` with `option=coach-output`, passing:
- The full coach output for all roles (Role emphasis, Strategy, Gap handling, Role summary per role)
- `01-writing-rules.md` is already in memory — confirm it is loaded before spawning

**If PASS:** proceed to Step 0.9.

**If FAIL:** the gatekeeper returns a list of specific unverifiable claims per role and per property. Return those claims to the employment coach with this instruction: "The following claims in your output cannot be traced to `01-writing-rules.md`. Revise the affected properties to remove or correct them. Do not substitute alternative fabrications — if a claim cannot be grounded in the reference file, omit it." Spawn the coach with only the affected roles and properties.

**Cap: 2 revision passes.** If still failing after pass 2, strip the unverifiable claims from the affected properties (replace with `[UNVERIFIABLE — removed]`), log all removed claims in the run-level revision log under `## Coach Fact Check — Unverifiable Claims Removed`, flag for {{USER_FIRST_NAME}} in final delivery, and proceed to Step 0.9.

## Step 0.9 — Writeback and briefing

This step is mechanical and runs end-to-end without pausing.

### 0.9a — Write coach outputs to Notion

**Rule: write only to empty properties.** For every property below, check the current Notion value first. If already populated — skip it. Do not overwrite any existing value. `N/A` counts as populated.

Where Path A1 (the `ntn` CLI, Step 0b gate) is active in this run, property writes may equivalently go through `ntn api /v1/pages/<page_id> -X PATCH -d '{"properties": {...}}'` — same write-only-to-empty rule, same parallelism. Otherwise use the connector tools as written below.

For each role in the processing queue, apply this rule to:
- `Priority` — write the coach's value (`1`–`6`) only if currently empty. If the role was coach-skipped (already coach-complete per Step 0.8), do not write at all — leave unchanged. In a mixed batch, apply per role individually.
- `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Relationship type`, `Role summary`, `Person who Advertised Role (if not Hiring Manager)` — write if empty.
- `Hiring manager's role`, `Manager role confirmed`, `No incumbents in this function` — write if empty.
- `First Advertised` — write if empty. Look for the original posting date on the job board page (often shown as "Posted X days ago", "Date posted:", or a visible timestamp). If the URL fetch returned a page with a posting date, parse and write it (format: YYYY-MM-DD). If no date is findable, leave empty — do not guess or approximate.
- `Gap handling` — write if empty. If gap_handling_mode = disabled, skip entirely.
- `Company Stage` — write if empty. Exact option values: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`, `Stealth`, or `N/A`.
- `Role Type` — write if empty. Multi-select exact values: `Builder`, `Scaler`, `Specialist`, `Leader`, or `N/A`.
- `Landscape` — write if empty. Skip entirely if already has content.

Confirm in chat: "Writeback complete: K roles updated, M properties skipped (already populated)."

### 0.9b — Brief {{USER_FIRST_NAME}}

Report to {{USER_FIRST_NAME}}:
- Queue list: company, title, priority source (existing / generated), and coach's reason for each.
- Batch analysis and base CV recommendation from the coach.
- Per-role Strategy and focus recommendations from the coach.
- Patterns and notes from the coach.

This is the one moment {{USER_FIRST_NAME}} sees the coach's reasoning before per-role processing begins. Do not wait for a response — proceed immediately to Step 0.9d.

### 0.9d — Status writeback (standalone mode only)

**Skip this step entirely when running as a sub-step of the career-engine orchestrator.** The orchestrator manages Status separately. This step runs only in standalone intake mode.

For every role in the processing queue, write `Status = Researched` using `notion-update-page`. Run all writes in parallel. **Never write Researched to a `needs-manual` role** — it was removed from the processing queue in Step 0.8 and must keep its current Status so it surfaces again after the JD is resolved.

After all writes complete, confirm in chat: "Status updated to Researched for N roles."

Intake is complete.
