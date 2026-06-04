---
name: cv-campaign-role-steps
description: 'Per-role pipeline for the cv-campaign orchestrator. Handles Step 0.10 (warm-up role selection) and Steps 1 through 7 for New Applications pipeline roles: CV draft, gatekeeper, recruiter review, HM review, CV revision, cover letter draft, cover letter gatekeeper, cover letter recruiter review, cover letter HM review, cover letter revision, cover letter gatekeeper (post-revision), DOCX export for both files, and Notion writeback. The structured JD for each role is already in memory from the queue pipeline — do not re-fetch. Load this skill as part of the cv-campaign pipeline, after cv-campaign-intake.'
---

# CV Campaign — Per-Role Pipeline

This skill covers Step 0.10 and Steps 1 through 7 of the New Applications pipeline. Step 0.10 runs once before the per-role loop begins. Steps 1 through 7 repeat for each role in the processing queue. The structured JD was fetched in Step 0.5 and is in memory — pass it directly without re-fetching.

The pipeline produces two deliverables per role: a CV DOCX and a cover letter DOCX. Both go through the same review sequence — draft, gatekeeper, recruiter review, HM review, revision, gatekeeper (post-revision) — before DOCX export.

---

## Step 0.10 — Warm-up role selection (for batch runs of 2 or more roles)

**Only applies when the processing queue contains 2 or more roles.**

Before processing the full queue, identify the warm-up role — the first role to process. The warm-up role's gatekeeper violations will be extracted and injected as pre-warnings into the cv-writer prompt for all remaining roles, reducing loops across the batch.

**Warm-up role selection logic:**
1. If any role in the queue has priority `Highest` — use the first one.
2. Otherwise, use the first `First` priority role in the queue.
3. If no `Highest` or `First` exists — use the first role in the queue regardless of priority.
4. Among ties, prefer {{USER_CITY}}/{{USER_COUNTRY}} location over remote.

**After the warm-up role completes Steps 1 through 4.5 (draft → gatekeeper → reviews → revision → gatekeeper):**

Extract recurring failure patterns from the gatekeeper violation logs. Specifically:
- Any tool name found in bullets (e.g., "ZoomInfo found in VL bullets")
- Any role missing RoleOverview (e.g., "[Company] missing RoleOverview")
- Any verb used 3+ times (e.g., "'Built' appeared 4 times")
- Any summary violation that repeated across loops

Build a `known_issues` note and prepend it to the cv-writer prompt for every subsequent role in the batch:

> "Pre-warnings from role 1 gatekeeper logs: [list violations]. Check for these specifically before returning your draft."

This is the only inter-role learning mechanism. It does not require agents to share state — the orchestrator extracts and injects the patterns explicitly.

---

## CV Steps (1 through 4.5)

### Step 1 — CV writer (draft)

Spawn `cv-writer` with `option=draft`, passing:
- `Role summary` (the compressed JD proxy — contains role context, key requirements, and self-characterization section)
- The coach's output for this role: `Role emphasis`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`

### Step 1.5 — Gatekeeper (CV draft check)

Spawn `gatekeeper` with `option=content`, passing the draft CV text, `Role summary`, and the coach's `Keywords` property for this role. The gatekeeper's ATS pre-check parses Keywords into tiers (Critical / Important / Nice-to-have) to verify coverage.

**If PASS:** proceed to Step 2.

**If FAIL:** review the violation list. If all violations are mechanical and unambiguous (swap two words, remove one phrase, reorder paragraphs — no creative judgment required), apply them inline. If any violation requires cv-writer judgment (rewriting a bullet, resolving a fabrication flag), spawn `cv-writer` with `option=revision`, passing the draft and the gatekeeper's full violation list. After fix, spawn `gatekeeper` again with `option=content`. Repeat until PASS. Do not surface this loop to {{USER_FIRST_NAME}} — log violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 1.5)` section in the revision log, proceed to Step 2, and flag for {{USER_FIRST_NAME}} in the final delivery that this CV needs manual review before sending.

### Step 2 — Recruiter review (CV)

Spawn `recruiter-reviewer` with `Role summary` and the draft CV. Returns tiered feedback.

### Step 3 — Hiring manager review (CV)

Spawn `hiring-manager-reviewer` with `option=cv`, passing `Role summary` and the draft CV. Returns structured feedback and a verdict (Yes / Conditional / No).

### Step 4 — CV writer (revision)

