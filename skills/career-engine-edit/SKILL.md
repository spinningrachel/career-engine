---
name: career-engine-edit
description: Editing pipeline for the career-engine plugin. Triggers when {{USER_FIRST_NAME}} says "edit CVs", "run CV edits", "process the Needs editing queue", or any similar phrase. Retrieves all Job Applications rows with Status = Needs editing, runs the employment coach first to verify and update its owned properties, then routes each role through the appropriate pipeline agents to improve existing outputs — not to start from scratch. Agents in this pipeline are explicitly informed they are refining existing work, not generating from zero.
---

# New Application — Editing Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill handles the editing pipeline for roles {{USER_FIRST_NAME}} has flagged as needing revision. It runs separately from the main pipeline and is triggered by Status = `Needs editing` in the Job Applications database.

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

**Both paths fail → stop the run immediately** and report to {{USER_FIRST_NAME}}: the run needs either the output folder connected to the session or a host filesystem tool (e.g. Desktop Commander) enabled.

**The no-scratchpad rule applies on both paths.** Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support". If host access is lost mid-run, retry once; if still unreachable, deliver the remaining file contents in chat flagged for manual save and log the failure — never write to a substitute location.

Then confirm:
1. Output folder for each role is the run folder from the original run date. **How to identify it:** search for `state.json` files across all run folders under the output root — check both `applications-<YYYY-MM-DD>/` (current naming) and `cv-campaign-YYYY-MM-DD/` (legacy naming used by earlier pipeline runs). For each state.json found, look for an entry matching this role's `notion_page_id`. The run folder is the directory containing that state.json. If no state.json entry exists for this role (e.g., it was added to Notion after the original run), use today's date as the run folder (`applications-<YYYY-MM-DD>/`) and create it if needed.
2. File format is DOCX — same as the main pipeline.
3. `career-engine-export` skill is loaded.
4. All career-engine skills are loaded, including 01-writing-rules.md.

## Step E0-pre — Resolve per-install config (R-38)

The edit pipeline is its own entry (no orchestrator), so resolve config yourself. After the `career-data` discovery, read `${CAREER_DATA}/references/pipeline-preferences.json` and set `$NOTION_DATABASE_ID` and `$NOTION_NEEDS_EDITING_VIEW_URL` (used by the queries below) plus `$OUTPUT_FOLDER` and `$CV_TEMPLATE` (for export). Wherever this skill shows `{{NOTION_DATABASE_ID}}` or `{{NOTION_NEEDS_EDITING_VIEW_URL}}`, use the resolved values. Stop if `notion_database_id`, `output_folder`, or `cv_template` is missing: "career-data is missing a required config key — run `/career-engine:setup --phase 5`." The plugin keeps these placeholders literal (single build).

## Step E0 — Fetch roles for editing

**Guard — resolve the database ID from the career-data config (R-38).** The plugin keeps `{{NOTION_DATABASE_ID}}` literal by design — do not treat the literal placeholder as unconfigured. Use `$NOTION_DATABASE_ID` resolved in Step E0-pre from the career-data config. **Stop only if that config value is missing or empty**, and tell the user:

> "Your career-data config has no `notion_database_id`. Run `/career-engine:setup --phase 5` to add it."

---

**Path A1 — `ntn` CLI (preferred where available).** If the gate passes (`command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1`), query directly instead of the A2/B routes below (resolve the data source ID from `{{NOTION_DATABASE_ID}}` via `ntn api /v1/databases/{{NOTION_DATABASE_ID}}` → `data_sources[0].id`):

```bash
ntn datasources query <data-source-id> \
  --filter '{"property":"Status","status":{"equals":"Needs editing"}}' \
  --limit 100 --json
```

Trim the JSON in the shell to page `id` plus the named properties E0 needs; for the full per-role payload, `ntn pages get <page_id>` returns all properties plus the page body as markdown in one call. The pre-built view exists to serve the connector route — on A1, the direct Status filter is the sanctioned equivalent. If the gate fails or any A1 call errors, fall through to Path A2 (then Path B) below without comment (intake Step 0b documents the full ladder and syntax).

