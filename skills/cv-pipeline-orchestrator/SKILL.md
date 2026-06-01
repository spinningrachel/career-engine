---
name: cv-pipeline-orchestrator
description: Run {{USER_FIRST_NAME}}'s CV campaign pipeline against her Notion Job Applications database. Trigger whenever {{USER_FIRST_NAME}} says "run CV campaign", "process the CV queue", "run the CV pipeline", or any variant referencing a batch of tailored CVs or cover letters or tech-writer reframe pitches. Fetches all queued roles from Notion, passes them to the employment coach (which fetches JDs and produces strategic properties), builds the processing queue, and routes each role to the pipeline {{USER_FIRST_NAME}} specifies in chat.
---

# CV Campaign Orchestrator

## Role

The orchestrator coordinates {{USER_FIRST_NAME}}'s CV campaign from start to finish. It fetches roles, delegates every reasoning and writing task to sub-agents, routes outputs, and delivers a concise final summary. It does not write CVs or cover letters, does not review applications, and does not make judgment calls about fit.

The Standard pipeline produces three deliverables per role: a tailored CV, a cover letter, and a reviewer feedback file. All three are required outputs.

Sub-agents handle all reasoning work. Mechanical actions — Notion queries, priority writeback, DOCX export, Notion writeback, feedback file — run inline without spawning sub-agents.

---

## Absolute Constraints

These rules govern every run without exception. Read them before doing anything else.

**The orchestrator runs in the main session context — never as a spawned subagent.**

The orchestrator uses Bash to write files (markdown, DOCX, state.json, feedback) to {{USER_FIRST_NAME}}'s iCloud folder. Bash in a sandboxed subagent context does not have access to the real filesystem and cannot write to iCloud — it will silently write to a session scratchpad instead. Therefore: the orchestrator must always be invoked directly in the main session, not spawned via the Agent tool. Only analysis and writing agents (cv-writer, letter-writer, reviewers, gatekeeper) are spawned as subagents — they return text only, they do not write files.

**Outputs go to {{USER_FIRST_NAME}}'s iCloud folder — never to a session scratchpad.**

The only valid output destination is:
`/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-<YYYY-MM-DD>/`

**Mandatory path verification — run this before processing the first role:**

```bash
OUTPUT_DIR="/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-$(date +%Y-%m-%d)"
mkdir -p "$OUTPUT_DIR"
# Verify — if this path does not contain "Mobile Documents", stop immediately
echo "$OUTPUT_DIR" | grep -q "Mobile Documents" || { echo "ERROR: Output dir is not iCloud. Aborting."; exit 1; }
echo "Output dir confirmed: $OUTPUT_DIR"
```

If this check fails or the path does not contain "Mobile Documents", **stop the run immediately** and report the error to {{USER_FIRST_NAME}}. Do not proceed and do not fall back to any other path. Do not use `./outputs/`, relative paths, or any path containing "local-agent-mode-sessions" or "Application Support".

**Three to five files per role, one file per run.**

The Standard pipeline produces three files per role (CV DOCX, cover letter DOCX, reviewer feedback MD) plus up to two additional Hebrew files when `Languages` includes `Hebrew` (Hebrew CV DOCX, Hebrew cover letter DOCX). One file per run (LinkedIn updates MD). The DOCX files follow the same production path: cv-writer or letter-writer outputs styled markdown → the orchestrator writes the markdown to `/tmp/` → pandoc converts to `.docx` using the `.dotx` reference templates → files copy to the iCloud output folder. The reviewer feedback file is written in Step 7d. The LinkedIn updates file is written in Step 8 after all roles complete. Writing markdown to `/tmp/` is a required production step, not optional.

**Load `cv-campaign-export` before processing the first role.**

If `cv-campaign-export` is not loaded when you reach the DOCX export step, back up and load it.

**Run end-to-end. Do not stop to ask {{USER_FIRST_NAME}} about scope mid-run.**

The employment coach caps the run and selects which roles process this session. That cap is the decision. Do not pause after Role 1 to ask whether to continue. Do not ask whether to batch DOCX conversion. Do not ask whether the run is too long.

If a single role fails, log the failure and move to the next role. The only valid mid-run pauses are a hard unrecoverable system error or {{USER_FIRST_NAME}} explicitly typing a stop command in chat.

**Cover letters lead with strength and never volunteer scope or qualifications.**

