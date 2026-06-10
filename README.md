# career-engine

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A1L720MCOG)

**[⬇️ Download career-engine.plugin](https://github.com/spinningrachel/career-engine/raw/main/career-engine.plugin)** — install directly in [Claude Code Cowork](https://cowork.anthropic.com). After installing, run `/career-engine:setup` to configure the plugin with your own background and job tracking setup.

> **⚠️ UNDER CONSTRUCTION — EXPERIMENT AT YOUR OWN RISK**
> This plugin is actively developed and not yet stable. Expect rough edges, incomplete features, and breaking changes between versions. Back up your reference files before updating.

Job searching at scale breaks down fast. Every application takes hours to tailor, each session starts from scratch, and most AI tools make it worse: they write confidently about experience you don't have.

The career-engine plugin runs a full multi-agent pipeline. It pulls your target roles from Notion, researches each company, drafts and reviews tailored CVs and cover letters, exports formatted Word files to your output folder, and writes results back to Notion. No supervision required.

One rule runs through every agent: nothing goes on the page that isn't traceable to your documented background. The system gets sharper the more you run it. Every correction feeds back into the files every agent reads before writing anything.

Most job search tools give you one agent and a template. A few things that are different here:

- **Multi-agent review loop** — cv-writer, gatekeeper, recruiter reviewer, and hiring manager reviewer all run before anything is delivered
- **Employment coach with prioritization** — researches each company, scores your role queue, and writes strategic framing before a single bullet is drafted
- **Mandatory revision pass** — every letter runs a voice calibration and AI-pattern audit before the gatekeeper sees it. Not optional, not conditional
- **Fabrication-proof** — nothing goes on the page that isn't traceable to your documented background. Reviewer pressure cannot override this
- **Error handling and crash recovery** — failed roles are logged and skipped; the run continues. State is written after every role so a crashed run can resume without starting over
- **Notion integration** *(optional)* — reads your pipeline from Notion, writes CV file paths and coach properties back to each row when the run completes. CSV and Google Sheets are also supported
- **Hebrew localization** *(Alpha)* — native Israeli professional Hebrew CVs and cover letters produced as a pipeline step. Enriched options and RTL configuration documentation coming soon

What makes these reliable is the structure underneath. Three reference files — candidate rules, candidate background, and positioning framework — are read by every agent before writing anything. They accumulate as you run the pipeline. The longer you use it, the less it invents and the more it knows.

**Built and maintained by [Rachel Cheyfitz](https://www.linkedin.com/in/rachelcheyfitz).** Open-sourced so other job seekers can run the same pipeline with their own background, voice, and job-tracking setup.

---

## Contents

1. [How it works](#how-it-works)
2. [Prerequisites](#prerequisites)
3. [Onboarding](#onboarding)
4. [Your three reference files](#your-three-reference-files)
5. [Running the pipeline](#running-the-pipeline)
6. [Agents and skills](#agents-and-skills)
7. [Pipeline walkthrough](#pipeline-walkthrough)
8. [Pipelines and modes](#pipelines-and-modes)
9. [Job tracking database](#job-tracking-database)
10. [Output files](#output-files)
11. [How approved bullets work](#how-approved-bullets-work)
12. [Configuration](#configuration)
13. [Troubleshooting](#troubleshooting)
14. [Roadmap](#roadmap)
15. [Support this project](#support-this-project)

---

## How it works

The pipeline has two layers: a set of agents that do the writing and reviewing, and a set of reference files that every agent reads before it writes anything. The agents are fixed — they ship with the plugin and don't change. The reference files are yours — they start as templates and fill in as you use the system.

### The reference files

Three files in `references/` govern everything every agent produces.

**`01-writing-rules.md`** contains the rules that constrain agent behavior: fabrication guards, attribution rules (which outcomes belong to you vs. the company), framing constraints, JD term mappings, and your contact details and target roles. Every agent reads this first. If a claim can't be traced to this file or to `02-professional-background.md`, it doesn't go on the page.

**`02-professional-background.md`** contains your career content: role facts (companies, dates, titles, metrics, what you built), approved CV bullets, approved CV summaries by domain, testimonials, portfolio, and the Q&A bank. Agents draw from this file for every bullet, every proof point, and every intake answer. The Q&A bank accumulates automatically — every answer you give to a pipeline question gets promoted here so the same question is never asked twice.

**`03-framework.md`** contains your positioning: professional category, voice samples, core positioning statement, value pillars, methodology, domain depth, ICP, messaging by audience, taglines, differentiators, and elevator pitches. The letter-writer and employment coach draw from this file for cover letter strategy and career framing. It's what makes the letters sound like you rather than a generic candidate.

### How a run works

The plugin has three application pipelines, plus a sourcing tool for finding new roles. For full descriptions of each, see [Pipelines and modes](#pipelines-and-modes) and [Agents and skills](#agents-and-skills).

**Intake → New Application → Application Edit**

1. Add a role to your job tracking database with Status = `Hold`
2. Run **Intake**: the employment coach researches the company, writes strategic properties to your database, and generates Q&A intake questions tailored to the role
3. Open the role in your database and answer the Q&A questions in the Page Body field
4. Change Status to `Interested`
5. Run **New Application**: the pipeline fetches all `Interested` roles, builds a priority queue of up to five, and routes each one through the full CV and cover letter pipeline — employment coach → cv-writer → gatekeeper → recruiter reviewer → hiring manager reviewer → letter-writer → gatekeeper → DOCX export → writeback
6. Review your documents. If anything needs improving, change Status to `Needs editing`
7. Run **Application Edit**: the editing pipeline improves existing outputs without starting from scratch

---

## Prerequisites

Before installing the plugin, the following tools and services must be in place.

**CLI tools — required for DOCX export:**

| Tool | Install command | Purpose |
|---|---|---|
| pandoc | `brew install pandoc` | Converts CV and cover letter markdown to DOCX |
| python-docx | `pip3 install python-docx` | Updates the role-specific subtitle in the CV header |

pandoc and python-docx are only required if you want formatted DOCX output. The pipeline always produces markdown files — these can be copied into Google Docs, pasted into Notion, or opened in any text editor without pandoc installed. See [CV template and output format](#cv-template-and-output-format) for alternatives.

**Non-technical users:** The setup agent can install pandoc on your behalf. During onboarding, tell the agent you want it to handle the installation and it will run `brew install pandoc` (macOS) for you. If you're on Linux or Windows, ask the agent to find the correct install command for your system.

**MCP servers — connect in Claude Code before running setup:**

| Server | Required | Purpose |
|---|---|---|
| Notion | Yes (for Notion tracking) | Reads job roles and writes results back |
| Desktop Commander | Yes | File system operations for output folder management |
| Indeed, Dice, ZipRecruiter | Recommended | JD fetching and job search; the coach uses these to research roles |
| LinkedIn (stickerdaniel/linkedin-mcp-server) | Optional | Company profiles, hiring manager research, team mapping; also required for `/career-engine:source-open-roles` and `/career-engine:linkedin-coach` |

**LinkedIn MCP setup (stickerdaniel/linkedin-mcp-server):**

The LinkedIn MCP uses your real logged-in browser session — it controls a Chromium browser in the background while agents run. This has two implications:

1. **Do not use your browser while LinkedIn agents are running.** Concurrent browser sessions can trigger LinkedIn security checks, log you out, or cause tool calls to fail. Leave your computer alone for the duration of any run that uses LinkedIn tools (employment-coach with full research, source-open-roles, linkedin-coach).

2. **Do not use your LinkedIn browser tab.** Even if Chrome is your default browser, navigating to LinkedIn manually while the MCP server is active shares the same session — this can interfere with the agent mid-run.

Install with `uv` (install uv first if needed: `curl -LsSf https://astral.sh/uv/install.sh | sh`):

```bash
# First-time login — opens a browser window for you to sign in
uvx linkedin-scraper-mcp@latest --login
```

Add to your `~/.mcp.json` under `mcpServers`:

```json
"linkedin-mcp": {
  "command": "uvx",
  "args": ["linkedin-scraper-mcp@latest"],
  "env": { "UV_HTTP_TIMEOUT": "300" }
}
```

The server name must be `linkedin-mcp` — the plugin's tool declarations depend on this exact key. After adding it, restart Claude Code and verify the tools appear before running any LinkedIn-dependent pipeline.

---

## Onboarding

Onboarding is a one-time process that builds your three reference files from existing materials you provide. Run it after installing the plugin.

```
/career-engine:setup
```

The onboarding agent walks through six phases:

1. **Identity** — your name, email, phone, LinkedIn, location, and citizenship. These power the CV signature, output file names, and all agent instructions.
2. **Content submission** — you send your existing career materials (CVs, cover letters, LinkedIn export, portfolio, old JDs). The agent reads everything and builds `03-framework.md` from it. Files are not stored — only the synthesized output is kept. Cover letters are the exception: if you confirm they represent your voice well, the agent keeps them in `references/delivered-letters/` for future voice calibration.
3. **Framework synthesis** — the agent drafts `03-framework.md` from your submitted content: positioning, voice, domain depth, methodology, value pillars, ICP.
4. **Review and interview** — the agent shares the draft framework for your review. Whether you give feedback or approve, a targeted interview follows: gap-filling from what the materials left unclear, plus probing for things you didn't volunteer (testimonials, published work, community involvement, anti-positioning).
5. **Integration** — you choose your job tracking method (Notion, Google Sheets, or other), configure your output folder (any local path — iCloud, Dropbox, a local directory), CV template, and delivered letters folder.
6. **Permissions** — the agent generates the exact permissions block for your `~/.claude/settings.json`. Without it, Claude Code will pause mid-run for approval on every bash command.

Phases 5 and 6 can be deferred. The pipeline runs with only phases 1–4 complete, though Notion integration is required for the full batch flow.

To re-run a specific phase later:

```
/career-engine:setup --phase 4
```

To check what's been configured and what's missing:

```
/career-engine:setup --verify
```

### Job tracking options

The pipeline supports three job tracking configurations.

**Notion (recommended)** gives full pipeline integration: the coach reads JDs, writes strategic properties, and the orchestrator posts file paths back to each row after the run.

To set up a Notion database, duplicate the template at the link below — it includes all required columns with the exact names and select values the pipeline expects:

**[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**

After duplicating, paste the database ID (the 32-character string from your Notion URL) when the setup agent asks for it.

**Google Sheets** supports reading roles but not writeback — outputs go to your output folder only. During setup, the agent provides a CSV file with all required column headers to upload, and a prompt for setting up dropdown validation on select columns.

**Other platforms** receive the same CSV and a configuration prompt to adapt.

**Column names are hard-coded. Do not rename them.** The pipeline writes to these columns by exact name. Renaming any column breaks the integration without an error.

---

## Your three reference files

The three files in `references/` are the most important files in the plugin. Every agent loads one or more of them before writing anything. Understanding what lives where prevents confusion about why the pipeline produces what it produces.

### `01-writing-rules.md`

This file contains agent operating rules and your identity configuration. It answers the question: *how must agents behave when writing about this candidate?*

The rules section (Section 1) is the most important part. It contains:
- **Attribution rules** — which outcomes belong to you personally vs. the company (e.g., company-level ARR growth is not a personal claim)
- **Fabrication guards** — specific claims that would be easy to make but aren't accurate; these prevent agents from overclaiming scope or inventing experience
- **Framing rules** — how to handle specific scenarios (consulting scope, seniority step-downs, title mismatches)
- **JD term guardrails** — mappings that prevent agents from flagging documented experience as a gap because the JD uses different terminology

The identity section (Section 8) contains your contact details, education, and tools list. This is what populates the CV header and signature.

Section 1 is the first thing every agent reads. If something in this file contradicts what an agent believes about your background, this file is correct.

### `02-professional-background.md`

This file is your career content bank. It answers the question: *what has this candidate actually done, and what language has been approved for describing it?*

The role facts section (Section 7) contains per-company entries: title, dates, reporting structure, team size, key metrics, what was built, and approved CV bullets. Approved bullets are ones the pipeline has written and you have explicitly locked — they are reused verbatim in future CVs. New bullets start empty and fill in as you run the pipeline (see [How approved bullets work](#how-approved-bullets-work)).

The file also contains approved CV summaries by domain (Section 6), testimonials (Section 9), portfolio with links (Section 10), and the Q&A bank (Section 5). The Q&A bank is auto-populated: every answer you give during a pipeline run gets promoted here so the letter-writer never asks the same question twice.

### `03-framework.md`

This file is your positioning framework. It answers the question: *how should this candidate be positioned, in what voice, and for what audience?*

Sections include: professional category and market context, voice samples (direct quotes from how you talk about your work), core positioning statement, value pillars with proof, professional methodology, domain depth by vertical, ICP and target opportunities, messaging by hiring persona, taglines, elevator pitches, differentiators, competitive frame, and anti-positioning rules.

The letter-writer and employment coach draw from this file for every cover letter opener and every strategic framing decision. The more complete and accurate it is, the more the output sounds like you.

`03-framework.md` ships as a blank template. Onboarding builds it from your submitted materials and interview answers. You can edit it directly at any time — it is a living document.

---

## Running the pipeline

The pipeline is triggered by natural language in Claude Code. The commands below show the supported phrases, but any reasonable variation works.

### Full campaign (batch mode)

A full campaign fetches all roles with Status = `Interested` from your job tracking database, runs the employment coach on each, builds a priority queue, and produces a CV and cover letter for each role. The pipeline handles 1–5 roles per run. If you have more than five `Interested` roles, run it multiple times — the queue is rebuilt from whatever remains after each run. To produce a CV without a cover letter, specify "no letter" in your chat command.

```
Run CV campaign.
Process my CV queue.
Run the pipeline.
Run the pipeline, no letters.
```

### Single role, no Notion required

The `--now` mode skips the job tracking database entirely. Pass a URL or paste a JD directly. No Notion writeback occurs — results go to your output folder only.

```
/career-engine --now https://jobs.example.com/head-of-marketing
I just found this role, write my CV: [paste JD]
```

### Market intelligence (research only, no CVs)

The coach-skills pipeline researches companies behind roles with Status = `Hold` and writes competitive intelligence back to Notion. No CVs are produced.

```
Research my Hold roles.
Run market intelligence.
Fill in the competitive landscape.
```

### Editing existing outputs

When a role has Status = `Needs editing` in Notion, the editing pipeline improves existing outputs rather than starting from scratch.

```
Edit my CVs.
Process the Needs editing queue.
```

### Standalone coaching

Direct coaching runs conversationally and does not write to Notion.

```
/career-engine --coach Should I apply to this Axonius role?
/career-engine --coach What's my strongest angle for Head of PMM at a Series B?
```

### Quality checks

These commands run a single gatekeeper or reviewer pass on content you paste — useful for auditing an existing document.

```
/career-engine --check [paste CV or cover letter + JD]
/career-engine --review [paste CV or cover letter + JD]
```

### Cover letter only

Writes a cover letter without running the full pipeline.

```
/career-engine --write-letter [URL or paste JD]
```

### Status check

Reads `state.json` from the most recent run and reports which roles completed, which files were produced, and whether any steps failed. No agents run.

```
/career-engine --status
```

---

## Pipeline walkthrough

This section describes every step in the Standard pipeline in execution order.

### Before the run starts

The orchestrator verifies the output folder exists, loads all required skills, and confirms no mid-run pauses are active.

### Step 0 — Fetch and prepare roles

The orchestrator queries the job tracking database for all rows with Status = `Interested`. For each row, it captures the full payload: company, position, Job URL, JD Body (if already populated), all coach properties, and any existing Q&A content. In `--now` mode, this step is skipped — a single role is passed directly.

### Step 0.5 — JD content preparation

For each role, the orchestrator checks whether a JD Body already exists. If it does, that content is used as the structured JD throughout the run. If it doesn't, the URL is passed to the employment coach to fetch.

### Step 0.8 — Employment coach

The employment coach is the pipeline's research engine. For each role it:

- Fetches the JD from the URL if not already available; drops roles where the JD is inaccessible and logs them
- Researches funding, recent news, hiring manager identity, culture signals, date first advertised, and remote compatibility
- Assigns a priority score if the role has none, respecting existing priorities
- Returns confidence-tagged strategic properties: `[HIGH]` overwrites existing Notion values, `[LOW]` fills only empty fields

The coach writes six Notion properties per role: `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, and `Relationship type`. No other agent may write to these fields.

### Step 0.9 — Priority writeback and briefing

Coach properties are written to Notion. The orchestrator then presents the queue to you: role names, priorities, and a brief on each coach output. This is the last point before CV writing begins.

### Steps 1–4.5 — CV loop

For each role in the queue, the CV loop runs as follows:

1. **cv-writer (draft)** — produces a full CV draft using the coach's Role Type framing, Keywords, and Strategy
2. **gatekeeper (content)** — runs an ATS pre-check (keyword coverage thresholds) and 13 content checks; loops silently with cv-writer until everything passes
3. **recruiter-reviewer** — reviews the CV as a senior recruiter and returns tiered feedback
4. **hiring-manager-reviewer** — reviews the CV as the hiring manager and returns a verdict (Yes / Conditional / No) with specific feedback
5. **cv-writer (revision)** — produces the final CV incorporating recruiter and HM feedback, plus a CV Changes section documenting what changed and why
6. **gatekeeper (content)** — runs the same checks on the final CV; loops until PASS

### Steps 5–5.8 — Cover letter loop

The cover letter loop mirrors the CV loop:

1. **letter-writer (draft)** — produces a cover letter using final CV content, JD, Q&A answers, Strategy, and Gap handling
2. **gatekeeper (cover-letter)** — 13 voice and structure checks; loops silently with letter-writer until PASS
3. **recruiter-reviewer** — reviews the cover letter for screening-risk issues
4. **hiring-manager-reviewer** — evaluates whether the letter addresses the hiring manager's condition, adds something the CV doesn't, and increases interview likelihood
5. **letter-writer (revision)** — produces the final cover letter; mandatory revision pass runs before the gatekeeper sees it
6. **gatekeeper (cover-letter)** — final check; loops until PASS

**What happens if you skipped Q&A or Intake:**

If you skipped Intake entirely (no company research, no Q&A questions generated), the letter-writer has no strategic properties (Role emphasis, Keywords, Strategy) and no Q&A answers to draw from. It produces a letter based on the JD, your reference files, and general framing — valid, but generic. The letter won't reflect your specific angle on the role or the company-specific research the coach produces. Running Intake before New Application is strongly recommended for any role you genuinely want.

If Intake ran but you didn't answer the Q&A questions in the Notion page body, the letter-writer proceeds without your specific angle for that role. It uses the coach's Strategy field and your reference files, which produces a reasonable letter but one that won't capture what drew you to this specific opportunity. Filling in the Q&A and Page Body fields before running New Application produces noticeably better letters.

To skip the cover letter entirely for a run, say "no letter" in your chat command when triggering New Application.

### Step 6 — DOCX export

The orchestrator runs pandoc to convert the CV and cover letter markdown to DOCX using the `.dotx` reference templates. `update-subtitle.py` updates the role-specific subtitle in the CV header. Both files are copied from `/tmp` to the output folder and verified as nonzero.

If the role's `Languages` property includes `Hebrew`, the Hebrew localization agent runs after the English export and produces two additional DOCX files in the same company subdirectory. *(Alpha — RTL configuration requires manual Word setup; full documentation coming.)*

### Steps 7a–7d — Writeback and logging

After export, the orchestrator:

- Posts the file paths to `Link to CV` in Notion
- Writes coach-owned properties, hiring manager details, and `Last Pipeline Run` to the Notion row
- Updates Status to `CV Ready for Review`
- Writes a reviewer feedback file (`feedback-<role>-<company>-<mon>.md`) containing verbatim output from all four reviewer passes
- Appends the role record to `state.json`

### Steps 8–9b — Post-run processing

After all roles complete:

- **LinkedIn updates** — aggregates Keywords from all coach outputs, counts cross-role frequency, and writes a `linkedin-updates-<date>.md` file with high-signal (3+ roles) and medium-signal (2 roles) terms alongside extracted summary phrases
- **Revision log** — writes a run-level revision log with cross-run decisions and any technical issues encountered
- **Q&A promotion** — promotes new Q&A answers from this run into `02-professional-background.md` so the letter-writer never asks the same question twice
- **Bullet approval prompt** — asks which companies from this run you want to lock bullets for (see [How approved bullets work](#how-approved-bullets-work))

### Final delivery

The orchestrator delivers a single summary in chat covering any validation issues, cross-run decisions, and technical failures. If nothing needs reporting, the summary is one line: "All N roles completed."

---

## Pipelines and modes

The plugin has three pipelines, each serving a distinct phase of the job search. Which one runs depends on how you trigger it and what Status the roles carry in your job tracking database.

### Intake

The Intake pipeline runs market intelligence on roles you're researching but haven't committed to applying for. It operates on roles with Status = `Hold`, researches each company (competitive landscape, funding, hiring manager, culture signals), writes coach properties to your database, generates Q&A intake questions for each role, and updates Status to `Researched`. No CVs are produced.

**Intake is a mandatory prerequisite for New Application.** The letter-writer needs two inputs that only exist after Intake runs: the strategic properties the coach writes (Role emphasis, Keywords, Strategy, Gap handling) and the Q&A answers you provide in the page body after Intake generates the questions. Without these, the letter-writer falls back to generic framing.

Trigger Intake with the coach command or natural language:

```
Research my Hold roles.
Run market intelligence.
```

### New Application

The New Application pipeline produces tailored CVs and cover letters. It runs against roles with Status = `Interested`, processes up to five per run in priority order, and writes results back to your database when each role completes. To skip the cover letter for a specific run, say "no letter" in your chat command.

The `--now` flag runs the pipeline against a single role without a job tracking database. Pass a URL or paste a JD directly. No database writeback occurs.

```
/career-engine --now https://jobs.example.com/head-of-marketing
```

### Application Edit

The Application Edit pipeline improves existing outputs for roles you've flagged for revision. It never starts from scratch — it reads the existing CV text, cover letter text, and coach properties from the database row, runs the employment coach to verify and update its strategic properties, then routes the role through the appropriate writing agents to improve what's there.

Trigger it with the `--edit` flag or by saying "edit my CVs" in chat. The pipeline processes all roles with Status = `Needs editing`.

```
/career-engine --edit
```

### Status and pipeline routing

Status determines which pipeline processes a role and encodes where it sits in the sequence. The full lifecycle runs Hold → Researched → Interested → CV Ready for Review → Applied.

| Status | Set by | Processed by | What happens |
|---|---|---|---|
| `Hold` | You | Intake | Company research; Q&A questions generated; coach properties written; Status → `Researched` |
| `Researched` | Intake | — | Awaiting your Q&A answers and decision to apply |
| `Interested` | You | New Application | Full CV + cover letter pipeline; Status → `CV Ready for Review` |
| `CV Ready for Review` | New Application | — | Awaiting your review of the output |
| `Needs editing` | You | Application Edit | Existing outputs improved; Status → `CV Ready for Review` |
| `Applied` | You | — | Complete |

---

## Job tracking database

The job tracking database is the input and output surface for every batch run. The pipeline reads roles from it, writes strategic properties back to it, and posts file paths to it after each role completes.

### Status values and transitions

Status drives what the pipeline does with a role. The values and their meanings are fixed — do not use custom values.

| Status | Meaning | Set by |
|---|---|---|
| `Hold` | Being researched; not yet ready to apply | You |
| `Interested` | Ready to apply; queued for the CV pipeline | You |
| `CV Ready for Review` | Pipeline completed; review your documents | Pipeline |
| `Applied` | Application sent | You |
| `Researched` | Market intelligence run complete | Coach-skills pipeline |
| `Needs editing` | Documents need revision | You |

### Required properties

The following properties must exist with these exact names. The pipeline writes to them by name — renaming any column breaks the integration without an error. **Onboarding (`/career-engine:setup --phase 5`) configures your database connection and guides you through setting these up**, including providing the Notion template and the column schema for Google Sheets.

You can add as many additional custom properties as you want — for your own notes, tracking, or workflow purposes. The pipeline ignores columns it doesn't recognize. The only constraint is that the required properties below must be present and not renamed.

| Property | Type | Set by | Purpose |
|---|---|---|---|
| `Company` | Title/text | You | Company name |
| `Position` | Text | You | Role title |
| `Job URL` | URL | You | The job posting URL |
| `Status` | Select | You + Pipeline | Controls pipeline behavior (see above) |
| `Priority` | Select | You / Coach | Processing order. Values: `Highest`, `First`, `Second`, `Third`, `Fourth`, `Fifth` |
| `JD Body` | Text | Coach | Full JD text; populated by the coach on first fetch |
| `Q&A` | Text | Letter-writer | Interview questions generated for this role |
| `Page Body` | Text | You | Your notes and intake answers for this role; the letter-writer reads this before drafting |
| `Role emphasis` | Text | Coach | 1–2 sentences on the real mandate beneath the job title |
| `JD proof` | Text | Coach | Verbatim JD quote supporting Role emphasis; for your verification only — no writing agent reads this |
| `Keywords` | Text | Coach | 8–15 tiered JD terms: `Critical: ... \| Important: ... \| Nice-to-have: ...` |
| `Strategy` | Text | Coach | Lead proof point + secondary evidence + 2–3 sentence framing direction |
| `Role Type` | Multi-select | Coach | CV structure driver. Values: `Builder`, `Scaler`, `Specialist`, `Leader` |
| `Relationship type` | Select | Coach | Engagement framing. Values: `Full time`, `Part time`, `Temporary`, `Fractional/Consulting/Freelance` |
| `Gap handling` | Text | Coach (you may override) | One line per gap: how to handle it. You can edit this before triggering the CV pipeline — your version takes precedence. |
| `Role summary` | Text | Coach | 2-sentence role fit summary plus culture signal |
| `Hiring Manager's Name` | Text | Coach | Hiring manager name and title |
| `Hiring manager's role` | Text | Coach | HM title + what their org position implies for your seniority and accountability |
| `Manager role confirmed` | Select | Coach | `Yes` = confirmed. `No; this is only a hypothesis` = inferred. |
| `Person who Advertised Role (if not Hiring Manager)` | Text | Coach | Name and title of the person who posted the role |
| `No incumbents in this function` | Select | Coach | `No incumbent in this function` or `Function is already staffed`. Drives Builder vs. Scaler framing. |
| `Landscape` | Text | Coach-skills | Competitive landscape from research run |
| `Last Pipeline Run` | Date | Orchestrator | ISO date of most recent completed run |
| `Link to CV` | Text | Orchestrator | Local file paths posted after the run |
| `Draft Directory` | URL | Orchestrator | Link to the output folder directory |
| `CV File Name` | Text | Orchestrator | CV filename for this role |
| `Letter File Name` | Text | Orchestrator | Cover letter filename for this role |
| `Languages` | Multi-select | You | Output languages. Values: `English`, `Hebrew` |
| `Note` | Text | You | Your personal notes. Agents do not write here. |

### Property write discipline

Each property has exactly one authoritative writer. Agents do not write to each other's properties, and they do not write the same information twice in different fields.

The employment coach owns `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, and `Gap handling`. These are set once and not overwritten by other agents.

`JD proof` is a transparency field only. Its purpose is to let you verify that the coach's Role emphasis interpretation matches what the JD actually says. No writing agent reads it or uses it as input.

The `Note` field belongs to you. Agents must **never** write to this field to summarize, repeat, or rephrase content already captured in a structured property — that is a hard violation of property write discipline, not a judgment call.

---

## Output files

All files from a run land in a campaign folder named by date: `<output_folder>/applications-<YYYY-MM-DD>/`. Each role gets its own subdirectory named after the company in kebab-case.

`<output_folder>` is the path you configure during onboarding (`/career-engine:setup --phase 5`). It can be any local directory — iCloud, Dropbox, a standard folder, or anything else your filesystem allows. The placeholder `{{OUTPUT_FOLDER}}` in plugin files is replaced with your actual path during setup.

### File naming conventions

Files use a consistent slug format: `<roletitle>-<company>-<monYYYY>`. Role title and company are lowercased and hyphenated.

| File type | Name pattern |
|---|---|
| CV | `cv-<lastname>-<slug>.docx` |
| Cover letter | `coverletter-<lastname>-<slug>.docx` |
| Hebrew CV | `he-cv-<lastname>-<slug>.docx` |
| Hebrew cover letter | `he-coverletter-<lastname>-<slug>.docx` |
| Reviewer feedback | `feedback-<slug>.md` |
| Revision log (per role) | `revision-log-<slug>.md` |
| Revision log (per run) | `revision-log-<YYYY-MM-DD>.md` |
| LinkedIn updates | `linkedin-updates-<YYYY-MM-DD>.md` |
| State file | `state.json` |

**Example:** A Head of Marketing role at Acme in April 2026 produces:
- `cv-smith-head-of-marketing-acme-apr2026.docx`
- `coverletter-smith-head-of-marketing-acme-apr2026.docx`
- `feedback-head-of-marketing-acme-apr2026.md`

### What each file contains

**Reviewer feedback file** (`feedback-<slug>.md`) — verbatim output from all four reviewer passes in sequence: recruiter CV review, hiring manager CV review, recruiter cover letter review, hiring manager cover letter review. This is the primary file to read after a run.

**Revision log (per role)** — what the cv-writer and letter-writer changed between draft and final, including gatekeeper violations caught and resolved.

**Revision log (per run)** — cross-run decisions, orchestration issues, and any roles that failed or were dropped.

**LinkedIn updates file** — high-frequency keywords across all roles processed in the run, with extracted summary phrases. Use this to refresh your LinkedIn headline and About section after a batch run.

**State file** (`state.json`) — machine-readable record of every role processed, including file paths, Notion page IDs, verdicts, and coach properties. Used by `--status` and crash recovery.

---

## How approved bullets work

When you first run the pipeline, there are no approved bullets — just raw role facts from your setup. The pipeline writes fresh bullets for each CV based on the job description and your documented background. After each run, the pipeline asks which companies you want to lock. Locked bullets are reused verbatim in future CVs for the same company, which is where consistency and quality compound.

The first run is rarely final. The system is designed to iterate. Review the output, flag what needs changing with `--edit`, run again. After a pass or two on a company, the bullets sharpen — then you lock them.

**What setup does and does not do:** Setup extracts raw facts from your CV (company, dates, metrics, scope) but does not treat old CV language as approved bullets. Your existing bullet phrasing is starting material, not finished product. Approved bullets are ones the pipeline wrote and you explicitly locked.

### The approval prompt

At the end of every run, the orchestrator asks:

> "New bullets were written for: Company A, Company B. Which should I add to your approved list? Reply with company names, 'all', or 'none'."

When you approve a company, the bullets from that run are written into `02-professional-background.md` under that company's role entry. Future runs for the same company start from those bullets rather than generating from scratch.

---

## Agents and skills

### Commands

The plugin has two groups of commands: pipeline commands that run against your job tracking database, and standalone skills that operate independently of any active job search.

**Pipeline commands** — these run the multi-agent campaign and require Notion (or CSV) to be configured.

| Command | Behavior |
|---|---|
| `/career-engine` | Full campaign against Interested roles |
| `/career-engine --edit` | Editing pipeline for Needs editing roles |
| `/career-engine --now <url>` | Single role, no Notion |
| `/career-engine --coach <question>` | Direct coaching, conversational |
| `/career-engine --check` | Gatekeeper pass on pasted content |
| `/career-engine --review` | Recruiter + HM review on pasted content |
| `/career-engine --write-letter` | Cover letter only, no pipeline |
| `/career-engine --status` | Read state.json, no agents |

**Standalone skills** — these run independently. No job tracking database required.

| Command | Behavior |
|---|---|
| `/career-engine:source-open-roles` | Multi-source role sourcing across LinkedIn, remote boards, startup boards, and general job boards. Scores results against your saved preferences, deduplicates against your Notion pipeline, and surfaces hiring manager signals. Six modes: `quick` (LinkedIn only), `remote`, `startup`, `broad`, `ai`, `full`. Optional time range override. Requires LinkedIn MCP for LinkedIn searches. |
| `/career-engine:personal-brand` | Build or refresh your positioning using the Why You / Why Them / Why Now framework; produces a positioning statement, audience and channel map, content pillars, and bio library. |
| `/career-engine:linkedin-coach` | LinkedIn profile audit, content review, content strategy, headline optimization, and video introduction scripting — five modes to choose from. |

### Agents

Eight agents handle all reasoning and writing. The orchestrator spawns them as subagents — they return text only and do not write files directly.

**employment-coach** — The pipeline's research and prioritization engine. Fetches JDs, researches companies (including LinkedIn company profiles, hiring manager profiles, and team composition when the LinkedIn MCP is connected), assigns priorities, and writes strategic properties using a red/green flag methodology that weights GTM fit, funding trajectory, and team signals. Two modes: Pipeline (full analysis + Notion writeback) and Direct coaching (conversational, no writeback). Sole owner of Role emphasis, JD proof, Keywords, Strategy, Role Type, Relationship type, and Gap handling.

**cv-writer** — Writes and revises CVs. Two options: Draft and Revision. CV structure is driven by Role Type. The fabrication rule is absolute — claims that can't be grounded in documented experience are left out, not invented.

**letter-writer** — Writes and revises cover letters and generates Q&A interview questions during the research pipeline. Receives page body content, Q&A answers, Strategy, and Gap handling from the orchestrator. Voice and structure rules in `skills/cover-letter/SKILL.md` hold regardless of reviewer feedback.

**recruiter-reviewer** — Reviews CVs and cover letters as a senior recruiter in the Israeli tech and global startup market. Returns tiered feedback (Tier 1/2/3). Flags everything accurately; cv-writer and letter-writer address what they can through reframing.

**hiring-manager-reviewer** — Reviews CVs and cover letters as the hiring manager. CV review returns a verdict (Yes / Conditional / No) with specific feedback. Cover letter review answers three questions: does it address the HM's condition, does it add something the CV doesn't, does it increase interview likelihood.

**gatekeeper** — Quality gate for both CVs and cover letters. CV option checks ATS compliance (keyword coverage thresholds and section headings) plus 13 content rules. Cover letter option checks 13 voice and structure rules. Returns PASS or a specific violation list. Loops silently with the writing agent until PASS. Does not rewrite; only checks.

**localization** *(Alpha)* — Produces native Israeli professional Hebrew versions of the CV and cover letter. Runs after the English DOCX export when the role's Languages property includes Hebrew. Localization follows the Israeli tech professional register — hybrid Hebrew-English, direct, not formal. RTL layout requires manual Word setup; full configuration instructions coming.

**pmm-positioning-expert** — Analyzes competitive positioning for a company during standalone research runs. Does not run in the main campaign pipeline.

### Skills

Skills contain the detailed procedures each agent follows. They are loaded by the orchestrator before processing begins.

| Skill | Loaded by | Purpose |
|---|---|---|
| `applications-orchestrator` | Orchestrator | Full campaign coordination, Steps 0–9b |
| `application-intake` | Orchestrator | Steps 0–0.9: Notion fetch, coach invocation, queue building |
| `new-application-steps` | Orchestrator | Steps 1–7d: per-role CV and cover letter pipeline |
| `application-files-export` | Orchestrator | DOCX conversion commands, file naming, copy protocol |
| `application-edit` | Orchestrator | Editing pipeline for Needs editing roles |
| `coach` | Coach command | Standalone research pipeline for Hold roles |
| `cover-letter` | letter-writer | Voice rules, structure, use-case patterns, revision pass |
| `cv-writing` | cv-writer | Bullet formula, ATS rules, forbidden phrases |
| `gatekeeper-checks` | gatekeeper | Full checklist for both CV and cover letter options |
| `employment-coach` | employment-coach | Research procedure, priority scoring, strategic property definitions, LinkedIn research protocol, red/green flag methodology |
| `career-engine-setup` | Setup command | Onboarding phases 1–6 |
| `source-open-roles` | `career-engine:source-open-roles` command | Multi-source role sourcing, search modes, site catalog, scoring rubric, deduplication rules |
| `personal-brand` | `career-engine:personal-brand` command | Why You / Why Them / Why Now positioning, bio library, content pillars |
| `linkedin-coach` | `career-engine:linkedin-coach` command | Profile audit, content review, content strategy, headline optimization |

---

## Configuration

### Permissions

The pipeline runs bash commands and MCP tool calls throughout. Without pre-approved permissions, Claude Code pauses for approval at each one. Add the following block to your `~/.claude/settings.json` under the `permissions` key:

```json
"permissions": {
  "allow": [
    "Bash(pandoc:*)",
    "Bash(python3:*)",
    "Bash(cp:*)",
    "Bash(ls:*)",
    "Bash(mkdir:*)",
    "Bash(cat:*)",
    "mcp__<notion-tool-id>__*",
    "mcp__<desktop-commander-id>__*",
    "WebFetch(*)",
    "WebSearch(*)"
  ]
}
```

Replace `<notion-tool-id>` and `<desktop-commander-id>` with the actual IDs from your Claude Code MCP configuration. The setup agent generates this block with your specific IDs — run `/career-engine:setup --phase 6` to get it.

If a `permissions` block already exists in your settings, merge the `allow` arrays rather than replacing them.

### CV template and output format

The pipeline always produces two outputs per role: a markdown file and (if pandoc is installed) a DOCX file. The markdown is the canonical output — the DOCX is a formatted version of it.

**DOCX export (default, requires pandoc)**

The plugin ships with `references/cv-template-default.dotx`, a Word template with custom styles for pandoc DOCX export. The template controls fonts, heading sizes, color scheme, and the header layout. Microsoft Word is not required to use the DOCX — any application that opens `.docx` files works, including LibreOffice (free) and Google Docs.

To use your own template instead, provide the path during setup (`/career-engine:setup --phase 5`). Your template must define the same custom style names — see `skills/application-files-export/SKILL.md` for the full style reference.

**Markdown output (no dependencies)**

If you don't install pandoc, the pipeline still produces a complete markdown file for every CV and cover letter. You can:
- Paste it directly into Google Docs and apply your own formatting
- Post it as a Notion page using the Notion MCP
- Open it in any text editor or markdown viewer

The markdown files are saved to your output folder alongside the DOCX files (or instead of them if pandoc isn't installed).

**Output folder**

The output folder is configured during onboarding — it is not assumed to be iCloud. Any local path works: an iCloud folder, Dropbox, a standard local directory, or anywhere your filesystem allows. Configure it during setup (`/career-engine:setup --phase 5`) or update it at any time by re-running that phase.

### Token usage tracking

The pipeline tracks token consumption per run. After a few runs you'll have enough data to understand what a single CV costs vs. a full five-role batch, and what the editing pipeline costs compared to starting from scratch.

**How it works**

At the end of every run, the orchestrator writes a `run-metrics-<date>.json` file to your output folder. It records: pipeline type, roles processed, and invocation counts for every agent type. A Stop hook — configured separately — captures the actual token counts from the Claude Code session and writes them into the same file when the session closes.

**Enabling the Stop hook**

Add the following `hooks` block to your `~/.claude/settings.json` alongside the `permissions` block:

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

Replace `${CLAUDE_PLUGIN_ROOT}` with the actual installation path shown in your Claude Code plugin settings.

**Reading the output**

After each run, check `run-metrics-<date>.json` in your output folder. The file includes:
- `pipeline` — Standard, Edit, or Intake
- `roles_processed` — company names, track type, whether Hebrew was produced
- `agents_invoked` — counts per agent (employment_coach, cv_writer_draft, gatekeeper_cv, etc.)
- `token_counts` — input tokens, output tokens, cache read tokens, cost in USD (written by the Stop hook)

Without the hook, `token_counts` stays as `"pending"` and the structural metrics are still recorded.

### Delivered letters

The `references/delivered-letters/` folder contains cover letters you've sent and confirmed represent your voice well. The letter-writer reads 2–3 domain-similar letters from this folder before drafting, extracting sentence patterns, vocabulary level, and paragraph structure to calibrate its output.

Add letters to this folder any time by saving them as `.md` files using the naming convention: `coverletter-<lastname>-<roletitle>-<company>-<monYYYY>.md`. The more letters you accumulate here, the more precisely the letter-writer matches your voice.

---

## Troubleshooting

This section covers the most common failures and how to resolve them.

### Pipeline stops mid-run with an approval prompt

The permissions block in `~/.claude/settings.json` is incomplete or missing. Run `/career-engine:setup --phase 6` to regenerate the exact block for your configuration, then add it to your settings.

### "Output path not found" error

The output folder path configured during setup doesn't exist or isn't accessible. Verify the path exists by running `ls` against it in your terminal. If you've moved the folder or want to change your output location, re-run setup phase 5: `/career-engine:setup --phase 5`.

### DOCX files are unstyled (no formatting)

pandoc either isn't installed or can't find the `.dotx` template. Verify pandoc is installed with `pandoc --version`. If the command isn't found, run `brew install pandoc`. If pandoc is installed but the DOCX is still unstyled, check that the `{{CV_TEMPLATE_FILE}}` placeholder was replaced during setup with the actual template path.

### "python-docx not found" or subtitle update fails

The subtitle update script requires python-docx. Install it with `pip3 install python-docx`. The subtitle update failure is non-blocking — the CV DOCX is still produced, but the role-specific subtitle in the header won't be updated for that run.

### Coach drops a role silently

The employment coach drops roles whose JD isn't accessible. Common causes: the posting is behind a login wall, the URL has expired, or the job board blocks automated fetching. The dropped role appears in the run-level revision log. To process it manually, paste the JD text into the Notion row's `JD Body` field, set Status back to `Interested`, and re-run.

### Notion properties aren't updating

The Notion MCP connection may have expired or the database ID is wrong. Verify the Notion MCP is connected in your Claude Code settings and the database ID in your configuration matches your actual Notion database. Re-run `/career-engine:setup --phase 5` if you need to reconfigure the connection.

### "Gatekeeper loop exceeded" or run stalls in a loop

The gatekeeper loops with the writing agent until all checks pass. If a loop exceeds its limit, it typically means a check is failing that the writing agent can't resolve within the fabrication constraints — usually because the JD requires experience that isn't documented in your reference files. Check the gatekeeper violation output in chat, and add the relevant experience to `02-professional-background.md` if it's genuinely there.

### Cover letter doesn't sound like me

The letter-writer draws voice from two sources: your Q&A page body in Notion and the delivered letters in `references/delivered-letters/`. If neither is populated, it falls back to general voice calibration from `03-framework.md`, which produces more generic output. Add your best past letters to `references/delivered-letters/` and answer the Q&A questions in Notion before re-running.

### State.json is missing after a run

The run either crashed before completing or the state file write failed. Run `/career-engine --status` — if no state file is found, it will report that. Check the iCloud output folder directly for the campaign date folder. Partial runs can be resumed by setting the affected role's Status back to `Interested` and re-running.

---

## Roadmap

### Confirmed features — better documentation coming

**Crash recovery and run resumption.** The New Application pipeline writes `state.json` to the output folder after every role completes. If a run crashes or is interrupted, set the affected role's Status back to `Interested` and re-run — the pipeline picks up from where it left off. You can inspect the state file at any time with `/career-engine --status`.

**CV type handling.** The pipeline handles different CV types (specialist, senior, founding hire, leadership, etc.) through the Role Type system. The employment coach assigns a Role Type to every role — `Builder`, `Scaler`, `Specialist`, or `Leader` — and the cv-writer uses it to determine the CV's structure, what sections to include, and how to frame bullets. You don't need to specify a CV type manually. Full Role Type documentation in the job tracking database section.

**Onboarding pause and resume.** The onboarding interview can be paused and continued in a later session. Run `/career-engine:setup --phase 4` to resume the framework interview. The `[DRAFT]` and `[REVIEW]` markers in `03-framework.md` track what's been confirmed and what still needs work.

### Documentation coming

**Word template details.** The included `cv-template-default.dotx` contains the custom styles the pipeline uses for DOCX export, and the header section where your personal details live. Full documentation of all styles, macros, and configuration options — including why Word produces better output than Google Docs for this use case — is in progress.

**RTL and Hebrew setup.** *(Alpha)* Hebrew localization is live but right-to-left layout in Word requires manual configuration. Instructions for RTL setup, font configuration, and Word document direction settings are coming. Until then, ask the pipeline agent to walk you through the steps.

**Hebrew enrichment.** *(Alpha)* The Hebrew localization agent currently produces a functional native Hebrew register. Richer localization options — including more cultural calibration, additional term handling, and cover letter adaptation — are in progress.

### Planned features

**Deeper research on the hiring side.** The employment coach already identifies the hiring manager and researches the company. Future iterations would go further: tracking relationships and connections at the target company, surfacing relevant mutual contacts, monitoring for new hires or departures on the team, and improving the quality of company intelligence over time as more context accumulates per employer.

**Job search assistance.** Expanding upstream from the application itself: surfacing relevant roles based on your profile and target criteria, tracking application status and follow-up timing, and building a searchable record of every company researched and every role applied for across multiple job search campaigns.

If any of these directions is relevant to work you want to contribute, open an issue.

---

## Support this project

If career-engine has been useful, you can support its development here:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A1L720MCOG)
