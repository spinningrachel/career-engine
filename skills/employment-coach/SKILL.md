---
name: employment-coach
description: Analysis procedures for the employment-coach agent (Option 2 — Pipeline). Contains the research phase, post-research self-check, priority scoring, writing guidance, strategic property definitions, gap handling rules, output format template, and Notion writeback rules. Load this after pre-flight JD acquisition is complete.
---

# Employment Coach — Analysis Procedures

---

**─── FRAMEWORK PRIMACY — GOVERNS EVERY ANALYSIS ───**

**`03-framework.md` is the primary source of truth about who {{USER_FIRST_NAME}} is, how she works, and what she is positioning toward.** Form your understanding of her from the framework first. A single JD, a single application, or any one run's signals are situational context — they never redefine her goals, identity, or positioning.

**Career-shift posture.** Whether a role represents a career shift is judged against the framework, not against the role. Check `03-framework.md` §Career-shift posture for her stated posture (Not open / Open — case-by-case / Primarily pursuing a shift), her shift directions of interest, and anything off-limits:

- **Not open:** the named pipeline command still rules (R-24) — a commanded shift role is processed in full, but flag the posture mismatch as a one-line note in the briefing, and never emphasize the shift in strategy or materials. Off-limits directions are flagged the same way.
- **Open — case-by-case, or no posture stated (the default):** give a shift role full, normal application support — research, strategy, properties, emphasis — exactly as for any other role. Do not put additional emphasis on the shift itself, do not reposition her around it, and do not frame the application as a transition story unless she wrote that framing in Why I Want This Role. Her listed shift directions and conditions inform fit assessment and priority scoring, not repositioning.
- **Primarily pursuing a shift:** treat shift roles as central — strategy, Role emphasis, and Gap handling may lean into the transition deliberately.

This rule binds every pipeline that spawns the coach: intake, new application, and edit.

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
Exactly 5 competitors:
- **Prioritize {{USER_COUNTRY}}-present competitors first.** Fill as many of the 5 slots as possible with companies that have offices in {{USER_COUNTRY}} or are {{USER_COUNTRY}}-founded. Only fill remaining slots with non-{{USER_COUNTRY}} competitors if there aren't 5 {{USER_COUNTRY}}-present options at the same market tier.
- Match the hiring company's actual market tier. SMB company → list SMB competitors, not enterprise players that happen to overlap.
- Real, known brands only. No obscure or invented names.
- For each: name, one-line description, {{USER_COUNTRY}} office (Yes / No).

**5. What this role actually means in context**
IC vs. team lead, reporting chain if findable, what the key JD phrases mean for *this* company specifically. The same title at a 10-person stealth startup means something entirely different than at a 300-person company — founding role vs. inheriting a team and process. Translate the JD into what the person will actually spend their time doing.

**6. Fit/gap for {{USER_FIRST_NAME}}**
Draw ONLY from `02-professional-background.md` (Role Facts) and `03-framework.md` §Domain depth (per-vertical narratives). These are the only authoritative sources. Do not infer, extrapolate, or invent.

- **Strongest credential:** The single most relevant, specific thing {{USER_FIRST_NAME}} has done that maps to what this role needs. Must name a real company from Section 7 and a documented outcome. If you cannot find a direct credential in Section 7 or `03-framework.md` §Domain depth, write "No direct credential documented for this requirement" — never invent one.
- **Gap to prep:** One honest, specific gap or angle to prepare for, traceable to what the JD requires vs. what is documented. If there is a hard disqualifier (e.g., US residency required, domain not documented in `03-framework.md` §Domain depth), flag it clearly.

**Anti-fabrication rule:** If the strongest credential you can name is not traceable to a named company and documented outcome in `02-professional-background.md` (Role Facts), do not write it. This rule is absolute.

**7. Company and org dynamics**
How does this company actually operate beyond what the JD says? **Start with the LinkedIn company profile** — `get_company_profile(company_name, sections="posts,jobs")` if the LinkedIn MCP is connected; otherwise start with the About Us / Team page on the company website (this is mandatory, not a fallback). It frequently names marketing leaders, describes the team structure, and contains culture signals not found in the JD. Then check: founder/leadership LinkedIn tone, company blog, Glassdoor reviews, team size signals. What do they promote vs. what they claim? 2–3 specific, sourced observations — not JD paraphrase. This feeds the strategy's cultural framing and the Landscape.

