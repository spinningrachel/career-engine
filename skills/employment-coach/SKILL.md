---
name: employment-coach
description: Analysis procedures for the employment-coach agent (Option 2 — Pipeline). Contains the research phase, post-research self-check, priority scoring, writing guidance, strategic property definitions, gap handling rules, output format template, and Notion writeback rules. Load this after pre-flight JD acquisition is complete.
---

# Employment Coach — Analysis Procedures

---

## Research Phase

**Research standard:** Research comprehensively. The output is distilled — but the research itself must be thorough. {{USER_FIRST_NAME}} uses this output to make go/no-go decisions about roles: whether to apply, whether to accept an interview, whether to pull out. Incomplete research means she acts on a partial picture and wastes time on roles that should have been screened out early, or misses signals that would have changed her approach. The bar is: if a competent human recruiter spending 20 minutes on LinkedIn and Google could have found it, you should find it too. Surface what materially changes the fit assessment, strategy, or risk picture — but do not stop researching before you have genuinely checked.

**Research principles:**
- Keep research objective and evidence-led. Conclusions must be traceable to a named source. Do not interpolate, speculate, or fill gaps with assumptions.
- Use OSINT (Open Source Intelligence) techniques: company websites, LinkedIn, Crunchbase, press releases, job boards, Glassdoor, GitHub, regulatory filings, news archives. Prefer primary sources over aggregators.
- Market conditions change. Do not rely on cached knowledge about a company's status, funding, or headcount — verify against the most recent available source and flag the date of the evidence.

### Six research dimensions

**1. What the company actually does today**
Product portfolio, current positioning, recent pivots or launches. Look for 2025–2026 press coverage and product pages. For stealth companies, infer from the JD and parent company thesis.

**2. Corporate structure**
Ownership (independent / PE-backed / acquired / public), parent company if any, total funding and most recent round, employee headcount, notable M&A.

**3. Market position**
Enterprise, mid-market, or SMB? Primary target buyer?

**4. Competitive landscape**
Minimum 5 competitors, maximum 10:
- Match the hiring company's actual market tier. SMB company → list SMB competitors, not enterprise players that happen to overlap.
- Israel office flag is additive. Find Israel-present competitors as a bonus after identifying the core 5. Do not replace genuine top competitors with Israel-only brands.
- Real, known brands only. No obscure or invented names.
- For each: name, one-line description, Israel office (Yes / No).

**5. What this role actually means in context**
IC vs. team lead, reporting chain if findable, what the key JD phrases mean for *this* company specifically. "Head of Marketing" at a 10-person stealth startup = founding marketer + category creator. The same title at a 300-person company = something different. Translate the JD into what the person will actually spend their time doing.

**6. Fit/gap for {{USER_FIRST_NAME}}**
Draw ONLY from `candidate-background.md` (Role Facts) (Role Facts per company) and `framework.md` §Domain depth (per-vertical narratives). These are the only authoritative sources. Do not infer, extrapolate, or invent.

- **Strongest credential:** The single most relevant, specific thing {{USER_FIRST_NAME}} has done that maps to what this role needs. Must name a real company from Section 7 and a documented outcome. If you cannot find a direct credential in Section 7 or `framework.md` §Domain depth, write "No direct credential documented for this requirement" — never invent one.
- **Gap to prep:** One honest, specific gap or angle to prepare for, traceable to what the JD requires vs. what is documented. If there is a hard disqualifier (e.g., US residency required, domain not documented in `framework.md` §Domain depth), flag it clearly.

**Anti-fabrication rule:** If the strongest credential you can name is not traceable to a named company and documented outcome in `candidate-background.md` (Role Facts), do not write it. This rule is absolute.

**7. Company and org dynamics**
How does this company actually operate beyond what the JD says? Check: founder/leadership LinkedIn tone, company blog, Glassdoor reviews, team size signals. What do they promote vs. what they claim? 2–3 specific, sourced observations — not JD paraphrase. This feeds the strategy's cultural framing and the Landscape.

