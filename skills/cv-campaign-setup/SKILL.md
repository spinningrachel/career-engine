---
name: cv-campaign-setup
description: >
  Onboarding wizard for the cv-campaign plugin. Triggered when the user
  runs /cv-campaign:setup, says "set up the plugin", "start onboarding",
  "configure the plugin", "initialize my profile", "I just installed this",
  or any variant asking to get the plugin ready to use.
  Collects existing career materials, synthesizes framework.md, conducts
  a targeted interview to fill gaps, then configures job tracking and
  output paths. Run once; re-run any phase any time to update it.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
  - WebFetch
---

# cv-campaign Onboarding

This skill sets up the plugin for a new user. It builds the three reference files that all pipeline agents read before writing anything:

- `01-candidate-rules.md` — fabrication guards, attribution rules, framing constraints, contact details
- `02-candidate-background.md` — role facts, approved content, portfolio, Q&A answers
- `03-framework.md` — positioning, voice, methodology, domain narratives

**How onboarding works:** You send your existing career materials. The agent reads them and synthesizes `03-framework.md`. You review it and respond — with feedback or approval. That response triggers a targeted interview that fills gaps and captures what the materials didn't fully show. Integration (Notion, output path) comes after.

**Run order matters.** Phase 1 (identity) → Phase 2 (content submission) → Phase 3 (synthesis) → Phase 4 (review and interview) → Phase 5 (integration) → Phase 6 (permissions). Phases 5–6 can be deferred — the pipeline can run with Phases 1–4 complete.

---

## Pre-flight — check current state

Before doing anything, scan the three reference files for unfilled `{{...}}` placeholders:

```bash
grep -r "{{USER_" ${CLAUDE_PLUGIN_ROOT}/references/
```

- If all three files are fully configured: ask the user which phase they want to revisit.
- If partially complete: report which phases are done and which need work, then go to the first incomplete phase.
- If nothing is configured: start at Phase 1.

---

## Phase 1 — Identity and contact

**Purpose:** Powers the CV signature, agent instructions, and file naming. Nothing works correctly without this. Takes 2 minutes.

Ask for the following. Use the placeholder name as the prompt — "What's your `{{USER_FULL_NAME}}`?" reads naturally enough.

| Placeholder | What it's for |
|---|---|
| `{{USER_FULL_NAME}}` | Full name as it appears on CVs and cover letters |
| `{{USER_FIRST_NAME}}` | First name only — used throughout agent instructions |
| `{{USER_LAST_NAME}}` | Last name only — used in output file naming |
| `{{USER_EMAIL}}` | Email address |
| `{{USER_PHONE}}` | Phone number |
| `{{USER_LINKEDIN}}` | Full LinkedIn URL |
| `{{USER_WEBSITE}}` | Personal website or portfolio domain |
| `{{USER_LOCATION}}` | City, Country |
| `{{USER_CITIZENSHIP}}` | Citizenship or right to work |

