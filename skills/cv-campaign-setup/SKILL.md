---
name: cv-campaign-setup
description: >
  First-run setup wizard for the cv-campaign plugin. Triggered when the user
  runs /cv-campaign:setup, says "set up the plugin", "configure the plugin",
  "initialize my profile", "I just installed this", or any variant asking to
  get the plugin ready to use. Walks the user through populating all reference
  files, configuring job tracking and output paths, and generating the required
  permissions. Run once; re-run any time to update a section.
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

# cv-campaign Setup Wizard

This skill configures the plugin for a new user. It replaces `{{...}}` placeholders across three reference files with the user's real data, configures job tracking and output paths, and generates the permissions block for `~/.claude/settings.json`.

**Run order matters.** Complete Phase 1 before Phase 2. Phases 3–5 can be deferred and completed in a later session — the plugin can run a limited pipeline with only Phases 1–2 done.

---

## Pre-flight — scan the current state

Before asking any questions, read these three files and identify which `{{...}}` placeholders are still unfilled:

```
${CLAUDE_PLUGIN_ROOT}/references/who-rachel-is.md
${CLAUDE_PLUGIN_ROOT}/references/framework.md
${CLAUDE_PLUGIN_ROOT}/references/qa-bank.md
```

Report to the user:
- Which phases are complete (no placeholders remaining in that phase's sections)
- Which phases are incomplete (placeholders still present)
- Whether the integration is configured (iCloud/output path set, job tracking set)

If resuming a partial setup, skip completed phases and go directly to the first incomplete one.

---

## Phase 1 — Identity and contact (required)

**Purpose:** Powers the CV signature, agent instructions, and file naming across every pipeline run. Nothing works correctly without this.

Ask the following. Use the placeholder name as the question prompt — "What is your `{{USER_FULL_NAME}}`?" reads naturally enough.

| Placeholder | Question |
|---|---|
| `{{USER_FULL_NAME}}` | Full name as it will appear on CVs and cover letters |
| `{{USER_FIRST_NAME}}` | First name only (used throughout agent instructions) |
| `{{USER_LAST_NAME}}` | Last name only (used in file naming: `cv-{{USER_LAST_NAME}}-...`) |
| `{{USER_EMAIL}}` | Email address |
| `{{USER_PHONE}}` | Phone number |
| `{{USER_LINKEDIN}}` | LinkedIn URL (full URL, not just username) |
| `{{USER_WEBSITE}}` | Personal website or portfolio domain |
| `{{USER_PORTFOLIO_URL}}` | Full portfolio URL if different from website |
| `{{USER_LOCATION}}` | City, Country |
| `{{USER_CITIZENSHIP}}` | Citizenship / right to work (e.g., "US/Israeli citizenship", "EU citizen") |

After collecting all answers, write them into `who-rachel-is.md` Section 8 (Reference Details — Contact and Portfolio) by replacing each placeholder with the user's response.

Also write `{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, and `{{USER_LAST_NAME}}` into every other occurrence across all three reference files. These appear throughout agent instructions and must be consistent.

Confirm: "Phase 1 complete. Your identity and contact details are set across all reference files."

---

## Phase 2 — Career history (required for CV pipeline)

**Purpose:** Every CV bullet, proof point, and strategic property the agents produce must trace to this data. Without it, agents will fabricate.

Work through `who-rachel-is.md` Section 7 (Role Facts) systematically. For each role slot:

1. Ask: "Let's add your most recent role. What company, title, and dates?"
2. Ask for: reporting structure, team size, key metrics, 2–3 bullet-point achievements
3. Confirm the scope framing: was this a founding/solo role, a team leadership role, or a specialist IC role?
4. Ask: "Do you have any consulting or fractional work to include?"

Continue until the user has entered at least **two full-time roles** — the minimum for the pipeline to produce credible output.

For each role, populate the structured template in Section 7:
```
### {{USER_COMPANY_X}} ({{USER_COMPANY_X_DATES}})
- Title: [answer]
- Reporting: [answer]
- Team: [answer]
- Key metrics: [answer]
Approved CV bullets:
- [bullet 1]
- [bullet 2]
```

Also ask:
- Education: degree(s) and institution(s) → write into Section 8
- Languages → write into Section 8
- Core skills summary → write into Section 8

**Attribution rules — ask before writing:**
For each role, ask: "Are there any outcomes from this role that belong to the company rather than to you personally?" Examples: company-level ARR growth, team-delivered outputs the user managed but didn't execute. Write these as attribution rules in Section 1.

Confirm: "Phase 2 complete. Role facts for N roles are set. Agents will draw from these and will not fabricate beyond them."

---

## Phase 3 — Positioning and voice (recommended before first run)

**Purpose:** The framework.md file powers every cover letter opener, strategic argument, and voice calibration. Skipping it means generic output.

Work through `framework.md` in order. For each section, read the placeholder aloud and ask the user to fill it in. Group related placeholders:

**Category and market frame (10 min)**
- What professional category do you compete in? What's your target company profile?
- How would you describe your market context in 2–3 sentences?
- What is your positioning in one sentence — the 10-word version?

**Core positioning statement (15 min)**
- Walk the user through: who hires you → for what → the how → what makes you different → your three commercial anchors
- Draft the positioning statement together, then ask for approval

**Value pillars (20 min)**
- Three pillars: ask for the name, the claim, and the three proof points (company + outcome) for each

**Voice samples (10 min)**
- Ask: "Can you give me 3–5 direct quotes from how you talk about your work? Recordings, interviews, anything you've said in your own words."
- If none available: "Describe what energizes you professionally, in one or two sentences, the way you'd say it to a colleague."

**Domain depth (15 min)**
- What are your top 2–3 verticals? For each: companies, what you did, and the proof point you'd use in a letter.

**ICP and elevator pitch (10 min)**
- Who are the companies you're targeting? What's your 15-second and 60-second pitch?

Write each answer into its corresponding section of `framework.md`.

Confirm: "Phase 3 complete. Positioning, voice, and domain depth are configured. Cover letters will now draw from your actual profile."

---

## Phase 4 — Job tracking integration (required to run the full pipeline)

**Purpose:** The pipeline reads roles from a job tracking source and writes results back. This phase configures where that source lives.

Ask: "How do you want to track your job applications?"

**Option A — Notion (recommended)**
1. Provide the Notion template link: `https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782`
2. Ask: "Have you already duplicated this template to your Notion workspace?"
   - If yes: "Paste your database ID (the 32-character string from your Notion URL)."
   - If no: "Open the link, click 'Duplicate', then come back with the database ID."
3. Write the database ID into every `{{NOTION_DATABASE_ID}}` placeholder across all skill files.
4. Ask for the view ID if they have a filtered view they want to use → write to `{{NOTION_VIEW_ID}}`.

**Option B — CSV / Google Sheets**
1. Ask: "Where will your CSV or spreadsheet live? Provide the file path or Google Sheets URL."
2. Explain the required column schema (the pipeline expects these column names):
   - `Job URL`, `Company`, `Position`, `Status`, `Priority`, `JD Body`, `Notes`
3. Write the path/URL to the plugin config in `.claude/settings.json` under `job_tracking.source`.
4. Note: Notion writeback (posting file paths back to rows) is not available in CSV mode — outputs are delivered to the output folder only.

**Output folder**
Ask: "Where do you want your DOCX files saved?"
- Default: iCloud — ask them to confirm their iCloud path or provide a custom subfolder name
- Custom: any local absolute path

Write the path to every `{{ICLOUD_OUTPUT_PATH}}` placeholder across all skill files.

Ask: "Do you have a folder of approved, sent cover letters you want the pipeline to use as voice anchors? If so, where is it?"
- If yes: write the path to every `{{ICLOUD_DELIVERED_LETTERS_PATH}}` placeholder across all skill files.
- If no: write the output folder path as the default (agents will find nothing there initially and skip) — or remove the reference entirely by writing a note: "No delivered letters configured yet."

**CV template**
Ask: "Do you want to use the included CV template (`cv-template-default.dotx`) or provide your own `.dotx` file?"
- If own file: ask for the path → write to `{{CV_TEMPLATE_FILE}}` placeholders
- If default: write `${CLAUDE_PLUGIN_ROOT}/references/cv-template-default.dotx` to all `{{CV_TEMPLATE_FILE}}` placeholders

Confirm: "Phase 4 complete. Job tracking, output folder, and CV template are configured."

---

## Phase 5 — Permissions (required for autonomous pipeline runs)

**Purpose:** Without pre-approved permissions, Claude Code will pause mid-pipeline for approvals on every bash command and MCP call.

Read the current MCP tool IDs from `.claude/settings.json` in the plugin directory. Generate the exact allow-list block for the user's `~/.claude/settings.json`:

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

Fill in the actual MCP tool IDs from the plugin's `.mcp.json` or settings. Present the block to the user and say:

"Add this to your `~/.claude/settings.json` under the `permissions` key. If a `permissions` block already exists, merge the `allow` arrays."

Ask: "Have you added the permissions block? (You can do this now and come back, or skip for now and add it before your first run.)"

Confirm: "Phase 5 complete. The pipeline will run without approval prompts."

---

## Phase 6 — Q&A bank seed (optional, improves first-run letter quality)

**Purpose:** The Q&A bank lets the letter-writer use your real answers instead of asking the same intake questions repeatedly. Seeding it now means your first letters will use your voice from the start.

Show the user the question list from `qa-bank.md`. Ask them to answer 3–5 questions that feel most natural — particularly:
- The one that defines their professional approach ("the problem you exist to solve")
- Their answer to domain unfamiliarity / fast learning
- Their geographic preferences for remote work

Write their answers into `qa-bank.md`, replacing the `{{USER_ANSWER_...}}` placeholders.

Confirm: "Phase 6 complete. The letter-writer will use your answers directly."

---

## Verification

Run after Phases 1–4 are complete.

1. **Placeholder scan:** Run `grep -r "{{USER_" ${CLAUDE_PLUGIN_ROOT}/references/ | grep -v "{{USER_ANSWER_"` — report any required identity/contact/career placeholders that are still unfilled
2. **Integration check:** Confirm the output folder exists (`ls` the path). Confirm the CV template file exists at its configured path.
3. **Dependency check:** Run `pandoc --version` and `python3 -c "import docx"` — report if either is missing with install instructions (`brew install pandoc` / `pip3 install python-docx`)
4. **Summary:** Report which phases are complete and which are outstanding

If all four required phases are complete and dependencies are installed, confirm:

"Setup complete. You're ready to run `/cv-campaign`. If you haven't added the permissions block yet (Phase 5), do that before your first run to avoid mid-pipeline approval prompts."

---

## Style note

During the interview, maintain a direct and efficient tone. Ask one group of related questions at a time. Don't ask follow-up questions about answers that are already sufficiently clear. If the user says "skip" or "later" for any section, move on immediately and note it as outstanding in the verification summary.