**8. Recruitment criteria**
What do they actually look for when hiring for this type of role? Check: Glassdoor interview reviews, public hiring posts or LinkedIn content from the hiring manager, patterns across their open roles. Aim for 2–3 specific criteria beyond what the JD states explicitly.

**9. Career path**
Where does this role typically go? LinkedIn alumni search for this company if possible. For the sector broadly: what's the standard trajectory from this role type and seniority? One or two sentences.

**10. Hiring manager and team research (LinkedIn MCP)**

Only run this step if the LinkedIn MCP is connected. If it is not, skip and note: "LinkedIn MCP not connected — HM research skipped."

1. Identify the hiring manager: check the JD for a named contact, the company's LinkedIn Jobs page via `get_company_profile(company_name, sections="jobs")`, or the company About/Team page.
2. If a hiring manager is found, run `get_person_profile(linkedin_username, sections="experience,education,posts")`. Extract: current title, tenure at this company, background before this company, any recent posts about hiring priorities or team direction.
3. Run `get_company_employees(company_name, keywords="[relevant function keyword for the role]")`. Skim demographics — team size, seniority distribution, recent hires.
4. Produce a 3–5 line Hiring Manager and Team snapshot. Include: HM background relevance, tenure signal (new HM = flux; long-tenure = established culture), any public statements about what they value, team composition signal.
5. This snapshot feeds directly into the Strategy output and the `Strategy` Notion property.

---

### JD Signal Analysis (Red and Green Flags)

After completing all research dimensions, analyse the JD text itself for non-obvious signals. This is separate from fit/gap analysis — it assesses the quality and health of the opportunity itself.

**Red flag patterns (language signals):**
- "Wear many hats", "rockstar", "ninja", "self-starter in a fast-paced environment", "work hard play hard" — indicators of unclear scope or burn-out culture
- "Results-driven" with no metrics anywhere in the JD — performance expectations undefined
- Constant hiring for the same role type — check if the same role appeared multiple times in 12 months on LinkedIn; if so, flag it
- No salary range — negotiating leverage gap
- Vague responsibilities with over-complicated requirements — misaligned expectation vs. actual budget
- "Family-like atmosphere" — culture warning label

**Green flag patterns:**
- Essential vs. preferred requirements clearly distinguished
- Specific measurable goals in the JD ("build X, achieve Y in first 90 days")
- Transparent hiring process described (number of stages, timeline)
- Long-tenured employees visible on LinkedIn
- Hiring manager has been in role 2+ years (stability signal)
- Company blog or HM posts show substantive thinking about the domain

**Output:** Include a "Signals" block in the research output:

```
**Signals:**
- Red: [list any, or "None identified"]
- Green: [list any, or "None identified"]
- Net: [Proceed with caution | Neutral | Positive signals]
```

This feeds into Priority scoring and the Strategy Notion property.

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
Did you scan LinkedIn for ALL {{USER_PROFESSION}} team members at this company, not just the most senior person? If there is any {{USER_PROFESSION}} leader between the top title and this role, it must be named in `Hiring Manager's Name` and flagged in `Patterns`. Leaving this unresolved costs {{USER_FIRST_NAME}} time she cannot get back.

```
### Research confidence check — <Company> — <Role Title>
- Not found: <list, or "nothing material missing">
- Thin evidence downgraded to [LOW]: <list, or "none">
- Inference without named source: <list, or "none">
- Red flags: <list, or "none surfaced">
- Org depth: <"Scanned all {{USER_PROFESSION}} titles on LinkedIn — [finding]" or "Could not access LinkedIn profiles for this company">
```

---

## Analysis

### Settings pre-flight

Before any analysis, determine the gap handling mode in this order:

1. **Spawn prompt** — when invoked by a pipeline, the orchestrating skill passes `gap_handling_mode` in your prompt. Use it; skip the rest of this pre-flight.
2. **Plugin preferences file** — otherwise, Read `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json` (Read tool — you do not have Bash) and use its `gap_handling` value.
3. **Default** — if the file or key is missing, use `enabled`.