This rule governs every agent that touches cover letter content:
- Different domains and verticals are never a gap, never a weakness, and never referenced as a limitation in a cover letter.
- If there is any perceived skill gap a hiring manager might notice, the letter names the work {{USER_FIRST_NAME}} has done, names what was actually done, and lets it stand. It does not add a scope qualifier the hiring manager did not ask for. Phrases like "one product, not a portfolio," "smaller than the rest of my CV," "narrower than full-time" — all forbidden.
- If letter-writer or any cover letter agent produces language that qualifies, hedges, or volunteers scope, return it for revision before accepting the output.

---

## Configuration

**Job Applications database:** Notion database ID `3465ef1aa63480a283cfdf847cb47404`. Source of job descriptions and destination for per-role updates.

**Output folder:** `/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-<YYYY-MM-DD>/`

Each role's files go in a subdirectory inside the campaign folder named after the hiring company (see company directory naming convention in `cv-campaign-export`). After all files for a role are produced and verified, the orchestrator writes the file directory URL to the `Draft Directory` URL property on the Notion row. All English and Hebrew files for the role are accessible from that directory URL.

**`Draft Directory` property:** URL property. Written once per role when DOCX export (and Hebrew export if applicable) is confirmed. Value formula:

```
https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F
```

Where `<date-folder>` = the campaign folder name (e.g. `cv-campaign-2026-05-26`) and `<company_dir>` = the kebab-case company directory name.

**`Languages` property:** Multi-select on the Notion row. Expected options: `English`, `Hebrew`. If `Hebrew` is present, the pipeline automatically runs the Hebrew localization step (Step 6H) after English DOCX export and produces two additional DOCX files in the same company subdirectory. No extra configuration required.

---

## Skills to Load

Load these skills in order before doing anything else. Do not begin processing until all five are loaded.

**Note:** `who-rachel-is.md` is pre-loaded by the `/cv-campaign` command. If invoking the orchestrator directly (not via the command), load `references/who-rachel-is.md` first — it contains the fabrication rule and all constraint definitions that every downstream agent depends on.

1. `cv-campaign-intake` — Steps 0 through 0.9c: Notion fetch, JD fetching, coach invocation, priority writeback, queue building, Q&A questions
2. `cv-campaign-role-steps` — Steps 1 through 7: per-role CV writing, gatekeeper checks, reviews, cover letter (letter-writer), HM cover letter review, DOCX export (including Step 6H Hebrew), Notion writeback
3. `cv-reframe-pipeline` — Steps R1 through R3: Reframe only pipeline; cv-writer produces a tailored CV — no cover letter produced
4. `cv-edit-pipeline` — Steps E0 through E10: editing pipeline for `Needs editing` roles; starts from existing Notion row content, not from scratch
5. `cv-campaign-export` — DOCX template styles, pandoc commands, file naming, `/tmp → iCloud output folder` copy protocol, page count verification

## Notion Property Ownership

Each Notion property in the Job Applications database has a single designated owner. Agents write each piece of information once, to the correct field, and must not duplicate content across properties.

**Employment coach owns exclusively:** `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Role summary`, `Company Stage`, `Person who Advertised Role (if not Hiring Manager)`, and `Priority`. These reflect the coach's expert reading of what the role demands. No other agent rewrites or second-guesses them. **`Gap handling` is the exception to the carry-forward rule — if {{USER_FIRST_NAME}} has edited it in Notion, the pipeline reads her version as authoritative.**

**Mandatory value rule:** Every coach-owned property must receive an explicit value on every run. If a property is genuinely not applicable, write `N/A` — a blank field signals agent failure, not inapplicability. This applies to all property types including `Company Stage` and `Role Type`. **Prerequisite:** `N/A` must be present as a valid option in the Notion select fields for `Company Stage` and `Role Type` — {{USER_FIRST_NAME}} adds this directly in Notion.

**Letter-writer owns:** `Q&A` (interview questions generated in Step 0.9c). This property must also receive an explicit value or `N/A` — it is never left blank after the letter-writer has run.

**{{USER_FIRST_NAME}} owns exclusively:** `Additional Letter Writer Details`. This field is {{USER_FIRST_NAME}}'s response after reviewing the PMM Expert's positioning analysis from the standalone research pipeline. Agents read it — never write to it. If empty, agents apply the positioning restriction (no company positioning content in the letter). If populated, agents include only what {{USER_FIRST_NAME}} specified.

**The `Note` field is {{USER_FIRST_NAME}}'s space.** Agents may write to it only for context that structured properties cannot carry — never to repeat or summarize content already in a structured property.

---

## Role Type Definitions

Role Type is a multi-select property set exclusively by the employment coach. Choose all that apply — roles commonly combine types.

| Value | Definition |
|---|---|
| `Builder` | First or founding hire; building the function or infrastructure from zero with no team or existing motion |
| `Scaler` | Growing an existing function, managing a team, scaling what's already working |
| `Specialist` | Deep domain expert hired for a specific craft without a function-building mandate |
| `Leader` | Explicitly managing people; leadership-team membership expected from day one |

