---
name: career-engine-setup
description: >
  Onboarding wizard for the career-engine plugin. Triggered when the user
  runs /career-engine:setup, says "set up the plugin", "start onboarding",
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

# Career Engine Onboarding

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill sets up the plugin for a new user. It builds the three reference files that all pipeline agents read before writing anything:

- `01-writing-rules.md` — fabrication guards, attribution rules, framing constraints, contact details
- `02-professional-background.md` — role facts, approved content, portfolio
- `03-framework.md` — positioning, voice, methodology, domain narratives

**Output target — the `career-data` skill, not in-plugin references (R-37).** Setup builds these files into the user's external `career-data` skill, not into the plugin's `references/`. Author the data files (`01/02/03`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx`) into a `career-data/` skill directory, then install it through the app: package it as a `.skill` and have the user upload it via **Settings → Capabilities → Skills** (see the design's Appendix A). Write the first backup export of `career-data` to the output folder. The plugin's in-plugin `references/` stay as blank `{{...}}` templates — never personalized.

**Placeholder resolution (single-build).** Identity and config values are NOT substituted into the plugin's agent/skill/reference files — that would personalize the shared build. They live in `career-data` and agents resolve them at runtime: identity from `career-data` `01-writing-rules.md` §8, output folder and CV template from the `career-data` config (see CLAUDE.md → *Placeholder resolution*). Every step below writes these values into `career-data`, never into plugin files.

**How onboarding works:** You send your existing career materials. The agent reads them and synthesizes `03-framework.md`. You review it and respond — with feedback or approval. That response triggers a targeted interview that fills gaps and captures what the materials didn't fully show. Integration (Notion, output path) comes after.

**Run order matters.** Phase 1 (identity) → Phase 2 (content submission) → Phase 3 (synthesis) → Phase 4 (review and interview) → Phase 5 (integration) → Phase 6 (permissions) → Phase 7 (job-preferences). Phases 5–7 can be deferred — the pipeline can run with Phases 1–4 complete.

**Onboarding can be paused and resumed.** The Phase 4 interview in particular can take time. If the user needs to stop, they can resume later by running `/career-engine:setup --phase 4`. The state of `03-framework.md` is preserved between sessions — sections already confirmed have no `[DRAFT]` or `[REVIEW]` markers; sections still needing work do. The pre-flight check uses this to report progress accurately.

---

## Pre-flight — check current state

Before doing anything, assess what has been completed:

1. Check whether `career-data` is installed and complete: locate the `career-data` skill, read `career-data-marker.json`, and confirm every file in its `expected_files` is present and non-empty. Absent → new user, run full setup. Present but incomplete → report which files are missing and offer to repair.

2. Check `03-framework.md` for `[DRAFT]` or `[REVIEW]` markers — these indicate sections the interview hasn't confirmed yet.

3. Check whether the output folder and database have been configured (Phase 5).

Report to the user:
- Which phases are complete
- Which phases are incomplete or partially done (including how many `[DRAFT]`/`[REVIEW]` sections remain in `03-framework.md`)
- Whether the integration is configured

If resuming a partial setup, skip completed phases and go directly to the first incomplete one. If the user says they want to continue a previous interview session, load `03-framework.md`, identify remaining `[DRAFT]`/`[REVIEW]` sections, and pick up the interview from there.

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
| `{{USER_PROFESSION}}` | Your profession or function (e.g., "marketing", "software engineering", "product design", "sales", "data science") |
| `{{USER_CITY}}` | City you are based in |
| `{{USER_COUNTRY}}` | Country you are based in |
| `{{USER_FUNCTION_SENIORITY_HIERARCHY}}` | Typical title tiers in your function from most senior to IC (e.g., for marketing: "CMO → VP → Head/Director → Manager → IC") |

Write these answers into `career-data` `01-writing-rules.md` Section 8 (identity), per the **Writing personal data** rule. Do NOT substitute `{{...}}` placeholders into the plugin's agent, skill, or reference files — the single build stays un-personalized; agents resolve identity values at runtime from `career-data` §8 (CLAUDE.md → *Placeholder resolution*).

---

### Language configuration

Ask:

> "What language(s) do your applications need to be in?
> (a) One language only — all applications in the same language
> (b) Two languages — some roles may need outputs in a second language (e.g., bilingual markets, international applications)
>
> If (a): what is your primary application language? (e.g., English, French, German, Spanish — or whatever you write in naturally)
> If (b): what is your primary language, and what is your second language?"

Based on their answers:

1. Write `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` (or `none`) into `01-writing-rules.md` Section 8.

2. Write `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` into `agents/localization.md` and `skills/localization/SKILL.md` (replacing placeholders).

3. **If either language is right-to-left (RTL)** — this includes Hebrew, Arabic, Persian/Farsi, Urdu, and others:
   > ⚠️ **RTL template required.** RTL text in a left-to-right Word template will render incorrectly — characters appear in the wrong order and alignment breaks. You will need a separate `.dotx` template configured for right-to-left layout before running the pipeline for RTL-language roles. See `skills/career-engine-export/SKILL.md` for template setup instructions.

4. **Database reminder:** Tell the user:
   > "Add all languages you configured to the **Languages** column in your Notion (or tracking) database for each role. The pipeline reads this column to decide whether to run localization. Use the exact values you configured: `{{USER_DEFAULT_LANGUAGE}}`, `{{USER_SECOND_LANGUAGE}}` (or both). A role with Languages = `{{USER_DEFAULT_LANGUAGE}}` only gets one set of outputs. A role with Languages = `{{USER_DEFAULT_LANGUAGE}}, {{USER_SECOND_LANGUAGE}}` gets both."

5. **If the user has a second language:** update `skills/localization/SKILL.md` per the setup instruction at the bottom of its Opening section — confirm the Default Language and Second Language columns reflect the user's configured languages. See that skill for the exact algorithm.

---

Confirm: "Done. Let's move to your career materials."

---

## Phase 2 — Content submission

**Purpose:** The agent builds your positioning framework and career profile from materials you already have — rather than asking you to describe everything from scratch.

Tell the user:

> "Send me whatever you have from the list below. The more you share, the better the output. I'll read everything and build your positioning framework from it. I will **not store your files** — I'll use them to synthesize your reference files and then they're gone. The only exception is cover letters: if you tell me they're good representations of your voice, I'll add them to the plugin's delivered-letters archive (`references/delivered-letters/`, cap 6) as voice calibration anchors for future runs."

List of useful content and what each feeds:

| Content | What it feeds | Notes |
|---|---|---|
| Current CV(s) | `02-professional-background.md` — role facts (company, dates, titles, metrics, scope) | Used for facts only. Your old CV bullet language is **not** treated as approved bullets — those emerge from pipeline iterations. |
| Approved sent cover letters | `references/delivered-letters/` — the in-plugin voice-calibration archive (cap 6) | Only kept if you confirm they're good representations of your voice. Ask explicitly before storing; store via the letter-writer Option 3 entry format and update INDEX.md. |
| **LinkedIn profile PDF export** ("Save to PDF" on your own profile) | `references/linkedin-profile.md` — **stored as a permanent reference.** Every LinkedIn recommendation the plugin produces (the per-run LinkedIn updates file, the LinkedIn coach) analyses against this snapshot. Also feeds `03-framework.md` — testimonials, voice samples, domain context. | **Ask for this explicitly — it is the one item on this list to actively request, not just accept.** Skippable if the user declines: LinkedIn outputs run in fallback mode (raw signals, no profile analysis) until provided. Tell them: "You can add it any time later — export the PDF and say 'update my references'." A fresh export replaces the snapshot wholesale whenever they change their profile. |
| Performance reviews or peer feedback | `03-framework.md` — peer-attributed qualities, testimonials | Not stored. |
| Portfolio pieces or writing samples | `02-professional-background.md` Section 10 — portfolio | Not stored after synthesis. |
| Old job descriptions you were hired for | `01-writing-rules.md` — attribution rules, scope framing | Used to understand what was personal contribution vs. company-level. Not stored. |

Ask the user to send files. Wait for submission before proceeding.

---

## Phase 3 — Review and synthesize

**Purpose:** Read everything submitted and build `03-framework.md`. This is the agent's primary synthesis task — do it carefully.

### Cover letters — ask before storing

Before reading anything, ask:

> "You shared cover letters. Are these good representations of your voice — the kind of letters you'd be happy to send today? If yes, I'll add them to the plugin's delivered-letters archive so every future run can calibrate against them. If no, I'll read them for context and then they're gone."

- If yes: store each approved letter in `references/delivered-letters/` using the letter-writer Option 3 entry format (one file per letter, full text exactly as sent, metadata header) and update `INDEX.md`. Respect the cap of 6.
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

**Career-shift posture** — **never infer this silently and never leave it confident.** A career history says nothing reliable about appetite for a shift — a CV full of one function reveals nothing about whether the user *wants* a different one. Write only what the evidence implies (e.g., a fractional/consulting track record implies openness to contract work in the interim; repeated function changes may imply shift appetite) and **always mark the section `[DRAFT — confirm in interview]`** regardless of how strong the evidence seems. The Phase 4 posture questions are always asked and are the only thing that confirms this section.

**Messaging** — draft based on the positioning. Leave as draft; will be refined.

**Taglines, elevator pitches, differentiators, competitive frame, anti-positioning** — draft from the synthesis. Mark all as `[DRAFT — confirm in interview]`.

Write the completed `03-framework.md` to the references folder.

---

## Phase 4 — Framework review and interview

### Share framework.md

Present `03-framework.md` to the user and say:

> "Here's your positioning framework, built from what you sent me. Review it — especially the sections marked `[REVIEW]` or `[DRAFT]`. When you're ready, tell me what needs changing or say it looks right. Either way, I'll follow up with a few questions to fill gaps and check things your materials didn't fully capture.
>
> **A note on your files:** I've used your submitted content to build this but have not stored it. [If cover letters were kept: "Your approved cover letters are in the plugin's delivered-letters archive (`references/delivered-letters/`)."] Everything else has been read and synthesised — the original files are not in the plugin."

Wait for the user's response. Whether they give feedback or say it's fine, proceed to the interview.

### Update framework from feedback

If the user gave feedback, apply it to `03-framework.md` before proceeding.

### Interview — gap-filling and enrichment

The interview has two purposes: fill gaps the materials left, and surface things the user didn't think to volunteer.

**Run the interview as a natural conversation, not a form.** Ask 2–3 questions at a time, grouped by theme. Do not read out all questions at once. Adjust based on what the materials already covered — skip questions where you already have strong evidence.

**Track what's missing from each section of `03-framework.md` and `02-professional-background.md`. Ask about the most important gaps first.**

Core areas to cover:

**Voice, tone, and writing preferences (always ask — even if materials were provided)**

These questions cannot be reliably inferred from a CV. They shape how every letter sounds and how agents calibrate register. Ask all of them.

- How do you want to come across in a cover letter — formal and structured, or warm and direct? Or somewhere specific between those?
- Short punchy sentences, or longer flowing ones? Or does it depend on the audience?
- Is there anything that drives you absolutely crazy in AI-generated writing — phrases, structures, tones you'd never use?
- How do you talk about your work when you're explaining it to someone you respect, not selling yourself? (A quote or example if they have one.)
- Are there any words or phrases you genuinely use and want preserved — not polished away?
- How do you want to sound to a technical founder vs. a senior recruiter vs. a VP of Sales? Are those registers the same for you, or different?

Write the answers into `03-framework.md` §Voice and tone and §Voice samples. If the user provides actual quotes or phrases, capture them verbatim.

**Voice preferences never silently modify documented rules.** These answers refine register, vocabulary, and style — they do not weaken or create exceptions to any documented writing rule or prohibition (in `01-writing-rules.md`, the cover-letter skill, the humanizer, or cv-writing). If an answer conflicts with a documented behavior (e.g., the user says they love em dashes, or wants tricolons everywhere), surface the conflict and ask whether they **explicitly reject that specific documented behavior**. Only an explicit rejection changes a rule — write the change into the rule's home file and note it; never infer a rule change from a preference.

**Positioning and voice (if not clear from materials)**
- How would you describe what you do in one sentence — to a technical founder, not a recruiter?
- What's the problem you exist to solve that most people in your field don't solve as well?
- What would colleagues say about you that you'd never say about yourself?

**Career facts (for `02-professional-background.md`)**
- For each major role: confirm title, dates, direct reports, key metrics, what you specifically built or changed
- Attribution check: for any significant outcome, ask "was that company-level or something you drove specifically?" — this shapes attribution rules in `01-writing-rules.md`
- Consulting/fractional work: any client engagements not in the CV?

**Scope and framing (for `01-writing-rules.md`)**
- Were there any outcomes in your CV that were team-delivered or company-level that you want to make sure agents don't overclaim? (e.g., "300% YoY growth" as a company metric vs. a marketing attribution)
- Any roles where the title understates the scope, or overstates it?
- Any engagement that was fractional/consulting that needs specific scope framing?

**Differentiators and positioning (for `03-framework.md`)**
- What's the one thing that makes your background genuinely unusual — that you'd have a hard time finding in another candidate?
- What have you worked on that most people in your field haven't touched?

**Target search (for `01-writing-rules.md` Section 2)**
- What roles are you targeting — title, seniority, function?
- What company stage and size? Any strong preferences or hard nos?
- Geographic constraints or preferences?

**Career-shift posture (for `03-framework.md` §Career-shift posture — always ask, like the voice questions; appetite for a shift cannot be inferred from materials)**
- Beyond your established function, how do you feel about career-shift roles — not open, open case-by-case, or is a shift actually a primary goal of this search?
- If open or pursuing: which directions interest you (role types, functions), and what does a shift role need to offer — seniority, scope, specific conditions — for you to want it?
- Anything off-limits — functions or transitions you never want agents to propose or emphasize?

Write the answers into `03-framework.md` §Career-shift posture and remove its `[DRAFT]` marker. Also capture current employment status and search mode (full-time vs. contract/freelance in the interim) in the same section if it surfaced here or anywhere in the interview.

**Enrichment probing — things users often don't volunteer**

Ask about these specifically if they haven't come up naturally:

- **Testimonials:** "Do you have any LinkedIn recommendations or client feedback we should add? Third-party quotes carry different weight than self-description."
- **Published work:** "Have you published articles, research papers, or significant public writing — even ghostwritten?"
- **Community and teaching:** "Are you active in any professional communities, do any mentoring, or hold any formal advisory roles?"
- **Voice samples:** "Is there anything you've said in an interview, recording, or conversation that captures how you think about your work? Even a rough quote is useful."
- **Anti-positioning:** "Is there anything you've been mistakenly credited for, or a claim that would be easy to make but isn't accurate? Better to document it now."

### After the interview — update reference files

**Update `03-framework.md`:** Apply all interview answers to the relevant sections. Remove all `[REVIEW]` and `[DRAFT]` markers from sections that are now fully confirmed.

**Populate `02-professional-background.md`:**

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

**Update `01-writing-rules.md`:**

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

3. Write the database ID as `notion_database_id` in the career-data config (`${CAREER_DATA}/references/pipeline-preferences.json`). If the user gave a Needs-Editing view URL, write it as `notion_needs_editing_view_url`. Do NOT substitute `{{NOTION_DATABASE_ID}}` into plugin files — every skill resolves it from the config at runtime (R-38).
4. Write the view ID to every `{{NOTION_VIEW_ID}}` placeholder (or leave placeholder if not provided).

5. Say: "**Important:** Do not rename the columns in your Notion database. The pipeline writes to them by exact name — renaming breaks the integration silently."

---

### Option B — Google Sheets

1. Say: "I'll create a CSV file with all the required column headers. You'll upload it to Google Sheets to create your tracking sheet with the correct structure.
   
   **A note on column names: do not rename them.** The pipeline writes to these columns by exact name. Renaming any column will break the integration silently."

2. Write a CSV file to `/tmp/career-engine-tracker.csv` containing only the header row with all required columns in order:

```
Company,Position,Job URL,Status,Priority,JD Body,Why I Want This Role,Role emphasis,JD proof,Keywords,Strategy,Role Type,Relationship type,Gap handling,Role summary,Hiring Manager's Name,Hiring manager's role,Manager role confirmed,Person who Advertised Role (if not Hiring Manager),No incumbents in this function,Landscape,First Advertised,Last Pipeline Run,Link to CV,Draft Directory,CV File Name,Letter File Name,Languages,Edit type,Note
```

3. Tell the user: "Download this file and upload it to Google Sheets (File → Import → Upload). This creates your tracking sheet with all the required columns."

4. Provide the following prompt for them to run in a Google Sheets agent or Claude to set up data validation on the select columns:

Before giving this prompt to the user, substitute `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` with the actual values configured in Phase 1. If the user is single-language, omit `{{USER_SECOND_LANGUAGE}}` from the Languages row entirely.

```
Set up data validation (dropdown lists) on the following columns in my Google Sheet named "career-engine-tracker":

- Column "Status": allow only these exact values: Hold, Interested, CV Ready for Review, Applied, Researched, Needs editing
- Column "Priority": allow only these exact values: Highest, First, Second, Third, Fourth, Fifth
- Column "Role Type": allow multiple selections from: Builder, Scaler, Specialist, Leader
- Column "Relationship type": allow only these exact values: Full time, Part time, Temporary, Fractional/Consulting/Freelance
- Column "Manager role confirmed": allow only these exact values: Yes, No; this is only a hypothesis
- Column "Languages": allow multiple selections from: {{USER_DEFAULT_LANGUAGE}}, {{USER_SECOND_LANGUAGE}}
  (If single-language, allow only: {{USER_DEFAULT_LANGUAGE}})
- Column "Edit type": allow only these exact values: CV, Letter, Both

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

Columns: Company, Position, Job URL, Status, Priority, JD Body, Why I Want This Role, Role emphasis, JD proof, Keywords, Strategy, Role Type, Relationship type, Gap handling, Role summary, Hiring Manager's Name, Hiring manager's role, Manager role confirmed, Person who Advertised Role (if not Hiring Manager), No incumbents in this function, Landscape, First Advertised, Last Pipeline Run, Link to CV, Draft Directory, CV File Name, Letter File Name, Languages, Edit type, Note

Select column values (must match exactly):
- Status: Hold | Interested | CV Ready for Review | Applied | Researched | Needs editing
- Priority: Highest | First | Second | Third | Fourth | Fifth
- Role Type (multi-select): Builder | Scaler | Specialist | Leader
- Relationship type: Full time | Part time | Temporary | Fractional/Consulting/Freelance
- Manager role confirmed: Yes | No; this is only a hypothesis
- Languages (multi-select): {{USER_DEFAULT_LANGUAGE}} | {{USER_SECOND_LANGUAGE}}
  (If single-language, only: {{USER_DEFAULT_LANGUAGE}})
- Edit type: CV | Letter | Both
```

4. Once set up, ask for the access URL or connection details. Write to `.claude/settings.json` under `job_tracking.source`.

**Output folder**
Ask the user for their output folder path. This is where all pipeline output (CVs, cover letters, feedback files) will be saved. (Voice-calibration letters live inside the plugin at `references/delivered-letters/` — not in the output folder.)

Write the path as `output_folder` in `${CAREER_DATA}/references/pipeline-preferences.json` (the career-data config). Do NOT substitute `{{OUTPUT_FOLDER}}` into plugin files — the orchestrator resolves it from the config at runtime (R-38).

**CV template**
Ask: "Do you want to use the included CV template (`cv-template-default.dotx`) or provide your own `.dotx` file?"
- If own file: copy it into `career-data/references/` and record it as `cv_template` (a path relative to `career-data`, e.g. `references/<their-dotx>`) in the career-data config (`pipeline-preferences.json`). The orchestrator resolves `{{CV_TEMPLATE_FILE}}` from there at runtime (R-38).
- If default: record `cv_template` as `references/cv-template-default.dotx` in the career-data config (ship the default template into `career-data/references/` too, or the orchestrator falls back to the plugin's `${CLAUDE_PLUGIN_ROOT}/references/cv-template-default.dotx`). No plugin-file substitution.

**Draft Directory link base**
Ask: "Do you use a cloud file-share or file-browser app (e.g. Anchorpoint, Dropbox, Google Drive) that produces a stable folder URL pointing to your output folder? If yes, paste the base URL up to (and including) the separator before the date folder. If not, answer `skip`."

Examples of the expected format (the URL must end just before the date-folder segment):
- Anchorpoint: `https://app.anchorpoint.app/.../<workspace>/files/<path-to-output-folder>/`
- iCloud web share: share the output folder once; the link base is the part before the date-folder portion
- Answer `skip` if you don't use a cloud file browser or don't want Notion links

- Write the answer (or the literal word `skip`) as `draft_dir_url_base` in the career-data config. No plugin-file substitution (R-38).
- When the value is `skip`, the pipeline leaves the `Draft Directory` Notion property empty.

**Output directory prefix (optional)**
The pipeline creates a run folder named `<prefix>-YYYY-MM-DD` inside your output folder. Default prefix is `applications` (e.g. `applications-2026-06-15`). If you want a different name (e.g. `jobs`, `cv-runs`, `pipeline`), provide it — otherwise leave blank to use the default.
- Write the prefix (or omit the key to use the default `applications`) as `output_dir_prefix` in the career-data config.

**Default language**
Ask: "What is your primary language for CVs and cover letters? (e.g. `English`, `Hebrew`, `French`) This is used when the Notion row's `Languages` field is empty — the pipeline will produce output in this language only."
- Write the answer as `default_language` in the career-data config. If the user doesn't answer or is unsure, write `English`.

**Gap handling**
Ask: "Should the pipeline run gap analysis for every role? Gap handling identifies where your background doesn't fully match the JD and gives the coach and writers a strategy for handling each gap.

- **Enable (recommended if unsure):** The coach identifies and documents gaps for every role. You can suppress it for a specific role at any time by adding 'no gap handling' to your prompt when starting a run.
- **Disable:** Gap handling is skipped entirely for every run. Strategy and framing only — faster, but no gap analysis.

If you're not sure, leave it enabled. You can always turn it off per-role when it isn't relevant."

- Write the gap-handling choice into `${CAREER_DATA}/references/pipeline-preferences.json` **alongside** every other key set in this phase — one career-data config file (readable everywhere, survives upgrades). The complete file (R-38):
  ```json
  {
    "gap_handling": "enabled",
    "output_folder": "<the absolute path the user gave>",
    "cv_template": "references/<their-dotx-or-cv-template-default.dotx>",
    "notion_database_id": "<32-char DB id, or empty for non-Notion trackers>",
    "draft_dir_url_base": "<cloud-share base URL, or skip>",
    "output_dir_prefix": "applications",
    "default_language": "English",
    "word_templates_path": "<Hebrew .dotx templates dir, or empty>",
    "notion_needs_editing_view_url": "<Needs-Editing view URL, or empty>"
  }
  ```
  (`gap_handling` is `"enabled"`/`"disabled"`; `output_dir_prefix` defaults to `"applications"` if omitted.) **Required for any run:** `output_folder`, `cv_template`; **also required for Notion trackers:** `notion_database_id`. The orchestrator and standalone entry skills resolve every `{{CONFIG}}` placeholder from this file and stop if a required key is missing. Never substitute any of these into plugin files.
  (or `"disabled"`, matching the user's choice). Preserve any other keys already present in the file.
- Apply the **Writing personal data** rule: in Claude Code write `career-data` directly; in Cowork stage the change and emit the Appendix-A handoff. Refresh the `career-data` backup export after a direct write.
- Do NOT write this preference to `~/.claude/settings.json` — that location is reachable only from the user's own machine and silently falls back to the default everywhere else. The pipeline still reads it as a legacy fallback, but `career-data` is the authority.
- Verify by reading the file back and confirming the value matches the user's choice.

Confirm: "Phase 5 complete. Job tracking, output folder, CV template, and gap handling preference are configured."

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

**Token usage tracking (optional but recommended):**

The pipeline tracks actual token consumption per run. Each run writes a `run-metrics-<date>.json` file to your output folder with structural metrics (roles processed, agents invoked). A Stop hook then fills in the real token counts and an estimated cost.

The hook ships with the plugin and **registers itself** via `hooks/hooks.json`, so on a current Claude Code there is nothing to configure — confirm by checking that `run-metrics-*.json` files show numeric `token_counts` after a run (not `"pending"` or `"unknown"`).

It reads counts from the session transcript and every subagent transcript (not from the hook payload, which carries no token data — R-40), and writes them into the `run-metrics` file the run created this session.

**Only if your Claude Code version does not auto-load plugin hooks**, add the block manually to `~/.claude/settings.json`, replacing `${CLAUDE_PLUGIN_ROOT}` with your plugin install path (shown in Claude Code's plugin settings):

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

Ask: "Token tracking is built in and self-registering. Want me to verify it's firing, or generate the manual hook block as a fallback?"

Confirm: "Phase 6 complete. The pipeline will run without approval prompts."

---

## Phase 7 — Job-preferences configuration

**Purpose:** Some job searches involve geographic friction — applying internationally, working through recruiters, or submitting through platforms with strict formatting rules. This phase configures rules to handle those situations correctly. **Skip this phase entirely if the user is applying only to roles in the country they live in, in one language, submitted directly by themselves.**

Ask: "Does your job search involve any of the following? Say 'none' to skip this phase entirely.

1. Applications submitted through a recruiter or agency (you won't see the JD before they do)
2. Applying to roles in a country or market different from where you're based
3. Platform submissions (LinkedIn Easy Apply, Workday, Greenhouse) where formatting and length rules differ from a direct application
4. Applications in a language other than your primary language

If none of these apply, say 'none' and I'll skip to verification."

**If none apply:** confirm and move on. No job-preferences rules are needed for application submission.

**If any apply:** present the default job-preferences rules and ask whether they are appropriate:

---

**Default job-preferences rules (present these to the user):**

> 1. **Recruiter-submitted applications:** Remove all first-person pronouns from the CV (no "I", "my", "me"). Use action verb openings instead. Cover letters may retain first person — confirm with the recruiter.
> 2. **Remote location:** If the role lists a country/city as required and you are remote, add "(Remote)" after your location in the contact header. Do not fabricate a local address.
> 3. **Platform submissions:** Respect character or word limits if stated. Where a rich-text letter is not accepted, omit the cover letter rather than pasting into a plain-text field.
> 4. **Language:** If a role's `Languages` field includes a second language, run the localization agent after the English pipeline. The localized output is the submission copy.

---

Ask: "Do these rules match how you work, or do you need to change any of them? You can also add rules for contexts not listed here."

If the user confirms the defaults: write them to a `remote-compat` block in `.claude/settings.json` as:
```json
"remote_compat": {
  "remove_first_person_cv": true,
  "add_remote_location_label": true,
  "omit_letter_on_plain_text_platforms": true
}
```

If the user changes or adds rules: capture the custom rules in plain language and write them to `references/01-writing-rules.md` under a new section **§ Job-preferences rules**. Also write any boolean flags that changed to `.claude/settings.json`.

Confirm: "Phase 7 complete. Job-preferences rules are configured."

---

## Pipeline Orientation

Before completing onboarding, walk the user through how the pipeline works. Present this as a briefing, not a list to read.

---

### The two pipelines

**New Application pipeline** (`/career-engine` or `/career-engine`)
The main pipeline. Picks up all roles in your tracking database with Status = `Interested`, and for each one:
1. Coach analysis — reads the JD, writes Role emphasis, Strategy, Keywords, Gap handling
2. CV writer — drafts a tailored CV
3. Gatekeeper — checks the CV for rule violations
4. Recruiter + hiring manager review — evaluates the CV
5. Cover letter writer — writes the letter (if Why I Want This Role is filled in)
6. Cover letter gatekeeper + recruiter/HM review
7. Humanizer — removes AI writing patterns from the letter
8. Export — produces DOCX files

**Edit pipeline** (`/career-engine --edit`)
For roles where you already have a CV and/or letter and want targeted revisions. Set `Edit type` to `CV`, `Letter`, or `Both` in your tracking database before running. Only runs the relevant sub-pipeline for each role.

---

### What is mandatory for each pipeline

| Input | New Application pipeline | Edit pipeline |
|---|---|---|
| Job URL or JD Body | Required — pipeline cannot run without one | Required |
| Status = Interested | Required | Status = any active status |
| Edit type field | Not used | Required — CV / Letter / Both |
| Why I Want This Role | **Required for a cover letter.** If empty, CV is produced but the letter step is skipped entirely. | Required if Edit type = Letter or Both |

---

### Why I Want This Role — what "good" looks like

This field is the only source the letter-writer uses for the opener. The opener is the most important paragraph in the letter — it is what makes a letter yours rather than a template. The agent cannot invent your motivation, your specific reaction, or your angle on this company. If it does, that is fabrication.

**Good:** Specific. Your actual reaction when you read the JD. What you noticed, what excited you, what connected to something you've done or want to do. A few sentences is enough. Examples of what works:
- "The thing that grabbed me was that they're building agentic SecOps — I spent two years marketing exactly this layer and I've been watching this space evolve. I want to be the person building the story for the next platform."
- "I daydream about consumer campaigns. I've spent my whole career in B2B and I'm genuinely ready to apply what I know to products people actually want."
- "I worked at [Company] for five years and I know exactly how the enterprise buying cycle moves. This role is why I'd come back."

**Not enough:** "I think this role is a great fit." / "I'm excited about this opportunity." / "This company does interesting work." These give the agent nothing to work from. The letter will be a placeholder until you fill in more.

**The hard rule:** If Why I Want This Role is empty when the pipeline runs, the cover letter step is skipped. The agent will not generate motivation on your behalf — that would not be your letter. Fill in this field before running the pipeline for any role where you want a cover letter.

---

Present this to the user and ask: "Any questions before we do a final verification check?"

---

## Verification

Run after Phases 1–5 are complete.

1. **Placeholder scan:** `grep -r "{{USER_" ${CLAUDE_PLUGIN_ROOT}/references/ | grep -v "{{USER_ANSWER_"` — report any identity or contact placeholders still unfilled
2. **Integration check:** Confirm the output folder exists. Confirm the CV template file exists at its configured path.
3. **Dependency check:** Run `pandoc --version` and `python3 -c "import docx"`. If either is missing, ask the user: "pandoc [or python-docx] is not installed. Want me to install it for you?" If yes, run `brew install pandoc` (macOS) or `pip3 install python-docx` as appropriate using Bash. If the user is on Linux or Windows, ask them to confirm their system so you can use the right package manager command.
4. **Framework check:** Confirm `03-framework.md` has no sections still marked `[REVIEW]` or `[DRAFT]`
5. **Summary:** Report which phases are complete and which are outstanding

If Phases 1–5 are complete and dependencies are installed:

"Onboarding complete. You're ready to run `/career-engine`. Before your first run:

- Add roles to your Notion database (or CSV) and set their Status to `Interested`.
- **Why I Want This Role:** For each role you want a cover letter for, fill in the `Why I Want This Role` field in Notion before running the pipeline. Write your genuine motivation — a sentence or two is enough. If this field is empty when the pipeline runs, the cover letter will be skipped and only the CV will be delivered. The pipeline will never generate this for you.
- **Edit type (for editing runs):** When using the edit pipeline (`/career-engine --edit`), set the `Edit type` field to `CV`, `Letter`, or `Both` for each role before running. Roles without this field set will be skipped.
- **Gap handling:** Configured in Phase 5. If enabled, you can suppress it for a specific role by adding "no gap handling" to your prompt when starting a run.

Run `/career-engine` to start. The pipeline will pick up all `Interested` roles automatically."

---

## Style notes

- Direct and efficient. One theme of questions at a time.
- If the user says "skip" or "later" for anything, move on immediately and note it as outstanding.
- When building `03-framework.md`, be confident where the evidence is clear. Use `[DRAFT]` only where you are genuinely uncertain.
- Never fabricate voice samples, testimonials, or proof points. If the materials don't contain them, leave the placeholder.
- The interview is a conversation, not a form. Adjust based on what you already know from the materials.