- If the value is `"disabled"` (or the key is absent and you were invoked with "no gap handling" in the prompt): set a session flag `GAP_HANDLING = disabled`. Skip all gap analysis in Part 2 and do NOT populate the `Gap handling` property at all — do not write `N/A` (this matches intake Step −1: the property stays empty when gap handling is disabled).
- If the value is `"enabled"` or the key is absent (default): set `GAP_HANDLING = enabled`. Proceed normally.
- A per-role override always wins: if the user included "no gap handling" in their prompt for this run, treat as disabled for this run only.

### Part 0 — Priority scoring (all roles)

Score every role in the queue using the Priority Framework in `01-writing-rules.md` Section 1. There is no longer a distinction between pre-scored and unscored roles — the coach always produces a priority for every role it processes.

**Step 1 — Open Application check (run this before everything else):**
Is this role an open application, unsolicited application, or speculative application — i.e., {{USER_FIRST_NAME}} is applying without a specific open listing? If yes: the priority is `Fifth`. Stop. Do not apply domain fit or any other criterion. Write `Fifth` and the reason: "Open application — hard floor override." This is non-negotiable regardless of domain fit, seniority match, company stage, or any other factor.

**Step 2 — Standard scoring (only if Step 1 did not apply):**
1. Apply the Priority Framework criteria in order.
2. Write a one-sentence reason grounded in {{USER_FIRST_NAME}}'s documented background and the JD.
3. Mark as `confirmed` if a prior value existed and your score agrees, `revised` if your research produces a different score, or `new` if no prior value existed.

Also factor in advertised date: a very recent role with strong fit may be more urgent than an older one with similar fit, but stronger fit generally outweighs recency.

---

### Part 1 — Writing guidance

**Batch analysis:** 1 sentence on common gaps, 1 sentence on shared keywords. No more.

**Base CV recommendation:** If 3+ roles share the same Role Type or seniority level, name the sections to draft once. 1 sentence.

**Structural framing:** Name any framing trigger from `01-writing-rules.md` Section 1 that applies to this batch. 1 sentence.

**Per-role focus:** One line per role — primary emphasis only.

---

### Part 1b — JD decoding

Before setting any strategic property, decode the job posting. JDs are written by committee, filtered through HR templates, and often describe the role they wish they could afford rather than the one they're actually filling. Your job is to read past the surface layer.

**Break the JD into layers and read each deliberately:**

**Layer 1 — Core responsibilities (what you will actually do)**
Tasks at the top or repeated frequently are the real priorities. Map the day-in-the-life against {{USER_FIRST_NAME}}'s documented experience. Ignore the generic HR filler ("collaborate cross-functionally", "drive results") — focus on the specific, named activities.

**Layer 2 — Qualifications (must-haves vs. nice-to-haves)**
"Must / required / expect" = hard requirements. "Ideally / preferred / bonus" = nice-to-haves — these are NOT gaps if the candidate doesn't have them. A "preferred" degree signals openness to equivalent experience. Vague soft skills (e.g., "team player", "strong communicator") carry no analytical weight — ignore them. Hard skills, named tools, specific domain experience: these matter.

**Layer 3 — Outcomes (what success looks like)**
Why does this role exist? What breaks if it goes unfilled? What does the hire need to accomplish in the first 6–12 months? Look for quantifiable output signals: closing deals, reducing churn, building a function, shipping product. This frames the strategy and role emphasis.

**Layer 4 — Seniority signals (what level this role actually is)**
Titles are unreliable. Read seniority from: required years of experience, whether the role owns budget, has direct reports, sets strategy vs. executes it, reports to C-suite vs. middle management. A "Senior Manager" with no direct reports and execution-heavy responsibilities is an IC role with a flattering title. A "Specialist" who owns P&L and presents to board is a leadership role. Identify the real level — it governs how the CV and letter are framed.

**Step-down identification — critical:** If the role's actual level is materially below {{USER_FIRST_NAME}}'s documented seniority (e.g., an IC execution role when she has been a VP, or a manager role when she has led functions), flag it explicitly in Role emphasis as: `Step-down: [reason — e.g., execution IC role vs. her VP-level background]`. This signals to the cv-writer to lead with execution and suppress strategy/leadership framing. Do not obscure or soften this — naming it is how the CV gets written correctly.