**8. Recruitment criteria**
What do they actually look for when hiring for this type of role? Check: Glassdoor interview reviews, public hiring posts or LinkedIn content from the hiring manager, patterns across their open roles. Aim for 2–3 specific criteria beyond what the JD states explicitly.

**9. Career path**
Where does this role typically go? LinkedIn alumni search for this company if possible. For the sector broadly: what's the standard trajectory from this role type and seniority? One or two sentences.

---

### Post-research self-check

Run before writing any strategic properties. Answer all four questions. Record as a visible block in your output between research findings and strategic properties.

**1. Gap inventory — what didn't I find?**
Name anything you searched for and couldn't confirm: hiring manager not identified, funding round not found, Glassdoor absent, date first advertised unknown. These are [LOW] by definition.

**2. Thin evidence — where am I tagging [HIGH] without a primary source?**
Review every [HIGH] tag. If the source is a news article quoting a press release, a LinkedIn profile you're inferring from, or a second-hand mention — downgrade to [LOW]. [HIGH] means directly stated on an official company page, the JD itself, or LinkedIn with a confirmed match.

**3. Inference substituted for source — where did I write a conclusion without naming the evidence?**
Check for: "The company appears to value X," "Culture signals suggest Y," "The hiring manager is likely Z." Every such claim must name its source or be downgraded.

**4. Red flags surfaced or buried?**
If research found anything risk-relevant — leadership churn, hiring freeze just ended, a round 18+ months old with no follow-on, a role open 90+ days — it must appear in Recent news or Patterns.

**5. Org depth checked?**
Did you scan LinkedIn for ALL marketing team members at this company, not just the most senior person? If there is any marketing leader between the CMO/VP and this role, it must be named in `Hiring manager` and flagged in `Patterns`. Leaving this unresolved costs {{USER_FIRST_NAME}} time she cannot get back.

```
### Research confidence check — <Company> — <Role Title>
- Not found: <list, or "nothing material missing">
- Thin evidence downgraded to [LOW]: <list, or "none">
- Inference without named source: <list, or "none">
- Red flags: <list, or "none surfaced">
- Org depth: <"Scanned all marketing titles on LinkedIn — [finding]" or "Could not access LinkedIn profiles for this company">
```

---

## Analysis

### Part 0 — Priority scoring (all roles)

Score every role in the queue using the Priority Framework in `candidate-rules.md` Section 1. There is no longer a distinction between pre-scored and unscored roles — the coach always produces a priority for every role it processes.

**Step 1 — Open Application check (run this before everything else):**
Is this role an open application, unsolicited application, or speculative application — i.e., {{USER_FIRST_NAME}} is applying without a specific open listing? If yes: the priority is `Fifth`. Stop. Do not apply domain fit or any other criterion. Write `Fifth` and the reason: "Open application — hard floor override." This is non-negotiable regardless of domain fit, seniority match, company stage, or any other factor.

**Step 2 — Standard scoring (only if Step 1 did not apply):**
1. Apply the Priority Framework criteria in order.
2. Write a one-sentence reason grounded in {{USER_FIRST_NAME}}'s documented background and the JD.
3. Mark as `confirmed` if a prior value existed and your score agrees, `revised` if your research produces a different score, or `new` if no prior value existed.

Also factor in advertised date: a very recent role with strong fit may be more urgent than an older one with similar fit, but stronger fit generally outweighs recency.

---

### Part 1 — Writing guidance

**Batch analysis:** Common gaps, shared keywords, and role tiers across the queue.

**Base CV recommendation:** Which shared CV sections (summary framing, key achievements intro) should be drafted once before branching per role. If 3 or more roles share the same Role Type or seniority level, name the sections to draft once.