**Path A2 — `notionApi` structured query.** If A1 is unavailable, load the schema (`ToolSearch query="select:notionApi__API-query-data-source"`, or call `mcp__notionApi__API-query-data-source` directly). A tool-not-found error means the server is not connected — fall through to Path B; on any other error (401, timeout, malformed response) treat it as unusable and also fall through. Otherwise call `API-query-data-source` with database ID `{{NOTION_DATABASE_ID}}`, filter `{"property":"Status","status":{"equals":"Needs editing"}}`, page_size 100. It returns structured JSON keyed by property name.

**Path B — standard connector view query (discovery only).** `notion-query-database-view` runs a *view's own saved filter* — it takes no ad-hoc `filter` argument (any filter you pass is ignored) and needs a real view URL (`...?v=<VIEW_ID>`), never the bare database URL (R-39). Query the Job Applications database using the pre-built "Needs Editing" view:

```
View URL: {{NOTION_NEEDS_EDITING_VIEW_URL}}
```

This view is pre-configured to return only rows with `Status = Needs editing`. Call `notion-query-database-view` with this `view_url` and no other arguments — do not construct your own filter (the A1/A2 direct filters above are the only sanctioned filtered routes). The view URL is a fast path; if it is empty, fails, or is stale (view deleted or reorganised), resolve it by name instead: fetch the database page with `notion-fetch id="{{NOTION_DATABASE_ID}}"`, find the view named "Needs Editing" in the `Views` list, and use that URL.

**The view result is for discovery only (R-1).** `notion-query-database-view` returns a rendered table that is susceptible to column misalignment and shows only the view's visible columns — never enough for the full row payload below. Extract only the page IDs/links from the result (unambiguous even in a misaligned table), then call `notion-fetch id="<page_id>"` on each page and read the full payload from the structured page response. Never read property values out of the rendered table.

