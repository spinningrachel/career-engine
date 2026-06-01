---
name: cv-campaign-export
description: DOCX production rules for the cv-campaign pipeline. Contains the pandoc conversion protocol, custom-style annotation reference, cover letter styles, and file naming conventions. Load this skill before any DOCX export step in the cv-campaign pipeline. Both the CV pipeline.
---

# CV Campaign — DOCX Production

This skill governs all DOCX production in the cv-campaign pipeline. Load it before any DOCX export step. Output files are `.docx`, opened directly in Word. {{USER_FIRST_NAME}} exports to PDF before sending.

**The templates own all fonts, sizes, and colors — never hand-set these.**

---

## How DOCX production works

cv-writer outputs **styled markdown** using pandoc's `custom-style` div and span syntax. The pipeline converts it to `.docx` at Step 6 using pandoc with the `.dotx` reference templates. A short post-processing script then updates the role-specific Subtitle in the CV document header.

**Templates (in `./references/`):**
- `rachel-{{USER_LAST_NAME}}.dotx` — CV reference template. Contains all custom styles, {{USER_FIRST_NAME}}'s name and contact info in the document header, and correct formatting throughout.
- `cover-letter-template.dotx` — Cover letter reference template. Contains header and styles.

Neither template should be read into context. Use them only as pandoc `--reference-doc` arguments.

---

## Prerequisites

- `pandoc` — DOCX conversion
- `python-docx` — subtitle update script (`pip install python-docx`)

---

## Step 6 production protocol

Run these steps in sequence. All bash commands run directly — no agent spawn needed.

**Plugin dir:** the directory containing `agents/`, `skills/`, and `references/` — typically the plugin root.

**Output dir:** `{{ICLOUD_OUTPUT_PATH}}/cv-campaign-<YYYY-MM-DD>/`

**Company directory:** Each role's files go in a subdirectory named after the hiring company. The subdirectory name is derived from the Company property: lowercase, spaces replaced with hyphens, non-alphanumeric-or-hyphen characters stripped, consecutive hyphens collapsed. If the result is empty or the company is unknown, use `unknown-company`.

```bash
COMPANY_DIR=$(echo "<company_name>" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//')
[ -z "$COMPANY_DIR" ] && COMPANY_DIR="unknown-company"
```

Examples: `"Nuvoton"` → `nuvoton` · `"Visual Layer"` → `visual-layer` · `"Coro Cybersecurity"` → `coro-cybersecurity`

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

Run the conversion script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/convert-cv.sh" \
  "/tmp/<cv_filename>.md" \
  "/tmp/<cl_filename>.md" \
  "<output_dir>/<company_dir>" \
  "${CLAUDE_PLUGIN_ROOT}"
```

Pandoc inherits the header/footer from the reference template. {{USER_FIRST_NAME}}'s name and contacts appear automatically. Only the Subtitle (role tagline) needs updating per role.

### 4. Update the Subtitle in the CV header

Run the subtitle script on the file in the output directory (convert-cv.sh writes DOCX directly to output_dir, not /tmp):

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/<cv_filename>.docx" \
  "<role title>"
```

**The subtitle MUST be the exact job title {{USER_FIRST_NAME}} is applying for — taken verbatim from the JD.** Examples: "Head of Marketing", "Director of Product Marketing", "VP of Marketing". NOT a generic descriptor like "Product Marketing & GTM Leader". NOT {{USER_FIRST_NAME}}'s background framing. The role title. Full stop.

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

This gives a plain-text word count of the full rendered document (including all headers, titles, dates, and body). {{USER_FIRST_NAME}}'s CV is senior-level with a full work history — a clean 2-page document is normal and expected. Thresholds are calibrated accordingly:

- **Under 1050 words** — proceed to Notion writeback.
- **1050–1350 words** — likely 2 dense pages; proceed but flag in the chat summary: "CV word count at [N] — confirm 2-page fit before sending."
- **Over 1350 words** — likely over 2 pages. Return to cv-writer with: "CV plain-text word count is [N] after DOCX conversion, indicating likely overflow beyond 2 pages. Cut bullets from the lowest-priority roles to bring body word count under 1000."

