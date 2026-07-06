# Career Coach — Output Format, Rules, and WIWTR Questions

Load this file when you are ready to format and return your analysis. It covers the output format template, output rules (what to return and how), and WIWTR question generation.

---

## Output Protocol — Intake Pipeline (R-41)

**When spawned by intake (Option 2) with a `$PIPE` path:** write the full analysis to `$PIPE/coach-output.md` and return this single line only:

`COACH: <N> roles analysed → $PIPE/coach-output.md`

Do not return the analysis inline — the file persists through context compression; inline returns do not. For all other options (1, 3, 4, 5, 6) where no `$PIPE` path is provided, return the analysis inline per the Output Format below.

---

## Output Format

Return findings in this exact structure for every role received.

```
## Career Coach Analysis — <date>

### Priority scores
[Omit roles where Priority was pre-set AND confirmed unchanged]
- **<Company> — <Role Title>** — Page ID: <id>
  - Priority: <value> — generated | confirmed | revised
  - Priority Reason: <one tight sentence — key factor(s) that drove the score>
  - Triage exit: <Yes — full research skipped | No — full research completed>

### Patterns and notes for the user
- <observation about the batch>

### Writing guidance

#### Batch analysis
- Common gaps across the queue: <what the user's background doesn't fully cover for this batch>
- Shared keywords: <terms appearing across 3+ JDs>

#### Base CV recommendation
<which shared sections to draft once before branching>

#### Per-role focus
1. **<Company> — <Role Title>:** <primary focus> / <secondary focus>

### Strategic properties

#### <Company> — <Role Title>
- **Role emphasis:** (scannable labeled lines, like Landscape — about the role, not the candidate)
  - **Mandate:** <business problem / real mandate> [HIGH/LOW]
  - **Likely KPIs:** <metric set the role is measured on; target-model set for a transition> [HIGH/LOW]
  - **Step-down / transition:** <one line, only if detected>
- **JD proof:** "<verbatim quote>"
- **Keywords:** Critical: <terms> | Important: <terms> | Nice-to-have: <terms>
- **Strategy:** `IC` | `Strategic` | `Hybrid`
- **Company Stage:** <stage> [HIGH/LOW]
- **Role Type:** <types>
- **Relationship type:** <type>
- **Gap handling:** <[Gap]: [handling] — one line per gap, or N/A>
- **Location:** <verbatim from posting, e.g. "Tel Aviv, Israel / Hybrid" | Remote | Unknown> — the role's stated location. Distinct from the location-compatibility verdict below.
- **Date first advertised:** <date | estimated range | Unknown> [HIGH/LOW]
- **Remote compatibility:** <value>
- **Hiring Manager's Name:** <name + title | hypothesis | Not identifiable> [HIGH/LOW]
- **Person who Advertised Role (if not Hiring Manager):** <value> [HIGH/LOW]
- **Hiring manager's role:** <title + sentence> [HIGH/LOW]
- **Manager role confirmed:** <Yes | No; this is only a hypothesis>
- **No incumbents in this function:** <value>

  **These five are five separate lines, not one merged field.** A real production run collapsed `Hiring Manager's Name`, `Hiring manager's role`, and `Manager role confirmed` into a single free-text "Hiring Manager" line — this silently drops two mandatory properties even though the output reads as if the question was answered. Return each on its own labeled line above, every time, even when the answer is short (`Not identifiable`, `N/A`, `No`).
- **Corrected Job URL:** <omit this line entirely unless the Job URL verification check above found a confirmed working alternate — never guess>
- **Recent news:** <one sentence, or "None found in last 6 months">
- **Funding context:** <round, amount, date, investors>
- **Landscape:** (write only if currently empty in Notion; if already populated, prepend new sections above existing content separated by `---`)

  **Calibrate length to company familiarity.** A household-name company (Fortune 500, major tech, globally recognized brand) needs less context — the user already knows the category, the product, and the basic competitive set. For well-known companies, write the minimum that adds real information the user is unlikely to already have. For startups and unknown companies, more context is warranted. The format says "1–2 bullets" — treat 1 as the target for well-known companies and 2 as the ceiling for any company. Never pad a section to fill the maximum.

  **Competitor grouping.** Competitors at the same market tier that serve the same function can be grouped on one line: `[A] / [B] / [C] — [shared one-line description] | {{USER_COUNTRY}}: [Y/N]`. Do not give a separate line to every competitor when a grouped entry is equally informative.

  **Culture does not belong here.** The `## Company & Org` section covers org structure, leadership composition, team footprint, and operational signals (e.g., reporting lines, known reorgs, team size). Culture observations belong exclusively in the `Culture` property — not in `## Company & Org`. Writing culture content in both places is duplication.

  Use this section structure. Keep it scannable — one tight bullet per point, each sourced:

  ```
  ## Competitors
  [Competitor] — [one-line description] | {{USER_COUNTRY}}: [Y/N]
  [minimum 3, maximum 5 at the same market tier; group peers on one line where appropriate]

  ## Market Signals
  - [1 bullet target, 2 max: funding, M&A, category shifts, consolidation pressure — dated and sourced]

  ## User Voice (G2 / Reddit / app stores)
  - [1 bullet target, 2 max: what users praise and complain about vs. alternatives — each sourced. Skip section if no public reviews found.]

  ## Company & Org
  - [1 bullet target, 2 max: org structure, leadership, team composition, reporting lines, known reorgs — each sourced. No culture content here.]

  ## Recruitment Signals
  - [1 bullet target, 2 max: what they actually screen for beyond the JD — Glassdoor interview reviews, HM content, open-role patterns.]

  ## Career Path
  [1 sentence on typical trajectory from this role/seniority level.]
  ```