Spawn `cv-writer` with `option=revision`, passing the draft CV, the recruiter feedback, and the hiring manager feedback. Returns the final CV and a CV Changes section (what changed and why). The CV Changes section is included in the feedback file at Step 7d.

If any recruiter or HM flag identifies a skill or credential gap {{USER_FIRST_NAME}} does not have — do not address it. IT SHOULD BE COMPLETELY OMITTED. Reframing, surfacing, and reordering are permitted; fabrication and scope-hedging ARE ABSOLUTELY PROHIBITED.

**Immediately after Step 4 returns — save the revised CV markdown and the revision log to disk before spawning the gatekeeper.** Context compaction can interrupt between any two steps, and this is the only reliable recovery path.

```bash
# Save CV markdown to /tmp (used by pandoc in Step 6)
cat > /tmp/<cv_filename>.md << 'MARKDOWN_EOF'
<full CV markdown>
MARKDOWN_EOF

# Save CV markdown to iCloud output dir (company subdir) as crash-recovery backup
cp /tmp/<cv_filename>.md "<output_dir>/<company_dir>/<cv_filename>.md"

# Save revision log to iCloud output dir (company subdir)
cat > "<output_dir>/<company_dir>/revision-log-<roletitle>-<company>-<monYYYY>.md" << 'MARKDOWN_EOF'
# Revision Log — <Role Title> at <Company> — <YYYY-MM-DD>

## CV Changes
<full revision log from cv-writer — changes made and why each is stronger>
MARKDOWN_EOF
```

### Step 4.5 — Gatekeeper (CV final check)

Spawn `gatekeeper` with `option=content`, passing the revised CV text, `Role summary`, and the coach's `Keywords` property for this role.

**If PASS:** proceed to Step 5.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the revised CV and the gatekeeper's full violation list. After revision, re-save the updated markdown to `/tmp/` and the iCloud backup path before spawning `gatekeeper` again. Repeat until PASS. Log all violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 4.5)` section in the revision log, proceed to Step 5, and flag for {{USER_FIRST_NAME}} in the final delivery that this CV needs manual review before sending.

---

## Cover Letter Steps (5 through 5.8)

The cover letter receives the **final revised CV** as input. letter-writer uses it to ensure the letter and CV tell a coherent story and the letter adds something the CV cannot.

### Pre-Step 5 — Cover letter content inputs

**Skip in `--now` mode** — no Notion row exists.

Read the following from Notion for this role:

**Q&A property** — Contains letter-writer-generated questions and {{USER_FIRST_NAME}}'s answers to them. If populated, include the full content in the letter-writer prompt as the primary content input. If empty, proceed without it.

**Page body content** — Optional additional background {{USER_FIRST_NAME}} may have added (her reaction to the role, any context she wants in the letter). Include if present. If blank, skip — it is not required.

**`Additional Letter Writer Details` property** — {{USER_FIRST_NAME}}'s response to the PMM Expert's positioning analysis from the standalone research pipeline. **The PMM expert agent does NOT run as part of this pipeline — it runs in the standalone intake (coach skill) only.** This field is populated by {{USER_FIRST_NAME}} after she reviews the PMM expert's output there. Read it here and pass it to letter-writer. If populated, the letter may reference the hiring company's positioning per {{USER_FIRST_NAME}}'s instructions. If empty or absent, letter-writer must NOT reference, analyse, or comment on the company's positioning in any part of the letter.

**If both Q&A and page body are empty:** Do NOT proceed to Step 5 for this role. Spawn `letter-writer` with `option=interview-questions` for this role (passing the JD, company name, role title, and coach output), write the returned questions to the `Q&A` property in Notion, and log this role as "Letter skipped — awaiting intake." Then skip to the next role in the pipeline. If this is the only role in the run, end the pipeline after logging and surface this message to {{USER_FIRST_NAME}}:

> **Letter skipped for [Company] — [Role Title].** Q&A and page body are both empty. Intake questions have been written to the Notion row. Answer them there, then re-run the pipeline for this role.

**This gate applies only to this role.** Other roles in the batch are not affected — continue processing them normally.

---

### Step 5 — Cover letter (draft)

**Before spawning letter-writer:** Read `02-candidate-background.md` (Role Facts) for {{USER_FIRST_NAME}}'s role facts — key proof points from `02-candidate-background.md` (Role Facts). Pass this context to letter-writer so it can draw proof naturally from her background rather than assembling pre-written paragraphs.

