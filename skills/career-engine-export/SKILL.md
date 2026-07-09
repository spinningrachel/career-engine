---
name: career-engine-export
description: DOCX production rules for the career-engine pipeline. Contains the pandoc conversion protocol, custom-style annotation reference, cover letter styles, and file naming conventions. Load this skill before any DOCX export step in the career-engine pipeline. Both the CV pipeline.
---

# New Application — DOCX Production

This skill governs all DOCX production in the career-engine pipeline. Load it before any DOCX export step. Output files are `.docx`, opened directly in Word. The user exports to PDF before sending.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

**The templates own all fonts, sizes, and colors — never hand-set these.**

---

## How DOCX production works

cv-writer outputs **styled markdown** using pandoc's `custom-style` div and span syntax. The pipeline converts it to `.docx` at Step 6 using pandoc with the `.dotx` reference templates. A short post-processing script then updates the role-specific Subtitle in the CV document header.

**Templates — fixed-path convention, no config key, never an external OS path (2026-07-04 fix).** All templates resolve by fixed filename inside `${CAREER_DATA}/references/templates/` — there is no `cv_template` or `word_templates_path` config key anymore, and the plugin never reads a template from outside career-data:
- `$CV_TEMPLATE` = `${CAREER_DATA}/references/templates/cv.dotx` — CV reference template, **Detailed CV Type**. Contains all custom styles, the user's name and contact info in the document header, and correct formatting throughout.
- `$CV_TEMPLATE_BRIEF` = `${CAREER_DATA}/references/templates/cv-brief.dotx` — CV reference template, **Brief CV Type** (one-page, two-column). Required only when the resolved CV Type for a role is `Brief` — see the CV Type resolution step in `career-engine-new-application/SKILL.md`/`career-engine-edit/SKILL.md`. Never used for a Detailed-type role.
- `$CL_TEMPLATE` = `${CAREER_DATA}/references/templates/cover-letter-template.dotx` — Cover letter reference template. Contains header and styles. **This must resolve from career-data, never from the plugin's own `references/` default** — the plugin's copy is the new-user default only (see `career-engine-setup/SKILL.md`), and using it in place of the user's own personalized template was a real production bug (the cover letter export silently ignored the user's actual template every run).
- `$CV_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/cvHe.dotm` — Hebrew CV reference template (note the `.dotm` extension — this file is macro-enabled, not `.dotx`).
- `$CL_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/he-letter.dotx` — Hebrew cover letter reference template.

Confirm each file exists before use. `$CV_TEMPLATE` and `$CL_TEMPLATE` are required for any export — if either is missing, stop and report: "career-data is missing `references/templates/<filename>` — run `/career-engine:setup --phase 5` to restore the default templates, or add your own at that path." `$CV_TEMPLATE_BRIEF` follows the same required-when-needed rule as the Hebrew templates: if the resolved CV Type for this role is `Brief` and `cv-brief.dotx` is missing, stop and report the same way — never silently fall back to `$CV_TEMPLATE` (that would silently produce a Detailed-shaped document for a role the user explicitly configured as Brief). `$CV_TEMPLATE_HE`/`$CL_TEMPLATE_HE` are optional — if either is missing, Hebrew export for that document type is unavailable; skip it and note it, exactly as the old `word_templates_path`-empty case did.

None of these templates should be read into context. Use them only as pandoc `--reference-doc` arguments.

---

## Prerequisites

- `pandoc` — DOCX conversion
- `python-docx` — subtitle update script (`pip install python-docx`)

---

## Step 6 production protocol

Run these steps in sequence. All bash commands run directly — no agent spawn needed.