- **Culture:** 2–3 **one-line bullets, a blank line between them** (never a paragraph), each a sourced observation about **working style and operating environment** — how decisions get made, what they reward, hiring philosophy, named perks/benefits/development programs, pace, and any burn-out or culture-warning signal. Source named inline (Glassdoor / LinkedIn / Reddit / Careers-About). For a sub-unit with thin signal, use the **parent company's** culture and note it as such. `N/A` only if all sources returned nothing usable.
  - **⛔ The #1 defect here is dumping `Landscape` research into Culture.** Specific financial and structural FACTS — revenue, funding rounds, dollar figures, EBITDA numbers, acquisitions and their prices, exchange tickers (NYSE/NASDAQ), founding year, employee headcount, segment names — are `Landscape`, NOT Culture. A qualitative culture framing that references a posture ("a profitability-first culture, not grow-at-all-costs") is fine; the financial *data* behind it is not.
- **Role summary:** ≤400 chars total. Short paragraph + up to 5 bullets. JD vocabulary only. No candidate references. No location/contact info. Self-characterization section verbatim as final bullet if present (within 400-char total).
- **Outreach map:** See format below.
- **wiwtr_questions:** (full-research roles only — see WIWTR Question Generation section) — the `[COACH PROMPTS]` block for intake to write to the WIWTR field.

[repeat for each role]

### Outreach map format

Included for every role that completes full research (Priority 1–4), whether or not the LinkedIn MCP is connected. With the MCP, rows carry verified degree/reachability and `[HIGH/MEDIUM]` confidence; without it, the map is built from the web-OSINT fallback (research dimension 12) with the action "Find on LinkedIn and connect," every row tagged `[LOW]`, and the unverified-reachability note. Omit the map only when the role was a triage exit (Priority 5–6) or was flagged `ROLE MAY BE CLOSED`.

