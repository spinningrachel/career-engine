---
name: career-engine-new-application
description: 'Per-role pipeline for the career-engine orchestrator. Handles Step 0.10 (warm-up role selection) and Steps 1 through 7 for New Applications pipeline roles: CV draft, gatekeeper, recruiter review, CV revision, cover letter draft, cover letter gatekeeper, cover letter coach review, cover letter revision, cover letter humanizer, final verification gate, DOCX export for both files, and Notion writeback. The structured JD for each role is already in memory from the queue pipeline — do not re-fetch. Load this skill as part of the career-engine pipeline, after career-engine-intake.'
---

# New Application — Per-Role Pipeline

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

This skill covers Step 0.10 and Steps 1 through 7 of the New Applications pipeline. Step 0.10 runs once before the per-role loop begins. Steps 1 through 7 repeat for each role in the processing queue. The structured JD was fetched in Step 0.5 and is in memory — pass it directly without re-fetching.

The pipeline produces two deliverables per role: a CV DOCX and a cover letter DOCX. The CV goes through: draft, gatekeeper, recruiter review, revision, gatekeeper (post-revision). The cover letter receives the recruiter review (including interview-trigger gaps) so the letter can proactively address gaps where documented background provides a real answer.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

---

## Step 0.10 — Warm-up role selection (for batch runs of 2 or more roles)

**Only applies when the processing queue contains 2 or more roles.**

Before processing the full queue, identify the warm-up role — the first role to process. The warm-up role's gatekeeper violations will be extracted and injected as pre-warnings into the cv-writer prompt for all remaining roles, reducing loops across the batch.

**Warm-up role selection logic:**
1. If any role in the queue has priority `Highest` — use the first one.
2. Otherwise, use the first `First` priority role in the queue.
3. If no `Highest` or `First` exists — use the first role in the queue regardless of priority.
4. Among ties, prefer {{USER_CITY}}/{{USER_COUNTRY}} location over remote.

**After the warm-up role completes Steps 1 through 4.5 (draft → gatekeeper → recruiter review → revision → gatekeeper):**

Extract recurring failure patterns from the gatekeeper violation logs. Specifically:
- Any tool name found in bullets (e.g., "ZoomInfo found in VL bullets")
- Any role missing RoleOverview (e.g., "[Company] missing RoleOverview")
- Any verb used 3+ times (e.g., "'Built' appeared 4 times")
- Any summary violation that repeated across loops

Build a `known_issues` note and prepend it to the cv-writer prompt for every subsequent role in the batch:

> "Pre-warnings from role 1 gatekeeper logs: [list violations]. Check for these specifically before returning your draft."

This is the only inter-role learning mechanism. It does not require agents to share state — the orchestrator extracts and injects the patterns explicitly.

---

### Step 0.pipe — Create the per-role pipeline directory

