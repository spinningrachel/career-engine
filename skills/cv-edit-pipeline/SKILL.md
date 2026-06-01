---
name: cv-edit-pipeline
description: Editing pipeline for the cv-campaign plugin. Triggers when {{USER_FIRST_NAME}} says "edit CVs", "run CV edits", "process the Needs editing queue", or any similar phrase. Retrieves all Job Applications rows with Status = Needs editing, runs the employment coach first to verify and update its owned properties, then routes each role through the appropriate pipeline agents to improve existing outputs — not to start from scratch. Agents in this pipeline are explicitly informed they are refining existing work, not generating from zero.
---

# CV Campaign — Editing Pipeline

This skill handles the editing pipeline for roles {{USER_FIRST_NAME}} has flagged as needing revision. It runs separately from the main campaign pipeline and is triggered by Status = `Needs editing` in the Job Applications database.

The key difference from the main pipeline: **agents are not starting from scratch.** Existing CV text, cover letter text, coach properties, and reviewer feedback are all in the Notion row. The goal is to improve what exists, informed by what is already documented there.

**`Needs editing` always means edit from the Notion entry.** Every role with Status = `Needs editing` uses whatever is already inside its Notion row as the starting point — existing CV text, cover letter, coach properties, reviewer notes. Nothing is discarded. This rule holds regardless of what state.json says. state.json is crash recovery only (see State file section below).

## Preflight

**Outputs go to the iCloud output folder — never to a session scratchpad.**

The only valid output destination is:
`/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-<YYYY-MM-DD>/`

Do not create a local output directory inside a session path (`local_*/outputs/` or similar). Files written there do not sync and are not findable.

Before starting, run this path verification:

```bash
# Verify iCloud output root exists — if not, stop immediately
ls "/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/" 2>/dev/null \
  && echo "iCloud output path confirmed." \
  || { echo "ERROR: iCloud output root not found. Aborting."; exit 1; }
```

If this check fails, **stop the run immediately** and report the error to {{USER_FIRST_NAME}}. Do not fall back to any other path. Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support".

Then confirm:
1. Output folder for each role is the campaign folder from the original run date. **How to identify it:** check the most recent `state.json` in the iCloud campaign folders — find the entry for this role (match by `notion_page_id`) and read the `cv_path` field, which is in the format `cv-campaign-<YYYY-MM-DD>/<filename>.docx`. The folder prefix is the output dir. If no state.json entry exists for this role (e.g., it was added to Notion after the original run), use today's date as the campaign folder and create it if needed.
2. File format is DOCX — same as the main pipeline.
3. `cv-campaign-export` skill is loaded.
4. All cv-campaign skills are loaded, including operating-rules.md.

## Step E0 — Fetch roles for editing

Query the Job Applications database (ID: `3465ef1aa63480a283cfdf847cb47404`). Filter for entries where:
- Status is `Needs editing`