Multi-select examples: "Builder, Leader" = founding hire who also owns people management. "Scaler, Specialist" = growing a specialist function (e.g., scaling a PMM team with deep product marketing craft required).

**Effect on CV structure:** Builder or Leader → one-line skills, no Key Achievements section (function-builder framing). Scaler or Specialist → categorized skills block, compact Key Achievements acceptable (craft/scaling framing). When combined, lead with the stronger signal for the specific JD.

---

## Status Definitions

Status is the single property that drives what the pipeline does with a role. {{USER_FIRST_NAME}} sets and updates it in Notion; agents update it at pipeline completion only.

| Status | Who sets it | Meaning |
|---|---|---|
| `Hold` | {{USER_FIRST_NAME}} | Being researched before a decision to apply. **NOT handled by this (CV-writing) pipeline.** Two pre-campaign paths can process Hold roles: the coach standalone pipeline (`/cv-campaign coach`) for full market intelligence (competitive landscape, PMM analysis), or cv-campaign-intake standalone for quick coach properties and Q&A. Both promote Hold roles to Researched when complete. |
| `Interested` | {{USER_FIRST_NAME}} | {{USER_FIRST_NAME}} has decided to apply. **This is what cv-campaign-intake and the main CV campaign pipeline pull.** Move a role from Hold → Interested (or add directly as Interested) when {{USER_FIRST_NAME}} wants a CV and cover letter produced. |
| `Needs editing` | {{USER_FIRST_NAME}} | Queued for the editing pipeline. Pipeline starts from existing outputs in the Notion row — does not run fresh. |
| `CV Ready for Review` | Pipeline (on completion) | Pipeline finished; {{USER_FIRST_NAME}} needs to review before sending. |
| `Applied` | {{USER_FIRST_NAME}} | Sent. |
| `Researched` | Coach standalone pipeline (on completion) | Coach has run market intelligence — competitive landscape, priority scoring, strategic properties, PMM expert analysis. Role is ready for {{USER_FIRST_NAME}} to decide whether to move to Interested. |

**Pipeline reads:** `Interested` (main pipeline and cv-campaign-intake) and `Needs editing` (editing pipeline). All other statuses — including `Hold` and `Researched` — are ignored by this pipeline.

**The two pre-campaign pipelines are separate:**
- `/cv-campaign coach` → researches **Hold** roles → sets Status to **Researched**
- `cv-campaign-intake` (Steps 0–0.9c) → prepares **Interested** roles → feeds the CV writing pipeline

---

## Priority Definitions

**`Priority`** is the sole queue ordering signal. It is set by the employment coach on every run — for every role the coach processes. The coach scores all roles, confirms or revises existing scores, and always writes a value. Values and meanings:

| Label | Notion value | Meaning |
|---|---|---|
| `Highest` | `1` | Urgent — drop everything, run this role first |
| `First` | `2` | Excellent fit — strong domain, right seniority, right stage, no red flags |
| `Second` | `3` | Strong fit — domain or seniority match is clear; minor friction elsewhere |
| `Third` | `4` | Reasonable fit — worth applying but the cover letter has work to do |
| `Fourth` | `5` | Weaker fit — possible if {{USER_FIRST_NAME}} wants to stretch |
| `Fifth` | `6` | Weakest fit in this batch. Also the hard floor for Open Application entries regardless of any other criterion. |

**Always write the numeric Notion value (1–6) when setting Priority via `notion-update-page`.** The label names are internal shorthand — Notion rejects them as select values.

Roles with `Priority` already set are always selected into the queue before unscored roles, ordered 1 → 6. Unscored roles fill any remaining slots and are scored by the coach in Step 0.8.

**Open Application hard floor:** Roles identifiable as open/speculative/unsolicited applications (no specific listing posted) must always sort and be treated as `6` (Fifth) in the queue, regardless of any Priority value currently in Notion. The coach will write `6` to Notion in Step 0.8. If the coach is skipped (all coach-complete), verify any open application entry is set to `6` before queue ordering — correct it inline if not.

---

## Pipeline Flow

Run the queue pipeline first (`cv-campaign-intake`). When the processing queue is built and {{USER_FIRST_NAME}} has been briefed, run the per-role pipeline for each role in queue order.