Before Step 1, create `<output_dir>/<company_dir>/_pipeline/` (the run's scratch area for intermediate text artifacts — reviewer feedback, revision logs, gatekeeper violations). Call this path `$PIPE`. On Path A use `mkdir -p`; on Path B create it through the host file tool (R-30). Every subagent below is given an exact `$PIPE/<file>.md` path to write to, and returns only a short status plus that path — never its full output (R-41). The orchestrator branches on the short status and, when a later step needs prior content, passes the path so that step reads it from disk. `_pipeline/` is intermediate only — it is not a deliverable and is not written to Notion.

### Step 0.data — Write role properties to `$PIPE/role-properties.md`

Immediately after creating `$PIPE`, write the role's Notion-sourced properties to disk before spawning any subagent. This file is the single on-disk record of role metadata for this pipeline run — it survives context compression and is available to every subagent in this role's pipeline as `$PIPE/role-properties.md`.

**Content to write:**

````markdown
# Role Properties — <Company> — <Role Title>

**Company:** <company name>
**Role title:** <role title>
**Strategy:** <IC / Strategic / Hybrid>
**Relationship type:** <Full time / Part time / Temporary / Fractional>
**Keywords:** <keywords string — tiered: Critical: ... | Important: ... | Nice-to-have: ...>
**Gap handling:** <value, or "disabled (empty)">
**Role summary (JD proxy):**
<full Role summary content — the compressed JD proxy including role context, key requirements, and self-characterization section verbatim if present>
````

**Write mechanics:** On Path A use the `Write` tool or `cat >` to write the file directly. On Path B (host-bridge MCP), use Desktop Commander `write_file` to create it host-side — same R-30 pattern as other `$PIPE/` writes.

---

## CV Steps (1 through 4.5)

> **Step numbering:** the CV stages are Steps 1, 1.5, 2, 4, and 4.5. There is no Step 3 — the numbering skips it intentionally; "Steps 1 through 4.5" is the full CV range.

### Step 1 — CV writer (draft)

Spawn `cv-writer` with `option=draft`, passing:
- `CAREER_DATA=${CAREER_DATA}`
- `Role summary` (the compressed JD proxy — contains role context, key requirements, and self-characterization section)
- The coach's output for this role: `Role emphasis`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`
- `CV_PATH=$PIPE/cv-draft.md` — the writer writes the draft there and returns the path (R-41).

**Note:** `Role summary`, `Strategy`, `Keywords`, `Relationship type`, and `Gap handling` are also written to `$PIPE/role-properties.md` (Step 0.data). Subagents that need a lightweight reference to role metadata may read from that file instead of receiving the full content inline in every spawn prompt.

### Step 1.5 — Gatekeeper (CV draft check)

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the CV path `$PIPE/cv-draft.md` to read, `Role summary`, the coach's `Keywords` property, and `OUTPUT_PATH=$PIPE/gatekeeper-cv-<round>.md`. The gatekeeper's ATS pre-check parses Keywords into tiers (Critical / Important / Nice-to-have) to verify coverage. It returns `PASS`, or `FAIL: <n> violations → <path>` (R-41).

**If PASS:** proceed to Step 2.

**If FAIL:** read the violation file at the returned path. If all violations are mechanical and unambiguous (swap two words, remove one phrase, reorder paragraphs — no creative judgment required), apply them inline to `$PIPE/cv-draft.md`. If any violation requires cv-writer judgment (rewriting a bullet, resolving a fabrication flag), spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `CV_PATH=$PIPE/cv-draft.md` (read and overwrite), the gatekeeper violation path, and the fix-log path `$PIPE/fix-log.md` (read and append). Locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL, and a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After fix, spawn `gatekeeper` again with `option=cv` (new `OUTPUT_PATH` round). Repeat until PASS. Do not surface this loop to the user — log violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 1.5)` section in the revision log, proceed to Step 2, and flag for the user in the final delivery that this CV needs manual review before sending.

### Step 2 — Recruiter review (CV)

Spawn `recruiter-reviewer` with `CAREER_DATA=${CAREER_DATA}`, `Role summary`, the CV path `$PIPE/cv-draft.md` to read, and `OUTPUT_PATH=$PIPE/recruiter-cv.md`. It writes its full review there and returns a 2-line status (R-41).

### Step 4 — CV writer (revision)

Spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `CV_PATH=$PIPE/cv-final.md` (write), the draft path `$PIPE/cv-draft.md`, and the recruiter review path `$PIPE/recruiter-cv.md` to read. The writer also writes the CV CHANGES section to `$PIPE/cv-changes.md` and returns the paths (R-41). Step 7d reads `$PIPE/cv-changes.md` for the feedback file.

If any recruiter flag identifies a skill or credential gap the user does not have — do not address it. IT SHOULD BE COMPLETELY OMITTED. Reframing, surfacing, and reordering are permitted; fabrication and scope-hedging ARE ABSOLUTELY PROHIBITED.

**Immediately after Step 4 returns — stage the revised CV markdown and the revision log for export and crash recovery before spawning the gatekeeper.** Context compaction can interrupt between any two steps, and disk is the only reliable recovery path. The writer has already written `$PIPE/cv-final.md` and `$PIPE/cv-changes.md` (R-41); copy them into place:

```bash
# CV markdown that pandoc consumes in Step 6
cp "$PIPE/cv-final.md" /tmp/<cv_filename>.md
# crash-recovery backup in the company subdir
cp "$PIPE/cv-final.md" "<output_dir>/<company_dir>/<cv_filename>.md"

# revision log, built from the writer's CV CHANGES file
{ echo "# Revision Log — <Role Title> at <Company> — <YYYY-MM-DD>"; echo; echo "## CV Changes"; cat "$PIPE/cv-changes.md"; } \
  > "<output_dir>/<company_dir>/revision-log-<roletitle>-<company>-<monYYYY>.md"
```

### Step 4.5 — Gatekeeper (CV final check)

Spawn `gatekeeper` with `option=cv`, passing `CAREER_DATA=${CAREER_DATA}`, the CV path `$PIPE/cv-final.md` to read, `Role summary`, the coach's `Keywords` property, and `OUTPUT_PATH=$PIPE/gatekeeper-cv-<round>.md`.

**If PASS:** proceed to Step 5.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `CV_PATH=$PIPE/cv-final.md` (read and overwrite), the gatekeeper violation path, and the fix-log path `$PIPE/fix-log.md` (read and append). Locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL, and a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, re-copy `$PIPE/cv-final.md` to `/tmp/<cv_filename>.md` and the output backup path before spawning `gatekeeper` again (new `OUTPUT_PATH` round). Repeat until PASS. Log all violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 4.5)` section in the revision log, proceed to Step 5, and flag for the user in the final delivery that this CV needs manual review before sending.

---

## Cover Letter Steps (5 through 5.8)

The cover letter receives the **final revised CV** as input. letter-writer uses it to ensure the letter and CV tell a coherent story and the letter adds something the CV cannot.

### Pre-Step 5 — Cover letter content inputs

**Skip in `--now` mode** — no Notion row exists.

Read the following from Notion for this role:

