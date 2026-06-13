# career-engine

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A1L720MCOG)

A multi-agent pipeline for Claude Code that turns your target roles into tailored, reviewed, fabrication-checked CVs and cover letters. It reads roles from your job tracker, researches each company, drafts and reviews each document through a sequence of specialized agents, exports formatted Word files, and writes results back to your tracker. A full batch runs without supervision.

**[⬇ Download career-engine.plugin](https://github.com/spinningrachel/career-engine/raw/main/career-engine.plugin)** — install it in [Claude Code](https://claude.com/claude-code) or [Cowork](https://cowork.anthropic.com), then run `/career-engine:setup`. Setup authors a separate `career-data` skill that holds your background and preferences, and you install it through the app. The plugin ships with no personal data; your data lives in `career-data`.

> **⚠ Under construction — experiment at your own risk.**
> This plugin is in active development and not yet stable. Expect rough edges, incomplete features, and breaking changes between versions. Your personal data lives in the `career-data` skill, outside the plugin, so plugin updates never touch it. Setup also writes a backup export of `career-data` to your output folder.

---

## What it solves

Job searching at scale breaks down in three predictable ways. Tailoring a single application takes hours. Every session starts from zero, because nothing learned in one application carries into the next. And most generative-AI tools make the problem worse instead of better, because they write confidently about experience you do not have.

career-engine addresses all three. It produces tailored documents in batch, it accumulates everything it learns into reference files that every agent reads, and one rule runs through every agent: nothing goes on the page that cannot be traced to your documented background. Reviewer pressure never overrides that rule.

Your work shifts to three moments: deciding which roles to pursue, writing a short personal motivation for each one, and reviewing finished documents.

## What makes it different

Most job-search tools hand you one agent and a template. A few things work differently here.

- **A multi-agent review loop.** A CV passes through the employment coach, cv-writer, gatekeeper, recruiter reviewer, and hiring-manager reviewer before anything is delivered. Cover letters add a dedicated voice-calibration and AI-pattern pass on top.
- **Research before writing.** The employment coach studies each company, identifies the hiring manager, scores your role queue, and writes strategic framing before a single bullet is drafted.
- **A fabrication guard that cannot be argued down.** Claims that cannot be traced to your reference files are left off the page, not invented. Reviewer feedback cannot force an unsupported claim onto a document.
- **Failure isolation and crash recovery.** A failed role is logged and skipped; the batch continues. State is written to disk after every role, so an interrupted run resumes without redoing finished work.
- **Compounding quality.** Approved bullets, sent letters, and promoted motivation content build up in your reference files. The longer you run it, the less it invents and the more it knows.
- **Notion integration, with alternatives.** It reads your pipeline from Notion and writes file paths and strategic properties back to each row. CSV and Google Sheets work as read-only sources.
- **Second-language localization** *(alpha)*. Native-register CVs and cover letters in a configurable second language as a pipeline step. Hebrew is the maintainer's instance and the worked example throughout this README. RTL layout still needs manual Word setup; fuller documentation is coming.

Built and maintained by [Rachel Cheyfitz](https://www.linkedin.com/in/rachelcheyfitz). Open-sourced so other job seekers can run the same pipeline with their own background, voice, and job tracker.

---

## Contents

1. [How it works](#how-it-works)
2. [The core loop](#the-core-loop)
3. [Prerequisites](#prerequisites)
4. [Onboarding](#onboarding)
5. [Where your data lives](#where-your-data-lives)
6. [Keeping references current](#keeping-references-current)
7. [The role lifecycle](#the-role-lifecycle)
8. [Running the pipeline](#running-the-pipeline)
9. [Pipelines and modes](#pipelines-and-modes)
10. [Inside a New Application run](#inside-a-new-application-run)
11. [How cover letters get your voice](#how-cover-letters-get-your-voice)
12. [Job tracker database](#job-tracker-database)
13. [Output files](#output-files)
14. [How approved bullets work](#how-approved-bullets-work)
15. [Agents and skills](#agents-and-skills)
16. [Configuration](#configuration)
17. [Troubleshooting](#troubleshooting)
18. [How it is built](#how-it-is-built)
19. [Roadmap](#roadmap)
20. [License and support](#license-and-support)

---

## How it works

The plugin has two layers. One is a set of agents that do the writing and reviewing. The other is a set of reference files that every agent reads before it writes anything.

The agents are fixed. They ship with the plugin and do not change between your runs. The reference files are yours. They live in a separate skill named `career-data` that you install once, outside the plugin. The plugin itself ships only blank `{{...}}` templates, which serve as the starting point for a brand-new user; setup fills your real data into `career-data` instead. Plugin upgrades never touch `career-data`. See [Where your data lives](#where-your-data-lives).

Everything the system knows lives in three places: your job tracker (Notion or a spreadsheet), your output folder on disk, and your `career-data` skill. There is no server, no separate database, and no background process.

The reference files in `career-data` are the source of trust. Three of them govern every document the system produces:

- **`01-writing-rules.md`** holds the rules that constrain every agent: fabrication guards, attribution rules (which outcomes are yours versus the company's), framing constraints, job-description term mappings, and your contact details. Every agent reads this first.
- **`02-professional-background.md`** holds your career content: role facts, approved CV bullets, approved summaries, testimonials, portfolio, and a motivation bank that grows on its own as you run the pipeline.
- **`03-framework.md`** holds your positioning: professional category, voice samples, value pillars, methodology, domain depth, target audience, and messaging. This is what makes the letters sound like you rather than a generic candidate.

[Where your data lives](#where-your-data-lives) covers the `career-data` skill and each file in full.

## The core loop

Three pipelines run in sequence on roles already in your tracker. This is the path most of your work follows.

1. Add a role to your tracker with Status `Hold`.
2. Run **Intake**. The employment coach researches the company and writes strategic properties to the row. Status becomes `Researched`.
3. Read the research. Fill in the **Why I Want This Role** field: what specifically caught your attention, plus anything you want in the letter that is not already in your CV. Change Status to `Interested`.
4. Run **New Application**. The pipeline queues up to five `Interested` roles, runs the full CV and cover letter pipeline on each, exports the files, and writes everything back. Status becomes `CV Ready for Review`.
5. Review the documents and the feedback file. Either apply, or set Status to `Needs editing` (with an Edit type) and run the **Edit** pipeline.

The full lifecycle and every status transition are in [The role lifecycle](#the-role-lifecycle).

---

## Prerequisites

The following tools and services must be in place before the pipeline runs at full capability.

### CLI tools (required only for DOCX export)

The pipeline always produces markdown. DOCX output is an optional formatting step on top of it.

| Tool | Install command | Purpose |
|---|---|---|
| pandoc | `brew install pandoc` | Converts CV and cover letter markdown to DOCX |
| python-docx | `pip3 install python-docx` | Writes the role-specific subtitle into the CV header |

Neither tool is required to get usable output. Without pandoc, the pipeline still writes a complete markdown file for every CV and cover letter, ready to paste into Google Docs, post to Notion, or open in any editor. See [CV template and output format](#cv-template-and-output-format) for the alternatives.

The setup agent can install pandoc for you. During onboarding, tell it you want help with the installation and it runs `brew install pandoc` on macOS, or finds the correct command for Linux or Windows.

### MCP servers (connect in Claude Code before running setup)

Connect these servers in Claude Code before you run setup. Only the first two are needed for the core batch flow; the rest extend research and sourcing.

| Server | Required | Purpose |
|---|---|---|
| Notion | Yes, for Notion tracking | Reads roles and writes results back |
| A host filesystem MCP (such as Desktop Commander) | Yes | File operations on your output folder, and host-side pandoc in sandboxed environments |
| Provider-specific job-board MCPs (Indeed, Dice, ZipRecruiter, and similar) | Optional, provider-specific | Job-description fetching and search; the coach uses any that are connected to research roles. No bundled install; connect the ones you use |
| LinkedIn (`linkedin-mcp`) | Optional | Company profiles, hiring-manager research, team mapping; also required for `source-open-roles` and `linkedin-coach`. Full setup in the subsection below |

### LinkedIn MCP setup

The LinkedIn MCP is the `stickerdaniel/linkedin-mcp-server` project, installed via its published `linkedin-scraper-mcp` uvx package and configured under the server key `linkedin-mcp`. It drives a real logged-in browser session in the background while agents run. Two consequences follow from that.

First, do not use your browser during any run that touches LinkedIn tools (employment-coach with full research, source-open-roles, linkedin-coach). Concurrent sessions can trigger LinkedIn security checks, log you out, or break tool calls. Leave the machine alone for the duration of those runs.

Second, do not open LinkedIn in a browser tab while the server is active, even if the run is idle. Manual navigation shares the same session and can interfere mid-run.

Install the `linkedin-scraper-mcp` package with `uv`. Install `uv` first if you do not have it:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Run the first-time login. This opens a browser window for you to sign in:

```bash
uvx linkedin-scraper-mcp@latest --login
```

Add the server to your `~/.mcp.json` under `mcpServers`, keyed as `linkedin-mcp`:

```json
"linkedin-mcp": {
  "command": "uvx",
  "args": ["linkedin-scraper-mcp@latest"],
  "env": { "UV_HTTP_TIMEOUT": "300" }
}
```

The server key must be exactly `linkedin-mcp`, even though the underlying package is `linkedin-scraper-mcp`. The plugin's tool declarations depend on that key. After adding it, restart Claude Code and confirm the tools appear before running any LinkedIn-dependent pipeline.

---

## Onboarding

Onboarding is a one-time process that builds your `career-data` skill from materials you already have. It authors your three reference files and the rest of your data layer, then installs `career-data` through the app. Cowork users run this step in the Code tab. Run it after installing the plugin.

```
/career-engine:setup
```

Setup runs seven phases.

1. **Identity.** Your name, email, phone, LinkedIn, location, citizenship, and language configuration. These values drive the CV header, output file names, and every agent instruction.
2. **Content submission.** You send your existing career materials: CVs, cover letters, LinkedIn export, portfolio, old job descriptions. The agent reads everything and synthesizes it. Source files are not retained; only the synthesized output is kept. The one exception is sent cover letters: if you confirm a letter represents your voice, it is kept in `career-data/references/delivered-letters/` for voice calibration.
3. **Framework synthesis.** The agent drafts `03-framework.md` from your materials: positioning, voice, domain depth, methodology, value pillars, target audience.
4. **Framework review and interview.** The agent shares the draft for your review, then runs a targeted interview to fill gaps the materials left unclear and to probe for things you did not volunteer (testimonials, published work, community involvement, career-shift intent). This phase can be long; it can be paused and resumed.
5. **Integration.** You choose your job tracker (Notion, Google Sheets, or another tool), configure your output folder, your CV template, and your gap-handling preference.
6. **Permissions.** The agent generates the exact permissions block for your `~/.claude/settings.json`. Without it, Claude Code pauses for approval on every shell command mid-run.
7. **Job-preferences.** Sourcing, scoring, and coaching rules for the `source-open-roles` and coaching pipelines.

Phases 5 through 7 can be deferred. The pipeline runs with Phases 1 through 4 complete, though Notion integration is needed for the full batch flow.

To re-run a single phase later:

```
/career-engine:setup --phase 4
```

To check what is configured and what is missing, including the `career-data` skill's presence, version, and completeness:

```
/career-engine:setup --verify
```

### Job tracker options

The pipeline supports three configurations.

**Notion (recommended)** gives full integration. The coach reads job descriptions and writes strategic properties, and the orchestrator posts file paths back to each row after the run. To set up a Notion database, duplicate the template below. It ships every required column with the exact names and select values the pipeline expects.

**[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**

After duplicating, paste the 32-character database ID from your Notion URL when the setup agent asks for it. It is the 32-character hexadecimal string in the URL path, immediately before the `?v=` view parameter.

**Google Sheets** reads roles but does not support writeback; outputs go to your output folder only. During setup, the agent provides a CSV file with the required headers and a prompt for setting up dropdown validation on the select columns.

**Other platforms** receive the same CSV and an adaptation prompt.

Column names are part of the contract. The pipeline writes to them by exact name. Renaming a required column breaks the integration silently, with no error. You can add as many extra columns as you want for your own notes; the pipeline ignores columns it does not recognize.

---

## Where your data lives

Your personal data lives in a separate skill named `career-data`, which you install once and which sits outside the plugin. Setup authors it from your interview and submitted materials, and you install it through the app (Settings → Capabilities → Skills) as a `.skill`. Because `career-data` is a skill rather than part of the plugin, plugin upgrades and reinstalls never touch it.

`career-data` has these layers:

- **`references/`** holds the data files: your three core reference files (below), your delivered letters, your LinkedIn snapshot, your job and pipeline preferences, and your personal `.dotx` template.
- **A voice-and-identity layer** reserved for positioning and voice content.
- **A marker** at the root that stamps the version and records that the install is configured. The marker lives with the data, so a clean plugin reinstall leaves it intact and a full `career-data` wipe removes it together with the data.

A skill installed through the Desktop app is the single, shared copy across Chat, Cowork, and Code. Create and update it only through the Desktop app; never write to `~/.claude/skills/` directly from a CLI, which creates a divergent copy that the other surfaces never see. Sync is one-way, app to Code.

The three reference files below are the most important files in `career-data`. Every agent loads one or more of them before writing anything. Knowing what lives where explains why the pipeline produces what it produces.

### `01-writing-rules.md`

This file answers one question: how must agents behave when writing about you? It holds agent operating rules and your identity configuration.

The rules section is the load-bearing part. It contains:

- **Attribution rules** that separate your personal outcomes from company-level results. Company-wide ARR growth, for example, is not a personal claim.
- **Fabrication guards** that name specific claims that would be easy to make but are not accurate, so agents cannot overclaim scope or invent experience.
- **Framing rules** for specific scenarios: consulting scope, seniority step-downs, title mismatches.
- **Job-description term guardrails** that map differing terminology, so an agent does not flag documented experience as a gap because the posting uses a different word for it.

The identity section holds your contact details, education, and tools list. That is what populates the CV header and signature. When this file contradicts what an agent believes about your background, this file wins.

### `02-professional-background.md`

This file answers a different question: what have you actually done, and what language has been approved to describe it? It is your career content bank.

The role-facts section holds a per-company entry for each position: title, dates, reporting structure, team size, key metrics, what you built, and approved CV bullets. Approved bullets are ones the pipeline wrote and you explicitly locked. They are reused verbatim in future CVs. New bullets start empty and fill in as you run the pipeline. See [How approved bullets work](#how-approved-bullets-work).

The file also holds approved CV summaries by domain, testimonials, portfolio links, and the motivation bank. The motivation bank fills itself: after each run, durable content from your Why I Want This Role field is promoted here verbatim, so the letter-writer can reuse your real angles and phrasings in future applications.

### `03-framework.md`

This file answers the positioning question: how should you be presented, in what voice, and to which audience?

It holds your professional category and market context, voice samples quoted from how you talk about your work, your core positioning statement, value pillars with proof, methodology, domain depth by vertical, target opportunities, messaging by hiring persona, taglines, elevator pitches, differentiators, and anti-positioning rules. It also carries a quantitative voice fingerprint that the letter-writer and humanizer calibrate against.

The letter-writer and employment coach draw on this file for every cover letter opener and every strategic framing decision. The more complete and accurate it is, the more the output sounds like you. The plugin ships a blank template; setup builds your copy into `career-data`, and it stays a living document you can edit at any time.

---

## Keeping references current

The reference files are meant to evolve. Say "update my references" or just share a material (an updated CV, a new testimonial, a portfolio piece, a changed role fact), and the `update-refs` skill folds it in.

This includes your positioning. People grow and shift, and a plain statement in chat ("I'm now pursuing a career shift," "I started a new role") is enough to update `03-framework.md`, with the behavioral consequence named in the proposal, because the framework governs how every agent treats you. For bigger life changes, the skill offers the relevant onboarding questions instead of patching piecemeal.

The skill classifies each item against the reference map, proposes update, replace, or add operations with a before-and-after preview, and writes nothing without your approval. Ambiguous items and brand-new reference files trigger clarifying questions. A new file is created only after you have said what it is for, which agents should load it, and when, and it gets wired into the agents' loading tables in the same session. Approved bullets and validated summaries are protected; conflicts are surfaced, never silently overwritten.

### Updating without losing your data

Because your data lives in `career-data` and not in the plugin, upgrading or reinstalling the plugin never touches it. Updates to your personal data go through the app instead. In Chat, edit and repackage the `.skill`, then re-upload it through Settings → Capabilities → Skills, where it replaces the existing install. A Cowork run that produces durable updates stages them to your output folder and hands you a ready-to-paste prompt to run in Chat; the change travels as a file, never re-typed.

Hand this prompt to the agent to update your `career-data` and repackage it:

> I need to update my installed `career-data` skill and repackage it so I can reinstall it. I'm attaching my current skill package.
>
> Here's what I want changed:
> - **Edit:** "In the file [name], change/add/remove [exact text]."
> - **Replace:** "Replace [name] with the file I'm attaching." (attach it)
> - **Add:** "Add this new file to [folder]." (attach it)
>
> Before you package anything: show me exactly what changed and where; list every file going in and give the total **file** count; if any file that was in my skill is missing, **stop and ask me**; keep any binary files (like `.dotx`) byte-for-byte intact.
>
> Then give it back as an installable **`.skill`** with the `career-data/` folder at the root and `SKILL.md` inside, nothing flattened or dropped.

Then go to **Settings → Capabilities → Skills → upload**. It replaces the existing install; delete the old one if it duplicates. Attach the current package (or the files to change) at the start, drag files in as-is, and keep the verification lines, which are the safeguard against a dropped file shipping silently.

### Surviving a clean reinstall

Uninstalling and reinstalling the plugin keeps your `career-data` intact; the reinstalled plugin re-discovers it on the first run and proceeds. The only action that removes your data is uninstalling `career-data` itself. To make even that recoverable, setup and runs keep a backup export of `career-data` in your output folder, so a full wipe restores from your own folder rather than starting over.

---

## The role lifecycle

Status is the single property that drives what the pipeline does with a role. The values are fixed. Do not invent custom ones.

```
Hold ──(Intake: research + properties)──► Researched
Researched ──(you fill "Why I Want This Role", flip status)──► Interested
Interested ──(New Application: full pipeline)──► CV Ready for Review
CV Ready for Review ──(you review, decide)──► Applied            (terminal)
CV Ready for Review ──(you flag problems, set Edit type)──► Needs editing
Needs editing ──(Edit pipeline)──► CV Ready for Review
```

| Status | Meaning | Set by | Processed by |
|---|---|---|---|
| `Hold` | Being researched; not yet ready to apply | You | Intake |
| `Researched` | Research complete; awaiting your Why content and decision | Intake | — |
| `Interested` | Ready to apply; queued for the CV pipeline | You | New Application |
| `CV Ready for Review` | Pipeline finished; review your documents | Pipeline | — |
| `Needs editing` | Documents need revision | You | Edit |
| `Applied` | Application sent | You | — |

---

## Running the pipeline

The pipeline is triggered by natural language in Claude Code. The phrasings below are examples; reasonable variations work.

### Full batch

A batch run fetches every role with Status `Interested`, runs the coach on each, builds a priority queue, and produces a CV and cover letter per role. It handles up to five roles per run. With more than five `Interested` roles, run it again; the queue rebuilds from whatever remains.

```
Run the career engine.
Process my CV queue.
Run the pipeline.
Run the pipeline, no letters.
```

Add "no letter" to produce CVs without cover letters.

### Single role, no tracker

The `--now` mode skips the job tracker. Pass a URL or paste a job description. No writeback occurs; results go to your output folder only.

```
/career-engine --now https://jobs.example.com/head-of-marketing
I just found this role, write my CV: [paste JD]
```

### Market intelligence (research only)

Researches the companies behind your `Hold` roles and writes competitive intelligence back to your tracker. No CVs are produced. The canonical flag is `--coach-skills`; the natural-language phrasings below are equivalent.

```
/career-engine --coach-skills
Research my Hold roles.
Run market intelligence.
```

### Editing existing outputs

When a role has Status `Needs editing`, the Edit pipeline improves existing outputs instead of starting over.

```
Edit my CVs.
Process the Needs editing queue.
```

### Standalone coaching

Direct coaching runs conversationally and does not write to your tracker.

```
/career-engine --coach Should I apply to this role?
/career-engine --coach What's my strongest angle for Head of PMM at a Series B?
```

### Quality checks on pasted content

These run a single reviewer or gatekeeper pass on text you paste, for auditing a document you already have.

```
/career-engine --check [paste CV or cover letter + JD]
/career-engine --review [paste CV or cover letter + JD]
```

### Cover letter only

Writes a cover letter without the full pipeline.

```
/career-engine --write-letter [URL or paste JD]
```

### Status check

Reads `state.json` from the most recent run and reports which roles finished, which files were produced, and whether any step failed. No agents run.

```
/career-engine --status
```

---

## Pipelines and modes

The plugin runs ten pipelines and five one-pass utility modes. Which one runs depends on how you trigger it and what Status the roles carry. The pipeline you name is the routing authority: row metadata can inform a briefing note, but it never re-scopes a commanded run.

| Pipeline | Trigger | Needs first | Produces | Status flow |
|---|---|---|---|---|
| **Setup** | `/career-engine:setup` | nothing | a configured `career-data` skill, database, settings | — |
| **Sourcing** | "find open roles" | saved search preferences | ranked role list saved to a dated file | new rows enter as `Hold` |
| **Intake** | "run intake" | roles with Status `Hold` | coach research, strategic properties | `Hold` → `Researched` |
| **New Application** | the command, no flag | Intake has run; Why filled for letters | CV DOCX + cover letter DOCX + feedback file | `Interested` → `CV Ready for Review` |
| **Fast track** | `--now <url or JD>` | a JD; Why given in chat, else CV only | CV DOCX (+ letter if Why provided) | none; skips the tracker |
| **Edit** | "edit CVs" or `--edit` | Status `Needs editing`, Edit type set | revised DOCX files | `Needs editing` → `CV Ready for Review` |
| **Localization** | automatic when Languages includes the second language (Hebrew in the maintainer's instance) | finished English DOCX | translated CV + letter DOCX | — |
| **LinkedIn coach** | "review my LinkedIn" | nothing | profile audit, headline, content strategy, video script | — |
| **Personal brand** | "build my personal brand" | nothing | positioning, channel map, content pillars, bio library | — |
| **Update references** | "update my references" | a material to fold in | updated `career-data` reference files | none |

**One-pass utility modes** run without loops and write nothing to your tracker: `--coach` (talk through a role), `--check` (gatekeeper on pasted text), `--review` (recruiter and HM review on pasted text), `--write-letter` (standalone letter draft), `--status` (completion report from the last run).

**Update references** (`update-refs`) folds shared materials into your reference files through a classify, propose, approve, apply flow. It never writes without explicit approval.

### Intake is a prerequisite for New Application

Intake runs market intelligence on roles you are still considering. It works on `Hold` roles, researches each company, writes coach properties, and moves the role to `Researched`. No CVs are produced. After reading the research, you fill in the Why I Want This Role field.

New Application needs two inputs that exist only after Intake runs: the strategic properties the coach writes, and the motivation you provide in the Why field. Without them, the letter-writer falls back to generic framing. Run Intake before New Application for any role you genuinely want.

### Sourcing modes

`source-open-roles` searches a catalog of about two dozen sources and resolves one of seven modes.

| Mode | Sources |
|---|---|
| `quick` | LinkedIn only |
| `remote` | remote-focused boards |
| `startup` | startup boards |
| `broad` | general job boards |
| `ai` | AI and ML focused sources |
| `full` | the entire catalog |
| `contract` | Upwork and BeBee (surfaced as contract signals, not ranked roles) |

Results are deduplicated against your tracker, filtered by your exclusion patterns, scored 0 to 100 on a published rubric, and saved to a dated sourcing file. A role scoring 75 or higher triggers an add-to-intake offer. The first run collects your preferences through a short setup saved to a JSON file.

---

## Inside a New Application run

This is the core pipeline, described at the level you need to read its output. The run proceeds end to end. The orchestrator does not pause to ask scope questions mid-run; the only valid interruptions are an unrecoverable error or you typing a stop command.

### Before the run

The orchestrator verifies it can reach your output folder, loads the required skills, and reads your gap-handling preference. A configuration guard stops the run with setup instructions if your database ID is still an unreplaced placeholder.

### Fetch and prepare roles

The orchestrator fetches the database schema first and treats it as the authority for every property name and select value it will write. It then queries for `Interested` roles. For each role it captures the full payload: company, position, URL, stored job-description body, all coach properties, and your Why content. In `--now` mode this step is skipped and a single role is passed directly.

### Acquire the job description

For every role with a URL, the live posting is fetched even when a stored copy exists, because postings change. If a fetch fails, a fallback ladder takes over: domain connectors for LinkedIn and Indeed, rendering-capable extractors discovered at runtime, the company careers page, ATS and job-board mirrors, and finally an exact title-and-company search. A page that returns only navigation, a cookie wall, or a script shell counts as a failed fetch. A role is marked for manual handling only after the full ladder is exhausted, and it keeps its status so it reappears next run.

### Build the queue

Priority is the only ordering signal, on a 1 to 6 scale. With five or fewer roles, all of them process and ordering is skipped. With more, the top five are selected in priority order. Open or speculative applications with no specific listing are floored at the lowest priority.

### Employment coach

The coach is the research engine. For each role it researches the company across ten dimensions (current product, structure, market position, five named competitors with Israel-presence flags, what the role really means here, fit and gaps against your documented background, company dynamics, recruitment criteria, career path, and hiring-manager identity). It decodes the job description into real responsibilities, true seniority (flagging any step-down explicitly), and signals, then scores priority weighted 40 percent culture and stage fit, 40 percent documented credential match, and 20 percent level and trajectory. Every research claim carries a `[HIGH]` or `[LOW]` confidence tag.

The coach owns and writes the strategic properties listed in [Job tracker database](#job-tracker-database). No other agent writes to them.

### Writeback and briefing

Coach outputs are written to your tracker under a write-only-to-empty rule: an existing value, including a deliberate `N/A`, is never overwritten. You then receive one briefing in chat: the queue, the priorities and the reasons for them, and the per-role strategy. This is the single moment you see the coach's reasoning before document work begins. The run does not wait for a reply.

### CV loop (per role)

1. **cv-writer (draft)** writes a full CV from the coach's framing. Approved bullets are the default source; fresh bullets are written from documented role facts only where no approved bullet maps to a requirement.
2. **gatekeeper (CV)** runs an ATS pre-check (keyword coverage thresholds, standard headings, no hostile formatting) plus content and structure rules. A failure loops back to cv-writer with the full violation list. Cap: three passes, then flag for manual review and continue.
3. **recruiter-reviewer** reviews as a senior recruiter and returns tiered feedback: elimination risks, competitive weaknesses, polish.
4. **hiring-manager-reviewer** reviews as the hiring manager and returns a verdict (Yes, Conditional with the one decisive condition named, or No).
5. **cv-writer (revision)** applies a strict ladder to each flag: reframe or reorder documented experience, surface documented experience not yet shown, or leave the flag visibly unaddressed when neither is possible without fabricating.
6. **gatekeeper (CV)** runs the same checks on the final CV.

### The letter gate

If your Why I Want This Role field is empty, no letter is written for that role. The CV ships alone with a message to fill in the field and re-run. The gate is per-role; the batch continues. In `--now` mode the Why content is collected in chat before this gate, and "skip" means CV only.

### Cover letter loop (per role)

The letter loop mirrors the CV loop (draft, gatekeeper, recruiter, hiring manager, revision, gatekeeper), then adds two final steps unique to letters: a humanizer pass and a final-bytes verification. Both are described in [How cover letters get your voice](#how-cover-letters-get-your-voice).

### Export

pandoc converts the markdown to DOCX against your `.dotx` templates, and a script writes the exact role title into the CV header subtitle. A word-count check approximates page fit. Both files must exist and be nonzero on disk before the run continues. If the role's Languages property includes Hebrew, the localization agent runs after the English export and produces two more DOCX files in the same folder.

### Writeback and logging

After export, the orchestrator posts file paths and the output-folder link to your tracker, writes coach-owned and hiring-manager properties plus `Last Pipeline Run`, sets Status to `CV Ready for Review`, writes a feedback file with all four reviewer passes verbatim, and appends the role to `state.json`.

### After all roles finish

The orchestrator aggregates keywords across the run into a LinkedIn updates file, writes a run-level revision log, promotes durable Why content into your motivation bank, and asks once which companies' fresh bullets to lock. Final delivery in chat is a single line when nothing needs reporting.

---

## How cover letters get your voice

The cover letter pipeline is where the system does the most to match your voice rather than read like an AI. Four mechanisms do that work.

**The voice gate.** Before writing a word, the letter-writer reads the index of your delivered letters, opens the two or three closest in domain, and calibrates register against them. The more letters you keep in `career-data/references/delivered-letters/`, the tighter the match.

**The opener rule.** The opening paragraph is built solely from your Why content, in your vocabulary. It must pass a context test: if the paragraph could appear unchanged in a letter to a different company, it is rewritten before the body is drafted. The opening paragraph is then protected; reviewer feedback cannot rewrite it.

**The humanizer.** After the gatekeeper passes the letter, a dedicated humanizer reads your delivered letters and your quantitative voice fingerprint, then walks ordered rule sets covering punctuation, sentence structure, vocabulary, and structure, rewriting only the sentences that violate a rule. The body is capped at 320 words, with no minimum.

**Final-bytes verification.** Because the humanizer changes text after the last gatekeeper pass, that pass no longer holds. A final check runs on the exact markdown that will be converted: a mechanical checklist (company name present, role title present, zero em dashes and colons in the body) plus one fresh gatekeeper pass. Text that has not cleared this step is never exported. If it cannot clear within two rounds, the system reverts to the last good version and flags it for your review.

Voice authority is tiered, which matters when a rule and your real writing disagree. Truth is absolute over every input, including your own claims; anything unverifiable is set aside and surfaced to you, never silently dropped. Structure rules (opener sourcing, the ban on repeating CV content) are strict. Voice and register are governed by your delivered letters and your fingerprint: a pattern consistent with your sent letters is kept, not "corrected," even when a generic rule would flag it.

---

## Job tracker database

The tracker is the input and output surface for every batch run. The pipeline reads roles from it, writes strategic properties back, and posts file paths after each role finishes.

The integration is name-based. The pipeline writes to columns by exact name, so renaming a required column breaks it without an error. Extra columns you add for your own use are ignored. Onboarding (`/career-engine:setup --phase 5`) configures the connection and walks you through the schema, including the Notion template and the CSV header set.

### Required properties

| Property | Type | Owner | Purpose |
|---|---|---|---|
| `Company` | Title | You | Company name; also drives the output subdirectory name |
| `Position` | Text | You | Role title |
| `Job URL` | URL | You | The posting URL |
| `Status` | Select | You + Pipeline | Lifecycle driver (six fixed values) |
| `Priority` | Select | Coach | Queue order; `Highest`, `First` through `Fifth` |
| `Why I Want This Role` | Text | You only | Mandatory letter source; agents never write here |
| `Note` | Text | You only | Your personal notes; agents never write here |
| `Languages` | Multi-select | You | `English`, `Hebrew`; Hebrew triggers localization |
| `Edit type` | Select | You | `CV`, `Letter`, `Both`; gates the Edit pipeline |
| `JD Body` | Text | Coach | Verbatim job description |
| `JD Fetch Status` | Select | Coach | `Fetched`, `LinkedIn-blocked`, `Unfetchable` |
| `Israel Compatibility` | Select | Coach | `Yes`, `Remote-only`, `No` |
| `Role emphasis` | Text | Coach | The real mandate beneath the title |
| `JD proof` | Text | Coach | Verbatim JD quote supporting Role emphasis; for your verification only |
| `Keywords` | Text | Coach | 6 to 10 tiered terms: `Critical: … \| Important: … \| Nice-to-have: …` |
| `Strategy` | Text | Coach | Exactly three labeled hiring-manager priorities |
| `Role Type` | Multi-select | Coach | `Builder`, `Scaler`, `Specialist`, `Leader`; drives CV structure |
| `Relationship type` | Select | Coach | `Full time`, `Part time`, `Temporary`, `Fractional/Consulting/Freelance` |
| `Gap handling` | Text | Coach (you may override) | One line per gap; your edit wins over the coach's |
| `Role summary` | Text | Coach | Short role-fit proxy that downstream agents read |
| `Company Stage` | Select | Coach | `Seed` through `Public`, `PE-backed`, `Stealth`, `N/A` |
| `Hiring Manager's Name` | Text | Coach | Hiring manager name and title |
| `Hiring manager's role` | Text | Coach | What their org position implies for your seniority |
| `Manager role confirmed` | Select | Coach | `Yes`, or `No; this is only a hypothesis` |
| `Person who Advertised Role` | Text | Coach | Name and title of the poster, if not the hiring manager |
| `No incumbents in this function` | Select | Coach | Drives Builder versus Scaler framing |
| `First Advertised` | Text | Coach | When the role was first posted |
| `Landscape` | Text | Coach (research) | Competitive landscape from the research pipeline |
| `Last Pipeline Run` | Date | Orchestrator | ISO date of the most recent completed run |
| `Link to CV` | Text | Orchestrator | File paths posted after the run |
| `Draft Directory` | URL | Orchestrator | Link to the output folder; written only after files are verified |
| `CV File Name` | Text | Orchestrator | CV filename for this role |
| `Letter File Name` | Text | Orchestrator | Cover letter filename for this role |

### Property write discipline

Every property has exactly one authoritative writer. Agents do not write to each other's properties, and they do not write the same fact into two fields.

The employment coach owns the strategic properties and sets them once. `JD proof` is a transparency field: it lets you check that the coach's Role emphasis matches what the posting actually says, and no writing agent reads it. The `Note` field is yours alone; no agent ever writes to it.

---

## Output files

Every run writes to a dated run folder: `<output_folder>/applications-<YYYY-MM-DD>/`. Each role gets its own subdirectory, named after the company in kebab-case.

`<output_folder>` is whatever local path you set during onboarding: iCloud, Dropbox, a plain directory, anywhere your filesystem allows.

### File names

Files use a consistent slug: `<roletitle>-<company>-<monYYYY>`, lowercased and hyphenated.

| File | Pattern |
|---|---|
| CV | `cv-<lastname>-<slug>.docx` (with a `.md` sibling) |
| Cover letter | `coverletter-<lastname>-<slug>.docx` (with `.md` and `.prehumanizer.md` siblings) |
| Hebrew CV | `he-cv-<lastname>-<slug>.docx` |
| Hebrew cover letter | `he-coverletter-<lastname>-<slug>.docx` |
| Reviewer feedback | `feedback-<slug>.md` |
| Revision log (per role) | `revision-log-<slug>.md` |
| Revision log (per run) | `revision-log-<YYYY-MM-DD>.md` |
| LinkedIn updates | `linkedin-updates-<YYYY-MM-DD>.md` |
| State | `state.json` |
| Metrics | `run-metrics-<YYYY-MM-DD>.json` |

For a Head of Marketing role at Acme in April 2026, that produces `cv-smith-head-of-marketing-acme-apr2026.docx`, `coverletter-smith-head-of-marketing-acme-apr2026.docx`, and `feedback-head-of-marketing-acme-apr2026.md`.

### What each file holds

**The feedback file** is the one to read after a run. It contains all four reviewer passes verbatim: recruiter CV review, hiring-manager CV review, recruiter letter review, hiring-manager letter review, plus the CV change log.

**The per-role revision log** records what the writers changed between draft and final, including the gatekeeper violations caught and resolved.

**The per-run revision log** records cross-run decisions, orchestration issues, and any roles that failed or were dropped.

**The LinkedIn updates file** aggregates high-frequency keywords across the run and, when you have provided a LinkedIn profile snapshot, sorts every signal into genuinely missing, present but buried, or already covered, each paired with the profile section it would strengthen. Provide the snapshot by exporting your LinkedIn PDF and saying "update my references."

**`state.json`** is the machine-readable record of every role processed: file paths, page IDs, verdicts, and coach properties. It powers `--status` and crash recovery. A role recorded as exported is skipped on re-run, because disk is the source of truth and writeback can fail independently. To resume an interrupted run, set the affected role back to `Interested` and run again.

---

## How approved bullets work

On your first run there are no approved bullets, only raw role facts from setup. The pipeline writes fresh bullets for each CV from the job description and your documented background. After each run, it asks which companies you want to lock. Locked bullets are reused verbatim in future CVs for the same company, and that is where consistency and quality compound.

The first run is rarely final. Review the output, flag what needs work with `--edit`, run again. After a pass or two on a company, the bullets sharpen, and then you lock them.

Setup extracts raw facts from your old CV (company, dates, metrics, scope) but does not treat your old bullet phrasing as approved. Existing wording is starting material, not finished product. An approved bullet is one the pipeline wrote and you explicitly locked.

At the end of every run, the orchestrator asks:

> "New bullets were written for: Company A, Company B. Which should I add to your approved list? Reply with company names, 'all', or 'none'."

Approving a company writes its bullets into `02-professional-background.md` under that company's entry. Future runs for the same company start from those bullets instead of generating from scratch.

---

## Agents and skills

### Commands

The plugin has two command groups: pipeline commands that run against your tracker, and standalone skills that run independently of any active job search.

**Pipeline commands** run the multi-agent pipeline and need Notion or CSV configured.

| Command | Behavior |
|---|---|
| `/career-engine` | Full pipeline against `Interested` roles |
| `/career-engine --edit` | Editing pipeline for `Needs editing` roles |
| `/career-engine --coach-skills` | Market intelligence on `Hold` roles; no CVs |
| `/career-engine --now <url>` | Single role, no tracker |
| `/career-engine --coach <question>` | Direct coaching, conversational |
| `/career-engine --check` | Gatekeeper pass on pasted content |
| `/career-engine --review` | Recruiter and HM review on pasted content |
| `/career-engine --write-letter` | Cover letter only |
| `/career-engine --status` | Read `state.json`, no agents |

**Standalone skills** need no tracker.

| Command | Behavior |
|---|---|
| `/career-engine:source-open-roles` | Sources roles across LinkedIn, remote, startup, and general boards; scores against your preferences; deduplicates against your pipeline; returns a ranked list. Seven modes (see [Sourcing modes](#sourcing-modes)). Requires the LinkedIn MCP for LinkedIn results. |
| `/career-engine:personal-brand` | Builds or refreshes your positioning with the Why You / Why Them / Why Now framework; produces a positioning statement, audience and channel map, content pillars, and bio library. |
| `/career-engine:linkedin-coach` | Profile audit, content review, content strategy, headline optimization, and a 30-second video script; five modes. |

### Agents

Ten agents handle all reasoning and writing. The orchestrator spawns them as subagents; they return text only and never write files directly.

| Agent | What it does |
|---|---|
| **employment-coach** | The research and prioritization engine. Fetches job descriptions, researches companies (including LinkedIn profiles, hiring managers, and team composition when the LinkedIn MCP is connected), scores priority, and writes every strategic property. Two modes: pipeline (batch, with writeback) and direct coaching (conversational, no writeback). |
| **cv-writer** | Writes and revises CVs from documented background only. Structure is driven by Role Type. The fabrication rule is absolute. Two options: draft and revision. |
| **letter-writer** | Writes and revises cover letters. Refuses to write without your Why content. Voice and structure rules hold regardless of reviewer feedback. |
| **gatekeeper** | The rule checker. Returns PASS or a specific violation list, never rewrites, never judges quality. Three options: CV content, cover letter, and coach-output fact check. |
| **recruiter-reviewer** | Reviews CVs and letters as a senior recruiter. Returns tiered feedback. Flags honestly, knowing the writers will not fabricate to satisfy a flag. |
| **hiring-manager-reviewer** | Reviews as the hiring manager. CV review returns Yes, Conditional, or No. Letter review answers whether the letter addresses the condition, adds something the CV cannot, and raises interview likelihood. |
| **cover-letter-humanizer** | The final-stage language editor. Removes AI writing patterns sentence by sentence after the gatekeeper passes the letter. Changes language only, never structure or content. |
| **localization** *(alpha)* | Produces native Israeli-register Hebrew CV and letter after the English export, when Languages includes Hebrew. Translation only. |
| **source-open-roles** | Top-of-funnel role sourcing across job boards; scores and ranks against your saved preferences; deduplicates against your tracker. Seven search modes. |
| **qa-plugin** | The maintenance-time auditor that checks the plugin itself after edits. It does not run during your job-search runs. |

### Skills

Skills hold the detailed procedures and writing doctrine each agent follows. The orchestrator loads them before processing begins.

| Skill | Loaded by | Purpose |
|---|---|---|
| `career-engine` | entry command | Routing to the right pipeline |
| `career-engine-orchestrator` | Orchestrator | Full pipeline coordination |
| `career-engine-intake` | Orchestrator | Notion fetch, coach invocation, queue building |
| `career-engine-new-application` | Orchestrator | Per-role CV and cover letter pipeline |
| `career-engine-export` | Orchestrator | DOCX conversion, file naming, copy protocol |
| `career-engine-edit` | Orchestrator | Editing pipeline for `Needs editing` roles |
| `career-engine-coach` | Coach command | Standalone research pipeline for `Hold` roles |
| `career-engine-setup` | Setup command | Onboarding phases 1 through 7 |
| `cv-writing` | cv-writer | Bullet formula, ATS rules, forbidden phrases |
| `cover-letter` | letter-writer | Voice rules, structure, use-case patterns |
| `cover-letter-humanizer` | humanizer | AI-pattern rule sets and the final voice pass |
| `gatekeeper-checks` | gatekeeper | The full checklist for every gatekeeper option |
| `employment-coach` | employment-coach | Research procedure, scoring, strategic-property definitions, LinkedIn protocol |
| `source-open-roles` | source-open-roles command | Search modes, site catalog, scoring rubric, deduplication |
| `personal-brand` | personal-brand command | Positioning, bio library, content pillars |
| `linkedin-coach` | linkedin-coach command | Profile audit, content review and strategy, headline optimization |
| `localization` | localization | Hebrew register, terminology, RTL handling |
| `update-refs` | "update my references" | Classify, propose, approve, apply for reference files |

---

## Configuration

### Permissions

The pipeline runs shell commands and MCP tool calls throughout. Without pre-approved permissions, Claude Code pauses for approval at each one. Add the block below to `~/.claude/settings.json` under the `permissions` key.

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

Run `/career-engine:setup --phase 6` to generate the exact block with your real `<notion-tool-id>` and `<desktop-commander-id>` filled in from your MCP configuration. This is the recommended path; hand-editing the placeholders above is a fallback only. If a `permissions` block already exists, merge the `allow` arrays rather than replacing them.

### CV template and output format

Every role gets two outputs: a markdown file and, when pandoc is installed, a DOCX file. The markdown is canonical; the DOCX is a formatted version of it.

**DOCX export** uses `references/cv-template-default.dotx`, a Word template that controls fonts, heading sizes, colors, and the header layout. Word is not required to open the result; LibreOffice and Google Docs open `.docx` files too. To use your own template, provide its path during setup. Your template must define the same custom style names; the style reference is in `skills/career-engine-export/SKILL.md`.

**Markdown output** needs no dependencies. Without pandoc, the pipeline still writes a complete markdown file for every CV and cover letter. Paste it into Google Docs and apply your own formatting, post it as a Notion page, or open it in any editor.

### Token usage tracking

The pipeline tracks token consumption per run. After a few runs you can compare the cost of a single CV, a five-role batch, and an edit pass.

At the end of every run, the orchestrator writes `run-metrics-<date>.json` to your output folder, recording pipeline type, roles processed, and per-agent invocation counts. A Stop hook captures the actual token counts and cost when the session closes and writes them into the same file. Add the hook to `~/.claude/settings.json` alongside the permissions block:

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

Run `/career-engine:setup --phase 6` to generate this block too, with `${CLAUDE_PLUGIN_ROOT}` resolved to your installation path from your Claude Code plugin settings. Hand-editing the placeholder is a fallback only. Without the hook, `token_counts` stays `pending` and the structural metrics are still recorded.

### Delivered letters

`career-data/references/delivered-letters/` holds cover letters you have sent and confirmed represent your voice. The letter-writer reads two or three domain-similar letters from this folder before drafting, calibrating sentence patterns, vocabulary, and paragraph structure against them. The archive caps at six letters.

Add a letter any time by saving it as a `.md` file named `coverletter-<lastname>-<roletitle>-<company>-<monYYYY>.md`. The more you keep here, the more precisely the letter-writer matches your voice.

---

## Troubleshooting

### The pipeline stops mid-run with an approval prompt

The permissions block in `~/.claude/settings.json` is incomplete or missing. Run `/career-engine:setup --phase 6` to regenerate the exact block for your configuration, then add it.

### "Output path not found"

The output folder set during setup does not exist or is not reachable. Confirm the path with `ls` in your terminal. To change it, re-run `/career-engine:setup --phase 5`.

### DOCX files have no formatting

pandoc is missing or cannot find the `.dotx` template. Confirm pandoc with `pandoc --version`. If the command is not found, run `brew install pandoc`. If pandoc is installed but the DOCX is still unstyled, confirm the CV template path was set during setup.

### "python-docx not found" or the subtitle is not updated

The subtitle script needs python-docx. Install it with `pip3 install python-docx`. This failure is non-blocking: the CV is still produced, but the role-specific subtitle in the header is not updated for that run.

### The coach drops a role

The coach drops a role whose job description it cannot reach after exhausting the fallback ladder. Common causes are a login wall, an expired URL, or a board that blocks automated fetching. The dropped role appears in the run-level revision log. To process it manually, paste the job-description text into the row's `JD Body` field, set Status to `Interested`, and run again.

### Notion properties are not updating

The Notion MCP connection may have expired, or the database ID is wrong. Confirm the Notion MCP is connected and that the configured database ID matches your actual database. Re-run `/career-engine:setup --phase 5` to reconfigure.

### A gatekeeper loop exceeds its limit

The gatekeeper loops with a writing agent until every check passes. Exceeding the cap usually means a check is failing that the writer cannot resolve within the fabrication rule, most often because the job description requires experience your reference files do not document. Read the gatekeeper output in chat, and add the experience to `02-professional-background.md` if it is genuinely there.

### The cover letter does not sound like me

The letter-writer draws voice from your Why content and the delivered letters in `career-data/references/delivered-letters/`. With neither populated, it falls back to `03-framework.md`, which produces more generic output. Add your best past letters to the archive and fill in the Why field before re-running.

### `state.json` is missing after a run

The run crashed before completing, or the state write failed. Run `/career-engine --status`; if no state file is found, it reports that. Check the output folder for the dated run folder. Resume a partial run by setting the affected role back to `Interested` and running again.

---

## How it is built

career-engine is a Claude Code and Cowork plugin: a packaged directory of markdown instruction files plus a few scripts and Word templates. There is no server and no separate database.

```
career-engine.plugin
├── .claude-plugin/plugin.json   manifest
├── agents/                       10 agent definitions
├── skills/                       18 skill modules (procedures + writing doctrine)
├── references/                   blank templates and read-only doctrine (no personal data)
└── scripts/                      the token-usage Stop hook
```

The export scripts (`convert-cv.sh`, `update-subtitle.py`) ship inside the export skill at `skills/career-engine-export/scripts/`, not in top-level `scripts/`.

The plugin is one build of code plus blank `{{...}}` templates and carries no personal data. Your filled data layer lives in the separate `career-data` skill, which agents resolve at run start; the plugin's blank templates are a new-user fallback only.

A strict separation keeps the layers clean. Agents hold orchestration only: identity, gates, file-loading tables, steps, and output formats. Skills hold doctrine: craft rules, thresholds, templates, and vocabulary. References hold blank scaffolding and read-only doctrine; your source material lives in `career-data`, which agents read and never write except through named pipeline steps and the app-based update flow. Internal paths always use the `${CLAUDE_PLUGIN_ROOT}` variable rather than absolute paths.

The orchestrator runs in the main session, not as a spawned subagent, because sandboxed subagent shells lose access to the real filesystem. Only reasoning agents are spawned. Every loop is bounded with a defined fallback, so no run can stall.

Contributions are welcome. If a roadmap direction is relevant to work you want to do, open an issue on [the repository](https://github.com/spinningrachel/career-engine).

---

## Roadmap

### Confirmed, with fuller documentation coming

- **Crash recovery and resumption.** New Application writes `state.json` after every role. After an interruption, set the affected role back to `Interested` and re-run; the pipeline picks up where it left off. Inspect the state file any time with `/career-engine --status`.
- **CV type handling.** The Role Type system (`Builder`, `Scaler`, `Specialist`, `Leader`) drives CV structure. The coach assigns it; you do not set it manually.
- **Onboarding pause and resume.** The framework interview can stop and continue later. Run `/career-engine:setup --phase 4` to resume. `[DRAFT]` and `[REVIEW]` markers in `03-framework.md` track what is confirmed and what still needs work.

### Documentation coming

- **Word template details.** Full documentation of the styles, macros, and configuration options in `cv-template-default.dotx`.
- **RTL and Hebrew setup** *(alpha)*. Hebrew localization is live, but right-to-left layout in Word still needs manual configuration. Until the instructions land, ask the pipeline agent to walk you through it.
- **Hebrew enrichment** *(alpha)*. Richer localization: more cultural calibration, additional term handling, and deeper cover letter adaptation.

### Planned

- **Deeper hiring-side research.** Tracking relationships and mutual contacts at a target company, monitoring team changes, and improving company intelligence as context accumulates per employer.
- **Job-search assistance.** Surfacing roles from your profile and criteria, tracking application status and follow-up timing, and building a searchable record of every company researched and role applied to across multiple searches.

---

## License and support

career-engine is released under the MIT License by Rachel Cheyfitz.

If the plugin has been useful, you can support its development here:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A1L720MCOG)
