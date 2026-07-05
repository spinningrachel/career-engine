---
name: career-engine-edit
description: Editing pipeline for the career-engine plugin. Triggers when the user says "edit CVs", "run CV edits", "process the Needs editing queue", or any similar phrase. Retrieves all Job Applications rows with Status = Needs editing, runs the career coach first to verify and update its owned properties, then routes each role through the appropriate pipeline agents to improve existing outputs — not to start from scratch. Agents in this pipeline are explicitly informed they are refining existing work, not generating from zero.
---

# New Application — Editing Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill handles the editing pipeline for roles the user has flagged as needing revision. It runs separately from the main pipeline and is triggered by Status = `Needs editing` in the Job Applications database.

The key difference from the main pipeline: **agents are not starting from scratch.** Existing CV text, cover letter text, coach properties, and reviewer feedback are all in the Notion row. The goal is to improve what exists, informed by what is already documented there.

**`Needs editing` always means edit from the Notion entry.** Every role with Status = `Needs editing` uses whatever is already inside its Notion row as the starting point — existing CV text, cover letter, coach properties, reviewer notes. Nothing is discarded. This rule holds regardless of what state.json says. state.json is crash recovery only (see State file section below).

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

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
2. **Config keys — required hard-stop; everything else optional.** Read `pipeline-preferences.json`. **Required (stop if missing or empty):** `output_folder`, and — when a database backend is configured (`database_backend`; default `notion`) — `database_id`. Stop with: "career-data config is incomplete — run `/career-engine:setup --phase 5` to fill in: [required keys missing]." **All other keys are optional — never stop on them;** collect any absent (older config) or empty into `CONFIG_HEALTH` and emit the same end-of-run `⚙️ Config health` block the orchestrator defines. **Backward compatibility:** accept legacy `notion_database_id` (→ `database_id`), `notion_needs_editing_view_url` (→ `database_edit_view_url`), `location_compatibility.notion_property` (→ `database_property`); prefer the `database_*` names and flag any legacy name in `CONFIG_HEALTH`.
3. (Code sessions) If `~/.claude/skills/career-data/` is absent or differs from `${CAREER_DATA}`, warn: "career-data may be out of sync with the Desktop app — re-install the .skill file if you recently updated it in Chat. Continuing on the resolved path."

