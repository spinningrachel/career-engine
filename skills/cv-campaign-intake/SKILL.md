---
name: cv-campaign-intake
description: >
  Dual-mode intake pipeline for the CV campaign. In **standalone mode** (triggered
  directly via "run intake" or similar): processes Hold roles — fetches JDs, runs the
  employment coach for strategic properties and priority scoring, generates Q&A
  interview questions, writes all results to Notion, updates Status to Researched.
  In **orchestrator mode** (called by cv-pipeline-orchestrator): processes Interested
  roles using the Interested view — same steps, but Status is managed by the
  orchestrator, not this skill.
  Run standalone with: "run intake", "build the CV queue", "prep my Hold roles",
  "run the campaign intake", or any variant asking to research Hold roles.
  Does NOT write CVs or cover letters.
---

# CV Campaign — Queue Pipeline

This skill covers Steps 0 through 0.9 of the cv-campaign pipeline. All of these steps run before any per-role CV work begins. The goal of this pipeline is to give the employment coach complete information — full JD data for every role — before it makes any prioritization or writing decisions.

## Step 0 — Fetch Notion schema and roles

**First — fetch the database schema.** Run `notion-fetch` on the Job Applications database before doing anything else:

```
notion-fetch id="{{NOTION_DATABASE_ID}}"
```

Extract the SQLite `CREATE TABLE` block from the response. This is your **schema reference** for the entire run — the authoritative list of property names and valid select option values. Keep it in context.

**Use the schema reference for every Notion write in this run.** When writing a select field, look up the valid options in the SQLite comment for that column (e.g., `-- one of ["Yes", "Remote-only", "No"]`) and write the exact string from the schema. Never hardcode select option values. If any agent returns a value that does not match a schema option, map it to the closest matching option using the schema as the authority.

**Pass the SQLite block to the employment coach** in its prompt as a "Notion schema reference" section so it can write select values that exactly match the live Notion options.

---

**Then — fetch roles.** Use `notion-query-database-view` with this exact view URL:

```
https://www.notion.so/{{NOTION_DATABASE_ID}}?v=35e5ef1aa63480ff9b4e000cbcd67aec
```

This view returns `Hold` roles. Do not construct your own filter — use the view directly. Do not fetch the full database. Verify that returned rows have Status = `Hold` before processing — skip any row with a different status.

**When loaded by the cv-campaign orchestrator:** use the Interested view instead — `v=35e5ef1aa6348032abdb000ca4cf71ac`. The orchestrator specifies this override in its Pipeline Flow instructions. All other steps in this skill apply unchanged.

Skip any entry where neither a Job URL nor job description details in the RTF body of the record are populated.

**If Position is empty:** do not skip. Instead, attempt to infer the position title from the Notion page title (the `Name` property):
- If the page title clearly contains a role signal (words like "Head", "VP", "Director", "Manager", "Lead", "PMM", "Marketing", "Engineer", "Designer", "Product", "Content", "Technical", or a similar job-title word), use it as the Position value for this run and flag the role in the Step 0.9b briefing: "Position inferred from page title — update the Position field in Notion to confirm."
- If the page title looks like a company name only (identical to the Company field, or contains only a company name with no role title signal), process the role with Position = "(unknown)" and flag it in Step 0.9b: "Position field is empty and could not be inferred from the page title — update in Notion."

**Data quality skip condition:** Skip any entry where Company is empty, "Unknown", or appears to contain a job title embedded in the company name field (e.g., "VP Marketing @ Company") AND Position is also empty AND the page title provides no usable signal — flag these in the Step 0.9b briefing as data quality issues requiring correction before they can be processed.

**Hold roles are processed fresh each intake run** — JD fetched (or read from JD Body if already populated), coach spawned unless already coach-complete, Q&A generated unless already populated. Hold roles that are already coach-complete are likely holdovers from a prior intake run where Status writeback to Researched failed — the pipeline completes their Status update in Step 0.9c.

For each matching entry, capture the full row payload including:
- Page ID
- Company name
- Position title (use inferred value if Position field is empty, per the rules above)
- Job URL
- Every other property set on the row (notes, tags, source, and any existing priority value) — pass these through verbatim; do not interpret them yet
- In orchestrator mode only: the pipeline {{USER_FIRST_NAME}} is running (Standard) — from her chat command, not from a Notion property. Default is `Standard` unless {{USER_FIRST_NAME}} specifies otherwise. Not applicable in standalone intake mode.