**Before spawning, pass the following for this role:**
- **Q&A property**, **Page body content**, and **`Additional Letter Writer Details`** — use the values retrieved in Pre-Step 5. Do not re-read from Notion.
- **Strategy** property — from the employment coach
- **Gap handling** property — from the employment coach

**Priority rule:** Q&A and page body content take precedence over Strategy and Gap handling. If there is any conflict between them on what content to prioritise or how to organise the letter, Q&A and page body content win.

**Include this verbatim at the front of the letter-writer prompt:**
> STRUCTURE IS NON-NEGOTIABLE. Regardless of any reviewer feedback you receive, the letter structure defined in `cover-letter/SKILL.md` must be observed in full — in particular the tone, voice, and content of the opening paragraph. Reviewer feedback informs what proof to include or emphasise; it does not change how the letter is structured or how the opening is written.

Spawn `letter-writer` with `option=cover-letter`, passing:
- The **final revised CV** (from Step 4)
- `Role summary` (contains the role context, key requirements, and Company self-characterization section verbatim if present — this is the JD proxy for the letter-writer)
- The coach's Relationship type
- The HM CV verdict from Step 3 — if Conditional, quote the specific condition verbatim so letter-writer knows upfront what the cover letter must address
- **Q&A** from Notion (read above) — primary content input; include if populated
- **Page body content** from Notion (read above) — supplementary; include if present
- **`Additional Letter Writer Details`** from Notion — governs all company positioning content; if empty, include this instruction verbatim: "Additional Letter Writer Details is empty — do not reference, analyse, describe, or comment on the hiring company's positioning anywhere in this letter."
- **Strategy** and **Gap handling** from Notion (read above) — secondary context; defer to Q&A and page body content on any conflict

**Orchestrator quality read — before passing to gatekeeper:**

After letter-writer returns the cover letter, read it against the worked examples in `skills/cover-letter/SKILL.md`. Ask:
- Does it open with something specific and arresting, or with a generic frame?
- Does it sound like a person talking, or like marketing copy assembled from blocks?
- Does it name something concrete about this company or this role that the reader will recognize as real?
- Does it close with a reason to respond?

If the answer to any of these is "no," return to `letter-writer` with `option=cover-letter` and quote the specific problem verbatim. One retry only. Then proceed to Step 5.2 regardless.

### Step 5.2 — Gatekeeper (cover letter draft check)

Spawn `gatekeeper` with `option=cover-letter`, passing the cover letter text, `Role summary`, {{USER_FIRST_NAME}}'s Q&A answers and page body content (from the Pre-Step 5 read), and whether `Additional Letter Writer Details` is populated or empty. The Q&A and page body content allows the gatekeeper to apply the Q&A exemption correctly — see the exemption rule at the top of Option 2 in `gatekeeper-checks/SKILL.md`.

**If PASS:** proceed to Step 5.3.

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the cover letter and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again with `option=cover-letter`. Repeat until PASS. Log all violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 5.2)` section in the revision log, proceed to Step 5.3, and flag for {{USER_FIRST_NAME}} in the final delivery that this cover letter needs manual review before sending.

### Step 5.3 — Recruiter review (cover letter)

Spawn `recruiter-reviewer` with `option=cover-letter`, passing `Role summary` and the draft cover letter. The recruiter reviews the cover letter for screening-risk issues: does it hold attention past the first sentence, does it establish {{USER_FIRST_NAME}}'s seniority and relevance quickly, does anything read as a red flag before a hiring manager sees her. Returns tiered feedback.

### Step 5.5 — Hiring manager review (cover letter)

Spawn `hiring-manager-reviewer` with `option=cover-letter`, passing:
- The cover letter
- The HM CV verdict from Step 3 (including the specific condition if Conditional)
- `Role summary`

Returns three questions: does it address the condition (if any), does it add something new the CV doesn't say, does it increase interview likelihood. Returns a verdict: Proceed to DOCX / Return to letter-writer.

### Step 5.7 — Cover letter revision

Spawn `letter-writer` with `option=revision`, passing:
- The draft cover letter
- The recruiter feedback (from Step 5.3)
- The hiring manager cover letter feedback (from Step 5.5)
- The HM CV verdict from Step 3 — if Conditional, quote the specific condition verbatim and flag whether the draft addressed it (based on the HM cover letter verdict from Step 5.5)

Returns the final cover letter. Address what can be addressed through reframing or surfacing documented experience. If the HM CV Conditional condition remains unmet and genuinely cannot be addressed without fabrication, proceed anyway.

**Immediately after Step 5.7 returns — save the revised cover letter markdown to disk:**

```bash
cat > /tmp/<coverletter_filename>.md << 'MARKDOWN_EOF'
<full cover letter markdown>
MARKDOWN_EOF

