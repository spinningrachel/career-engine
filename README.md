# career-engine

A Claude Code (and Cowork) plugin for senior technology professionals who want their career to work for them — whether that means landing the right next role, building a credible professional presence, or maintaining the materials and positioning that make both possible on short notice.

The plugin covers three surfaces:

- **Application pipeline** — connects your career materials to a Notion job-tracking database and runs a multi-agent workflow that researches roles, writes tailored CVs and cover letters, routes them through recruiter and hiring-manager review, gatekeeps them against fabrication rules, exports them to DOCX, and writes results back to Notion.
- **Presence and brand** — covers LinkedIn optimisation and personal brand development, with richer pipelines for LinkedIn content, blog posts, and broader thought leadership coming.
- **Maintenance layer** — keeps your reference files, positioning framework, and delivered-letter archive current so every pipeline run starts from accurate material.

All three surfaces draw from a single source of truth: `career-data`, a separate skill that holds your positioning framework, career content bank, and approved voice. `career-data` is never modified by plugin runs or plugin updates — it lives outside the plugin on your own machine. See [career-data skill](#career-data-skill) for details.

---

## Table of contents

- [How it works](#how-it-works)
- [Unique advantages](#unique-advantages)
- [Installation](#installation)
  - [Update the plugin](#update-the-plugin)
  - [Uninstall the plugin](#uninstall-the-plugin)
  - [Manage your career-data skill](#manage-your-career-data-skill)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [Setup phases](#setup-phases)
  - [Resuming setup](#resuming-setup)
  - [Verification](#verification)
- [Updating career-data](#updating-career-data)
  - [Why career-data is separate](#why-career-data-is-separate)
  - [Getting an update prompt](#getting-an-update-prompt)
  - [Applying an update](#applying-an-update)
- [Pipelines](#pipelines)
  - [Sourcing](#sourcing)
  - [Intake](#intake)
  - [New Application](#new-application)
  - [Edit](#edit)
  - [Fast track](#fast-track)
  - [Localization](#localization)
  - [Utility modes](#utility-modes)
- [Cover letter prerequisites](#cover-letter-prerequisites)
- [State file and crash recovery](#state-file-and-crash-recovery)
- [Update prompts](#update-prompts)
- [Output files](#output-files)
- [Standalone capabilities](#standalone-capabilities)
  - [LinkedIn coach](#linkedin-coach)
  - [Personal brand](#personal-brand)
  - [Career coach](#career-coach)
  - [Update references](#update-references)
  - [Plugin builder](#plugin-builder)
  - [Technical writer](#technical-writer)
- [Architecture](#architecture)
  - [Single-build model](#single-build-model)
  - [career-data skill](#career-data-skill)
  - [Agents and skills](#agents-and-skills)
  - [Output protocol](#output-protocol)
- [Reference files](#reference-files)
- [Configuration keys](#configuration-keys)
- [Token usage tracking](#token-usage-tracking)
- [External connectors](#external-connectors)
- [Capability status](#capability-status)

---

## How it works

The plugin operates through slash commands after a one-time setup. Each pipeline run reads your career materials from `career-data` and routes work through specialized agents — one per task, each loading only the doctrine it needs. The orchestrator handles sequencing and Notion state transitions; it never authors content.

The core pipeline stages run in sequence, handing off via Notion status transitions:

1. **Sourcing** — finds open roles across job boards and LinkedIn, scored against your preferences, deduplicated against your Notion database.
2. **Intake** — researches a role, runs the career coach, and writes strategic properties (priority, emphasis, keywords, strategy) to Notion. No CVs yet.
3. **New Application** — drafts and refines a CV and cover letter through recruiter review, hiring-manager review, and gatekeeper checks, then exports DOCX files to your output folder.
4. **Edit** — refines existing CV and cover letter outputs for roles already processed.

The pipeline never skips a stage or back-fills properties it does not own (`Hold` → `Researched` → `Interested` → `Needs editing`).

For standalone capabilities that run independently of the pipeline, see [Standalone capabilities](#standalone-capabilities).

---

## Unique advantages

| Advantage | Description |
|---|---|
| **Your voice, not a generic voice** | Every agent calibrates against your delivered-letters archive — actual sent letters, not a rule list. The humanizer and gatekeeper treat those letters as the authoritative register source. When a style rule and a sent letter conflict, the sent letter wins. |
| **Fabrication-proof by architecture** | The fabrication rule is enforced structurally, not by prompt instruction. The gatekeeper checks every CV claim against your career content bank (`02-professional-background.md`) and refuses to pass a document that asserts something not traceable to an approved source. Every claim is verifiable, so your materials can be bold and specific rather than hedged. |
| **Specialized agents for every stage** | A distinct agent handles each role: career coach, CV writer, letter writer, recruiter reviewer, hiring-manager reviewer, gatekeeper, humanizer, localization agent. Each loads only the doctrine it needs. The orchestrator handles routing and never authors content. |
| **Framework primacy** | Your positioning framework (`03-framework.md`) governs every output. The LinkedIn coach, the career coach, and the personal brand skill all treat it as the source of truth about who you are and where you are heading. A single application or run's signals do not pull your positioning off course. |
| **State-backed crash recovery** | The orchestrator writes `state.json` per run. If a session ends mid-pipeline, `--status` reports exactly which roles completed, which files exist on disk, and what is missing. |
| **No personal data in the plugin** | Your career materials, filled reference files, and delivered letters live in `career-data`, a separate skill the plugin never touches. Plugin updates carry no risk to your data. There is no second copy to keep in sync. |
| **Regression-guarded** | Over 40 documented failure modes are logged in `CLAUDE.md` with root cause, fix, and affected files. Every session that touches an affected file verifies the regression has not returned. The QA agent runs as a mandatory gate after every plugin change and asserts structural integrity before a new build ships. |

---

## Installation

To install the plugin, download the `.plugin` file and upload it through the Claude Desktop app.

<a href="https://raw.githubusercontent.com/spinningrachel/career-engine/main/career-engine.plugin">
  <img src="https://img.shields.io/badge/⬇%20Download-career--engine.plugin-2563eb?style=for-the-badge" alt="Download career-engine.plugin">
</a>

1. Click the button above to download `career-engine.plugin`.
2. Open the Claude Desktop app and go to **Customize → Connectors → Personal plugins**.
3. Click **+** → **Create plugin** → **Upload plugin**.
4. Select the downloaded `career-engine.plugin` file.
5. The plugin installs immediately across Chat and Cowork.

After installation, run `/career-engine:setup` to create your `career-data` skill and configure the plugin for your environment. Setup runs once.

### Update the plugin

To update, download the latest `.plugin` file from the button above, then go to **Customize → Connectors → Personal plugins**, find career-engine, and upload the new file. `career-data` is never affected by a plugin update.

### Uninstall the plugin

To uninstall, go to **Customize → Connectors → Personal plugins**, find career-engine, and remove it.

### Manage your career-data skill

To install, update, or remove `career-data`, go to **Customize → Skills**. This is where you upload the `.skill` file after setup or after applying an update prompt.

---

## Prerequisites

Before installing, verify the following are in place:

- Claude Code (desktop app or CLI) with MCP server support
- [pandoc](https://pandoc.org/installing.html) installed and on your `PATH` (required for DOCX export)
- `python-docx` installed: `pip install python-docx` (required by the subtitle update script)
- A local output folder where DOCX files will be saved (iCloud or any local path)
- Desktop Commander MCP configured (enables file operations and pandoc calls from within sandboxed Claude sessions; required for Cowork and some Code environments; available on macOS, Windows, and Linux)

The following prerequisites are required for specific features only:

- **Notion** — a Notion workspace with the plugin database schema is required for any pipeline run that reads from or writes to Notion. Not required for standalone capabilities. See [External connectors → Notion setup](#notion-setup).
- **LinkedIn MCP** — improves research quality during intake and the LinkedIn coach. Falls back to WebSearch when not available. See [External connectors](#external-connectors) for install instructions.

---

## Setup

Setup conducts a structured onboarding interview — asking about your career history, target roles, positioning, and preferences — and synthesizes the results into three core reference files and a runtime configuration, packaged as a `career-data` skill.

`career-data` does not exist before setup runs. Setup creates it.

```
/career-engine:setup
```

> **Note:** If your background, preferences, or configuration change after setup, see [Updating career-data](#updating-career-data) to apply changes without re-running full setup.

### Setup phases

Setup runs in seven phases. Phases 5–7 can be deferred — the standalone skills work with Phases 1–4 complete. The application pipeline requires Phase 5.

| Phase | What it does | Can defer? |
|---|---|---|
| 1 — Identity and contact | Collects your name, contact details, location, profession, and language configuration. Powers file naming, agent instructions, and the CV signature. | No — nothing works without this |
| 2 — Content submission | You send existing career materials (CV, cover letters, LinkedIn export, performance reviews, portfolio). The agent reads them without storing them. | No — Phase 3 depends on it |
| 3 — Synthesis | Builds `03-framework.md` from your materials. Sections with limited evidence are marked `[DRAFT]` or `[REVIEW]` for the interview. | No — runs automatically after Phase 2 |
| 4 — Framework review and interview | Presents `03-framework.md` for your review. Runs a targeted interview to fill gaps, confirm positioning, and capture voice samples not in the materials. Populates `02-professional-background.md` and `01-writing-rules.md` with confirmed facts. | No — uncovered gaps produce weak outputs |
| 5 — Job tracking and output | Configures your Notion database ID, output folder path, CV template, draft directory link base, output prefix, default language, gap handling, location compatibility, and job site preferences. All written to `${CAREER_DATA}/references/pipeline-preferences.json`. | Yes — required before running any pipeline |
| 6 — Permissions | Generates the `~/.claude/settings.json` allow-list block so the pipeline runs without per-command approval prompts. Also verifies token-tracking hook registration. | Yes — skip if you prefer prompt-by-prompt approval |
| 7 — Job preferences | Configures rules for recruiter-submitted applications, remote location handling, platform submissions, and multi-language applications. Skip entirely if you apply only in your home country, in one language, submitted by yourself. | Yes — skip if not applicable |

At the end of setup, the agent packages `career-data` as a `.skill` file. Upload it through the Desktop app (**Customize → Skills**). Every subsequent pipeline run reads your personal data from that installed skill.

### Resuming setup

Setup can be paused and resumed at any phase. Sections of `03-framework.md` that the interview has confirmed carry no markers; sections still needing work carry `[DRAFT]` or `[REVIEW]`. To resume a partial setup or re-run a specific phase:

```
/career-engine:setup --phase 4
```

Replace `4` with the phase number to re-run. Any phase can be re-run at any time to update your materials or configuration.

### Verification

Before confirming setup is complete, the agent runs a final check: placeholder scan, output folder and CV template existence check, pandoc and python-docx dependency check, and framework completeness check. The agent reports any failures and their fixes before exiting.

---

## Updating career-data

`career-data` is the foundation the entire plugin runs on. Without it, no pipeline can start — agents hard-stop rather than silently fall back to blank templates. This is by design: your career materials are too important to guess at.

### Why career-data is separate

Your personal data — background, positioning, delivered letters, CV template — never lives inside the plugin. It lives in `career-data`, a skill you install locally on your own machine. This means plugin updates never touch your data, and your materials are never exposed in the plugin's public repository.

### Getting an update prompt

Two methods are available:

1. **From the pipeline automatically.** After each New Application or Edit run, any `Why I Want This Role` content worth preserving is extracted and written as an `update-prompt-<company>-<monYYYY>.md` file into the role's company subdirectory in the output folder. Find these files in your output folder after a run.

2. **On demand from Cowork.** Ask the career coach: *"Generate an update prompt for [whatever you want to change]."* The agent collects what you want to change, confirms the target, and outputs a ready-to-paste prompt. Use this for ad-hoc updates: new career facts, preference changes, promotions, testimonials, or corrections.

### Applying an update

The update prompt file is self-contained — it includes everything the receiving agent needs to find `career-data`, make the change, and repackage the skill.

1. Copy the contents of the update prompt file.
2. Paste it into Claude Chat or Claude Code.
3. After the update is applied, the receiving agent repackages `career-data` as a `.skill` file and delivers it to you.
4. Reinstall the `.skill` file via **Customize → Skills** in the Desktop app.

> **Note:** If you use both Chat and Code (or Cowork and Code), each environment maintains its own copy of `career-data`. Paste the update prompt in each environment separately — once in Chat and once in Code — or the environments will diverge. The prompt includes this reminder.

---

## Pipelines

The application pipeline processes roles through a sequence of stages, each handing off to the next via Notion status transitions. Each stage is a separate invocation — run them in order, or pick up where you left off if a run is interrupted. All pipeline stages read your career materials from `career-data` at run start.

### Sourcing

The Sourcing pipeline finds open roles across job boards and LinkedIn, scores them against your preferences, and deduplicates them against your Notion database.

```
/career-engine:source-open-roles
```

Roles you accept are added to Notion with Status `Hold`. No CV or letter writing happens at this stage.

#### How it works

The agent checks your `preferred_job_sites` and `local_job_sites` (configured in setup Phase 5) first, then searches across the configured tiers. Results are scored against your saved preferences and filtered against roles already in your Notion database before being returned.

#### Search options

| Option | Sources searched |
|---|---|
| **Tier 1** (always) | LinkedIn Jobs, Indeed, Glassdoor, BuiltIn, Crunchbase, PitchBook, Tracxn |
| **Tier 2** (when remote preference is set) | Remote.co, We Work Remotely, Remote OK |
| **Tier 3** (always — 2–3 accelerator boards chosen by fit) | a16z, First Round, Sequoia, Bessemer, NFX, Accel, Lightspeed, Index Ventures, General Catalyst |
| **Tier 4** (by function) | Product Marketing Alliance, Sharebird, Exit Five, Wellfound, Welcome to the Jungle, Y Combinator Jobs, Techstars Jobs |

#### Options and commands

Append the following options to the command to change search scope:

| Option | Description |
|---|---|
| `quick` | LinkedIn MCP only |
| `full` | All tiers plus all career-specific boards |
| `contract` | Upwork only (contract signals, not ranked roles) |

> **Note:** The Sourcing pipeline does not research roles or write strategic properties. For research and strategic input, run [Intake](#intake).

---

### Intake

Researches roles with Status `Hold` in your Notion database, runs the career coach, and writes strategic properties — priority, role emphasis, keywords, strategy, role type, and relationship type — back to Notion. Status advances from `Hold` to `Researched`.

```
/career-engine --coach-skills
```

Alternatively, run intake on a single role by pasting a URL or JD directly:

```
/career-engine:career-coach <url or JD text>
```

#### Options and commands

| Option | Description |
|---|---|
| `--coach-skills` | Notion-fetch mode: queries all Hold roles from Notion, acquires their JDs, runs the career coach for each, and writes results back to Notion. |
| `/career-engine:career-coach <url or JD>` | Inline mode: no Notion interaction — runs the coach and delivers output conversationally. |

**JD acquisition:** Intake fetches the JD from the role's URL using a multi-step ladder. It tries rendering-capable extraction tools first (Tavily, Exa), falls back to web search for mirrored postings (company careers page, ATS boards, LinkedIn, BuiltIn), and marks a role `needs-manual` only after exhausting all fetch paths. Indeed URLs route through the Indeed job search connector rather than plain web fetch.

> **Note:** The Intake pipeline does not write CVs or cover letters, and it never creates or modifies Notion views. For CV and cover letter production, run [New Application](#new-application).

---

### New Application

The full per-role pipeline. Runs against all roles with Status `Interested`. For each role:

1. Checks that required strategic properties (Role emphasis, Keywords, Strategy) are populated — roles missing any of these are excluded with a log message directing you to run intake first
2. Drafts a tailored CV against the role's strategic properties
3. Gates the CV through the gatekeeper (ATS checks, fabrication checks, formatting rules)
4. Runs a recruiter review, then a hiring-manager review
5. Revises the CV until it passes (cap: 3 revision passes)
6. Drafts a cover letter if `Why I Want This Role` is populated in Notion
7. Gates the letter through the gatekeeper (cap: 3 revision passes)
8. Runs a coach strategic review on the gatekeeper-approved letter
9. Runs the humanizer to remove AI writing patterns
10. Gates the humanized letter one final time
11. Exports CV and cover letter to DOCX using pandoc and your `.dotx` template
12. Runs the Hebrew localization step if `Languages` includes Hebrew
13. Writes file paths and results back to Notion; writes a LinkedIn updates file to the output folder

```
/career-engine
```

**Queue cap:** the pipeline processes up to 5 `Interested` roles per run, ordered by Priority (Highest first, then First, Second, Third, Fourth, Fifth). Unscored roles fill any remaining slots. Roles beyond the cap remain in the queue for the next run.

**Cover letter prerequisite:** the letter pipeline requires `Why I Want This Role` to be filled in the role's Notion row before the run. If it is empty, the pipeline delivers a CV only and logs the skip reason. See [Cover letter prerequisites](#cover-letter-prerequisites).

**Gatekeeper rules:** the gatekeeper checks for fabricated claims, ATS formatting issues, CV content that directly repeats the cover letter opener, word count compliance (maximum 320 words for cover letters; no minimum), and voice rule violations. It never rewrites. It returns PASS or FAIL with specific violations. The pipeline retries up to 3 passes before flagging and continuing.

**LinkedIn updates file:** after all roles complete, the pipeline writes `linkedin-updates-<YYYY-MM-DD>.md` to your output folder. It aggregates keywords across all roles processed in the run, compares them against your saved LinkedIn profile (if available), and surfaces which terms are genuinely missing, already covered, or present but buried. One file is produced per run, not per role.

---

### Edit

Refines existing CV and cover letter outputs for roles with Status `Needs editing`. Reads the existing DOCX files, runs the relevant pipeline stages again based on the `Edit type` property (`CV`, `Letter`, or `Both`), and saves revised files to a new dated folder.

```
/career-engine --edit
```

**Prerequisites:**
- `Edit type` property must be set in the role's Notion row (`CV`, `Letter`, or `Both`)
- For letter edits (`Letter` or `Both`): `Why I Want This Role` must be populated
- The role must have been processed by the New Application pipeline first

**Edit notes:** when `Why I Want This Role` references specific property values as content sources, the edit pipeline passes those values verbatim to the letter-writer — never paraphrased or distilled.

> **Note:** The Edit pipeline never starts from scratch. It works only with roles that have existing Notion rows and output files. If strategic properties are missing, the role is excluded with a "run intake first" message.

---

### Fast track

Runs the full per-role pipeline on a single role without a Notion row. Pass a URL or JD text directly. The pipeline requires `Role emphasis`, `Keywords`, and `Strategy` inline — the career coach does not run in fast-track mode.

```
/career-engine --now <url or JD text>
```

The pipeline collects `Why I Want This Role` from you in chat before proceeding; if you decline, it delivers a CV only. Fast track never reads from or writes to Notion. Output files go to your configured output folder.

> **Note:** Hebrew output is not supported in fast-track mode. No Notion row exists, so the `Languages` property cannot be read. Add the role to Notion and run the standard pipeline if Hebrew files are required.

---

### Localization

Translates an approved English CV and cover letter into your configured second language. Runs automatically when a role's `Languages` property includes the second language, after the English DOCX files are complete.

The localization agent translates structure and content exactly — it does not draft, revise, or evaluate fit. The fabrication rule applies as strictly as in the source language: nothing is inferred or added during translation.

**Hebrew and other RTL languages:** RTL output requires a dedicated RTL-configured `.dotx` template. Setup prompts you to configure this if your second language is RTL (Hebrew, Arabic, Persian/Farsi, Urdu, or others). The Hebrew templates (`cvHe.dotx`, `he-letter.dotx`) live in `word_templates_path` (configured in setup). If `word_templates_path` is empty, Hebrew export is skipped and noted in the run summary.

**Output files:** the Hebrew CV is named `he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx`; the Hebrew cover letter is `he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx`. Both go in the same company subdirectory as the English files.

---

### Utility modes

These modes run a single pass with no loops and no Notion writeback.

| Flag | What it does |
|---|---|
| `--coach` | Conversational fit assessment or strategic framing question. The career coach responds directly in chat. |
| `--check` | Single gatekeeper pass on a CV or cover letter you paste. Specify CV or letter. JD is optional but improves checks that require JD comparison. Returns PASS or FAIL with violations. |
| `--review` | Single recruiter and hiring-manager review pass on a CV or cover letter you paste. Returns both reviews in sequence. |
| `--write-letter` | Standalone cover letter draft from a URL or JD text. No CV required, no reviewers, no gatekeeper loop. Returns a draft. Requires `Why I Want This Role` content — provide it in the same message or the letter-writer will ask. |
| `--status` | Reads `state.json` from the most recent run folder and prints a completion table showing which roles finished, which files exist on disk, and any files listed in state.json that are missing. |

---

## Cover letter prerequisites

The cover letter pipeline will not run without `Why I Want This Role` filled in the role's Notion row. This is a hard gate — the letter-writer never generates motivation on your behalf.

**What "good" looks like:**

Good content is specific: your actual reaction when you read the JD, what you noticed, what excited you, what connected to something you have done or want to do. A few sentences is enough.

Examples that work:
- "The thing that grabbed me was that they're building agentic SecOps — I spent two years marketing exactly this layer and I've been watching this space evolve."
- "I daydream about consumer campaigns. I've spent my whole career in B2B and I'm genuinely ready to apply what I know to products people actually want."

Examples that are not enough:
- "I think this role is a great fit."
- "I'm excited about this opportunity."
- "This company does interesting work."

**What happens when it's empty:**
- New Application pipeline: cover letter step is skipped; CV only is delivered; skip is logged.
- Edit pipeline with `Edit type = Letter` or `Both`: the role is excluded from the edit run with a log message.
- `--write-letter` mode: the letter-writer will ask you to provide this content before proceeding.
- `--now` mode: the pipeline asks you in chat before Step 5; if you decline, CV only is delivered.

**This field is set manually by you in Notion.** No pipeline agent ever writes to it.

---

## State file and crash recovery

The pipeline writes `state.json` to the run folder after each role completes (post-DOCX, pre-Notion-writeback). It is a crash-recovery file, not a run history — a role that crashed before DOCX export will not appear in it.

**Check run status:**

```
/career-engine --status
```

This reads `state.json` from the most recent run folder and prints a table showing:
- Which roles completed
- Which files are on disk (CV, cover letter, Hebrew CV, Hebrew cover letter, feedback, revision log)
- Any file listed in state.json that is missing on disk

**Crash scenarios:**

| What happened | What to do |
|---|---|
| state.json has fewer roles than expected | One or more roles crashed before completing. Re-run the pipeline — roles not in state.json always run fresh. |
| state.json is complete but a file is missing on disk | The state was written but the file copy failed. Re-run that role. |
| state.json is complete and files are present but Notion shows `Interested` | Step 7c (Notion writeback) failed after state was written. Files are good. Manually set Status to `CV Ready for Review` in Notion and write the Draft Directory URL to the `Draft Directory` property. |

All pipeline steps are stateless and safe to re-run. They overwrite the previous output intentionally.

---

## Update prompts

After each New Application or Edit run, the pipeline writes an `update-prompt-<company>-<monYYYY>.md` file into the role's company subdirectory when `Why I Want This Role` contains durable content worth preserving in your motivation bank (`02-professional-background.md` §5).

**Where to find them:** `<output_folder>/<run_folder>/<company_dir>/update-prompt-<company>-<monYYYY>.md`

**What to do with them:** paste the file contents into Claude Chat or Claude Code. The prompt is self-contained — it includes instructions for updating your career-data and repackaging the skill. If you use both Chat and Code, paste in both environments to keep them in sync.

**What they contain:** a fixed context block (the same every time) plus a variable content block with the company, role title, date, and the Why I Want This Role content that qualified for promotion. The receiving agent appends it to `02-professional-background.md` §5 (Motivation Bank).

---

## Output files

All pipeline output goes to:
`<output_folder>/<prefix>-<YYYY-MM-DD>/<company_dir>/`

The prefix defaults to `applications` (for example, `applications-2026-06-19`). Configure a different prefix via `output_dir_prefix` in setup.

The company directory name is derived from the Notion Company property: lowercase, spaces to hyphens, non-alphanumeric characters stripped (for example, `"Acme Corp"` → `acme-corp`).

**Files per role:**

| File | Description |
|---|---|
| `cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx` | Tailored CV |
| `coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx` | Cover letter (if Why I Want This Role was provided) |
| `he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx` | Hebrew CV (if Languages includes Hebrew) |
| `he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx` | Hebrew cover letter (if Languages includes Hebrew) |
| `feedback-<roletitle>-<company>-<monYYYY>.md` | Recruiter and hiring-manager feedback |
| `revision-log-<roletitle>-<company>-<monYYYY>.md` | Per-role revision log and validation results |
| `update-prompt-<company>-<monYYYY>.md` | career-data update prompt (when Why I Want This Role qualifies) |
| `_pipeline/` | Intermediate artifacts (reviewer output, gatekeeper violations) — not deliverables |

**Files per run:**

| File | Description |
|---|---|
| `state.json` | Crash recovery — roles that completed DOCX export |
| `linkedin-updates-<YYYY-MM-DD>.md` | LinkedIn keyword gap analysis across all roles in this run |
| `revision-log-<YYYY-MM-DD>.md` | Run-level revision log |
| `run-metrics-<date>.json` | Token usage and cost estimate (written by the Stop hook) |

**DOCX production:** cv-writer outputs styled markdown using pandoc's custom-style syntax. The pipeline converts it to `.docx` using pandoc with your `.dotx` reference template, then runs a subtitle update script to write the exact JD role title into the CV document header. The user's name and contact details come from the template — no pipeline step hand-sets fonts, sizes, or colors.

The subtitle under your name in the CV is always the exact job title from the JD, not a generic descriptor. The pipeline sets this automatically using `skills/career-engine-export/scripts/update-subtitle.py`.

---

## Standalone capabilities

The following capabilities run independently of the application pipeline and require no prior pipeline setup beyond installation.

### LinkedIn coach

Reviews and optimises your LinkedIn presence across five modes.

```
/career-engine:linkedin-coach
```

| Mode | What it covers |
|---|---|
| A — Full Profile Audit | Complete profile review against your target positioning or a specific role |
| B — Content Review | Analysis of existing posts for audience alignment and impact |
| C — Content Strategy | Sustainable 3x/week posting strategy built from your content pillars |
| D — Headline Optimisation | Headline-only focus; returns three rewrites with trade-off notes |
| E — Video Introduction | 30-second profile video script |

**Framework primacy:** the LinkedIn coach treats `03-framework.md` as the source of truth about your positioning. Recommendations strengthen the direction your framework describes, not the nearest open role.

The coach reads your profile from `${CAREER_DATA}/references/linkedin-profile.md` (a saved LinkedIn PDF export) if present, falls back to the LinkedIn MCP if connected, and asks you to paste sections if neither is available. Without a profile on file, recommendations are based on raw market signals rather than analysis of your actual profile.

---

### Personal brand

Builds or refreshes your personal brand using the Why You / Why Them / Why Now framework.

```
/career-engine:personal-brand
```

| Capability | What it produces |
|---|---|
| A — Brand Foundation | Positioning statement, one-line elevator version, three-word brand summary, and the "permission slip" (the specific experience that earns the right to speak on this topic) |
| B — Audience and Channel Map | Named audience segment with problem, platform map, and channel-specific tone guidance |
| C — Content Pillars and Cadence | Three to four content pillars with weekly cadence and post-type recommendations |
| D — Bio Library | Bios in four lengths (tweet, LinkedIn About, speaker deck, long-form) calibrated to each platform's norms |
| E — Brand Refresh | Gap analysis of your current presence against your framework, with a concrete refresh plan |

**Capability status:** personal brand is an early-stage capability. The skill produces well-structured strategic output, but the workflow has not been run through the same volume of iteration and regression hardening as the application pipeline. Outputs are substantively useful but may require more hands-on direction than the intake or new-application pipelines.

**Coming:** dedicated pipelines for LinkedIn post drafting, blog content, and broader thought leadership — grounded in your content pillars and voice fingerprint, with the same fabrication rules and delivered-archive calibration as the application pipeline.

---

### Career coach

Provides conversational coaching on a role, a strategic framing question, or a fit assessment. No Notion writeback. No documents produced.

```
/career-engine --coach
```

The career coach also powers the intake pipeline (`--coach-skills`), where it runs in a structured mode: fetches JDs, scores priority, writes strategic properties to Notion. The `--coach` flag bypasses all of that and gives you a direct conversational response.

---

### Update references

Folds new career materials into your reference files — a new CV, a testimonial, a promotion, a completed project, or updated contact details.

```
/career-engine:update-refs
```

The agent reads the material you provide, classifies it against the reference map (`REFERENCES.md`), proposes specific additions or modifications, and applies them only after you approve each change. It never rewrites a reference without explicit approval.

> **Note:** Update references does not write application content and does not write to Notion.

---

### Plugin builder

Development partner for extending or maintaining this plugin. Reads `CLAUDE.md` and the plugin-builder skill before touching anything, enforces single-build architecture rules, and ends every session by running the QA agent and rebuilding the `.plugin` artifact.

```
/career-engine:plugin-builder
```

---

### Technical writer

Principal systems architect for technical documentation. Covers API docs, PRDs, specs, READMEs, runbooks, SOPs, tutorials, how-to guides, conceptual explanations, and prompt writing.

```
/career-engine:technical-writer
```

Three modes: Write (create from scratch), Edit (improve existing documentation), Review (evaluate against quality standards with verbatim findings).

---

## Architecture

### Single-build model

The plugin ships as one build: this repository. It contains only agents, skills, and blank reference templates with `{{...}}` placeholders. It holds no personal data.

Your personal data — filled reference files, delivered letters, your `.dotx` template — lives in a separate, user-installed skill named `career-data`, outside the plugin. Plugin upgrades never touch it.

This means:
- No second copy to keep in sync
- No personal data exposed in the public repository
- Plugin changes carry no risk to your career materials

The QA agent validates the built `.plugin` artifact and asserts zero personal data before it ships.

### career-data skill

`career-data` is a `.skill` file generated by the setup agent from your onboarding interview. It contains your three core reference files, your runtime configuration, your delivered-letters archive, and your `.dotx` CV template. Install it through the Desktop app (**Customize → Skills**) and update it the same way whenever you re-run setup or apply an update prompt.

At runtime, agents resolve `${CAREER_DATA}` to the installed skill's path and read your personal files from there. The plugin's blank templates are the new-user fallback only — a configured installation that cannot find `career-data` is a hard stop, not a silent fallback.

**Sync is one-way: Desktop app → Claude Code CLI.** Writing directly to `~/.claude/skills/` from the CLI creates a copy that diverges from the Desktop app version and does not propagate to other Claude surfaces (including Cowork). See [Updating career-data](#updating-career-data) for the correct update path.

### Agents and skills

The plugin separates orchestration from doctrine.

**Agents** (`agents/`) define identity, invocation modes, file loading tables, execution steps, and output format. They do not contain writing craft, voice rules, or candidate-specific content.

**Skills** (`skills/`) contain doctrine: writing rules, positioning philosophy, use-case patterns, checklists, and strategic frameworks. Skills are loaded explicitly by agents via `Read` — they are not activated by the platform based on context.

**References** (`references/`) contain source material: blank templates for background facts, voice profile, approved CV bullets, and delivered letters. Agents read references. They write to references only via explicit pipeline steps with approval gates.

This separation means career materials can be updated without touching pipeline code, and pipeline logic can be updated without touching personal data.

### Output protocol

Per-role pipeline agents (cv-writer, letter-writer, reviewers, gatekeeper, humanizer) write their full output to a file in `<company_dir>/_pipeline/` and return only a one- or two-line status plus a file path. The orchestrator never holds full document content in context — it routes pointers. This keeps token costs manageable across a full pipeline run.

The orchestrator itself never authors document content. It handles mechanical operations: Notion queries, state management, DOCX export coordination, and final summary delivery.

---

## Reference files

The three core reference files live in `career-data` and govern every output the pipeline produces.

| File | What it contains |
|---|---|
| `01-writing-rules.md` | Priority framework, attribution rules, fabrication guards, operational identity, targets, voice profile, and contact details. The fabrication rule — agents never claim a fact not traceable to this file or the role's JD — governs every agent in every pipeline. |
| `02-professional-background.md` | Career content bank: approved CV summaries, role facts, approved CV bullets, testimonials, and portfolio work samples. Every CV claim must be grounded here. Also contains the Motivation Bank (§5), a record of durable Why I Want This Role content promoted from delivered applications. |
| `03-framework.md` | Positioning, voice, methodology, and domain narratives. The primary source of truth about who you are and what you are positioning toward. Contains the quantitative voice fingerprint (§Voice) used for cover letter calibration and LinkedIn optimisation. |

The plugin ships blank templates for each file. Setup synthesizes your materials into them. `update-refs` maintains them over time.

Three additional files support the pipeline:

| File | What it contains |
|---|---|
| `linkedin-profile.md` | Snapshot of your current LinkedIn profile (from a LinkedIn PDF export). Used by orchestrator Step 8 (LinkedIn updates file) and all LinkedIn coach modes. Optional — outputs run in fallback mode (raw signals, no profile analysis) until provided. Replace by running `update-refs` with a fresh LinkedIn export. |
| `references/delivered-letters/` | An archive of sent letters (cap: 6) used by the letter-writer, gatekeeper, and humanizer for voice calibration. The humanizer and gatekeeper treat these letters as the authoritative register source — they override rule-based style prescriptions when the two conflict. |
| `references/pipeline-preferences.json` | Runtime configuration. Written by setup; read at run start by the orchestrator and all standalone entry skills. See [Configuration keys](#configuration-keys) for the full schema. |

Two additional reference files ship inside the plugin (not in career-data):

| File | What it contains |
|---|---|
| `cv-self-check.md` | Mandatory pre-submission self-check for CV output. Covers ATS, summary, key achievements, experience section, header, and word count. |
| `job-preferences.md` | Full job search preferences — remote compatibility rules, target roles, seniority floor, industry fit, company stage, exclusion patterns, and coaching prioritization guidance. Loaded before any sourcing, scoring, or coaching step. |

---

## Configuration keys

All configuration lives in `${CAREER_DATA}/references/pipeline-preferences.json`. Written by setup Phase 5; updated by re-running that phase or applying an update prompt. The pipeline reads this file at run start and resolves every `{{CONFIG}}` placeholder from it.

| Key | Required | Default | What it does |
|---|---|---|---|
| `notion_database_id` | Yes (Notion runs) | — | 32-character Notion database ID. Required for any pipeline that reads from or writes to Notion. |
| `output_folder` | Yes | — | Absolute path to your local output folder. All DOCX files, feedback files, and run artifacts go here. |
| `cv_template` | Yes | — | Path to your CV `.dotx` template, relative to `${CAREER_DATA}` (for example, `references/my-cv.dotx`). |
| `draft_dir_url_base` | No | `skip` | Base URL for your cloud file browser (Anchorpoint, Dropbox, etc.), ending just before the date-folder segment. Written to the `Draft Directory` Notion property after each role completes. Set to `skip` or leave empty to disable. |
| `output_dir_prefix` | No | `applications` | Prefix for the run folder name. Run folders are named `<prefix>-YYYY-MM-DD`. |
| `default_language` | No | `English` | Language used for output when the Notion row's `Languages` field is empty. |
| `word_templates_path` | No | — | Absolute path to the folder containing Hebrew `.dotx` templates (`cvHe.dotx`, `he-letter.dotx`). Required for Hebrew export. |
| `notion_needs_editing_view_url` | No | — | URL of the "Needs Editing" Notion view (including `?v=...`). Used by the edit pipeline as the fast path for querying its queue. |
| `gap_handling` | No | `enabled` | Whether the coach identifies and documents skill gaps for each role. `"enabled"` or `"disabled"`. Suppress for a single run by adding "no gap handling" to your prompt. |
| `location_compatibility` | No | both empty | Object with `my_location` (your city/country/region) and `notion_property` (name of the Notion property to write compatibility to). Both empty = check skipped. |
| `favorite_brands` | No | `[]` | Array of company name strings. Roles at these companies score one tier higher than the coach would otherwise assign. |
| `preferred_job_sites` | No | `[]` | Up to 5 job boards to search on every sourcing run, before plugin defaults. |
| `local_job_sites` | No | `[]` | Up to 2 local or region-specific job boards to prioritize in sourcing. |

**Required for any run:** `output_folder`, `cv_template`. **Also required for any Notion run:** `notion_database_id`. A missing required key produces a hard stop with a message directing you to re-run setup Phase 5.

---

## Token usage tracking

A Stop hook records token usage at the end of every session. It reads the session transcript and all subagent transcripts, sums `input`, `output`, `cache_read`, and `cache_creation` token counts across all turns, calculates a cost estimate, and writes a `run-metrics-<date>.json` file to the run folder in your output folder.

The hook registers automatically via `hooks/hooks.json`. No manual configuration is required after the plugin is installed. Confirm it is working by checking that `run-metrics-*.json` files in your output folder show numeric `token_counts` after a run (not `"pending"` or `"unknown"`).

If your Claude Code version does not auto-load plugin hooks, add this block to `~/.claude/settings.json`, replacing `${CLAUDE_PLUGIN_ROOT}` with your plugin install path:

```json
"hooks": {
  "Stop": [{
    "hooks": [{
      "type": "command",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/log-token-usage.sh"
    }]
  }]
}
```

---

## External connectors

The plugin connects to the following external services.

| Category | Service | Required | Notes |
|---|---|---|---|
| Job tracking | Notion | Yes (pipeline) | See [Notion setup](#notion-setup) below |
| File storage | Local filesystem | Yes | Any local path; iCloud works |
| File system bridge | Desktop Commander MCP | Yes (Cowork) | Enables file operations and pandoc calls from sandboxed Claude sessions. Required for Cowork and some Code environments. Available on macOS, Windows, and Linux. |
| Document conversion | pandoc | Yes | CLI tool; install separately. Used for all DOCX production. |
| Document post-processing | python-docx | Yes | Python package; `pip install python-docx`. Used by the subtitle update script. |
| Job search | Indeed, Dice, ZipRecruiter | Yes | Used for JD fetching during intake |
| LinkedIn research | stickerdaniel/linkedin-mcp-server | Optional | Improves research quality in intake and the LinkedIn coach; falls back to WebSearch |
| Rendering-capable extraction | Tavily, Exa, or equivalent | Optional | Used in the JD acquisition ladder for JavaScript-rendered career pages and auth-walled sites. Discovered automatically via ToolSearch when available. |

### Notion setup

The plugin expects a specific database schema. Duplicate the Notion template to get started:

**[Duplicate the Notion template →](https://abounding-trouser-bce.notion.site/13a6d072845047c0a99cfeb6b201091b?v=843875fd750c4a9d884b298748a4d331)**

After duplicating:

1. Copy the database ID from the URL (`notion.so/<workspace>/<DATABASE_ID>?v=...`)
2. Run `/career-engine:setup` — it collects the ID and writes it to the career-data config

> **Note:** Do not rename Notion columns. The pipeline writes to them by exact name. Renaming any column breaks the integration silently.

If you do not use Notion, the setup agent can configure a Google Sheets or CSV-based workflow instead. In Google Sheets mode, the pipeline reads your roles but does not write results back to the sheet — outputs go to your output folder only.

### LinkedIn MCP (optional)

When configured, intake and the LinkedIn coach use this server for company research and hiring manager profiles. To install:

```bash
uvx linkedin-scraper-mcp@latest --login
```

Configure it in Claude Code settings with server name `linkedin-mcp`.

---

## Capability status

Not all pipelines have the same level of production hardening.

| Pipeline / capability | Status | Notes |
|---|---|---|
| Sourcing | Production | Runs against live job boards; scoring and deduplication tested across many runs |
| Intake | Production | Multi-step JD acquisition ladder; rendering-capable fallbacks; coach writeback tested |
| New Application | Production | 40+ regression checks documented in CLAUDE.md; every known failure mode has a guard |
| Edit | Production | Edit pipeline mirrors new-application coverage; own regression history |
| Fast track | Production | Tested; fewer Notion integration points than the main pipeline |
| Localization | Production | Translation-only; no drafting or revision |
| Utility modes (`--check`, `--review`, `--write-letter`, `--coach`, `--status`) | Production | Single-pass; no state management |
| Update references | Production | Approval-gated; conservative by design |
| LinkedIn coach | Early capability | Framework-grounded; profiles read from saved export or MCP; not yet run through the same regression volume as the application pipeline |
| Personal brand | Early capability | Skill produces structured strategic output but has not been through iterative hardening. Outputs require more hands-on direction. Treat as a strong starting framework rather than a finished deliverable. |
| Plugin builder | Internal tooling | Tested against the plugin's own change history |
| Technical writer | Production | Doctrine-driven; used to produce this document |

**Early capability** means the skill exists, produces substantively useful output, and is safe to use — expect to provide more direction, correct more often, and iterate more manually than with the production pipelines. These are capabilities worth using, not capabilities to avoid.