Report the count to {{USER_FIRST_NAME}}: "Found N roles in Hold status. Sending to the employment coach." If the count is 0, stop and report that. Do not wait for a response — proceed immediately to the next step.

## Step 0.5 — Prepare JD content for the coach

Before passing roles to the coach, check each role's Notion row for existing JD content and normalise it inline. The coach handles all fetching — this step only surfaces what's already there.

For each role, in this priority order:

1. **`JD Body` property is populated** — mark `content-exists`. Pass it to the coach as-is. Do not re-fetch.

2. **`JD Body` is empty but the Notion page body contains a full job description** ({{USER_FIRST_NAME}} manually pasted the JD) — write it to `JD Body` and set `JD Fetch Status` = `Manual-entry` using `notion-update-page`. Mark `content-exists`. This normalises the data so future runs read from `JD Body` directly.

3. **Neither** — mark `needs-fetch`. The coach will fetch the URL and handle the result.

Pass the full row payload (including `JD Body` content where present) to the employment coach in Step 0.8. The coach fetches, verifies, and writes `JD Body`, `JD Fetch Status`, and `Israel Compatibility` for all `needs-fetch` roles. Roles the coach cannot access are dropped and logged to the run-level revision log.

Hold all structured JD data in memory. Proceed immediately to Step 0.6.

## Step 0.6 — Check existing priorities

For every role that passed Step 0.5, read the `Priority` property from the Notion row data collected in Step 0. This is the coach's scoring of each role — it is the sole queue ordering signal. Flag each role as either:
- `scored` — `Priority` is set to a value
- `unscored` — `Priority` is empty or null

Record the counts. Proceed immediately to Step 0.7.

## Step 0.7 — Build the processing queue

Select up to 5 roles to process this run. No agent needed — the orchestrator does this directly from the priority data in memory.

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

Before spawning, check each role in the queue: a role is `coach-complete` only if **all seven** of the following fields are populated — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, and `Gap handling`. Partial population (any field missing) is not coach-complete and the role must be sent to the coach. `Gap handling` is always required — the coach must populate it for every role, even if only to confirm no material gaps exist.

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
- `01-candidate-rules.md` is already in memory — confirm it is loaded before spawning

**If PASS:** proceed to Step 0.9.

**If FAIL:** the gatekeeper returns a list of specific unverifiable claims per role and per property. Return those claims to the employment coach with this instruction: "The following claims in your output cannot be traced to `01-candidate-rules.md`. Revise the affected properties to remove or correct them. Do not substitute alternative fabrications — if a claim cannot be grounded in the reference file, omit it." Spawn the coach with only the affected roles and properties.

**Cap: 2 revision passes.** If still failing after pass 2, strip the unverifiable claims from the affected properties (replace with `[UNVERIFIABLE — removed]`), log all removed claims in the run-level revision log under `## Coach Fact Check — Unverifiable Claims Removed`, flag for {{USER_FIRST_NAME}} in final delivery, and proceed to Step 0.9.

## Step 0.9 — Writeback and briefing

This step is mechanical and runs end-to-end without pausing.

### 0.9a — Write coach outputs to Notion

For each role in the processing queue, write the following using `notion-update-page`. Every coach-owned property must receive a value — write `N/A` explicitly if nothing applies. Do not leave any coach-owned property blank.

- `Priority` — **apply this rule per role, not per session.** For each role where the coach ran (it was not coach-complete before this session): write the coach's numeric Notion value (`1`–`6`) from Part 0. For `scored` roles the coach returns `confirmed` or `revised`; for `unscored` roles it returns `new`. For each role where the coach was skipped (already coach-complete per Step 0.8): leave Priority unchanged — do NOT write to it. Writing null or a stale value to Priority for a coach-skipped role is a data loss error. In a mixed batch (some roles coached, some skipped), apply this rule individually to each role.
- `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Relationship type`, `Role summary`, `Person who Advertised Role (if not Hiring Manager)` — write for every role in the queue.
- `Hiring manager's role`, `Manager role confirmed`, `No other Marketing roles employed by company` — write for every role in the queue.
- `Gap handling` — write for every role in the queue. If {{USER_FIRST_NAME}} has already edited this in Notion, treat her version as authoritative and do not overwrite it.
- `Company Stage` — from the coach's output. Use the exact option values: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`, `Stealth`, or `N/A`. Write `N/A` if the coach could not determine stage.
- `Role Type` — from the coach's output. Multi-select — use the exact option values: `Builder`, `Scaler`, `Specialist`, `Leader`, or `N/A`. Write `N/A` if not determinable.

