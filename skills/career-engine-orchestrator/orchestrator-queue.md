# Orchestrator — Core Config, Constraints, and Queue (O1–O4)

Load this file at run start. It contains everything needed before the first role begins: identity, constraints, configuration, and the queue steps that select and dispatch roles.

---

## Role

The orchestrator coordinates the user's career engine from start to finish. It fetches roles, delegates every reasoning and writing task to sub-agents, routes outputs, and delivers a concise final summary. It does not write CVs or cover letters, does not review applications, and does not make judgment calls about fit.

The New Applications pipeline produces three deliverables per role: a tailored CV, a cover letter, and a reviewer feedback file. All three are required outputs.

Sub-agents handle all reasoning work. Mechanical actions — Notion queries, priority writeback, DOCX export, Notion writeback, feedback file — run inline without spawning sub-agents.

---

## Absolute Constraints

These rules govern every run without exception. Read them before doing anything else.

**The orchestrator runs in the main session context — never as a spawned subagent.**

The orchestrator uses Bash to write files (markdown, DOCX, state.json, feedback) to the user's output folder. Bash in a sandboxed subagent context does not have access to the real filesystem and cannot write to the output folder — it will silently write to a session scratchpad instead. Therefore: the orchestrator must always be invoked directly in the main session, not spawned via the Agent tool. Only analysis and writing agents (cv-writer, letter-writer, reviewers, gatekeeper) — plus lightweight general-purpose extraction/fetch subagents used to keep an oversized Notion result out of the orchestrator's own context (Step O1: oversized view-query extraction, per-page property fetch) — are spawned as subagents. **All of them return text only; none of them write files.** The orchestrator is the only agent in this pipeline that writes to disk, on every path including these extraction subagents' output.

**The orchestrator never authors document content.**

CV and cover letter text is produced only by cv-writer, letter-writer, and the humanizer. The orchestrator's editing authority is limited to the mechanical inline fixes explicitly authorized in the gatekeeper loop steps (swap a word, remove one phrase, reorder paragraphs — zero creative judgment). It never composes sentences, merges drafts, picks between bases, or assembles a final document from parts. If a writer keeps failing, the cap rules apply: deliver the last passing version flagged for manual review. A hand-assembled document has bypassed every gate and must never be exported.

**Writer regression is corrected by re-spawning, never by patching.**

Maintain a per-document **fix log** across every revision loop: each entry records the violation and the fix applied. Every revision spawn receives the full fix log with this instruction verbatim: "These violations were already fixed in earlier rounds. Reintroducing any of them is itself a FAIL. Treat the fixed phrasings as locked unless they violate a current rule." If a writer returns text that reverts to an older base or reintroduces a fixed violation, name the regression explicitly and re-spawn with the fix log — do not fix the text yourself beyond the authorized mechanical scope.

**A PASS is only valid against the exact bytes that ship.**

Any text change after a gatekeeper PASS — including the humanizer's changes — invalidates that PASS. The final verification gate in the pipeline steps (post-humanizer gatekeeper pass plus the mechanical pre-export checklist) must run on the exact markdown that will be converted to DOCX. Never export a document whose final text was not the text a PASS was issued against.

**Outputs go to the user's output folder — never to a session scratchpad.**

The only valid output destination is:
`{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`

**Mandatory path verification — run before processing the first role.** Run the *Mandatory career-data discovery* (below) FIRST — it resolves `${CAREER_DATA}` and reads `$OUTPUT_FOLDER` and `$CV_TEMPLATE` from the career-data config. The plugin keeps `{{OUTPUT_FOLDER}}` literal; never treat that placeholder as a path. Two access paths, tried in order. A failed Path A is an environment limitation, not a missing folder — it does not end the run by itself.

**Path A — direct filesystem** (Claude Code, or the output folder is connected to the session):

```bash
OUTPUT_DIR="$OUTPUT_FOLDER/${OUTPUT_DIR_PREFIX:-applications}-$(date +%Y-%m-%d)"
mkdir -p "$OUTPUT_DIR"
[ -d "$OUTPUT_DIR" ] && echo "Output dir confirmed (Path A): $OUTPUT_DIR"
```