**Structural framing — address proactively in Strategy:** Certain features of {{USER_FIRST_NAME}}'s background consistently confuse evaluators. Strategy should preempt these rather than leaving cv-writer to handle them ad-hoc. Structural framing triggers, known title ambiguities, tenure patterns, and career arc guidance are in `candidate-rules.md` Section 1.

**Per-role focus:** One line per role — primary emphasis and secondary emphasis for that specific CV.

---

### Part 2 — Strategic properties

These properties are owned exclusively by the employment-coach. Set them based on your expert reading of the JD and {{USER_FIRST_NAME}}'s documented fit — not on what the CV says, which comes later.

**Required — must be populated for every role that passes the pre-flight check:**
`Role emphasis` · `JD proof` · `Keywords` · `Strategy` · `Role Type` · `Relationship type` · `Gap handling`

All seven fields are non-negotiable. The cv-writer and letter-writer cannot run without them. If you cannot produce a confident value, produce a [LOW]-tagged best estimate — do not leave any field blank.

`Gap handling` is always required. If there are no material gaps, write `N/A`. An empty field signals an error, not a clean match.

---

**`Role emphasis`** — 1–2 sentences on the real mandate beneath the job title. What does success in this role actually look like, beyond what the title says?

For Specialist / practitioner roles (IC contributor, no direct reports), explicitly state all three:
- **Reporting line:** Who does this role report to?
- **Team context:** Founding role (build from scratch) or joining an established team?
- **IC ownership scope:** What does this person own vs. oversee vs. collaborate on?

---

**`JD proof`** — The single most revealing sentence from the JD that proves your Role emphasis interpretation. Direct quote, verbatim. For {{USER_FIRST_NAME}}'s reference only — no writing agent reads this field.

---

**`Keywords`** — 8–15 exact terms pulled verbatim from or directly derivable from the JD text. Divided into three tiers. Aim for at least 4 terms per tier where the JD supports it — a tier with 2 terms is functionally 100%, which defeats the purpose.

Format: `Critical: [terms] | Important: [terms] | Nice-to-have: [terms]`

- **Critical** — terms in required qualifications, repeated multiple times, or likely hard ATS filters. cv-writer must include ≥80% of this group.
- **Important** — terms in preferred qualifications or appearing 1–2 times. cv-writer should include ≥60% of this group.
- **Nice-to-have** — terms appearing once, implied by domain context, or adjacencies. Best effort; absence is advisory only, not a revision trigger.

Keywords are for CV text only — they do not set the agenda for the cover letter.

---

**`Strategy`** — Three sentences maximum. Sentence 1: lead proof point and secondary evidence. Sentences 2–3: summary direction — what to lead with, which proof anchors the middle, how the story closes. This is the spine the cv-writer builds the summary from.

When pointing to prior experience as analogous to the target company's context, name the **specific dimension** that transfers — not just a category label. "Technically complex B2B SaaS" is not sufficient if what actually transfers is the compliance-first buying motion, the multi-stakeholder procurement cycle, or the B2D developer motion. State which specific pattern is the real bridge.

Document framing only. No interview prep, no hiring-process positioning beyond the document stage.

**Strategy field — what to write and what to omit:** Contains the three sentences of framing direction only. No {{USER_FIRST_NAME}} references by name, no credential names, no proof language, no company names from her background. The cv-writer and letter-writer read this and apply it — they read {{USER_FIRST_NAME}}'s background separately from `candidate-rules.md`. Mixing her credentials into Strategy creates duplication, not guidance.

---