Confirm in chat: "Writeback complete: K roles scored (N confirmed, M revised, P new)."

### 0.9b — Brief {{USER_FIRST_NAME}}

Report to {{USER_FIRST_NAME}}:
- Queue list: company, title, priority source (existing / generated), and coach's reason for each.
- Batch analysis and base CV recommendation from the coach.
- Per-role Strategy and focus recommendations from the coach.
- Patterns and notes from the coach.

This is the one moment {{USER_FIRST_NAME}} sees the coach's reasoning before per-role processing begins. Do not wait for a response — proceed immediately to Step 0.9c.

### 0.9c — Interview questions

Q&A questions are only generated for roles that were **already researched before this session** (i.e., marked `coach-complete` in Step 0.8 before the coach ran). Roles where the coach ran fresh in this session are skipped — the full campaign will run without Q&A for those roles, and the letter-writer will work with what it has.

For each role in the processing queue:

1. **If the role was NOT `coach-complete` before this session** (coach ran fresh in Step 0.8): skip. Do not generate Q&A questions.

2. **If the role WAS `coach-complete` before this session AND `Q&A` is already populated:** skip — do not overwrite {{USER_FIRST_NAME}}'s existing content.

3. **If the role WAS `coach-complete` before this session AND `Q&A` is empty or null:** Spawn `letter-writer` with `option=interview-questions`, passing:
   - Company name and role title
   - The structured JD (including the Company self-characterization section if present)
   - The coach's output for this role: Role emphasis, Strategy, Gap handling, Relationship type

4. **Write the returned questions to Notion** using `notion-update-page`, writing to the `Q&A` property.

Run all eligible spawns in parallel. Do not wait for one to complete before spawning the next.

After all writes complete, report to {{USER_FIRST_NAME}}:

> "Interview questions written to Notion Q&A for N roles. [M roles already had Q&A content and were skipped. K roles were not pre-researched and will proceed without Q&A.] Review and answer each role's Q&A in Notion before running the full campaign."

### 0.9d — Status writeback (standalone mode only)

**Skip this step entirely when running as a sub-step of the cv-campaign orchestrator.** The orchestrator manages Status separately. This step runs only in standalone intake mode.

For every role in the processing queue, write `Status = Researched` using `notion-update-page`. Run all writes in parallel.

After all writes complete, confirm in chat: "Status updated to Researched for N roles."

### 0.9e — Q&A Bank Promotion (standalone mode only)

**Skip when running as a sub-step of the cv-campaign orchestrator.** The orchestrator handles Q&A bank promotion in its own Step 9a after all pipeline stages complete.

This step captures any Q&A answers {{USER_FIRST_NAME}} has already written into Notion (from a prior intake run) and promotes them into `references/02-candidate-background.md` so the letter-writer never asks {{USER_FIRST_NAME}} the same question twice.

For each role in the processing queue:

1. Read the `Q&A` property from Notion for this role (re-read from Notion or pull from memory if retained). If Q&A is empty, null, or contains only unanswered questions (no text after any question), skip this role.

2. Parse Q&A content into question/answer pairs: split on blank lines or labelled question patterns (`Q:`, `Question:`, numbered items). Treat the first line of each block as the question and everything after as the answer. Skip any pair where the answer is missing or fewer than 10 characters. Skip any pair where the question contains the company name or role title verbatim — those are role-specific and not reusable.

3. Read `references/02-candidate-background.md` and extract existing questions from the table. For each candidate pair, check for duplicates using keyword overlap: extract 4+ character words from both questions, exclude noise words (`what`, `have`, `your`, `does`, `with`, `that`, `this`, `from`, `been`, `are`, `you`, `the`, `and`, `for`, `any`, `how`, `do`), compute overlap ratio against the shorter set. If overlap ≥ 0.5, it's a duplicate — skip it.

4. For each non-duplicate pair, append a new row to the 02-candidate-background.md table:
   ```
   | <question> | <answer> | Auto-promoted from Notion Q&A — <YYYY-MM-DD>. Review and edit if role-specific context should be stripped. |
   ```
   Write all new rows in a single append operation.

5. Log in the chat summary: "Q&A bank: N new answers promoted to references/02-candidate-background.md." (Or: "No new Q&A answers to promote.")

Do not wait for {{USER_FIRST_NAME}} to respond. Intake is complete.