For each page fetched, capture the full row payload including:
- Page ID
- Company name
- Position title
- Job URL
- `Edit type` — required; options: `CV`, `Letter`, `Both`
- Pipeline (New Applications — from {{USER_FIRST_NAME}}'s chat command)
- All existing property values — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Why I Want This Role`, `CV File Name`, `Letter File Name` (note: these two file-name properties may be absent from the schema — that is not an error; see the run-folder convention below), `Note`, and any other populated fields
- Any reviewer feedback or notes already on the row

**Edit type is mandatory. It controls everything.** After fetching, immediately inspect the `Edit type` value for every role before any other work begins — before spawning the coach, before loading JDs, before any pipeline step.

- **`Edit type` is empty or not one of `CV`, `Letter`, `Both`:** do not proceed with this role under any circumstances. Do not default to `Both`. Log the skip: "[Company] — [Role Title]: skipped — Edit type not set. Add CV, Letter, or Both to the Edit type field in Notion." No subagent is spawned for this role.
- **`Edit type` is `CV`, `Letter`, or `Both`:** proceed with that role using the routing below.

Report the count to {{USER_FIRST_NAME}}: "Found N roles marked Needs editing (M skipped — Edit type missing)." If the count after skipping is 0, **stop immediately and report that.** Do not continue the pipeline.

**Routing by Edit type — hard gate, checked again before each subagent spawn:**
- `CV` — run CV editing steps only (E0.7 content check, E3–E6.5, CV DOCX export). Skip ALL cover letter steps. Do not spawn letter-writer, do not run cover letter gatekeeper.
- `Letter` — run cover letter editing steps only (E0.7 cover letter check, E7–E7.5, cover letter DOCX export). Skip ALL CV steps. Do not spawn cv-writer, do not run CV gatekeeper.
- `Both` — run all steps.

## Step E0.5 — Prepare JD content from Notion rows

For each role fetched in Step E0, extract the structured JD from the row payload. The `JD Body` property was already captured in Step E0 as part of the full row payload.

For each role:
1. **`JD Body` is populated** — mark `content-exists`. Use this as the structured JD for all downstream steps (coach, gatekeeper, cv-writer, letter-writer). Do not re-fetch from the Job URL.
2. **`JD Body` is empty** — mark `needs-fetch`. The employment coach (Step E1) will attempt to fetch the JD from the Job URL as part of its pre-flight. If the coach cannot access the URL, **hard-drop this role from the editing queue immediately**: log "Dropped — JD unavailable: [Company] — [Role Title]: URL unreachable and JD Body empty. Paste the JD into Notion before re-running edit." Remove from all subsequent steps (E0.7 onward). Do not proceed with a role that has no JD.

Hold all structured JD data in memory. All subsequent steps that reference "the structured JD from Step E0.5" draw from here.

## Step E0.7 — Baseline check

Run the gatekeeper on all existing outputs in parallel. The goal is a complete picture of what's already broken before any editing begins. All violation lists travel forward to the coach (E1) and cv-writer (E3) as context.

The employment coach fetches JDs as part of Step E1 — no separate fetch step needed here.

**Needs-fetch roles — defer this step.** A role marked `needs-fetch` in E0.5 has no JD yet; the coach fetches it in Step E1. Do not run either check below for that role now — run its baseline check immediately after E1 confirms a JD. If E1 hard-drops the role (URL unreachable), no baseline check runs at all.

**Content check:** Run only if Edit type is `CV` or `Both`. Spawn `gatekeeper` with `option=content`, passing the existing CV text, the structured JD, and the role's `Keywords` property (from the Notion row — required for the ATS pre-check). Returns either PASS or a content violation list.

**Cover letter check:** Run only if Edit type is `Letter` or `Both`. Skip if no cover letter exists (`Letter File Name` empty or absent AND no letter found by the run-folder convention — if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*`). Spawn `gatekeeper` with `option=cover-letter`, passing the existing cover letter text and the structured JD. Returns either PASS or a cover letter violation list.

Run both in parallel. Collect results. Do not loop or fix anything yet — this step is diagnosis only.

## Step E1 — Employment coach verification

Spawn `employment-coach` with the full row data, the structured JD data for every role in the editing queue, and the baseline violation lists from Step E0.7 as additional context.

The coach's job in this pipeline is verification and refinement — not a fresh start. For each role:

1. **Review the existing coach-owned properties** (`Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`) already on the Notion row. Assess whether they are accurate, complete, and well-calibrated given the full JD data and {{USER_FIRST_NAME}}'s documented background.

2. **If a property is correct:** keep it. Do not rewrite it for the sake of rewriting.

3. **If a property needs correction or improvement:** return the updated value with a one-sentence note explaining what changed and why.

4. **For `Gap handling` specifically:** if {{USER_FIRST_NAME}} has edited this in Notion, treat her version as authoritative and do not overwrite it. If it was set by a prior coach run and is still accurate, carry it forward. If it needs correction given the current JD, return an updated value with a one-sentence explanation.

5. **Return writing guidance** for the editing run — the same batch analysis, base CV recommendation, and per-role focus format as the main pipeline. This guidance informs how the cv-writer approaches the revision.

The coach does not re-score priorities or rebuild the queue in the editing pipeline. All roles in the editing queue are processed.

## Step E2 — Coach property writeback

Write any updated coach-owned properties back to the matching Notion rows using `notion-update-page`. Only overwrite properties the coach flagged as needing correction. Do not overwrite properties the coach confirmed as correct.

Confirm in chat: "Coach verification complete: K properties updated across N roles." Then proceed.

## Per-role editing pipeline

Process roles sequentially. For each role, branch on the pipeline {{USER_FIRST_NAME}} specified in chat (same logic as the main pipeline).

