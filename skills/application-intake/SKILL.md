---
name: application-intake
description: >
  Dual-mode intake pipeline for the CV campaign. In **standalone mode** (triggered
  directly via "run intake" or similar): processes Hold roles — fetches JDs, runs the
  employment coach for strategic properties and priority scoring,
  writes all results to Notion, updates Status to Researched.
  In **orchestrator mode** (called by applications-orchestrator): processes Interested
  roles using the Interested view — same steps, but Status is managed by the
  orchestrator, not this skill.
  Run standalone with: "run intake", "build the CV queue", "prep my Hold roles",
  "run the campaign intake", or any variant asking to research Hold roles.
  Does NOT write CVs or cover letters.
---

# CV Campaign — Queue Pipeline

This skill covers Steps 0 through 0.9 of the cv-campaign pipeline. All of these steps run before any per-role CV work begins. The goal of this pipeline is to give the employment coach complete information — full JD data for every role — before it makes any prioritization or writing decisions.

## Step −1 — Gap handling mode

Read `gap_handling` from `.claude/settings.json`. Set `gap_handling_mode` as follows:

- `"gap_handling": "disabled"` → `gap_handling_mode = disabled`
- `"gap_handling": "enabled"` → `gap_handling_mode = enabled`
- Key missing or any other value → `gap_handling_mode = enabled` (default)

Do not ask {{USER_FIRST_NAME}} about this. The preference was set during setup (Phase 5). If she wants to change the default, she updates `.claude/settings.json`. To suppress gap handling for a single run without changing the setting, she can add "no gap handling" to her prompt — check for that phrase in the current prompt and override to `disabled` if found.

**If `gap_handling_mode = disabled`:**
- Instruct the coach (in Step 0.8) to skip the `Gap handling` property entirely — do not populate it, do not write `N/A`.
- Skip the `Gap handling` writeback in Step 0.9a.
- The `coach-complete` check in Step 0.8 must NOT require `Gap handling` to be populated for this run.

**If `gap_handling_mode = enabled`:** proceed normally — gap handling is required for every role as documented.

---

## Step 0 — Fetch Notion schema and roles

**Guard — check configuration first.** Look at the database ID value immediately below. If it still reads the literal text `{{NOTION_DATABASE_ID}}` (unreplaced placeholder), **stop immediately** and tell the user:

> "The Notion database ID has not been configured. Run `/career-engine:setup` (or `/career-engine:setup --phase 5`) to complete the database integration before running the pipeline."

Do not attempt to search for the database. Do not proceed.

The database ID for this installation: `{{NOTION_DATABASE_ID}}`

---

**Step 0a — Fetch the database schema.** Run `notion-fetch` on the configured database ID:

```
notion-fetch id="{{NOTION_DATABASE_ID}}"
```

Extract the SQLite `CREATE TABLE` block from the response. This is your **schema reference** for the entire run — the authoritative list of property names and valid select option values. Keep it in context.

**Use the schema reference for every Notion write in this run.** When writing a select field, look up the valid options in the SQLite comment for that column (e.g., `-- one of ["Yes", "Remote-only", "No"]`) and write the exact string from the schema. Never hardcode select option values. If any agent returns a value that does not match a schema option, map it to the closest matching option using the schema as the authority.

**Pass the SQLite block to the employment coach** in its prompt as a "Notion schema reference" section so it can write select values that exactly match the live Notion options.

---

**Step 0b — Fetch roles using a direct Status filter.** Do NOT use view URL discovery. View-based queries fail for advanced-filter views and return oversized result sets for simple views. Query the database directly with a Status filter.

Target status by mode:
- **Standalone mode:** Status = `Hold`
- **Orchestrator mode:** Status = `Interested`

Run `notion-query-database-view` with:
- `url`: `https://www.notion.so/{{NOTION_DATABASE_ID}}`
- `filter`: `{"property": "Status", "status": {"equals": "Hold"}}` (standalone) or `{"property": "Status", "status": {"equals": "Interested"}}` (orchestrator)

If `notion-query-database-view` does not accept a `filter` parameter on a database URL, use the `notionApi` query tool with the same filter expression instead.

The result should contain only rows matching the target status. If the result still contains rows with other statuses (tool returned unfiltered data), filter them out in code — but log a warning that the filter did not apply. Do not process any row whose Status does not match the target.

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