For each matching entry, capture the full row payload including:
- Page ID
- Company name
- Position title
- Job URL
- Pipeline (Standard or Reframe only — from {{USER_FIRST_NAME}}'s chat command)
- All existing property values — `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Additional Letter Writer Details`, `CV File Name`, `Letter File Name`, `Note`, and any other populated fields
- Any reviewer feedback or notes already on the row

Report the count to {{USER_FIRST_NAME}}: "Found N roles marked Needs editing." If the count is 0, stop and report that.

## Step E0.5 — Prepare JD content from Notion rows

For each role fetched in Step E0, extract the structured JD from the row payload. The `JD Body` property was already captured in Step E0 as part of the full row payload.

For each role:
1. **`JD Body` is populated** — mark `content-exists`. Use this as the structured JD for all downstream steps (coach, gatekeeper, cv-writer, letter-writer). Do not re-fetch from the Job URL.
2. **`JD Body` is empty** — mark `needs-fetch`. The employment coach (Step E1) will attempt to fetch the JD from the Job URL as part of its pre-flight. If the coach cannot access the URL, log the failure and skip this role.

Hold all structured JD data in memory. All subsequent steps that reference "the structured JD from Step E0.5" draw from here.

## Step E0.7 — Baseline check

Run the gatekeeper on all existing outputs in parallel. The goal is a complete picture of what's already broken before any editing begins. All violation lists travel forward to the coach (E1) and cv-writer (E3) as context.

The employment coach fetches JDs as part of Step E1 — no separate fetch step needed here.

**Content check:** Spawn `gatekeeper` with `option=content`, passing the existing CV text, the structured JD, and the role's `Keywords` property (from the Notion row — required for the ATS pre-check). Returns either PASS or a content violation list.

**Cover letter check:** If a cover letter exists (`Letter File Name` property is populated on the Notion row), spawn `gatekeeper` with `option=cover-letter`, passing the existing cover letter text, the structured JD, and whether `Additional Letter Writer Details` is populated or empty. Returns either PASS or a cover letter violation list. Skip if no cover letter exists.

Run both in parallel. Collect results. Do not loop or fix anything yet — this step is diagnosis only.

## Step E1 — Employment coach verification

Spawn `employment-coach` with the full row data, the structured JD data for every role in the editing queue, and the baseline violation lists from Step E0.7 as additional context.

The coach's job in this pipeline is verification and refinement — not a fresh start. For each role:

1. **Review the existing coach-owned properties** (`Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`) already on the Notion row. Assess whether they are accurate, complete, and well-calibrated given the full JD data and {{USER_FIRST_NAME}}'s documented background.

2. **If a property is correct:** keep it. Do not rewrite it for the sake of rewriting.

3. **If a property needs correction or improvement:** return the updated value with a one-sentence note explaining what changed and why.

4. **For `Gap handling` specifically:** if {{USER_FIRST_NAME}} has edited this in Notion, treat her version as authoritative and do not overwrite it. If it was set by a prior coach run and is still accurate, carry it forward. If it needs correction given the current JD, return an updated value with a one-sentence explanation.

5. **Return writing guidance** for the editing run — the same batch analysis, base CV recommendation, and per-role focus format as the main pipeline. This guidance informs how the cv-writer approaches the revision.

The coach does not re-score priorities or rebuild the queue in the editing pipeline. All roles in the editing queue are processed.

## Step E2 — Coach property writeback

Write any updated coach-owned properties back to the matching Notion rows using `notion-update-page`. Only overwrite properties the coach flagged as needing correction. Do not overwrite properties the coach confirmed as correct.

Confirm in chat: "Coach verification complete: K properties updated across N roles." Then proceed.

## Per-role editing pipeline

Process roles sequentially. For each role, branch on the pipeline {{USER_FIRST_NAME}} specified in chat (same logic as the main pipeline).

### Pipeline `Standard`

Agents in this track are explicitly informed they are improving existing work. Pass each agent:
- The structured JD from Step E0.5
- The existing CV text from the Notion row or the existing DOCX (whichever is available)
- The existing cover letter text (retrieved from the iCloud campaign folder using the filename in `Letter File Name` — extract text using `pandoc "<output_dir>/<letter-filename>.docx" -t plain`; skip if `Letter File Name` is empty)
- The verified coach properties from Step E1
- Any reviewer feedback or notes already on the row

**Step E3 — CV writer (revision mode)**

Spawn `cv-writer` with `option=revision`. Pass:
- The existing CV text as the draft (from the saved markdown backup at the iCloud output path, or extracted using `pandoc "<cv>.docx" -t markdown` if only the DOCX is available)
- The coach's verified properties as the strategic anchor
- The baseline content violation list from Step E0.7 (so the cv-writer addresses pre-existing violations immediately, not after another loop)
- Any recruiter or hiring manager feedback already on the row from the original campaign run

The cv-writer is improving the existing CV — not drafting a new one.

**Quality requirement — include this verbatim in the cv-writer prompt:**
> For every section you touch, return a before/after comparison stating specifically what changed and why the revision is stronger. If you leave a section unchanged, say so explicitly. If you cannot improve a section beyond rule-compliance — same structure, same sentences, minor word swaps — say "no quality improvement possible here" rather than returning near-identical text. Rule-compliant-but-equivalent output is a failure, not a revision.

**Step E3.25 — Quality comparison gate**

Before passing the revised CV to the gatekeeper, the orchestrator reads both versions side by side.

Assess:
- Did the summary change substantively, or just swap words?
- Did bullet points become more specific, quantified, or better targeted to this JD?
- Is any section weaker than before (vaguer, less specific, or missing a proof point)?

**If output is near-identical or weaker in any section:** Return to `cv-writer` with `option=revision`, quoting the specific weak section verbatim and instructing: "This section is not improved. Rewrite it — new structure, stronger framing, more targeted language. Do not return text that is substantively the same as the input." Max 2 loops. If no quality improvement is achieved after 2 loops, flag in the final delivery: "[Role] — CV section [X]: no quality improvement achieved after 2 rounds."

**If output is demonstrably stronger:** proceed to Step E3.5.

**Step E3.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=content`, passing the revised CV text, the structured JD from Step E0.5, and the role's `Keywords` property (from the coach's verified output in Step E1 — required for the ATS pre-check).

**If PASS:** proceed to Step E4.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the revised CV and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again. Repeat until PASS. Do not surface this loop to {{USER_FIRST_NAME}}. Log all violation rounds internally.

**Step E4 — Recruiter review**

Spawn `recruiter-reviewer` with the structured JD and the revised CV. It returns tiered feedback on the revision. The reviewer is aware this is a revision, not a first draft.

**Step E5 — Hiring manager review**

Spawn `hiring-manager-reviewer` with the structured JD and the revised CV. It returns structured feedback on the revision.

**Step E6 — CV writer (final revision)**

Spawn `cv-writer` with `option=revision`, passing the revised CV from Step E3, the recruiter feedback from Step E4, and the hiring manager feedback from Step E5. Returns the final CV and revision log.

**Step E6.5 — Gatekeeper (content check)**

Spawn `gatekeeper` with `option=content`, passing the final revised CV text, the structured JD, and the role's `Keywords` property.

**If PASS:** proceed to Step E7.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the final CV and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again. Repeat until PASS. Log all violation rounds internally.

**Step E7 — Cover letter (initial revision)**

**Before spawning letter-writer:** Read the following from the Notion row payload collected in Step E0 (all are part of the full row payload already in memory):
- **`Q&A` property** — {{USER_FIRST_NAME}}'s answers to the pre-campaign interview questions. Include the full content if populated; skip if empty.
- **Page body content** — any additional background {{USER_FIRST_NAME}} added to the Notion page body. Include if present; skip if blank.
- **`Additional Letter Writer Details`** — {{USER_FIRST_NAME}}'s instructions for positioning content. This is {{USER_FIRST_NAME}}'s field — never rewritten by agents.

Spawn `letter-writer` with `option=revision`. Pass:
- The existing cover letter (from the iCloud campaign folder using the filename in `Letter File Name` — extract text with `pandoc "<output_dir>/<letter-filename>.docx" -t plain`)
- The baseline cover letter violation list from Step E0.7
- The verified coach properties from Step E1, including `Gap handling`
- The final CV (for context)
- **`Additional Letter Writer Details` status:** if populated, pass the field content and instruct letter-writer to incorporate the positioning angles {{USER_FIRST_NAME}} specified. If empty or absent, pass this instruction verbatim: "Additional Letter Writer Details is empty — do not reference, analyse, describe, or comment on the hiring company's positioning anywhere in this letter."

The letter-writer improves the existing letter — it does not start from scratch unless the strategic positioning changed significantly in Step E1.

The cover letter is written to the DOCX file only. Do not write cover letter text to any Notion property.

**Step E7.25 — Cover letter quality comparison gate**

Before passing the revised cover letter to the gatekeeper, compare the old and new versions on four dimensions:

1. **Opening strength** — does it pull the reader in immediately, or start with a generic frame?
2. **Specificity** — does it name concrete things about this company, this role, or this intersection of {{USER_FIRST_NAME}}'s background?
3. **Voice naturalness** — does it sound like a person talking, or like assembled copy?
4. **Closing force** — does it end with a reason to respond, or trail off?

**The new letter must be stronger than the old on at least 2 of these 4 dimensions.**

**If it is not:** Return to `letter-writer` with `option=revision`, quoting the old letter's strongest lines verbatim and instructing: "The revision is not better. The original was stronger in [specific dimension]. Here are the lines that worked best in the original: [quoted lines]. Write a new letter that preserves this strength while fixing the identified problems." Max 2 loops. If no improvement after 2 loops, flag in the final delivery: "[Role] — cover letter: no quality improvement achieved after 2 rounds; original preserved."

**If it is stronger:** proceed to Step E7.3.

**Step E7.3 — Gatekeeper (cover letter check — initial)**

Spawn `gatekeeper` with `option=cover-letter`, passing the cover letter text, the structured JD (including the Company self-characterization section), {{USER_FIRST_NAME}}'s Q&A answers and page body content (retrieved in Step E7 from Notion), and the `Additional Letter Writer Details` status (populated or empty).

**If PASS:** proceed to Step E7.4.

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the cover letter and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again with `option=cover-letter`. Repeat until PASS. Log all violation rounds internally. Then proceed to Step E7.4.

**Step E7.4 — Recruiter review**

Spawn `recruiter-reviewer` with `option=cover-letter`, passing the revised cover letter and the structured JD. The reviewer is aware this is a revision, not a first draft — it returns tiered feedback on what is working, what is not, and what is missing given the JD.

**Step E7.5 — Hiring manager review**

Spawn `hiring-manager-reviewer` with `option=cover-letter`. Pass the revised cover letter, the structured JD, the final CV (for context), and the recruiter feedback from Step E7.4. Returns structured feedback. If the hiring manager returns a Conditional verdict, quote the condition verbatim in the Step E7.6 prompt.

**Step E7.6 — Letter-writer (final revision)**

Spawn `letter-writer` with `option=revision`. Pass:
- The revised cover letter from Step E7
- Recruiter feedback from Step E7.4
- Hiring manager feedback from Step E7.5 (including any Conditional condition verbatim)
- The gatekeeper violation list from Step E7.3 if any items were not fully resolved

Returns the final cover letter and a brief revision log (what changed and why, one line per change).

**Step E7.7 — Gatekeeper (cover letter check — final)**

Spawn `gatekeeper` with `option=cover-letter`, passing the final cover letter text, the structured JD, {{USER_FIRST_NAME}}'s Q&A answers and page body content (same as Step E7.3), and the `Additional Letter Writer Details` status (populated or empty).

**If PASS:** proceed to Step E9.

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the final cover letter and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again with `option=cover-letter`. Repeat until PASS. Log all violation rounds internally.


**Step E9 — Produce DOCX**

Follow the same pandoc production protocol as the main pipeline. See `cv-campaign-export` for the full protocol.

Derive `<company_dir>` from the Company name using the naming convention in `cv-campaign-export`. The output goes to `<output_dir>/<company_dir>/` — the same subdirectory the original run used. Create the subdirectory if it does not exist; it will already exist for roles that had a prior run.

Write the final CV markdown and cover letter markdown to `/tmp/`, convert with pandoc using the `.dotx` reference templates, update the CV Subtitle, and copy both files to `<output_dir>/<company_dir>/`. If a file with the same name already exists, overwrite it — this is an edit, not a new file.

Verify both files exist and are nonzero before proceeding to Step E9H.

**Step E9H — Hebrew localization (conditional)**

**Only runs if `Languages` includes `Hebrew`.** Check the `Languages` property on the Notion row fetched in Step E0. If `Hebrew` is not present, skip this step entirely and proceed to Step E10.

Spawn `hebrew-localization` with:
- The final English CV markdown (from Step E6, in memory)
- The final English cover letter markdown (from Step E7.6, in memory)
- The structured JD from Step E0.5
- The exact role title from the JD

The agent returns a Hebrew CV markdown block and a Hebrew cover letter markdown block.

Write to `/tmp/` and convert:

```bash
cat > /tmp/he-<cv_filename>.md << 'MARKDOWN_EOF'
<Hebrew CV markdown from agent>
MARKDOWN_EOF

cat > /tmp/he-<cl_filename>.md << 'MARKDOWN_EOF'
<Hebrew cover letter markdown from agent>
MARKDOWN_EOF

HE_TEMPLATES="/Users/rachel/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Templates.localized"

# Hebrew CV — concatenate with Hebrew footer, then convert
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${HE_TEMPLATES}/cvHe.dotm" \
  -o "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

python3 "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

ls -lh "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
ls -lh "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
```

If a Hebrew file with the same name already exists, overwrite it — this is an edit.

**Step E10 — Notion writeback and state update**

1. Confirm both English DOCX files are saved in `<output_dir>/<company_dir>/`.
2. Write the Draft Directory URL to the `Draft Directory` URL property on the Notion row:
   ```
   Draft Directory: https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F
   ```
   Hebrew files (if produced in Step E9H) are in the same directory and are accessible via the same URL — no separate Hebrew property writes needed.
3. Write updated coach-owned properties if the coach corrected any in Step E1 — `Role emphasis`, `Keywords`, `Strategy`, `Gap handling` only; do not overwrite others.
4. Update Status from `Needs editing` to `CV Ready for Review`.
5. Append this role to the editing run's `state.json` (see State file section below) with `status: "completed"`.

Do not overwrite coach-owned properties again here — those were already updated in Step E2.

Do not write anything to the `Note` field unless the agent has genuinely additional context that the structured properties cannot carry.

### Pipeline `Reframe only`

**Step ER1 — Reframe CV writer**

Spawn `cv-writer` with `option=revision`, passing the structured JD, the existing reframe CV text (if available), and any notes on the row. The cv-writer improves the existing CV — it does not start from scratch unless the strategic positioning changed significantly.

**Step ER2 — Reframe DOCX**

Export the updated reframe CV using the `/tmp` to iCloud output folder copy protocol. Overwrite the existing file.

**Step ER2H — Hebrew reframe CV (conditional)**

**Only runs if `Languages` includes `Hebrew`.** Spawn `hebrew-localization` with the reframe CV markdown, the structured JD from Step E0.5, and the role title. Pass `null` for the English cover letter input — CV only.

Convert the Hebrew CV using the Hebrew DOCX production protocol from `cv-campaign-export`. Overwrite any existing Hebrew file. RTL adjustment in Word required before sending.

**Step ER3 — Reframe writeback and state update**

1. Write the Draft Directory URL to the `Draft Directory` URL property:
   ```
   Draft Directory: https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F
   ```
2. Update Status to `CV Ready for Review`.
3. Append this role to the editing run's `state.json` with `status: "completed"`.

## State file (crash-recovery resilience)

After each role completes, append its data to:
`/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-<YYYY-MM-DD>/state.json`

Use the same format as the main pipeline (see cv-campaign-role-steps Step 7b). The `session_date` field must reflect today's date.

**Purpose:** state.json is crash recovery only. If this editing pipeline is interrupted mid-run, the orchestrator can resume by checking state.json and skipping roles already marked `completed`. It is not a record of prior editing runs.

**At the start of an editing run:** check for a `state.json` in today's campaign folder. If one exists with today's `session_date`, skip any roles already marked `completed` — those were processed before the crash. If the `session_date` is from a prior day, ignore the file and process all `Needs editing` roles from scratch.

**`Needs editing` always takes precedence over state.json.** A role's Notion Status is the source of truth for what mode to run. If a role is marked `Needs editing`, it runs the editing pipeline using the Notion entry as source material — even if it also appears in state.json from an earlier session.

## Final chat delivery

Same format as the main pipeline:
- Named list of any roles that failed (company, title, failure step, reason)
- Any properties the coach updated and why (brief)
- Single confirmation line if nothing notable to report: "All N roles edited. Files updated in iCloud and Notion rows updated."

## Hard rules

- **Agents are improving existing work, not starting from scratch.** Every agent in this pipeline receives the existing outputs as context. The instruction "improve what exists" must be explicit in every sub-agent spawn.
- **Coach properties are the anchor.** The cv-writer, reviewers, and other agents take the coach's verified properties as given. They do not reinterpret strategic positioning.
- **Property discipline.** Each property is written once, by its owner. Do not duplicate content across fields. The `Note` field is {{USER_FIRST_NAME}}'s space.
- **Fabrication rule is absolute.** See operating-rules.md. Editing does not license invention.
- **Status update is the final step.** Only update Status to `CV Ready for Review` after the DOCX export and Notion writeback are confirmed complete.
- **Do not pause mid-run.** Process all roles in the editing queue without stopping to ask {{USER_FIRST_NAME}} about scope.
