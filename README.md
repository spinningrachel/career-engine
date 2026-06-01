# cv-campaign

Job searching at scale breaks down fast. Every application takes hours to tailor, each session starts from scratch, and most AI tools make it worse: they write confidently about experience you don't have.

The cv-campaign plugin runs a full multi-agent pipeline. It pulls your target roles from Notion, researches each company, drafts and reviews tailored CVs and cover letters, exports formatted Word files to your output folder, and writes results back to Notion. No supervision required.

One rule runs through every agent: nothing goes on the page that isn't traceable to your documented background. The system gets sharper the more you run it. Every correction feeds back into the files every agent reads before writing anything.

Most job search tools give you one agent and a template. A few things that are different here:

- **Multi-agent review loop** — cv-writer, gatekeeper, recruiter reviewer, and hiring manager reviewer all run before anything is delivered
- **Employment coach with prioritization** — researches each company, scores your role queue, and writes strategic framing before a single bullet is drafted
- **Mandatory revision pass** — every letter runs a voice calibration and AI-pattern audit before the gatekeeper sees it. Not optional, not conditional
- **Notion integration** — reads your pipeline from Notion, writes CV file paths and coach properties back to each row when the run completes
- **Hebrew localization** — native Israeli professional Hebrew CVs and cover letters produced as a pipeline step, not an afterthought

What makes these reliable is the structure underneath. Three reference files — candidate rules, candidate background, and positioning framework — are read by every agent before writing anything. They accumulate as you run the pipeline. The longer you use it, the less it invents and the more it knows.