**Why I Want This Role property** — the user's written motivation for this role, filled in manually in Notion. If populated, pass the full content to the letter-writer as the role-specific content input. **Why I Want This Role is NOT required to produce a letter** — the letter-writer's primary source is the Motivation Bank (`background/background-motivation-bank.md`), and the letter-writer itself decides whether it has enough to write.

**Always proceed to Step 5 and spawn the letter-writer for this role — whether or not Why I Want This Role is populated.** Pass the Why I Want This Role value if present; if empty, pass it empty and let the letter-writer's **Sufficiency Gate** decide (write from the role-matched Motivation Bank entries, or skip). **Do NOT pre-skip the letter on an empty Why I Want This Role** — that decision belongs to the letter-writer now.

**If the letter-writer returns a skip status** (it judged there was no Why I Want This Role content and no role-relevant Motivation Bank material): this is not an error. Deliver the CV only for this role, log "Letter skipped — [reason returned by the writer]", and surface the writer's message to the user (it tells her to add Why I Want This Role or enrich the Motivation Bank). **This applies only to this role** — continue processing other roles normally.

---

### Step 4.9 — Voice calibration (pre-compute)

Spawn `voice-analyst`, passing `CAREER_DATA=${CAREER_DATA}` and `PIPE=${PIPE}`.

- **On `PASS`:** proceed to Step 5. The calibration file is at `$PIPE/voice-calibration.md`.
- **On `FALLBACK`:** proceed to Step 5. The calibration file contains voice data drawn from `03-framework.md §Voice` — the letter-writer uses it as-is.
- **On any other error:** log the failure. Proceed to Step 5 without passing `$PIPE/voice-calibration.md`. The letter-writer falls back to its standalone Voice Gate (reads the archive directly).

---

### Step 5 — Cover letter (draft)

**Before spawning letter-writer:** Read `${CAREER_DATA}/references/background/background-role-facts-<company>.md` for the user's role facts for this company — key proof points the letter-writer can draw from naturally rather than assembling pre-written paragraphs. Derive `<company>` from the company name in the Notion role record, slugified: lowercase, spaces and punctuation to hyphens (e.g., "Visit TLV" → `background-role-facts-visit-tlv.md`). If the file does not exist for this company, note it in the spawn context: "No pre-documented role facts file found for this company — letter-writer draws from the Motivation Bank, framework, and WIWTR only."

**Before spawning, pass the following for this role:**
- **Why I Want This Role property** — use the value retrieved in Pre-Step 5. Do not re-read from Notion.
- **Strategy** property — from the career coach
- **Gap handling** property — from the career coach

**Priority rule:** the **Motivation Bank** (`background/background-motivation-bank.md`, loaded by the letter-writer from career-data) is the primary content source; **Why I Want This Role** is the role-specific source on top of it **when present**. Strategy provides the letter type only — it does not govern content selection.

**Include this verbatim at the front of the letter-writer prompt:**
> STRUCTURE IS NON-NEGOTIABLE. Regardless of any reviewer feedback you receive, the letter structure defined in `cover-letter/SKILL.md` must be observed in full — in particular the tone, voice, and content of the opening paragraph. Reviewer feedback informs what proof to include or emphasise; it does not change how the letter is structured or how the opening is written.

Spawn `letter-writer` with `option=cover-letter`, passing:
- `CAREER_DATA=${CAREER_DATA}`
- `LETTER_PATH=$PIPE/letter-draft.md` — the writer writes the draft there and returns the path (R-41)
- The **final revised CV** path `$PIPE/cv-final.md` to read (for CV/letter coherence)
- `Role summary` (contains the role context, key requirements, and Company self-characterization section verbatim if present — this is the JD proxy for the letter-writer)
- The coach's Relationship type
- **Why I Want This Role** from Notion (read above) — the role-specific content input; include if populated (the letter-writer loads its primary source, the Motivation Bank, from career-data itself). If empty, pass it empty — the letter-writer's Sufficiency Gate decides write-or-skip.
- **Strategy** and **Gap handling** from Notion (read above) — secondary context; defer to the user's own words (Why I Want This Role or the Motivation Bank) on any conflict
- **Recruiter review** path `$PIPE/recruiter-cv.md` to read — includes the "Interview-trigger gaps" section: things clear enough to pass the recruiter screen but that would prompt a hiring manager question; the letter-writer uses these to proactively address gaps where Why I Want This Role or documented background provides a real answer. **Fabrication rules always trump reviewer input — even when a gap is passed, the letter-writer may only answer it with documented background or Why I Want This Role content. A reviewer flag does not authorise invention.**

### Step 5.2 — Gatekeeper (cover letter draft check)

Spawn `gatekeeper` with `option=cover-letter`, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter path `$PIPE/letter-draft.md` to read, `Role summary`, the user's Why I Want This Role content (from the Pre-Step 5 read), the final CV path `$PIPE/cv-final.md` to read (required for the CV-repetition check; if no CV exists for this role — including in `--now` mode where no CV pipeline ran — state that explicitly so the gatekeeper reports the skipped check by name; do not pass a path that doesn't exist), and `OUTPUT_PATH=$PIPE/gatekeeper-cl-<round>.md`. The Why I Want This Role content allows the gatekeeper to apply the personal-content exemption correctly — see the exemption rule at the top of Cover Letter Check in `gatekeeper-checks/SKILL.md`.