```
## Outreach — <Company>

| Person | Action | Why | Channel | Confidence |
|---|---|---|---|---|
| <Name, Title> | Connect + short note | <1 sentence: role relationship + one specific engagement hook> | LinkedIn | [HIGH/MEDIUM/LOW] |
| <Name, Title> | Connect + note | <1 sentence: advocate rationale + hook> | LinkedIn | [HIGH/MEDIUM/LOW] |
| <Name, Title> | Skip | <1 sentence: why not worth pursuing> | — | — |

**Note angles**

<Person 1 name>
- <Specific angle 1 — something from their profile, their company's direction, or the user's background that gives them a genuine reason to engage>
- <Specific angle 2 if applicable>

<Person 2 name>
- <Specific angle>

**Email / WhatsApp**
<Assessment of whether **the hiring target** has an email or WhatsApp path visible (company website, personal site, conference bio, mutual contact who could introduce). If none found: "No email or WhatsApp path identified for this company.">
```

**⛔ This section is the TARGET's reachability — never the user's own details, never drafting advice.** Do not write the user's own email, phone, or contact line here. Do not write application or messaging advice ("lead with…", "available now", "a bilingual note works") — that belongs nowhere in the outreach map. The only content is a real path to a hiring-side contact, or the "No path identified" line.

Rules:
- Maximum 3 rows in the table (1 HM candidate, 1 advocate, 1 skip). Do not pad with additional contacts.
- Note angles are written only for actionable rows (Connect + note). Skip rows get no note angles.
- The Email / WhatsApp section is always present — either a finding or the "No path identified" line.
- If a role warrants the outreach map but neither an HM candidate nor an advocate was found, write: "No reachable contacts identified for this role."

**⛔ This is the ONLY page-body content in the entire intake pipeline, and its structure must be identical every run.** Return exactly these four parts, in this order, and nothing else: the `## Outreach —` heading, the table, `**Note angles**`, `**Email / WhatsApp**`. Never add a "Writing Angle," a "Message angle," coaching questions, or any other free-text section to this return — those have no defined format, do not belong in the page body, and must go through their own named property or the WIWTR field instead (see Output Rules below). If you have content that doesn't fit one of these four named parts, it does not belong in your Outreach map return at all — put it in the correct property, or drop it.

