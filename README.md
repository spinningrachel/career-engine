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

### 2026-06-30 — Consolidated overhaul: database abstraction, smarter sourcing, Motivation Bank, and file-based pipeline reliability

This release covers six days of continuous work across four layers of the plugin: a backend-neutral config model for the job-tracking database, two new sourcing capabilities (screening answers and expanded job discovery), a Motivation Bank that gives the letter-writer a standing verbatim voice source, a restructured `career-data` content bank that scales past a single flat file, and a file-based read/write pattern (R-41) applied across the intake, application, and edit pipelines to stop large batches from overflowing the model's context window. It also folds in roughly forty smaller correctness fixes found through systematic adversarial QA audits run throughout development: dual-writeback bugs, `CAREER_DATA` propagation gaps, stale file paths, and contract mismatches between an agent's stated output format and what its callers actually read.

#### Upgrading from a previous version

**Required**

1. **Reinstall the plugin.** Download `career-engine.plugin` from the Releases page and reinstall it via **Customize → Connectors → Personal plugins**. The previous installation must be replaced; updating in place is not supported.

2. **Migrate `career-data` to the v1.5.0 structure.** `02-professional-background.md` is now a router: it holds a routing table and a career-history summary. Everything else (role facts, approved CV summaries and bullets, testimonials, portfolio, cross-cutting skills, and the Motivation Bank) lives in dedicated sub-files under `background/`. A `career-data` skill on the prior flat structure produces an empty read where the pipeline expects role facts and the Motivation Bank.

   The plugin ships the router template and seven blank sub-file templates at `references/02-professional-background.md` and `references/background/`. Migrate as follows:

   - Replace `02-professional-background.md` with the router template. Add one row to the Career History Table for each role in your history.
   - Create `background/background-motivation-bank.md` and move your Motivation Bank table into it: a `| Tags | Motivation |` table holding your standing motivations in your own words. State why you do this work, what draws you to the roles you pursue, and what you want to contribute. If you have not built a Motivation Bank yet, start it here; the pipeline appends new rows automatically after each run.
   - Create one `background/background-role-facts-<company>.md` per company in your work history (slugified name: lowercase, spaces and punctuation converted to hyphens).
   - Move any other content you have (approved CV summaries, approved bullets, testimonials, portfolio, cross-cutting skills) into its matching sub-file (`background-cv-summaries.md`, `background-approved-bullets.md`, `background-testimonials.md`, `background-portfolio.md`, `background-cross-cutting-skills.md`).

   Generate an update-prompt and apply it via Chat, then repackage and reinstall `career-data` through the Desktop app. See [Updating career-data](https://github.com/spinningrachel/career-engine/wiki/Updating-career-data) for the procedure.

**Optional**

None of the following block a pipeline run. An older config with none of these fields set still works, and a per-run config-health notice lists what's empty or missing.

- **Screening answers.** Add a `screening_answers` block to `pipeline-preferences.json` with your standing answers to common gating questions (travel, relocation, security clearance, compensation floor, availability). Intake flags a match or conflict against the JD in Patterns (advisory only, never a gate), and sourcing down-ranks a conflicting role with a visible label rather than excluding it. Leave any field blank to skip it.
- **Sourcing keyword variants and locale boards.** Add title variant sets and locale-specific job boards to `job-preferences.md` to widen what `source-open-roles` searches. A new `references/locale-job-boards.md` ships as a starting reference, keyed by country.
- **Database config keys.** `pipeline-preferences.json` now names your tracker backend explicitly (`database_backend`, default `notion`) and reads `database_id` and five `database_*_view_url` fast-path keys in place of the old `notion_*` names. Every legacy `notion_*` key is still read, so an existing config keeps working untouched; migrate to the new names at your own pace.

**Changes in this release**

**New features**
- **Database backend abstraction.** Config keys are now backend-neutral (`database_backend`, `database_id`, `database_edit_view_url`, `database_property`, and four sibling view-URL keys), with full backward compatibility for the legacy `notion_*` names. The read/write mechanics live in one adapter skill, `database-notion`, that every pipeline delegates to. A future backend is a sibling adapter with the same generic operations.
- **Config-health notice.** Only `output_folder`, `cv_template`, and `database_id` (when a database backend is configured) stop a run if missing. Every other key is optional. A notice printed each run lists exactly what's empty or missing against the current template, so an older config never silently breaks and a new config key never goes unnoticed.
- **Screening answers.** See the Optional upgrade step above.
- **Smarter sourcing.** `source-open-roles` now searches keyword variant sets per title (stored in `job-preferences.md`), a new tier of locale-specific job boards, and net-widening sources (Remotive, Reddit hiring threads, LinkedIn hiring posts, and native company careers pages as a discovery channel), while explicitly skipping echo aggregators that mirror other boards.
- **Motivation Bank.** A `| Tags | Motivation |` table (now living in `background/background-motivation-bank.md` per the v1.5.0 structure above) is the letter-writer's primary content and voice source, read ahead of any constructed alternative. Why I Want This Role is supplementary: its distinct points must still appear in the letter when present, but the Bank alone can carry a letter when it's empty. A Sufficiency Gate skips a role rather than writing from fabricated motivation when both sources are empty. Durable Why I Want This Role content is promoted into the Bank as new rows after each run.
- **Coach worldview upgrade.** The career coach now classifies every role by mandate type (Builder, Fixer, or Maintainer, based on the JD's verb signals) and generates bespoke WIWTR coaching questions for the user to answer before the letter pipeline runs.
- **`career-data` v1.5.0 router structure.** See the Required upgrade step above.
- **File-based (R-41) pipeline I/O.** Large content passed between pipeline steps and subagents (JD text, row payloads, a subagent's full output) now travels by file path, not inline in a spawn prompt, everywhere the pattern was previously missing: `$PIPE/role-properties.md` at the start of every application-pipeline run, and `$PIPE/queue.md`, incremental per-role writes to `$PIPE/coach-output.md`, and `$PIPE/writeback-status.md` in the intake pipeline. This was root-caused from a real 25-role intake run. The documented 5-role batch cap was bypassed, the coach hit the model's output-token ceiling mid-generation and crashed, the run's own logic then hand-edited the coach's output file directly across five gatekeeper fail/fix rounds instead of re-invoking the coach, and a second crash mid-writeback lost 24 of 25 roles' completed, gatekeeper-passed analysis with no way to tell what had already reached Notion. The 5-role cap is now enforced at three points (queue selection, a defensive pre-spawn check, and a refusal built into the coach itself). A named anti-pattern now prohibits hand-editing a subagent's output file and requires a re-spawn instead, and the writeback ledger makes an interrupted run resumable instead of silently losing finished work.

**Improvements**
- **Gatekeeper Coach Output Check verifies against the full background, not the rules file alone.** Previously it checked claims only against `01-writing-rules.md`, producing false positives on real, documented claims that lived in `02-professional-background.md` or `03-framework.md`.
- **Orchestrator and coach split into phase-based sub-files.** Both monolithic skill files are now lazy-loaded by phase, reducing the context every run has to hold.
- **WIWTR instruction parsing.** The letter-writer classifies Why I Want This Role content before building its coverage checklist, executing sourcing directives ("Find in motivation bank...") instead of quoting them as letter content.
- Coach output brevity and calibration fixes: hard-capped keywords, Strategy calibration, gap-handling seam closed, filler-quality checks moved to the gatekeeper so the coach stays strategic.

**Bug fixes**
- **Dual-writeback bug.** The career coach no longer writes to Notion in any pipeline mode; intake's Step 0.9a is now the sole writer of coach-produced properties, closing a gap where two writers each assumed the other had written and `Role summary`/`Priority Reason` were silently dropped.
- **`CAREER_DATA` propagation.** Eight revision-branch spawns across the new-application and edit pipelines, plus a further set found by a full spawn-parameter audit, now pass `CAREER_DATA=${CAREER_DATA}` explicitly. Previously, gatekeeper-fail loops and re-spawn branches lost access to personal data at runtime.
- **CV path fixes** for edit-mode Letter-type (writes `$PIPE/cv-text.md` before the gatekeeper's repetition check) and `--now` mode (passes an explicit no-CV instruction instead of a path that doesn't exist).
- **Cover-letter filename slug drift** between the new-application and export pipelines.
- **Gatekeeper output-format contract fixed.** The gatekeeper's documented protocol has always required violations to be written to a file (`OUTPUT_PATH`) with a short status-line reply, but its own format section for all three checks showed the violation list printed inline instead. This was live drift for two of the three checks, and the cause of two real breaks in the edit pipeline's baseline checks, whose violation lists are read back downstream as if from a file that was never written. All three checks and both callers are now correct.
- **Freelance-manager config reference fixed.** It pointed at a `freelance-config.md` file that never existed; pricing floors now live in `pipeline-preferences.json` with everything else.
- Roughly a dozen defects found in a deep adversarial audit of under-traced pipeline surfaces, and fourteen pipeline-logic findings from a systematic QA trace of the intake, new-application, and orchestrator skills: stale file paths, missing stop conditions, and field-list mismatches between a gate and the check that enforces it.

### 2026-06-23 — Documentation and marketplace install support

- **Documentation moved to the Wiki.** The README is now a quick start; full docs live in the [Wiki](https://github.com/spinningrachel/career-engine/wiki).
- **Marketplace install support.** The plugin is now installable as a Claude Code marketplace. Add it with `/plugin marketplace add spinningrachel/career-engine`, then `/plugin install career-engine@cheyfitz`. Direct `.plugin` download still works for manual installs.