**View URL override for cv-campaign-intake:** When `cv-campaign-intake` runs as part of this pipeline, it must query `Interested` roles, not `Hold`. Override the view URL in Step 0 to: `https://www.notion.so/3465ef1aa63480a283cfdf847cb47404?v=35e5ef1aa6348032abdb000ca4cf71ac`. The intake skill's default view returns Hold roles — the orchestrator specifies this override explicitly. Queue selection order also differs in orchestrator mode: scored roles first (ordered 1 → 6), then unscored (per the skill's orchestrator-mode rules in Step 0.7).

**Pipeline is determined by {{USER_FIRST_NAME}}'s chat command**, not by a Notion property she sets per-role. All `Interested` roles default to the standard cv pipeline unless {{USER_FIRST_NAME}} specifies otherwise in chat. {{USER_FIRST_NAME}} can request a different pipeline for specific roles at run time.

| Pipeline | What runs | Deliverables |
|---|---|---|
| `Standard` (default) | cv pipeline — Steps 1 through 8 | CV DOCX + cover letter DOCX + feedback MD |
| `Reframe only` | reframe pipeline — Steps R1 through R3 | CV DOCX; no cover letter produced |
| `--now` | fast track — see below | CV DOCX + cover letter DOCX + feedback MD |
| `Needs editing` | cv-edit-pipeline (separate skill) — Steps E0 through E10 | Updated CV DOCX + updated cover letter DOCX; starts from existing Notion outputs, not from scratch. Trigger when {{USER_FIRST_NAME}} says "edit CVs" or similar, or when roles have Status = Needs editing. |

The structured JD for each role was fetched in Step 0.5 of the queue pipeline and is already in memory. Pass it directly to per-role sub-agents — do not re-fetch.

---

## --now Mode (Single-Role Fast Track)

Use when {{USER_FIRST_NAME}} provides a URL or pastes a JD directly in chat and needs documents immediately, without going through the Notion queue. **No Notion interaction at all** — no reading, no writing.

### When to use
{{USER_FIRST_NAME}} says something like: "Write my CV for this now", "/cv-campaign --now <url>", "I just found this job, do it", or pastes a JD with an urgent framing.

### Flow

**Step N1 — Determine input**

Check what {{USER_FIRST_NAME}} provided:
- A URL → proceed to N2 with that URL
- Pasted JD text (no URL) → skip N2, treat the pasted text as the JD body and proceed to N3 directly

**Step N2 — Prepare JD content**

If {{USER_FIRST_NAME}} provided a URL: pass it directly to the coach in Step N3. The coach fetches it as part of its pre-flight.

If {{USER_FIRST_NAME}} pasted JD text (no URL): treat it as the JD body directly. Pass it to the coach in Step N3 — no fetch needed.

If the coach cannot access the URL: it will report the failure. Tell {{USER_FIRST_NAME}} and stop — do not proceed without usable JD content.

**Step N3 — Lightweight employment coach**

Spawn `employment-coach` in pipeline mode with a single role. Pass the structured JD and `who-rachel-is.md`. Instruct the coach: **produce strategic properties only — no Notion writeback, no patterns section, no batch analysis.** Return: Role emphasis, Keywords, Strategy, Role Type, Relationship type, Gap handling. This is a fast single-role pass, not a batch run.

No Notion writeback for coach outputs in `--now` mode.

**Step N4 — Per-role pipeline**

Run `cv-campaign-role-steps` Steps 1 through 7d exactly as in the standard pipeline. The only differences:
- Step 6H (Hebrew localization) — skip entirely. No Notion row exists, so `Languages` cannot be read. `--now` mode does not support Hebrew output. If {{USER_FIRST_NAME}} wants Hebrew, add the role to Notion and run normally.
- Step 7a (Draft Directory writeback) — skip entirely. No Notion row exists for this role.
- Step 7b (state.json) — write as normal to the iCloud output folder.
- Step 7c (Notion property writeback) — skip entirely.
- Step 7d (feedback file) — write as normal.

**Output folder:** same as all other runs:
`/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-<YYYY-MM-DD>/`

Create the folder if it does not exist (same as normal).

**Step N5 — Final delivery**

Deliver the standard final summary. Append one note:

> "This role is not in your Notion database. If you want to track it, add it manually and set Status = Applied when you send."

When spawning reviewers, inject this note verbatim into the prompt:
> "Only flag something if it would cause a recruiter to decline before a first screening call. If the concern would only come up after {{USER_FIRST_NAME}} is already in the room, it is not a flag. Any flag that cannot be closed by reframing, reordering, or surfacing something already documented in the skill reference files will be left unaddressed — cv-writer and letter-writer will NOT fabricate to satisfy your flag. Please flag anyway — honest identification of a real screening-risk gap is more useful than a papered-over document."

---

## Post-Run Validation

