---
name: cv-reframe-pipeline
description: 'Reframe pipeline for the cv-campaign orchestrator. Handles Steps R1 through R3 when {{USER_FIRST_NAME}} specifies "Reframe only" in chat: tailored CV (no cover letter), DOCX export, and Notion writeback. The structured JD for each role is already in memory from the queue pipeline — do not re-fetch. Load this skill as part of the cv-campaign pipeline, after cv-campaign-intake.'
---

# CV Campaign — Reframe Pipeline

This skill covers Steps R1 through R3 of the reframe pipeline.

For `Reframe only` runs: Steps R1 through R3 only. A CV is produced. No cover letter is produced.

The structured JD was fetched in Step 0.5 of the queue pipeline and is already in memory — pass it directly without re-fetching.

## What the reframe pipeline is for

The reframe pipeline is for founding or first technical writer postings where {{USER_FIRST_NAME}}'s pitch is not "hire me for this role as posted" but rather "you don't need a writer, you need this." A tailored CV is produced — no cover letter. {{USER_FIRST_NAME}} specifies "Reframe only" in chat — the coach respects her choice and does not auto-detect or override it.

### Step R1 — Tailored CV

Spawn `cv-writer` with `option=draft`, passing:
- The structured JD from Step 0.5
- The coach's output for this role: `Role emphasis`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`

cv-writer returns a full tailored CV draft. Keep the output in memory for Steps R1.5 through R3.

Do not produce a cover letter. Do not spawn `letter-writer`.

### Step R1.5 — Gatekeeper check

Spawn `gatekeeper` with `option=content`, passing the draft CV text, the structured JD from Step 0.5, and the coach's `Keywords` property for this role. The gatekeeper's ATS pre-check uses the tiered Keywords list to verify coverage.

**If PASS:** proceed to Step R2.

**If FAIL:** spawn `cv-writer` with `option=revision`, passing the draft and the gatekeeper's full violation list. After revision, spawn `gatekeeper` again with `option=content`. Repeat until PASS. Log all violation rounds internally.

**Cap: 3 revision passes.** If the gatekeeper still returns FAIL after pass 3, log all remaining violations, proceed to Step R2, and flag for {{USER_FIRST_NAME}} in the final delivery that this reframe CV needs manual review before sending.

### Step R2 — Produce reframe CV DOCX

Follow the full DOCX production protocol in `cv-campaign-export` — including writing the CV markdown to `/tmp/` first, then running convert-cv.sh. The reframe CV uses the same CV template and style annotations as the standard CV. See the CV annotation reference in `cv-campaign-export` for the exact style names.

Output file:
`cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>.docx` in the run's iCloud output folder.

### Step R2H — Hebrew reframe CV (conditional)

**Only runs if `Languages` includes `Hebrew`.** Check the `Languages` property on the Notion row. If `Hebrew` is not present, skip this step entirely and proceed to Step R3.

Spawn `hebrew-localization` with:
- The final English reframe CV markdown (from Step R1, already in memory)
- The structured JD
- The exact role title from the JD
- Instruction: **CV only — no cover letter.** Pass `null` for the English cover letter input.

The agent returns a Hebrew CV markdown block only.

Write to `/tmp/` and convert:

```bash
cat > /tmp/<cv_filename>-he.md << 'MARKDOWN_EOF'
<Hebrew CV markdown from agent>
MARKDOWN_EOF

cat /tmp/<cv_filename>-he.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/static-cv-footer-he.md" \
    > /tmp/<cv_filename>-he-with-footer.md

pandoc /tmp/<cv_filename>-he-with-footer.md \
  --reference-doc="${CLAUDE_PLUGIN_ROOT}/references/rachel-{{USER_LAST_NAME}}.dotx" \
  -o "<output_dir>/cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>-he.docx"

python3 "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/update-subtitle.py" \
  "<output_dir>/cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>-he.docx" \
  "<role title>"

ls -lh "<output_dir>/cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>-he.docx"
```

**RTL note:** Hebrew DOCX files use the same LTR template as English files. {{USER_FIRST_NAME}} will need to set paragraph direction to RTL in Word before sending.

### Step R3 — Record reframe file paths and write state

1. Confirm the reframe CV DOCX is saved at the path defined in Step R2.
2. Write the file path to the CV path URL property. **Identify from the schema fetched in Step 0:** find the URL-type column containing `CV` but not `Letter` and not `Hebrew` — that is the CV path property. Use the schema-confirmed name. Current expected name: `CV File Name`. Write the filename only (no directory, no folder prefix, no path). There is no cover letter in the reframe pipeline — leave the letter path property unset.
3. **If Step R2H ran (Hebrew present):** also write to the Hebrew CV path property. URL-type column containing both `Hebrew` and `CV` = Hebrew CV path property. Current expected name: `CV File Name (Hebrew)`. Filename only: `cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>-he.docx`. Leave `Letter File Name (Hebrew)` unset — no Hebrew cover letter in the reframe pipeline.
4. Update Status to `CV Ready for Review`. Set this only after the DOCX and Notion writeback are confirmed complete.

If any Notion writeback fails, log the failure for this role and surface it in the final chat delivery — the file is already on disk.

**Step R3.1 — Write state file (crash-recovery)**

Append this role's data to:
`{{ICLOUD_OUTPUT_PATH}}/cv-campaign-<YYYY-MM-DD>/state.json`

Create the file if it does not exist. If it does exist, read the existing `roles` array, push the new role object, and write the full updated JSON back — do not use `cat >` on an existing file. Use the shortened path format for all paths.

```json
{
  "session_date": "<YYYY-MM-DD>",
  "roles": [
    {
      "notion_page_id": "<id>",
      "company": "<company>",
      "title": "<title>",
      "track": "reframe",
      "status": "completed",
      "cv_path": "cv-campaign-<YYYY-MM-DD>/<cv_filename>.docx",
      "cv_path_hebrew": "cv-campaign-<YYYY-MM-DD>/cv-{{USER_LAST_NAME}}-reframe-<roletitle>-<company>-<monYYYY>-he.docx"
    }
  ]
}
```

Omit `cv_path_hebrew` if Step R2H did not run (Languages does not include Hebrew).