cp /tmp/<coverletter_filename>.md "<output_dir>/<company_dir>/<coverletter_filename>.md"
```

### Step 5.8 — Gatekeeper (cover letter final check)

Spawn `gatekeeper` with `option=cover-letter`, passing the revised cover letter text, `Role summary`, {{USER_FIRST_NAME}}'s Q&A answers and page body content (same as Step 5.2), and whether `Additional Letter Writer Details` is populated or empty.

**If PASS:** proceed to Step 5.9.

**If FAIL:** spawn `letter-writer` with `option=revision`, passing the revised cover letter and the gatekeeper's full violation list. After revision, re-save the updated markdown to `/tmp/` and the iCloud backup path before spawning `gatekeeper` again. Repeat until PASS. Log all violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 5.8)` section in the revision log, proceed to Step 5.9, and flag for {{USER_FIRST_NAME}} in the final delivery that this cover letter needs manual review before sending.

---

### Step 5.9 — Humanizer (cover letter)

Spawn `cover-letter-humanizer`, passing the final cover letter markdown and `Role summary`.

The humanizer is a writing editor and linguistics expert. It loads `skills/cover-letter-humanizer/SKILL.md` and removes AI writing patterns sentence by sentence. It does not change structure, strategy, or content — only language.

**Wait for the humanizer to return** the corrected letter and its change log before proceeding.

Save the humanizer's output to `/tmp/` and the iCloud backup path, overwriting the previous cover letter markdown. The change log goes into the revision log under `## Humanizer changes`.

This step is non-blocking — if the humanizer returns no changes, proceed normally. If the humanizer fails, log the failure and proceed with the pre-humanizer version.

---

## Step 6 — Produce DOCX

Both the CV and the cover letter are now final markdown files saved to `/tmp/`. Convert both to `.docx` using pandoc with the `.dotx` reference templates. Run bash directly — no agent spawn needed.

Follow the `cv-campaign-export` skill's Step 6 production protocol exactly — it is the single authoritative source for pandoc commands, script paths, subtitle update, and verification. Do not substitute your own abbreviated steps. Both files must exist and be nonzero in the iCloud output folder before proceeding to Step 7.

**Subtitle argument:** Pass the exact role title from the JD as the subtitle argument to `update-subtitle.py` — the job title {{USER_FIRST_NAME}} is applying for (e.g., "[Role Title from JD]"). This is the ONLY text that should appear in the subtitle slot under {{USER_FIRST_NAME}}'s name. Do not pass a generic descriptor, {{USER_FIRST_NAME}}'s background framing, or anything not directly taken from the JD role title field.

---

## Step 6H — Hebrew localization (conditional)

**Only runs if `Languages` includes `Hebrew`.** Check the `Languages` property on the Notion row fetched in Step 0. If `Hebrew` is not present, skip this step entirely and proceed to Step 7.

### 6H.1 — Spawn Hebrew localization agent

Spawn `hebrew-localization` with:
- The final English CV markdown (from Step 4/4.5, already in memory)
- The final English cover letter markdown (from Step 5.7, already in memory)
- The structured JD
- The exact role title from the JD

The agent returns a Hebrew CV markdown block and a Hebrew cover letter markdown block.

### 6H.2 — Export Hebrew DOCX files

Write the Hebrew markdown files to `/tmp/` **and** copy them to the iCloud output folder:

```bash
cat > /tmp/he-<cv_filename>.md << 'MARKDOWN_EOF'
<Hebrew CV markdown from agent>
MARKDOWN_EOF

cat > /tmp/he-<cl_filename>.md << 'MARKDOWN_EOF'
<Hebrew cover letter markdown from agent>
MARKDOWN_EOF

# Copy Hebrew markdown files to output folder — required, same as English markdown files
cp /tmp/he-<cv_filename>.md "<output_dir>/"
cp /tmp/he-<cl_filename>.md "<output_dir>/"
```

Convert using the Hebrew DOCX production protocol from `cv-campaign-export`:

```bash
HE_TEMPLATES="{{WORD_TEMPLATES_PATH}}"

# Hebrew CV — concatenate with Hebrew footer, then convert
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${HE_TEMPLATES}/cvHe.dotm" \
  -o "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

# Hebrew CV subtitle
python3 "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
```

