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

The orchestrator uses Bash to write files (markdown, DOCX, state.json, feedback) to the user's output folder. Bash in a sandboxed subagent context does not have access to the real filesystem and cannot write to the output folder — it will silently write to a session scratchpad instead. Therefore: the orchestrator must always be invoked directly in the main session, not spawned via the Agent tool. Only analysis and writing agents (cv-writer, letter-writer, reviewers, gatekeeper) are spawned as subagents — they return text only, they do not write files.

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
   - **Required (stop the run if missing or empty):** `output_folder`, `cv_template`, and — only when a database backend is configured (`database_backend` set; default `notion`) — `database_id`. Stop with: "career-data config is incomplete — run `/career-engine:setup --phase 5` to fill in: [required keys missing]."
   - **All other keys are optional: never stop on them.** A pipeline must run to completion even when optional keys are absent or empty — this keeps an upgrade from breaking an existing user. Collect every optional key that is absent or present-but-empty into a `CONFIG_HEALTH` list for the end-of-run notification.
   - **Backward compatibility:** also accept the legacy names `notion_database_id` (→ `database_id`), `notion_needs_editing_view_url` (→ `database_edit_view_url`), `location_compatibility.notion_property` (→ `database_property`). Prefer the `database_*` names; add any legacy name found to `CONFIG_HEALTH` as a "rename to `<new>`" migration item. The run proceeds normally on a legacy name.
3. **Desktop-app sync check (Code sessions only):** If running in Claude Code, check whether `~/.claude/skills/career-data/` matches the resolved `${CAREER_DATA}`. If they differ, warn: "career-data appears to be out of sync — the Desktop app may not have propagated the latest skill to Code. If you recently updated career-data in Chat or via the Desktop app, re-install the .skill file to keep Code in sync. Continuing with the resolved career-data path." This is a warning, not a stop — proceed on the resolved path.

**Personal-data files** (load from `${CAREER_DATA}/references/`): `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx`. **Doctrine files** stay on `${CLAUDE_PLUGIN_ROOT}/references/`: the self-checks, `REFERENCES.md`, `remote-compatibility-rules.md`, `he-terminology-guide.md`, and the default `.dotx` templates. Inject `CAREER_DATA=<resolved path>` into every agent spawn prompt so each subagent reads personal data from that same root.

**Config resolution.** Read the **full** per-install config from `${CAREER_DATA}/references/pipeline-preferences.json` and resolve EVERY `{{CONFIG}}` placeholder from it. Keys (prefer the `database_*` names; legacy `notion_*` names are still accepted): `database_backend` (default `notion`), `database_id` (legacy `notion_database_id`), `database_interested_view_url` (optional fast-path), `database_hold_view_url` (optional), `database_researched_view_url` (optional), `database_cv_ready_view_url` (optional), `database_edit_view_url` (optional; legacy `notion_needs_editing_view_url`), `output_folder` (absolute), `cv_template` (relative to `${CAREER_DATA}`), `draft_dir_url_base` (or `skip`), `output_dir_prefix` (optional; defaults to `applications`), `default_language` (optional; defaults to `English`), `word_templates_path` (Hebrew; optional), `gap_handling`, `location_compatibility` (optional object: `{"my_location": "<city/country>", "database_property": "<property/field name>"}`; legacy `notion_property`; if absent or empty, location compatibility check is skipped), `favorite_brands` (optional array; if absent or empty, no brand boost applied). Set the matching shell vars (`$NOTION_DATABASE_ID` ← `database_id`, `$NOTION_INTERESTED_VIEW_URL` ← `database_interested_view_url`, `$NOTION_HOLD_VIEW_URL` ← `database_hold_view_url`, `$NOTION_RESEARCHED_VIEW_URL` ← `database_researched_view_url`, `$NOTION_CV_READY_VIEW_URL` ← `database_cv_ready_view_url`, `$OUTPUT_FOLDER`, `$CV_TEMPLATE`, `$DRAFT_DIR_URL_BASE`, `$OUTPUT_DIR_PREFIX`, `$DEFAULT_LANGUAGE`, `$WORD_TEMPLATES_PATH`, `$NOTION_NEEDS_EDITING_VIEW_URL` ← `database_edit_view_url`) — these internal var names belong to the Notion adapter (the current backend) and are unchanged — pass them to every spawn and downstream skill. **Required for any run:** `output_folder`, `cv_template`. **Also required when a database backend is configured:** `database_id`. If a required key is missing or empty, stop with: "career-data is missing config key `<name>` — run `/career-engine:setup --phase 5`." Optional keys absent → treat as unconfigured (collect into `CONFIG_HEALTH`): `draft_dir_url_base` empty/`skip` ⇒ leave Draft Directory blank; `output_dir_prefix` absent ⇒ use `applications`; `default_language` absent ⇒ use `English`; `word_templates_path` empty ⇒ Hebrew export unavailable.