Then read `${CAREER_DATA}/references/pipeline-preferences.json` and set `$NOTION_DATABASE_ID` (← `database_id`, legacy `notion_database_id`), `$NOTION_NEEDS_EDITING_VIEW_URL` (← `database_edit_view_url`, legacy `notion_needs_editing_view_url`), `$NOTION_INTERESTED_VIEW_URL` (← `database_interested_view_url`), `$NOTION_HOLD_VIEW_URL` (← `database_hold_view_url`), `$NOTION_RESEARCHED_VIEW_URL` (← `database_researched_view_url`), `$NOTION_CV_READY_VIEW_URL` (← `database_cv_ready_view_url`), `$OUTPUT_FOLDER`, and `$DRAFT_DIR_URL_BASE` (used by the queries and exports below; the `$NOTION_*` var names are the Notion adapter's internal names and are unchanged). Wherever this skill shows `{{NOTION_DATABASE_ID}}` or `{{NOTION_NEEDS_EDITING_VIEW_URL}}`, use the resolved values. Stop if `database_id` or `output_folder` is missing: "career-data is missing a required config key — run `/career-engine:setup --phase 5`." Optional: `draft_dir_url_base` absent or `skip` → Draft Directory writeback is skipped (log it in the final delivery as "Draft Directory not written — `draft_dir_url_base` not configured"). The plugin keeps these placeholders literal (single build).

**Template resolution — fixed filenames, no config key (2026-07-04 fix).** `cv_template` and `word_templates_path` are no longer config keys. Set `$CV_TEMPLATE` = `${CAREER_DATA}/references/templates/cv.dotx`, `$CL_TEMPLATE` = `${CAREER_DATA}/references/templates/cover-letter-template.dotx`, `$CV_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/cvHe.dotm`, `$CL_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/he-letter.dotx` — always these fixed relative paths, never an external OS path, never a config lookup. `$CV_TEMPLATE`/`$CL_TEMPLATE` are required for any export used by this pipeline — if either file doesn't exist, stop with: "career-data is missing `references/templates/<filename>` — run `/career-engine:setup --phase 5` to restore the default templates." `$CV_TEMPLATE_HE`/`$CL_TEMPLATE_HE` are optional — if either is missing, Hebrew export for that document type is unavailable (collect into `CONFIG_HEALTH`).

## Step E0 — Fetch roles for editing

**Guard — resolve the database ID from the career-data config (R-38).** The plugin keeps `{{NOTION_DATABASE_ID}}` literal by design — do not treat the literal placeholder as unconfigured. Use `$NOTION_DATABASE_ID` resolved in Step E0-pre from the career-data config. **Stop only if that config value is missing or empty**, and tell the user:

> "Your career-data config has no `database_id` (or legacy `notion_database_id`). Run `/career-engine:setup --phase 5` to add it."

---

**Establish a run-scoped `$RUN_PIPE` before the fetch below** — mirrors the intake pipeline's Step 0a.5 pattern (`skills/career-engine-intake/SKILL.md`) and the orchestrator's Step O1 pattern (`orchestrator-queue.md`). This is distinct from the per-role `$PIPE` created later at Step E0.pipe — that one doesn't exist yet at this point. Set `$RUN_PIPE` = `$OUTPUT_FOLDER/_edit_pipeline/<run-timestamp>/` (timestamped so a concurrent or immediately-prior run never collides; `$OUTPUT_FOLDER` is already resolved from Step E0-pre). Create it via `mkdir -p` (Path A) or the host file tool (Path B, R-30). `_edit_pipeline/` is intermediate only — never a deliverable, never written to Notion; remove it once Step E0.5 has consumed its content into each role's per-role `$PIPE`.

**Query the Needs-Editing queue via the database adapter.** Following `${CLAUDE_PLUGIN_ROOT}/skills/database-notion/SKILL.md` (the Notion adapter; loaded when `database_backend` is `notion`) → **§2 read ladder**, query the queue for **`Status = Needs editing`** (A1 → A2 → B; falling down the ladder is sanctioned routing). For Path B, the configured edit view is the fast path — pass `{{NOTION_NEEDS_EDITING_VIEW_URL}}` (resolved from `database_edit_view_url`, legacy `notion_needs_editing_view_url`) as the `view_url`; if it is empty, stale, or fails, fall back to the adapter's **§3 view discovery** to resolve the "Needs Editing" view by name. **On Path B, the view-query call itself (§2 Path B steps 2–3) is delegated by the adapter — never run it directly in this pipeline's own context; see the adapter for the subagent contract.** A live traced run confirmed this call returning tens of thousands of raw characters of full property data directly into this pipeline's own context when run inline — the same context-exhaustion failure shape as an undelegated per-page fetch. This step is discovery only — page IDs, company, position, priority. Do not fetch full per-page properties here; that is the next paragraph's job, delegated.

**⛔ Delegate the per-page property fetch — do not run it directly in this pipeline's own context.** This mirrors the orchestrator's Step O1 fix and the intake pipeline's Step 0b fix for the identical failure mode: running several raw `notion-fetch` calls in this context and holding every result inline has caused premature context exhaustion in production. **Spawn a lightweight subagent** (general-purpose / Task tool), passing it: the list of page IDs from the view-discovery step above, and the full property list needed — Page ID, Company name, Position title, Job URL, `Edit type`, `Edit notes`, `JD Body`, `Role summary`, `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Why I Want This Role`, `CV File Name`, `Letter File Name` (if present), `Note`, `Priority`, and any other populated fields, plus any reviewer feedback or notes already on the row. Instruct it exactly: *"For each page ID, call `notion-fetch` and capture its full property set. Do this for all N pages. If a page's fetch fails or errors, do not stop — skip that page, continue with the rest, and add one line for it under a final `## FAILED` section naming the page ID and the error. Return your response as one block, using this exact format, one section per role: `## ROLE — <Company> — <Position>` followed by `**Page ID:** <id>` and then every property as a labeled line, plus the `## FAILED` section if any page errored. Return nothing else — no commentary, no partial returns per page."* The subagent returns text only — it does not write `$RUN_PIPE` itself (sandboxed subagents cannot reach the real filesystem). **If the returned block's `## FAILED` section lists any page:** log each by page ID in the run-level revision log and exclude that role from the queue, never silently.

**Receive that one returned block and write it to `$RUN_PIPE/needs-editing-role-properties.md` in a single `Write` call, then drop the returned text from working memory immediately.** The bulk of the property/JD text arrives as one bounded return and is flushed to disk in one action, rather than accumulating turn-by-turn across several raw inline `notion-fetch` results. If the page count is large enough that the subagent's own return risks being oversized (rough guide: more than ~8-10 roles), split the page-ID list across two or more subagent spawns and append each returned block to `$RUN_PIPE/needs-editing-role-properties.md` in turn — still never running the per-page fetches in this pipeline's own context. **If the subagent cannot access `notion-fetch`** (check its return — it will say so or return an empty/error result): fall back to running the per-page fetches directly here, but still write each result to `$RUN_PIPE/needs-editing-role-properties.md` before fetching the next page, and log in the revision log that the delegation didn't fire this run.

**Read `$RUN_PIPE/needs-editing-role-properties.md`** to obtain the full row payload for every role — never a rendered table, never held from an earlier in-memory fetch. (Step E0.5 below reads this same file again for its own JD-extraction pass — that is a separate, expected read, not a contradiction of anything said here.) If every rung of the read ladder failed instead, stop and report — never treat it as zero results, and never improvise `notion-search` to enumerate the queue (R-39).

**Edit type is mandatory. It controls everything.** After reading `$RUN_PIPE/needs-editing-role-properties.md`, immediately inspect the `Edit type` value for every role before any other work begins — before spawning the coach, before loading JDs, before any pipeline step.

- **`Edit type` is empty or not one of `CV`, `Letter`, `Both`:** do not proceed with this role under any circumstances. Do not default to `Both`. Log the skip: "[Company] — [Role Title]: skipped — Edit type not set. Add CV, Letter, or Both to the Edit type field in Notion." No subagent is spawned for this role.
- **`Edit type` is `CV`, `Letter`, or `Both`:** proceed with that role using the routing below.

Report the count to the user: "Found N roles marked Needs editing (M skipped — Edit type missing)." If the count after skipping is 0, **stop immediately and report that.** Do not continue the pipeline.

**Queue cap — maximum 5 roles per run.** If more than 5 roles remain after skipping, select the top 5 by Priority field: First > Second > Third > Fourth > Fifth. Ties at the same Priority level are broken randomly. Report which roles are deferred: "Deferring N roles — re-run edit to process them." Proceed only with the selected 5.

**Routing by Edit type — hard gate, checked again before each subagent spawn:**
- `CV` — run CV editing steps only (E0.7 content check, E3–E5.5, CV DOCX export). Skip ALL cover letter steps. Do not spawn letter-writer, do not run cover letter gatekeeper.
- `Letter` — run cover letter editing steps only (E0.7 cover letter check, E7–E8.5, cover letter DOCX export). Skip ALL CV steps. Do not spawn cv-writer, do not run CV gatekeeper.
- `Both` — run all steps.

## Step E0.5 — Prepare JD content from Notion rows

For each role fetched in Step E0, extract the structured JD from `$RUN_PIPE/needs-editing-role-properties.md` (read once here, not re-read per step). The `JD Body` property was already captured in Step E0 as part of the full row payload written to that file. After this step has extracted what each role needs into working memory, `$RUN_PIPE` may be cleaned up (Path A: `rm -rf`; Path B: host file tool delete — non-blocking if removal fails).

For each role:
1. **`JD Body` is populated** — mark `content-exists`. Use this as the structured JD for all downstream steps (coach, gatekeeper, cv-writer, letter-writer). Do not re-fetch from the Job URL.
2. **`JD Body` is empty** — attempt to fetch from the Job URL directly (use the rendering-capable extraction ladder from `career-engine-intake` Step 0.5). If the fetch succeeds, populate `JD Body` in memory and proceed. If the URL is unreachable and `JD Body` remains empty, **hard-drop this role from the editing queue**: log "Dropped — JD unavailable: [Company] — [Role Title]: URL unreachable and JD Body empty. Paste the JD into Notion before re-running edit." Remove from all subsequent steps (E0.7 onward). Do not proceed with a role that has no JD.

Hold all structured JD data in memory. All subsequent steps that reference "the structured JD from Step E0.5" draw from here.

## Step E0.7 — Baseline check

Run the gatekeeper on all existing outputs in parallel. The goal is a complete picture of what's already broken before any editing begins. All violation lists travel forward to the coach (E1) and cv-writer (E3) as context.

**Do not skip this step because the letter or CV will be substantially rewritten anyway.** A real production run skipped baseline checks for all 5 roles on that reasoning — the letters were all being rewritten from scratch, so the run judged the existing-content diagnostic as moot. That reasoning is wrong: the baseline violation list is what tells the writer *what specifically was broken* about the existing draft, which is signal for what NOT to reproduce in the rewrite, independent of how much surviving text there is. The only valid reasons to skip are the two named below (no JD, cover letter file not locatable) — "it's getting rewritten" is never one of them.

**Baseline runs only for roles with a JD.** If E0.5 hard-dropped a role (URL unreachable and `JD Body` empty), no baseline check runs for it at all. For every role whose `JD Body` is populated (from the row or fetched in E0.5), run the baseline check now.

**Content check:** Run only if Edit type is `CV` or `Both`. Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the existing CV text, `Role summary` (from the Step E0 row payload — the JD proxy the gatekeeper reads), the role's `Keywords` property (from the Notion row — required for the ATS pre-check), and `OUTPUT_PATH=$PIPE/gatekeeper-baseline-cv.md`. Per the gatekeeper's R-41 protocol, it returns either `PASS` or `FAIL: <n> violations → $PIPE/gatekeeper-baseline-cv.md` — read the file for the violation list, never expect it inline.

**Cover letter check:** Run only if Edit type is `Letter` or `Both`. Locate the existing cover letter in this order: `Letter File Name` from the Notion row → state.json `cover_letter_path` → run-folder pattern search (`coverletter-*` / `cv-*` in the company subdirectory) → Draft Directory company subdirectory. If the file cannot be located by any of these methods, skip the cover letter baseline check entirely and log: "Cover letter baseline check skipped for [Company] — file not locatable (no prior pipeline run or file moved)." Otherwise spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the existing cover letter text, `Role summary` (from the Step E0 row payload), and `OUTPUT_PATH=$PIPE/gatekeeper-baseline-cl.md`. Returns either `PASS` (or `PASS — cover letter [Tier 2: <n>%]`) or `FAIL: <n> violations → $PIPE/gatekeeper-baseline-cl.md` — read the file for the violation list, never expect it inline.

Run both in parallel. Collect results. Do not loop or fix anything yet — this step is diagnosis only.

## Step E1 — Coach properties gate

**The career coach is never spawned from the edit pipeline.** Coach properties are set during intake (Needs Research → Researched) and are expected to be present when the editing pipeline runs.

For each role in the editing queue, verify these **writer-needed fields** are populated (non-empty):
`Role summary`, `Role emphasis`, `Keywords`, `Strategy`.

`Role summary` is the **JD proxy** every downstream agent reads instead of the full JD body (see `skills/career-coach/SKILL.md` → `Role summary`). Steps E7.4 and E8.5 pass it to the gatekeeper and coach review "from the coach properties verified in Step E1" with **no fallback**, so it must be gated here — exactly as the orchestrator's O2 readiness gate does (`skills/career-engine-orchestrator/SKILL.md` Step O2). This list must stay in parity with O2's writer-needed fields. `JD proof` is not checked — it is reference-only. `Gap handling` is not required when `gap_handling_mode = disabled`.

- **All four fields present** → role is ready; carry its existing coach values forward.
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
- The baseline content violation file path `$PIPE/gatekeeper-baseline-cv.md` from Step E0.7, if it returned FAIL — the cv-writer reads it directly (so it addresses pre-existing violations immediately, not after another loop). Omit this line entirely if Step E0.7 returned PASS (no file was written).
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

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the revised CV text, `Role summary` (from the coach properties verified in Step E1 — the JD proxy the gatekeeper reads), and the role's `Keywords` property (from the coach properties verified in Step E1 — required for the ATS pre-check).

**If PASS:** proceed to Step E4.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, the revised CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Do not surface this loop to the user. Log all violation rounds internally.

**Step E4 — Recruiter review**

Spawn `recruiter-reviewer` with `CAREER_DATA=${CAREER_DATA}`, the structured JD, the revised CV, and `OUTPUT_PATH=$PIPE/recruiter-review.md`. The reviewer writes its full review to that file and returns only a 2-line status (R-41 protocol). The reviewer is aware this is a revision, not a first draft.

**Step E5 — CV writer (final revision)**

Read recruiter feedback from `$PIPE/recruiter-review.md`. Spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, the revised CV from Step E3, and the recruiter feedback. Returns the final CV and revision log.

**Step E5.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the final revised CV text, `Role summary` (from the coach properties verified in Step E1), and the role's `Keywords` property.

**If PASS:** proceed to Step E7.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, the final CV and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again. Repeat until PASS. Cap: 3 revision passes. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

**Step E6.8 — Voice calibration (resolve)**

Read `${CAREER_DATA}/references/voice-calibration-coverletters.md` directly — no agent spawn.

- **If it exists:** copy its content to `$PIPE/voice-calibration.md`. Proceed to Step E7.
- **If it does not exist** (new user, or the user has not yet applied the update-prompt that delivers it): this is not an error — do not hard-stop. Proceed to Step E7 without creating `$PIPE/voice-calibration.md`. The letter-writer and humanizer both fall back to their standalone Voice Gate / calibration protocol (read the delivered-letters archive directly, or `03-framework.md` §Voice and tone if the archive is also empty).

**Step E6.85 — Capability preflight (once per run)**

**Run this once, on the first role of the run — not per role.** Check whether this environment can resume a sub-agent instance across multiple spawns (the mechanism Step E7 and its revision loops rely on to keep talking to the same letter-writer, and now the same career-coach, across a role's revision rounds instead of hiring a fresh one every round). Cache the result as `$SENDMESSAGE_AVAILABLE` (true/false) for the rest of the run — do not re-check per role or per revision round.

- **If available:** every "resume" instruction below (letter-writer and career-coach) reuses the same cached instance across all touchpoints for that role.
- **If unavailable:** log it plainly, once — "this environment can't reuse sub-agents; every revision spawns a fresh writer/coach with full context instead" — and every "resume" instruction below falls back to a fresh spawn with full accumulated context, for the rest of the run, without rediscovering the same fact on every role.

**Step E6.9 — Coach pre-draft outline**

**Skip this entire step if Edit type = `CV`** — there is no letter track for this role, so there is nothing to outline. Only run this step for Edit type `Letter` or `Both`, matching the same gate every other letter-only step in this pipeline observes.

**Before spawning the letter-writer**, spawn `career-coach` with **Option 4a — Pre-Draft Outline** (the agent dispatches by this literal heading name — never a slug-style `option=` value, unlike the gatekeeper), passing:
- `CAREER_DATA=${CAREER_DATA}`
- `Role summary`, `Strategy`, `Keywords` (from the coach properties verified in Step E1)
- Why I Want This Role content (from the Step E0 row payload) — pass verbatim if populated, empty if not
- `Gap handling` (from the Step E1 coach properties)
- Company name and role title
- The user's `references/templates/cover_letter_templates.md` if present (career-data path); note its absence explicitly if not

The coach writes `$PIPE/template-selection.txt` and `$PIPE/coach-outline.md` and returns `COACH-OUTLINE: template=<selection> → $PIPE/template-selection.txt, outline written → $PIPE/coach-outline.md` (R-41).

**When `$SENDMESSAGE_AVAILABLE`: capture the returned agent ID** and write it to `$PIPE/coach-agent-id.txt` — this is the same coach instance resumed at Step E7.4's review below, so it remembers its own outline when checking whether the writer followed it. **When unavailable**, skip this capture — Step E7.4 spawns its own fresh coach instead, using the two `$PIPE` files above for continuity in place of instance memory.

Read `$PIPE/template-selection.txt` after this step — its value is threaded into the gatekeeper spawns at Steps E7.3 and E7.7 below as `Template selected=<value>`, for Gate 9.

**Step E7 — Cover letter (initial revision)**

**Gate — always run the letter track for `Letter`/`Both`; the letter-writer decides write-or-skip.** Why I Want This Role is **no longer required** to edit a letter. Spawn the letter-writer whether or not `Why I Want This Role` is populated (pass it if present, empty if not). The letter-writer's **Sufficiency Gate** decides: it revises from the Motivation Bank (its primary source) plus Why I Want This Role when present, or — if there is no Why I Want This Role content **and** no role-relevant Motivation Bank material — returns a skip. **If the letter-writer returns a skip:** for Edit type `Both`, continue with the CV track only; for `Letter`, skip the role. Log and surface the writer's message (it tells the user to add Why I Want This Role or enrich the Motivation Bank). **Do NOT pre-skip on an empty Why I Want This Role** — that decision belongs to the letter-writer now.

**Before spawning letter-writer:** Read the following from the Notion row payload collected in Step E0 (all are part of the full row payload already in memory):
- **`Why I Want This Role` property** — the user's role-specific motivation; include the full content **if populated** (the letter-writer's primary source is the Motivation Bank, loaded from career-data). If empty, pass it empty — the Sufficiency Gate decides.

Spawn `letter-writer` with `option=revision`. Pass:
- `CAREER_DATA=${CAREER_DATA}`
- The existing cover letter (from the output run folder using the filename in `Letter File Name`; if the property is absent from the schema or empty, locate the file via the run-folder convention instead: state.json `cover_letter_path`/`cv_path`, or the Draft Directory company subdirectory with filename patterns `coverletter-*`/`cv-*`)
- The baseline cover letter violation file path `$PIPE/gatekeeper-baseline-cl.md` from Step E0.7, if it returned FAIL — the letter-writer reads it directly. Omit this line entirely if Step E0.7 returned PASS (no file was written).
- From the coach properties verified in Step E1: `Strategy`, `Keywords`, `Gap handling` — **do NOT pass `Role emphasis`** to the letter-writer
- **The CV (always required — for context).** If Edit type is `Both`, use the final revised CV from Steps E3–E5 (already at `$PIPE/cv-final.md`). If Edit type is `Letter`, read the existing CV from the output run folder using the filename in `CV File Name` from the Notion row (fallback: state.json `cv_path`, or the Draft Directory company subdirectory with filename pattern `cv-*`). Extract text via `pandoc "<cv-file>.docx" -t plain` and **write the extracted markdown to `$PIPE/cv-text.md`** — this file is the CV reference for all subsequent cover letter gatekeeper spawns (Steps E7.3, E7.7, E8.5). If the CV file cannot be located, log a warning and skip the write (the gatekeeper spawns will report the repetition check skipped); proceed — but never omit this attempt silently. The letter-writer uses the CV to check first-person consistency, scope claims, and experience framing.
- **`Why I Want This Role` — when populated, pass the verbatim text as a quoted block, never paraphrased or distilled.** The letter-writer's instruction rules require working from the user's exact words, not thematic summaries of them. If the Edit notes reference this field as the content source, that is even more reason to pass it raw — the writer must receive the actual material, not the orchestrator's interpretation of it. If empty, pass it empty; the letter-writer falls back to the Motivation Bank (its primary source). (R-44)
- **`Edit notes` content** (from the Step E0 row payload) — if populated, include verbatim with the instruction: "Address these specific edit notes first, before applying general improvements: [content]". Omit if empty.
- **Recruiter review** path `$PIPE/recruiter-review.md` to read — includes the "Interview-trigger gaps" section; the letter-writer uses these to proactively address gaps where Why I Want This Role or documented background provides a real answer. **Fabrication rules always trump reviewer input — even when a gap is passed, the letter-writer may only answer it with documented background or Why I Want This Role content. A reviewer flag does not authorise invention.**
- The coach's **template selection** (`$PIPE/template-selection.txt`) and **outline** (`$PIPE/coach-outline.md`) from Step E6.9 — read and follow per Step 0.7 in `agents/letter-writer.md`; the writer no longer chooses the template itself
- `LETTER_PATH=$PIPE/letter-draft.md` — the writer writes its output to this file and returns only a 2-line status + path (R-41 protocol).

The letter-writer improves the existing letter — it does not start from scratch. **Exception:** if the Edit notes contain an explicit "write from scratch" instruction, spawn the letter-writer in fresh-draft mode and discard the existing letter as the starting point. **When "write from scratch" is present, this instruction applies to ALL language versions** — if the role's `Languages` property includes Hebrew or other languages, Step E9H must also regenerate those versions from scratch (do not carry the old localized text forward as a base; spawn localization with the new English letter as the source).

The cover letter is written to the DOCX file only. Do not write cover letter text to any Notion property.

**Capture the returned agent ID** and write it to `$PIPE/letter-writer-agent-id.txt`. This is the one instance that gets resumed — never re-spawned fresh — for every subsequent letter-writer touch on this same letter (the revision loops below, including E7.3, E7.7, E8.5, and the quality-comparison loop).

> **⛔ Resume, don't respawn — applies to every "spawn letter-writer with option=revision" instruction for this letter, anywhere below.** A fresh subagent has no memory of what it already tried or why — this is precisely how a real production run took 4 gatekeeper rounds on one letter: fixing "role in sentence 1" broke "subject-first," and a fresh, memoryless writer fixing *that* produced a banned cliché neither rule caught. Instead: read `$PIPE/letter-writer-agent-id.txt` and resume that exact instance (send it a new message; do not spawn a new one) with a prompt scoped to *only* the new feedback — "Gatekeeper/coach found these issues: [violations]. Fix only these — leave everything else exactly as it is." The resumed instance still retains its own R-41 output contract (write to `$PIPE`, return a 1-line status) — nothing about resuming changes what the orchestrator holds in its own context. **If `$PIPE/letter-writer-agent-id.txt` is missing or the resume fails** (e.g. crash-recovery restart): fall back to a fresh `option=revision` spawn with full context (current draft + all accumulated feedback), and capture and overwrite the agent-ID file with the new instance.

**Step E7.25 — Cover letter quality comparison gate**

Before passing the revised cover letter to the gatekeeper, compare the old and new versions on four dimensions:

1. **Opening strength** — does it pull the reader in immediately, or start with a generic frame?
2. **Specificity** — does it name concrete things about this company, this role, or this intersection of the user's background?
3. **Voice naturalness** — does it sound like a person talking, or like assembled copy?
4. **Closing force** — does it end with a reason to respond, or trail off?

**The new letter must be stronger than the old on at least 2 of these 4 dimensions.**

**If it is not:** **Resume the letter-writer instance** (see the resume rule at Step E7 — do not spawn fresh), quoting the old letter's strongest lines verbatim and instructing: "The revision is not better. The original was stronger in [specific dimension]. Here are the lines that worked best in the original: [quoted lines]. Write a new letter that preserves this strength while fixing the identified problems." Max 2 loops. If no improvement after 2 loops, preserve the original letter and flag in the final delivery: "[Role] — cover letter: quality ceiling reached — the revision could not improve on 2 of 4 dimensions after 2 attempts. Original letter preserved. To get a different result, add specific Edit notes (e.g., 'rewrite paragraph 3 to strengthen the [X] angle') and re-run."

**If it is stronger:** proceed to Step E7.3.

**Step E7.3 — Gatekeeper (cover letter check — initial)**

Spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter (read from `$PIPE/letter-draft.md`), `Role summary` (from the coach properties verified in Step E1 — includes the Company self-characterization section), the user's Why I Want This Role content (retrieved in Step E7 from Notion), the CV path to read: `$PIPE/cv-final.md` for Edit type `Both`; `$PIPE/cv-text.md` for Edit type `Letter` (written from the pandoc extraction in Step E7); if the CV file does not exist (CV could not be located in Step E7), state that explicitly so the gatekeeper reports the skipped check by name — do not pass a path that doesn't exist; `$PIPE/wiwtr-checklist.md` to read if it exists (the letter-writer's numbered [WIWTR-N] point list, for Gate 2's coverage check — omit this parameter entirely if the file wasn't written); and `Template selected=<value read from $PIPE/template-selection.txt at Step E6.9, or omit if that file was absent>`.

**If PASS:** proceed to Step E7.4. On round 2+ the gatekeeper's own reply may read `PASS — cover letter [Tier 2: <n>% — deferred to humanizer]` — this is a normal round-aware PASS (Tier 1 clean, Tier 2 below 70% but no longer blocking past round 1), not an error. When it carries that deferred note, log the failing Tier 2 check types (read from the gatekeeper's `OUTPUT_PATH`) under `## Gatekeeper — Tier 2 Deferred to Humanizer (Step E7.3)` in the revision log; the humanizer handles them from there.

**If FAIL — round 1:** **resume the letter-writer instance** (see the resume rule at Step E7 — do not spawn fresh), passing the cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Log all violation rounds internally.

**If FAIL — round 2+:** this only occurs when a Tier 1 check still fails (Tier 2 alone never blocks past round 1 — see the PASS case above). Loop as above. Hard/Tier 1 fails block every round.

**Cap: 3 revision passes on hard fails.** After the third hard-fail FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Then proceed to Step E7.4.

**Step E7.4 — Coach strategic letter review**

**When `$SENDMESSAGE_AVAILABLE`, resume the coach instance captured at Step E6.9** (`$PIPE/coach-agent-id.txt`) with the **Option 4 — Strategic Letter Review** context below, rather than spawning fresh — it already holds the outline it wrote at Step E6.9 and can check whether the writer actually followed it. **When unavailable**, spawn a fresh `career-coach` with **Option 4 — Strategic Letter Review** instead. Either way, pass:
- `CAREER_DATA=${CAREER_DATA}`
- The cover letter path `$PIPE/letter-draft.md` to read
- `Role summary`, `Strategy`, `Keywords` (from the coach properties verified in Step E1)
- `Gap handling` (from the Step E1 coach properties; an **empty** `Gap handling` means gap handling is disabled for this run and there are no gaps — the review must give zero gap feedback)
- Why I Want This Role content (from the Step E7 Notion payload) — verbatim, not summarized
- Company name and role title
- `OUTPUT_PATH=$PIPE/coach-letter-review.md`

The coach writes its diagnostic review to that file and returns: `COACH-LETTER-REVIEW: <n> issues → $PIPE/coach-letter-review.md`

**If issues identified:** **resume the letter-writer instance** (see the resume rule at Step E7 — do not spawn fresh), passing `LETTER_PATH=$PIPE/letter-draft.md` (read and overwrite), the coach review path `$PIPE/coach-letter-review.md` as the revision brief, and `$PIPE/fix-log.md` (read and append). Locked-fixes instruction applies. After revision, spawn `gatekeeper` with `option=cover-letter` (new OUTPUT_PATH round, pass Why I Want This Role and final CV). **Cap: 1 coach-directed revision + 1 gatekeeper pass.** If the gatekeeper returns a Tier 1 FAIL after the revision, log the violations and flag for manual review — do not loop further. If it returns PASS (including a Tier 2 deferred note), proceed — the humanizer handles residual Tier 2 issues.

**If no issues identified:** proceed directly to Step E7.7.

**Step E7.7 — Gatekeeper (cover letter check — final)**

Spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the final cover letter text, `Role summary` (from the coach properties verified in Step E1), the user's Why I Want This Role content, the final CV text (same as Step E7.3), `$PIPE/wiwtr-checklist.md` to read if it exists (same as Step E7.3), and `Template selected=<same value passed at Step E7.3, or omit if that file was absent>`.

**If PASS:** proceed to Step E8 (humanizer). If the reply carries a Tier 2 deferred note (`PASS — cover letter [Tier 2: <n>% — deferred to humanizer]`), log the failing Tier 2 check types (read from the gatekeeper's `OUTPUT_PATH`) under `## Gatekeeper — Tier 2 Deferred to Humanizer (Step E7.7)` in the revision log — the humanizer handles them from there.

**If FAIL (a Tier 1 check still failing):** **resume the letter-writer instance** (see the resume rule at Step E7 — do not spawn fresh), passing the final cover letter and the gatekeeper's full violation list. Pass the accumulated fix log from all prior rounds with the locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL; a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter`. Cap: 3 revision passes on hard fails. After the third FAIL, stop looping, log the unresolved violations, flag the role in the final report, and continue the pipeline. Log all violation rounds internally.

---

**Step E8 — Humanizer (cover letter)**

**Before spawning, snapshot the revert target:** copy `$PIPE/letter-draft.md` (the E7.7-passing text) to a sibling `$PIPE/letter-draft.prehumanizer.md` — the revert target for E8.5. The humanizer edits in place, so this snapshot must be taken first.

Spawn `humanizer`, passing `CAREER_DATA=${CAREER_DATA}`, `LETTER_PATH=$PIPE/letter-draft.md` (it edits in place), and `$PIPE/voice-calibration.md` if it was created in Step E6.8 (the durable voice calibration; the humanizer uses it instead of reading the archive directly). Do not pass the structured JD, Role summary, strategy, or any role-specific context — the humanizer's only inputs are the letter, the career-data path, and the voice-calibration file.

The humanizer removes AI writing patterns sentence by sentence. It does not change structure, strategy, or content — only language. Wait for it to finish editing `$PIPE/letter-draft.md` in place and writing its change log before proceeding. The change log goes into the revision log under `## Humanizer changes`. If the humanizer fails, proceed with the pre-humanizer version `$PIPE/letter-draft.prehumanizer.md` (which already passed E7.7) — restore it over `$PIPE/letter-draft.md`.

**Step E8.5 — Final verification on the exported bytes**

The humanizer changed the text after the last PASS, so that PASS is no longer valid. Run both checks below on the exact saved markdown `$PIPE/letter-draft.md` that E9 will convert: (1) run the mechanical pre-export checklist **directly, using Bash in the orchestrator's own context (not a spawned subagent's)** — company name in first body paragraph (stealth roles: JD descriptor suffices), role title in body, zero em dashes and zero colons in body text (ignoring pandoc `:::` fences and `{custom-style=...}` attributes), zero hits for "I know this", "that's where", "that's what", "that's the kind", "that exact", "exactly that", "this same", "serves as", "stands as", "acts as"; also grep "the same" — a hit fails only when it points at an agent-coined abstraction ("the same engine"), not in benign uses ("the same week"); **word count ≤320 via `wc -w`, run here directly, not delegated** (a confirmed real production run had every gatekeeper-subagent round report no Bash tool available and substitute a hand-estimate wrong by 10-45 words every time, shipping over-cap letters despite a reported gatekeeper PASS — this orchestrator-level count is the guaranteed-mechanical enforcement, and does not defer to the subagent's own reported number); **Gate 6 Tier 1 banned-vocabulary/phrase/fit-declaration grep battery** named in `skills/gatekeeper-checks/SKILL.md` → Gate 6's Tier 1 section, run directly against this exact text, with the personal-voice exemption (`skills/writer-craft/SKILL.md` §2) applied before treating any hit as real; (2) spawn `gatekeeper` with `option=cover-letter` on this exact text, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter path `$PIPE/letter-draft.md` to read, `Role summary`, the user's Why I Want This Role content, the final CV path (same as Step E7.3), `$PIPE/wiwtr-checklist.md` to read if it exists (same as Step E7.3), and `Template selected=<same value passed at Step E7.3, or omit if that file was absent>`. If either fails: re-spawn `humanizer` (language issues — same `LETTER_PATH=$PIPE/letter-draft.md`, same `$PIPE/voice-calibration.md` if present) or **resume the letter-writer instance** (see the resume rule at Step E7 — do not spawn fresh) (content issues) and re-run this step. Cap: 2 rounds; after the cap, revert to the `$PIPE/letter-draft.prehumanizer.md` file saved in E8 (the last E7.7-passing text) by restoring it over `$PIPE/letter-draft.md`, and flag for manual review. Never export text that has not passed this step.

---

**Step E9 — Produce DOCX**

Follow the same pandoc production protocol as the main pipeline. See `career-engine-export` for the full protocol.

Derive `<company_dir>` from the Company name using the naming convention in `career-engine-export`. Convert using the original run folder as the temporary landing pad: write the final CV markdown and the final cover letter markdown (the E8.5-verified `$PIPE/letter-draft.md`) to `/tmp/`, convert with pandoc using the `.dotx` reference templates, update the CV Subtitle, and copy both files to `<output_dir>/<company_dir>/`. If a file with the same name already exists, overwrite it — this is an edit, not a new file.

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

# $CV_TEMPLATE_HE and $CL_TEMPLATE_HE already resolved above (fixed career-data paths, no config key)

# Hebrew CV — concatenate with Hebrew footer, then convert
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${CV_TEMPLATE_HE}" \
  -o "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"

python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${CL_TEMPLATE_HE}" \
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
but are not yet documented in your role-facts files. They are NOT fabrications —
they are your own first-person record. To make them available to future pipeline runs
without re-triggering this advisory, add them to `background-role-facts-[company].md`
for the relevant role, pending your verification that the facts are accurate.

For each item below: if accurate, add it as a role fact to the relevant
`background-role-facts-[company].md` file. If not accurate, remove it from your
Why I Want This Role before the next run.

[For each WIWTR-UNLOGGED item, one line:]
- **[Employer]** — "[verbatim claim from WIWTR]" *(flagged in [step] — not in background-role-facts-[company].md)*
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