**If PASS:** proceed to Step 5.3.

**If FAIL — round 1:** spawn `letter-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `LETTER_PATH=$PIPE/letter-draft.md` (read and overwrite), the gatekeeper violation path, and the fix-log path `$PIPE/fix-log.md` (read and append). Locked-fixes instruction (see the orchestrator's Absolute Constraints): reintroducing a previously fixed violation is itself a FAIL, and a writer that reverts to an older base is re-spawned with the regression named — never patched by hand. After revision, spawn `gatekeeper` again with `option=cover-letter` (new `OUTPUT_PATH` round). Log all violation rounds internally.

**If FAIL — round 2+ (advisory violations only, no hard fails):** treat as PASS. Log the advisory violations under `## Gatekeeper — Advisory Violations Deferred to Humanizer (Step 5.2)` in the revision log, and proceed to Step 5.3. The humanizer handles residual advisory issues.

**If FAIL — round 2+ (hard fails present):** loop as above. Hard fails block every round.

**Cap: 3 revision passes on hard fails.** If the gatekeeper still returns hard-fail violations after pass 3, log all remaining violations under a `## Gatekeeper — Unresolved Violations (Step 5.2)` section in the revision log, proceed to Step 5.3, and flag for the user in the final delivery that this cover letter needs manual review before sending.

### Step 5.3 — Coach strategic letter review