Report the count to {{USER_FIRST_NAME}}: "Found N roles in Hold status. Sending to the employment coach." If the count is 0, stop and report that. Do not wait for a response — proceed immediately to the next step.

## Step 0.5 — Prepare JD content for the coach

Before passing roles to the coach, check each role's Notion row for existing JD content and normalise it inline.

**Always attempt the URL.** For every role that has a Job URL, fetch it — regardless of whether `JD Body` is already populated. The live posting may contain updated requirements, application instructions, salary information, recruiter name, or other signals not present in a manually copied JD Body. If the fetch succeeds, pass both the fetched content and the existing JD Body to the coach; the coach uses whichever is more complete or resolves any differences.

For each role:

1. **Job URL is present** — attempt `WebFetch` on the URL.
   - **Fetch succeeds:** mark `url-fetched`. Pass fetched content to the coach alongside any existing `JD Body`.
   - **Fetch fails or is blocked (paywalled, login-required, 404):** log the failure. If `JD Body` is populated, mark `content-exists` and proceed on that. If `JD Body` is also empty, mark `needs-manual` and log to the run-level revision log — do not drop the role yet, flag it for {{USER_FIRST_NAME}} to resolve.

2. **No Job URL — `JD Body` property is populated** — mark `content-exists`. Pass it to the coach as-is.

3. **No Job URL — `JD Body` is empty but the Notion page body contains a full job description** ({{USER_FIRST_NAME}} manually pasted the JD) — write it to `JD Body` and set `JD Fetch Status` = `Manual-entry` using `notion-update-page`. Mark `content-exists`. This normalises the data so future runs read from `JD Body` directly.

4. **No Job URL and no JD content anywhere** — mark `needs-fetch`. Log to the run-level revision log. Drop from this run.

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

**Standalone intake mode (Hold roles — default):** Unscored roles take priority. The intake pipeline's purpose is to coach and score fresh Hold roles. Already-scored roles have been through intake before and are in Hold only because their Status writeback to Researched failed — they fill any remaining slots and receive a Status cleanup in Step 0.9c.

1. `unscored` roles — ordered by Notion creation date, earliest first (oldest un-coached roles run before newer ones). Fill up to 5 slots.
2. Remaining slots (if any) — filled with `scored` coach-complete roles ordered `1` → `2` → `3` → `4` → `5` → `6`.

**Orchestrator mode (Interested roles):** Scored roles take priority. The full pipeline should process the highest-priority ready-to-apply roles first.

1. `scored` roles ordered `1` → `2` → `3` → `4` → `5` → `6`
2. Remaining slots filled with `unscored` roles — the coach will score them in Step 0.8.

**Open Application hard floor (both modes):** Any role identifiable as an open application, unsolicited application, or speculative application where no specific listing is posted must always slot at `6` (Fifth) in the queue, regardless of any Priority value already set. If the coach has not yet run and a pre-set priority above `6` is found on such a role, treat it as `6` for queue ordering. The coach will correct the Notion value in Step 0.8.

All roles not selected are deferred. Proceed immediately to Step 0.8.

## Step 0.8 — Employment coach

Before spawning, check each role in the queue: a role is `coach-complete` only if **all eight** of the following fields are populated — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, and `Landscape`. Partial population (any field missing) is not coach-complete and the role must be sent to the coach. `Gap handling` and `Landscape` are always required — the coach must populate both for every role, even if only to confirm no material gaps or no new landscape intelligence exists.

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

For each role in the processing queue, apply this rule to:
- `Priority` — write the coach's value (`1`–`6`) only if currently empty. If the role was coach-skipped (already coach-complete per Step 0.8), do not write at all — leave unchanged. In a mixed batch, apply per role individually.
- `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Relationship type`, `Role summary`, `Person who Advertised Role (if not Hiring Manager)` — write if empty.
- `Hiring manager's role`, `Manager role confirmed`, `No incumbents in this function` — write if empty.
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

**Skip this step entirely when running as a sub-step of the cv-campaign orchestrator.** The orchestrator manages Status separately. This step runs only in standalone intake mode.

For every role in the processing queue, write `Status = Researched` using `notion-update-page`. Run all writes in parallel.

After all writes complete, confirm in chat: "Status updated to Researched for N roles."

Intake is complete.