**Environment note (R-30):** the commands below assume Path A (direct filesystem access — see the orchestrator's Mandatory path verification). On Path B (sandboxed environment with host-bridge MCP access), run every command in this protocol through the host process tool (e.g. Desktop Commander `start_process`) and write files through the host file tools. Sandbox `/tmp/` is not visible to host-side pandoc — write intermediate markdown through the host tool to the output company directory (or a host temp path) instead.

**Plugin dir:** the directory containing `agents/`, `skills/`, and `references/` — typically the plugin root.

**Output dir:** `{{OUTPUT_FOLDER}}/applications-<YYYY-MM-DD>/`

**Company directory:** Each role's files go in a subdirectory named after the hiring company. The subdirectory name is derived from the Company property: lowercase, spaces replaced with hyphens, non-alphanumeric-or-hyphen characters stripped, consecutive hyphens collapsed. If the result is empty or the company is unknown, use `unknown-company`.

```bash
COMPANY_DIR=$(echo "<company_name>" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//')
[ -z "$COMPANY_DIR" ] && COMPANY_DIR="unknown-company"
```

Examples: `"Acme Corp"` → `acme-corp` · `"Blue Sky"` → `blue-sky` · `"Acme Cybersecurity"` → `acme-cybersecurity`

### 1. Create output directory

```bash
mkdir -p "<output_dir>/<company_dir>"
```

### 2. Write markdown files to /tmp

Save the final CV markdown (from Step 4/4.5) and cover letter markdown (from Step 5) to `/tmp/`:

```
/tmp/<cv_filename>.md
/tmp/<cl_filename>.md
```

Filename convention: lowercase, no spaces, hyphens between words, `.md` extension.

### 3. Convert with pandoc

**Select the CV template path first — conditional on the resolved CV Type for this role** (read from `$PIPE/cv-type.txt`, written by the resolution step earlier in the pipeline; never re-derived here):

```bash
if [ "<resolved CV Type>" = "Brief" ]; then
  CV_TEMPLATE_FOR_EXPORT="$CV_TEMPLATE_BRIEF"
else
  CV_TEMPLATE_FOR_EXPORT="$CV_TEMPLATE"
fi
```

Run the conversion script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/convert-cv.sh" \
  "/tmp/<cv_filename>.md" \
  "/tmp/<cl_filename>.md" \
  "<output_dir>/<company_dir>" \
  "${CLAUDE_PLUGIN_ROOT}" \
  "$CV_TEMPLATE_FOR_EXPORT" \
  "$CL_TEMPLATE"
```

`$CV_TEMPLATE_FOR_EXPORT` (arg 5) resolves to either `$CV_TEMPLATE` (`cv.dotx`) or `$CV_TEMPLATE_BRIEF` (`cv-brief.dotx`) per the conditional above — `convert-cv.sh` itself needs no change for this; it already takes the template path as a plain positional argument, so only this caller-side resolution differs by CV Type. `$CL_TEMPLATE` (arg 6) is the resolved `.dotx` path from `${CAREER_DATA}/references/templates/` (fixed filename `cover-letter-template.dotx` — no config key, see the Templates section above). The personal templates live in career-data, not the plugin (R-37). The script fails fast if either is missing. (R-42 — the script previously hardcoded a literal `{{USER_DOTX_FILE}}.dotx` and a stale export-skill footer path, which broke every export. **2026-07-04 fix:** arg 6 added — the script previously hardcoded the plugin's own default `references/cover-letter-template.dotx` for every cover letter export, silently ignoring the user's actual personalized template every run.)

Pandoc inherits the header/footer from the reference template. The user's name and contacts appear automatically. Only the Subtitle (role tagline) needs updating per role.

### 4. Update the Subtitle in the CV header

Run the subtitle script on the file in the output directory (convert-cv.sh writes DOCX directly to output_dir, not /tmp):

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/<cv_filename>.docx" \
  "<role title>"
```

**The subtitle MUST be the exact job title the user is applying for — taken verbatim from the JD.** Examples: e.g., "Head of Marketing", "Senior Software Engineer", "Director of Product Design". NOT a generic descriptor. NOT the user's background framing. The role title. Full stop.

The cover letter header does not need a subtitle update.

### 5. Verify

```bash
ls -lh "<output_dir>/<company_dir>/<cv_filename>.docx"
ls -lh "<output_dir>/<company_dir>/<cl_filename>.docx"
```

Both files must exist and be nonzero before proceeding.

### 6. Page count check

```bash
pandoc "<output_dir>/<company_dir>/<cv_filename>.docx" -t plain | wc -w
```

This gives a plain-text word count of the full rendered document (including all headers, titles, dates, and body). **Thresholds branch by CV Type — a Brief CV's one-page target is a materially tighter constraint than Detailed's.**

**Detailed:** the user's CV is senior-level with a full work history — a clean 2-page document is normal and expected. Thresholds are calibrated accordingly:
- **Under 1050 words** — proceed to Notion writeback.
- **1050–1350 words** — likely 2 dense pages; proceed but flag in the chat summary: "CV word count at [N] — confirm 2-page fit before sending."
- **Over 1350 words** — likely over 2 pages. Return to cv-writer with: "CV plain-text word count is [N] after DOCX conversion, indicating likely overflow beyond 2 pages. Cut bullets from the lowest-priority roles to bring body word count under 1000."

**Brief:** apply the single total-body word-count backstop ceiling from `writer-craft/SKILL.md` §5b instead (a one-page target, not a 2-page one — do not apply Detailed's thresholds above to a Brief CV). If over the ceiling, return to cv-writer with: "Brief CV plain-text word count is [N] after DOCX conversion, over the one-page backstop ceiling — fold more roles into the `Earlier:` line or tighten bullet density (`writer-craft/SKILL.md` §5b's one-page-fit judgment principle)."

After cv-writer returns a revised draft, re-run the full export protocol from Step 2. One revision pass only — if still over threshold after one pass, proceed and flag in the chat summary.

### 7. Generate Draft Directory URL

After both files are verified, construct the Draft Directory URL for this role's directory. Hold it in memory — the pipeline writes it to the `Draft Directory` Notion property in the writeback step.

```bash
DATE_FOLDER=$(basename "<output_dir>")  # e.g. applications-2026-05-26
DRAFT_DIR_URL="{{DRAFT_DIR_URL_BASE}}${DATE_FOLDER}%2F${COMPANY_DIR}%2F"
```

**Unconfigured link base guard:** if `$DRAFT_DIR_URL_BASE` (from the career-data config key `draft_dir_url_base`) is empty, unset, or the word `skip`, leave the `Draft Directory` property empty and continue — do not write a malformed URL.


Example: `{{DRAFT_DIR_URL_BASE}}applications-2026-05-26%2Fnorthwind%2F`

---

## File naming conventions

All filenames are lowercase, no spaces, hyphens between words. Extension is `.docx`. **Unchanged by CV Type** — a Brief CV uses the same `cv-...` filename pattern as Detailed; one CV is produced per role regardless of type, so there is no naming collision to resolve.

- CV: `cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx`
- Standard cover letter: `coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx`
- Hebrew CV: `he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx`
- Hebrew cover letter: `he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx`
- Reviewer feedback: `feedback-<roletitle>-<company>-<monYYYY>.md`
- Revision log (per role): `revision-log-<roletitle>-<company>-<monYYYY>.md`
- Revision log (per run): `revision-log-<YYYY-MM-DD>.md`
- State file: `state.json`

Example: `cv-<last-name>-[role-title]-[company]-[mon-year].docx` / `revision-log-[role-title]-[company]-[mon-year].md`

---

## Hebrew DOCX production protocol

Hebrew DOCX files are produced inline in Step 6H (Standard/Edit pipelines). This section documents the bash steps for reference — they are spelled out in full in each pipeline skill.

**Footer:** Hebrew CVs use `static-cv-footer-he.md` (Hebrew-language Education and Languages sections) instead of `static-cv-footer.md`. The pipeline concatenates this file before calling pandoc.

**Hebrew templates:** Two dedicated templates exist for Hebrew output — both live in `${CAREER_DATA}/references/templates/`, fixed filenames, no config key and no external OS path (2026-07-04 fix — this used to point at an external, machine-specific Office templates folder via the now-removed `word_templates_path` config key):

- `$CV_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/cvHe.dotm` — Hebrew CV reference template. **Note the `.dotm` extension** (macro-enabled) — not `.dotx`.
- `$CL_TEMPLATE_HE` = `${CAREER_DATA}/references/templates/he-letter.dotx` — Hebrew cover letter reference template.

If either file is missing, Hebrew export for that document type is unavailable; skip it and note it.

Both Hebrew templates support RTL formatting. Use `--reference-doc` with these templates — do not use pandoc's default template for Hebrew output.

**YAML front matter:** Hebrew markdown files must include the following front matter at the very top (before any content). The localization agent includes this in its output. Do not strip it:

```yaml
---
dir: rtl
lang: he
---
```

**Conversion steps for Hebrew CV:**

```bash
# $CV_TEMPLATE_HE resolved from ${CAREER_DATA}/references/templates/cvHe.dotm (fixed path, no config key)

# 1. Concatenate Hebrew CV markdown with Hebrew footer
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

# 2. Convert with pandoc using Hebrew CV template
pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${CV_TEMPLATE_HE}" \
  -o "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx"

# 3. Update subtitle
python3 "${CLAUDE_PLUGIN_ROOT}/skills/career-engine-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-<last-name>-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"
```

**Conversion steps for Hebrew cover letter:**

```bash
# $CL_TEMPLATE_HE resolved from ${CAREER_DATA}/references/templates/he-letter.dotx (fixed path, no config key)

pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${CL_TEMPLATE_HE}" \
  -o "<output_dir>/<company_dir>/he-coverletter-<last-name>-<roletitle>-<company>-<monYYYY>.docx"
```

All files save to the role's company subdirectory:
`{{OUTPUT_FOLDER}}/applications-<YYYY-MM-DD>/<company_dir>/`

---

## CV — custom-style annotation reference

cv-writer uses pandoc's div/span syntax to apply Word custom styles. The `.dotx` template owns all formatting. Never add inline font, size, or color in the markdown.

### Section banners → Heading 2 (no annotation needed)

Standard `##` headings map automatically to the `Heading 2` style from the template:

```markdown
## SUMMARY
## SKILLS & EXPERTISE
## EXPERIENCE
## CONSULTING
## TOOLS          ← optional; include only when JD specifies relevant tools
```

**Never include in cv-writer output:** `## EDUCATION`, `## LANGUAGES`, `## ADDITIONAL` — these are injected automatically by the user's Word macros after DOCX export. They must not appear in the markdown passed to pandoc. If they appear, the macro will duplicate them in the final document.

### Summary paragraphs → Normal (no annotation needed)

Regular markdown paragraphs use the `Normal` style automatically:

```markdown
[Example — your summary paragraph goes here. Typically 1–2 sentences establishing your function and value proposition.]
```

### Builder / Leader competencies line → Normal (no annotation needed)

Plain paragraph, pipe-separated. No annotation:

```markdown
[Example — pipe-separated list of your core competencies]
```

### RoleTitle

```markdown
::: {custom-style="RoleTitle"}
Head of [Function] | [Company Name]{custom-style="BlueFont"} | {{USER_CITY}}, {{USER_COUNTRY}} | *[Start] -- [End]*
:::
```

Notes:
- Company name uses the `BlueFont` inline span for one word/phrase
- **BlueFont bracket rule — MANDATORY:** The span MUST be written as `[Company Name]{custom-style="BlueFont"}` — square brackets around the text, curly braces after. Writing `Company Name{custom-style="BlueFont"}` (no brackets) is a hard error: pandoc renders the literal text `{custom-style="BlueFont"}` into the DOCX instead of applying the style.
- Dates (after the last `|`) are italicized with standard markdown `*italic*` — the style applies italic locally
- Use `--` for en-dashes in date ranges

### RoleOverview

```markdown
::: {custom-style="RoleOverview"}
[Example — one sentence: company context and your scope, e.g. "B2B SaaS platform; sole [function] hire from founding through Series B, owning all GTM and content."]
:::
```

One sentence. No bold or italic markup — the style handles formatting.

### RoleActivitiesList bullets

```markdown
- ::: {custom-style="RoleActivitiesList"}
  [Example — outcome-first bullet: what changed, with metric or named result, because of your work.]
  :::

- ::: {custom-style="RoleActivitiesList"}
  [Example — outcome-first bullet: what you built or delivered, with scope or named outcome.]
  :::
```

For a role with a single bullet, use `RoleActivitySingle` instead:

```markdown
::: {custom-style="RoleActivitySingle"}
[Example — single-bullet role entry, e.g. "Fractional [function] for seed-stage SaaS clients; engagements kept open alongside full-time roles."]
:::
```

### Skills section — Scaler / Specialist (categorized block)

```markdown
::: {custom-style="SkillsHeading"}
Strategy & GTM
:::

::: {custom-style="Skills"}
Product positioning | Go-to-market strategy | ICP development | Competitive intelligence | Sales enablement
:::

::: {custom-style="SkillsHeading"}
Leadership
:::

::: {custom-style="Skills"}
[Example — pipe-separated skills for this category, e.g. "Team building | Cross-functional alignment | Board reporting"]
:::
```

### BlueFont inline span

Use for company name in RoleTitle — ONE word or phrase per line, maximum:

```markdown
[Company Name]{custom-style="BlueFont"}
```

### Earlier line (collapsed older roles)

```markdown
**Earlier:** Senior marketing and content roles across B2B SaaS, media, and agency — full details on LinkedIn.
```

Plain `Normal` style paragraph. "Earlier:" is bolded with standard markdown `**bold**`. For Brief, this line closes out `## EXPERIENCE` directly (there is no `## CONSULTING` to sit between it and the rest of the document) — see the Brief annotation reference below.

---

## CV — custom-style annotation reference — Brief variant

**⚠ Known technical limitation, empirically CONFIRMED against a real build — plain pandoc markdown cannot produce the two-column sidebar layout.** Two mechanisms were tested against a real `cv-template-brief-default.dotx` build (python-docx, with `RoleTitle`/`RoleActivitiesList`/`RoleActivitySingle`/`SkillsHeading`/`Skills`/`BlueFont` custom styles defined, converted with `pandoc --reference-doc`):

1. **Pipe table with `::: {custom-style="..."}` div content in cells** — pandoc's pipe-table parser requires strictly single-line cell content and a `|---|---|` header separator row; multi-line block content (headings, divs) inside a cell is not parsed as a table at all — the whole block silently degrades to one literal-text paragraph, with every `|` and `:::` character rendered as visible text. **Confirmed broken.**
2. **Grid table (`+---+---+` ASCII-art borders) with block content in cells** — pandoc's grid-table parser IS designed for multi-paragraph cell content in principle, but requires the border and content rows to be exactly character-aligned to the declared column widths; a real test with hand-authored grid syntax failed to parse as a table at all (same literal-text degradation as the pipe table). Even if a perfectly-aligned grid table can be made to work, **requiring an LLM writer agent to hand-align ASCII-art table borders character-for-character, every draft and every revision, is not a reliable content-generation target** — a single misaligned dash silently breaks the whole layout with no error, exactly as observed in testing.

**What did work, confirmed in the same test:** `RoleTitle`, `RoleActivitiesList`, and `BlueFont` div/span annotations applied correctly (verified via the rendered DOCX's `w:pStyle`/`w:rStyle` references) when used in normal linear (non-table) markdown — identical to how they already work for Detailed. The problem is specifically the two-column table wrapper, not the annotation system itself.

**Recommended mechanism — not yet built, a real follow-up item, distinct from the blank template file itself:** cv-writer should NOT attempt to emit a pandoc table at all. Instead:
1. cv-writer outputs Brief content as ordinary **linear, single-column markdown** (exactly like Detailed), using two HTML-comment markers to delimit what belongs in the sidebar vs. the main column — e.g. `<!-- SIDEBAR -->` ... `<!-- /SIDEBAR -->` around the Skills content, everything outside those markers is main-column content. This is a content-generation task cv-writer is already good at (linear markdown with simple delimiters) — no ASCII-art alignment, no nested div-in-table syntax.
2. A new post-processing script (python-docx, same pattern as the existing `update-subtitle.py` — a small script that runs after pandoc, not instead of it) splits the sidebar-marked and main-marked content into two separate small pandoc conversions (or one conversion plus a re-parse), builds the two-column table shell (the same shell already proven to work in `cv-template-brief-default.dotx` — see that file for a working reference), and inserts each portion's rendered paragraphs into the correct cell, preserving their custom styles.
3. Step 6 of the production protocol gains a Brief-only step calling this new script, parallel to how Step 4 already calls `update-subtitle.py`.

**This script does not exist yet — building it is out of scope for the template file itself and needs its own implementation pass.** Until it exists, a Brief CV cannot actually be exported to the two-column visual shape described in this feature — the blank default `.dotx` template (a real, working file with all the right custom styles defined) and the content-authoring rules (`writer-craft/SKILL.md` §5b, `agents/cv-writer.md`) are ready, but the "assemble them into a two-column DOCX" step is not.

### Content annotations — Skills (sidebar) and Profile Summary / Experience (main column)

Once the marker-based split above is built, the content on each side uses ordinary annotations, unchanged from what's proven to work:

```markdown
<!-- SIDEBAR -->
::: {custom-style="SkillsHeading"}
SKILLS
:::

::: {custom-style="Skills"}
[Example — one flat pipe-separated or line-per-skill list; no Role-Type-driven categorization, unlike Detailed's Scaler/Specialist categorized blocks]
:::
<!-- /SIDEBAR -->

## PROFILE SUMMARY

[Example — your profile paragraph, tighter than Detailed's summary; see writer-craft/SKILL.md §5b for the word-count backstop]

## EXPERIENCE

::: {custom-style="RoleTitle"}
Head of [Function] | [Company Name]{custom-style="BlueFont"} | *[Start] -- [End]*
:::

- ::: {custom-style="RoleActivitiesList"}
  [Example — short, condensed bullet]
  :::

**Earlier:** [Company A], [Company B], [Company C] ([Year]–[Year])
```

Contact details (phone, email, location, site) are template-header content or the first table cell's fixed content, same convention as Detailed's header/contact info — cv-writer never writes them. (The photo, if the user's template includes one, is baked into the `.dotx` template directly — cv-writer never generates or inserts an image; see `pipeline-preferences.json` → `cv_type.brief_has_photo`.) **No `RoleOverview` annotation is ever used here** — Brief has no RoleOverview line at all (`writer-craft/SKILL.md` §5b). The `**Earlier:**` line is the last element inside `## EXPERIENCE`, not a separate section.

---

## Cover letter — custom-style annotation reference

```markdown
::: {custom-style="Salutation"}
Hi to the [Company name] team!
:::

Body paragraphs are regular markdown paragraphs (Normal style — no annotation needed).

[Full Name]{custom-style="Signature Char"}
```

---

## Cover letter approach and styles

### Word count and structure

All cover letters are limited to a single page, maximum 320 words with no minimum (not counting greeting or sign-off) — or 250 when the role's `Strategy = Strategic`. This matches the requirement in `skills/writer-craft/SKILL.md` and the gatekeeper check. Structure and voice are consistent across all letters and follow the framework below.

### Voice constraints

**Load `skills/writer-craft/SKILL.md` before writing any cover letter.** It defines writing mechanics, letter structure, use-case patterns, forbidden phrases, forbidden structures, and fabrication traps. Non-negotiable.

Every claim about the company must be traceable to the JD or brief. Do not infer the company's strategy, culture, or operating model from category signals. If a sentence about them cannot be sourced, cut it or rewrite it as an observation about the role.

The register is direct, specific, and confident. Energy is genuine, not performed. Warmth comes from the closing line.

The user writes about what she does, not what she avoids. Frame capability through action, not through the failure mode it prevents.

The user can express genuine interest when it is real: "I have wanted to work at X for years," "the work you are doing on Y is exactly where I want to be." Use only when true — not as a default opener.

What stays prohibited is unverifiable claims about the company itself — its strategy, uniqueness, or character. The test: if the sentence makes a claim about the company, it needs sourcing. If it makes a claim about the user's motivation, she is the source.

Do not reach for cleverness. If a line calls attention to its own phrasing, cut it.

### Cover letter framework

**Before writing:** Read the Company self-characterization section from the structured JD. This "good fit / not a good fit" or "you'll thrive here if" section is the most honest signal of what they're actually selecting for. Mirror it — not by copying it, but by demonstrating the user matches the positive signals with a specific named proof.

#### Structure, in order

**1. The opening move.** One of two things, both in first person — the opening paragraph is always the user speaking first:
- The user's genuine reaction to something specific about this role: what she recognizes, what excites her, what maps directly to work she has done. Name the role signal, then name the candidate's proof. The worked examples all follow this pattern.
- Genuine first-person interest in this specific company, when the user actually feels it. Use only when real.

Observations about the company's product, buyers, or market position belong in paragraph 2 or later. Do not open with second-person sentences — "Your buyers are technical," "Your product does X" — regardless of how accurate they are.

**2. Signalling business understanding.** A concrete observation about the company's operating model, the problem they are hiring to solve, or the structural reality of the role. Sourced from the JD. Specifics over adjectives. May fold into the opening paragraph when both beats read naturally as one.

**3. The positioning move.** Which part of the user's documented experience maps directly to what they need, and why. One named company, one named outcome.

**4. Handling adjacent or smaller-scale experience.**

THE NUMBER ONE GOLDEN RULE: COVER LETTERS ARE THE CANDIDATE'S OPPORTUNITY TO SHINE. LEAD WITH THEIR MOST RELEVANT BIGGEST STRENGTHS. NEVER PRE-EMPTIVELY EXPLAIN OR QUALIFY ANYTHING. ONLY LEAD WITH WHAT SHE HAS DONE AND NAME THE SPECIFICS THAT MAP TO WHAT THEY ARE HIRING FOR.

- Different domains and verticals are NEVER a gap and especially not a weakness.
- If there is any *perceived skill* gap the hiring manager will clock in the first 10 seconds, name the work she has done, let it stand. Do not add a scope qualifier. Lead with what was done, name the specifics, and stop.
- Do NOT volunteer scale they did not ask about. The phrasing pattern: "On the X side, I have run Y for a handful of Z clients — [named example] is one I can name. The work covered..."

**WRONG — never use these structures:**
- "The scale is different from X COMPANY — but..."
- "The closest I've worked to X is Y..."

**5. The closing posture.** A direct ask, not a request for permission. Warm or plain depending on the letter's tone. Never "I look forward to hearing from you at your earliest convenience."

### Prohibited phrasing (in addition to writer-craft skill rules)

- Never open or close with a fit claim: "This role has my name on it," "I'm the perfect candidate," "I was made for this role"
- Never volunteer a title gap — scope speaks for itself; that conversation is for the interview
- "Full disclosure" followed by a gap apology — banned
- "Whether that's the fit you need" — banned
- Never ever use "is worth naming" or "is worth calling out" — if it's worth naming, name it directly without the framing!!
