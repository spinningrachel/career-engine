---
name: career-engine
description: "Run the career-engine pipeline. Main entry point for all career-engine commands."
argument-hint: "[--edit | --coach-skills | --coach | --now <url> | --check | --review | --write-letter]"
allowed-tools:
  # Core tools
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
  - Agent
  # Notion — job applications DB and agent reports DB
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-fetch
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-query-database-view
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-update-page
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-create-pages
  # notion-search is intentionally NOT allowlisted: it is relevance-ranked and capped,
  # cannot enumerate the queue, and must never be used to discover queue rows (R-39).
  # Job search — JD fetching
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__get_job_details
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__search_jobs
  - mcp__89f52ca2-1cd0-442d-af81-06fc3dac6f6c__search_jobs
  - mcp__c7718911-054e-4537-aa99-e7c6cc691fae__search_jobs
  # Web fetch — JD URL fetching
  - WebFetch
  - WebSearch
  # Bash handles all file system operations (output folder copy, script execution) — no additional tool needed
---

# New Application

## What This Does

This command runs {{USER_FIRST_NAME}}'s multi-agent career engine from start to finish. It fetches roles from her Notion Job Applications database, runs the employment coach for prioritization and writing guidance, generates tailored CVs and cover letters through a staged review pipeline, converts them to DOCX using pandoc, and saves files to the configured output folder. Per-role results are written back to Notion.

Without arguments, the command runs the main run against all roles with Status = `Interested`. Two flags shift the mode.

## Arguments

| Flag | What runs |
|---|---|
| *(none)* | Main run — full pipeline for all `Interested` roles |
| `--edit` | Editing pipeline — refine existing outputs for all `Needs editing` roles |
| `--coach-skills` | Market intelligence only — research companies and assign priorities; no CVs generated |
| `--coach` | Direct coaching — employment coach responds conversationally to a role question, fit assessment, or strategic framing question; no Notion writeback |
| `--now <url or JD text>` | Single-role fast track — skips Notion entirely; takes a URL or pasted JD directly; coach fetches and analyses in one pass; full per-role pipeline; outputs DOCX to the configured output folder |
| `--status` | Read state.json from the most recent run and print a completion table — which roles finished, which files exist on disk, verdicts, and any files listed in state.json that are missing |
| `--check` | Run the gatekeeper on a CV or cover letter {{USER_FIRST_NAME}} pastes or provides. Paste the document in chat and specify CV or cover letter. JD is optional but improves checks that require JD comparison. Returns PASS or FAIL with violations. One pass only — no loop. |
| `--review` | Run recruiter and hiring manager review on a CV or cover letter {{USER_FIRST_NAME}} provides. Paste the document and JD in chat. Returns both reviews in sequence. Treats prior verdicts as N/A when none exist. One pass only. |
| `--write-letter` | Write a cover letter for a single role without the full pipeline. Provide a URL or JD text. Spawns `letter-writer` in standalone mode — no CV required, no reviewers, no gatekeeper loop. Returns a cover letter draft. |

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
| 10 | Update references | "update my references", "update refs", "here's my updated CV", any shared career material to fold into references | `update-refs` | none | none | Never writes application content; never writes to Notion; never writes a reference without explicit approval |

**One-pass utility modes** (no loops, no Notion writeback): `--coach` (conversational fit assessment), `--check` (single gatekeeper pass on pasted text), `--review` (single recruiter + HM pass), `--write-letter` (standalone letter draft), `--status` (read state.json and report).

## Running the Pipeline

Load the following skills in order before doing anything. Do not spawn any sub-agent until all required skills are loaded.

**Main run (no flag):**
1. `01-writing-rules.md` — core constraints governing every agent; load first
2. `career-engine-orchestrator` — queue cap, queue selection logic, Role Type and Priority Definitions, Notion property ownership, Steps 8–9 (LinkedIn updates file, run-level revision log), Post-Run Validation, State File and crash recovery
3. `career-engine-intake` — Steps 0 through 0.9d: fetch roles, run employment coach, build queue
4. `career-engine-new-application` — Step 0.10 and Steps 1 through 7d: CV draft, gatekeeper, recruiter review, HM review, CV revision, cover letter draft through final gatekeeper, DOCX export, Notion writeback, reviewer feedback file
5. `career-engine-export` — DOCX production protocol, pandoc commands, template styles, page count verification

**`--edit` flag:**
Load in order: `01-writing-rules.md`, `career-engine-export`, `career-engine-edit`. Follow the editing pipeline as written in that skill.

**`--coach-skills` flag:**
Load `career-engine-coach` only. Follow that skill and stop.

**`--coach` flag:**
Load `01-writing-rules.md` first. Then spawn `employment-coach` in direct coaching mode. Pass {{USER_FIRST_NAME}}'s question, role URL, or JD text as the input. The coach responds conversationally — no structured output format, no Notion writeback.

**`--now <url or JD text>` flag:**
Load in order: `01-writing-rules.md`, `career-engine-orchestrator` (read the `--now` mode section), `career-engine-new-application`, `career-engine-export`. Follow the `--now` flow defined in `career-engine-orchestrator`.

**`--status` flag:**
Load `career-engine-orchestrator` (read the `--status` section). No other skills needed. No Notion access, no agents spawned — read-only filesystem operation.

**`--check` flag:**
Load `01-writing-rules.md` first. Then spawn `gatekeeper` directly:
- If {{USER_FIRST_NAME}} says "check my CV" or pastes CV text → spawn with `option=content`. Pass the CV text and JD if provided. If no JD, note that checks requiring JD comparison (keyword coverage and JD phrase checks) will be skipped.
- If {{USER_FIRST_NAME}} says "check my cover letter" or pastes letter text → spawn with `option=cover-letter`. Pass the letter text and JD if provided. If no JD, note that Check 7 (company self-characterization) will be skipped.
Return the gatekeeper's PASS or FAIL result directly. No loop.

**`--review` flag:**
Load `01-writing-rules.md` first. Ask {{USER_FIRST_NAME}} to paste the document (CV or cover letter) and the JD if she hasn't already. Then:
1. Spawn `recruiter-reviewer` with the document and JD. Return results.
2. Spawn `hiring-manager-reviewer` with the document and JD. For cover letter review, treat prior HM CV verdict as N/A. Return results.
Deliver both reviews together. No revision loop.

**`--write-letter` flag:**
Load `01-writing-rules.md` and `cover-letter` skill. Ask {{USER_FIRST_NAME}} for the URL or JD text if not provided. Then spawn `letter-writer` using the Standalone Invocation path — no final CV required, no reviewer loop, no gatekeeper spawn. Return the cover letter draft directly for {{USER_FIRST_NAME}} to use or refine.

## Rules

- Load all required skills before spawning any sub-agent.
- Route each role by the pipeline {{USER_FIRST_NAME}} specified in chat: `New Applications` (default) → cv pipeline.
- Do not pause mid-run to ask scope questions. The employment coach caps the run — that cap is final.
- If a single role fails, log the failure and continue to the next role.
- All DOCX output goes to {{USER_FIRST_NAME}}'s configured output folder, not to a session scratchpad.