Write answers into `01-candidate-rules.md` Section 8. Write `{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, and `{{USER_LAST_NAME}}` into every occurrence across all three reference files.

Confirm: "Done. Let's move to your career materials."

---

## Phase 2 — Content submission

**Purpose:** The agent builds your positioning framework and career profile from materials you already have — rather than asking you to describe everything from scratch.

Tell the user:

> "Send me whatever you have from the list below. The more you share, the better the output. I'll read everything and build your positioning framework from it. I will **not store your files** — I'll use them to synthesize your reference files and then they're gone. The only exception is cover letters: if you tell me they're good representations of your voice, I'll keep those in your delivered-letters folder as voice calibration anchors for future runs."

List of useful content and what each feeds:

| Content | What it feeds | Notes |
|---|---|---|
| Current CV(s) | `02-candidate-background.md` — role facts (company, dates, titles, metrics, scope) | Used for facts only. Your old CV bullet language is **not** treated as approved bullets — those emerge from pipeline iterations. |
| Approved sent cover letters | `delivered-letters/` folder — voice calibration | Only kept if you confirm they're good representations of your voice. Ask explicitly before storing. |
| LinkedIn export or profile text | `03-framework.md` — testimonials, voice samples, domain context | Not stored. |
| Performance reviews or peer feedback | `03-framework.md` — peer-attributed qualities, testimonials | Not stored. |
| Portfolio pieces or writing samples | `02-candidate-background.md` Section 10 — portfolio | Not stored after synthesis. |
| Old job descriptions you were hired for | `01-candidate-rules.md` — attribution rules, scope framing | Used to understand what was personal contribution vs. company-level. Not stored. |

Ask the user to send files. Wait for submission before proceeding.

---

## Phase 3 — Review and synthesize

**Purpose:** Read everything submitted and build `03-framework.md`. This is the agent's primary synthesis task — do it carefully.

### Cover letters — ask before storing

Before reading anything, ask:

> "You shared cover letters. Are these good representations of your voice — the kind of letters you'd be happy to send today? If yes, I'll keep them in your delivered-letters folder so future pipeline runs can use them for voice calibration. If no, I'll read them for context and then they're gone."

- If yes: copy approved cover letters to `${CLAUDE_PLUGIN_ROOT}/references/delivered-letters/`
- If no: read them for context only, do not store

### Read all submitted content carefully

Read every file. For each piece of content, note:
- Career history: companies, titles, dates, metrics, scope, what was built
- Voice: how the user writes, sentence patterns, vocabulary level, what they emphasise
- Positioning: what they claim as their core value, how they frame their work
- Domain depth: which verticals and sub-categories they have documented experience in
- Differentiators: what appears repeatedly as distinctive about their background
- Testimonials: any third-party quotes about their work
- Portfolio: specific work samples with descriptions and links

### Build `03-framework.md`

Fill in every section of `03-framework.md` from what the materials show. Where the materials provide clear evidence, write confident content. Where they are thin or unclear, write a best-effort draft and mark it `[REVIEW — limited evidence]` so the user knows to check it in Phase 4.

**Section-by-section guidance:**

**Category and market frame** — infer from the companies worked at, industries served, seniority of roles held. What professional category does the evidence point to?

**Voice and tone** — extract from cover letters (if approved) and LinkedIn writing. Note actual sentence patterns, vocabulary, what the user emphasises, how formal or informal. Pull 4–6 direct quotes for Voice samples. Use only documented quotes — never fabricate them.

**Core positioning statement** — synthesise from the career arc. Who hires this person, for what, and why them over alternatives? Draft from the evidence; mark as draft.

**Value pillars** — identify 2–3 recurring patterns of impact across the career. For each: what they do, what the proof is. Use specific companies and metrics from the CV.

**Professional methodology and POV** — extract from how the user describes their approach in cover letters, LinkedIn, or anywhere they explain how they work. If thin, leave placeholders.

**Domain depth** — map the career history to verticals. For each vertical: companies, what was done, what the proof point is.

**Proof points bank** — extract specific metrics and outcomes. Company → outcome → attribution (personal vs. company-level).

**ICP and target opportunities** — infer from the career stage, company sizes, and domains worked in. Draft; will be refined in the interview.

**Messaging** — draft based on the positioning. Leave as draft; will be refined.

**Taglines, elevator pitches, differentiators, competitive frame, anti-positioning** — draft from the synthesis. Mark all as `[DRAFT — confirm in interview]`.

Write the completed `03-framework.md` to the references folder.

---

## Phase 4 — Framework review and interview

### Share framework.md

Present `03-framework.md` to the user and say:

> "Here's your positioning framework, built from what you sent me. Review it — especially the sections marked `[REVIEW]` or `[DRAFT]`. When you're ready, tell me what needs changing or say it looks right. Either way, I'll follow up with a few questions to fill gaps and check things your materials didn't fully capture.
>
> **A note on your files:** I've used your submitted content to build this but have not stored it. [If cover letters were kept: "Your approved cover letters are in your delivered-letters folder."] Everything else has been read and synthesised — the original files are not in the plugin."

Wait for the user's response. Whether they give feedback or say it's fine, proceed to the interview.

### Update framework from feedback

If the user gave feedback, apply it to `03-framework.md` before proceeding.

### Interview — gap-filling and enrichment

The interview has two purposes: fill gaps the materials left, and surface things the user didn't think to volunteer.

**Run the interview as a natural conversation, not a form.** Ask 2–3 questions at a time, grouped by theme. Do not read out all questions at once. Adjust based on what the materials already covered — skip questions where you already have strong evidence.

**Track what's missing from each section of `03-framework.md` and `02-candidate-background.md`. Ask about the most important gaps first.**

Core areas to cover:

**Positioning and voice (if not clear from materials)**
- How would you describe what you do in one sentence — to a technical founder, not a recruiter?
- What's the problem you exist to solve that most people in your field don't solve as well?
- What would colleagues say about you that you'd never say about yourself?

**Career facts (for `02-candidate-background.md`)**
- For each major role: confirm title, dates, direct reports, key metrics, what you specifically built or changed
- Attribution check: for any significant outcome, ask "was that company-level or something you drove specifically?" — this shapes attribution rules in `01-candidate-rules.md`
- Consulting/fractional work: any client engagements not in the CV?

**Scope and framing (for `01-candidate-rules.md`)**
- Were there any outcomes in your CV that were team-delivered or company-level that you want to make sure agents don't overclaim? (e.g., "300% YoY growth" as a company metric vs. a marketing attribution)
- Any roles where the title understates the scope, or overstates it?
- Any engagement that was fractional/consulting that needs specific scope framing?

**Differentiators and positioning (for `03-framework.md`)**
- What's the one thing that makes your background genuinely unusual — that you'd have a hard time finding in another candidate?
- What have you worked on that most people in your field haven't touched?

**Target search (for `01-candidate-rules.md` Section 2)**
- What roles are you targeting — title, seniority, function?
- What company stage and size? Any strong preferences or hard nos?
- Geographic constraints or preferences?

**Enrichment probing — things users often don't volunteer**

Ask about these specifically if they haven't come up naturally:

- **Testimonials:** "Do you have any LinkedIn recommendations or client feedback we should add? Third-party quotes carry different weight than self-description."
- **Published work:** "Have you published articles, research papers, or significant public writing — even ghostwritten?"
- **Community and teaching:** "Are you active in any professional communities, do any mentoring, or hold any formal advisory roles?"
- **Voice samples:** "Is there anything you've said in an interview, recording, or conversation that captures how you think about your work? Even a rough quote is useful."
- **Anti-positioning:** "Is there anything you've been mistakenly credited for, or a claim that would be easy to make but isn't accurate? Better to document it now."

### After the interview — update reference files

**Update `03-framework.md`:** Apply all interview answers to the relevant sections. Remove all `[REVIEW]` and `[DRAFT]` markers from sections that are now fully confirmed.

**Populate `02-candidate-background.md`:**

For each role confirmed in the interview, write into Section 7:
```
### [Company] ([dates])
- Title: [answer]
- Reporting: [answer]
- Team: [answer]
- Key metrics: [answer]
- What was built: [summary from CV + interview]