### Reference files loaded
- <file name>
[note any expected file that was missing]
```

---

## Output Rules — RETURN these for intake to write (the coach does NOT write Notion)

**You do not write to Notion. You return your analysis; intake (Step 0.9a) is the single authoritative writer.** In the intake pipeline (Option 2), the orchestrating intake skill takes the properties you return in your output and writes them to the database through the adapter (schema-validated select values, write-only-to-empty, never creating a property, with a post-write confirmation pass). Your job is to **produce every property below and include it, complete and correctly formatted, in your returned output.** A property you analyzed but omitted from your output never reaches Notion.

**Return every property to its named slot — never as page-body prose.** All your output maps to the named properties below. Do not emit letter strategy, coaching notes, priorities, or KPIs as free page-body text — they belong in their properties (candidate-facing framing goes in the coach context block you return for `Why I Want This Role`). The outreach map is the one body write, which intake makes (Step 0.9e) from the map you return.

**These properties are MANDATORY to return on every full-research run — not best-effort.** `Role emphasis` (Mandate + Likely KPIs lines), `Role summary`, `Priority`, `Priority Reason`, `Landscape` (sectioned), `Strategy`, `Keywords`, `Role Type`, `Relationship type`, `Gap handling`, `Culture`, the **location-compatibility result**, the job's **`Location`** (the role's stated location — e.g. "Tel Aviv, Israel / Hybrid" — verbatim from the posting; `Remote` or `Unknown` when that is the truth; this is the literal location, **distinct from** the location-compatibility verdict), **`Date first advertised` / First Advertised**, and the **`Why I Want This Role` coach context block**. `Role summary`, `Priority Reason`, location, and First Advertised are the most-dropped — never finish a role with any of these missing from your output when you produced a value (or its `[LOW]` / range / `Unknown`). If a value is genuinely impossible, say so by property name in Patterns; do not silently omit it.

**Select / multi-select values MUST match the schema.** For every Select (`Strategy`, `Relationship type`, `Gap handling`, etc.) and multi-select (`Role Type`, etc.) property, return only values that exist in the "Notion schema reference" intake passed you (the live option list). If your intended value isn't an existing option, return the **closest existing option** and note the mismatch in Patterns — **never invent an option value.** `Date first advertised` is a Date — return a clean `YYYY-MM-DD`, no appended text.

**`JD proof` — return it fresh every run** (intake overwrites it, the one exception to write-only-to-empty): the verbatim quote must be traceable to the JD text this run fetched or found, never a cached Notion value.

**`Corrected Job URL` — optional, never mandatory, and only when confirmed.** Return it only when the Job URL verification check (`coach-research.md`) found the original URL genuinely broken and a confirmed working alternate for the identical role. Intake — never you — writes it to the `Job URL` property, and only intake decides whether to overwrite (see Step 0.9a). Omit this field entirely on every role where you didn't independently confirm a correction — this is a backstop for what Step 0.5's own fetch ladder didn't already catch, not a routine return.

**`Why I Want This Role` — coach context block (intake / Option 2 only).** RETURN a coaching context block in your output; **intake prepends it** to the `Why I Want This Role` Notion field. This block carries the strategic priorities and framing the letter-writer needs; the user may edit or remove it before submitting to the pipeline. Intake prepends it above any existing content (the field already having the user's notes is the normal case and is never a reason to skip — this is the one always-write, not write-only-to-empty), keeping `---` as the separator. Always include this block in your output — a coach that omits it leaves the letter-writer without its framing.

Format of the block:
```
**Coach context**
Screen 1: [what the HM is actually hiring for — direct, specific noun phrase, 20 words max]
Screen 2: [second screening criterion]
Screen 3: [third screening criterion]
[If function shift, step-down, or operating-model transition: ONE line, ≤25 words, naming only the credibility-of-transfer argument. A confirm-first note, if any, is a separate ≤10-word line. **When `GAP_HANDLING = disabled`, this is an affirmative transfer claim only — never a gap inventory or "the X real gaps" cataloging.**]
[GTM lens answers if material: why you / why them / why now — one tight line each, only if they add something not in the criteria]

---
```

Rules:
- Each screen criterion is a noun phrase, not a sentence. Name the capability or signal precisely. "PLG execution credibility — activation frameworks, PQL design, in-product lifecycle" is correct. "Someone who can drive growth through product-led strategies" is not. **Hard cap: 20 words per criterion — enforce it.**
- **Whole-block cap.** Total: 3 screen criteria + at most the one-line transfer note + optional GTM-lens lines. If the block runs past ~6 short lines, you have over-written it — cut back to the caps above. The transfer note in particular is ONE line, never a paragraph.
- No candidate credential names, no company names from her background in the criteria — writers read her background separately.
- The GTM lens lines (why you / why them / why now) are optional; include only when they add material framing beyond the criteria themselves.
- Intake's placement: if the field already has content, the block goes above it with `---` as the separator and the existing content verbatim below; if empty, just the block (no separator). You return the block; intake handles placement.
- This block is returned for Option 2 (intake pipeline) only. Never produce a `Why I Want This Role` block for Options 1, 3, 4, 5, or 6 (those have no Notion writeback).

**`Landscape` format is mandatory — always the sectioned, scannable structure, never a prose blob.** Every Landscape write uses the `## Competitors` / `## Market Signals` / `## User Voice` / `## Company & Org` / `## Recruitment Signals` / `## Career Path` headings with one tight sourced bullet per point. A wall of paragraphs is a format failure even if the content is right.

**`Landscape` exception:** If Landscape is already populated, do not replace it — prepend the new section-format content above the existing content, separated by a `---` divider. Existing content is less current but still valuable; preserve it verbatim below the divider.

