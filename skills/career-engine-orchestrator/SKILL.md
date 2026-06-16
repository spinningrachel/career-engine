---
name: career-engine-orchestrator
description: Run {{USER_FIRST_NAME}}'s career-engine pipeline against her Notion Job Applications database. Trigger whenever {{USER_FIRST_NAME}} says "run the career engine", "process the CV queue", "run the CV pipeline", or any variant referencing a batch of tailored CVs or cover letters. Fetches all queued roles from Notion, passes them to the employment coach (which fetches JDs and produces strategic properties), builds the processing queue, and routes each role to the pipeline {{USER_FIRST_NAME}} specifies in chat.
---

# New Application Orchestrator

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

## Role

The orchestrator coordinates {{USER_FIRST_NAME}}'s career engine from start to finish. It fetches roles, delegates every reasoning and writing task to sub-agents, routes outputs, and delivers a concise final summary. It does not write CVs or cover letters, does not review applications, and does not make judgment calls about fit.

The New Applications pipeline produces three deliverables per role: a tailored CV, a cover letter, and a reviewer feedback file. All three are required outputs.

Sub-agents handle all reasoning work. Mechanical actions — Notion queries, priority writeback, DOCX export, Notion writeback, feedback file — run inline without spawning sub-agents.

---

## Absolute Constraints

These rules govern every run without exception. Read them before doing anything else.

**The orchestrator runs in the main session context — never as a spawned subagent.**

The orchestrator uses Bash to write files (markdown, DOCX, state.json, feedback) to {{USER_FIRST_NAME}}'s output folder. Bash in a sandboxed subagent context does not have access to the real filesystem and cannot write to the output folder — it will silently write to a session scratchpad instead. Therefore: the orchestrator must always be invoked directly in the main session, not spawned via the Agent tool. Only analysis and writing agents (cv-writer, letter-writer, reviewers, gatekeeper) are spawned as subagents — they return text only, they do not write files.

**The orchestrator never authors document content.**

CV and cover letter text is produced only by cv-writer, letter-writer, and the humanizer. The orchestrator's editing authority is limited to the mechanical inline fixes explicitly authorized in the gatekeeper loop steps (swap a word, remove one phrase, reorder paragraphs — zero creative judgment). It never composes sentences, merges drafts, picks between bases, or assembles a final document from parts. If a writer keeps failing, the cap rules apply: deliver the last passing version flagged for manual review. A hand-assembled document has bypassed every gate and must never be exported.

**Writer regression is corrected by re-spawning, never by patching.**

Maintain a per-document **fix log** across every revision loop: each entry records the violation and the fix applied. Every revision spawn receives the full fix log with this instruction verbatim: "These violations were already fixed in earlier rounds. Reintroducing any of them is itself a FAIL. Treat the fixed phrasings as locked unless they violate a current rule." If a writer returns text that reverts to an older base or reintroduces a fixed violation, name the regression explicitly and re-spawn with the fix log — do not fix the text yourself beyond the authorized mechanical scope.

**A PASS is only valid against the exact bytes that ship.**

Any text change after a gatekeeper PASS — including the humanizer's changes — invalidates that PASS. The final verification gate in the pipeline steps (post-humanizer gatekeeper pass plus the mechanical pre-export checklist) must run on the exact markdown that will be converted to DOCX. Never export a document whose final text was not the text a PASS was issued against.

**Outputs go to {{USER_FIRST_NAME}}'s output folder — never to a session scratchpad.**

The only valid output destination is:
`{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`

**Mandatory path verification — run before processing the first role.** Run the *Mandatory career-data discovery* (below) FIRST — it resolves `${CAREER_DATA}` and reads `$OUTPUT_FOLDER` and `$CV_TEMPLATE` from the career-data config (R-38). The plugin keeps `{{OUTPUT_FOLDER}}` literal; never treat that placeholder as a path. Two access paths, tried in order (R-30). A failed Path A is an environment limitation, not a missing folder — it does not end the run by itself.

**Path A — direct filesystem** (Claude Code, or the output folder is connected to the session):

```bash
OUTPUT_DIR="$OUTPUT_FOLDER/${OUTPUT_DIR_PREFIX:-applications}-$(date +%Y-%m-%d)"
mkdir -p "$OUTPUT_DIR"
[ -d "$OUTPUT_DIR" ] && echo "Output dir confirmed (Path A): $OUTPUT_DIR"
```