Approved CV bullets:
[LEAVE EMPTY — approved bullets are populated through pipeline iterations, not setup]
```

**Important:** Do not populate approved bullets from the user's old CV. Old CV bullet language is raw material, not approved language. The approved bullets section starts empty for every company and fills in as the user runs the pipeline and locks bullets they're happy with.

Populate Section 10 (portfolio) from any portfolio materials submitted.
Populate Section 9 (testimonials) from LinkedIn recommendations or peer feedback confirmed in the interview.

**Update `01-candidate-rules.md`:**

Write attribution rules into Section 1 for any outcomes confirmed as company-level rather than personal contribution. Write framing rules for any scope limitations confirmed in the interview. Write the target role information into Section 2.

Confirm: "Your positioning framework, career background, and candidate rules are now configured. Let's set up your job tracking and output folder."

---

## Phase 5 — Job tracking and output

**Purpose:** The pipeline reads roles from a job tracking source and writes results back. This phase sets up the database and configures where it lives.

Ask: "How do you want to track your job applications? Options: **Notion** (recommended — full pipeline integration with writeback), **Google Sheets**, or **another platform**."

---

### Option A — Notion

1. Say: "Use this template — it has all the required columns and select values pre-configured:
   **[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**
   Click Duplicate, add it to your workspace, then come back."

2. Once they confirm it's set up, ask:
   - "Paste your database ID." (the 32-character string from the Notion URL — `notion.so/[workspace]/DATABASE_ID?v=...`)
   - "Do you have a filtered view you want to use? If so, paste the view ID too." (the `v=...` part of the URL)

3. Write the database ID to every `{{NOTION_DATABASE_ID}}` placeholder across all skill files.
4. Write the view ID to every `{{NOTION_VIEW_ID}}` placeholder (or leave placeholder if not provided).

5. Say: "**Important:** Do not rename the columns in your Notion database. The pipeline writes to them by exact name — renaming breaks the integration silently."

---

### Option B — Google Sheets

1. Say: "I'll create a CSV file with all the required column headers. You'll upload it to Google Sheets to create your tracking sheet with the correct structure.
   
   **A note on column names: do not rename them.** The pipeline writes to these columns by exact name. Renaming any column will break the integration silently."

2. Write a CSV file to `/tmp/cv-campaign-tracker.csv` containing only the header row with all required columns in order:

```
Company,Position,Job URL,Status,Priority,JD Body,Q&A,Page Body,Role emphasis,JD proof,Keywords,Strategy,Role Type,Relationship type,Gap handling,Role summary,Hiring Manager,Hiring manager's role,Manager role confirmed,Person who Advertised Role (if not Hiring Manager),No other Marketing roles employed by company,Landscape,Last Pipeline Run,Link to CV,Draft Directory,CV File Name,Letter File Name,Languages,Note
```

3. Tell the user: "Download this file and upload it to Google Sheets (File → Import → Upload). This creates your tracking sheet with all the required columns."

4. Provide the following prompt for them to run in a Google Sheets agent or Claude to set up data validation on the select columns:

```
Set up data validation (dropdown lists) on the following columns in my Google Sheet named "cv-campaign-tracker":