**Path B — host-bridge MCP** (sandboxed environments, e.g. Cowork, where sandbox Bash cannot reach the user's filesystem): if Path A fails, discover host filesystem tools via ToolSearch — search for `Desktop Commander`, `read_file`, `write_file`, `create_directory`, `start_process`, or equivalent host filesystem/process tools — and verify access by listing `$OUTPUT_FOLDER` (resolved from the career-data config) through the strongest available tool. If access is confirmed, proceed, and route ALL file operations for this run through those tools: directory creation, file reads and writes, and every pandoc command (via the host process tool, e.g. `start_process`). Sandbox `/tmp/` is not visible to host-side pandoc — on Path B, write intermediate markdown through the host tool to the output company directory (or a host temp path) instead of sandbox `/tmp/`.

**Both paths fail → stop the run immediately** and report to the user: the run needs either the output folder connected to the session or a host filesystem tool (e.g. Desktop Commander) enabled. Do not proceed.

**The no-scratchpad rule is unchanged and applies on both paths.** Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support". Path B writes to the same real output folder — through a different tool, never to a substitute location.

**If host access is lost mid-run** (e.g. the MCP disconnects): retry the operation once. If still unreachable, do not improvise a fallback path — deliver the remaining file contents in chat flagged for manual save, log the failure in the run-level revision log, and continue the run's non-file steps.

**Mandatory career-data discovery — run before loading any personal reference (R-37).** The user's personal data lives in the external `career-data` skill, not in the plugin. Resolve it once here, treat the resolved directory as `${CAREER_DATA}` for the whole run, and pass it to every spawned agent.

1. Locate the `career-data` skill directory on the current surface (the loaded-skill path in Code; the readable skills mount in Cowork). Confirm `career-data-marker.json` is present at its root.
2. Set `${CAREER_DATA}` to that directory. Personal-data files load from `${CAREER_DATA}/references/...`. The plugin's `${CLAUDE_PLUGIN_ROOT}/references/...` copies are blank templates and serve only as the new-user fallback.
3. Three outcomes:
   - **Healthy** — marker present and every file in the marker's `expected_files` present and non-empty → run the health check below, then proceed.
   - **Damaged** — marker present but an expected file missing or empty → **stop the run**, name the file, tell the user to restore `career-data` from the output-folder backup. Do NOT fall back to templates.
   - **Absent** — no `career-data` found (marker also absent) → check the output folder for a `career-data` backup export. Backup present → configured user, offer to restore. No backup → genuine new user: run `/career-engine:setup` (blank templates are the correct starting point only here).

**career-data health check (runs on Healthy outcome only):**
After confirming the marker and files, run these two checks before proceeding:
1. **Delivered-letters count:** count files in `${CAREER_DATA}/references/delivered-letters/` (excluding `INDEX.md`). If count = 0: **stop the run** and warn: "career-data has no delivered letters — voice calibration will fail. Add at least one sent letter to `career-data/references/delivered-letters/` using the letter-writer Option 3 flow, then re-run." This is a hard stop, not a warning-and-proceed.
2. **Config key check — required keys hard-stop; everything else is optional and never blocks.** Read `pipeline-preferences.json`.
   - **Required (stop the run if missing or empty):** `output_folder`, and — only when a database backend is configured (`database_backend` set; default `notion`) — `database_id`. Stop with: "career-data config is incomplete — run `/career-engine:setup --phase 5` to fill in: [required keys missing]." (`cv_template` is not a config key — see Template resolution below.)
   - **All other keys are optional: never stop on them.** A pipeline must run to completion even when optional keys are absent or empty — this keeps an upgrade from breaking an existing user. Collect every optional key that is absent or present-but-empty into a `CONFIG_HEALTH` list for the end-of-run notification.
   - **Backward compatibility:** also accept the legacy names `notion_database_id` (→ `database_id`), `notion_needs_editing_view_url` (→ `database_edit_view_url`), `location_compatibility.notion_property` (→ `database_property`). Prefer the `database_*` names; add any legacy name found to `CONFIG_HEALTH` as a "rename to `<new>`" migration item. The run proceeds normally on a legacy name.
3. **Desktop-app sync check (Code sessions only):** If running in Claude Code, check whether `~/.claude/skills/career-data/` matches the resolved `${CAREER_DATA}`. If they differ, warn: "career-data appears to be out of sync — the Desktop app may not have propagated the latest skill to Code. If you recently updated career-data in Chat or via the Desktop app, re-install the .skill file to keep Code in sync. Continuing with the resolved career-data path." This is a warning, not a stop — proceed on the resolved path.

**Personal-data files** (load from `${CAREER_DATA}/references/`): `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `pipeline-preferences.json`, `delivered-letters/`, `templates/`, and the user's `.dotx`. **Doctrine files** stay on `${CLAUDE_PLUGIN_ROOT}/references/`: the self-checks, `REFERENCES.md`, `he-terminology-guide.md`, and the default `.dotx` templates (new-user fallback only — see `career-engine-setup/SKILL.md`). Inject `CAREER_DATA=<resolved path>` into every agent spawn prompt so each subagent reads personal data from that same root.

**Config resolution.** Read the **full** per-install config from `${CAREER_DATA}/references/pipeline-preferences.json` and resolve EVERY `{{CONFIG}}` placeholder from it. Keys (prefer the `database_*` names; legacy `notion_*` names are still accepted): `database_backend` (default `notion`), `database_id` (legacy `notion_database_id`), `database_interested_view_url` (optional fast-path), `database_hold_view_url` (optional), `database_researched_view_url` (optional), `database_cv_ready_view_url` (optional), `database_edit_view_url` (optional; legacy `notion_needs_editing_view_url`), `output_folder` (absolute), `draft_dir_url_base` (or `skip`), `output_dir_prefix` (optional; defaults to `applications`), `default_language` (optional; defaults to `English`), `gap_handling`, `location_compatibility` (optional object: `{"my_location": "<city/country>", "database_property": "<property/field name>"}`; legacy `notion_property`; if absent or empty, location compatibility check is skipped), `favorite_brands` (optional array; if absent or empty, no brand boost applied). Set the matching shell vars (`$NOTION_DATABASE_ID` ← `database_id`, `$NOTION_INTERESTED_VIEW_URL` ← `database_interested_view_url`, `$NOTION_HOLD_VIEW_URL` ← `database_hold_view_url`, `$NOTION_RESEARCHED_VIEW_URL` ← `database_researched_view_url`, `$NOTION_CV_READY_VIEW_URL` ← `database_cv_ready_view_url`, `$OUTPUT_FOLDER`, `$DRAFT_DIR_URL_BASE`, `$OUTPUT_DIR_PREFIX`, `$DEFAULT_LANGUAGE`, `$NOTION_NEEDS_EDITING_VIEW_URL` ← `database_edit_view_url`) — these internal var names belong to the Notion adapter (the current backend) and are unchanged — pass them to every spawn and downstream skill. **Required for any run:** `output_folder`. **Also required when a database backend is configured:** `database_id`. If a required key is missing or empty, stop with: "career-data is missing config key `<name>` — run `/career-engine:setup --phase 5`." Optional keys absent → treat as unconfigured (collect into `CONFIG_HEALTH`): `draft_dir_url_base` empty/`skip` ⇒ leave Draft Directory blank; `output_dir_prefix` absent ⇒ use `applications`; `default_language` absent ⇒ use `English`.

**Template resolution — fixed filenames, no config key (2026-07-04 fix).** `cv_template` and `word_templates_path` are no longer config keys. Set `$CV_TEMPLATE` = `${CAREER_DATA}/references/templates/cv.dotx`, `$CV_TEMPLATE_BRIEF` = `${CAREER_DATA}/references/templates/cv-brief.dotx` (Brief CV Type — resolved once here like the others, though only actually required for a role whose per-role Step 0.type resolves to `Brief`), `$CL_TEMPLATE` = `${CAREER_DATA}/references/templates/cover-letter-template.dotx`, `$CV_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/cvHe.dotm`, `$CL_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/he-letter.dotx` — always these fixed relative paths, never an external OS path, never a config lookup. `$CV_TEMPLATE`/`$CL_TEMPLATE` are required for any export — if either file doesn't exist, stop with: "career-data is missing `references/templates/<filename>` — run `/career-engine:setup --phase 5` to restore the default templates." `$CV_TEMPLATE_BRIEF`/`$CV_TEMPLATE_HE`/`$CL_TEMPLATE_HE` are optional at this preflight stage — if `$CV_TEMPLATE_BRIEF` is missing, Brief CV Type export is unavailable (collect into `CONFIG_HEALTH`; `career-engine-new-application`'s own Step 0.type additionally fails fast per-role if a role actually resolves to `Brief` and the file is still missing at that point). If `$CV_TEMPLATE_HE`/`$CL_TEMPLATE_HE` is missing, Hebrew export for that document type is unavailable (collect into `CONFIG_HEALTH`).

**Config-health notification (every run, until resolved).** After resolution, compare the user's `pipeline-preferences.json` against the plugin's blank template at `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json`:
- **Missing keys** (in the template, absent from the user's config) → list under "outdated config."
- **Present-but-empty optional fields** and any **legacy `notion_*` names** found → list under "unfilled / rename."
Emit a `⚙️ Config health` block at the **end of the run output** whenever `CONFIG_HEALTH` is non-empty: one line per item (key name + one-line "what it enables"), prefixed "Optional — your run was unaffected." Then the populate path: "To set these: ask the coach (career-data update mode) or run `/career-engine:setup --phase 5` to generate an update-prompt → paste in Chat → repackage the `.skill` → reinstall via Customize → Skills (and re-apply in Code if you use both)." This block repeats every run until the user resolves the items; because it diffs the live template, any future key added to the schema surfaces here automatically. Never write `career-data` directly to fix it (R-37 / June-18 anti-pattern) — the notification only detects and routes.

**Writing personal data (R-37).** Any write to a personal-data file targets `${CAREER_DATA}/references/...`. In Claude Code, write it directly. In Cowork (the skills mount is read-only), do NOT write the skill — stage the change to the output folder as `pending-career-data-updates.md` and emit the Appendix-A handoff prompt (`${CLAUDE_PLUGIN_ROOT}/references/career-data-skill-handoff.md`) for the user to apply in Chat; never write a divergent copy. After any successful direct write, refresh the `career-data` backup export in the output folder. New Section 7-grade career facts are flagged for approval, never auto-written.

**Three to five files per role, one file per run.**

The New Applications pipeline produces three files per role (CV DOCX, cover letter DOCX, reviewer feedback MD) plus up to two additional Hebrew files when `Languages` includes `Hebrew` (Hebrew CV DOCX, Hebrew cover letter DOCX). One file per run (LinkedIn updates MD). The DOCX files follow the same production path: cv-writer or letter-writer outputs styled markdown → the intermediate markdown lands somewhere pandoc can read it → pandoc converts to `.docx` using the `.dotx` reference templates → files copy to the output folder. **On Path A, that intermediate landing spot is `/tmp/` — a required production step for Path A, not optional. On Path B, it is never `/tmp/`** (per the Path B instruction above: sandbox `/tmp/` is invisible to host-side pandoc — write through the host tool to the output company directory or a host temp path instead). Whichever path this run confirmed at preflight governs every file-copy step below, including this one — do not default to the Path A `/tmp/` instruction on a Path B run. The reviewer feedback file is written in Step 7d. The LinkedIn updates file is written in Step 8 after all roles complete.

**Load `career-engine-export` before processing the first role.**

If `career-engine-export` is not loaded when you reach the DOCX export step, back up and load it.

**Run end-to-end. Do not stop to ask the user about scope — not before launch, not at the queue report, not mid-run.**

Step O3's Priority-ordered selection (below) caps the run and selects which roles process this session — that cap is the decision, already made deterministically before the run starts. (This is Step O3's own logic, not a live coach spawn — the coach is never spawned from this pipeline; see the note further below.) Do not pause after Role 1 to ask whether to continue. Do not ask whether to batch DOCX conversion. Do not ask whether the run is too long.

If a single role fails, log the failure and move to the next role. The only valid mid-run pauses are a hard unrecoverable system error or the user explicitly typing a stop command in chat.

> **⛔ Named anti-pattern: pausing mid-run over perceived call-volume/cost.** A real Cowork run found 34 Interested roles, correctly capped the queue at 5 (P1 first, P2 randomly tie-broken — the selection logic worked exactly as designed), and got 3 gatekeeper rounds into role 1's CV, correctly hitting the round-3 cap and logging the unresolved violations to a file. Then, instead of moving on to the cover letter for that role, it stopped and called `AskUserQuestion`: *"I found 34 roles... way more than a typical run... Each full role... is taking a very large number of agent calls. How do you want me to proceed?"* — offering options like "Finish all 5 roles fully" vs. "Finish [role 1] only, then stop." The question itself then failed with a transport error, and the session died there: 4 of 5 queued roles were never processed, and no final report was ever generated. **Noticing that a run is taking many agent calls, or that the queue is unusually large, is not new information requiring confirmation — it is not a reason to pause, and it was never grounds to ask permission to continue.** Scope was already decided the moment the queue was built (the cap above). Never construct an `AskUserQuestion` (or any other check-in) offering to change scope, batch differently, or stop early because the run feels long or expensive — that self-perceived cost/duration concern is exactly the "how do you want me to proceed" pattern this section already prohibits, arriving later and on a different trigger than the queue-selection version of this same anti-pattern (see the "Do not ask the user about this" guard in the intake pipeline's Step 0.7, added after a real run asked "There are 28 roles in Hold, how should I pick 5?" despite the selection rule already being deterministic). This is the second confirmed production instance of the same failure mode — treat any urge to check in about scope, mid-run, as the signal to stop and re-read this paragraph, not as a reasonable caution.

**The named pipeline command is the routing authority. Do not re-scope it before launch.**

When the user invokes a pipeline by name ("run a new application pipeline", "run the edit pipeline", "run intake"), that command decides the route. Row metadata — `Edit type`, `Last Pipeline Run`, prior outputs on disk, recent Status changes — is context, never a veto. Do not pause before launch to ask whether she meant a different pipeline, whether the roles were "already processed", or how to scope the run. The command already answered those questions. If the metadata suggests another pipeline might also be relevant, add a one-line note to the briefing and proceed with the pipeline named.

---

## Configuration

**Job Applications database:** Notion database ID `{{NOTION_DATABASE_ID}}`. Source of job descriptions and destination for per-role updates.

**Output folder:** `{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`

Each role's files go in a subdirectory inside the run folder named after the hiring company (see company directory naming convention in `career-engine-export`). After all files for a role are produced and verified **on disk** (confirmed via `ls`), the orchestrator writes the file directory URL to the `Draft Directory` URL property on the Notion row. All English and Hebrew files for the role are accessible from that directory URL.

**`Draft Directory` property:** URL property. Written in Step 7a — only after both DOCX files are confirmed present and nonzero on disk via `ls`. **Never written before files are confirmed on disk.** If the `ls` check fails, the role is flagged as incomplete and Notion is not updated for that role. Value formula:

```
$DRAFT_DIR_URL_BASE<date-folder>%2F<company_dir>%2F
```

Where `<date-folder>` = the run folder name (e.g. `${OUTPUT_DIR_PREFIX:-applications}-2026-05-26`) and `<company_dir>` = the kebab-case company directory name.

**`Languages` property:** Multi-select on the Notion row. Expected options: `English`, `Hebrew`. If `Hebrew` is present, the pipeline automatically runs the Hebrew localization step (Step 6H) after English DOCX export and produces two additional DOCX files in the same company subdirectory. No extra configuration required.

---

## Skills to Load

Load these skills in order before doing anything else. Do not begin processing until all four are loaded.

**Note:** The orchestrator does NOT load `01-writing-rules.md`. Each writing subagent (cv-writer, letter-writer, gatekeeper, humanizer) loads its own context from `${CAREER_DATA}` via the `CAREER_DATA` path injected at spawn time. Loading it in the orchestrator adds ~30K tokens to the startup context with no benefit — the orchestrator routes and spawns; it does not apply writing rules directly.

1. `database` — Status values, Priority values, and property ownership rules (backend-neutral pipeline concepts). Load before Step O1.
2. `career-engine-new-application` — Steps 1 through 7: per-role CV writing, gatekeeper checks, reviews, cover letter (letter-writer), HM cover letter review, DOCX export (including Step 6H Hebrew), Notion writeback
3. `career-engine-edit` — Steps E0 through E10: editing pipeline for `Needs editing` roles; starts from existing Notion row content, not from scratch
4. `career-engine-export` — DOCX template styles, pandoc commands, file naming, `/tmp → output folder` copy protocol, page count verification

## Property Ownership

Full Status values, Priority values, and property ownership rules are in `skills/database/SKILL.md` — load it before Step O1. Role Type Definitions (Builder/Scaler/Specialist/Leader and their effect on CV structure) are in `references/role-type-definitions.md` — loaded by the career coach and cv-writer as needed. The orchestrator does not use either table directly.

This orchestrator writes only two database properties per role: `Draft Directory` (Step 7a, after DOCX files confirmed on disk) and Status → `CV Ready for Review` (Step 7c). It never writes or rewrites coach-owned properties.

**Queue ordering (summary):** scored roles 1→6 first, unscored last. Open Application entries always sort as `6`. The orchestrator reads Priority — it never writes it (coach writes Priority during intake).

---

## Pipeline Registry

See `skills/career-engine/SKILL.md` (canonical, always current). This orchestrator owns **Pipeline 4 — New Application** and **Pipeline 5 — Fast track (`--now`)**. All other pipeline commands route elsewhere — do not improvise their steps here.

**One-pass utility modes** (no loops, no database writeback): `--coach` (conversational fit assessment), `--check` (single gatekeeper pass on pasted text), `--review` (single recruiter + HM pass), `--write-letter` (standalone letter draft), `--status` (read state.json and report).

---

## Orchestrator Steps

**The orchestrator owns the Interested queue.** It fetches Interested roles directly via the database adapter (Status = `Interested`), runs a readiness check, builds the processing queue, and passes it to `career-engine-new-application`. It does NOT delegate queue-fetching to `career-engine-intake` — intake processes only Needs Research roles and is never called from here.

### Step O1 — Fetch Interested roles (via the database adapter)

**Establish a run-scoped `$QUEUE_PIPE` before the fetch loop below** — mirrors the intake pipeline's Step 0.4 pattern (`skills/career-engine-intake/SKILL.md`). **Named distinctly from the per-role/per-company `$PIPE` created later inside `career-engine-new-application`** — sharing one variable name across a queue-scoped value and a per-role value that gets recreated on every iteration of Step O4's loop risks the queue-level value being silently overwritten before Step 8a needs it back; a distinct name removes the ambiguity entirely rather than relying on prose to keep them apart. Set `$QUEUE_PIPE` = `$OUTPUT_FOLDER/_queue_pipeline/<run-timestamp>/` (timestamped so a concurrent or immediately-prior run never collides). `$OUTPUT_FOLDER` is already resolved and required by this point (the orchestrator preflight guards it before Step O1 ever runs). Create it and write to it using whichever access path (A or B) the *Mandatory path verification* above already confirmed for this run — do not re-verify or choose a different path here. `_queue_pipeline/` is intermediate only — never a deliverable, never written to Notion.

These are database operations. **Load `${CLAUDE_PLUGIN_ROOT}/skills/database-notion/SKILL.md`** — the Notion adapter, mandatory when `database_backend` is `notion` (the default) — and follow it:
- **§1 Schema read** — fetch the schema reference (the SQLite `CREATE TABLE` block) and keep it in context for all property writes. If the schema fetch fails, stop and report. **Before running this, check §1's own STOP guard** — if all you need right now is view discovery and `$NOTION_INTERESTED_VIEW_URL` is already non-empty, skip straight to the view query per that guard; don't run the full fetch just to find a view you already have the URL for.
- **§2 Read ladder** — query the queue with **target status `Interested`** (A1 → A2 → B). On Path B: if `$NOTION_INTERESTED_VIEW_URL` is non-empty, use it directly as the view URL (skips the 59KB DB discovery fetch); otherwise the adapter resolves the "Interested" view via **§3 view discovery** (one DB fetch → read the `<views>` block → match by name — never a `collection://` fetch). **On Path B, the view-query call itself (§2 Path B steps 2–3) is delegated by the adapter — never run it directly in this pipeline's own context; see the adapter for the subagent contract.** This step is discovery only — page IDs, company, position, priority. Do not fetch full per-page properties here; that is the next bullet's job, delegated.
- **⛔ Running these `notion-fetch` calls directly in the orchestrator's own context — one by one or batched — has caused premature context exhaustion in real production runs, ending the session before any pipeline subagent (cv-writer, letter-writer, gatekeeper) ever got to spawn.** A live 18-role run fired 6 raw `notion-fetch` calls in bursts, held every result inline (~70-163KB combined), and the transcript stopped shortly after — the exact failure this step exists to prevent. **Delegate the per-page property fetch — do not run it here.** An earlier instruction to "write each result immediately" was satisfied loosely by firing several fetches in a burst and writing them after — by the time that happens, the damage (all results already landing live in context) is done. Prose telling the orchestrator to interleave its own fetch-then-write per page does not survive real tool-call batching; delegate the whole loop instead, mirroring the extraction-subagent pattern already used for an oversized view-query result above.

  **Spawn a lightweight subagent** (general-purpose / Task tool — the same kind of agent used for the oversized-result extraction), passing it: the list of page IDs from the view-discovery step above, and the full property list needed (every property the coach may have written — `Role summary`, `Role emphasis`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Culture`, `Landscape`, `JD proof`, `Priority`, `Priority Reason`, `Company Stage`, plus `Location`/`First Advertised`/location-compatibility where present). Instruct it exactly: *"For each page ID, call `notion-fetch` and capture its full property set. Do this for all N pages. If a page's fetch fails or errors, do not stop — skip that page, continue with the rest, and add one line for it under a final `## FAILED` section naming the page ID and the error. Return your response as one block, using this exact format, one section per role: `## ROLE — <Company> — <Position>` followed by `**Page ID:** <id>` and then every property as a labeled line, plus the `## FAILED` section if any page errored. Return nothing else — no commentary, no partial returns per page."* The subagent **returns text**, per this file's own Absolute Constraint above (subagents are sandboxed and cannot write the real output folder) — it does not write `$QUEUE_PIPE` itself. **If the returned block's `## FAILED` section lists any page:** log each by page ID in the run-level revision log and exclude that role from the processing queue (same "excluded, re-run later" treatment as a Step O2 readiness-check failure) — never silently drop it without logging, and never treat a partial subagent return as the full result.

  **The orchestrator receives that one returned block and writes it to `$QUEUE_PIPE/role-properties.md` in a single `Write` call, then drops the returned text from working memory immediately.** This is the structural fix: the ~70-160KB of property/JD text arrives as one bounded return and is flushed to disk in one action, rather than accumulating turn-by-turn across several raw inline `notion-fetch` results the way it did in the traced failure. If the page count is large enough that the subagent's own return risks being oversized (rough guide: more than ~8-10 roles — when in doubt, split; an unnecessary split costs one extra spawn, an oversized single return risks losing the whole block), split the page-ID list across two or more subagent spawns and append each returned block to `$QUEUE_PIPE/role-properties.md` in turn — still never running the per-page fetches in the orchestrator's own context.

  **If the subagent cannot access `notion-fetch`** (tool not available in its spawned context — check its return; a subagent that can't call the tool will say so or return an empty/error result instead of the expected format): fall back to running the per-page fetches directly in the orchestrator's own context, but still write each result to `$QUEUE_PIPE/role-properties.md` before fetching the next page, and treat this as a degraded path, not the default — log it in the revision log so it's visible that the delegation didn't fire this run.

  **If the subagent returns text that doesn't match the required `## ROLE — <Company> — <Position>` format at all** (not a tool-unavailable error, not a per-page `## FAILED` entry — just malformed or unparseable output): treat this the same as the tool-unavailable case above — do not try to salvage or partially parse it. Fall back to running the per-page fetches directly in the orchestrator's own context, log in the revision log that the delegated return didn't match the expected format, and proceed via the degraded path.

  Step O2's readiness check reads the four scalar fields it needs (`Role summary`, `Role emphasis`, `Keywords`, `Strategy`) from `$QUEUE_PIPE/role-properties.md`, not from in-memory fetch results — this is the same pattern intake's Step 0.5 already uses for `$PIPE/queue.md`.
- If every rung fails, stop and report — never treat it as zero results, and never improvise `notion-search` (R-39).

(If `database_backend` is ever not `notion`, load that backend's adapter instead — the operation is the same: read schema, query the `Interested` queue.)

Report count: "Found N Interested roles."

**Empty queue (genuine zero):** if the read ladder succeeds but returns **0 `Interested` roles**, this is a clean terminal stop, not a failure and not a scoping question. Report plainly — "No roles with Status = Interested. Move a role from Needs Research → Interested (or add one as Interested) and re-run." — and stop. Do NOT ask how to scope the run, do NOT fall back to another status, and do NOT improvise a search.

### Step O2 — Readiness check

For each fetched role, read its section from `$QUEUE_PIPE/role-properties.md` (written in Step O1) — do not re-fetch or hold the full per-page result in memory again — and verify these **writer-needed fields** are populated (non-empty):
`Role summary`, `Role emphasis`, `Keywords`, `Strategy`.

`JD proof` is not checked — it is reference-only. `Gap handling` is not required when `gap_handling_mode = disabled`. `Landscape` is context, not a writer input.

- **All four fields present** → role is ready; carry its coach values forward.
- **Any field missing** → log: "[Company] — [Position]: excluded — missing writer-needed field(s) `<list>`. Run intake first, then re-run the New Application pipeline." Remove from queue. Leave Status unchanged.

Roles that pass are the processing queue.

**Empty queue after the readiness filter:** if every fetched role was excluded here (0 roles pass the readiness check), the queue is empty. This is a clean terminal stop — report plainly: "All N Interested role(s) were excluded for missing writer-needed fields. Run intake (`/career-engine --coach-skills`) to populate them, then re-run the New Application pipeline." — and stop. Do NOT proceed to O3, do NOT ask how to scope the run, and do NOT process a role with missing fields.

### Step O3 — Build the processing queue

**If there are 5 or fewer ready roles:** process all of them.

**If there are more than 5:** select top 5:
1. `scored` roles ordered `1` → `2` → `3` → `4` → `5` → `6`
2. Remaining slots filled with `unscored` roles in queue order

**Tiebreaker for same-Priority roles:** choose randomly among tied roles. Do not use queue order, creation date, or any other deterministic signal — just pick.

Unscored roles still process — `Priority` affects ordering only; the coach is never spawned here to score them. The career coach runs only in intake.

**Open Application hard floor:** roles identifiable as open/speculative applications must sort as `6` regardless of any Priority value set.

Post exactly one declarative line — e.g. "Queue: Cognyte (P1), hearing.ai (P1), DualBird (P1), Gilat (P2), Datadog (P2). Running all 5." — then immediately begin Step O4. **Do not wait for a reply. Do not ask how to scope the run. The queue is already scoped.**

### Step O3.5 — Run plan (internal)

Before spawning any subagent, write a compact run plan silently (not delivered in chat):

1. For each queued role: pipeline type (New Applications or Edit), cover letter expected (Why I Want This Role populated: yes/no), complexity flags (Hebrew, unusual role type, known gaps).
2. Context strategy: "Processing sequentially. State written after each role — crash recovery available if interrupted. If a role fails, log and continue to the next."

Write this once and begin O4 immediately. Do not surface it in chat.

### Step O4 — Per-role pipeline

Run `career-engine-new-application` Steps 1 through 7 for each role in queue order. **Each role's coach properties come from `$QUEUE_PIPE/role-properties.md`, never pasted inline into the per-role pipeline's steps** — pass `$QUEUE_PIPE/role-properties.md` (the path) plus this role's company/position identifier at the point `career-engine-new-application` begins for this role; its own Step 0.data reads that role's section from the file, consistent with the R-41 file-based-handoff convention every other pipeline transition in this plugin already follows. Step 8 (LinkedIn updates) is orchestrator-owned and runs ONCE after the per-role loop completes — see `orchestrator-post-run.md` *Step 8 — LinkedIn Updates File*. It is not part of the per-role new-application pipeline; do not run it inside the loop.

**Carry all resolved config vars into every role's execution.** The preflight set `$OUTPUT_FOLDER`, `$DRAFT_DIR_URL_BASE`, `$CV_TEMPLATE`, `$CV_TEMPLATE_BRIEF`, `$DEFAULT_LANGUAGE`, `$OUTPUT_DIR_PREFIX`, `$CAREER_DATA`, and `$NOTION_DATABASE_ID`. These must remain in scope through every step of new-application — including Step 7a (which builds the Draft Directory URL from `$DRAFT_DIR_URL_BASE`) and Step 6 (which uses `$CV_TEMPLATE`/`$CV_TEMPLATE_BRIEF`, selected per role by `career-engine-export/SKILL.md`'s CV-Type-conditional logic, and `$OUTPUT_FOLDER`). If any of these is unset when a step needs it, stop and report rather than silently defaulting or skipping.

**Within this pipeline (New Applications), which track a role runs is determined by the user's chat command**, not by a Notion property she sets per-role — all `Interested` roles default to the standard cv pipeline unless the user specifies otherwise in chat. This orchestrator's Step O1 only ever fetches `Interested`-status roles, so `Needs editing` never appears as a live branch inside this per-role loop.

| Pipeline | What runs | Deliverables |
|---|---|---|
| `New Applications` (default) | cv pipeline — Steps 1 through 7 per role, then orchestrator Step 8 once | CV DOCX + cover letter DOCX + feedback MD |
| `--now` | fast track — see `orchestrator-modes.md` | CV DOCX + feedback MD + cover letter DOCX only if Why I Want This Role content is provided in chat |
| `Needs editing` *(reference only — not a branch of this loop)* | career-engine-edit (separate skill, separate entry point) — Steps E0 through E10 | Updated CV DOCX + updated cover letter DOCX; starts from existing Notion outputs, not from scratch. Listed here for orientation only: this pipeline is invoked directly when the user says "edit CVs" or similar — it is never reached by this orchestrator's `Interested`-only Step O1 fetch, regardless of what Status a role happens to carry. |

The JD for each role was already in Notion (`JD Body`) when fetched in Step O1. Pass it directly to per-role sub-agents — do not re-fetch.

**When all roles complete, load `orchestrator-post-run.md` and continue.**

**If the loop stops early instead — a hard external blocker (rate/spend limit, connection loss, or any error that is clearly not a quality/business-logic FAIL and is not retryable) halts a role's subagent chain before all queued roles are processed — do not skip straight to a chat summary.** Load `orchestrator-post-run.md` and run its full sequence anyway, scoped to the roles that completed this run. An interrupted run is not an exemption from post-run wrap-up for whatever roles did finish. **Confirmed real regression this closes:** a production run hit a spend-limit error two roles into a five-role queue, correctly stopped rather than hand-authoring around the blocker, but then skipped Steps 8/9/9b/9c (LinkedIn updates, revision log, bullet approval, run metrics) entirely and improvised a chat summary in their place — leaving the two fully-completed roles with none of their run-level artifacts, including the `run-metrics-<date>.json` file every prior run has had. Only the per-role loop stops early; the post-run wrap-up for already-completed roles must still run, scoped to `<N completed>` not the original queue size.
