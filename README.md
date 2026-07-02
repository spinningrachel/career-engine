# career-engine

> ⚠️ **This release changes `pipeline-preferences.json` significantly.** Job-search preferences (target titles, remote preference, exclusion patterns, and more) moved into it from the retired `job-preferences.md`. If you already have `career-data` installed, ask Claude (in Chat, Cowork, or Code) to check it against the current schema and generate an update prompt for you before your next pipeline run. See the [Changelog](#changelog) below for exactly what changed and the full upgrade steps.

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

### 2026-07-02 — Mandatory QA pass: stale writer-craft pointers and a second per-page fetch delegation gap

Consolidated QA pass (`agents/qa-plugin.md`) run against the accumulated diff before opening a PR — the writer-craft consolidation and the three prior bug-fix rounds had each passed their own QA check, but a full trace sweep across every consumer surfaced two classes of drift that the narrower per-round checks missed.

**Bug fixes**
- **Four stale prose pointers to skills retired by the writer-craft consolidation.** `agents/letter-writer.md`, `skills/career-engine-setup/SKILL.md`, `skills/career-engine-export/SKILL.md`, and `skills/update-refs/SKILL.md` each referenced "the cover-letter skill," "cv-writing," or "the humanizer" by their old (now-deleted) file paths in body prose — the path-based greps from the consolidation's own QA pass caught every `skills/cover-letter/...`-style reference but missed these prose mentions with no literal path. Repointed all four to `skills/writer-craft/SKILL.md`.
- **`skills/gatekeeper-checks/SKILL.md`'s 320-word cover letter rule cited "the cover-letter skill" as canonical** — same stale-pointer class, same fix.
- **Intake's Step 0b and edit's Step E0 ran an uncapped per-page Notion fetch loop directly in the pipeline's own context**, the same failure shape as the orchestrator's Step O1 context-exhaustion incident (documented 2026-07-01) — but the fix that day was only ever applied to the orchestrator's Interested-queue site, not propagated to intake's Hold-queue fetch or edit's Needs-editing-queue fetch, both of which fetch per-page properties for the *entire* queue before their respective 5-role caps are applied. Fixed both by mirroring the orchestrator's pattern exactly: delegate the per-page fetch to a lightweight subagent that returns one bounded block, write it to a run-scoped scratch file in a single `Write` call, and read downstream from that file. Intake's `$PIPE` establishment moved from Step 0.4 to a new Step 0a.5 (ahead of Step 0b, so the delegated fetch has somewhere to write); edit gained a new run-scoped `$RUN_PIPE` (distinct from its existing per-role `$PIPE` at Step E0.pipe, which is created later).

**Documentation**
- Added a cross-file-contracts row in `CLAUDE.md` for the three-site per-page-fetch-delegation contract (orchestrator Step O1 as the original fix; intake Step 0b and edit Step E0 as the two sites that had drifted out of parity with it).
- Updated the intake `$PIPE` contract row in `CLAUDE.md` to reflect the new Step 0a.5 / Step 0b step numbers and the new `hold-role-properties.md` file.

### 2026-07-02 — Production validation: writer-craft consolidation confirmed in a live run

The 2026-07-01 writer-craft consolidation (`skills/writer-craft/SKILL.md`) was validated against a real New Application pipeline run — UR Tech Jobs, Head of Marketing — using the gatekeeper unchanged (`gatekeeper-checks/SKILL.md` and `agents/gatekeeper.md` were explicitly out of scope for the consolidation). Output quality held up well even without a matching gatekeeper-side update, which is itself a useful signal: the writer-side fix carries real value on its own, and whether the gatekeeper needs the same treatment remains a separate, deliberately deferred decision rather than a blocking dependency.

### 2026-07-01 — Writer-craft consolidation: one doctrine file for CV, cover letter, and humanizer

Forensic analysis of real pipeline sessions this cycle found production cover-letter runs hitting 7-round whack-a-mole revision loops, partly attributable to doctrine size and its split across files; a duplicated-content drift risk between `shared-voice-rules.md` and `gatekeeper-checks.md`; and a real per-round token cost from loading 3-4 separate large files on every writer spawn. Condensed-prompt experiments run this session (a small test prompt against the real pipeline) confirmed the problem was never doctrine *size* — a short prompt still caught real violations — it was the *split* and a handful of narrowly-scoped bans that were easy to route around.

**Improvements**
- **Consolidated `cv-writer`, `letter-writer`, and `cover-letter-humanizer` onto one shared skill, `skills/writer-craft/SKILL.md`.** Retired five files the three agents used to load separately: `skills/cv-writing/SKILL.md`, `skills/cover-letter/SKILL.md`, `skills/cover-letter-humanizer/SKILL.md`, `references/cover-letter-self-check.md`, and `references/humanizer-target-metrics.md`, plus the CV/cover-letter/humanizer-relevant portion of `references/shared-voice-rules.md` (§1-7; §8 LinkedIn is untouched). `shared-voice-rules.md` itself is not deleted — it remains canonical, unmodified, for its six other live consumers (`linkedin-post-writer`, `linkedin-post-reviewer`, `freelance-manager`, `linkedin-coach`, `fiverr`, `upwork`).
- **Content was aggressively trimmed to demonstrated rules, not merged wholesale.** Kept: every rule that fired in a real traced production violation this session (single-instance summary trap, absolute-peak numbers needing range language, an opening verb used 5 times, verbatim JD phrase-lifting into CV bullets; greeting format, gap-volunteering language, staccato fragments, a presumptuous company-business verdict, JD-language mirroring, missing role name in the first sentence, a required voiced phrase dropped mid-revision, cross-paragraph repetition, CV-repetition in a proof paragraph); every gap a condensed-prompt test this session demonstrated matters (the em dash ban is now stated at full width instead of narrowly scoped to "as a list separator" — the narrow framing was the single largest violation category in one test; the colon ban is a full ban in letter body copy, not just "avoid before lists"; the JD/company-language-mirroring opener check is now explicit that it applies even when the mirrored phrasing traces back to the candidate's own WIWTR notes — a real hard fail traced an opener to WIWTR text that itself echoed a JD tagline; the antithesis/pivot ban and the overreach/unsubstantiated-company-claim ban are both explicit and non-waivable); and every document-correctness rule regardless of "demonstrated" status (CV required/forbidden sections, BlueFont annotation syntax, the fabrication rule and its personal-content exemption, the cover letter's universal three-block shape and 320-word ceiling, and the opener's Use-Case Structures). Trimmed hard: the exhaustive AI-vocabulary/idiom/hollow-construction catalogs were cut to a curated, high-signal subset rather than kept in full — general writing-hygiene lists not tied to an observed failure.
- **Rewired `agents/cv-writer.md`, `agents/letter-writer.md`, and `agents/cover-letter-humanizer.md`'s file-loading tables** to point at the single consolidated skill instead of 2-4 separate files each.
- **Updated `agents/qa-plugin.md`'s hardcoded content-presence checks** (Failure mode A/B, Voice fingerprint, maximum-320, Proof-point partitioning, always-surfaced, WIWTR enumeration, strategic-builder phrase, colon ban, sentence-length/monotone parity, skill-directory count and enumeration) to verify the same content in its new location.
- Updated `CLAUDE.md`'s cross-file-contracts table (shrunk the Shared Voice Rules consumer list; added a new contract row for the writer-craft consolidation) and `references/REFERENCES.md`.

### 2026-07-01 — Production bug fixes: dropped coach fields, context-bloat during Notion reads, and a hand-edit anti-pattern recurrence

Traced from forensic analysis of three real pipeline sessions run against the 2026-06-30 release, cross-checked against the current repo.

**Bug fixes**
- **Career coach silently dropped `Location` and `First Advertised` on every role.** The Step 0.8 `coach-complete` field checklist in `skills/career-engine-intake/SKILL.md` had drifted out of parity with the Step 0.9a confirmation-pass mandatory-field list — it omitted `Location` and `First Advertised` entirely, so roles could be marked coach-complete (skipping the coach) with both fields silently empty. Confirmed in two independent live intake runs: 10 roles processed across 2 batches, zero occurrences of either field. Restored parity across all three lists that must match (Step 0.8 coach-complete, Step 0.9a confirmation pass, and a newly-added gatekeeper presence-check — see below). Also added a literal `Location` template slot to `skills/career-coach/coach-output.md` (it had a fill-in-the-blank line for `Date first advertised` but none for `Location`, which was prose-only).
- **Gatekeeper's Coach Output Check had no presence-check for mandatory fields.** Across 6 gatekeeper passes in the traced runs, every violation was about keyword caps, Culture contamination, WIWTR length, or unverifiable claims — never a missing mandatory field, because no such check existed. Added check 7 (mandatory-field presence) to `skills/gatekeeper-checks/SKILL.md` → Coach Output Check, and wired the new violation category into `agents/gatekeeper.md`'s output format.
- **Orchestrator ran the full ~60-65KB Notion DB-discovery fetch even when a fast-path view URL was already loaded in context.** The existing fast-path doctrine was buried mid-paragraph in `skills/database-notion/SKILL.md` §3 and `skills/career-engine-orchestrator/orchestrator-queue.md`. Restructured both as an explicit `⛔ STOP` pre-check at the top of §1 and §3, and added the same check to intake's Step 0a call site.
- **Persisted/oversized Notion fetch responses were re-read into context in full**, defeating the point of persist-to-stub. Confirmed in the New Application session (a failed 87KB re-read followed by 4 rounds of ad hoc extraction) and both Intake sessions (a 61,383-byte schema file `Read` in full, immediately preceding the first auto-compaction in each run). Added explicit guidance to `skills/database-notion/SKILL.md` §1: extract only the needed block via a scoped shell command; never re-ingest the full persisted file.
- **New Application orchestrator queue-building (Step O1) held full per-page Notion fetch results live in context** with no `$PIPE` to redirect them (unlike intake's Step 0.5, which already writes to `$PIPE/queue.md`). Added a run-scoped `$PIPE` to `orchestrator-queue.md` Step O1 (mirroring intake's Step 0.4 pattern), writing each per-page fetch to `$PIPE/role-properties.md`; Step O2's readiness check now reads from that file instead of holding fetch results in memory.
- **`notion-update-page`'s required call shape was undocumented**, costing a full failed writeback round in both Intake sessions (`{"id": ...}` fails with `MCP error -32602`; the correct shape is `{"page_id": ..., "command": "update_properties", "properties": {...}}`). Documented the exact shape in `skills/database-notion/SKILL.md` §4.
- **Re-reading `coach-output.md` once per gatekeeper round instead of once per run** — strengthened the existing "read once" instruction in `skills/career-engine-intake/SKILL.md` Step 0.8 to explicitly cover every subsequent gatekeeper round in the same run, since the prior wording (already present) still didn't prevent a live run reading a 53-56KB file 3 separate times.
- **Orchestrator hand-edited the coach's own `$PIPE/coach-output.md` file instead of re-spawning the coach on a gatekeeper FAIL**, recurring in two more sessions despite an already-explicit named anti-pattern in Step 0.8.5. Added an explicit pre-`Edit`-call self-check line and restructured the step to lead with the imperative rather than append the warning as a footnote. Flagged as possibly a model-adherence issue that prose alone cannot fully solve.

**Documentation**
- Added a cross-file-contracts row in `CLAUDE.md` for the three-way coach mandatory-field-list parity contract (Step 0.8 coach-complete, Step 0.9a confirmation pass, gatekeeper presence-check).

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
- **Sourcing keyword variants and locale boards.** Add `target_titles`, `title_variants`, and locale-specific job boards to `pipeline-preferences.json` to widen what `source-open-roles` searches. A new `references/locale-job-boards.md` ships as a starting reference, keyed by country.
- **Database config keys.** `pipeline-preferences.json` now names your tracker backend explicitly (`database_backend`, default `notion`) and reads `database_id` and five `database_*_view_url` fast-path keys in place of the old `notion_*` names. Every legacy `notion_*` key is still read, so an existing config keeps working untouched; migrate to the new names at your own pace.

**Changes in this release**

**New features**
- **Database backend abstraction.** Config keys are now backend-neutral (`database_backend`, `database_id`, `database_edit_view_url`, `database_property`, and four sibling view-URL keys), with full backward compatibility for the legacy `notion_*` names. The read/write mechanics live in one adapter skill, `database-notion`, that every pipeline delegates to. A future backend is a sibling adapter with the same generic operations.
- **Config-health notice.** Only `output_folder`, `cv_template`, and `database_id` (when a database backend is configured) stop a run if missing. Every other key is optional. A notice printed each run lists exactly what's empty or missing against the current template, so an older config never silently breaks and a new config key never goes unnoticed.
- **Screening answers.** See the Optional upgrade step above.
- **Smarter sourcing.** `source-open-roles` now searches keyword variant sets per title (stored in `pipeline-preferences.json`), a new tier of locale-specific job boards, and net-widening sources (Remotive, Reddit hiring threads, LinkedIn hiring posts, and native company careers pages as a discovery channel), while explicitly skipping echo aggregators that mirror other boards.
- **Motivation Bank.** A `| Tags | Motivation |` table (now living in `background/background-motivation-bank.md` per the v1.5.0 structure above) is the letter-writer's primary content and voice source, read ahead of any constructed alternative. Why I Want This Role is supplementary: its distinct points must still appear in the letter when present, but the Bank alone can carry a letter when it's empty. A Sufficiency Gate skips a role rather than writing from fabricated motivation when both sources are empty. Durable Why I Want This Role content is promoted into the Bank as new rows after each run.
- **Coach worldview upgrade.** The career coach now classifies every role by mandate type (Builder, Fixer, or Maintainer, based on the JD's verb signals) and generates bespoke WIWTR coaching questions for the user to answer before the letter pipeline runs.
- **`job-preferences.md` retired; every job-search preference now lives in `pipeline-preferences.json`.** `source-open-roles` also kept its own separate local file (`~/.career-engine-job-prefs.json`) outside the `career-data` model entirely, duplicating target titles, remote preference, exclusion patterns, and location in a form nothing else in the plugin could see. Both are gone. `target_titles`, `title_variants`, `remote_preference`, `exclusion_patterns`, `default_search_time_range`, `seniority_floor`, `target_function`, `industry_fit`, `company_stage_fit`, `employment_type_preference`, and `coaching_prioritization` are now `pipeline-preferences.json` keys, and location consolidates onto the existing `location_compatibility.my_location` field rather than a third separate location store. Setup's Phase 5 now asks for target titles, remote preference, exclusion patterns, and default search time range directly (closing a gap where nothing in onboarding ever actually asked for them); `source-open-roles`' own Gate 1 remains the fallback for anyone who skipped that question. The one section of `job-preferences.md` genuinely worth keeping, the Remote Compatibility classification framework, was inlined directly into the coach's research doctrine, since the actual runtime remote-geography logic already lived independently in `source-open-roles/SKILL.md`'s Verification Pass and never read the old file's version.
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