After cv-writer returns a revised draft, re-run the full export protocol from Step 2. One revision pass only — if still over threshold after one pass, proceed and flag in the chat summary.

### 7. Generate Draft Directory URL

After both files are verified, construct the Draft Directory URL for this role's directory. Hold it in memory — the pipeline writes it to the `Draft Directory` Notion property in the writeback step.

```bash
DATE_FOLDER=$(basename "<output_dir>")  # e.g. cv-campaign-2026-05-26
DRAFT_DIR_URL="https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2F${DATE_FOLDER}%2F${COMPANY_DIR}%2F"
```

Example: `https://anchorpoint.app/link?p=projects%2F83fe790c-6170-462d-a560-ad639af051c6%2Fcv-campaign-2026-05-26%2Fnuvoton%2F`

---

## File naming conventions

All filenames are lowercase, no spaces, hyphens between words. Extension is `.docx`.

- CV: `cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx`
- Standard cover letter: `coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx`
- Hebrew CV: `he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx`
- Hebrew cover letter: `he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx`
- Reviewer feedback: `feedback-<roletitle>-<company>-<monYYYY>.md`
- Revision log (per role): `revision-log-<roletitle>-<company>-<monYYYY>.md`
- Revision log (per run): `revision-log-<YYYY-MM-DD>.md`
- State file: `state.json`

Example: `cv-{{USER_LAST_NAME}}-head-of-marketing-acme-apr2026.docx` / `revision-log-head-of-marketing-acme-apr2026.md`

---

## Hebrew DOCX production protocol

Hebrew DOCX files are produced inline in Step 6H (Standard/Edit pipelines). This section documents the bash steps for reference — they are spelled out in full in each pipeline skill.

**Footer:** Hebrew CVs use `static-cv-footer-he.md` (Hebrew-language Education and Languages sections) instead of `static-cv-footer.md`. The pipeline concatenates this file before calling pandoc.

**Hebrew templates:** Two dedicated templates exist for Hebrew output — both located in {{USER_FIRST_NAME}}'s Office templates folder:

- `cvHe.dotm` — Hebrew CV reference template (macro-enabled)
- `he-letter.dotx` — Hebrew cover letter reference template

Full path: `{{WORD_TEMPLATES_PATH}}/`

Both Hebrew templates support RTL formatting. Use `--reference-doc` with these templates — do not use pandoc's default template for Hebrew output.

**YAML front matter:** Hebrew markdown files must include the following front matter at the very top (before any content). The hebrew-localization agent includes this in its output. Do not strip it:

```yaml
---
dir: rtl
lang: he
---
```

**Conversion steps for Hebrew CV:**

```bash
HE_TEMPLATES="{{WORD_TEMPLATES_PATH}}"

# 1. Concatenate Hebrew CV markdown with Hebrew footer
cat /tmp/he-<cv_filename>.md \
    "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/static-cv-footer-he.md" \
    > /tmp/he-<cv_filename>-with-footer.md

# 2. Convert with pandoc using Hebrew CV template
pandoc /tmp/he-<cv_filename>-with-footer.md \
  --reference-doc="${HE_TEMPLATES}/cvHe.dotm" \
  -o "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"

# 3. Update subtitle
python3 "${CLAUDE_PLUGIN_ROOT}/skills/cv-campaign-export/scripts/update-subtitle.py" \
  "<output_dir>/<company_dir>/he-cv-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx" \
  "<role title>"
```

**Conversion steps for Hebrew cover letter:**

```bash
HE_TEMPLATES="{{WORD_TEMPLATES_PATH}}"

pandoc /tmp/he-<cl_filename>.md \
  --reference-doc="${HE_TEMPLATES}/he-letter.dotx" \
  -o "<output_dir>/<company_dir>/he-coverletter-{{USER_LAST_NAME}}-<roletitle>-<company>-<monYYYY>.docx"
```