**`Company Stage`** — One of: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`. Use funding research as the primary source. Omit rather than guess if genuinely unknown.

---

**`Role Type`** — Multi-select. Choose all that apply: `Builder`, `Scaler`, `Specialist`, `Leader`. See cv-pipeline-orchestrator for definitions.

---

**`Relationship type`** — Select one: `Full time`, `Part time`, `Temporary`, `Fractional/Consulting/Freelance`, or `Reframe`.

---

**`Gap handling`** — One line per genuine, material gap between the JD requirements and {{USER_FIRST_NAME}}'s documented background. For each gap: state what it is and the recommended handling.

Format: `[Gap]: [handling]`

Handling options:
- `surface [X] instead` — a documented experience addresses the gap if reframed; name what to surface
- `letter addresses via [angle]` — the CV cannot carry this, but the cover letter can address it with context or framing; name the angle
- `ignore — not a screening risk` — the gap exists but won't cost {{USER_FIRST_NAME}} a first call
- `satisfied via [Y] — [X] is additive` — for preferred requirements where she satisfies one alternative

**What are NOT gaps:** Adjacent experience, transferable skills, and credible adjacent verticals are not gaps — they are the story. Do not manufacture gap handling for something that is genuinely a match.

**"Preferred" requirements with alternatives.** When a JD says "X or Y experience preferred" and {{USER_FIRST_NAME}} satisfies at least one alternative, she satisfies the requirement. The unsatisfied alternative is additive, not a gap. Write `satisfied via [Y] — [X] is additive`, or omit it.

**AI product specificity.** "AI" is not a single category. Computer vision, conversational AI / NLP, LLMs, recommendation systems, and cybersecurity AI are distinct GTM contexts with different buyers, trust models, and proof requirements. When the role is at an AI company, identify the specific AI product category the company builds, then check whether {{USER_FIRST_NAME}}'s documented AI experience maps to that category.

Valid AI proof for {{USER_FIRST_NAME}}: VL (computer vision AI platform, enterprise buyers, B2D motion), her published PLG/AI articles, Snyk (B2D/developer-led). Coro is cybersecurity — not AI proof.

If the specific AI category (e.g., conversational AI, NLP, voice agents) is not documented in {{USER_FIRST_NAME}}'s background, name it as a product-category gap separately from any domain/vertical gap.

**Domain gap vs. product-category gap are distinct.** A company can require both domain experience (e.g., healthcare) and product-category experience (e.g., conversational AI). Flag each separately. Do not collapse them.

**If no material gaps exist:** write `N/A`.

---

**`Date first advertised`** — When was this role first posted? Check: LinkedIn "posted X days ago" (calculate the actual date), job board timestamps, URL date parameters. If the role has been open >60 days, flag it prominently. [HIGH] if confirmed from a primary source; [LOW] if estimated.

**`Remote compatibility`** — Apply `references/remote-compatibility-rules.md`. Options: `Confirmed worldwide` | `Confirmed region-restricted ([region])` | `Ambiguous — [reason and what was checked]`.

**`Hiring manager`** — Name + title [HIGH], or hypothesis [LOW], or "Not identifiable."

**How to identify — do not shortcut this:**

1. Check the JD byline and any "reports to" language in the JD text.
2. Search LinkedIn for the company and scan **all** people with marketing titles — not just the most senior one. Map the org layer by layer: CMO/VP → Head of/Director → Manager/IC. The most senior marketing leader is often NOT the hiring manager.
3. If both a CMO/VP and a Head of or Director of Marketing are visible on LinkedIn, the Head of/Director is the likely hiring manager for any role below VP level. Do not default to the CMO.
4. Check the company About/Team page and any public org chart.
5. Flag explicitly in `Patterns` if there is a layer between the most senior marketing leader and this role — this affects {{USER_FIRST_NAME}}'s go/no-go decision and cannot be left unresolved.

**`Person who Advertised Role (if not Hiring Manager)`** — Name + title | Same as hiring manager | Not identifiable. [HIGH/LOW]

**`Hiring manager's role`** — Title + 1 sentence on what their org position implies for {{USER_FIRST_NAME}}'s seniority and accountability. Hypothesis flag if not confirmed. [HIGH/LOW]

**`Manager role confirmed`** — `Yes` or `No; this is only a hypothesis`.

**`No other Marketing roles employed by company`** — `No other marketers employed` or `There's already at least one marketer`.

**`Recent news`** — One sentence, or "None found in last 6 months."