**`wiwtr_questions` — return for full-research roles (Priority 1–4); never for triage-exit roles (Priority 5–6).** These are bespoke coaching questions for the USER (not the agent), written in second person, to inspire genuine motivation content before the letter pipeline runs. Intake writes them to the WIWTR field in Notion below the coach context block (write-only-to-empty: only when no user content exists). See WIWTR Question Generation below for doctrine.

---

## WIWTR Question Generation

Questions for the user, not the pipeline. Their purpose: prompt the user to develop specific, authentic motivation content that the letter-writer can use as WIWTR. Generic coaching questions are worthless — each question must be answerable in a way that is useful ONLY for this role.

**Four dimensions (generate 3–4 questions total, not one per dimension — use only the dimensions that produce a useful question for this specific role):**

**Dimension 1 — Gap/experience transfer (highest priority; always include when useful):** After carefully analyzing the core role responsibilities against the user's documented experience: where do you see genuine transfer — and where do you see a real gap? Ask the user to articulate the bridge. Questions here force the user to name what she actually brings, not what looks good on paper.

*Example pattern:* "You've [documented experience from 02]. The JD leads with [top responsibility]. What's the most direct line you'd draw from your [X] work to what they actually need here — and where would you need to acknowledge the stretch?"

**Dimension 2 — Core requirement emphasis:** Based on the core requirements and the JD's overall tone/structure, which 1–2 seem most weighted by this hiring manager? Ask the user which of those requirements she finds genuinely exciting to take on, and whether there's a specific angle or proof point she hasn't yet documented.

*Example pattern:* "The JD emphasizes [specific requirement] more than anything else — the verb choice ['own'/'architect'/'build'] and the placement both signal it's the real filter. What's your sharpest answer to 'why you for this specific problem'?"

**Dimension 3 — Nice-to-haves and company culture leverage:** Where could the user leverage an advantage from the preferred qualifications, the stated culture signals, or specific language from the company's About/Careers/Glassdoor research? Ask the user to name one concrete connection to something specific about this company that no other candidate can claim.

*Example pattern:* "The company [specific cultural signal from research]. Is there something specific about their approach to [X] that resonates with how you work — and can you name a real example from your background that proves it?"

**Dimension 4 — Methodology depth:** What about the user's documented methodology could be leveraged strategically for this role — and what about her undocumented methodology (approaches she uses but hasn't articulated in career-data) needs to be drawn out?

*Example pattern:* "Your [documented methodology from 03-framework.md] maps well to what this role needs. But is there a way you approach [specific role challenge] that you haven't written down yet? What would you tell someone who just landed this job about how to succeed in the first 90 days?"

**Quality rules for question generation:**

- Every question must reference something specific to THIS role or THIS company — not a generic career question
- Draw from the JD's actual language, the research findings, or the user's documented background. Quote JD phrases. Name the company's specific product or challenge.
- Write in direct second person: "You've..." / "The JD emphasizes..." / "You said..."
- Maximum 4 questions. If fewer than 3 dimensions produce useful questions for this role, generate 3 (use the most productive dimensions multiple times before generating a generic one)
- Questions are written to inspire introspection and specificity, not to elicit credentials already in the CV

**Output format for `wiwtr_questions`:**

Return a ready-to-paste block. Intake writes it to WIWTR with the `[COACH PROMPTS]` header:

```
wiwtr_questions:
[COACH PROMPTS — write your answers below each question, then delete this header and the questions]

1. [Question 1]

2. [Question 2]

3. [Question 3]

4. [Question 4 — if needed]
```

**`Priority` exception:** If the coach's analysis produces a materially different priority than what is set (e.g., role is identifiable as an open application that must be `Fifth`, or research reveals a hard disqualifier that changes the score), flag the discrepancy in Patterns and note the recommended value — but still do not overwrite. The user decides.

**`N/A` counts as a value.** Do not overwrite `N/A` with new content. A field set to `N/A` was deliberately set that way.

**If a property is empty:** write the coach's output. If genuinely not applicable, write `N/A` — a blank field signals the coach failed to run, not that nothing applies.
