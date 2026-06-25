---
name: career-engine-edit
description: Editing pipeline for the career-engine plugin. Triggers when the user says "edit CVs", "run CV edits", "process the Needs editing queue", or any similar phrase. Retrieves all Job Applications rows with Status = Needs editing, runs the career coach first to verify and update its owned properties, then routes each role through the appropriate pipeline agents to improve existing outputs — not to start from scratch. Agents in this pipeline are explicitly informed they are refining existing work, not generating from zero.
---

# New Application — Editing Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill handles the editing pipeline for roles the user has flagged as needing revision. It runs separately from the main pipeline and is triggered by Status = `Needs editing` in the Job Applications database.

The key difference from the main pipeline: **agents are not starting from scratch.** Existing CV text, cover letter text, coach properties, and reviewer feedback are all in the Notion row. The goal is to improve what exists, informed by what is already documented there.

**`Needs editing` always means edit from the Notion entry.** Every role with Status = `Needs editing` uses whatever is already inside its Notion row as the starting point — existing CV text, cover letter, coach properties, reviewer notes. Nothing is discarded. This rule holds regardless of what state.json says. state.json is crash recovery only (see State file section below).

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

## Preflight

**Outputs go to the configured output folder — never to a session scratchpad.**

The only valid output destination is:
`{{OUTPUT_FOLDER}}/applications-<YYYY-MM-DD>/`

Do not create a local output directory inside a session path (`local_*/outputs/` or similar). Files written there do not sync and are not findable.