- Column "Status": allow only these exact values: Hold, Interested, CV Ready for Review, Applied, Researched, Needs editing
- Column "Priority": allow only these exact values: Highest, First, Second, Third, Fourth, Fifth
- Column "Role Type": allow multiple selections from: Builder, Scaler, Specialist, Leader
- Column "Relationship type": allow only these exact values: Full time, Part time, Temporary, Fractional/Consulting/Freelance, Reframe
- Column "Manager role confirmed": allow only these exact values: Yes, No; this is only a hypothesis
- Column "Languages": allow multiple selections from: English, Hebrew

These values must match exactly — they are hard-coded in the pipeline that reads this sheet.
```

5. Once the user has set up their sheet, ask: "Paste your Google Sheets URL." Write it to `.claude/settings.json` under `job_tracking.source`.

6. Say: "Note: in Google Sheets mode, the pipeline reads your roles but does not write results back to the sheet. Outputs (DOCX files and coach properties) go to your output folder only."

---

### Option C — Other platform

1. Say: "I'll give you the column schema and a prompt you can use to set up your database in [platform]."

2. Provide the same CSV header row as Option B.

3. Provide a prompt the user can adapt:

```
Create a database/table with the following columns. Do not rename them — they are referenced by exact name by an external pipeline.

Columns: Company, Position, Job URL, Status, Priority, JD Body, Q&A, Page Body, Role emphasis, JD proof, Keywords, Strategy, Role Type, Relationship type, Gap handling, Role summary, Hiring Manager, Hiring manager's role, Manager role confirmed, Person who Advertised Role (if not Hiring Manager), No other Marketing roles employed by company, Landscape, Last Pipeline Run, Link to CV, Draft Directory, CV File Name, Letter File Name, Languages, Note

