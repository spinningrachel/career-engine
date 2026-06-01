---
name: archive
description: Add a finalized cover letter or CV to the delivered-letters archive in the plugin. Run when {{USER_FIRST_NAME}} confirms a document is ready to be saved as a reference for future pipeline runs.
allowed-tools:
  - Read
  - Write
  - Bash
---

# Archive Finalized Document

{{USER_FIRST_NAME}} has confirmed a document is finalized and should be added to the delivered-letters archive so future pipeline runs can use it as a voice and quality reference.

## What to do

1. **Identify the file.** {{USER_FIRST_NAME}} will provide a path or filename. If she provides a campaign folder path, look for:
   - Cover letter: `coverletter-{{USER_LAST_NAME}}-*.md` or `coverletter-{{USER_LAST_NAME}}-*.docx`
   - CV: `cv-{{USER_LAST_NAME}}-*.md` or `cv-{{USER_LAST_NAME}}-*.docx`

2. **Get a readable version.** The archive stores `.md` text files — not PDFs or DOCX.
   - If a `.md` file exists alongside the DOCX in the campaign folder, use it directly.
   - If only a DOCX exists, convert it: `pandoc "<path>.docx" -t plain -o "<dest>.md"`
   - If only a PDF exists, convert it: `pdftotext "<path>.pdf" - > "<dest>.md"`

3. **Copy to the archive:**
   ```bash
   cp "<source>.md" "${CLAUDE_PLUGIN_ROOT}/references/delivered-letters/<filename>.md"
   ```

4. **Confirm.** Report the filename added and the total count of files now in the archive.

## Archive location

`${CLAUDE_PLUGIN_ROOT}/references/delivered-letters/`

Files here are loaded by letter-writer and cv-writer as voice and quality anchors for future applications. Cover letters inform tone, register, and opener style. CVs inform bullet quality and summary framing.

## Naming convention

Keep the original pipeline filename as-is:
- `coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.md`
- `cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.md`