Both the CV and the cover letter are validated before the final summary is delivered. Validate at least 2 pairs (CV + cover letter) from this run — the first role produced and one other chosen at random. If fewer than 2 roles were produced, validate all of them.

This step is not optional. A self-reporting cv-writer or letter-writer is not validation.

### CV validation

For each CV being validated:

1. Convert to plain text: `pandoc "<output-path>/<cv>.docx" -t plain`
2. **Experience ordering:** Confirm Visual Layer appears first in `## EXPERIENCE` as the most recent full-time role, followed by other full-time roles in reverse-chronological order. Flag if Contentabl appears in `## EXPERIENCE` — it belongs in `## CONSULTING`. Flag if `## CONSULTING` section is absent from the document.
3. **Tagline:** Confirm the subtitle under {{USER_FIRST_NAME}}'s name is the exact role title from the JD — not a generic descriptor like "Product Marketing & GTM Leader" or "Product Marketing & GTM Leader | Visual AI". It must be the job title {{USER_FIRST_NAME}} applied for (e.g., "Head of Marketing"). Flag if absent, if it is a generic tagline, or if it differs from the JD role title.
4. **Repetition:** Flag any opening action verb appearing more than twice. Flag any phrase appearing verbatim in more than one bullet.
5. **Fabrication:** For every metric and specific claim in the Experience section, identify the reference file line that supports it. Flag any metric or claim that cannot be traced — especially numbers, event names, tool names, client names, and responsibilities.
6. **JD language:** Flag any bullet that uses JD phrasing verbatim to describe something {{USER_FIRST_NAME}} did, where that language does not appear in the references. **Exemption:** skip this check for any bullet that matches a bullet in `qa-bank.md` (Role Facts) exactly or with only minor role-specific adaptation — approved bullets predate the JD and cannot have been lifted from it.

If flags found: append them to the matching role's revision log file (`revision-log-<roletitle>-<company>-<monYYYY>.md`) under a `## CV Validation Issues` section.
If no flags: append a single line to the revision log: `CV validation passed.`

### Cover letter validation

For each cover letter being validated:

1. Convert to plain text: `pandoc "<output-path>/<cover-letter>.docx" -t plain`
2. **Greeting:** Confirm the letter opens with "Hi to the" — not "Dear" or any formal variant.
3. **Word count:** Count body words (excluding greeting and sign-off). Flag if outside 230–290 words.
4. **VL exit signal:** Confirm at least one of these appears naturally in the body: "Visual Layer", "ARR from $1M to $3M", "acquisition", "Camtek", "$7M". Flag if absent.
5. **Sign-off:** Confirm the letter closes with "Looking forward to next steps," followed by "{{USER_FULL_NAME}}" and nothing else. Flag any additional text after the name.
6. **Opening paragraph:** Confirm the first paragraph is {{USER_FIRST_NAME}}'s personal reaction to this specific role — first person, her response to the opportunity, before any credential or company description. This check cannot be waived by coach output or Strategy. Flag if the first paragraph: leads with company analysis; leads with a career credential; leads with an availability statement; OR has {{USER_FIRST_NAME}} as the grammatical subject of the first sentence but the sentence pivots immediately to a general market/industry observation rather than her reaction to THIS role (Pattern G2 — e.g. "I've spent six years in cybersecurity PMM, and the job — above everything else — is finding the right words for a market where half the vendors say the same thing."). Also flag if the very first sentence frames an industry challenge or market condition before {{USER_FIRST_NAME}} appears as a reacting subject (Pattern I).
7. **Fabrication:** For every specific claim, number, or named outcome in the letter, identify the reference file line that supports it. Flag any claim that cannot be traced to `who-rachel-is.md`.
8. **Voice:** Flag any sentence that opens with a gerund, prepositional phrase, or dependent clause instead of {{USER_FIRST_NAME}} as subject. Flag any hollow phrase from the banned list in `skills/cover-letter/SKILL.md`.

If flags found: append them to the matching role's revision log file under a `## Cover Letter Validation Issues` section.
If no flags: append a single line to the revision log: `Cover letter validation passed.`

---

## State File

`state.json` is a crash-recovery file — not a run-history log. It records roles that reached Step 7b (post-DOCX, pre-Notion-writeback or later). A role that crashed before Step 7b will not appear in it at all.

**`state.json` is the authoritative source for crash recovery:**

If a `state.json` exists in the most recent campaign folder and a role is marked `completed` in it, **skip that role** — regardless of when the run was, regardless of the role's current Notion Status. The most recent `state.json` represents actual pipeline progress. Notion writeback may have failed without invalidating what is on disk.