Before starting, verify output access using the two-path ladder (R-30 — full definition in the orchestrator's Mandatory path verification):

**Path A — direct filesystem:**

```bash
ls "{{OUTPUT_FOLDER}}/" 2>/dev/null && echo "Output path confirmed (Path A)."
```

**Path B — host-bridge MCP:** if Path A fails (sandboxed environment — an environment limitation, not a missing folder), discover host filesystem tools via ToolSearch (`Desktop Commander`, `read_file`, `write_file`, `create_directory`, `start_process`, or equivalent) and verify access by listing `{{OUTPUT_FOLDER}}` through the strongest available tool. If confirmed, proceed — and route ALL of this run's file operations through those tools: reading the existing CV/letter DOCX files, the pandoc text extractions (E0.7 baseline, existing letter text), every conversion, and every write back to the run folder (pandoc runs via the host process tool; intermediate markdown is written through the host tool, not sandbox `/tmp/`).

**Both paths fail → stop the run immediately** and report to the user: the run needs either the output folder connected to the session or a host filesystem tool (e.g. Desktop Commander) enabled.

**The no-scratchpad rule applies on both paths.** Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support". If host access is lost mid-run, retry once; if still unreachable, deliver the remaining file contents in chat flagged for manual save and log the failure — never write to a substitute location.

Then confirm:
1. Output folder for each role is the run folder from the original run date. **How to identify it:** search for `state.json` files across all run folders under the output root — check both `applications-<YYYY-MM-DD>/` (current naming) and `cv-campaign-YYYY-MM-DD/` (legacy naming used by earlier pipeline runs). For each state.json found, look for an entry matching this role's `notion_page_id`. The run folder is the directory containing that state.json. If no state.json entry exists for this role (e.g., it was added to Notion after the original run), use today's date as the run folder (`applications-<YYYY-MM-DD>/`) and create it if needed.
2. File format is DOCX — same as the main pipeline.
3. `career-engine-export` skill is loaded.
4. All career-engine skills are loaded, including 01-writing-rules.md.

## Step E0-pre — Resolve per-install config (R-38)

The edit pipeline is its own entry (no orchestrator), so resolve config yourself. After the `career-data` discovery, run the **career-data health check** before proceeding:
1. Count files in `${CAREER_DATA}/references/delivered-letters/` (excluding `INDEX.md`). If count = 0: **stop** — "career-data has no delivered letters — voice calibration will fail. Add at least one sent letter, then re-run."
2. **Config keys — required hard-stop; everything else optional.** Read `pipeline-preferences.json`. **Required (stop if missing or empty):** `output_folder`, `cv_template`, and — when a database backend is configured (`database_backend`; default `notion`) — `database_id`. Stop with: "career-data config is incomplete — run `/career-engine:setup --phase 5` to fill in: [required keys missing]." **All other keys are optional — never stop on them;** collect any absent (older config) or empty into `CONFIG_HEALTH` and emit the same end-of-run `⚙️ Config health` block the orchestrator defines. **Backward compatibility:** accept legacy `notion_database_id` (→ `database_id`), `notion_needs_editing_view_url` (→ `database_edit_view_url`), `location_compatibility.notion_property` (→ `database_property`); prefer the `database_*` names and flag any legacy name in `CONFIG_HEALTH`.
3. (Code sessions) If `~/.claude/skills/career-data/` is absent or differs from `${CAREER_DATA}`, warn: "career-data may be out of sync with the Desktop app — re-install the .skill file if you recently updated it in Chat. Continuing on the resolved path."

Then read `${CAREER_DATA}/references/pipeline-preferences.json` and set `$NOTION_DATABASE_ID` (← `database_id`, legacy `notion_database_id`), `$NOTION_NEEDS_EDITING_VIEW_URL` (← `database_edit_view_url`, legacy `notion_needs_editing_view_url`), `$OUTPUT_FOLDER`, `$CV_TEMPLATE`, and `$DRAFT_DIR_URL_BASE` (used by the queries and exports below; the `$NOTION_*` var names are the Notion adapter's internal names and are unchanged). Wherever this skill shows `{{NOTION_DATABASE_ID}}` or `{{NOTION_NEEDS_EDITING_VIEW_URL}}`, use the resolved values. Stop if `database_id`, `output_folder`, or `cv_template` is missing: "career-data is missing a required config key — run `/career-engine:setup --phase 5`." Optional: `draft_dir_url_base` absent or `skip` → Draft Directory writeback is skipped (log it in the final delivery as "Draft Directory not written — `draft_dir_url_base` not configured"). The plugin keeps these placeholders literal (single build).

## Step E0 — Fetch roles for editing

**Guard — resolve the database ID from the career-data config (R-38).** The plugin keeps `{{NOTION_DATABASE_ID}}` literal by design — do not treat the literal placeholder as unconfigured. Use `$NOTION_DATABASE_ID` resolved in Step E0-pre from the career-data config. **Stop only if that config value is missing or empty**, and tell the user:

> "Your career-data config has no `database_id` (or legacy `notion_database_id`). Run `/career-engine:setup --phase 5` to add it."

---

**Path A1 — `ntn` CLI (preferred where available).** If the gate passes (`command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1`), query directly instead of the A2/B routes below (resolve the data source ID from `{{NOTION_DATABASE_ID}}` via `ntn api /v1/databases/{{NOTION_DATABASE_ID}}` → `data_sources[0].id`):

```bash
ntn datasources query <data-source-id> \
  --filter '{"property":"Status","status":{"equals":"Needs editing"}}' \
  --limit 100 --json
```

Trim the JSON in the shell to page `id` plus the named properties E0 needs; for the full per-role payload, `ntn pages get <page_id>` returns all properties plus the page body as markdown in one call. The pre-built view exists to serve the connector route — on A1, the direct Status filter is the sanctioned equivalent. If the gate fails or any A1 call errors, fall through to Path A2 (then Path B) below without comment (intake Step 0b documents the full ladder and syntax).

**Path A2 — `notionApi` structured query.** If A1 is unavailable, load the schema (`ToolSearch query="select:notionApi__API-query-data-source"`, or call `mcp__notionApi__API-query-data-source` directly). A tool-not-found error means the server is not connected — fall through to Path B; on any other error (401, Enterprise-gated response, timeout, malformed response) treat it as unusable and also fall through. Otherwise call `API-query-data-source` with database ID `{{NOTION_DATABASE_ID}}`, filter `{"property":"Status","status":{"equals":"Needs editing"}}`, page_size 100. It returns structured JSON keyed by property name.

**Path B — standard connector view query (discovery only).** `notion-query-database-view` runs a *view's own saved filter* — it takes no ad-hoc `filter` argument (any filter you pass is ignored) and needs a real view URL (`...?v=<VIEW_ID>`), never the bare database URL (R-39). Query the Job Applications database using the pre-built "Needs Editing" view:

```
View URL: {{NOTION_NEEDS_EDITING_VIEW_URL}}
```

This view is pre-configured to return only rows with `Status = Needs editing`. Call `notion-query-database-view` with this `view_url` and no other arguments — do not construct your own filter (the A1/A2 direct filters above are the only sanctioned filtered routes). The view URL is a fast path; if it is empty, fails, or is stale (view deleted or reorganised), resolve it by name instead using a two-step fetch: (1) call `notion-fetch id="{{NOTION_DATABASE_ID}}"` to get the `collection://` URL from the `<data-sources>` block; (2) call `notion-fetch id="<collection_url>"` to list views, find the one with `"name":"Needs Editing"`, take its UUID (from the `view://UUID-with-dashes` format), **remove all dashes**, and construct `https://www.notion.so/<DB_ID_NO_DASHES>?v=<VIEW_ID_NO_DASHES>`.

**The view result is for discovery only (R-1).** `notion-query-database-view` returns a rendered table that is susceptible to column misalignment and shows only the view's visible columns — never enough for the full row payload below. Extract only the page IDs/links from the result (unambiguous even in a misaligned table), then call `notion-fetch id="<page_id>"` on each page and read the full payload from the structured page response. Never read property values out of the rendered table.

For each page fetched, capture the full row payload including:
- Page ID
- Company name
- Position title
- Job URL
- `Edit type` — required; options: `CV`, `Letter`, `Both`
- `Edit notes` — optional; the user's specific instructions about what needs to change. When populated, pass to cv-writer (Step E3) and/or letter-writer (Step E7) so they address the exact issues named before applying general improvements. Do not pass to the coach or gatekeeper.
- Pipeline (New Applications — from the user's chat command)
- All existing property values — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Why I Want This Role`, `CV File Name`, `Letter File Name` (note: these two file-name properties may be absent from the schema — that is not an error; see the run-folder convention below), `Note`, and any other populated fields
- Any reviewer feedback or notes already on the row

**Edit type is mandatory. It controls everything.** After fetching, immediately inspect the `Edit type` value for every role before any other work begins — before spawning the coach, before loading JDs, before any pipeline step.

- **`Edit type` is empty or not one of `CV`, `Letter`, `Both`:** do not proceed with this role under any circumstances. Do not default to `Both`. Log the skip: "[Company] — [Role Title]: skipped — Edit type not set. Add CV, Letter, or Both to the Edit type field in Notion." No subagent is spawned for this role.
- **`Edit type` is `CV`, `Letter`, or `Both`:** proceed with that role using the routing below.

Report the count to the user: "Found N roles marked Needs editing (M skipped — Edit type missing)." If the count after skipping is 0, **stop immediately and report that.** Do not continue the pipeline.

**Queue cap — maximum 5 roles per run.** If more than 5 roles remain after skipping, select the top 5 by Priority field: First > Second > Third > Fourth > Fifth. Ties at the same Priority level are broken randomly. Report which roles are deferred: "Deferring N roles — re-run edit to process them." Proceed only with the selected 5.

**Routing by Edit type — hard gate, checked again before each subagent spawn:**
- `CV` — run CV editing steps only (E0.7 content check, E3–E6.5, CV DOCX export). Skip ALL cover letter steps. Do not spawn letter-writer, do not run cover letter gatekeeper.
- `Letter` — run cover letter editing steps only (E0.7 cover letter check, E7–E7.5, cover letter DOCX export). Skip ALL CV steps. Do not spawn cv-writer, do not run CV gatekeeper.
- `Both` — run all steps.

## Step E0.5 — Prepare JD content from Notion rows

For each role fetched in Step E0, extract the structured JD from the row payload. The `JD Body` property was already captured in Step E0 as part of the full row payload.

For each role:
1. **`JD Body` is populated** — mark `content-exists`. Use this as the structured JD for all downstream steps (coach, gatekeeper, cv-writer, letter-writer). Do not re-fetch from the Job URL.
2. **`JD Body` is empty** — attempt to fetch from the Job URL directly (use the rendering-capable extraction ladder from `career-engine-intake` Step 0.5). If the fetch succeeds, populate `JD Body` in memory and proceed. If the URL is unreachable and `JD Body` remains empty, **hard-drop this role from the editing queue**: log "Dropped — JD unavailable: [Company] — [Role Title]: URL unreachable and JD Body empty. Paste the JD into Notion before re-running edit." Remove from all subsequent steps (E0.7 onward). Do not proceed with a role that has no JD.

Hold all structured JD data in memory. All subsequent steps that reference "the structured JD from Step E0.5" draw from here.

## Step E0.7 — Baseline check

Run the gatekeeper on all existing outputs in parallel. The goal is a complete picture of what's already broken before any editing begins. All violation lists travel forward to the coach (E1) and cv-writer (E3) as context.

**Needs-fetch roles — defer this step.** A role marked `needs-fetch` in E0.5 has no JD yet; the fetch in E0.5 attempted retrieval. If E0.5 hard-dropped the role (URL unreachable), no baseline check runs at all. For roles where the JD was successfully fetched in E0.5 (and populated in memory), run the baseline check now.

**Content check:** Run only if Edit type is `CV` or `Both`. Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the existing CV text, the structured JD, and the role's `Keywords` property (from the Notion row — required for the ATS pre-check). Returns either PASS or a content violation list.

**Cover letter check:** Run only if Edit type is `Letter` or `Both`. Locate the existing cover letter in this order: `Letter File Name` from the Notion row → state.json `cover_letter_path` → run-folder pattern search (`coverletter-*` / `cv-*` in the company subdirectory) → Draft Directory company subdirectory. If the file cannot be located by any of these methods, skip the cover letter baseline check entirely and log: "Cover letter baseline check skipped for [Company] — file not locatable (no prior pipeline run or file moved)." Otherwise spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the existing cover letter text and the structured JD. Returns either PASS or a cover letter violation list.

Run both in parallel. Collect results. Do not loop or fix anything yet — this step is diagnosis only.

## Step E1 — Coach properties gate

**The career coach is never spawned from the edit pipeline.** Coach properties are set during intake (Hold → Researched) and are expected to be present when the editing pipeline runs.

For each role in the editing queue, verify these **writer-needed fields** are populated (non-empty):
`Role emphasis`, `Keywords`, `Strategy`.

`JD proof` is not checked — it is reference-only. `Gap handling` is not required when `gap_handling_mode = disabled`.

- **All three fields present** → role is ready; carry its existing coach values forward.
- **Any field missing** → **hard-drop this role from the queue**. Log: "Career coach properties missing for [Company] — [Role Title]: missing `<list>`. Run intake first (`/career-engine --coach-skills`), then re-run edit." Leave Status unchanged.

After the gate, confirm in chat: "Coach properties verified: N roles proceed, M excluded (missing coach properties)."

## Per-role editing pipeline

Process roles sequentially. For each role, branch on the pipeline the user specified in chat (same logic as the main pipeline).

**Step E0.pipe — Create scratch directory**

Before starting any role, create a per-role scratch directory for reviewer outputs (mirrors the new-application `$PIPE` pattern):

```
$PIPE = <output_dir>/<company_dir>/_pipeline/
```

Path A (Bash): `mkdir -p "$PIPE"`
Path B (host-bridge MCP): create the directory through the host file tool.

Set `$PIPE` as a variable used throughout this role's steps. Remove it after Step E9.5 (same as the new-application Step 7g cleanup) — non-blocking if removal fails.

### Pipeline `New Applications`

Agents in this track are explicitly informed they are improving existing work. Pass each agent:
- The structured JD from Step E0.5
- The existing CV text from the Notion row or the existing DOCX (whichever is available)
- The existing cover letter text (retrieved from the output run folder using the filename in `Letter File Name`; if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*` — extract text using `pandoc "<output_dir>/<letter-filename>.docx" -t plain` or read the `.md` sibling)
- The coach properties verified in Step E1
- Any reviewer feedback or notes already on the row

**Step E3 — CV writer (revision mode)**

Spawn `cv-writer` with `option=revision`. Pass:
- `CAREER_DATA=${CAREER_DATA}`
- The existing CV text as the draft (from the saved markdown backup at the output path, or extracted using `pandoc "<cv>.docx" -t markdown` if only the DOCX is available)
- The coach's verified properties as the strategic anchor
- The baseline content violation list from Step E0.7 (so the cv-writer addresses pre-existing violations immediately, not after another loop)
- Any recruiter or hiring manager feedback already on the row from the original pipeline run
- **`Edit notes` content** (from the Step E0 row payload) — if populated, include verbatim with the instruction: "Address these specific edit notes first, before applying general improvements: [content]". Omit if empty.

The cv-writer is improving the existing CV — not drafting a new one.

**Quality requirement — include this verbatim in the cv-writer prompt:**
> For every section you touch, return a before/after comparison stating specifically what changed and why the revision is stronger. If you leave a section unchanged, say so explicitly. If you cannot improve a section beyond rule-compliance — same structure, same sentences, minor word swaps — say "no quality improvement possible here" rather than returning near-identical text. Rule-compliant-but-equivalent output is a failure, not a revision.

**Step E3.25 — Quality comparison gate**

Before passing the revised CV to the gatekeeper, the orchestrator reads both versions side by side.

Assess:
- Did the summary change substantively, or just swap words?
- Did bullet points become more specific, quantified, or better targeted to this JD?
- Is any section weaker than before (vaguer, less specific, or missing a proof point)?

**If output is near-identical or weaker in any section:** Return to `cv-writer` with `option=revision`, quoting the specific weak section verbatim and instructing: "This section is not improved. Rewrite it — new structure, stronger framing, more targeted language. Do not return text that is substantively the same as the input." Max 2 loops. If no quality improvement is achieved after 2 loops, flag in the final delivery: "[Role] — CV section [X]: no quality improvement achieved after 2 rounds."

**If output is demonstrably stronger:** proceed to Step E3.5.

**Step E3.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the revised CV text, the structured JD from Step E0.5, and the role's `Keywords` property (from the coach properties verified in Step E1 — required for the ATS pre-check).

**If PASS:** proceed to Step E4.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the revised CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Do not surface this loop to the user. Log all violation rounds internally.

**Step E4 — Recruiter review**

Spawn `recruiter-reviewer` with `CAREER_DATA=${CAREER_DATA}`, the structured JD, the revised CV, and `OUTPUT_PATH=$PIPE/recruiter-review.md`. The reviewer writes its full review to that file and returns only a 2-line status (R-41 protocol). The reviewer is aware this is a revision, not a first draft.

**Step E5 — CV writer (final revision)**

Read recruiter feedback from `$PIPE/recruiter-review.md`. Spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, the revised CV from Step E3, and the recruiter feedback. Returns the final CV and revision log.

**Step E5.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the final revised CV text, the structured JD, and the role's `Keywords` property.

**If PASS:** proceed to Step E7.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the final CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

**Step E7 — Cover letter (initial revision)**

**Gate — Why I Want This Role is mandatory for the letter track.** Check the `Why I Want This Role` value from the Step E0 row payload before spawning anything. If it is empty: do NOT spawn letter-writer — its Intake Gate refuses to write without this content, and that refusal has no recovery path inside this pipeline. Instead: for Edit type `Both`, skip Steps E7–E8 and continue with the CV track only; for Edit type `Letter`, skip the role entirely. In both cases log and surface: "Letter edit skipped for [Company] — [Role Title]: the Why I Want This Role field in Notion is empty. Fill it in and re-run edit for this role."

**Before spawning letter-writer:** Read the following from the Notion row payload collected in Step E0 (all are part of the full row payload already in memory):
- **`Why I Want This Role` property** — the user's written motivation for this role; passes the gate above, so it is populated. Include the full content.

Spawn `letter-writer` with `option=revision`. Pass:
- `CAREER_DATA=${CAREER_DATA}`
- The existing cover letter (from the output run folder using the filename in `Letter File Name`; if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*`)
- The baseline cover letter violation list from Step E0.7
- From the coach properties verified in Step E1: `Strategy`, `Keywords`, `Gap handling` — **do NOT pass `Role emphasis`** to the letter-writer
- **The CV (always required — for context).** If Edit type is `Both`, use the final revised CV from Steps E3–E5. If Edit type is `Letter`, read the existing CV from the output run folder using the filename in `CV File Name` from the Notion row (fallback: state.json `cv_path`, or the Draft Directory company subdirectory with filename pattern `cv-*`). Extract text via `pandoc "<cv-file>.docx" -t plain`. If the file cannot be located, log a warning and proceed — but do not omit this pass silently. The letter-writer uses the CV to check first-person consistency, scope claims, and experience framing. It cannot do that without the CV.
- **`Why I Want This Role` — pass the verbatim text as a quoted block, never paraphrased or distilled.** The letter-writer's Intake Gate requires this field and its instruction rules require working from the user's exact words, not thematic summaries of them. If the Edit notes reference this field as the content source, that is even more reason to pass it raw — the writer must receive the actual material, not the orchestrator's interpretation of it. (R-44)
- **`Edit notes` content** (from the Step E0 row payload) — if populated, include verbatim with the instruction: "Address these specific edit notes first, before applying general improvements: [content]". Omit if empty.
- **Recruiter review** path `$PIPE/recruiter-review.md` to read — includes the "Interview-trigger gaps" section; the letter-writer uses these to proactively address gaps where Why I Want This Role or documented background provides a real answer. **Fabrication rules always trump reviewer input — even when a gap is passed, the letter-writer may only answer it with documented background or Why I Want This Role content. A reviewer flag does not authorise invention.**
- `LETTER_PATH=$PIPE/letter-draft.md` — the writer writes its output to this file and returns only a 2-line status + path (R-41 protocol).

The letter-writer improves the existing letter — it does not start from scratch. **Exception:** if the Edit notes contain an explicit "write from scratch" instruction, spawn the letter-writer in fresh-draft mode and discard the existing letter as the starting point. **When "write from scratch" is present, this instruction applies to ALL language versions** — if the role's `Languages` property includes Hebrew or other languages, Step E9H must also regenerate those versions from scratch (do not carry the old localized text forward as a base; spawn localization with the new English letter as the source).

The cover letter is written to the DOCX file only. Do not write cover letter text to any Notion property.

**Step E7.25 — Cover letter quality comparison gate**

Before passing the revised cover letter to the gatekeeper, compare the old and new versions on four dimensions:

1. **Opening strength** — does it pull the reader in immediately, or start with a generic frame?
2. **Specificity** — does it name concrete things about this company, this role, or this intersection of the user's background?
3. **Voice naturalness** — does it sound like a person talking, or like assembled copy?
4. **Closing force** — does it end with a reason to respond, or trail off?

**The new letter must be stronger than the old on at least 2 of these 4 dimensions.**

**If it is not:** Return to `letter-writer` with `option=revision`, quoting the old letter's strongest lines verbatim and instructing: "The revision is not better. The original was stronger in [specific dimension]. Here are the lines that worked best in the original: [quoted lines]. Write a new letter that preserves this strength while fixing the identified problems." Max 2 loops. If no improvement after 2 loops, preserve the original letter and flag in the final delivery: "[Role] — cover letter: quality ceiling reached — the revision could not improve on 2 of 4 dimensions after 2 attempts. Original letter preserved. To get a different result, add specific Edit notes (e.g., 'rewrite paragraph 3 to strengthen the [X] angle') and re-run."

**If it is stronger:** proceed to Step E7.3.

**Step E7.3 — Gatekeeper (cover letter check — initial)**

Spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter (read from `$PIPE/letter-draft.md`), the structured JD (including the Company self-characterization section), the user's Why I Want This Role content (retrieved in Step E7 from Notion). Also pass the final CV text for this role (required for the CV-repetition check); if no CV exists for this role, state that explicitly so the gatekeeper reports the skipped check by name.

**If PASS:** proceed to Step E7.4.

**If FAIL — round 1:** spawn `letter-writer` with `option=revision`, passing the cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Log all violation rounds internally.

**If FAIL — round 2+ (advisory violations only, no hard fails):** treat as PASS. Log the advisory violations under `## Gatekeeper — Advisory Violations Deferred to Humanizer (Step E7.3)` in the revision log, and proceed to Step E7.4. The humanizer handles residual advisory issues.

**If FAIL — round 2+ (hard fails present):** loop as above. Hard fails block every round.

**Cap: 3 revision passes on hard fails.** After the third hard-fail FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Then proceed to Step E7.4.

**Step E7.4 — Coach strategic letter review**

Spawn `career-coach` with `option=letter-review`, passing:
- `CAREER_DATA=${CAREER_DATA}`
- The cover letter path `$PIPE/letter-draft.md` to read
- `Role summary`, `Strategy`, `Keywords` (from the coach properties verified in Step E1)
- Why I Want This Role content (from the Step E7 Notion payload) — verbatim, not summarized
- Company name and role title
- `OUTPUT_PATH=$PIPE/coach-letter-review.md`

The coach writes its diagnostic review to that file and returns: `COACH-LETTER-REVIEW: <n> issues → $PIPE/coach-letter-review.md`

**If issues identified:** spawn `letter-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `LETTER_PATH=$PIPE/letter-draft.md` (read and overwrite), the coach review path `$PIPE/coach-letter-review.md` as the revision brief, and `$PIPE/fix-log.md` (read and append). Locked-fixes instruction applies. After revision, spawn `gatekeeper` with `option=cover-letter` (new OUTPUT_PATH round, pass Why I Want This Role and final CV). **Cap: 1 coach-directed revision + 1 gatekeeper pass.** If gatekeeper returns hard fails after the revision, log the violations and flag for manual review — do not loop further. If gatekeeper returns advisory violations only (no hard fails), treat as PASS and proceed — the humanizer handles residual advisory issues.

**If no issues identified:** proceed directly to Step E7.7.

**Step E7.7 — Gatekeeper (cover letter check — final)**

Spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the final cover letter text, the structured JD, the user's Why I Want This Role content, and the final CV text (same as Step E7.3).

**If PASS:** proceed to Step E8 (humanizer).

**If FAIL — advisory violations only (no hard fails):** treat as PASS. Log the advisory violations under `## Gatekeeper — Advisory Violations Deferred to Humanizer (Step E7.7)` in the revision log, and proceed to Step E8. The humanizer handles residual advisory issues.

**If FAIL — hard fails present:** spawn `letter-writer` with `option=revision`, passing the final cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Cap: 3 revision passes on hard fails. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

---

**Step E8 — Humanizer (cover letter)**

Spawn `cover-letter-humanizer`, passing `CAREER_DATA=${CAREER_DATA}` and the final cover letter markdown path (it edits in place). Do not pass the structured JD, Role summary, strategy, or any role-specific context — the humanizer reads only the letter and calibrates against the delivered-letters archive and voice fingerprint in career-data.

The humanizer removes AI writing patterns sentence by sentence. It does not change structure, strategy, or content — only language. Wait for it to return the corrected letter and its change log.

Before overwriting, copy the current (E7.7-passing) markdown to a sibling file with the suffix `.prehumanizer.md` — this is the revert target for E8.5. Then save the humanizer's output, overwriting the previous cover letter markdown. The change log goes into the revision log under `## Humanizer changes`. If the humanizer fails, proceed with the pre-humanizer version (which already passed E7.7).

**Step E8.5 — Final verification on the exported bytes**

The humanizer changed the text after the last PASS, so that PASS is no longer valid. On the exact saved markdown that E9 will convert: (1) run the mechanical pre-export checklist — company name in first body paragraph (stealth roles: JD descriptor suffices), role title in body, zero em dashes and zero colons in body text (ignoring pandoc `:::` fences and `{custom-style=...}` attributes), zero hits for "I know this", "that's where", "that's what", "that's the kind", "that exact", "exactly that", "this same", "serves as", "stands as", "acts as"; also grep "the same" — a hit fails only when it points at an agent-coined abstraction ("the same engine"), not in benign uses ("the same week"); (2) spawn `gatekeeper` with `option=cover-letter` on this exact text, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter path, `Role summary`, the user's Why I Want This Role content, and the final CV path (same as Step E7.3). If either fails: re-spawn the humanizer (language issues) or letter-writer with `option=revision` (content issues) and re-run this step. Cap: 2 rounds; after the cap, revert to the `.prehumanizer.md` file saved in E8 (the last E7.7-passing text) and flag for manual review. Never export text that has not passed this step.

---

**Step E9 — Produce DOCX**

Follow the same pandoc production protocol as the main pipeline. See `career-engine-export` for the full protocol.

Derive `<company_dir>` from the Company name using the naming convention in `career-engine-export`. Convert using the original run folder as the temporary landing pad: write the final CV markdown and cover letter markdown to `/tmp/`, convert with pandoc using the `.dotx` reference templates, update the CV Subtitle, and copy both files to `<output_dir>/<company_dir>/`. If a file with the same name already exists, overwrite it — this is an edit, not a new file.

Verify the produced file(s) exist and are nonzero before proceeding to Step E9.5. (Only the file(s) for the active Edit type are produced here — the unedited companion file is handled in E9.5.)

**Step E9.5 — Move edited DOCXs to today's dated folder**

Regardless of what was edited (CV only, letter only, or both), move **both** DOCX files — CV and cover letter — from the original run folder to a new folder named with today's edit date. This keeps the original run folder clean and makes it immediately obvious which files are the most recently edited versions.

**The unedited file must travel too.** Step E9 only produces the file(s) for the active edit type — the other file was not re-converted. Before moving, locate the unedited file in the original run folder (`<output_dir>/<company_dir>/`):
- Edit type `CV`: locate the existing cover letter DOCX by filename (`Letter File Name` Notion property → state.json `cover_letter_path` → `coverletter-*` glob in the company subdirectory). It must move alongside the freshly produced CV.
- Edit type `Letter`: locate the existing CV DOCX (`CV File Name` → state.json `cv_path` → `cv-*` glob). It must move alongside the freshly produced cover letter.
- Edit type `Both`: both files were produced by E9; no special handling needed.

If the unedited file cannot be located, log the missing file and move what is available — do not block the move of the edited file.

```
$EDIT_DIR = $OUTPUT_FOLDER/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD-today>/<company_dir>/
```

Create `$EDIT_DIR` if it does not exist.

**Path A (direct Bash):**
```bash
mkdir -p "$EDIT_DIR"
# Move CV DOCX if it exists
CV_DOCX="<output_dir>/<company_dir>/<cv-filename>.docx"
[ -f "$CV_DOCX" ] && mv "$CV_DOCX" "$EDIT_DIR/"

# Move cover letter DOCX if it exists
CL_DOCX="<output_dir>/<company_dir>/<coverletter-filename>.docx"
[ -f "$CL_DOCX" ] && mv "$CL_DOCX" "$EDIT_DIR/"
```

**Path B (host-bridge MCP):** Use the host filesystem tool's move/rename capability for each file.

**If today's folder is the same as the original run folder** (i.e., the original pipeline ran today): skip the move — the files are already in the right place. Set `$EDIT_DIR = <output_dir>/<company_dir>/` and proceed.

**After the move, patch the original `state.json`:** Open the state.json in the original run folder, find the entry for this role's `notion_page_id`, and update `cv_path` and `cover_letter_path` to the new paths under `$EDIT_DIR`. Leave all other fields untouched. This ensures a future edit run finds the files immediately rather than falling back to pattern-search.

Non-blocking: if the move or patch fails, log the failure and continue — the files remain in the original folder and the pipeline proceeds.

**`$PIPE` cleanup:** After the move, remove the `_pipeline/` scratch directory — but **only if Hebrew localization (Step E9H) is not running for this role** (i.e., `Languages` is empty or does not include `Hebrew`). If Hebrew localization will run, delay `$PIPE` cleanup until after Step E9H completes. Cleanup: Path A: `rm -rf "$PIPE"`; Path B: host file tool delete. Non-blocking — log and continue if removal fails. The output folder after cleanup contains only the moved DOCXs (in `$EDIT_DIR`) and the unchanged originals (state.json, feedback.md, revision logs).

**Step E9H — Additional language localization (conditional)**

**Language resolution rule:** If the `Languages` property from Step E0 is **empty or not set**, produce output in `$DEFAULT_LANGUAGE` only — skip this step entirely and proceed to Step E10. If `Languages` is populated, handle all listed languages beyond the default here.

**Hebrew localization — runs only if `Languages` explicitly includes `Hebrew`.** If `Hebrew` is not listed, skip even if other non-default languages are listed. If `Hebrew` is not present, skip this step entirely and proceed to Step E10. **After Step E9H completes (or is skipped), run the `$PIPE` cleanup described in Step E9.5 if it was deferred.**

Spawn `localization` with:
- `CAREER_DATA=${CAREER_DATA}`
- The final English CV markdown — for Edit type `Both`, the final revised CV from Step E5 (in memory); for Edit type `Letter`, extract from the existing CV DOCX (`CV File Name` → state.json `cv_path` → `cv-*` glob) via `pandoc "<cv-file>.docx" -t plain`
- The final English cover letter markdown (read from `$PIPE/letter-draft.md`)
- The structured JD from Step E0.5
- The exact role title from the JD

The agent returns a Hebrew CV markdown block and a Hebrew cover letter markdown block.

Write to `/tmp/` and convert:

```bash
cat > /tmp/he-<cv_filename>.md << 'MARKDOWN_EOF'
<Hebrew CV markdown from agent>
MARKDOWN_EOF

cat > /tmp/he-<cl_filename>.md << 'MARKDOWN_EOF'
<Hebrew cover letter markdown from agent>
MARKDOWN_EOF

HE_TEMPLATES="{{WORD_TEMPLATES_PATH}}"

# Hebrew CV — concatenate with Hebrew footer, then convert
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${HE_TEMPLATES}/cvHe.dotx" \
  -o "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"

python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx"

ls -lh "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
ls -lh "<output_dir>/<company_dir>/he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
```

If a Hebrew file with the same name already exists, overwrite it — this is an edit.

After conversion, move the Hebrew DOCX files to `$EDIT_DIR` (same destination as the English files in Step E9.5) using the same Path A/B logic. Non-blocking if the move fails.

**Step E10 — Notion writeback and state update**

1. Confirm both English DOCX files are saved in `$EDIT_DIR` (set in Step E9.5 — today's dated folder, or the original folder if today's run date matches).
2. Write the Draft Directory URL to the `Draft Directory` URL property on the Notion row, using the edit-date folder (today's date, from `$EDIT_DIR`):
   ```
   Draft Directory: $DRAFT_DIR_URL_BASE<today-date-folder>%2F<company_dir>%2F
   ```
   Use `$DRAFT_DIR_URL_BASE` — the value resolved from `pipeline-preferences.json` in Step E0-pre. If `$DRAFT_DIR_URL_BASE` is empty or `skip`, omit this property from the writeback entirely. Do not write an empty string or the literal word "skip" to the Notion property. If omitted, include a named note in the final chat delivery: "Draft Directory not written for [Company] — `draft_dir_url_base` not configured or empty. Run `/career-engine:setup --phase 5` to configure it."
   This always reflects where the DOCX files actually are after Step E9.5. Hebrew files (if produced in Step E9H) move to the same `$EDIT_DIR` — no separate Hebrew property writes needed.
3. Update Status from `Needs editing` to `CV Ready for Review`.
4. Append this role to the editing run's `state.json` (see State file section below) with `status: "completed"`.

Do not overwrite coach-owned properties here — those are set during intake and verified (read-only) in Step E1.

Do not write anything to the `Note` field unless the agent has genuinely additional context that the structured properties cannot carry.

**Step E10.5 — Why I Want This Role promotion prompt + WIWTR-UNLOGGED role facts**

Runs for every role in the run. This step is mechanical and must never block delivery: if it fails, log the failure and continue.

Write a file named `update-prompt-<company>-<monYYYY>.md` into the role's company subdirectory in the output folder. The file uses the structure defined in `skills/career-engine-new-application/SKILL.md` Step 7f. If the file already exists (generated by the new-application run), **append** the new sections rather than overwriting.

**Section 1 — Why I Want This Role promotion (if the field is populated):** Copy the fixed context block verbatim and fill in the variable content block with this role's Why I Want This Role content, company, role title, and date.

**Section 2 — WIWTR-UNLOGGED role facts (always check):** Collect every item the gatekeeper flagged as `[WIWTR-UNLOGGED]` during this run (from E7.3, E7.7, and E8.5 violation reports). For each item, append the following section to the update-prompt file:

```
## Role facts needing verification (WIWTR-UNLOGGED — from [Company] [Run Date])

The following claims appeared in your Why I Want This Role and were used in the letter,
but are not yet documented in `02-professional-background.md`. They are NOT fabrications —
they are your own first-person record. To make them available to future pipeline runs
without re-triggering this advisory, add them to Section 7 (Role Facts) for the relevant
role, pending your verification that the facts are accurate.

For each item below: if accurate, add it as a role fact to §7 under the relevant employer.
If not accurate, remove it from your Why I Want This Role before the next run.

[For each WIWTR-UNLOGGED item, one line:]
- **[Employer]** — "[verbatim claim from WIWTR]" *(flagged in [step] — not in 02-professional-background.md)*
```

If no [WIWTR-UNLOGGED] items were found in this run, omit Section 2 entirely.

Log in the final delivery per role: "Update prompt written/appended to `<company_dir>/update-prompt-<company>-<monYYYY>.md` — paste into Chat or Code (do both if you use both environments)" or "No Why I Want This Role content and no WIWTR-UNLOGGED items — skipped."


## State file (crash-recovery resilience)

After each role completes, append its data to the state.json in the role's run folder (identified in Preflight step 1). For new runs where the run folder is today's date, this is:
`{{OUTPUT_FOLDER}}/applications-<YYYY-MM-DD>/state.json`

Use the same format as the main pipeline (see career-engine-new-application Step 7b). The `session_date` field must reflect today's date.

**Purpose:** state.json is crash recovery only. If this editing pipeline is interrupted mid-run, the orchestrator can resume by checking state.json and skipping roles already marked `completed`. It is not a record of prior editing runs.

**At the start of an editing run:** check for a `state.json` in today's run folder. If one exists with today's `session_date`, skip any roles already marked `completed` — those were processed before the crash. If the `session_date` is from a prior day, ignore the file and process all `Needs editing` roles from scratch.

**`Needs editing` always takes precedence over state.json.** A role's Notion Status is the source of truth for what mode to run. If a role is marked `Needs editing`, it runs the editing pipeline using the Notion entry as source material — even if it also appears in state.json from an earlier session.

## Final chat delivery

Same format as the main pipeline:
- Named list of any roles that failed (company, title, failure step, reason)
- Any properties the coach updated and why (brief)
- Single confirmation line if nothing notable to report: "All N roles edited. Files updated in the output folder and Notion rows updated."

## Hard rules

- **No orchestrator-authored content.** Document text comes only from cv-writer, letter-writer, and the humanizer. The orchestrator never composes sentences, merges drafts, or assembles a final document from parts — writer regression is handled by re-spawning with the fix log, per the orchestrator's Absolute Constraints.

- **Agents are improving existing work, not starting from scratch.** Every agent in this pipeline receives the existing outputs as context. The instruction "improve what exists" must be explicit in every sub-agent spawn.
- **Coach properties are the anchor.** The cv-writer, reviewers, and other agents take the coach's verified properties as given. They do not reinterpret strategic positioning.
- **Property discipline.** Each property is written once, by its owner. Do not duplicate content across fields. The `Note` field is the user's space.
- **Fabrication rule is absolute.** See 01-writing-rules.md. Editing does not license invention.
- **Status update is the final step.** Only update Status to `CV Ready for Review` after the DOCX export and Notion writeback are confirmed complete.
- **Do not pause mid-run. This is an Absolute Constraint.** Process all roles in the selected queue automatically without stopping to ask the user about scope, workload, priorities, or session length. Mid-run observations (fabrication catches, data gaps, file issues) go into the final report — never into a blocking question. The only permitted stops are a hard failure (output folder unreachable, zero roles after skipping) and the end-of-run summary.

- **Reviewer spawns are never skipped. This is an Absolute Constraint.** Steps E4 (recruiter review) and E7.4 (coach strategic letter review) run for every role, every time, regardless of edit scope, prior review history, or inferred task description. The only valid exception is an explicit per-session user instruction to skip them — "fabrication-only edit" or "these were already reviewed" are not grounds for skipping.