**Built and maintained by [Rachel Cheyfitz](https://www.linkedin.com/in/rachelcheyfitz).** Open-sourced so other job seekers can run the same pipeline with their own background, voice, and job-tracking setup.

## What it does

- **Employment coach** — researches each target role (funding, hiring manager, JD analysis), assigns a priority score, and writes strategic properties (role emphasis, keywords, gap handling)
- **CV pipeline** — drafts a tailored CV, runs it through recruiter and hiring manager reviewers, revises, and exports DOCX via pandoc
- **Cover letter pipeline** — writes a letter grounded in your Q&A intake and coach output, runs the same reviewer loop
- **Gatekeeper** — quality gate at every stage: checks fabrication, ATS compliance, voice, and structure before anything is delivered
- **Standalone modes** — `--now` for a single role without Notion, `--coach` for direct career advice, `--check` to audit any existing document

## Prerequisites

| Tool | Install |
|---|---|
| **pandoc** | `brew install pandoc` |
| **python-docx** | `pip3 install python-docx` |
| **Notion MCP** | Connected and authenticated |
| **Desktop Commander MCP** | Connected |
| **Job search MCPs** | Indeed, Dice, ZipRecruiter (optional but recommended) |

## Setup

**Run once after installing the plugin:**

```
/cv-campaign:setup
```

The setup agent will walk you through:

1. **Your profile** — populate `references/who-i-am.md` and `references/03-framework.md` with your background, voice, and positioning
2. **Job tracking** — connect your Notion database (use the [Notion template](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782) for the expected schema) or set up a CSV/spreadsheet alternative
3. **Output folder** — configure your iCloud (or local) output path
4. **CV template** — use the included `cv-template-default.dotx` or provide your own `.dotx` file with custom styles
5. **Permissions** — add the required bash and MCP permissions to your Claude Code settings

You can also populate the reference files manually — see `references/who-i-am.md` and `references/03-framework.md` for the template structure with instructions at every `{{placeholder}}`.

## Pipeline overview

```
Notion Job Applications DB                     OR    --now <url or JD text>
  (filter: Status = Interested)                            │ (skips Notion entirely)
         │                                                 │
         ▼                                                 ▼
    employment-coach              → fetches JDs for all roles (parallel); drops inaccessible roles
         │                        → structured JD + Date first advertised + Israel/Remote check
         │                        → pre-flight check: drops roles with no accessible JD
         │                        → researches: funding, recent news, hiring manager, culture signals
         │                        → pedantic remote check: Remote(US) ≠ worldwide
         │                        → priority (Highest/First–Fifth) per role
         │                        → respects existing priorities, generates for blanks
         │                        → owns Role emphasis, JD proof, Keywords, Strategy
         │                        → practitioner roles: reporting line + founding/joining context explicit
         │                        → confidence-tagged output: [HIGH] overwrites, [LOW] fills empty only
         ▼
    Notion priority writeback     → generated priorities + coach properties posted to each row
         │                          (skipped entirely in --now mode)
         ▼
    Queue built (up to 5 roles, ordered by Final ({{USER_FIRST_NAME}}'s) Priority)
    {{USER_FIRST_NAME}} briefed on coach output
         │
         ▼
    FOR EACH ROLE IN QUEUE (in priority order):
         │
         ├─ IF Standard pipeline (or --now):
         │     ├─ cv-writer (draft)           → DRAFT CV (Role Type-driven framing)
         │     ├─ gatekeeper (content)        → ATS pre-check + 13 content checks — loops silently until PASS
         │     ├─ recruiter-reviewer          → structured feedback
         │     ├─ hiring-manager-reviewer     → structured feedback + verdict
         │     ├─ cv-writer (revision)        → FINAL CV + CV CHANGES (included in feedback file)
         │     ├─ gatekeeper (content)        → ATS pre-check + same 13 checks — loops silently until PASS
         │     ├─ letter-writer (cover letter) → always produced; equally required as the CV
         │     ├─ gatekeeper (cover letter)   → 13 voice/structure checks — loops silently until PASS
         │     ├─ recruiter-reviewer (CL)     → cover letter screening-risk check
         │     ├─ hiring-manager-reviewer (CL) → condition addressed / adds value / interview likelihood
         │     ├─ letter-writer (revision)    → final cover letter incorporating both feedback sets
         │     ├─ gatekeeper (cover letter)   → final voice/structure check — loops until PASS
         │     ├─ DOCX export                 → CV DOCX + cover letter DOCX via pandoc + .dotx templates
         │     │                               scripts/update-subtitle.py sets role tagline in CV header
         │     │                               both files copied /tmp → iCloud output folder
         │     ├─ Feedback file               → feedback-<role>-<company>-<mon>.md saved to iCloud folder
         │     │                               verbatim output from all 4 reviewer invocations
         │     └─ Notion writeback            → both iCloud file paths posted to Link to CV
         │                                      + coach-owned properties written to row
         │                                      (skipped in --now mode — no Notion row exists)
         │
         └─ IF Reframe only pipeline:
               ├─ cv-writer (option=draft)    → tailored CV (no cover letter produced)
               ├─ DOCX export                 → pandoc conversion, /tmp → iCloud output folder copy
               └─ Notion writeback            → local iCloud file path posted to Link to CV

    AFTER ALL ROLES:
         │
         ├─ LinkedIn updates file (orchestrator, inline)
         │     aggregates Keywords across all roles → frequency map → high/medium signal terms
         │     extracts first 2 sentences from each CV summary markdown
         │     writes linkedin-updates-<date>.md to iCloud output folder
         │
         └─ final chat delivery (orchestrator)
              → cross-run decisions
              → technical/orchestration issues (failures logged during run, surfaced here)
              → --now mode note: "This role is not in Notion — add manually if you applied"
              → "All N roles completed" if nothing to flag
```

## Step-by-step reference

| Step | Actor | Summary |
|---|---|---|
| Preflight | Orchestrator (inline) | Confirm iCloud output folder exists, load all skills, confirm no mid-run scope pauses. |
| 0 — Fetch roles | Orchestrator (inline, Notion) | Query Job Applications DB for `Interested` rows with a Job URL or JD body. Capture full row payload. Pipeline (Standard / Reframe only) is determined by {{USER_FIRST_NAME}}'s chat command — not a Notion property. *(Skipped in --now mode.)* |
| 0.5 — Prepare JD content | Orchestrator (inline) | Check each role for existing JD Body content. Normalise page body → JD Body if needed. Pass job URLs and existing content to the coach. |
| 0.6 — Check priorities | Orchestrator (inline) | Flag each role `has-priority` or `blank-priority` based on `Final ({{USER_FIRST_NAME}}'s) Priority`. *(Skipped in --now mode.)* |
| 0.7 — Build queue | Orchestrator (inline) | Select up to 5 roles ordered by Final ({{USER_FIRST_NAME}}'s) Priority (Highest → Fifth). *(Skipped in --now mode — single role proceeds directly.)* |
| 0.8 — Employment coach | `employment-coach` | Pre-flight check: skips roles where JD is inaccessible. Researches funding, news, hiring manager, culture signals, date first advertised, and remote compatibility per role. Assigns priorities to blank roles. Returns strategic properties ([HIGH]/[LOW] confidence tags for Notion writeback). |
| 0.9 — Priority writeback + briefing | Orchestrator (inline, Notion) | Write coach properties to Notion (confidence-tagged: [HIGH] overwrites existing, [LOW] fills empty only). Brief {{USER_FIRST_NAME}}, then proceed. *(Skipped in --now mode.)* |
| **Per-role pipeline (Standard / --now) — CV steps** | | |
| 1 — Draft CV | `cv-writer` (option=draft) | Produce initial CV draft from structured JD using coach output (Role emphasis, Keywords, Strategy, Role Type, Relationship type). |
| 1.5 — Gatekeeper (CV draft) | `gatekeeper` (option=content) | ATS pre-check (Critical ≥80% / Important ≥60% keyword coverage, section headings, no ATS-hostile formatting) + 13 content checks. Loops silently with cv-writer until PASS. Nice-to-have misses are advisory only. |
| 2 — Recruiter review (CV) | `recruiter-reviewer` | Returns tiered feedback (Tier 1/2/3) on the CV draft. |
| 3 — HM review (CV) | `hiring-manager-reviewer` (option=cv) | Returns structured feedback and verdict (Yes / Conditional / No). |
| 4 — CV revision | `cv-writer` (option=revision) | Produces final CV plus revision log. Markdown saved to disk immediately after. |
| 4.5 — Gatekeeper (CV final) | `gatekeeper` (option=content) | ATS pre-check + same 13 checks. Loops silently until PASS. |
| **Per-role pipeline (Standard / --now) — Cover letter steps** | | |
| 5 — Cover letter draft | `letter-writer` (option=cover-letter) | Draft produced using final CV, structured JD, page body content, Q&A, Strategy, Gap handling, Role summary. 230–290 words. |
| 5.2 — Gatekeeper (CL draft) | `gatekeeper` (option=cover-letter) | 13 voice and structure checks. Loops silently with letter-writer until PASS. |
| 5.3 — Recruiter review (CL) | `recruiter-reviewer` | Reviews cover letter for screening-risk issues only. Returns tiered feedback. |
| 5.5 — HM review (CL) | `hiring-manager-reviewer` (option=cover-letter) | Three questions: condition addressed, adds something new, increases interview likelihood. Verdict: Proceed / Return. |
| 5.7 — Cover letter revision | `letter-writer` (option=revision) | Consolidates recruiter and HM feedback. Returns final cover letter plus revision log. Markdown saved to disk immediately after. |
| 5.8 — Gatekeeper (CL final) | `gatekeeper` (option=cover-letter) | Same 13 checks. Loops silently until PASS. |
| **Per-role pipeline (Standard / --now) — Export and writeback** | | |
| 6 — Produce DOCX | Orchestrator (inline, bash) | Convert CV markdown → CV DOCX (pandoc + {{CV_TEMPLATE_FILE}} + update-subtitle.py). Convert cover letter markdown → cover letter DOCX (pandoc + cover-letter-template.dotx). Copy both to iCloud output folder. Verify both files are nonzero. |
| 7a — File path writeback | Orchestrator (inline, Notion) | Post shortened paths to `Link to CV` property. *(Skipped in --now mode — no Notion row exists.)* |
| 7b — State file | Orchestrator (inline) | Append role record to `state.json`. Fields: `track`, `notion_page_id` (null in --now mode), `cv_path`, `cover_letter_path`, `feedback_path`, `hm_cv_verdict`, `hm_cl_verdict`, `role_emphasis`, `jd_proof`, `keywords`, `strategy`, `date_first_advertised`, `remote_compatibility`. Shortened paths only. |
| 7c — Pipeline outputs to Notion | Orchestrator (inline, Notion) | Write coach-owned properties, pipeline-derived properties (`Hiring Manager`, `Last Pipeline Run`), update Status to `CV Ready for Review`. Respects confidence tags from coach. *(Skipped in --now mode.)* |
| 7d — Reviewer feedback file | Orchestrator (inline) | Write `feedback-<role>-<company>-<mon>.md` to iCloud output folder. Contains verbatim output from all four reviewer invocations: Recruiter CV (Step 2), HM CV (Step 3), Recruiter CL (Step 5.3), HM CL (Step 5.5). Non-blocking — failure logged but does not stop the pipeline. |
| **Reframe pipeline (Reframe only)** | | |
| R1 — Reframe CV writer | `cv-writer` (option=draft) | Returns tailored CV draft. No cover letter produced. |
| R2 — Reframe DOCX | Orchestrator (inline, bash) | Export reframe CV to `.docx` via pandoc. Copy to iCloud output folder. |
| R3 — Reframe writeback | Orchestrator (inline, Notion) | Post the local iCloud file path to `Link to CV`. Update Status to `CV Ready for Review`. |
| 8 — LinkedIn updates | Orchestrator (inline) | After all roles complete: aggregate all Keywords from all coach outputs; count cross-role frequency; extract first 1–2 sentences from each CV summary markdown; write `linkedin-updates-<date>.md` to iCloud output folder. High signal (3+ roles), medium signal (2 roles), omit single-role terms. Non-blocking — failure logged but does not stop delivery. |
| Final delivery | Orchestrator (chat) | Brief summary covering validation issues, cross-run decisions, and technical failures only — or single confirmation line if none apply. --now mode appends a note to add the role to Notion if applied. |

## Components

### Command
- **cv-campaign** — Entry-point slash command (`/cv-campaign`). Flags:
  - *(none)* — full campaign against all Interested roles
  - `--edit` — editing pipeline for Needs editing roles
  - `--coach-skills` — market intelligence only; no CVs produced
  - `--coach <question>` — direct coaching, conversational
  - `--now <url or JD text>` — single-role fast track; skips Notion entirely
  - `--status` — read state.json from the most recent run; no agents spawned
  - `--check` — run gatekeeper on a pasted CV or cover letter; one pass, no loop
  - `--review` — recruiter + HM review on a pasted document; one pass, no loop
  - `--write-letter` — write a cover letter only; no full pipeline; no Notion

### Skills (load order matters for the main campaign)
1. **cv-pipeline-orchestrator** — Orchestrator. Triggers on "run CV campaign" and similar phrases. Loads all other skills before starting. Contains the `--now` mode flow (Steps N1–N5).
2. **cv-campaign-intake** — Steps 0 through 0.10: Notion fetch, JD content check, employment coach invocation (which fetches JDs), priority writeback, Q&A question generation for pre-researched roles, queue building, warm-up role selection.
3. **cv-campaign-role-steps** — Steps 1 through 7d: per-role CV writing and cover letter writing. CV loop: cv-writer draft → gatekeeper → recruiter review → HM review → cv-writer revision → gatekeeper. Cover letter loop: letter-writer draft → gatekeeper → recruiter review → HM review → letter-writer revision → gatekeeper. Then: DOCX export, Notion writeback, reviewer feedback file, revision log file.
4. **cv-reframe-pipeline** — Steps R1 through R3: reframe track only.
5. **cv-campaign-export** — Pandoc conversion commands, .dotx template references, script paths, file naming, and the `/tmp → iCloud output folder` copy protocol.
6. **cv-edit-pipeline** — Editing pipeline for roles with Status = `Needs editing`. Runs coach verification first, then improves existing outputs without starting from scratch. Loaded by the `--edit` flag only.
7. **coach-skills** — Standalone research pipeline. Loaded by the `coach.md` command (not the main campaign). Run with natural language ("research my roles", "run market intelligence", etc.). Researches companies behind Hold roles, spawns the employment coach for full strategic property generation, spawns letter-writer to generate Q&A questions, writes all results to Notion, and updates Status to Researched. This is the pipeline {{USER_FIRST_NAME}} runs before the full campaign to ensure the coach's advice and Q&A questions are ready before CV writing begins.

### Agents
1. **employment-coach** — {{USER_FIRST_NAME}}'s career coach and the pipeline's research engine. Fetches JDs directly as its first step — if JD Body is already in Notion, uses it; if not, fetches the URL and preserves verbatim text before any analysis; drops inaccessible roles and logs them. Then: researches funding, news, hiring manager, culture signals, date first advertised, and remote compatibility; assigns priorities for blank-priority roles; returns confidence-tagged strategic properties. Two modes: Pipeline (full analysis + Notion writeback) and Direct coaching (conversational, no writeback). Sole owner of `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, and `Gap handling`.
2. **cv-writer** — Writes and revises tailored CVs. Three options: Draft (Option 1), Revision (Option 2), Reframe (Option 3 — for founding/first TW roles where the pitch is "you need this, not a writer"). CV structure driven by Role Type (Builder / Scaler / Specialist / Leader). Fabrication rule is absolute — what can't be addressed through reframing or documented experience is left unaddressed. Cover letters are handled by letter-writer.
3. **letter-writer** — Writes and revises cover letters, and generates Q&A interview questions during the research pipeline. Three options: Standard cover letter (Option 1), Cover letter revision (Option 1b), Interview questions (Option 2). Tech writer reframe work uses cv-writer Option 3 instead. Receives page body content, Q&A, Strategy, and Gap handling from the orchestrator prompt — does not read Notion directly. Structure and voice rules in `skills/cover-letter/SKILL.md` are non-negotiable regardless of reviewer feedback.
4. **recruiter-reviewer** — Senior recruiter, Israeli tech and global startups. Returns tiered feedback (Tier 1/2/3) on CVs and cover letters. Flags everything accurately — cv-writer and letter-writer address what they can through reframing; what can't be addressed without fabrication is left unaddressed.
5. **hiring-manager-reviewer** — Two options. CV review (option=cv): direct evidence, gaps, Yes/No/Conditional verdict. Cover letter review (option=cover-letter): three questions — condition addressed, adds something new, increases interview likelihood. Verdict: Proceed / Return. One revision pass maximum.
6. **gatekeeper** — Quality gate. Two options: `content` (ATS pre-check + 13 content checks on every CV draft and revision) and `cover-letter` (13 voice and structure checks on every cover letter draft and revision). Returns PASS or a specific violation list. Loops silently until PASS. Never rewrites. Never judges quality. Checks rules only.

### Scripts (in `skills/cv-campaign-export/scripts/`)
- **convert-cv.sh** — Runs pandoc to convert CV and cover letter markdown to DOCX using the `.dotx` reference templates.
- **update-subtitle.py** — Updates the role-specific Subtitle in the CV DOCX header's first-page section.

## Databases and services

| Purpose | Identifier |
|---|---|
| Job Applications DB (input + per-role local iCloud file path posted to `Link to CV`) | `{{NOTION_DATABASE_ID}}` |
| iCloud outputs folder per run | `{{ICLOUD_OUTPUT_PATH}}/cv-campaign-<YYYY-MM-DD>/` |

### Required Notion properties on the Job Applications DB

The "Set by" column identifies who writes each property. Several properties are written by multiple actors at different points; "Set by" shows the authoritative writer for that property's strategic content.

| Property | Type | Set by | Purpose |
|---|---|---|---|
| `Status` | Select | {{USER_FIRST_NAME}} + Pipeline | Drives what the pipeline does with a role. Values and transitions defined authoritatively in cv-pipeline-orchestrator. Summary: `Hold` (being researched), `Interested` (queued for pipeline), `CV Ready for Review` (pipeline done), `Applied` (sent), `Researched` (market intelligence run). |
| `Job URL` | URL | {{USER_FIRST_NAME}} | The posting |
| `Priority` | Select: `Highest`, `First`, `Second`, `Third`, `Fourth`, `Fifth` | {{USER_FIRST_NAME}} / Coach | {{USER_FIRST_NAME}} sets manually; coach generates for blanks and writes back. Definitions in cv-pipeline-orchestrator. |
| `Landscape` | Text | Coach-skills | Competitive landscape written during the Hold → Researched research run. Includes funding, recent news, and competitor list. Written only if currently empty. |
| `Link to CV` | Text | Orchestrator | Local iCloud file paths posted after each role completes |
| `Role emphasis` | Text | Employment coach | 1-2 sentences on the real mandate beneath the job title |
| `JD proof` | Text | Employment coach | **For {{USER_FIRST_NAME}}'s reference only.** Verbatim quote from the JD that the coach used to justify its Role emphasis interpretation. {{USER_FIRST_NAME}} uses this to verify the coach isn't fabricating. Never read or used by any writing agent. |
| `Keywords` | Text | Employment coach | 8–15 tiered terms from the JD. Format: `Critical: ... | Important: ... | Nice-to-have: ...` |
| `Strategy` | Text | Employment coach | Lead proof point + secondary evidence + 2–3 sentence summary direction. CV/cover letter framing only — no interview prep. |
| `Role Type` | Multi-select: `Builder`, `Scaler`, `Specialist`, `Leader` | Employment coach | Drives CV structure and skills section format. See cv-pipeline-orchestrator for definitions. |
| `Relationship type` | Select: `Full time` / `Part time` / `Temporary` / `Fractional/Consulting/Freelance` / `Reframe` | Employment coach | What kind of engagement this document is pitching for. The one framing signal that materially changes how cv-writer and letter-writer approach the document. |
| `Gap handling` | Text | Employment coach ({{USER_FIRST_NAME}} may override) | One line per material gap: what it is and how to handle it (surface X instead / letter addresses via angle / ignore). Writes `N/A` if no material gaps exist. {{USER_FIRST_NAME}} can edit before triggering the CV pipeline — her version takes precedence. |
| `Role summary` | Text | Employment coach | 2-sentence max summary of the role and fit, followed by a bulleted list of why the role fits {{USER_FIRST_NAME}}'s background, and a culture signal. |
| `Hiring Manager` | Text | Orchestrator | Hiring manager name and title from the coach's research |
| `Hiring manager's role` | Text | Employment coach | Hiring manager's title + 1 sentence on what their org position implies for {{USER_FIRST_NAME}}'s seniority and accountability. Hypothesis flagged if not confirmed. |
| `Manager role confirmed` | Select | Employment coach | `Yes` = confirmed from JD/LinkedIn/team page. `No; this is only a hypothesis` = inferred from company stage and comparable data. |
| `Person who Advertised Role (if not Hiring Manager)` | Text | Employment coach | Name + title of the person who posted the role if different from the identified hiring manager. "Same as hiring manager" or "Not identifiable" if applicable. |
| `No other Marketing roles employed by company` | Select | Employment coach | `No other marketers employed` = founding/sole marketer role confirmed. `There's already at least one ...` = other marketing roles exist. Critical for Builder vs. Scaler framing at early-stage companies. |
| `Last Pipeline Run` | Date | Orchestrator | ISO date written at pipeline completion |
| `Note` | Text | {{USER_FIRST_NAME}} / Agent (overflow only) | {{USER_FIRST_NAME}}'s own notes, or genuinely additional context that structured properties cannot carry |

## Pipelines and modes

The system has two independent dimensions: **pipeline** (what kind of output to produce, specified in {{USER_FIRST_NAME}}'s chat command) and **mode** (whether to produce it from scratch or improve existing output, determined by Status in Notion).

### Pipelines — specified by {{USER_FIRST_NAME}} in chat

Pipeline is not a per-role Notion property. {{USER_FIRST_NAME}} tells the orchestrator which pipeline to run when she triggers a session. All `Interested` roles default to Standard unless {{USER_FIRST_NAME}} specifies otherwise.

| Pipeline | Outputs |
|---|---|
| `Standard` (default) | Tailored CV (DOCX) + cover letter (DOCX) + reviewer feedback file (MD) per role; one `linkedin-updates-<date>.md` per run |
| `Reframe only` | Tailored CV (DOCX) only — no cover letter |
| `--now <url>` | Same as Standard but skips Notion entirely; takes URL or pasted JD directly; no Notion writeback |

### Which mode runs — determined by Status in Notion

| Status | Triggered by | Mode | What runs |
|---|---|---|---|
| `Interested` | `/cv-campaign` (no flag) | **From scratch** | Full pipeline — all steps run fresh regardless of prior history |
| `Needs editing` | `/cv-campaign --edit` | **Edit** | Editing pipeline — starts from existing Notion outputs and improves them |
| `Hold` | `coach.md` command | **Market intelligence** | Research-only run via `coach-skills` skill; no CV produced; Status updates to `Researched` on completion |

Any pipeline can run in either mode. A Standard role with `Needs editing` runs the editing pipeline against the existing CV. A Reframe only role with `Needs editing` runs the reframe editing pipeline against the existing CV.

## Property write discipline

Each property is written once, by its designated writer. Agents must not write the same information twice across different fields, and must not populate a field that belongs to a different writer. The `Note` field is {{USER_FIRST_NAME}}'s space and an agent overflow field only — it must never be used to repeat or reword content already captured in a structured property.

The employment coach owns `Role emphasis`, `JD proof`, `Keywords`, and `Strategy`. These are set once by the coach and must not be rewritten or second-guessed by other agents.

**`JD proof` is a special case.** The coach populates it, but no writing agent reads it or uses it as input. Its sole purpose is to let {{USER_FIRST_NAME}} verify that the coach's Role emphasis interpretation is grounded in what the JD actually says — not fabricated. It is a transparency field, not a writing input.

## Dependencies

- **Reference files** in `references/`. All agents that write CV or cover letter content MUST read from this folder before producing any output. `01-candidate-rules.md` is the primary reference file and is mandatory for every writing task.
- **Notion** — read/write access to both databases. Configured in `.mcp.json`.
- **iCloud** — local filesystem storage for DOCX outputs. Files are saved via `cp` to the iCloud path, which syncs automatically. No MCP configuration needed — iCloud is a local folder, not a network service.
- **Job search MCPs** — Indeed, Dice, ZipRecruiter. Available to the employment coach. Configured in `.mcp.json`.
- **Desktop Commander** — file system operations. Configured in `.mcp.json`.
- **pandoc** — CLI tool for markdown → DOCX conversion. Must be installed separately (`brew install pandoc`).
- **python-docx** — Python library for subtitle update script. Must be installed separately (`pip3 install python-docx`).

See `CONNECTORS.md` for the full connector list and alternatives.

## Permissions

The pipeline runs bash commands and MCP tool calls at every step. Without pre-approved permissions, Claude Code will pause mid-run for approvals.

**After setup, add these to your `~/.claude/settings.json` under `permissions.allow`:**

```json
"permissions": {
  "allow": [
    "Bash(pandoc:*)",
    "Bash(python3:*)",
    "Bash(cp:*)",
    "Bash(ls:*)",
    "Bash(mkdir:*)",
    "mcp__notion__*",
    "mcp__desktop-commander__*"
  ]
}
```

The setup agent (`/cv-campaign:setup`) will generate the exact allow-list for your configuration.

## File naming

All files land in `{{ICLOUD_OUTPUT_PATH}}/cv-campaign-<YYYY-MM-DD>/`

- CV: `cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx` — lowercase, hyphens only
- Cover letter: `coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx`
- Reframe CV: `cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>.docx`
- Reviewer feedback: `feedback-<roletitle>-<company>-<monYYYY>.md` — same slug as the CV and cover letter
- Revision log (per role): `revision-log-<roletitle>-<company>-<monYYYY>.md` — same slug; contains CV changes and validation notes
- Revision log (per run): `revision-log-<YYYY-MM-DD>.md` — one per run; contains cross-run decisions and technical issues
- LinkedIn updates: `linkedin-updates-<YYYY-MM-DD>.md` — one file per run, not per role
- State file: `state.json`

Example: `cv-{{USER_LAST_NAME}}-head-of-marketing-acme-apr2026.docx` / `feedback-head-of-marketing-acme-apr2026.md` / `revision-log-head-of-marketing-acme-apr2026.md` / `revision-log-2026-05-16.md`

## Usage

**Run the full campaign:**
> Run CV campaign.

**Run the editing pipeline:**
> Edit CVs. / Run CV edits. / Process the Needs editing queue.

**Run market intelligence:**
> Run market intelligence. / Research my interested roles.

**Pitch a standalone tech writer role:**
> Pitch this tech writer job: [URL or description]

**Write CV and cover letter immediately for a single role (no Notion required):**
> /cv-campaign --now https://jobs.example.com/head-of-marketing
> I just found this job, write my CV now: [URL]
> [paste JD text] — write my CV for this

**Get coaching on a role or strategy question:**
> /cv-campaign --coach Should I apply to this Axonius role?
> /cv-campaign --coach What's my strongest angle for Head of PMM at a Series B?
> /cv-campaign --coach Help me decide between these two roles: [X] vs [Y]

**Check the quality of a CV or cover letter:**
> /cv-campaign --check [paste CV or cover letter + JD]

**Get a recruiter and hiring manager review:**
> /cv-campaign --review [paste CV or cover letter + JD]

**Write a cover letter only (no full pipeline):**
> /cv-campaign --write-letter [URL or paste JD]

**Check run status and file completeness:**
> /cv-campaign --status

## Execution rules

- Roles are processed one at a time, in priority order, through the full pipeline. Parallel execution across roles is available if {{USER_FIRST_NAME}} requests it.
- The coach fetches JDs as its first step — always. Roles it cannot access are dropped and logged.
- **Fabrication rule is absolute, including against reviewer pressure.** NO invented claims, no inferred experience. 
- Preserve the managed-vs-executed distinction in every bullet.
- No app names inside role bullets.
- All per-role outputs delivered together at the end via final chat delivery. No progressive output during processing.
- All files saved to iCloud via the `/tmp → iCloud output folder` copy protocol.
- Each Notion property is written once, by its designated owner. No duplication across fields.
- **Do NOT compact the conversation without telling {{USER_FIRST_NAME}} first.**