### Pipeline `New Applications`

Agents in this track are explicitly informed they are improving existing work. Pass each agent:
- The structured JD from Step E0.5
- The existing CV text from the Notion row or the existing DOCX (whichever is available)
- The existing cover letter text (retrieved from the output run folder using the filename in `Letter File Name`; if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*` — extract text using `pandoc "<output_dir>/<letter-filename>.docx" -t plain` or read the `.md` sibling)
- The verified coach properties from Step E1
- Any reviewer feedback or notes already on the row

**Step E3 — CV writer (revision mode)**

Spawn `cv-writer` with `option=revision`. Pass:
- The existing CV text as the draft (from the saved markdown backup at the output path, or extracted using `pandoc "<cv>.docx" -t markdown` if only the DOCX is available)
- The coach's verified properties as the strategic anchor
- The baseline content violation list from Step E0.7 (so the cv-writer addresses pre-existing violations immediately, not after another loop)
- Any recruiter or hiring manager feedback already on the row from the original pipeline run

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

Spawn `gatekeeper` with `option=content`, passing the revised CV text, the structured JD from Step E0.5, and the role's `Keywords` property (from the coach's verified output in Step E1 — required for the ATS pre-check).

**If PASS:** proceed to Step E4.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the revised CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Do not surface this loop to {{USER_FIRST_NAME}}. Log all violation rounds internally.

**Step E4 — Recruiter review**

Spawn `recruiter-reviewer` with the structured JD and the revised CV. It returns tiered feedback on the revision. The reviewer is aware this is a revision, not a first draft.

**Step E5 — Hiring manager review**

Spawn `hiring-manager-reviewer` with the structured JD and the revised CV. It returns structured feedback on the revision.

**Step E6 — CV writer (final revision)**

Spawn `cv-writer` with `option=revision`, passing the revised CV from Step E3, the recruiter feedback from Step E4, and the hiring manager feedback from Step E5. Returns the final CV and revision log.

**Step E6.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=content`, passing the final revised CV text, the structured JD, and the role's `Keywords` property.

**If PASS:** proceed to Step E7.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the final CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

**Step E7 — Cover letter (initial revision)**

**Gate — Why I Want This Role is mandatory for the letter track.** Check the `Why I Want This Role` value from the Step E0 row payload before spawning anything. If it is empty: do NOT spawn letter-writer — its Intake Gate refuses to write without this content, and that refusal has no recovery path inside this pipeline. Instead: for Edit type `Both`, skip Steps E7–E8 and continue with the CV track only; for Edit type `Letter`, skip the role entirely. In both cases log and surface: "Letter edit skipped for [Company] — [Role Title]: the Why I Want This Role field in Notion is empty. Fill it in and re-run edit for this role."

**Before spawning letter-writer:** Read the following from the Notion row payload collected in Step E0 (all are part of the full row payload already in memory):
- **`Why I Want This Role` property** — {{USER_FIRST_NAME}}'s written motivation for this role; passes the gate above, so it is populated. Include the full content.

Spawn `letter-writer` with `option=revision`. Pass:
- The existing cover letter (from the output run folder using the filename in `Letter File Name`; if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*`)
- The baseline cover letter violation list from Step E0.7
- The verified coach properties from Step E1, including `Gap handling`
- The final CV (for context)
- **`Why I Want This Role`** content: if populated, include it as the primary personal content input.

The letter-writer improves the existing letter — it does not start from scratch unless the strategic positioning changed significantly in Step E1.

The cover letter is written to the DOCX file only. Do not write cover letter text to any Notion property.

**Step E7.25 — Cover letter quality comparison gate**

Before passing the revised cover letter to the gatekeeper, compare the old and new versions on four dimensions:

1. **Opening strength** — does it pull the reader in immediately, or start with a generic frame?
2. **Specificity** — does it name concrete things about this company, this role, or this intersection of {{USER_FIRST_NAME}}'s background?
3. **Voice naturalness** — does it sound like a person talking, or like assembled copy?
4. **Closing force** — does it end with a reason to respond, or trail off?

**The new letter must be stronger than the old on at least 2 of these 4 dimensions.**

**If it is not:** Return to `letter-writer` with `option=revision`, quoting the old letter's strongest lines verbatim and instructing: "The revision is not better. The original was stronger in [specific dimension]. Here are the lines that worked best in the original: [quoted lines]. Write a new letter that preserves this strength while fixing the identified problems." Max 2 loops. If no improvement after 2 loops, flag in the final delivery: "[Role] — cover letter: no quality improvement achieved after 2 rounds; original preserved."

**If it is stronger:** proceed to Step E7.3.

**Step E7.3 — Gatekeeper (cover letter check — initial)**

Spawn `gatekeeper` with `option=cover-letter`, passing the cover letter text, the structured JD (including the Company self-characterization section), {{USER_FIRST_NAME}}'s Why I Want This Role content (retrieved in Step E7 from Notion). Also pass the final CV text for this role (required for the CV-repetition check); if no CV exists for this role, state that explicitly so the gatekeeper reports the skipped check by name.

**If PASS:** proceed to Step E7.4.

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally. Then proceed to Step E7.4.

**Step E7.4 — Recruiter review**

Spawn `recruiter-reviewer` with `option=cover-letter`, passing the revised cover letter and the structured JD. The reviewer is aware this is a revision, not a first draft — it returns tiered feedback on what is working, what is not, and what is missing given the JD.

**Step E7.5 — Hiring manager review**

Spawn `hiring-manager-reviewer` with `option=cover-letter`. Pass the revised cover letter, the structured JD, the final CV (for context), and the recruiter feedback from Step E7.4. Returns structured feedback. If the hiring manager returns a Conditional verdict, quote the condition verbatim in the Step E7.6 prompt.

**Step E7.6 — Letter-writer (final revision)**

Spawn `letter-writer` with `option=revision`. Pass:
- The revised cover letter from Step E7
- Recruiter feedback from Step E7.4
- Hiring manager feedback from Step E7.5 (including any Conditional condition verbatim)
- The gatekeeper violation list from Step E7.3 if any items were not fully resolved

Returns the final cover letter and a brief revision log (what changed and why, one line per change).

**Step E7.7 — Gatekeeper (cover letter check — final)**

Spawn `gatekeeper` with `option=cover-letter`, passing the final cover letter text, the structured JD, {{USER_FIRST_NAME}}'s Why I Want This Role content, and the final CV text (same as Step E7.3).

**If PASS:** proceed to Step E8 (humanizer).

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the final cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

---

**Step E8 — Humanizer (cover letter)**

Spawn `cover-letter-humanizer`, passing the final cover letter markdown and the structured JD.

The humanizer removes AI writing patterns sentence by sentence. It does not change structure, strategy, or content — only language. Wait for it to return the corrected letter and its change log.

Before overwriting, copy the current (E7.7-passing) markdown to a sibling file with the suffix `.prehumanizer.md` — this is the revert target for E8.5. Then save the humanizer's output, overwriting the previous cover letter markdown. The change log goes into the revision log under `## Humanizer changes`. If the humanizer fails, proceed with the pre-humanizer version (which already passed E7.7).

**Step E8.5 — Final verification on the exported bytes**

The humanizer changed the text after the last PASS, so that PASS is no longer valid. On the exact saved markdown that E9 will convert: (1) run the mechanical pre-export checklist — company name in first body paragraph (stealth roles: JD descriptor suffices), role title in body, zero em dashes and zero colons in body text (ignoring pandoc `:::` fences and `{custom-style=...}` attributes), zero hits for "I know this", "that's where", "that's what", "that's the kind", "that exact", "exactly that", "this same", "serves as", "stands as", "acts as"; also grep "the same" — a hit fails only when it points at an agent-coined abstraction ("the same engine"), not in benign uses ("the same week"); (2) spawn `gatekeeper` with `option=cover-letter` on this exact text. If either fails: re-spawn the humanizer (language issues) or letter-writer with `option=revision` (content issues) and re-run this step. Cap: 2 rounds; after the cap, revert to the `.prehumanizer.md` file saved in E8 (the last E7.7-passing text) and flag for manual review. Never export text that has not passed this step.

---

**Step E9 — Produce DOCX**

Follow the same pandoc production protocol as the main pipeline. See `career-engine-export` for the full protocol.

Derive `<company_dir>` from the Company name using the naming convention in `career-engine-export`. The output goes to `<output_dir>/<company_dir>/` — the same subdirectory the original run used. Create the subdirectory if it does not exist; it will already exist for roles that had a prior run.

Write the final CV markdown and cover letter markdown to `/tmp/`, convert with pandoc using the `.dotx` reference templates, update the CV Subtitle, and copy both files to `<output_dir>/<company_dir>/`. If a file with the same name already exists, overwrite it — this is an edit, not a new file.

Verify both files exist and are nonzero before proceeding to Step E9H.

**Step E9H — Hebrew localization (conditional)**

**Only runs if `Languages` includes `Hebrew`.** Check the `Languages` property on the Notion row fetched in Step E0. If `Hebrew` is not present, skip this step entirely and proceed to Step E10.

Spawn `localization` with:
- The final English CV markdown (from Step E6, in memory)
- The final English cover letter markdown (from Step E7.6, in memory)
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
  --reference-doc="${HE_TEMPLATES}/cvHe.dotm" \
  -o "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

ls -lh "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
ls -lh "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
```

If a Hebrew file with the same name already exists, overwrite it — this is an edit.

**Step E10 — Notion writeback and state update**

1. Confirm both English DOCX files are saved in `<output_dir>/<company_dir>/`.
2. Write the Draft Directory URL to the `Draft Directory` URL property on the Notion row:
   ```
   Draft Directory: {{DRAFT_DIR_URL_BASE}}<date-folder>%2F<company_dir>%2F
   ```
   Hebrew files (if produced in Step E9H) are in the same directory and are accessible via the same URL — no separate Hebrew property writes needed.
3. Update Status from `Needs editing` to `CV Ready for Review`.
4. Append this role to the editing run's `state.json` (see State file section below) with `status: "completed"`.

Do not overwrite coach-owned properties again here — those were already updated in Step E2.

Do not write anything to the `Note` field unless the agent has genuinely additional context that the structured properties cannot carry.

**Step E10.5 — Why I Want This Role promotion**

Runs for every role in the run whose `Why I Want This Role` field is populated — including roles where the letter track was skipped. This step is mechanical and must never block delivery: if it fails, log the failure and continue. Run the identical procedure defined in `skills/career-engine-new-application/SKILL.md` Step 7f: read `${CAREER_DATA}/references/02-professional-background.md` in full, identify content in the field that is new, append verbatim-quoted entries to Section 5 → "Promoted from Why I Want This Role" (append-only, never paraphrase, never infer) following the orchestrator's **Writing personal data** rule (Code direct / Cowork staged + Appendix-A; refresh backup), flag new Section 7-grade career facts for approval instead of writing them, and log "Promoted N new entries to the motivation bank" or "No new content to promote" per role in the final delivery.


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
- **Property discipline.** Each property is written once, by its owner. Do not duplicate content across fields. The `Note` field is {{USER_FIRST_NAME}}'s space.
- **Fabrication rule is absolute.** See 01-writing-rules.md. Editing does not license invention.
- **Status update is the final step.** Only update Status to `CV Ready for Review` after the DOCX export and Notion writeback are confirmed complete.
- **Do not pause mid-run.** Process all roles in the editing queue without stopping to ask {{USER_FIRST_NAME}} about scope.