Verify both files exist and are nonzero:

```bash
ls -lh "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
ls -lh "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
```

**Hebrew re-translation rule:** If either English document (CV or cover letter) is revised after Hebrew export, the corresponding Hebrew document MUST be fully re-translated from the updated English markdown — do not patch or edit the prior Hebrew text. If the English CV changes, re-translate the Hebrew CV. If the English cover letter changes, re-translate the Hebrew cover letter. Both change together only if both English documents changed. This applies regardless of how small the English edit is.

Hebrew files land in the same `<company_dir>` subdirectory as the English files. The `Draft Directory` URL (written in Step 7a) points to the whole directory and covers both English and Hebrew files — no separate Notion writeback for Hebrew filenames.

---

## Step 7 — Record file paths and write state

### Step 7a — Notion Draft Directory writeback

**Hard gate — do not skip, do not proceed on failure.**

Run this bash check first:

```bash
ls -lh "<output_dir>/<company_dir>/<cv_filename>.docx"
ls -lh "<output_dir>/<company_dir>/<cl_filename>.docx"
```

**If either file is missing or zero bytes: STOP.** Do not write anything to Notion. Do not mark the role complete. Report to {{USER_FIRST_NAME}}: "DOCX export failed for [Company] — files not found on disk. Step 6 did not complete. Notion has not been updated." Then move to the next role in the queue.

**Only if both files exist and are nonzero:** write the Draft Directory URL to the `Draft Directory` URL property on the Notion row (match by Page ID from Step 0), then write `state.json` in Step 7b, then write remaining Notion properties in Step 7c.

```
Draft Directory: https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F
```

If the Notion writeback itself fails after files are confirmed, log it and surface it in the final delivery — the files are on disk and state.json captures the data as fallback.

### Step 7b — Write state file (crash-recovery)

Append this role's data to:
`{{OUTPUT_FOLDER}}/cv-campaign-<YYYY-MM-DD>/state.json`

Create the file on the first role; append on subsequent ones. Use the `/tmp→iCloud` copy protocol from `cv-campaign-export`. Use the shortened path format for all paths — `cv-campaign-<YYYY-MM-DD>/<filename>` only, never the full iCloud path.

**To append (role 2+):** Read the existing state.json, parse the `roles` array, push the new role object, and write the full updated JSON back. Do not use `cat >` on a file that already exists — that overwrites the file and loses all previous role entries.

```json
{
  "session_date": "<YYYY-MM-DD>",
  "roles": [
    {
      "notion_page_id": "<id | null for --now mode roles>",
      "company": "<company>",
      "company_dir": "<company_dir>",
      "title": "<title>",
      "track": "<cv | now>",
      "status": "completed",
      "cv_path": "<company_dir>/<cv_filename>.docx",
      "cover_letter_path": "<company_dir>/<coverletter_filename>.docx",
      "feedback_path": "<company_dir>/feedback-<roletitle>-<company>-<monYYYY>.md",
      "hm_cv_verdict": "<Yes|Conditional|No>",
      "hm_cl_verdict": "<Proceed|Return>",
      "revision_log_path": "<company_dir>/revision-log-<roletitle>-<company>-<monYYYY>.md",
      "draft_dir_url": "https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F",
      "role_emphasis": "<1-2 sentence real mandate interpretation>",
      "jd_proof": "<verbatim quote from JD>",
      "keywords": "Critical: <terms> | Important: <terms> | Nice-to-have: <terms>",
      "strategy": "<lead proof point + summary direction — no interview prep>",
      "date_first_advertised": "<YYYY-MM-DD | estimated range | Unknown>",
      "remote_compatibility": "<Confirmed worldwide | Confirmed region-restricted ([region]) | Ambiguous — [reason]>"
    }
  ]
}
```

**Field notes:**
- `track` — `cv` for New Applications pipeline, `now` for --now mode
- `notion_page_id` — `null` for --now mode roles that were never in Notion
- `company_dir` — the kebab-case company directory name (same as used for the subdirectory)
- `hm_cv_verdict` / `hm_cl_verdict` — record both verdicts separately; omit `hm_cl_verdict` if the cover letter loop did not complete
- `date_first_advertised` / `remote_compatibility` — from the coach's research output; write `null` if not available (e.g., content-exists roles where coach skipped fetching)
- All paths are relative to the campaign folder (e.g., `company-name/cv-{{USER_LAST_NAME}}-[role-title]-company-name-may2026.docx`). Hebrew files are not listed separately — they are in the same `company_dir` and accessible via the Draft Directory URL.