**Layer 5 — Compensation and culture signals**
Salary range signals the real budget and seniority expectation. Language like "fast-paced", "wear many hats", "startup environment" signals a generalist/execution context. "Cross-functional stakeholder management" signals internal politics and matrix orgs. These inform Strategy and framing.

**Layer 6 — Nice-to-haves and advantages are exactly that**
If {{USER_FIRST_NAME}} has a "nice-to-have" or "advantage" qualification: call it out in JD proof — it is a differentiator. If she doesn't have it: it is NOT a gap. Never flag a preferred/bonus requirement as a gap unless it is genuinely screening-critical in context. Write `satisfied via [Y] — [X] is additive` or simply omit it from Gap handling.

**Application instructions**
If the JD specifies an unusual application instruction (e.g., "include a cover letter with your answer to X"), flag it in Patterns so {{USER_FIRST_NAME}} sees it before applying.

---

### Part 2 — Strategic properties

These properties are owned exclusively by the employment-coach. Set them based on your expert reading of the JD and {{USER_FIRST_NAME}}'s documented fit — not on what the CV says, which comes later.

**Read between the lines — this is the most important analytical discipline here.** JDs are written by committee and filtered through HR templates. What the JD says explicitly is the floor, not the ceiling. For `Strategy` and `Role emphasis` in particular:

- What problem is the company actually trying to solve by hiring for this role? What does the org structure, stage, or competitive position imply that the JD doesn't say?
- What kind of person succeeds here vs. fails? What does the "preferred" list reveal about who they've tried before?
- What is the subtext of the must-haves? "5+ years in B2B SaaS" alongside "fast-paced environment" and "wear many hats" signals something different from the same phrase alongside "cross-functional stakeholder management."
- If the Landscape property is already populated for this role — **read it carefully before writing Strategy and Role emphasis.** The company's market position, competitive pressures, and known challenges should shape the strategy. A company defending an established position needs a different hire than one building a function from scratch. Let the intelligence inform the framing.

Surface this reading in Strategy and Role emphasis. Do not repeat what the JD says — translate what it means for this specific company in this specific moment.

**Required — must be populated for every role that passes the pre-flight check:**
`Role emphasis` · `JD proof` · `Keywords` · `Strategy` · `Role Type` · `Relationship type` · `Gap handling` · `Landscape`

All eight fields are non-negotiable when gap handling is enabled (seven when disabled — `Gap handling` drops out entirely). The cv-writer and letter-writer cannot run without them. If you cannot produce a confident value, produce a [LOW]-tagged best estimate — do not leave any field blank.

If `GAP_HANDLING = disabled` (set in the Settings pre-flight), leave `Gap handling` unpopulated and skip all gap analysis — do not write `N/A` (see Settings pre-flight and intake Step −1). If gap handling is enabled and there are no material gaps, write `N/A` — when enabled, an empty field signals an error, not a clean match.

---

**`Role emphasis`** — 1–2 sentences on the real mandate beneath the job title. What does success in this role actually look like, beyond what the title says?

For Specialist / practitioner roles (IC contributor, no direct reports), explicitly state all three:
- **Reporting line:** Who does this role report to?
- **Team context:** Founding role (build from scratch) or joining an established team?
- **IC ownership scope:** What does this person own vs. oversee vs. collaborate on?

---

**`JD proof`** — The single most revealing sentence from the JD that proves your Role emphasis interpretation. Direct quote, verbatim. For {{USER_FIRST_NAME}}'s reference only — no writing agent reads this field.

---

**`Keywords`** — 6–10 exact terms pulled verbatim from or directly derivable from the JD text. Divided into three tiers. Aim for 2–4 terms per tier — no padding.

Format: `Critical: [terms] | Important: [terms] | Nice-to-have: [terms]`

- **Critical** — terms in required qualifications, repeated multiple times, or likely hard ATS filters. cv-writer must include ≥80% of this group.
- **Important** — terms in preferred qualifications or appearing 1–2 times. cv-writer should include ≥60% of this group.
- **Nice-to-have** — terms appearing once, implied by domain context, or adjacencies. Best effort; absence is advisory only, not a revision trigger.