**When to process from scratch:** If no `state.json` exists, or a role does not appear in it as `completed`, run the full pipeline for that role from the beginning. `Interested` roles not in `state.json` always run fresh.

`Needs editing` → always run the editing pipeline using whatever is in the Notion entry. state.json is not used for the editing pipeline.

---

## --status Mode

Read-only. No agents. No Notion. Just reads the filesystem.

**Step S1 — Find the most recent run folder**

```bash
ls -1d "/Users/rachel/Library/Mobile Documents/com~apple~CloudDocs/Main Directory/Professional/Employment/CVs jobsearch and hiring/cv-campaign-"* | sort | tail -1
```

If no campaign folder exists, report: "No campaign runs found."

**Step S2 — Read state.json**

```bash
cat "<most-recent-folder>/state.json"
```

If state.json is missing, report: "state.json not found in `<folder>` — run may not have started or crashed before any role completed."

**Step S3 — Check files on disk**

For each role in state.json, verify the expected files exist. `cv_path` and `cover_letter_path` are relative to the campaign folder and already include the company subdirectory (e.g. `nuvoton/cv-{{USER_LAST_NAME}}-...docx`). Hebrew file presence is inferred from the `languages` field in state.json — if it contains `"Hebrew"`, check for Hebrew DOCX files in the same company subdirectory.

```bash
ls "<most-recent-folder>/<cv_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<cover_letter_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<feedback_path>" 2>/dev/null && echo "✓" || echo "MISSING"
ls "<most-recent-folder>/<revision_log_path>" 2>/dev/null && echo "✓" || echo "MISSING"
# Hebrew files — derive expected filenames from cv_path/cover_letter_path with -he suffix, check only if languages includes Hebrew
```

**Step S4 — Print summary**

```
## Campaign status — <session_date>

Completed: N roles  ·  Files missing: M

| Company | Role | Track | CV | Cover letter | Hebrew CV | Hebrew CL | Feedback | Revision log | HM CV | HM CL |
|---|---|---|---|---|---|---|---|---|---|---|
| <company> | <title> | <track> | ✓/MISSING | ✓/MISSING | ✓/—/MISSING | ✓/—/MISSING | ✓/MISSING | ✓/MISSING | <hm_cv_verdict> | <hm_cl_verdict> |
...
Note: — means no Hebrew was produced for that role (Languages did not include Hebrew).

<if all files present for all roles>
All files accounted for. Notion writebacks happened during the run — check row Status in Notion to confirm.

<if any file MISSING>
Files marked MISSING exist in state.json but were not found on disk. See Crash Recovery below.
```

If any role's cover_letter_path is null or empty in state.json, note it: that role may have crashed before the cover letter completed.

---

## Crash Recovery

### What state.json captures — and doesn't

state.json records roles that **completed Step 7b** (all three files produced, state written). It does not capture:
- Roles that started but crashed before DOCX export
- Which step within a role's pipeline failed
- Whether Notion writeback (Steps 7a, 7c) succeeded after state was written

### Diagnosing where a run crashed

**If state.json has fewer roles than expected:** One or more roles crashed before completing. The crashed role will still have Status = `Interested` in Notion. Check the iCloud output folder for partial files (markdown backups from Steps 4 and 5.7 land there as `.md` files).

**If state.json has all expected roles but a file is MISSING on disk:** The state was written but the file copy failed or was deleted after the run. The markdown source file in `/tmp/` is gone; re-run that role.

**If state.json is complete and all files are present but Notion rows still show `Interested`:** Step 7c (Notion writeback) failed after state was written. The files are good. Manually update each Notion row: set Status to `CV Ready for Review` and write the Draft Directory URL to the `Draft Directory` property (construct it from the `draft_dir_url` field in state.json, or derive it from the formula using the campaign folder date and company directory name).

### Which steps are safe to re-run

All agent steps are stateless and safe to re-run. They produce the same class of output each time — a fresh draft, review, or revision — and overwrite the previous output intentionally.

| Step | Safe to re-run? | Notes |
|---|---|---|
| 0.5 — JD content prep | Yes | Idempotent; only writes if JD Body was empty |
| 0.8 — employment coach | Yes | Fetches JDs + overwrites Notion properties ([HIGH] tags); [LOW] only fills empty |
| 1 — cv-writer draft | Yes | Overwrites previous draft |
| 1.5 / 4.5 / 5.2 / 5.8 — gatekeeper | Yes | Pure check, no side effects |
| 2 / 5.3 — recruiter-reviewer | Yes | Pure review, no side effects |
| 3 / 5.5 — hiring-manager-reviewer | Yes | Pure review, no side effects |
| 4 — cv-writer revision | Yes | Overwrites draft; markdown backup re-saved |
| 5 — letter-writer draft | Yes | Overwrites previous draft |
| 5.7 — letter-writer revision | Yes | Overwrites draft; markdown backup re-saved |
| 6 — DOCX export | Yes | Overwrites existing DOCX files (harmless if content unchanged) |
| 7a — Draft Directory writeback | Yes | Idempotent; same URL written |
| 7b — state.json | **Caution** | Appends a new record; creates a duplicate if role already in state.json. Not harmful but makes --status output noisy. |
| 7c — Notion property writeback | Yes | Idempotent; same properties written |
| 7d — feedback file | Yes | Overwrites existing feedback file (harmless) |