All files save to the role's company subdirectory:
`{{ICLOUD_OUTPUT_PATH}}/cv-campaign-<YYYY-MM-DD>/<company_dir>/`

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

**Never include in cv-writer output:** `## EDUCATION`, `## LANGUAGES`, `## ADDITIONAL` — these are injected automatically by {{USER_FIRST_NAME}}'s Word macros after DOCX export. They must not appear in the markdown passed to pandoc. If they appear, the macro will duplicate them in the final document.

### Summary paragraphs → Normal (no annotation needed)

Regular markdown paragraphs use the `Normal` style automatically:

```markdown
Go-to-market and technical marketing leader with 15 years of experience translating complex B2B products into clear value for the buyers who need them.
```

### Builder / Leader competencies line → Normal (no annotation needed)

Plain paragraph, pipe-separated. No annotation:

```markdown
Product Marketing | GTM Strategy | Technical Documentation | Analyst Relations | Team Leadership | Content Strategy | Sales Enablement | Brand
```

### RoleTitle

```markdown
::: {custom-style="RoleTitle"}
Head of Product Marketing | [Visual Layer]{custom-style="BlueFont"} | Tel Aviv, Israel | *Apr 2025 -- Apr 2026*
:::
```

Notes:
- Company name uses the `BlueFont` inline span for one word/phrase
- Dates (after the last `|`) are italicized with standard markdown `*italic*` — the style applies italic locally
- Use `--` for en-dashes in date ranges

### RoleOverview

```markdown
::: {custom-style="RoleOverview"}
Computer vision and ML platform acquired by Camtek ($3M+ integration); sole marketing hire from founding through acquisition, owning all GTM and technical documentation.
:::
```

One sentence. No bold or italic markup — the style handles formatting.

### RoleActivitiesList bullets

```markdown
- ::: {custom-style="RoleActivitiesList"}
  Led full GTM motion across product, content, events, and sales enablement for a seed-stage computer vision platform targeting manufacturing and defense verticals.
  :::

- ::: {custom-style="RoleActivitiesList"}
  Built the documentation infrastructure from zero: API docs, product guides, and a GEO-optimized technical site that became a primary inbound channel.
  :::
```

For a role with a single bullet, use `RoleActivitySingle` instead:

```markdown
::: {custom-style="RoleActivitySingle"}
Fractional GTM and content for seed-stage SaaS clients; engagements kept open alongside full-time roles.
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
Team building (up to 13 reports) | Cross-functional alignment | Board reporting
:::
```

### BlueFont inline span

Use for company name in RoleTitle — ONE word or phrase per line, maximum:

```markdown
[Visual Layer]{custom-style="BlueFont"}
```

### Earlier line (collapsed older roles)

```markdown
**Earlier:** Senior marketing and content roles across B2B SaaS, media, and agency — full details on LinkedIn.
```

Plain `Normal` style paragraph. "Earlier:" is bolded with standard markdown `**bold**`.

---

## Cover letter — custom-style annotation reference

```markdown
::: {custom-style="Salutation"}
Hi to the [Company name] team!
:::

Body paragraphs are regular markdown paragraphs (Normal style — no annotation needed).

[{{USER_FIRST_NAME}} {{USER_LAST_NAME}}]{custom-style="Signature Char"}
```

---

## Cover letter approach and styles

### Word count and structure

All cover letters are limited to a single page, 230–290 words (not counting greeting or sign-off). This matches the requirement in cover-letter/SKILL.md and the gatekeeper check. Structure and voice are consistent across all letters and follow the framework below.

### Voice constraints

**Load `skills/cover-letter/SKILL.md` before writing any cover letter.** It defines writing mechanics, letter structure, and use-case patterns. **Also load `references/cover-letter-self-check.md`** — forbidden phrases, forbidden structures, and fabrication traps are now there. Both are non-negotiable.