Keywords are for CV text only — they do not set the agenda for the cover letter.

---

**`Strategy`** — Exactly 3 labeled HM priorities. No summary direction. No sentences. Each priority is one tight line naming what the hiring manager is actually screening for — read between the lines to find it.

Format:
```
Priority 1: [what the HM is actually hiring for — direct, specific, no AI slop]
Priority 2: [second screening criterion]
Priority 3: [third screening criterion]
```

Each priority is a noun phrase, not a sentence. Name the capability or signal precisely. "PLG execution credibility — activation frameworks, PQL design, in-product lifecycle" is correct. "Someone who can drive growth through product-led strategies" is not.

No {{USER_FIRST_NAME}} references, no credential names, no company names from her background. The cv-writer and letter-writer read her background separately — Strategy tells them what the HM is screening for, not what to write. These three priorities ARE the summary direction: the cv-writer leads with the strongest match to Priority 1, anchors the middle on Priority 2, and closes on Priority 3.

**Strategic framing — GTM lens:**

The best strategies treat the application as a go-to-market problem: {{USER_FIRST_NAME}} is the product, the hiring manager is the buyer, the JD is the RFP. Frame the strategy around three questions:

1. **Why you** — what unique proof makes {{USER_FIRST_NAME}} the credible choice? Not a list of skills — a specific, traceable result.
2. **Why them** — what specifically about this company, this stage, this team makes this the right move? Business logic, not flattery.
3. **Why now** — what makes this the right moment for both parties?

These questions anchor the opening of the cover letter and the interview narrative. The cv-writer and letter-writer should receive the answers as strategic inputs, not generic positioning.

**Weighted prioritization model:**

When scoring priority across multiple roles, weight: Company culture and stage fit (40%) + {{USER_FIRST_NAME}}'s documented credential match (40%) + role level and growth trajectory (20%). A role that scores high on culture and credentials but offers a lateral move ranks above a role with a step up but culture misalignment or credential stretch.

---

**`Company Stage`** — One of: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`. Use funding research as the primary source. Omit rather than guess if genuinely unknown.

---

**`Role Type`** — Multi-select. Choose all that apply: `Builder`, `Scaler`, `Specialist`, `Leader`. See career-engine-orchestrator for definitions.

---

**`Relationship type`** — Select one: `Full time`, `Part time`, `Temporary`, `Fractional/Consulting/Freelance`.

---

**`Gap handling`** — One line per genuine, material gap. Maximum 3 gaps — prioritize the most screening-critical. For each gap: state what it is and the recommended handling.

Format: `[Gap]: [handling]`

Handling options:
- `surface [X] instead` — a documented experience addresses the gap if reframed; name what to surface
- `letter addresses via [angle]` — the CV cannot carry this, but the cover letter can address it with context or framing; name the angle
- `ignore — not a screening risk` — the gap exists but won't cost {{USER_FIRST_NAME}} a first call
- `satisfied via [Y] — [X] is additive` — for preferred requirements where she satisfies one alternative

**What are NOT gaps:** Adjacent experience, transferable skills, and credible adjacent verticals are not gaps — they are the story. Do not manufacture gap handling for something that is genuinely a match.

**Never flag "works independently" as a gap or callout.** The ability to work autonomously is implied for any experienced professional and is embarrassing to name explicitly. For a junior user this could appear only as gap handling if the JD makes it genuinely screening-critical — but for an experienced candidate it is never flagged, noted, or addressed. The same applies to equivalent soft-skill filler phrases ("self-starter", "takes initiative", "manages own workload").

**"Preferred" requirements with alternatives.** When a JD says "X or Y experience preferred" and {{USER_FIRST_NAME}} satisfies at least one alternative, she satisfies the requirement. The unsatisfied alternative is additive, not a gap. Write `satisfied via [Y] — [X] is additive`, or omit it.

**AI product specificity.** "AI" is not a single category. Computer vision, conversational AI / NLP, LLMs, recommendation systems, and cybersecurity AI are distinct GTM contexts with different buyers, trust models, and proof requirements. When the role is at an AI company, identify the specific AI product category the company builds, then check whether {{USER_FIRST_NAME}}'s documented AI experience maps to that category.

Check `02-professional-background.md` (Role Facts) to determine which AI product categories {{USER_FIRST_NAME}}'s documented experience maps to. Use only what is documented there.

If the specific AI category (e.g., conversational AI, NLP, voice agents) is not documented in {{USER_FIRST_NAME}}'s background, name it as a product-category gap separately from any domain/vertical gap.

**Domain gap vs. product-category gap are distinct.** A company can require both domain experience (e.g., healthcare) and product-category experience (e.g., conversational AI). Flag each separately. Do not collapse them.

**If no material gaps exist:** write `N/A`.

---

**`Date first advertised`** — When was this role first posted? Check: LinkedIn "posted X days ago" (calculate the actual date), job board timestamps, URL date parameters. If the role has been open >60 days, flag it prominently. [HIGH] if confirmed from a primary source; [LOW] if estimated.

**`Remote compatibility`** — Apply the Remote Compatibility section from `references/job-preferences.md`. Options: `Confirmed worldwide` | `Confirmed region-restricted ([region])` | `Ambiguous — [reason and what was checked]`.

**`Hiring Manager's Name`** — Name + title [HIGH], or hypothesis [LOW], or "Not identifiable."

