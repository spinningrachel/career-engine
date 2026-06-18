# career-engine

A Claude Code plugin for senior technology professionals who want their career to work for them — whether that means landing the right next role, building a credible professional presence, or maintaining the materials and positioning that make both possible on short notice.

The plugin covers three surfaces. The **application pipeline** connects your career materials to a Notion job-tracking database and runs a multi-agent workflow that researches roles, writes tailored CVs and cover letters, routes them through recruiter and hiring-manager review, gatekeeps them against fabrication rules, exports them to DOCX, and writes results back to Notion. The **presence and brand surface** covers LinkedIn optimisation and personal brand development — with richer pipelines for LinkedIn content, blog posts, and broader thought leadership coming. The **maintenance layer** keeps your reference files, positioning framework, and delivered-letter archive current so every pipeline run starts from accurate material.

Everything is grounded in a single source of truth about you — your positioning framework, your career content bank, your approved voice — and none of it lives in the plugin itself, so upgrades never overwrite your data.

---

## Table of contents

- [How it works](#how-it-works)
- [Unique advantages](#unique-advantages)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Pipelines](#pipelines)
  - [Sourcing](#sourcing)
  - [Intake](#intake)
  - [New Application](#new-application)
  - [Edit](#edit)
  - [Fast track](#fast-track)
  - [Localization](#localization)
  - [Utility modes](#utility-modes)
- [Standalone capabilities](#standalone-capabilities)
  - [LinkedIn coach](#linkedin-coach)
  - [Personal brand](#personal-brand)
  - [Update references](#update-references)
  - [Plugin builder](#plugin-builder)
  - [Technical writer](#technical-writer)
- [Architecture](#architecture)
  - [Single-build model](#single-build-model)
  - [career-data skill](#career-data-skill)
  - [Agents and skills](#agents-and-skills)
  - [Output protocol](#output-protocol)
- [Reference files](#reference-files)
- [Token usage tracking](#token-usage-tracking)
- [External connectors](#external-connectors)
- [Capability status](#capability-status)

---

## How it works

You install the plugin, run setup once, and then manage your job search through slash commands. The plugin reads your career materials from an external `career-data` skill it never modifies, pulls roles from a Notion database, and runs specialized agents for each stage of the application pipeline.

The core pipeline stages are:

1. **Sourcing** — find open roles across job boards and LinkedIn, scored against your preferences, deduplicated against your Notion database.
2. **Intake** — research a role, run the career coach, and write strategic properties (priority, emphasis, keywords, strategy) to Notion. No CVs yet.
3. **New Application** — draft and refine a CV and cover letter through recruiter review, hiring-manager review, and gatekeeper checks, then export DOCX files to your output folder.
4. **Edit** — refine existing CV and cover letter outputs for roles already processed.

Each stage hands off to the next via Notion status transitions (`Hold` → `Researched` → `Interested` → `Needs editing`). The pipeline never skips a stage or back-fills properties it does not own.

---

## Unique advantages

**Your voice, not a generic voice.** Every agent in the pipeline calibrates against your delivered-letters archive — actual sent letters, not a rule list. The humanizer and gatekeeper treat those letters as the authoritative register source. When a style rule and a sent letter conflict, the sent letter wins.

**Fabrication-proof by architecture.** The fabrication rule is not a prompt instruction — it is enforced structurally. The gatekeeper checks every CV claim against your career content bank (`02-professional-background.md`) and refuses to pass a document that asserts something not traceable to an approved source. This means your materials are bold and specific rather than hedged, because every claim is verifiable.

**Specialized agents for every stage.** A single LLM doing everything produces generic output and loses context across a long pipeline. This plugin uses a distinct agent for each role: career coach, CV writer, letter writer, recruiter reviewer, hiring-manager reviewer, gatekeeper, humanizer, localization agent. Each agent loads only the doctrine it needs. The orchestrator handles routing; it never authors content.

**Framework primacy.** Your positioning framework (`03-framework.md`) governs every output — not the nearest open job posting. The LinkedIn coach, the career coach, and the personal brand skill all treat the framework as the source of truth about who you are and where you are heading. A single application, a single target role, or any one run's signals do not pull your positioning off course.

**State-backed crash recovery.** The orchestrator writes `state.json` per run. If a session ends mid-pipeline, `--status` tells you exactly which roles completed, which files exist on disk, and what is missing. You can resume without re-running finished stages.

**No personal data in the plugin.** Your career materials, filled reference files, and delivered letters live in a separate `career-data` skill the plugin never touches. You can install a plugin update without any risk to your data. There is no second copy to keep in sync.

**Regression-guarded.** Over 40 documented failure modes are logged in `CLAUDE.md` with their root cause, fix, and the files that changed. Every session that touches an affected file verifies the regression has not returned. The QA agent runs as a mandatory gate after every plugin change and asserts structural integrity across all agents, skills, and references before a new build ships.

---

## Prerequisites

Before installing, verify you have:

- Claude Code (desktop app or CLI) with MCP server support
- [pandoc](https://pandoc.org/installing.html) installed (the export stage uses it for DOCX conversion)
- A Notion workspace with the plugin database schema (see [External connectors → Notion setup](#notion-setup))
- A local output folder where DOCX files will be saved (iCloud or any local path)

The LinkedIn MCP server is optional but improves research quality. See [External connectors](#external-connectors) for install instructions.

---

## Setup

Run setup once after installing the plugin. It conducts a structured onboarding interview with you — asking about your career history, target roles, positioning, and preferences — and from that conversation synthesizes the three core reference files and your runtime configuration into a `career-data` skill package that it saves to your Claude installation.

`career-data` does not exist before setup runs. Setup creates it.

```
/career-engine:setup
```

The interview covers:

- Your career history, target roles, and positioning (synthesized into `01-writing-rules.md`, `02-professional-background.md`, and `03-framework.md`)
- Your Notion database ID
- Your local output folder path
- Your CV template (`.dotx` file path)
- Your job preferences, including remote compatibility and exclusion patterns
- Your gap-handling preference (whether pipeline agents flag employment gaps)

At the end of setup, you upload the generated `.skill` file through the Desktop app (Settings → Capabilities → Skills). Every subsequent pipeline run reads your personal data from that installed skill. Re-run setup at any time to update your materials or configuration; the same upload step applies.

---

## Pipelines

### Sourcing

Finds open roles across LinkedIn, remote boards, startup boards, general job boards, and Upwork. Scores results against your saved preferences, deduplicates against your Notion database, and returns a ranked list with fit rationale.

```
/career-engine:source-open-roles
```

Roles you accept are added to Notion with Status `Hold`. No CV or letter writing happens here.

**What sourcing does not do:** it does not research roles or write strategic properties. Those happen during intake.

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

**JD acquisition:** intake fetches the JD from the role's URL using a multi-step ladder. It tries rendering-capable extraction tools first (Tavily, Exa), falls back to web search for mirrored postings, and marks a role `needs-manual` only after exhausting all fetch paths. Indeed URLs route through the Indeed job search connector rather than plain web fetch.

**What intake does not do:** it does not write CVs or cover letters, and it never creates or modifies Notion views.

---

### New Application

The full per-role pipeline. Runs against all roles with Status `Interested`. For each role:

1. Drafts a tailored CV against the role's strategic properties
2. Runs a recruiter review, then a hiring-manager review
3. Gates the CV through the gatekeeper (ATS checks, fabrication checks, formatting rules)
4. Revises the CV until it passes (cap: 3 revision passes)
5. Drafts a cover letter if `Why I Want This Role` is populated in Notion
6. Gates the letter through the gatekeeper (cap: 3 revision passes)
7. Runs a coach strategic review on the gatekeeper-approved letter
8. Runs the humanizer to remove AI writing patterns
9. Gates the humanized letter one final time
10. Exports CV and cover letter to DOCX using pandoc and your `.dotx` template
11. Writes file paths and results back to Notion

```
/career-engine
```

**Cover letter prerequisite:** the letter pipeline requires `Why I Want This Role` to be filled in the role's Notion row before the run. If it is empty, the pipeline delivers a CV only and logs the skip reason. This field is the primary source of personal content for the letter — it governs the opener, drives the evidence selection, and determines the letter's tone. Fill it before running.

**Gatekeeper rules:** the gatekeeper checks for fabricated claims, ATS formatting issues, CV content that directly repeats the cover letter opener, word count compliance, and voice rule violations. It never rewrites. It returns PASS or FAIL with specific violations. The pipeline retries up to 3 passes before flagging and continuing.

---

### Edit

Refines existing CV and/or cover letter outputs for roles with Status `Needs editing`. Reads the existing DOCX files, runs the relevant pipeline stages again based on the `Edit type` property (`CV`, `Letter`, or `Both`), and saves revised files to a new dated folder.

```
/career-engine --edit
```

**What edit does not do:** it never starts from scratch. It works only with roles that have existing Notion rows and output files.

**Prerequisite:** the `Edit type` property must be set in the role's Notion row. For letter edits, `Why I Want This Role` must be populated. If the cover letter path is empty or the file cannot be located, the letter track is skipped with a logged message.

---

### Fast track

Runs the full per-role pipeline on a single role without a Notion row. Pass a URL or JD text directly. The pipeline collects `Why I Want This Role` from you in chat before proceeding; if you decline, it delivers a CV only.

```
/career-engine --now <url or JD text>
```

Fast track never reads from or writes to Notion. Output files go to your configured output folder.

---

### Localization

Translates an approved English CV and cover letter into your configured second language. Runs automatically when a role's `Languages` property includes the second language, after the English DOCX files are complete.

The localization agent translates structure and content exactly — it does not draft, revise, or evaluate fit. The fabrication rule applies as strictly as in the source language: nothing is inferred or added during translation.

---

### Utility modes

These modes run a single pass with no loops and no Notion writeback.

| Flag | What it does |
|---|---|
| `--coach` | Conversational fit assessment or strategic framing question. The career coach responds directly in chat. |
| `--check` | Single gatekeeper pass on a CV or cover letter you paste. Specify CV or letter. JD is optional but improves checks that require JD comparison. Returns PASS or FAIL with violations. |
| `--review` | Single recruiter + hiring-manager review pass on a CV or cover letter you paste. Returns both reviews in sequence. |
| `--write-letter` | Standalone cover letter draft from a URL or JD text. No CV required, no reviewers, no gatekeeper loop. Returns a draft. |
| `--status` | Reads `state.json` from the most recent run and prints a completion table — which roles finished, which files exist on disk, and any files listed in state.json that are missing. |

---

## Standalone capabilities

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

**Framework primacy:** the LinkedIn coach treats `03-framework.md` as the source of truth about your positioning. A single active application or target role does not override your overall positioning — recommendations strengthen the direction your framework describes, not the nearest open role.

The coach reads your profile from `references/linkedin-profile.md` (a saved LinkedIn PDF export) if present, falls back to the LinkedIn MCP if connected, and asks you to paste sections if neither is available.

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

**Capability status:** personal brand is an early-stage capability. The skill produces well-structured strategic output, but the workflow has not been run through the same volume of iteration and regression hardening as the application pipeline. Outputs are substantively useful but may require more hands-on direction than the intake or new-application pipelines. See [Capability status](#capability-status) for the full picture.

**Coming:** dedicated pipelines for LinkedIn post drafting, blog content, and broader thought leadership — grounded in your content pillars and voice fingerprint, with the same fabrication rules and delivered-archive calibration as the application pipeline.

---

### Update references

Folds new career materials into your reference files — a new CV, a testimonial, a promotion, a completed project, or updated contact details.

```
/career-engine:update-refs
```

The agent reads the material you provide, classifies it against the reference map (`REFERENCES.md`), proposes specific additions or modifications, and applies them only after you approve each change. It never rewrites a reference without explicit approval.

**What update references does not do:** it never writes application content and never writes to Notion.

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
- Plugin changes never risk overwriting your career materials

The QA agent validates the built `.plugin` artifact and asserts zero personal data before it ships.

### career-data skill

`career-data` is a `.skill` file generated by the setup agent from your onboarding interview. It contains your three core reference files, your runtime configuration, your delivered-letters archive, and your `.dotx` CV template. You install it through the Desktop app (Settings → Capabilities → Skills) and update it the same way whenever you re-run setup.

At runtime, agents resolve `${CAREER_DATA}` to the installed skill's path and read your personal files from there. The plugin's blank templates are the new-user fallback only — a configured installation that cannot find `career-data` is a hard stop, not a silent fallback.

**Sync is one-way: Desktop app → Claude Code CLI.** Never write `~/.claude/skills/` directly from the CLI — it creates a copy that diverges from the Desktop app version and will not propagate to other Claude surfaces (including Cowork).

### Agents and skills

The plugin separates orchestration from doctrine.

**Agents** (`agents/`) define identity, invocation modes, file loading tables, execution steps, and output format. They do not contain writing craft, voice rules, or candidate-specific content.

**Skills** (`skills/`) contain doctrine: writing rules, positioning philosophy, use-case patterns, checklists, and strategic frameworks. Skills are loaded explicitly by agents via `Read` — they are not activated by the platform based on context.

**References** (`references/`) contain source material: blank templates for background facts, voice profile, approved CV bullets, and delivered letters. Agents read references. They write to references only via explicit pipeline steps with approval gates.

This separation means you can update your career materials without touching the pipeline code, and pipeline logic can be updated without touching your data.

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

Two additional files support the letter pipeline:

| File | What it contains |
|---|---|
| `references/delivered-letters/` | An archive of sent letters (cap: 6) used by the letter-writer, gatekeeper, and humanizer for voice calibration. The humanizer and gatekeeper treat these letters as the authoritative register source — they override rule-based style prescriptions when the two conflict. |
| `references/pipeline-preferences.json` | Runtime configuration: `notion_database_id`, `output_folder`, `cv_template`, `draft_dir_url_base`, `word_templates_path`, `notion_needs_editing_view_url`, `gap_handling`. Written by setup; read at run start by the orchestrator and standalone entry skills. |

---

## Token usage tracking

A Stop hook records token usage at the end of every session. It reads the session transcript and all subagent transcripts, sums token counts across all turns, calculates a cost estimate using Opus pricing, and writes a `run-metrics-<date>.json` file to your run folder.

The hook registers automatically via `hooks/hooks.json`. No manual configuration is required after the plugin is installed.

---

## External connectors

The plugin connects to the following external services.

| Category | Service | Required | Notes |
|---|---|---|---|
| Job tracking | Notion | Yes | See Notion setup below |
| File storage | Local filesystem | Yes | Any local path; iCloud works |
| File system bridge | Desktop Commander MCP | Yes | Enables file operations and pandoc calls from within Claude sessions |
| Job search | Indeed, Dice, ZipRecruiter | Yes | Used for JD fetching during intake |
| Document conversion | pandoc | Yes | CLI tool; install separately |
| LinkedIn research | stickerdaniel/linkedin-mcp-server | Optional | Improves research quality in intake and the LinkedIn coach; falls back to WebSearch |

### Notion setup

The plugin expects a specific database schema. Duplicate the Notion template to get started:

**[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**

After duplicating:

1. Copy the database ID from the URL (`notion.so/<workspace>/<DATABASE_ID>?v=...`)
2. Run `/career-engine:setup` — it collects the ID and writes it to the plugin config

If you do not use Notion, the setup agent can configure a CSV-based workflow instead.

### LinkedIn MCP (optional)

When configured, intake and the LinkedIn coach use this server for company research and hiring manager profiles. Install it separately:

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
| Utility modes (`--check`, `--review`, `--write-letter`, `--coach`) | Production | Single-pass; no state management |
| Update references | Production | Approval-gated; conservative by design |
| LinkedIn coach | Early capability | Framework-grounded; profiles read from saved export or MCP; not yet run through the same regression volume as the application pipeline |
| Personal brand | Early capability | Skill produces structured strategic output but has not been through iterative hardening. Outputs require more hands-on direction. Treat as a strong starting framework rather than a finished deliverable. |
| Plugin builder | Internal tooling | Tested against the plugin's own change history |
| Technical writer | Production | Doctrine-driven; used to produce this document |

**Early capability** means the skill exists, produces substantively useful output, and is safe to use — but you should expect to provide more direction, correct more often, and iterate more manually than with the production pipelines. These are capabilities worth using, not capabilities to avoid.