Select column values (must match exactly):
- Status: Hold | Interested | CV Ready for Review | Applied | Researched | Needs editing
- Priority: Highest | First | Second | Third | Fourth | Fifth
- Role Type (multi-select): Builder | Scaler | Specialist | Leader
- Relationship type: Full time | Part time | Temporary | Fractional/Consulting/Freelance | Reframe
- Manager role confirmed: Yes | No; this is only a hypothesis
- Languages (multi-select): English | Hebrew
```

4. Once set up, ask for the access URL or connection details. Write to `.claude/settings.json` under `job_tracking.source`.

**Output folder**
Ask: "Where do you want your DOCX files saved?"
- Default: iCloud — ask them to confirm their iCloud path or provide a custom subfolder name
- Custom: any local absolute path

Write the path to every `{{ICLOUD_OUTPUT_PATH}}` placeholder across all skill files.

If cover letters were NOT kept during Phase 3, ask: "Do you have an existing folder of approved sent cover letters for voice calibration? If so, where is it?" Write the path to `{{ICLOUD_DELIVERED_LETTERS_PATH}}` if provided.

**CV template**
Ask: "Do you want to use the included CV template (`cv-template-default.dotx`) or provide your own `.dotx` file?"
- If own file: ask for the path → write to `{{CV_TEMPLATE_FILE}}` placeholders
- If default: write `${CLAUDE_PLUGIN_ROOT}/references/cv-template-default.dotx` to all `{{CV_TEMPLATE_FILE}}` placeholders

Confirm: "Phase 5 complete. Job tracking, output folder, and CV template are configured."

---

## Phase 6 — Permissions

**Purpose:** Without pre-approved permissions, Claude Code will pause mid-pipeline for approvals on every bash command and MCP call.

Read the current MCP tool IDs from `.claude/settings.json`. Generate the exact allow-list block for the user's `~/.claude/settings.json`:

```json
"permissions": {
  "allow": [
    "Bash(pandoc:*)",
    "Bash(python3:*)",
    "Bash(cp:*)",
    "Bash(ls:*)",
    "Bash(mkdir:*)",
    "Bash(cat:*)",
    "[NOTION_MCP_TOOL_ID]__*",
    "[DESKTOP_COMMANDER_MCP_TOOL_ID]__*",
    "WebFetch(*)",
    "WebSearch(*)"
  ]
}
```

Fill in the actual MCP tool IDs from the plugin's `.mcp.json` or settings. Present the block and say:

"Add this to your `~/.claude/settings.json` under the `permissions` key. If a permissions block already exists, merge the allow arrays."

Ask: "Have you added the permissions block? You can do this now and come back, or skip and add it before your first run."

Confirm: "Phase 6 complete. The pipeline will run without approval prompts."

---

## Verification

Run after Phases 1–5 are complete.

1. **Placeholder scan:** `grep -r "{{USER_" ${CLAUDE_PLUGIN_ROOT}/references/ | grep -v "{{USER_ANSWER_"` — report any identity or contact placeholders still unfilled
2. **Integration check:** Confirm the output folder exists. Confirm the CV template file exists at its configured path.
3. **Dependency check:** Run `pandoc --version` and `python3 -c "import docx"` — report if either is missing with install instructions (`brew install pandoc` / `pip3 install python-docx`)
4. **Framework check:** Confirm `03-framework.md` has no sections still marked `[REVIEW]` or `[DRAFT]`
5. **Summary:** Report which phases are complete and which are outstanding

If Phases 1–5 are complete and dependencies are installed:

"Onboarding complete. You're ready to run `/cv-campaign`. Before your first run: add roles to your Notion database (or CSV), set their Status to `Interested`, and run `/cv-campaign`. The pipeline will pick them up automatically."

---

## Style notes

- Direct and efficient. One theme of questions at a time.
- If the user says "skip" or "later" for anything, move on immediately and note it as outstanding.
- When building `03-framework.md`, be confident where the evidence is clear. Use `[DRAFT]` only where you are genuinely uncertain.
- Never fabricate voice samples, testimonials, or proof points. If the materials don't contain them, leave the placeholder.
- The interview is a conversation, not a form. Adjust based on what you already know from the materials.