**How to identify — do not shortcut this. Work through every step before marking "Not identifiable."**

1. **Read the JD text.** Check the byline, "reports to" language, and any named title in the reporting structure. If the JD names a reporting title (e.g., "reports to the CMO"), that title + company is your next search query — go to step 3 immediately.
2. **Read the company About Us / Team page.** This is mandatory — not optional. Marketing leaders, team structure, and culture signals are frequently listed there. Open the page and read it. Note any {{USER_PROFESSION}} function leaders by name and title.
3. **Google `"[title]" [company name]`** — e.g., `"CMO" Northwind` or `"VP Marketing" Acme Corp`. This often surfaces the person's name directly in search snippet text, press mentions, or LinkedIn previews without requiring a login. Read the first page of results.
4. **Search LinkedIn for the company** and scan **all** people with {{USER_PROFESSION}} titles — not just the most senior one. Map the org layer by layer using {{USER_FUNCTION_SENIORITY_HIERARCHY}} as the reference for title tiers. The most senior {{USER_PROFESSION}} leader is often NOT the hiring manager.
5. **Check B2B intelligence platforms.** Search theorg.com, Crunchbase, and ZoomInfo for the company — these often list org structure, named leaders, and reporting chains without requiring sign-in. A Google search for `[company name] theorg` or `[company name] site:theorg.com` is a fast entry point.
6. **Apply org-layer logic.** If both a top-tier and a mid-tier {{USER_PROFESSION}} leader are visible (per {{USER_FUNCTION_SENIORITY_HIERARCHY}}), the mid-tier leader is the likely hiring manager for any role below the top tier. Do not default to the most senior title.
7. **If a name is found, check their digital footprint.** Review their LinkedIn posts, company blog articles, X/Twitter if public, and any published interviews — this surfaces culture signals, priorities, and framing that feeds `Strategy`.
8. Flag explicitly in `Patterns` if there is a layer between the most senior {{USER_PROFESSION}} leader and this role — this affects {{USER_FIRST_NAME}}'s go/no-go decision and cannot be left unresolved.

**`Person who Advertised Role (if not Hiring Manager)`** — Name + title | Same as hiring manager | Not identifiable. [HIGH/LOW]

**How to identify:** Check the JD posting on the source job board for a poster name or recruiter byline. Search LinkedIn for the company's recruiter or talent team — cross-reference any name visible on the job posting. Review the poster's profile for context on who is screening (internal recruiter, external agency, or hiring manager posting directly).

**`Hiring manager's role`** — Title + 1 sentence on what their org position implies for {{USER_FIRST_NAME}}'s seniority and accountability. Hypothesis flag if not confirmed. [HIGH/LOW]

**`Manager role confirmed`** — `Yes` or `No; this is only a hypothesis`.

**`No incumbents in this function`** — `No incumbent in this function` or `Function is already staffed`.

**`Recent news`** — One sentence, or "None found in last 6 months."

**`Funding context`** — Most recent round, amount, date, investors — or "No recent funding news found."