### The most common crash scenario: good DOCX, no Notion writeback

If the pipeline produced both DOCX files and the feedback file but crashed before Step 7a or 7c:

1. Run `--status` to confirm the files are on disk.
2. In Notion, manually set the row's Status to `CV Ready for Review`.
3. Write the Draft Directory URL to the `Draft Directory` URL property. Construct it from the `draft_dir_url` field in state.json, or derive it using the formula:
   `https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F<date-folder>%2F<company_dir>%2F`
4. The role is done. Do not re-run it — the documents are good.

---

## Step 8 — LinkedIn Updates File

Run after all roles complete. Inline — no agent spawn. Produces one file per run (not per role): `linkedin-updates-<YYYY-MM-DD>.md`, saved to the iCloud output folder alongside the per-role files.

**Purpose:** Surface what the run's collective intelligence implies for {{USER_FIRST_NAME}}'s permanent LinkedIn profile — specifically, which keywords and framing choices recur across multiple JDs in this session, making them stronger signals than anything optimized for a single application.

### Step 8a — Aggregate keywords

The coach returned a tiered `Keywords` string for each role processed this run (format: `Critical: ... | Important: ... | Nice-to-have: ...`). Collect all of them.

For each role, split on `|` to extract the three tier strings, then split each tier on `,` to get individual terms. Normalize each term: trim whitespace, preserve original casing. Pool all terms across all tiers into a single frequency map — record how many roles each term appeared in and which companies. Terms from Critical and Important tiers carry more signal weight than Nice-to-have, but all feed the frequency map.

**Threshold logic:**
- 3+ roles → **high signal** — likely a permanent LinkedIn gap
- 2 roles → **medium signal** — worth considering
- 1 role → omit — JD-specific, not a profile signal

Note: With a 5-role cap per run, "2 roles" = 40% of the batch. That is a meaningful pattern, not noise.

### Step 8b — Extract summary phrases

For each completed role, read the saved CV markdown from the iCloud output folder:

```bash
# CV markdowns are saved in the role's company subdirectory alongside the DOCX files
cat "<output_dir>/<company_dir>/<cv_filename>.md" | awk '/^## SUMMARY/{found=1; next} found && /^[^#]/ && NF{print; exit}'
```

This extracts the first non-empty paragraph after the `## SUMMARY` heading — which is the summary paragraph. Store it paired with company name and role title.

If a markdown file is missing (role used a different path or failed), skip that role's summary and note it.

### Step 8c — Write the file

```bash
cat > "<output_dir>/linkedin-updates-<YYYY-MM-DD>.md" << 'MARKDOWN_EOF'
<full file content>
MARKDOWN_EOF
```

**File format:**

```markdown
# LinkedIn Updates — <YYYY-MM-DD> — <N> roles

*Accumulated across <N> roles this session. Terms appearing in multiple JDs are profile signals — they indicate what recruiters in your current target market are searching for.*

---

## Keywords

### High signal — appeared in 3+ roles this session

- **<term>** — <N> roles: <Company A>, <Company B>, <Company C>
- ...

*If a term here is not in your LinkedIn About section, headline, or Skills list, add it.*

### Medium signal — appeared in 2 roles this session

- **<term>** — <Company A>, <Company B>
- ...

*Worth adding if it fits naturally. Less urgent than high-signal terms.*

---

## Summary phrases — review against your LinkedIn About section

First 1–2 sentences from each tailored CV summary this session. If any of these are stronger than what you currently have in your LinkedIn About section, adapt them.

**<Company> — <Role Title>:**
> <first 1–2 sentences of the CV summary>

**<Company> — <Role Title>:**
> <first 1–2 sentences of the CV summary>

---

## Experience bullets — review manually

The CVs produced this run contain tailored bullet versions for each experience entry. Compare the saved CV markdown files to your current LinkedIn experience entries and update where the tailored version is meaningfully stronger.

Saved CV markdowns this run:
<list of cv_filename.md files from this run>
```