**Config-health notification (every run, until resolved).** After resolution, compare the user's `pipeline-preferences.json` against the plugin's blank template at `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json`:
- **Missing keys** (in the template, absent from the user's config) → list under "outdated config."
- **Present-but-empty optional fields** and any **legacy `notion_*` names** found → list under "unfilled / rename."
Emit a `⚙️ Config health` block at the **end of the run output** whenever `CONFIG_HEALTH` is non-empty: one line per item (key name + one-line "what it enables"), prefixed "Optional — your run was unaffected." Then the populate path: "To set these: ask the coach (career-data update mode) or run `/career-engine:setup --phase 5` to generate an update-prompt → paste in Chat → repackage the `.skill` → reinstall via Customize → Skills (and re-apply in Code if you use both)." This block repeats every run until the user resolves the items; because it diffs the live template, any future key added to the schema surfaces here automatically. Never write `career-data` directly to fix it (R-37 / June-18 anti-pattern) — the notification only detects and routes.

**Writing personal data (R-37).** Any write to a personal-data file targets `${CAREER_DATA}/references/...`. In Claude Code, write it directly. In Cowork (the skills mount is read-only), do NOT write the skill — stage the change to the output folder as `pending-career-data-updates.md` and emit the Appendix-A handoff prompt (`${CLAUDE_PLUGIN_ROOT}/references/career-data-skill-handoff.md`) for the user to apply in Chat; never write a divergent copy. After any successful direct write, refresh the `career-data` backup export in the output folder. New Section 7-grade career facts are flagged for approval, never auto-written.

**Three to five files per role, one file per run.**

The New Applications pipeline produces three files per role (CV DOCX, cover letter DOCX, reviewer feedback MD) plus up to two additional Hebrew files when `Languages` includes `Hebrew` (Hebrew CV DOCX, Hebrew cover letter DOCX). One file per run (LinkedIn updates MD). The DOCX files follow the same production path: cv-writer or letter-writer outputs styled markdown → the orchestrator writes the markdown to `/tmp/` → pandoc converts to `.docx` using the `.dotx` reference templates → files copy to the output folder. The reviewer feedback file is written in Step 7d. The LinkedIn updates file is written in Step 8 after all roles complete. Writing markdown to `/tmp/` is a required production step, not optional.

**Load `career-engine-export` before processing the first role.**

If `career-engine-export` is not loaded when you reach the DOCX export step, back up and load it.

**Run end-to-end. Do not stop to ask the user about scope — not before launch, not at the queue report, not mid-run.**

The career coach caps the run and selects which roles process this session. That cap is the decision. Do not pause after Role 1 to ask whether to continue. Do not ask whether to batch DOCX conversion. Do not ask whether the run is too long.

If a single role fails, log the failure and move to the next role. The only valid mid-run pauses are a hard unrecoverable system error or the user explicitly typing a stop command in chat.

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

Load these skills in order before doing anything else. Do not begin processing until all three are loaded.

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

**The orchestrator owns the Interested queue.** It fetches Interested roles directly via the database adapter (Status = `Interested`), runs a readiness check, builds the processing queue, and passes it to `career-engine-new-application`. It does NOT delegate queue-fetching to `career-engine-intake` — intake processes only Hold roles and is never called from here.

### Step O1 — Fetch Interested roles (via the database adapter)

These are database operations. **Load `${CLAUDE_PLUGIN_ROOT}/skills/database-notion/SKILL.md`** — the Notion adapter, mandatory when `database_backend` is `notion` (the default) — and follow it:
- **§1 Schema read** — fetch the schema reference (the SQLite `CREATE TABLE` block) and keep it in context for all property writes. If the schema fetch fails, stop and report.
- **§2 Read ladder** — query the queue with **target status `Interested`** (A1 → A2 → B). On Path B: if `$NOTION_INTERESTED_VIEW_URL` is non-empty, use it directly as the view URL (skips the 59KB DB discovery fetch); otherwise the adapter resolves the "Interested" view via **§3 view discovery** (one DB fetch → read the `<views>` block → match by name — never a `collection://` fetch). Then per-page `notion-fetch` for properties (discovery-only, R-1).
- If every rung fails, stop and report — never treat it as zero results, and never improvise `notion-search` (R-39).

(If `database_backend` is ever not `notion`, load that backend's adapter instead — the operation is the same: read schema, query the `Interested` queue.)

Report count: "Found N Interested roles."

**Empty queue (genuine zero):** if the read ladder succeeds but returns **0 `Interested` roles**, this is a clean terminal stop, not a failure and not a scoping question. Report plainly — "No roles with Status = Interested. Move a role from Hold → Interested (or add one as Interested) and re-run." — and stop. Do NOT ask how to scope the run, do NOT fall back to another status, and do NOT improvise a search.

### Step O2 — Readiness check

For each fetched role, verify these **writer-needed fields** are populated (non-empty):
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

Run `career-engine-new-application` Steps 1 through 7 for each role in queue order. Step 8 (LinkedIn updates) is orchestrator-owned and runs ONCE after the per-role loop completes — see `orchestrator-post-run.md` *Step 8 — LinkedIn Updates File*. It is not part of the per-role new-application pipeline; do not run it inside the loop.

**Carry all resolved config vars into every role's execution.** The preflight set `$OUTPUT_FOLDER`, `$DRAFT_DIR_URL_BASE`, `$CV_TEMPLATE`, `$DEFAULT_LANGUAGE`, `$OUTPUT_DIR_PREFIX`, `$CAREER_DATA`, and `$NOTION_DATABASE_ID`. These must remain in scope through every step of new-application — including Step 7a (which builds the Draft Directory URL from `$DRAFT_DIR_URL_BASE`) and Step 6 (which uses `$CV_TEMPLATE` and `$OUTPUT_FOLDER`). If any of these is unset when a step needs it, stop and report rather than silently defaulting or skipping.

**Pipeline is determined by the user's chat command**, not by a Notion property she sets per-role. All `Interested` roles default to the standard cv pipeline unless the user specifies otherwise in chat.

| Pipeline | What runs | Deliverables |
|---|---|---|
| `New Applications` (default) | cv pipeline — Steps 1 through 7 per role, then orchestrator Step 8 once | CV DOCX + cover letter DOCX + feedback MD |
| `--now` | fast track — see `orchestrator-modes.md` | CV DOCX + feedback MD + cover letter DOCX only if Why I Want This Role content is provided in chat |
| `Needs editing` | career-engine-edit (separate skill) — Steps E0 through E10 | Updated CV DOCX + updated cover letter DOCX; starts from existing Notion outputs, not from scratch. Trigger when the user says "edit CVs" or similar, or when roles have Status = Needs editing. |

The JD for each role was already in Notion (`JD Body`) when fetched in Step O1. Pass it directly to per-role sub-agents — do not re-fetch.

**When all roles complete, load `orchestrator-post-run.md` and continue.**