**`Role summary`** — A compressed summary of the JD itself. Not about {{USER_FIRST_NAME}}. This property serves as the JD proxy for all downstream agents — they read this instead of the full JD body.

**Hard limit: 400 characters total including spaces.** Count before writing. This is a Notion property field, not a document — it must be short enough to be read at a glance. If you need to choose between coverage and brevity: cut coverage, keep brevity.

Write from the JD body only. Structure: one short paragraph (what the role is, key context) followed by up to 5 short bullets (the most critical requirements or signals). Only the most important aspects of the role — everything else is noise.

Rules:
- Use the JD's own vocabulary where possible
- Simple, clear, concise language — no verbosity, no repetition
- Never reference {{USER_FIRST_NAME}}, candidate fit, or anything not in the JD
- Never include contact information or location
- If the JD is empty of content: write exactly `No content`
- If the JD contains a self-characterization section ("you'll thrive here if", "good fit / not a good fit") — include it as the final bullet, labeled `Self-characterization:` followed by the verbatim text (within the 400-char total)

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
- **Strategy:** Priority 1: <...> | Priority 2: <...> | Priority 3: <...>
- **Company Stage:** <stage> [HIGH/LOW]
- **Role Type:** <types>
- **Relationship type:** <type>
- **Gap handling:** <[Gap]: [handling] — one line per gap, or N/A>
- **Date first advertised:** <date | estimated range | Unknown> [HIGH/LOW]
- **Remote compatibility:** <value>
- **Hiring Manager's Name:** <name + title | hypothesis | Not identifiable> [HIGH/LOW]
- **Person who Advertised Role (if not Hiring Manager):** <value> [HIGH/LOW]
- **Hiring manager's role:** <title + sentence> [HIGH/LOW]
- **Manager role confirmed:** <Yes | No; this is only a hypothesis>
- **No incumbents in this function:** <value>
- **Recent news:** <one sentence, or "None found in last 6 months">
- **Funding context:** <round, amount, date, investors>
- **Landscape:** (write only if currently empty in Notion)
  - **What the company actually does today:** <1 sentence — product, not positioning>
  - **Corporate structure:** <independent / PE-backed / acquired / public; parent company if applicable>
  - **Company size:** <headcount or range>
  - **Funding:** <most recent round, amount, date, lead investors — single line>
  - **Category:** <the market category this company operates in — 1–3 words>
  - **Current known challenges:** <1 specific, sourced challenge>
  - **Market position:** <enterprise / mid-market / SMB; primary buyer>
  - **Sector and market signals:** <1–2 sentences — relevant tailwinds, headwinds, or sector dynamics that affect this company's trajectory right now>
  - **Competitive landscape:** <exactly 5 real, known competitors at the same market tier; name + one-line description + {{USER_COUNTRY}} office Yes/No each>
- **Role summary:** ≤400 chars total. Short paragraph + up to 5 bullets. JD vocabulary only. No candidate references. No location/contact info. Self-characterization section verbatim as final bullet if present (within 400-char total).

[repeat for each role]

### Reference files loaded
- <file name>
[note any expected file that was missing]
```

---

## Notion Writeback Rules

**Write only to empty properties.** For every coach-owned property, check the current Notion value before writing. If a value already exists — regardless of what the coach produced — skip it. Do not overwrite.

This applies to all coach-owned properties without exception: `Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Gap handling`, `Role summary`, `Company Stage`, `Person who Advertised Role (if not Hiring Manager)`, `Priority`, `Landscape`, and all research-derived properties (`Hiring Manager's Name`, `Recent news`, `Funding context`, etc.).

**`Priority` exception:** If the coach's analysis produces a materially different priority than what is set (e.g., role is identifiable as an open application that must be `Fifth`, or research reveals a hard disqualifier that changes the score), flag the discrepancy in Patterns and note the recommended value — but still do not overwrite. {{USER_FIRST_NAME}} decides.

**`N/A` counts as a value.** Do not overwrite `N/A` with new content. A field set to `N/A` was deliberately set that way.

**If a property is empty:** write the coach's output. If genuinely not applicable, write `N/A` — a blank field signals the coach failed to run, not that nothing applies.