### Step 7c — Write pipeline outputs to Notion properties

Write the following properties using `notion-update-page`. All values are already in memory.

**Coach-owned properties** — write verbatim from the coach's output in Step 0.8. Do not rewrite or reinterpret.

| Property | Source |
|---|---|
| `Role emphasis` | Employment coach output — verbatim |
| `JD proof` | Employment coach output — verbatim |
| `Keywords` | Employment coach output — verbatim |
| `Strategy` | Employment coach output — verbatim |
| `Role Type` | Employment coach output — verbatim |
| `Relationship type` | Employment coach output — verbatim |
| `Gap handling` | Employment coach output — verbatim. If {{USER_FIRST_NAME}} edited this in Notion before the pipeline ran, her version is already there; do not overwrite it. |
| `Role summary` | Employment coach output — verbatim. |
| `Person who Advertised Role (if not Hiring Manager)` | Employment coach output — verbatim. |
| `Hiring manager's role` | Employment coach output — verbatim. |
| `Manager role confirmed` | Employment coach output — verbatim. |
| `No other Marketing roles employed by company` | Employment coach output — verbatim. |

**Pipeline-derived properties**

| Property | What to write |
|---|---|
| `Hiring Manager` | Hiring manager name and title from the coach's research. Write "Not identified" if none found. |
| `Last Pipeline Run` | Today's date in ISO format (YYYY-MM-DD). |
| `Status` | `CV Ready for Review` — set once DOCX export and writeback are confirmed complete. |
| `Draft Directory` | The Draft Directory URL for this role's directory (generated in export Step 7). Written in Step 7a. |

**Property discipline** — write only the properties listed above. Nothing else.

- Do NOT write CV text, cover letter text, revision logs, or reviewer feedback to Notion. Reviewer feedback goes to the feedback markdown file (Step 7d), not to Notion.
- Do NOT write to the `Note` field. It is {{USER_FIRST_NAME}}'s space.

If any writeback fails, log it and surface it in the final chat delivery. The state.json holds all data as a fallback.

### Step 7d — Save reviewer feedback file

Write a single markdown file to the iCloud output folder. This is the one file {{USER_FIRST_NAME}} reads — it contains reviewer feedback from all four review passes plus the cv-writer's change log.

**Filename:** `feedback-<roletitle>-<company>-<monYYYY>.md`  
(Use the same slug format as the CV and cover letter files for this role.)

**File content:**

```markdown
# Feedback — <Role Title> at <Company> — <YYYY-MM-DD>

## CV Changes

<paste the full ## CV CHANGES section from cv-writer Step 4 here>

---

## Recruiter Review — CV

<paste the full verbatim output from recruiter-reviewer Step 2 here>

---

## Hiring Manager Review — CV

<paste the full verbatim output from hiring-manager-reviewer Step 3 here>

---

## Recruiter Review — Cover Letter

<paste the full verbatim output from recruiter-reviewer Step 5.3 here>

---

## Hiring Manager Review — Cover Letter

<paste the full verbatim output from hiring-manager-reviewer Step 5.5 here>

---

## Opening Paragraph Feedback

<If any reviewer (recruiter or HM) flagged the cover letter opening paragraph negatively, quote their exact feedback here — even if it was not acted on. If letter-writer's revision log includes "opener feedback noted — not revised per pipeline rules", paste that note here too. If no opener feedback exists, write "None.">
```

Write this file directly to the role's company subdir using the same `/tmp → iCloud` copy protocol as the DOCX files:

```bash
cat > /tmp/<feedback_filename>.md << 'MARKDOWN_EOF'
<full feedback file content>
MARKDOWN_EOF

cp /tmp/<feedback_filename>.md "<output_dir>/<company_dir>/<feedback_filename>.md"
```

Verify the file exists and is nonzero. If the write fails, log it in the final chat delivery — it is not a blocking error; the pipeline has already completed.

### Step 7e — Note new bullets in role state

After Step 7d, record in state.json that this role produced new (unapproved) bullets this run:

```json
"bullets_status": "new"
```

This flag is read by the orchestrator's Step 9b (bullet approval prompt) at the end of the full run. Roles where bullets were already approved in a prior run and no new bullets were written do not need this flag set.