**Failure handling:** If the file write fails, log it and surface in final delivery. It is non-blocking — documents are already complete.

**Skip condition:** If only one role was processed this run (no cross-role signal possible), still write the file but note in the keywords section: "Only one role processed this session — no cross-run frequency signal. Review keywords for the single role in the CV directly."

---

## Step 9 — Run-level revision log

After all roles complete and after Step 8 (LinkedIn updates), write a single run-level revision log to the iCloud output folder:

**Filename:** `revision-log-<YYYY-MM-DD>.md`

```bash
cat > "<output_dir>/revision-log-<YYYY-MM-DD>.md" << 'MARKDOWN_EOF'
# Run Log — <YYYY-MM-DD> — <N> roles

## Cross-run decisions
<Any decision that affected all CVs or all roles. If none: "None.">

## Technical and orchestration issues
<Failures, fallbacks, writeback errors, and any unexpected or non-standard decisions made by any agent during the run. If none: "None.">
MARKDOWN_EOF
```

This file is non-blocking — if the write fails, log it in chat only.

---

## Step 9a — Q&A Bank Promotion

Run after Step 9 (revision log). Non-blocking — if any part fails, log the error in the revision log and proceed to Final Chat Delivery without stopping.

**Purpose:** Promote new Q&A answers from this run into `references/qa-bank.md` so the letter-writer never asks {{USER_FIRST_NAME}} the same question twice across future runs.

**Skip entirely if:** no role this run had a populated Q&A property with answers, or this is a `--now` run (no Notion interaction).

### Step 9a.1 — Collect Q&A content

For each role processed this run, retrieve the Q&A property value from Notion. Use `notion-fetch` on the role's page ID — the Q&A property was already read during the pipeline, so this is a lightweight re-read (or pull from memory if retained). Skip any role where Q&A is empty, null, or contains only questions with no answers.

### Step 9a.2 — Parse into pairs

Parse each Q&A text block into question/answer pairs. The format is free-form ({{USER_FIRST_NAME}} writes her answers directly into Notion), so be flexible:

- Split blocks on blank lines or numbered/labelled question patterns (`Q:`, `Question:`, `1.`, etc.)
- Treat the first line of each block as the question; everything after as the answer
- Skip any pair where the answer is missing or fewer than 10 characters — it hasn't been answered yet
- Skip any pair where the question is clearly role-specific (contains the company name or role title verbatim) — those are not reusable

### Step 9a.3 — Deduplicate against qa-bank.md

Read `references/qa-bank.md` (same directory as `who-rachel-is.md`). Extract all existing questions from the table.

For each new candidate pair, check whether a sufficiently similar question is already present:

```python
import re

def key_words(text):
    noise = {'what', 'have', 'your', 'does', 'with', 'that', 'this', 'from',
             'been', 'are', 'you', 'the', 'and', 'for', 'any', 'how', 'do'}
    return {w for w in re.findall(r'\b\w{4,}\b', text.lower()) if w not in noise}

def is_duplicate(new_q, existing_questions, threshold=0.5):
    nw = key_words(new_q)
    if not nw:
        return False
    for eq in existing_questions:
        ew = key_words(eq)
        if ew and len(nw & ew) / min(len(nw), len(ew)) >= threshold:
            return True
    return False
```

Anything scoring ≥ 0.5 overlap is a duplicate — skip it.

### Step 9a.4 — Append new entries

For each non-duplicate pair, append a new row to the qa-bank.md table:

```
| <question> | <answer> | Auto-promoted from Notion Q&A — <YYYY-MM-DD>. Review and edit if role-specific context should be stripped. |
```

Write all new rows in a single append operation. Do not rewrite the whole file — append only.

### Step 9a.5 — Log

Append to the run-level revision log under a new section:

```
## Q&A Bank Promotion
Added N new entries. [Or: No new entries — all Q&A was already in the bank, unanswered, or role-specific.]
```

---

## Final Chat Delivery

After Step 9a completes, deliver a single confirmation line in chat:

`All N roles completed. Files are in your iCloud job-search folder and Notion rows are updated.`

Nothing else. All feedback, validation results, and decisions are in the revision log files in the output folder.

---

## Execution Rules

- Run roles sequentially unless {{USER_FIRST_NAME}} explicitly asks for parallel execution.
- Narrate progress briefly between steps: "Role 3/5: recruiter review done, moving to hiring manager."
- Do not deliver individual role outputs during processing — deliver everything together at the end.
- If any step fails, log it and move on. All failures are written to the run-level revision log (Step 9).
- The fabrication rule is absolute. Every claim must trace to `who-rachel-is.md`. If it is not documented there, it does not exist.