After the gatekeeper passes the draft, spawn `career-coach` with `option=letter-review`, passing:
- `CAREER_DATA=${CAREER_DATA}`
- The cover letter path `$PIPE/letter-draft.md` to read
- `Role summary`, `Strategy`, `Keywords` (from the coach's Step 0.8 output)
- `Gap handling` property (so the review knows whether gap handling is off for this run — an **empty** `Gap handling` means it is disabled and there are no gaps; the review must then give zero gap feedback)
- Why I Want This Role content (from the Pre-Step 5 read) — pass verbatim, not summarized
- Company name and role title
- `OUTPUT_PATH=$PIPE/coach-letter-review.md`

The coach writes its diagnostic review to that file and returns: `COACH-LETTER-REVIEW: <n> issues → $PIPE/coach-letter-review.md`

**If issues identified:** spawn `letter-writer` with `option=revision`, passing `CAREER_DATA=${CAREER_DATA}`, `LETTER_PATH=$PIPE/letter-draft.md` (read and overwrite), the coach review path `$PIPE/coach-letter-review.md` as the revision brief, and `$PIPE/fix-log.md` (read and append). Locked-fixes instruction applies. After revision, spawn `gatekeeper` with `option=cover-letter` (new `OUTPUT_PATH` round, pass Why I Want This Role and CV path same as Step 5.2). **Cap: 1 coach-directed revision + 1 gatekeeper pass.** If gatekeeper fails after the revision, log the violations and flag the letter for manual review — do not loop further.

**If no issues identified:** proceed directly. Do not spawn letter-writer.

After this step, copy `$PIPE/letter-draft.md` to `$PIPE/letter-final.md`, `/tmp/<cl_filename>.md`, and the output backup path:

```bash
cp "$PIPE/letter-draft.md" "$PIPE/letter-final.md"
cp "$PIPE/letter-draft.md" /tmp/<cl_filename>.md
cp "$PIPE/letter-draft.md" "<output_dir>/<company_dir>/<cl_filename>.md"
```

---

### Step 5.9 — Humanizer (cover letter)

**Before spawning, snapshot the revert target:** copy `$PIPE/letter-final.md` (the Step 5.3-passing text) to a sibling `$PIPE/letter-final.prehumanizer.md` — the revert target for Step 5.95. (The humanizer edits in place, so this snapshot must be taken first.)

Spawn `cover-letter-humanizer`, passing `CAREER_DATA=${CAREER_DATA}`, the final cover letter markdown path `$PIPE/letter-final.md` (it edits in place), and `$PIPE/voice-calibration.md` (the pre-computed voice calibration from the voice-analyst; the humanizer uses it instead of reading the archive directly). Do not pass Role summary, strategy, JD, or any role-specific context — the humanizer's only inputs are the letter, the career-data path, and the voice-calibration file.

The humanizer is a writing editor and linguistics expert. It loads `skills/cover-letter-humanizer/SKILL.md` and removes AI writing patterns sentence by sentence. It does not change structure, strategy, or content — only language.

**Wait for the humanizer to finish** editing `$PIPE/letter-final.md` in place and writing its change log before proceeding.

After it returns, copy `$PIPE/letter-final.md` to `/tmp/<cl_filename>.md` and the output backup path. The humanizer writes its change log to `$PIPE/humanizer-changes.md`; append it to the revision log under `## Humanizer changes`.

If the humanizer fails or returns no changes, proceed with the pre-humanizer version (`$PIPE/letter-final.prehumanizer.md`, which already passed Step 5.3).

### Step 5.95 — Final verification on the exported bytes

The humanizer changed the text after the last PASS, so that PASS is no longer valid. Run both checks below on the **exact saved markdown** that Step 6 will convert:

1. **Mechanical pre-export checklist** — run directly, no subagent. On the letter body (ignore pandoc fence lines starting `:::` and `{custom-style=...}` attributes):
   - Company name appears in the first body paragraph (stealth roles: the JD descriptor satisfies this).
   - Role title appears somewhere in the body.
   - Zero em dashes (`—`) and zero colons in body text.
   - Zero hits for the named banned patterns: "I know this", "that's where", "that's what", "that's the kind", "that exact", "exactly that", "this same", "serves as", "stands as", "acts as"; also grep "the same" — a hit fails only when it points at an agent-coined abstraction ("the same engine"), not in benign uses ("the same week").
2. **Final gatekeeper pass** — spawn `gatekeeper` with `option=cover-letter` on this exact text, passing `CAREER_DATA=${CAREER_DATA}`, the cover letter path `$PIPE/letter-final.md` to read, `Role summary`, the user's Why I Want This Role content (same as Step 5.2), the final CV path `$PIPE/cv-final.md` to read, and `OUTPUT_PATH=$PIPE/gatekeeper-cl-<round>.md`.

**If both pass:** proceed to Step 6. **If either fails:** spawn `cover-letter-humanizer` again with `CAREER_DATA=${CAREER_DATA}`, `$PIPE/voice-calibration.md`, and the specific failures named (language-level issues) or `letter-writer` with `option=revision` passing `CAREER_DATA=${CAREER_DATA}` (content-level issues), then re-run this step. Cap: 2 rounds. After the cap, revert to the `.prehumanizer.md` file saved in Step 5.9 (the last text that passed Step 5.3) and flag the letter for manual review in the final delivery. Never export text that has not passed this step.

**Sync the passing bytes to the export path — do this on EVERY exit from this step, before Step 6 runs.** The retry branches above edit `$PIPE/letter-final.md` in place, and the revert branch restores `$PIPE/letter-final.prehumanizer.md` — in both cases the `/tmp/<cl_filename>.md` copy made in Step 5.9 is now stale, and Step 6 would convert the wrong bytes. After the verification passes (and after any revert), re-copy the authoritative final letter to the export working path and the output backup:

```bash
# Revert branch only: restore the last text that passed Step 5.3 as the final letter.
# cp "$PIPE/letter-final.prehumanizer.md" "$PIPE/letter-final.md"

# Both branches: re-sync the passing bytes Step 6 will convert.
cp "$PIPE/letter-final.md" /tmp/<cl_filename>.md
cp "$PIPE/letter-final.md" "<output_dir>/<company_dir>/<cl_filename>.md"
```

On Path B, run these copies through the host file tool (R-30), writing the intermediate markdown host-side rather than to sandbox `/tmp/`.

---

## Step 6 — Produce DOCX

**Before executing this step:** confirm `career-engine-export` is loaded. If it is not already in context, load it now — read `skills/career-engine-export/SKILL.md` before proceeding. Do not execute Step 6 without it.

Both the CV and the cover letter are now final markdown files saved to `/tmp/`. Convert both to `.docx` using pandoc with the `.dotx` reference templates. Run bash directly — no agent spawn needed. **On Path B (host-bridge MCP — see the orchestrator's Mandatory path verification, R-30), run these commands through the host process tool instead, with intermediate markdown written host-side rather than to sandbox `/tmp/`.**

Follow the `career-engine-export` skill's Step 6 production protocol exactly — it is the single authoritative source for pandoc commands, script paths, subtitle update, and verification. Do not substitute your own abbreviated steps. Both files must exist and be nonzero in the output folder before proceeding to Step 7.

**Subtitle argument:** Pass the exact role title from the JD as the subtitle argument to `update-subtitle.py` — the job title the user is applying for (e.g., "[Role Title from JD]"). This is the ONLY text that should appear in the subtitle slot under the user's name. Do not pass a generic descriptor, the user's background framing, or anything not directly taken from the JD role title field.

---

## Step 6H — Additional language localization (conditional)

**Skip in `--now` mode** — no Notion row exists, so there is no `Languages` property to read. Produce output in `$DEFAULT_LANGUAGE` only and proceed to Step 7.

**Language resolution rule — apply before deciding whether to run this step:**

1. Read the `Languages` property from this role's Notion row — the one the orchestrator/queue pipeline already fetched upstream and holds in memory. Do not re-fetch.
2. **If `Languages` is empty or not set:** produce output in `$DEFAULT_LANGUAGE` only. Skip this step entirely and proceed to Step 7.
3. **If `Languages` is populated:** produce output in every listed language. The `$DEFAULT_LANGUAGE` output has already been produced in Steps 1–5.95. This step handles all additional languages listed in `Languages` beyond the default.

**Hebrew localization — runs only if `Languages` explicitly includes `Hebrew`** (i.e. the `Languages` property is non-empty and `Hebrew` is one of its values). If `Hebrew` is not listed, skip Hebrew localization even if other non-default languages are listed.

### 6H.1 — Spawn Hebrew localization agent

Spawn `localization` with:
- `CAREER_DATA=${CAREER_DATA}`
- The final English CV markdown (read from `$PIPE/cv-final.md`)
- The final English cover letter markdown (read from `$PIPE/letter-final.md`)
- The structured JD — the same in-memory JD the queue pipeline fetched in Step 0.5 and passed through Steps 1–5. On a crash-recovery resume where that in-memory JD is no longer available, omit it: the localization agent translates from the on-disk English markdown above (the authoritative source content) plus the role title below — the structured JD is supplementary context, not required.
- The exact role title from the JD — on a resume where the in-memory value is gone, recover it from the `<roletitle>` slug in the staged English filenames / `<company_dir>` (the same slug Step 4 and Step 5.3 wrote to disk).

The agent returns a Hebrew CV markdown block and a Hebrew cover letter markdown block.

### 6H.2 — Export Hebrew DOCX files

Write the Hebrew markdown files to `/tmp/` **and** copy them to the output folder:

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

Convert using the Hebrew DOCX production protocol from `career-engine-export`:

```bash
HE_TEMPLATES="{{WORD_TEMPLATES_PATH}}"

# Hebrew CV — concatenate with Hebrew footer, then convert
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${HE_TEMPLATES}/cvHe.dotx" \
  -o "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"

# Hebrew CV subtitle
python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"

# Hebrew cover letter
pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
```

Verify both files exist and are nonzero:

```bash
ls -lh "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
ls -lh "<output_dir>/<company_dir>/he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
```

**Hebrew re-translation rule:** If either English document (CV or cover letter) is revised after Hebrew export, the corresponding Hebrew document MUST be fully re-translated from the updated English markdown — do not patch or edit the prior Hebrew text. If the English CV changes, re-translate the Hebrew CV. If the English cover letter changes, re-translate the Hebrew cover letter. Both change together only if both English documents changed. This applies regardless of how small the English edit is.

Hebrew files land in the same `<company_dir>` subdirectory as the English files. The `Draft Directory` URL (written in Step 7a) points to the whole directory and covers both English and Hebrew files — no separate Notion writeback for Hebrew filenames.

---

## Step 7 — Record file paths and write state

### Step 7a — DOCX existence gate + Draft Directory URL construction

**Hard gate — do not skip, do not proceed on failure.**

```bash
ls -lh "<output_dir>/<company_dir>/<cv_filename>.docx"
ls -lh "<output_dir>/<company_dir>/<cl_filename>.docx"
```

**If either file is missing or zero bytes: STOP.** Do not write anything to Notion. Do not mark the role complete. Report to the user: "DOCX export failed for [Company] — files not found on disk. Step 6 did not complete. Notion has not been updated." Then move to the next role in the queue.

**If both files exist and are nonzero:** construct the Draft Directory URL and store it in `$DRAFT_DIR_URL` for use in Steps 7b and 7c:

```
DRAFT_DIR_URL=$DRAFT_DIR_URL_BASE<date-folder>%2F<company_dir>%2F
```

If `$DRAFT_DIR_URL_BASE` is empty or the literal word `skip`, set `$DRAFT_DIR_URL` to an empty string. Step 7c will omit the `Draft Directory` property from the `notion-update-page` call in that case.

Then proceed to Step 7b.

### Step 7b — Write state file (crash-recovery)

Append this role's data to:
`$OUTPUT_DIR/state.json`

where `$OUTPUT_DIR` is the run directory resolved by the orchestrator (e.g. `{{OUTPUT_FOLDER}}/${OUTPUT_DIR_PREFIX:-applications}-<YYYY-MM-DD>/`). Create the file on the first role; append on subsequent ones. Use the `/tmp→output folder` copy protocol from `career-engine-export`. Use the shortened path format for all paths — `<run-dir-name>/<filename>` only, never the full output folder path.

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
      "cover_letter_path": "<company_dir>/<cl_filename>.docx",
      "feedback_path": "<company_dir>/feedback-<roletitle>-<company>-<monYYYY>.md",
      "revision_log_path": "<company_dir>/revision-log-<roletitle>-<company>-<monYYYY>.md",
      "draft_dir_url": "$DRAFT_DIR_URL (the value constructed in Step 7a — empty string if $DRAFT_DIR_URL_BASE was skip/unset)",
      "role_emphasis": "<1-2 sentence real mandate interpretation>",
      "jd_proof": "<verbatim quote from JD>",
      "keywords": "Critical: <terms> | Important: <terms> | Nice-to-have: <terms>",
      "strategy": "<IC | Strategic | Hybrid>",
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
- `date_first_advertised` / `remote_compatibility` — from the coach's research output; write `null` if not available (e.g., content-exists roles where coach skipped fetching)
- All paths are relative to the run folder (e.g., `company-name/cv-<last-name>-[role-title]-company-name-may2026.docx`). Hebrew files are not listed separately — they are in the same `company_dir` and accessible via the Draft Directory URL.

### Step 7c — Write pipeline outputs to Notion properties

Write the following properties using `notion-update-page`. All values are already in memory.

**Confirm every property name against the schema before writing.** The database-notion adapter's §1 schema read (the SQLite `CREATE TABLE` block — the authoritative list of property names and select-option values) was already done upstream and is in context; do not re-fetch it. Before the `notion-update-page` call, check each property name below against that schema. Per the adapter's writeback rule (`skills/database-notion/SKILL.md` §3), a property that is missing, renamed, or whose type doesn't match the schema must **not** be silently dropped and must **never** spawn a numbered variant ("Strategy 1") — omit only that property from the call and surface a named note in the final chat delivery: "Notion property `<name>` not found in the database schema for [Company] — renamed or removed; its value was not written. Update the property name or your `database_property` mapping." Write the properties that do match; one renamed property never blocks the others.

**Coach-owned properties** — write verbatim from the coach's output in Step 0.8. Do not rewrite or reinterpret.

| Property | Source |
|---|---|
| `Role emphasis` | Career coach output — verbatim |
| `JD proof` | Career coach output — verbatim |
| `Keywords` | Career coach output — verbatim |
| `Strategy` | Career coach output — Select value (`IC` / `Strategic` / `Hybrid`) |
| `Role Type` | Career coach output — verbatim |
| `Relationship type` | Career coach output — verbatim |
| `Gap handling` | Career coach output — verbatim. If the user edited this in Notion before the pipeline ran, her version is already there; do not overwrite it. |
| `Role summary` | Career coach output — verbatim. |
| `Person who Advertised Role (if not Hiring Manager)` | Career coach output — verbatim. |
| `Hiring manager's role` | Career coach output — verbatim. |
| `Manager role confirmed` | Career coach output — verbatim. |
| `No incumbents in this function` | Career coach output — verbatim. |

**Pipeline-derived properties**

| Property | What to write |
|---|---|
| `Hiring Manager's Name` | Hiring manager name and title from the coach's research. Write "Not identified" if none found. |
| `Last Pipeline Run` | Today's date in ISO format (YYYY-MM-DD). |
| `Status` | `CV Ready for Review` — set once DOCX export and writeback are confirmed complete. |
| `Draft Directory` | `$DRAFT_DIR_URL` (constructed in Step 7a). **Omit this property from the `notion-update-page` call entirely if `$DRAFT_DIR_URL` is empty** — do not write an empty string to the property. If `$DRAFT_DIR_URL` is empty, include a named note in the final chat delivery: "Draft Directory not written for [Company] — `draft_dir_url_base` not configured or empty. Run `/career-engine:setup --phase 5` to configure it." |

**Property discipline** — write only the properties listed above. Nothing else.

- Do NOT write CV text, cover letter text, revision logs, or reviewer feedback to Notion. Reviewer feedback goes to the feedback markdown file (Step 7d), not to Notion.
- Do NOT write to the `Note` field. It is the user's space.

If any writeback fails, log it and surface it in the final chat delivery. The state.json holds all data as a fallback.

### Step 7d — Save reviewer feedback file

Write a single markdown file to the output folder. This is the one file the user reads — it contains reviewer feedback from all review passes plus the cv-writer's change log, **all read from the role's `_pipeline/` files, not pasted from context (R-41).**

**Filename:** `feedback-<roletitle>-<company>-<monYYYY>.md`  
(Use the same slug format as the CV and cover letter files for this role.)

**File content:**

```markdown
# Feedback — <Role Title> at <Company> — <YYYY-MM-DD>

## CV Changes

<contents of `$PIPE/cv-changes.md` — read the file; if missing, write `_(not available)_`>

---

## Recruiter Review — CV

<contents of `$PIPE/recruiter-cv.md` — read the file; if missing, write `_(not available)_`>

---

## Coach Strategic Letter Review

<contents of `$PIPE/coach-letter-review.md` — read the file; if missing, write `_(not available)_`>
```

Build the file by reading each `$PIPE` section from disk (not from context — R-41; the reviewer text flows file→file and never re-enters the orchestrator's working set) and writing it to the company subdir using the same `/tmp → output folder` copy protocol as the DOCX files. On Path B, read the `$PIPE` files and run the copy through the host file/process tools (R-30):

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

### Step 7f — Why I Want This Role promotion prompt

Runs for every role in the run whose `Why I Want This Role` field is populated — including roles where the letter track was skipped. This step is mechanical and must never block delivery: if it fails, log the failure and continue.

Write a file named `update-prompt-<company>-<monYYYY>.md` into the role's company subdirectory in the output folder using the structure below. The file has two parts: a fixed context block that never changes (copy it verbatim every time) and a variable content block specific to this role.

```
# career-data Update Prompt
<!-- This prompt is generated by the career-engine pipeline. Paste it into Claude Chat or Claude Code to update your career-data skill. -->

## Context for the receiving agent

You are updating a skill file called `career-data`. This is a `.skill` package installed in Claude Desktop that contains the user's personal career data — their background, voice, positioning, and motivation bank. The pipeline cannot run without it. The user's data stays local (never in the plugin) for privacy.

To find `career-data`: locate the directory containing `career-data-marker.json`. It will be at a path like:
`~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/<workspace-id>/<user-id>/skills/career-data/`

If you are in Claude Code, you can also find it at `~/.claude/skills/career-data/` if a Code-side copy exists. **Important:** if the user runs both Chat and Code (or Cowork), they must apply this update twice — once in Chat and once in Code — because each environment maintains its own copy.

The file to update is: `references/background/background-motivation-bank.md`

Read that file in full before making any changes. Make only the additions described below. Do not rewrite, reorganise, or delete anything else in the file.

After updating the file, repackage the `career-data` directory as a `.skill` zip and provide it to the user to reinstall via Desktop app Settings → Capabilities → Skills. The `.skill` file is a standard zip archive with a `.skill` extension containing all the files in the `career-data/` directory.

## What to add

**Target location:** The `| Tags | Motivation |` table. Append new rows to it. There is **no** "Promoted from Why I Want This Role" subsection — promoted content is simply new rows in this table.

**Source content** (from Why I Want This Role — [Company], [Role Title], [YYYY-MM-DD]):
> [INSERT THE USER'S WHY I WANT THIS ROLE CONTENT HERE — VERBATIM, EXACTLY AS SHE WROTE IT. Do NOT correct grammar or spelling, do NOT polish, do NOT paraphrase. Scrappy English is fine and preferred over a cleaned-up version; the user fixes her own wording inside this prompt before sending if she wants.]

**Promotion rules:**
- Compare the source content against the entire file. Add only what is genuinely new: durable motivation themes, standing professional observations, reusable angles, or characteristic phrasings the user wrote.
- Exclude: anything already captured (even in different words), purely company- or role-specific reactions with no reuse value, and anything not in the user's own written words.
- **Verbatim, raw.** The Motivation cell is the user's exact words — never paraphrased, polished, or grammar-"fixed" by the agent. Quote what she wrote. The user may correct her own wording in this prompt before sending; the agent never does.
- **Entry format — append a new table row:** `| [suggested tags] | "[verbatim quote]" *(Why I Want This Role — [Company], [YYYY-MM-DD])* |`. Suggest the **tags** (comma-separated: where/when this applies in a cover letter — persona, theme, vertical, opener-vs-body, audience); the user can adjust them. The Motivation text stays raw verbatim regardless of the tags.
- Append-only. Never rewrite, merge, reorder, or delete existing rows; never change the table's column layout.
- If the content contains a new durable career fact (outcome, metric, deliverable, role detail) that belongs in the role-facts file for this company, do NOT write it there — it requires the user's explicit approval. Flag it instead: "New role fact found: '[quote]' — add to `background-role-facts-<company>.md` if accurate."
- If there is nothing new to add, say so explicitly: "No new content to promote from this entry."
```

**After the Motivation Bank promotion section, append a WIWTR-UNLOGGED section if applicable:** Collect every item the gatekeeper flagged as `[WIWTR-UNLOGGED]` during this run (from Steps 5.2, 5.3, and 5.95 violation reports). For each item, append to the update-prompt file:

```
## Role facts needing verification (WIWTR-UNLOGGED — from [Company] [Run Date])

The following claims appeared in your Why I Want This Role and were used in the letter,
but are not yet documented in your role-facts files. They are NOT fabrications —
they are your own first-person record. To make them available to future pipeline runs
without re-triggering this advisory, add them to `background-role-facts-[company].md`
for the relevant role, pending your verification that the facts are accurate.

For each item below: if accurate, add it as a role fact to the relevant
`background-role-facts-[company].md` file. If not accurate, remove it from your
Why I Want This Role before the next run.

[For each WIWTR-UNLOGGED item, one line:]
- **[Employer]** — "[verbatim claim from WIWTR]" *(flagged in [step] — not in background-role-facts-[company].md)*
```

If no [WIWTR-UNLOGGED] items were found, omit this section entirely.

Log in the final delivery per role: "Update prompt written to `<company_dir>/update-prompt-<company>-<monYYYY>.md` — paste into Chat or Code to complete the motivation bank promotion (do both if you use both environments)" or "No Why I Want This Role content and no WIWTR-UNLOGGED items — skipped."

### Step 7g — Clean up `_pipeline/` scratch directory

After Step 7f, remove the `_pipeline/` directory for this role. All content needed for delivery (feedback file, revision log) has already been written to the output folder in Step 7d and in the post-Step-4 and post-Step-5.3 staging blocks. The `_pipeline/` files are intermediate scratch — they are not deliverables and do not belong in the user's output folder.

- **Path A:** `rm -rf "$PIPE"`
- **Path B:** delete `$PIPE` through the host file tool (Desktop Commander `move_file`/delete or equivalent).

If the deletion fails, log it in the final delivery ("_pipeline cleanup failed for [Company] — delete manually") and continue. This step must never block delivery.

The output folder after cleanup contains only: final DOCX files, the feedback markdown, the revision log markdown, and (for Hebrew runs) the Hebrew DOCX files.