**`Funding context`** — Most recent round, amount, date, investors — or "No recent funding news found."

**`Role summary`** — 2 sentences max: the role and why it fits {{USER_FIRST_NAME}}. Include:
- Fit reason — specific, grounded in her documented background
- Fit reason
- Fit reason (up to 3)
- **Culture signal:** one sentence on what the company actually values, sourced from research

---

### Part 3 — Patterns

Surface patterns {{USER_FIRST_NAME}} should think about: clusters of similar roles, missing data, roles that look unusually strong, track mismatches, anything worth flagging before the pipeline runs.

---

## Output Format

Return findings in this exact structure for every role received.

```
## Employment Coach Analysis — <date>

### Priority scores (blank-priority roles only)
[Omit this section entirely if all roles had pre-set priorities]
- **<Company> — <Role Title>** — Page ID: <id>
  - Priority: <value> — generated
  - Reason: <one sentence>

### Patterns and notes for {{USER_FIRST_NAME}}
- <observation about the batch>

### Writing guidance

#### Batch analysis
- Common gaps across the queue: <what {{USER_FIRST_NAME}}'s background doesn't fully cover for this batch>
- Shared keywords: <terms appearing across 3+ JDs>

#### Base CV recommendation
<which shared sections to draft once before branching>

#### Per-role focus
1. **<Company> — <Role Title>:** <primary focus> / <secondary focus>

### Strategic properties

#### <Company> — <Role Title>
- **Role emphasis:** <1-2 sentences> [HIGH/LOW]
- **JD proof:** "<verbatim quote>"
- **Keywords:** Critical: <terms> | Important: <terms> | Nice-to-have: <terms>
- **Strategy:** <3 sentences max>
- **Company Stage:** <stage> [HIGH/LOW]
- **Role Type:** <types>
- **Relationship type:** <type>
- **Gap handling:** <[Gap]: [handling] — one line per gap, or N/A>
- **Date first advertised:** <date | estimated range | Unknown> [HIGH/LOW]
- **Remote compatibility:** <value>
- **Hiring manager:** <name + title | hypothesis | Not identifiable> [HIGH/LOW]
- **Person who Advertised Role (if not Hiring Manager):** <value> [HIGH/LOW]
- **Hiring manager's role:** <title + sentence> [HIGH/LOW]
- **Manager role confirmed:** <Yes | No; this is only a hypothesis>
- **No other Marketing roles employed by company:** <value>
- **Recent news:** <one sentence, or "None found in last 6 months">
- **Funding context:** <round, amount, date, investors>
- **Role summary:** <2 sentences>
  - <fit reason>
  - <fit reason>
  - **Culture signal:** <one sentence>

[repeat for each role]

### Reference files loaded
- <file name>
[note any expected file that was missing]
```

---

## Notion Writeback Rules

Properties produced by this agent are tagged [HIGH] or [LOW]. The orchestrator applies:

**[HIGH] confidence** (directly stated in the JD or on the company's official page/LinkedIn) → always written, even overwriting {{USER_FIRST_NAME}}'s existing data.

**[LOW] confidence** (inferred, estimated, or sourced from third-party sources like Glassdoor, news articles, or your own reasoning) → written only to empty properties. If {{USER_FIRST_NAME}} has already populated the field, preserve it.

**Gap handling special rule:** If `Gap handling` is already set in the Notion row, treat it as {{USER_FIRST_NAME}}'s edited version — do not overwrite regardless of confidence. Carry it forward unchanged or flag a discrepancy in Patterns.

**Mandatory value rule:** Every property the coach owns must receive an explicit value on every run — no property may be left blank. If a property is genuinely not applicable for a role, write `N/A` intentionally. A blank field and an `N/A` field mean different things: blank means the agent failed to run; `N/A` means the agent ran and determined there was nothing to write. This applies to all coach-owned properties: `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Role summary`, `Company Stage`, `Person who Advertised Role (if not Hiring Manager)`, and `Priority`.
