# career-engine

![Career Engine Pipeline](assets/career-engine-pipeline-v2.png)

A Claude Code (and Cowork) plugin for senior technology professionals who want their career to work for them — landing the right next role, building a credible professional presence, and maintaining the materials and positioning that make both possible on short notice.

It connects your career materials to a Notion job-tracking database and runs a multi-agent workflow that researches roles, writes tailored CVs and cover letters, routes them through recruiter review, gatekeeps them against fabrication rules, exports them to DOCX, and writes results back to Notion — alongside standalone LinkedIn, personal-brand, and maintenance capabilities.

All of it draws from one source of truth: **`career-data`**, a separate skill that holds your positioning framework, career content bank, and approved voice. `career-data` lives on your own machine and is never modified by plugin runs or updates.

> 📖 **Full documentation lives in the [Wiki](https://github.com/spinningrachel/career-engine/wiki).** This page is just the quick start.

---

## Get started

**1. Install the plugin.**

[![Download career-engine.plugin](https://img.shields.io/badge/⬇%20Download-career--engine.plugin-2563eb?style=for-the-badge)](https://raw.githubusercontent.com/spinningrachel/career-engine/main/career-engine.plugin)

Open the Claude Desktop app → **Customize → Personal Plugins → +** → **Personal** (tab) → **+** → **Upload plugin**, and select the downloaded file. It becomes available in **Cowork** and **Claude Code** (not Chat).

![Installing the career-engine plugin](assets/install-plugin.gif)

Claude Code users can install via the marketplace instead, for automatic updates:

```
/plugin marketplace add spinningrachel/career-engine
/plugin install career-engine@cheyfitz
```

**2. Run setup (once).**

```
/career-engine:setup
```

Setup interviews you about your background, target roles, and positioning, then builds your `career-data` skill. The closing step installs that skill — in Cowork it hands you a prompt to paste into **Chat** (with `/skill-creator`). This is the step people get stuck on: read **[Installing career-data](https://github.com/spinningrachel/career-engine/wiki/Installing-career-data)** before you reach it.

**3. Run the pipeline.**

```
/career-engine:source-open-roles   # find roles
/career-engine --coach-skills      # research + strategy
/career-engine                     # write CVs + cover letters
```

See the **[Pipelines Overview](https://github.com/spinningrachel/career-engine/wiki/Pipelines-Overview)** for the full flow.

---

## Basic requirements

- **Claude Code** (desktop app or CLI) with MCP server support
- **[pandoc](https://pandoc.org/installing.html)** on your `PATH` — required for DOCX export
- **python-docx** — `pip install python-docx`
- A **local output folder** for generated files (iCloud or any local path)
- **Desktop Commander MCP** — file operations and pandoc from sandboxed sessions (required for Cowork)
- **`/skill-creator`** installed in Chat — builds your `career-data` skill during setup

Feature-specific: **Notion** (any pipeline run that reads/writes Notion) and the optional **LinkedIn MCP** (better research; falls back to WebSearch).

Full details and the environment-by-environment breakdown: **[Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Prerequisites)**.

---

## Documentation

Everything beyond this quick start lives in the **[Wiki](https://github.com/spinningrachel/career-engine/wiki)**:

| Section | Pages |
|---|---|
| **Getting Started** | [Installation](https://github.com/spinningrachel/career-engine/wiki/Installation) · [Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Prerequisites) · [Setup](https://github.com/spinningrachel/career-engine/wiki/Setup) · [Installing career-data](https://github.com/spinningrachel/career-engine/wiki/Installing-career-data) |
| **Your Data** | [career-data Overview](https://github.com/spinningrachel/career-engine/wiki/career-data-Overview) · [Updating career-data](https://github.com/spinningrachel/career-engine/wiki/Updating-career-data) · [Reference Files](https://github.com/spinningrachel/career-engine/wiki/Reference-Files) · [Configuration Keys](https://github.com/spinningrachel/career-engine/wiki/Configuration-Keys) |
| **Application Pipeline** | [Overview](https://github.com/spinningrachel/career-engine/wiki/Pipelines-Overview) · [Sourcing](https://github.com/spinningrachel/career-engine/wiki/Sourcing) · [Intake](https://github.com/spinningrachel/career-engine/wiki/Intake) · [New Application](https://github.com/spinningrachel/career-engine/wiki/New-Application) · [Edit](https://github.com/spinningrachel/career-engine/wiki/Edit) · [Fast Track](https://github.com/spinningrachel/career-engine/wiki/Fast-Track) · [Localization](https://github.com/spinningrachel/career-engine/wiki/Localization) · [Cover Letter Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Cover-Letter-Prerequisites) · [Utility Modes](https://github.com/spinningrachel/career-engine/wiki/Utility-Modes) |
| **Standalone Capabilities** | [LinkedIn coach, personal brand, career coach, update references, plugin builder, technical writer](https://github.com/spinningrachel/career-engine/wiki/Standalone-Capabilities) |
| **Outputs & Operations** | [Output Files](https://github.com/spinningrachel/career-engine/wiki/Output-Files) · [Update Prompts](https://github.com/spinningrachel/career-engine/wiki/Update-Prompts) · [State File & Crash Recovery](https://github.com/spinningrachel/career-engine/wiki/State-File-and-Crash-Recovery) · [Token Usage Tracking](https://github.com/spinningrachel/career-engine/wiki/Token-Usage-Tracking) |
| **Reference & Architecture** | [Architecture](https://github.com/spinningrachel/career-engine/wiki/Architecture) · [External Connectors](https://github.com/spinningrachel/career-engine/wiki/External-Connectors) · [Capability Status](https://github.com/spinningrachel/career-engine/wiki/Capability-Status) |

---

## Changelog

### 2026-06-30 — Coach R-41, career-data v1.5.0 router support, pipeline reliability fixes

This release restructures the `career-data` content bank into sub-files, fixes the Motivation Bank read path and role-facts read path, and adds two pipeline reliability improvements.

#### Upgrading from a previous version

**Required**

1. **Reinstall the plugin.** Download `career-engine.plugin` and reinstall it via **Customize → Connectors → Personal plugins**.

2. **Migrate `career-data` to the v1.5.0 structure.** `02-professional-background.md` is now a router — all content has moved to dedicated sub-files in `background/`. The plugin reads the Motivation Bank from `background/background-motivation-bank.md`; if your `career-data` still has the flat structure (Motivation Bank at §5), the pipeline will not find it.

   The updated blank router and seven sub-file templates ship with the plugin at `references/02-professional-background.md` and `references/background/`. To migrate:

   - Replace `02-professional-background.md` with the router template. Add a row to the Career History Table for each role in your history.
   - Move your Motivation Bank table to `background/background-motivation-bank.md`.
   - Move role facts for each company to `background/background-role-facts-<company>.md` (one file per company, slugified name).
   - Move any other content to its matching sub-file (`background-cv-summaries.md`, `background-approved-bullets.md`, `background-testimonials.md`, `background-portfolio.md`, `background-cross-cutting-skills.md`).

   Apply these changes via the update-prompt path. See [Updating career-data](https://github.com/spinningrachel/career-engine/wiki/Updating-career-data) for the procedure.

   > **Minimum migration if you just installed June 29:** if you only added the Motivation Bank at §5 and haven't filled in role facts or other sections yet, the minimum required change is to replace `02-professional-background.md` with the router template and create `background/background-motivation-bank.md` with your Motivation Bank table.

**Optional**

Nothing additional is required. WIWTR instruction parsing, role properties on disk, and the pipeline reliability fixes are purely plugin-side.

**Changes in this release**

- **Coach R-41 output protocol.** The career coach now writes its full analysis to `$PIPE/coach-output.md` (R-41) in intake pipeline mode and returns a single status line. Previously the coach returned its analysis inline, which was vulnerable to context compression during 5-role batch runs — the compression event could occur between the coach return and the Step 0.9a Notion writes, destroying the analysis. File-based output survives compression; the intake skill reads the file in Step 0.8.5 and passes it to the gatekeeper. All other coach options continue to return inline.
- **career-data v1.5.0 router support.** All plugin agents, skills, and reference files now use the v1.5.0 sub-file paths for `02-professional-background.md`, which has been converted from a flat file to a router pointing to `background/background-*.md` sub-files. The plugin's blank template for `02-professional-background.md` has been updated accordingly, and `references/background/` now ships seven blank sub-file templates.
- **WIWTR instruction parsing.** The letter-writer now classifies Why I Want This Role content before building the coverage checklist. Instruction directives ("Find in motivation bank...", "Refer to professional background...") are executed as sourcing instructions rather than quoted as letter content. Mixed items are split: the directive is executed, the genuine motivation is kept verbatim. This prevents instructions written in the WIWTR field from appearing in the letter body.
- **Role properties on disk at pipeline start.** A new Step 0.data writes all role metadata (company, role title, Strategy, Keywords, Gap handling, Role summary) to `$PIPE/role-properties.md` immediately after the pipeline directory is created. The file survives context compression and gives all subagents a lightweight on-disk reference to role metadata.
- **Screen 1/2/3 renamed from Priority 1/2/3.** The coach's priority classification labels were renamed to Screen 1/2/3 to avoid colliding with the Notion `Priority` property during intake writeback.
- **Priority Select value annotation fixed.** The coach context block in the coach skill now correctly annotates select values with their allowed options so intake can validate before writing.
- **Likely KPIs removed from coach context block.** The coach no longer writes a `Likely KPIs` field to the coach context block written to WIWTR; the field is not part of the Notion schema and caused writeback errors.
- **Section references updated throughout.** Stale numbered section references (`§5`, `Section 7`, `§9`, `§10`) in agents and skills have been replaced with the correct `background/` sub-file paths, matching the v1.5.0 career-data structure.
- **Role facts file read fixed.** The cover letter pre-step that reads background context for the letter-writer was pointing at `02-professional-background.md` (now a router with no content). It now reads `background/background-role-facts-<company>.md` directly, with company slug derivation and a fallback message when no file exists for the company. The letter-writer was previously receiving a routing table as "role facts."

### 2026-06-29 — Motivation Bank and pipeline reliability

This release introduces the Motivation Bank, restructures the cover letter content model, adds Notion fast-paths for all five pipeline views, and fixes two CAREER_DATA propagation gaps in the revision loops.

#### Upgrading from a previous version

Two changes to `career-data` are required before the cover letter pipeline runs correctly. The rest are optional enhancements.

**Required**

1. **Reinstall the plugin.** Download `career-engine.plugin` from the Releases page and reinstall it via **Customize → Connectors → Personal plugins**. The previous installation must be replaced. Updating in place is not supported.

2. **Add the Motivation Bank to `02-professional-background.md`.** The cover letter pipeline reads from this table as its primary content and voice source. Without it, the letter-writer has no standing motivation content and skips roles where Why I Want This Role is also empty.

   Add this section to `02-professional-background.md` at §5:

   ```markdown
   ## Section 5 — Motivation Bank

   | Tags | Motivation |
   |---|---|
   ```

   Populate the table with your standing motivations in your own words: why you do this work, what draws you to the roles you pursue, what you want to contribute. The pipeline appends rows automatically after each run when Why I Want This Role content is worth preserving.

   Apply this change via the update-prompt path: generate an update-prompt, paste it into Chat, then repackage and reinstall `career-data` via the Desktop app. See [Updating career-data](https://github.com/spinningrachel/career-engine/wiki/Updating-career-data) for the update-prompt procedure.

**Optional**

- **Notion view URL fast-paths.** Five optional keys in `pipeline-preferences.json` skip the Notion database discovery fetch when populated. The adapter falls back to view-by-name discovery when any key is absent.

  ```json
  "database_interested_view_url": "",
  "database_hold_view_url": "",
  "database_researched_view_url": "",
  "database_cv_ready_view_url": "",
  "database_edit_view_url": ""
  ```

- **Screening answers.** A `screening_answers` section in `career-data` holds standing answers to common gating questions. Intake applies them automatically when the field is present.

**Changes in this release**

- **Motivation Bank.** A `| Tags | Motivation |` table in `02-professional-background.md` §5 is now the letter-writer's mandatory primary content and voice source. Each row holds your own words; the pipeline reads from it ahead of any constructed alternative. Why I Want This Role is now supplementary: when both are present, WIWTR's distinct points must appear in the letter; when WIWTR is absent, the Bank alone drives the opener.
- **Sufficiency Gate.** When both the Motivation Bank and WIWTR are empty for a role, the letter-writer skips that role rather than writing with fabricated or constructed motivation.
- **WIWTR promotion.** Durable Why I Want This Role content is appended to the Motivation Bank as new tagged rows after each run, keeping the Bank current without manual edits.
- **Gatekeeper: Bank-derived content exempted.** Sentences drawn from Motivation Bank entries pass the personal-content check and are not flagged as fabricated even when they don't appear verbatim in the CV.
- **Notion view URL fast-paths.** Five new optional config keys skip the Notion database discovery fetch when populated. View-by-name discovery remains the fallback when any key is absent.
- **CAREER_DATA pass-through fixed.** All eight revision-branch spawns in the new-application and edit pipelines now pass `CAREER_DATA=${CAREER_DATA}` explicitly. Previously, gatekeeper-fail loops and re-spawn branches lost access to personal data at runtime.
- **CV path fixed for edit-mode Letter-type.** The edit pipeline now writes the pandoc-extracted CV text to `$PIPE/cv-text.md` before spawning the gatekeeper, giving the repetition check a concrete file to read.
- **CV path fixed for `--now` mode.** The fast-track path now passes an explicit no-CV instruction to the gatekeeper instead of referencing a file that does not exist in that mode.
- **Changelog rules.** Format (`### YYYY-MM-DD — <label>`, newest-first, never-remove) is now documented in CLAUDE.md and checked by the QA agent on every run.

### 2026-06-23 — Documentation and marketplace install support

- **Documentation moved to the Wiki.** The README is now a quick start; full docs live in the [Wiki](https://github.com/spinningrachel/career-engine/wiki).
- **Marketplace install support.** The plugin is now installable as a Claude Code marketplace. Add it with `/plugin marketplace add spinningrachel/career-engine`, then `/plugin install career-engine@cheyfitz`. Direct `.plugin` download still works for manual installs.