**Path B — host-bridge MCP** (sandboxed environments, e.g. Cowork, where sandbox Bash cannot reach the user's filesystem): if Path A fails, discover host filesystem tools via ToolSearch — search for `Desktop Commander`, `read_file`, `write_file`, `create_directory`, `start_process`, or equivalent host filesystem/process tools — and verify access by listing `$OUTPUT_FOLDER` (resolved from the career-data config) through the strongest available tool. If access is confirmed, proceed, and route ALL file operations for this run through those tools: directory creation, file reads and writes, and every pandoc command (via the host process tool, e.g. `start_process`). Sandbox `/tmp/` is not visible to host-side pandoc — on Path B, write intermediate markdown through the host tool to the output company directory (or a host temp path) instead of sandbox `/tmp/`.

**Both paths fail → stop the run immediately** and report to {{USER_FIRST_NAME}}: the run needs either the output folder connected to the session or a host filesystem tool (e.g. Desktop Commander) enabled. Do not proceed.

**The no-scratchpad rule is unchanged and applies on both paths.** Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support". Path B writes to the same real output folder — through a different tool, never to a substitute location.

**If host access is lost mid-run** (e.g. the MCP disconnects): retry the operation once. If still unreachable, do not improvise a fallback path — deliver the remaining file contents in chat flagged for manual save, log the failure in the run-level revision log, and continue the run's non-file steps.

**Mandatory career-data discovery — run before loading any personal reference (R-37).** The user's personal data lives in the external `career-data` skill, not in the plugin. Resolve it once here, treat the resolved directory as `${CAREER_DATA}` for the whole run, and pass it to every spawned agent.

1. Locate the `career-data` skill directory on the current surface (the loaded-skill path in Code; the readable skills mount in Cowork). Confirm `career-data-marker.json` is present at its root.
2. Set `${CAREER_DATA}` to that directory. Personal-data files load from `${CAREER_DATA}/references/...`. The plugin's `${CLAUDE_PLUGIN_ROOT}/references/...` copies are blank templates and serve only as the new-user fallback.
3. Three outcomes:
   - **Healthy** — marker present and every file in the marker's `expected_files` present and non-empty → proceed.
   - **Damaged** — marker present but an expected file missing or empty → **stop the run**, name the file, tell {{USER_FIRST_NAME}} to restore `career-data` from the output-folder backup. Do NOT fall back to templates (R-28 class).
   - **Absent** — no `career-data` found (marker also absent) → check the output folder for a `career-data` backup export. Backup present → configured user, offer to restore. No backup → genuine new user: run `/career-engine:setup` (blank templates are the correct starting point only here).

**Personal-data files** (load from `${CAREER_DATA}/references/`): `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx`. **Doctrine files** stay on `${CLAUDE_PLUGIN_ROOT}/references/`: the self-checks, `REFERENCES.md`, `remote-compatibility-rules.md`, `he-terminology-guide.md`, and the default `.dotx` templates. Inject `CAREER_DATA=<resolved path>` into every agent spawn prompt so each subagent reads personal data from that same root.

**Config resolution (R-38).** Read the **full** per-install config from `${CAREER_DATA}/references/pipeline-preferences.json` and resolve EVERY `{{CONFIG}}` placeholder from it — the single build keeps them all literal. Keys: `notion_database_id`, `output_folder` (absolute), `cv_template` (relative to `${CAREER_DATA}`, e.g. `references/<lastname>.dotx`), `draft_dir_url_base` (or `skip`), `output_dir_prefix` (optional; defaults to `applications`), `default_language` (optional; defaults to `English`), `word_templates_path` (Hebrew; optional), `notion_needs_editing_view_url` (edit pipeline; optional), `gap_handling`, `location_compatibility` (optional object: `{"my_location": "<city/country>", "notion_property": "<Notion property name>"}`; if absent or empty, location compatibility check is skipped entirely), `favorite_brands` (optional array of company name strings; if absent or empty, no brand boost applied). Set the matching shell vars (`$NOTION_DATABASE_ID`, `$OUTPUT_FOLDER`, `$CV_TEMPLATE`, `$DRAFT_DIR_URL_BASE`, `$OUTPUT_DIR_PREFIX`, `$DEFAULT_LANGUAGE`, `$WORD_TEMPLATES_PATH`, `$NOTION_NEEDS_EDITING_VIEW_URL`), pass them to every spawn and downstream skill, and wherever a skill's text shows one of these `{{...}}` placeholders, use the resolved value. **Required for any run:** `output_folder`, `cv_template`. **Also required for any Notion run:** `notion_database_id`. If a required key is missing or empty, stop with: "career-data is missing config key `<name>` — run `/career-engine:setup --phase 5`." Optional keys absent → treat as unconfigured (`draft_dir_url_base` empty/`skip` ⇒ leave Draft Directory blank; `output_dir_prefix` absent ⇒ use `applications`; `default_language` absent ⇒ use `English`; `word_templates_path` empty ⇒ Hebrew export unavailable). This is the gap that broke the first two live runs (R-38): the plugin carries no substituted config, so the config file must supply all of it.

**Writing personal data (R-37).** Any write to a personal-data file targets `${CAREER_DATA}/references/...`. In Claude Code, write it directly. In Cowork (the skills mount is read-only), do NOT write the skill — stage the change to the output folder as `pending-career-data-updates.md` and emit the Appendix-A handoff prompt for the user to apply in Chat; never write a divergent copy. After any successful direct write, refresh the `career-data` backup export in the output folder. New Section 7-grade career facts are flagged for approval, never auto-written.

**Three to five files per role, one file per run.**

The New Applications pipeline produces three files per role (CV DOCX, cover letter DOCX, reviewer feedback MD) plus up to two additional Hebrew files when `Languages` includes `Hebrew` (Hebrew CV DOCX, Hebrew cover letter DOCX). One file per run (LinkedIn updates MD). The DOCX files follow the same production path: cv-writer or letter-writer outputs styled markdown → the orchestrator writes the markdown to `/tmp/` → pandoc converts to `.docx` using the `.dotx` reference templates → files copy to the output folder. The reviewer feedback file is written in Step 7d. The LinkedIn updates file is written in Step 8 after all roles complete. Writing markdown to `/tmp/` is a required production step, not optional.

**Load `career-engine-export` before processing the first role.**

If `career-engine-export` is not loaded when you reach the DOCX export step, back up and load it.

**Run end-to-end. Do not stop to ask {{USER_FIRST_NAME}} about scope mid-run.**

The employment coach caps the run and selects which roles process this session. That cap is the decision. Do not pause after Role 1 to ask whether to continue. Do not ask whether to batch DOCX conversion. Do not ask whether the run is too long.

If a single role fails, log the failure and move to the next role. The only valid mid-run pauses are a hard unrecoverable system error or {{USER_FIRST_NAME}} explicitly typing a stop command in chat.

**The named pipeline command is the routing authority. Do not re-scope it before launch.**

When {{USER_FIRST_NAME}} invokes a pipeline by name ("run a new application pipeline", "run the edit pipeline", "run intake"), that command decides the route. Row metadata — `Edit type`, `Last Pipeline Run`, prior outputs on disk, recent Status changes — is context, never a veto. Do not pause before launch to ask whether she meant a different pipeline, whether the roles were "already processed", or how to scope the run. The command already answered those questions. If the metadata suggests another pipeline might also be relevant, add a one-line note to the briefing and proceed with the pipeline she named.

**Cover letters lead with strength and never volunteer scope or qualifications.**

This rule governs every agent that touches cover letter content:
- Different domains and verticals are never a gap, never a weakness, and never referenced as a limitation in a cover letter.
- If there is any perceived skill gap a hiring manager might notice, the letter names the work {{USER_FIRST_NAME}} has done, names what was actually done, and lets it stand. It does not add a scope qualifier the hiring manager did not ask for. Phrases like "one product, not a portfolio," "smaller than the rest of my CV," "narrower than full-time" — all forbidden.
- If letter-writer or any cover letter agent produces language that qualifies, hedges, or volunteers scope, return it for revision before accepting the output.

---

## Configuration

**Job Applications database:** Notion database ID `{{NOTION_DATABASE_ID}}`. Source of job descriptions and destination for per-role updates.

**Output folder:** `{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`

Each role's files go in a subdirectory inside the run folder named after the hiring company (see company directory naming convention in `career-engine-export`). After all files for a role are produced and verified **on disk** (confirmed via `ls`), the orchestrator writes the file directory URL to the `Draft Directory` URL property on the Notion row. All English and Hebrew files for the role are accessible from that directory URL.

**`Draft Directory` property:** URL property. Written in Step 7a — only after both DOCX files are confirmed present and nonzero on disk via `ls`. **Never written before files are confirmed on disk.** If the `ls` check fails, the role is flagged as incomplete and Notion is not updated for that role. Value formula:

```
{{DRAFT_DIR_URL_BASE}}<date-folder>%2F<company_dir>%2F
```

Where `<date-folder>` = the run folder name (e.g. `${OUTPUT_DIR_PREFIX:-applications}-2026-05-26`) and `<company_dir>` = the kebab-case company directory name.

**`Languages` property:** Multi-select on the Notion row. Expected options: `English`, `Hebrew`. If `Hebrew` is present, the pipeline automatically runs the Hebrew localization step (Step 6H) after English DOCX export and produces two additional DOCX files in the same company subdirectory. No extra configuration required.

---

## Skills to Load

Load these skills in order before doing anything else. Do not begin processing until all four are loaded.

**Note:** `01-writing-rules.md` is pre-loaded by the `/career-engine` command. If invoking the orchestrator directly (not via the command), load `${CAREER_DATA}/references/01-writing-rules.md` first (per the career-data discovery preflight above) — it contains the fabrication rule and all constraint definitions that every downstream agent depends on.

1. `career-engine-intake` — Steps 0 through 0.9d: Notion fetch, JD fetching, coach invocation, priority writeback, queue building, Status writeback
2. `career-engine-new-application` — Steps 1 through 7: per-role CV writing, gatekeeper checks, reviews, cover letter (letter-writer), HM cover letter review, DOCX export (including Step 6H Hebrew), Notion writeback
3. `career-engine-edit` — Steps E0 through E10: editing pipeline for `Needs editing` roles; starts from existing Notion row content, not from scratch
4. `career-engine-export` — DOCX template styles, pandoc commands, file naming, `/tmp → output folder` copy protocol, page count verification

## Notion Property Ownership

Each Notion property in the Job Applications database has a single designated owner. Agents write each piece of information once, to the correct field, and must not duplicate content across properties.

**Employment coach owns exclusively:**

*Strategic properties (written for all roles — triage-exit and full-research):*
`Priority`, `Priority Reason`, `JD Body`, `JD Fetch Status`, `Role Type`, `Relationship type`, and the location compatibility property (name from `pipeline-preferences.json` → `location_compatibility.notion_property`; written only if configured).

*Strategic properties (written for full-research roles only — Priority 1–4, pre-scored, or `--full-research`):*
`Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Gap handling`, `Role summary`, `Company Stage`, `Landscape`, `Person who Advertised Role (if not Hiring Manager)`, `Hiring Manager's Name`, `Hiring manager's role`, `Manager role confirmed`, `No incumbents in this function`, `First Advertised`, `Recent news`, `Funding context`.

No other agent rewrites or second-guesses any of these. **`Gap handling` is the exception to the carry-forward rule — if {{USER_FIRST_NAME}} has edited it in Notion, the pipeline reads her version as authoritative. The write-only-to-empty rule enforces this: if the field is non-empty, the coach skips writing.**

**Mandatory value rule:** Every coach-owned property that the coach writes must receive an explicit value — `N/A` when genuinely inapplicable. A blank field signals agent failure, not inapplicability. This applies to `Company Stage` and `Role Type` in particular. **Prerequisite:** `N/A` must be present as a valid option in the Notion select fields for `Company Stage` and `Role Type` — {{USER_FIRST_NAME}} adds this directly in Notion.

**Triage-exit roles** (Priority 5–6, non-`--full-research`): only the first group of properties above is written. Full-research properties are skipped — they remain blank and are not required for triage-exit roles.

**`Why I Want This Role` is set manually by {{USER_FIRST_NAME}} in Notion.** Agents never write to it. If it is empty when the pipeline runs, the cover letter is skipped for that role — only the CV is delivered.

**The `Note` field is {{USER_FIRST_NAME}}'s space.** Agents may write to it only for context that structured properties cannot carry — never to repeat or summarize content already in a structured property.

---

## Role Type Definitions

Role Type is a multi-select property set exclusively by the employment coach. Choose all that apply — roles commonly combine types.

| Value | Definition |
|---|---|
| `Builder` | First or founding hire; building the function or infrastructure from zero with no team or existing motion |
| `Scaler` | Growing an existing function, managing a team, scaling what's already working |
| `Specialist` | Deep domain expert hired for a specific craft without a function-building mandate |
| `Leader` | Explicitly managing people; leadership-team membership expected from day one |

Multi-select examples: "Builder, Leader" = founding hire who also owns people management. "Scaler, Specialist" = growing a specialist function (e.g., scaling a PMM team with deep product marketing craft required).

**Effect on CV structure:** Builder or Leader → one-line skills, no Key Achievements section (function-builder framing). Scaler or Specialist → categorized skills block, compact Key Achievements acceptable (craft/scaling framing). When combined, lead with the stronger signal for the specific JD.

---

## Status Definitions

Status is the single property that drives what the pipeline does with a role. {{USER_FIRST_NAME}} sets and updates it in Notion; agents update it at pipeline completion only.

| Status | Who sets it | Meaning |
|---|---|---|
| `Hold` | {{USER_FIRST_NAME}} | Being researched before a decision to apply. **NOT handled by this (CV-writing) pipeline.** Two upstream paths can process Hold roles: the coach standalone pipeline (`/career-engine --coach-skills`) for full market intelligence (competitive landscape, PMM analysis), or career-engine-intake standalone for quick coach properties. Both promote Hold roles to Researched when complete. |
| `Interested` | {{USER_FIRST_NAME}} | {{USER_FIRST_NAME}} has decided to apply. **This is what career-engine-intake and the main career-engine pipeline pull.** Move a role from Hold → Interested (or add directly as Interested) when {{USER_FIRST_NAME}} wants a CV and cover letter produced. |
| `Needs editing` | {{USER_FIRST_NAME}} | Queued for the editing pipeline. Pipeline starts from existing outputs in the Notion row — does not run fresh. |
| `CV Ready for Review` | Pipeline (on completion) | Pipeline finished; {{USER_FIRST_NAME}} needs to review before sending. |
| `Applied` | {{USER_FIRST_NAME}} | Sent. |
| `Researched` | Coach standalone pipeline (on completion) | Coach has run market intelligence — competitive landscape, priority scoring, strategic properties, PMM expert analysis. Role is ready for {{USER_FIRST_NAME}} to decide whether to move to Interested. |

**Pipeline reads:** `Interested` (main pipeline and career-engine-intake) and `Needs editing` (editing pipeline). All other statuses — including `Hold` and `Researched` — are ignored by this pipeline.

**The two upstream pipelines are separate:**
- `/career-engine --coach-skills` → researches **Hold** roles → sets Status to **Researched**
- `career-engine-intake` (Steps 0–0.9d) → prepares **Interested** roles → feeds the CV writing pipeline

---

## Priority Definitions

**`Priority`** is the sole queue ordering signal. It is set by the employment coach **during intake only** — that is the one and only place scoring happens. The New Application pipeline never scores: it reads the `Priority` intake already wrote and uses it purely for queue order (an unscored role still processes, just ordered last). Values and meanings:

| Label | Notion value | Meaning |
|---|---|---|
| `Highest` | `1` | Urgent — drop everything, run this role first |
| `First` | `2` | Excellent fit — strong domain, right seniority, right stage, no red flags |
| `Second` | `3` | Strong fit — domain or seniority match is clear; minor friction elsewhere |
| `Third` | `4` | Reasonable fit — worth applying but the cover letter has work to do |
| `Fourth` | `5` | Weaker fit — possible if {{USER_FIRST_NAME}} wants to stretch |
| `Fifth` | `6` | Weakest fit in this batch. Also the hard floor for Open Application entries regardless of any other criterion. |

**Always write the numeric Notion value (1–6) when setting Priority via `notion-update-page`.** The label names are internal shorthand — Notion rejects them as select values.

Roles with `Priority` already set are always selected into the queue before unscored roles, ordered 1 → 6. Unscored roles fill any remaining slots and are processed in queue order after the scored ones. In the New Application pipeline the coach is **not** spawned to score them (R-42 — the coach runs only in standalone intake); an unscored role is still processed, and `Priority` affects ordering only.

**Open Application hard floor:** Roles identifiable as open/speculative/unsolicited applications (no specific listing posted) must always sort and be treated as `6` (Fifth) in the queue, regardless of any Priority value currently in Notion. The coach will write `6` to Notion in Step 0.8. If the coach is skipped (all coach-complete), verify any open application entry is set to `6` before queue ordering — correct it inline if not.

---

## Pipeline Registry

The complete list of pipelines this plugin can run. Before taking any action, confirm it belongs to the pipeline you are running — anything owned by another pipeline's row is out of scope and must not be improvised.

| # | Pipeline | Trigger | Entry skill | Hard preconditions | Status transitions owned | Never does |
|---|---|---|---|---|---|---|
| 1 | Setup | `/career-engine:setup`, "set up the plugin" | `career-engine-setup` | none | none | Writes no application content |
| 2 | Sourcing | "find open roles", "source roles" | `source-open-roles` | preferences saved | creates rows (new roles enter as `Hold`) | Never writes CVs or letters |
| 3 | Intake | "run intake", `--coach-skills` | `career-engine-intake` | database configured | `Hold` → `Researched` (standalone mode only) | Never writes CVs or letters; never creates or modifies Notion views |
| 4 | New Application | career-engine command, no flag | `career-engine-orchestrator` + `career-engine-new-application` | Intake has run; `Why I Want This Role` filled for any role needing a letter | `Interested` → downstream statuses per orchestrator | Orchestrator never authors document content |
| 5 | Fast track | `--now <url or JD>` | `career-engine-orchestrator` → --now Mode | Why I Want This Role collected in chat, else CV-only | none — no Notion row | Never reads or writes Notion |
| 6 | Edit | "edit CVs", `--edit`, Status = `Needs editing` | `career-engine-edit` | `Edit type` set; `Why I Want This Role` populated for the letter track | `Needs editing` → `CV Ready for Review` | Never starts from scratch; always edits the existing Notion-documented outputs |
| 7 | Localization | automatic when `Languages` includes the second language | `localization` | English DOCX files complete | none | Translation only — never drafts, revises, or evaluates |
| 8 | LinkedIn coach | "review my LinkedIn", "optimise my profile" | `linkedin-coach` | none | none | Never writes to Notion |
| 9 | Personal brand | "build my personal brand", "refresh my bio" | `personal-brand` | none | none | Never writes to Notion |

**One-pass utility modes** (no loops, no Notion writeback): `--coach` (conversational fit assessment), `--check` (single gatekeeper pass on pasted text), `--review` (single recruiter + HM pass), `--write-letter` (standalone letter draft), `--status` (read state.json and report).

## Pipeline Flow

Run the queue pipeline first (`career-engine-intake`). When the processing queue is built and {{USER_FIRST_NAME}} has been briefed, run the per-role pipeline for each role in queue order.

**Mode for career-engine-intake:** When `career-engine-intake` runs as part of this pipeline, it operates in **orchestrator mode** — it queries the database directly with a Status filter for `Interested` (not Hold) and applies orchestrator-mode queue selection (scored roles first, ordered 1 → 6, then unscored).

**Pipeline is determined by {{USER_FIRST_NAME}}'s chat command**, not by a Notion property she sets per-role. All `Interested` roles default to the standard cv pipeline unless {{USER_FIRST_NAME}} specifies otherwise in chat. {{USER_FIRST_NAME}} can request a different pipeline for specific roles at run time.

| Pipeline | What runs | Deliverables |
|---|---|---|
| `New Applications` (default) | cv pipeline — Steps 1 through 8 | CV DOCX + cover letter DOCX + feedback MD |
| `--now` | fast track — see below | CV DOCX + feedback MD + cover letter DOCX only if Why I Want This Role content is provided in chat (see Step N4) |
| `Needs editing` | career-engine-edit (separate skill) — Steps E0 through E10 | Updated CV DOCX + updated cover letter DOCX; starts from existing Notion outputs, not from scratch. Trigger when {{USER_FIRST_NAME}} says "edit CVs" or similar, or when roles have Status = Needs editing. |

The structured JD for each role was fetched in Step 0.5 of the queue pipeline and is already in memory. Pass it directly to per-role sub-agents — do not re-fetch.

---

## --now Mode (Single-Role Fast Track)

Use when {{USER_FIRST_NAME}} provides a URL or pastes a JD directly in chat and needs documents immediately, without going through the Notion queue. **No Notion interaction at all** — no reading, no writing.

### When to use
{{USER_FIRST_NAME}} says something like: "Write my CV for this now", "/career-engine --now <url>", "I just found this job, do it", or pastes a JD with an urgent framing.

### Flow

**Step N1 — Determine input**

Check what {{USER_FIRST_NAME}} provided:
- A URL → proceed to N2 with that URL
- Pasted JD text (no URL) → skip N2, treat the pasted text as the JD body and proceed to N3 directly

**Step N2 — Prepare JD content**

If {{USER_FIRST_NAME}} provided a URL: pass it directly to the coach in Step N3. The coach fetches it as part of its pre-flight.

If {{USER_FIRST_NAME}} pasted JD text (no URL): treat it as the JD body directly. Pass it to the coach in Step N3 — no fetch needed.

If the coach cannot access the URL: it will report the failure. Tell {{USER_FIRST_NAME}} and stop — do not proceed without usable JD content.

**Step N3 — Lightweight employment coach**

Spawn `employment-coach` in pipeline mode with a single role. Pass the structured JD and `01-writing-rules.md`. Instruct the coach: **produce strategic properties only — no Notion writeback, no patterns section, no batch analysis.** Return: Role emphasis, Keywords, Strategy, Role Type, Relationship type, Gap handling. This is a fast single-role pass, not a batch run.

No Notion writeback for coach outputs in `--now` mode.

**Step N4 — Per-role pipeline**

Run `career-engine-new-application` Steps 1 through 7d exactly as in the standard pipeline. The only differences:
- **Why I Want This Role (before Step 5)** — no Notion row exists, so the field cannot be read. Ask {{USER_FIRST_NAME}} in chat: "Why do you want this role? One or two sentences in your own words — this becomes the letter's opener. Reply 'skip' for CV only." If she provides content, use it as the Why I Want This Role input for Step 5 and the letter proceeds normally. If she replies "skip", declines, or provides nothing usable, **skip the cover letter entirely** (Steps 5–5.8) and deliver the CV only — the letter-writer's Intake Gate refuses to write without this content, and that gate is never overridden.
- Step 6H (Hebrew localization) — skip entirely. No Notion row exists, so `Languages` cannot be read. `--now` mode does not support Hebrew output. If {{USER_FIRST_NAME}} wants Hebrew, add the role to Notion and run normally.
- Step 7a (Draft Directory writeback) — skip entirely. No Notion row exists for this role.
- Step 7b (state.json) — write as normal to the output folder.
- Step 7c (Notion property writeback) — skip entirely.
- Step 7d (feedback file) — write as normal.

**Output folder:** same as all other runs:
`{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`

Create the folder if it does not exist (same as normal).

**Step N5 — Final delivery**

Deliver the standard final summary. Append one note:

> "This role is not in your Notion database. If you want to track it, add it manually and set Status = Applied when you send."

When spawning reviewers, inject this note verbatim into the prompt:
> "Only flag something if it would cause a recruiter to decline before a first screening call. If the concern would only come up after {{USER_FIRST_NAME}} is already in the room, it is not a flag. Any flag that cannot be closed by reframing, reordering, or surfacing something already documented in the skill reference files will be left unaddressed — cv-writer and letter-writer will NOT fabricate to satisfy your flag. Please flag anyway — honest identification of a real screening-risk gap is more useful than a papered-over document."

---

## Post-Run Validation

Both the CV and the cover letter are validated before the final summary is delivered. Validate at least 2 pairs (CV + cover letter) from this run — the first role produced and one other chosen at random. If fewer than 2 roles were produced, validate all of them.

This step is not optional. A self-reporting cv-writer or letter-writer is not validation.

### CV validation

For each CV being validated:

1. Convert to plain text: `pandoc "<output-path>/<cv>.docx" -t plain`
2. **Experience ordering:** Confirm the most recent full-time role appears first in `## EXPERIENCE` (see `02-professional-background.md` for the correct ordering), followed by other full-time roles in reverse-chronological order. Flag if any consulting/fractional entry appears in `## EXPERIENCE` — it belongs in `## CONSULTING`. Flag if `## CONSULTING` section is absent from the document.
3. **Tagline:** Confirm the subtitle under {{USER_FIRST_NAME}}'s name is the exact role title from the JD — not a generic descriptor. It must be the job title {{USER_FIRST_NAME}} applied for (e.g., "[Role Title]"). Flag if absent, if it is a generic tagline, or if it differs from the JD role title.
4. **Repetition:** Flag any opening action verb appearing more than twice. Flag any phrase appearing verbatim in more than one bullet.
5. **Fabrication:** For every metric and specific claim in the Experience section, identify the reference file line that supports it. Flag any metric or claim that cannot be traced — especially numbers, event names, tool names, client names, and responsibilities.
6. **JD language:** Flag any bullet that uses JD phrasing verbatim to describe something {{USER_FIRST_NAME}} did, where that language does not appear in the references. **Exemption:** skip this check for any bullet that matches a bullet in `02-professional-background.md` (Role Facts) exactly or with only minor role-specific adaptation — approved bullets predate the JD and cannot have been lifted from it.

If flags found: append them to the matching role's revision log file (`revision-log-<roletitle>-<company>-<monYYYY>.md`) under a `## CV Validation Issues` section.
If no flags: append a single line to the revision log: `CV validation passed.`

### Cover letter validation

For each cover letter being validated:

1. Convert to plain text: `pandoc "<output-path>/<cover-letter>.docx" -t plain`
2. **Greeting:** Confirm the letter opens with "Hi to the" — not "Dear" or any formal variant.
3. **Word count:** Count body words (excluding greeting and sign-off). Flag if over 320 words (no minimum).
4. **Key proof signals:** Confirm that key proof signals from `02-professional-background.md` (Role Facts) — the most recent role's key outcomes — are woven naturally into the body. Flag if the body contains no named outcomes from the candidate's background.
5. **Sign-off:** Confirm the letter closes with "Looking forward to next steps," followed by "{{USER_FIRST_NAME}} {{USER_LAST_NAME}}" and nothing else. Flag any additional text after the name.
6. **Opening paragraph:** Confirm the first paragraph is {{USER_FIRST_NAME}}'s personal reaction to this specific role — first person, her response to the opportunity, before any credential or company description. This check cannot be waived by coach output or Strategy. Flag if the first paragraph: leads with company analysis; leads with a career credential; leads with an availability statement; OR has {{USER_FIRST_NAME}} as the grammatical subject of the first sentence but the sentence pivots immediately to a general market/industry observation rather than her reaction to THIS role (Pattern G2 — e.g. "I've spent six years in [field], and the job — above everything else — is [general market observation]." [Example from your background]). Also flag if the very first sentence frames an industry challenge or market condition before {{USER_FIRST_NAME}} appears as a reacting subject (Pattern I).
7. **Fabrication:** For every specific claim, number, or named outcome in the letter, identify the reference file line that supports it. Flag any claim that cannot be traced to `01-writing-rules.md`.
8. **Voice:** Flag any sentence that opens with a gerund, prepositional phrase, or dependent clause instead of {{USER_FIRST_NAME}} as subject. Flag any hollow phrase from the banned list in `skills/cover-letter/SKILL.md`.

If flags found: append them to the matching role's revision log file under a `## Cover Letter Validation Issues` section.
If no flags: append a single line to the revision log: `Cover letter validation passed.`

---

## State File

`state.json` is a crash-recovery file — not a run-history log. It records roles that reached Step 7b (post-DOCX, pre-Notion-writeback or later). A role that crashed before Step 7b will not appear in it at all.

**`state.json` is the authoritative source for crash recovery:**

If a `state.json` exists in the most recent run folder and a role is marked `completed` in it, **skip that role** — regardless of when the run was, regardless of the role's current Notion Status. The most recent `state.json` represents actual pipeline progress. Notion writeback may have failed without invalidating what is on disk.

**When to process from scratch:** If no `state.json` exists, or a role does not appear in it as `completed`, run the full pipeline for that role from the beginning. `Interested` roles not in `state.json` always run fresh.

`Needs editing` → always run the editing pipeline using whatever is in the Notion entry. state.json is not used for the editing pipeline.

---

## --status Mode

Read-only. No agents. No Notion. Just reads the filesystem.

**Step S1 — Find the most recent run folder**

```bash
ls -1d "{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-"* | sort | tail -1
```

If no run folder exists, report: "No pipeline runs found."

**Step S2 — Read state.json**

```bash
cat "<most-recent-folder>/state.json"
```

If state.json is missing, report: "state.json not found in `<folder>` — run may not have started or crashed before any role completed."

**Step S3 — Check files on disk**

For each role in state.json, verify the expected files exist. `cv_path` and `cover_letter_path` are relative to the run folder and already include the company subdirectory (e.g. `northwind/cv-{{USER_LAST_NAME}}-...docx`). Hebrew file presence is detected from filenames — if any DOCX in the company subdirectory carries the `-he` suffix (derived from `cv_path`/`cover_letter_path` with `-he` inserted before `.docx`), treat the role as having Hebrew outputs and verify both Hebrew files exist.

```bash
ls "<most-recent-folder>/<cv_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<cover_letter_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<feedback_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<revision_log_path>" 2>/dev/null && echo "✓" || echo "MISSING"
# Hebrew files — derive expected filenames from cv_path/cover_letter_path with -he suffix; check only if a -he DOCX is present in the company subdirectory
```

**Step S4 — Print summary**

```
## Run status — <session_date>

Completed: N roles  ·  Files missing: M

| Company | Role | Track | CV | Cover letter | Hebrew CV | Hebrew CL | Feedback | Revision log | HM CV | HM CL |
|---|---|---|---|---|---|---|---|---|---|---|
| <company> | <title> | <track> | ✓/MISSING | ✓/MISSING | ✓/—/MISSING | ✓/—/MISSING | ✓/MISSING | ✓/MISSING | <hm_cv_verdict> | <hm_cl_verdict> |
...
Note: — means no Hebrew was produced for that role (Languages did not include Hebrew).

<if all files present for all roles>
All files accounted for. Notion writebacks happened during the run — check row Status in Notion to confirm.

<if any file MISSING>
Files marked MISSING exist in state.json but were not found on disk. See Crash Recovery below.
```

If any role's cover_letter_path is null or empty in state.json, note it: that role may have crashed before the cover letter completed.

---

## Crash Recovery

### What state.json captures — and doesn't

state.json records roles that **completed Step 7b** (all three files produced, state written). It does not capture:
- Roles that started but crashed before DOCX export
- Which step within a role's pipeline failed
- Whether Notion writeback (Steps 7a, 7c) succeeded after state was written

### Diagnosing where a run crashed

**If state.json has fewer roles than expected:** One or more roles crashed before completing. The crashed role will still have Status = `Interested` in Notion. Check the output folder for partial files (markdown backups from Steps 4 and 5.7 land there as `.md` files).

**If state.json has all expected roles but a file is MISSING on disk:** The state was written but the file copy failed or was deleted after the run. The markdown source file in `/tmp/` is gone; re-run that role.

**If state.json is complete and all files are present but Notion rows still show `Interested`:** Step 7c (Notion writeback) failed after state was written. The files are good. Manually update each Notion row: set Status to `CV Ready for Review` and write the Draft Directory URL to the `Draft Directory` property (construct it from the `draft_dir_url` field in state.json, or derive it from the formula using the run folder date and company directory name).

### Which steps are safe to re-run

All agent steps are stateless and safe to re-run. They produce the same class of output each time — a fresh draft, review, or revision — and overwrite the previous output intentionally.

| Step | Safe to re-run? | Notes |
|---|---|---|
| 0.5 — JD content prep | Yes | Idempotent; only writes if JD Body was empty |
| 0.8 — employment coach | Yes | Fetches JDs + overwrites Notion properties ([HIGH] tags); [LOW] only fills empty |
| 1 — cv-writer draft | Yes | Overwrites previous draft |
| 1.5 / 4.5 / 5.2 / 5.8 — gatekeeper | Yes | Pure check, no side effects |
| 2 / 5.3 — recruiter-reviewer | Yes | Pure review, no side effects |
| 3 / 5.5 — hiring-manager-reviewer | Yes | Pure review, no side effects |
| 4 — cv-writer revision | Yes | Overwrites draft; markdown backup re-saved |
| 5 — letter-writer draft | Yes | Overwrites previous draft |
| 5.7 — letter-writer revision | Yes | Overwrites draft; markdown backup re-saved |
| 6 — DOCX export | Yes | Overwrites existing DOCX files (harmless if content unchanged) |
| 7a — Draft Directory writeback | Yes | Idempotent; same URL written |
| 7b — state.json | **Caution** | Appends a new record; creates a duplicate if role already in state.json. Not harmful but makes --status output noisy. |
| 7c — Notion property writeback | Yes | Idempotent; same properties written |
| 7d — feedback file | Yes | Overwrites existing feedback file (harmless) |

### The most common crash scenario: good DOCX, no Notion writeback

If the pipeline produced both DOCX files and the feedback file but crashed before Step 7a or 7c:

1. Run `--status` to confirm the files are on disk.
2. In Notion, manually set the row's Status to `CV Ready for Review`.
3. Write the Draft Directory URL to the `Draft Directory` URL property. Construct it from the `draft_dir_url` field in state.json, or derive it using the formula:
   `{{DRAFT_DIR_URL_BASE}}<date-folder>%2F<company_dir>%2F`
4. The role is done. Do not re-run it — the documents are good.

---

## Step 8 — LinkedIn Updates File

Run after all roles complete. Inline — no agent spawn. Produces one file per run (not per role): `linkedin-updates-<YYYY-MM-DD>.md`, saved to the output folder alongside the per-role files.

**Purpose:** Surface what the run's collective intelligence implies for {{USER_FIRST_NAME}}'s permanent LinkedIn profile — specifically, which keywords and framing choices recur across multiple JDs in this session, making them stronger signals than anything optimized for a single application.

**Framework primacy.** `03-framework.md` is the primary source of truth about {{USER_FIRST_NAME}}'s goals and positioning; LinkedIn is a tool the plugin helps her improve, never a source of truth about her. Treat the framework as background guidance for every recommendation. The profile is permanent and serves her whole positioning: this run's roles — including any role that represents a career shift — must not pull recommendations toward themselves unless the change also strengthens her overall positioning. Only if the framework indicates a career shift is a primary goal may recommendations deliberately support the transition.

### Step 8-pre — Load the LinkedIn profile reference

Read `${CAREER_DATA}/references/linkedin-profile.md`.

- **Profile available** (file exists and its content does not still contain the characters `{{` and `}}`): run Steps 8a–8c in **gap-analysis mode** — every recommendation is grounded in what the profile actually says today.
- **Profile not provided** (file missing or still templated): run Steps 8a–8c in **fallback mode** — keyword aggregation without profile comparison. Open the output file with the note: "No LinkedIn profile on file — these are raw market signals, not a profile analysis. Provide a LinkedIn PDF export (say 'update my references') to get recommendations based on your actual profile."

### Step 8a — Aggregate keywords

The coach returned a tiered `Keywords` string for each role processed this run (format: `Critical: ... | Important: ... | Nice-to-have: ...`). Collect all of them.

For each role, split on `|` to extract the three tier strings, then split each tier on `,` to get individual terms. Normalize each term: trim whitespace, preserve original casing. Pool all terms across all tiers into a single frequency map — record how many roles each term appeared in and which companies. Terms from Critical and Important tiers carry more signal weight than Nice-to-have, but all feed the frequency map.

**Threshold logic:**
- 3+ roles → **high signal** — likely a permanent LinkedIn gap
- 2 roles → **medium signal** — worth considering
- 1 role → omit — JD-specific, not a profile signal

Note: With a 5-role cap per run, "2 roles" = 40% of the batch. That is a meaningful pattern, not noise.

**Gap-analysis mode (profile available):** after building the frequency map, check every high- and medium-signal term against the actual profile content — headline, About, Skills list, and experience entries. Sort each term into:
- **Already covered** — the term (or a direct equivalent) appears in the profile. Report where it appears; no action needed. Do not recommend adding what is already there.
- **Genuinely missing** — the term appears nowhere in the profile. Recommend it, and name the specific profile section where it would do the most work (headline, About, Skills, or a specific experience entry).
- **Present but buried** — the term appears only deep in an old experience entry while the JDs treat it as central. Recommend surfacing it (e.g., into the headline, About, or Skills).

### Step 8b — Extract summary phrases

For each completed role, read the saved CV markdown from the output folder:

```bash
# CV markdowns are saved in the role's company subdirectory alongside the DOCX files
cat "<output_dir>/<company_dir>/<cv_filename>.md" | awk '/^## SUMMARY/{found=1; next} found && /^[^#]/ && NF{print; exit}'
```

This extracts the first non-empty paragraph after the `## SUMMARY` heading — which is the summary paragraph. Store it paired with company name and role title.

If a markdown file is missing (role used a different path or failed), skip that role's summary and note it.

**Gap-analysis mode (profile available):** compare each extracted summary phrase against the profile's actual About section and headline. Only surface a phrase as a recommendation when it says something the About section doesn't already say, or says it meaningfully better — and state which existing About sentence it would strengthen or replace. Phrases that merely restate the current About are dropped, not listed.

### Step 8c — Write the file

```bash
cat > "<output_dir>/linkedin-updates-<YYYY-MM-DD>.md" << 'MARKDOWN_EOF'
<full file content>
MARKDOWN_EOF
```

**File format:**

```markdown
# LinkedIn Updates — <YYYY-MM-DD> — <N> roles

*Accumulated across <N> roles this session, analysed against your LinkedIn profile snapshot of <profile snapshot date>. Terms appearing in multiple JDs are profile signals — they indicate what recruiters in your current target market are searching for.*
*(Fallback mode: replace the line above with the no-profile note from Step 8-pre and use the raw signal lists without the profile-comparison columns.)*

---

## Keywords

### Genuinely missing from your profile — add these

- **<term>** — <N> roles: <Company A>, <Company B> → add to: <specific profile section>
- ...

### Present but buried — surface these

- **<term>** — <N> roles — currently only in <where it appears> → surface in: <headline / About / Skills>
- ...

### Already covered — no action

- **<term>** — appears in <profile section>
- ...

*Career-shift guard: a term is only recommended if adding it strengthens the overall positioning per `03-framework.md` — not because a single role this run pointed at it.*

---

## About section — phrase upgrades

Tailored summary phrases from this run that say something your current About section doesn't — each paired with the existing About sentence it would strengthen or replace. Phrases that merely restate your About are omitted.

**<Company> — <Role Title>:**
> <phrase>
*vs. your current:* "<existing About sentence>" — <one line on why the new phrasing is stronger>

---

## Experience bullets — review manually

The CVs produced this run contain tailored bullet versions for each experience entry. Compare the saved CV markdown files to your current LinkedIn experience entries and update where the tailored version is meaningfully stronger.

Saved CV markdowns this run:
<list of cv_filename.md files from this run>
```

**Failure handling:** If the file write fails, retry once. If it still fails, surface the error in final delivery and include the full file content as plain text in chat so it is not lost. The LinkedIn updates file is a required output of every New Applications run — treat a failed write as a blocking issue, not a skip.

**Skip condition:** If only one role was processed this run (no cross-role signal possible), still write the file but note in the keywords section: "Only one role processed this session — no cross-run frequency signal. Review keywords for the single role in the CV directly."

---

## Step 9 — Run-level revision log

After all roles complete and after Step 8 (LinkedIn updates), write a single run-level revision log to the output folder:

**Filename:** `revision-log-<YYYY-MM-DD>.md`

```bash
cat > "<output_dir>/revision-log-<YYYY-MM-DD>.md" << 'MARKDOWN_EOF'
# Run Log — <YYYY-MM-DD> — <N> roles

## Cross-run decisions
<Any decision that affected all CVs or all roles. If none: "None.">

## Technical and orchestration issues
<Failures, fallbacks, writeback errors, and any unexpected or non-standard decisions made by any agent during the run. If none: "None.">
MARKDOWN_EOF
```

This file is non-blocking — if the write fails, log it in chat only.

---

## Step 9b — Bullet Approval Prompt

Run after Step 9 (revision log). For every role completed this run that produced a CV, ask once at the end of the full run — not per role:

> "New bullets were written for: **[Company A]**, **[Company B]**, **[Company C]**. Which of these should I add to your approved list? Approved bullets will be reused verbatim in future CVs for the same company. Reply with company names, 'all', or 'none'."

**If the user says 'all' or names specific companies:** For each approved company, append the bullets from the delivered CV into `${CAREER_DATA}/references/02-professional-background.md` under that company's role facts entry, under the heading `**Approved CV bullets:**`. If a bullets section already exists for that company, merge — do not duplicate bullets already present. This writes the personal data layer: in Code, write `${CAREER_DATA}` directly; in Cowork, stage the append to the output folder and emit the Appendix-A handoff (write path, §5.3) — never write a divergent copy.

**If the user says 'none' or does not respond:** Skip. Bullets remain as candidate status and will be rewritten fresh on the next run.

**Important:** Do not add approved bullets from old CVs the user submitted during setup. Only bullets the pipeline itself produced are candidates for approval.

---

## Step 9c — Run metrics

Run after Step 9b. Write a `run-metrics-<YYYY-MM-DD>.json` file to the run output folder. This file records structural metrics for the run. Actual token counts are appended by a Stop hook configured during setup — the hook writes to this same file when the session ends.

```bash
cat > "<output_dir>/run-metrics-$(date +%Y-%m-%d).json" << 'JSON_EOF'
{
  "run_date": "<YYYY-MM-DD>",
  "pipeline": "<New Applications|Edit|Intake>",
  "roles_processed": <N>,
  "roles_per_company": [
    {"company": "<name>", "track": "<cv|now>", "hebrew": <true|false>}
  ],
  "agents_invoked": {
    "employment_coach": <N>,
    "cv_writer_draft": <N>,
    "cv_writer_revision": <N>,
    "gatekeeper_cv": <N>,
    "recruiter_reviewer_cv": <N>,
    "hm_reviewer_cv": <N>,
    "letter_writer_draft": <N>,
    "letter_writer_revision": <N>,
    "gatekeeper_cl": <N>,
    "recruiter_reviewer_cl": <N>,
    "hm_reviewer_cl": <N>,
    "localization": <N>
  },
  "token_counts": "pending — written by Stop hook at session end"
}
JSON_EOF
```

Fill all values from the run state. Set each agent count from the actual invocations this run. Leave `token_counts` as the literal string `"pending — written by Stop hook at session end"` — the hook replaces this value when the session closes.

---

## Final Chat Delivery

After Step 9c completes, deliver a single confirmation line in chat:

`All N roles completed. Files are in your output folder and Notion rows are updated. LinkedIn updates file: linkedin-updates-<YYYY-MM-DD>.md`

Nothing else. All feedback, validation results, and decisions are in the revision log files in the output folder.

---

## Execution Rules

- Run roles sequentially unless {{USER_FIRST_NAME}} explicitly asks for parallel execution.
- Narrate progress briefly between steps: "Role 3/5: recruiter review done, moving to hiring manager."
- Do not deliver individual role outputs during processing — deliver everything together at the end.
- If any step fails, log it and move on. All failures are written to the run-level revision log (Step 9).
- The fabrication rule is absolute. Every claim must trace to `01-writing-rules.md`. If it is not documented there, it does not exist.