Every claim about the company must be traceable to the JD or brief. Do not infer the company's strategy, culture, or operating model from category signals. If a sentence about them cannot be sourced, cut it or rewrite it as an observation about the role.

The register is direct, specific, and confident. Energy is genuine, not performed. Warmth comes from the closing line.

{{USER_FIRST_NAME}} writes about what she does, not what she avoids. Frame capability through action, not through the failure mode it prevents.

{{USER_FIRST_NAME}} can express genuine interest when it is real: "I have wanted to work at X for years," "the work you are doing on Y is exactly where I want to be." Use only when true — not as a default opener.

What stays prohibited is unverifiable claims about the company itself — its strategy, uniqueness, or character. The test: if the sentence makes a claim about the company, it needs sourcing. If it makes a claim about {{USER_FIRST_NAME}}'s motivation, she is the source.

Do not reach for cleverness. If a line calls attention to its own phrasing, cut it.

### Cover letter framework

**Before writing:** Read the Company self-characterization section from the structured JD. This "good fit / not a good fit" or "you'll thrive here if" section is the most honest signal of what they're actually selecting for. Mirror it — not by copying it, but by demonstrating {{USER_FIRST_NAME}} matches the positive signals with a specific named proof.

#### Structure, in order

**1. The opening move.** One of two things, both in first person — the opening paragraph is always {{USER_FIRST_NAME}} speaking first:
- {{USER_FIRST_NAME}}'s genuine reaction to something specific about this role: what she recognizes, what excites her, what maps directly to work she has done. Name the role signal, then name the {{USER_FIRST_NAME}} proof. The worked examples all follow this pattern.
- Genuine first-person interest in this specific company, when {{USER_FIRST_NAME}} actually feels it. Use only when real.

Observations about the company's product, buyers, or market position belong in paragraph 2 or later. Do not open with second-person sentences — "Your buyers are technical," "Your product does X" — regardless of how accurate they are.

**2. Signalling business understanding.** A concrete observation about the company's operating model, the problem they are hiring to solve, or the structural reality of the role. Sourced from the JD. Specifics over adjectives. May fold into the opening paragraph when both beats read naturally as one.

**3. The positioning move.** Which part of {{USER_FIRST_NAME}}'s documented experience maps directly to what they need, and why. One named company, one named outcome.

**4. Handling adjacent or smaller-scale experience.**

THE NUMBER ONE GOLDEN RULE: COVER LETTERS ARE RACHEL'S OPPORTUNITY TO SHINE. LEAD WITH HER MOST RELEVANT BIGGEST STRENGTHS. NEVER PRE-EMPTIVELY EXPLAIN OR QUALIFY ANYTHING. ONLY LEAD WITH WHAT SHE HAS DONE AND NAME THE SPECIFICS THAT MAP TO WHAT THEY ARE HIRING FOR.

- Different domains and verticals are NEVER a gap and especially not a weakness.
- If there is any *perceived skill* gap the hiring manager will clock in the first 10 seconds, name the work she has done, let it stand. Do not add a scope qualifier. Lead with what was done, name the specifics, and stop.
- Do NOT volunteer scale they did not ask about. The phrasing pattern: "On the X side, I have run Y for a handful of Z clients — [named example] is one I can name. The work covered..."

**WRONG — never use these structures:**
- "The scale is different from X COMPANY — but..."
- "The closest I've worked to X is Y..."

**5. The closing posture.** A direct ask, not a request for permission. Warm or plain depending on the letter's tone. Never "I look forward to hearing from you at your earliest convenience."

### Prohibited phrasing (in addition to cover-letter skill rules)

- Never open or close with a fit claim: "This role has my name on it," "I'm the perfect candidate," "I was made for this role"
- Never volunteer a title gap — scope speaks for itself; that conversation is for the interview
- "Full disclosure" followed by a gap apology — banned
- "Whether that's the fit you need" — banned
- Never ever use "is worth naming" or "is worth calling out" — if it's worth naming, name it directly without the framing!!
