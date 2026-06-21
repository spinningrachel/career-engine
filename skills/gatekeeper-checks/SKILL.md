---
name: gatekeeper-checks
description: 'Check definitions for the gatekeeper agent. Three options: Option 1 CV content checks, Option 2 cover letter checks, Option 3 coach output fact check. Load this skill before running any gatekeeper option.'
---

# Gatekeeper Check Definitions

---

## Option 1 — CV Content Checks

Run the ATS pre-check first, then the content checks in order.

### ATS Pre-Check

ATS failures mean the document may never reach a human reader regardless of quality.

**Keyword coverage:** Parse the Keywords property into three tiers (`Critical: ... | Important: ... | Nice-to-have: ...`). Search for each term (case-insensitive) in the full CV body — summary, experience bullets, and skills section.

| Tier | Requirement | Action if below threshold |
|---|---|---|
| **Critical** | ≥80% must appear | FAIL — list the missing terms by name |
| **Important** | ≥60% must appear | FAIL — list the missing terms by name |
| **Nice-to-have** | No threshold | Advisory only — include in end-of-pipeline feedback note, do not return as a violation |

**Gap handling exception:** If a missing Critical or Important term is explicitly listed as a gap in the role's Gap handling property, do not fail on it — add it to the advisory note instead.

**Standard section headings:** Search the full document text (case-insensitive) for "SUMMARY", "EXPERIENCE", "SKILLS". Quote the line where found, or state explicitly it is absent. Headings may appear anywhere in the document.

| Required | Not acceptable |
|---|---|
| SUMMARY or PROFESSIONAL SUMMARY | Profile, About Me, Introduction |
| EXPERIENCE or WORK EXPERIENCE | Career History, Professional History, Work History |
| SKILLS | Core Competencies only (without SKILLS anywhere) |

FAIL if EXPERIENCE or SUMMARY headings are absent or substantially renamed.

**Macro-injected sections — FAIL if present, never fail on their absence:** `EDUCATION`, `LANGUAGES`, and `ADDITIONAL` are injected automatically by the user's Word template. They must NOT appear in cv-writer's markdown output — they are already formatted in the template and will be duplicated if written here. FAIL immediately if any of `## EDUCATION`, `## LANGUAGES`, or `## ADDITIONAL` appear anywhere in the CV text, with the message: "[SECTION] section must not be written — it is part of the Word template and will duplicate." Never fail on their absence.

**`TOOLS` is optional.** Do not fail if absent. If present, confirm it uses the correct `## TOOLS` heading — no other form is acceptable. FAIL if present but not using `## TOOLS` — flag as: "TOOLS section uses non-standard heading [heading] — rename to `## TOOLS`."

**ATS-hostile formatting:** FAIL if any of these appear in the body:
- Tables in the Experience section
- Columns or side-by-side layouts
- Special character bullet markers (✓, →, ◆, ★, ••)
- Text boxes or sidebars

**BlueFont annotation check — FAIL if triggered:** Scan the full CV markdown for any occurrence of the pattern `[^]]{custom-style="BlueFont"}` — i.e., `{custom-style="BlueFont"}` not immediately preceded by `]`. This indicates an unbracketed span. Pandoc will render the literal annotation string `{custom-style="BlueFont"}` as body text in the DOCX. Flag every unbracketed occurrence as: "Unbracketed BlueFont span: `[text here]` — wrap text in square brackets: `[text here]{custom-style=\"BlueFont\"}`." FAIL if any are found.

---

### Content Checks

**Summary**
- No company, client, or conference names — descriptors only (prohibited list in `01-writing-rules.md` Section 1)
- The summary should open with language most relevant to the hiring manager and the role being applied for. No specific role is required to appear — the summary's job is to lead with the user's strongest, most relevant credentials for this opening. Do not fail on the absence of any particular role, including the most recent one.
- ≤120 words, 1 paragraph, ≤4 sentences
- No tool/platform names, consulting client names, or metrics not documented as summary-appropriate
- None of these phrases: "comfortable operating across", "proven track record", "passionate about", "results-driven", "dynamic", "extensive experience" — **advisory only if found; do not fail or loop**
- **Single-instance trap — FAIL if triggered:** The summary claims a pattern. For every concrete claim or named activity in the summary, count how many times the CV body actually demonstrates it across different roles. If a sentence implies "she repeatedly does X" but the CV shows only one instance of X, that sentence is a bullet wearing a summary's clothes. FAIL with: "Summary sentence '[sentence]' implies a repeated pattern but the CV shows only one instance — move the specific detail to a bullet under [role], replace with the breadth claim." A summary that is dense, em-dash-stuffed, or reads structurally like a bullet point is a signal to check this rule.
- **Absolute-peak numbers in the summary — FAIL if triggered:** A single absolute number for a team size or growth metric (e.g., "a 13-person team", "300% YoY growth") implies that was the sustained state. If the number reflects a peak or a single point in time, it must use range language ("up to 13-person teams", "up to 300% YoY growth"). FAIL with: "Summary uses absolute number '[number]' for a peak value — rewrite as 'up to [number]'."
- **Roster-level detail in the summary — FAIL if triggered:** Listing the specific functions that made up a team or initiative (e.g., "spanning editorial, technical writing, social, product marketing, and field") is bullet-level detail. The summary carries the scope and the unified outcome, not the org chart. FAIL with: "Summary lists specific team functions — abstract to 'multiple competencies' or equivalent scope language; move the roster to a bullet."

**Experience**
- `## EXPERIENCE` contains full-time employment only, in reverse-chronological order by end date
- Any consulting/fractional practice appears in `## CONSULTING`, not `## EXPERIENCE` — flag if found in the Experience section
- Any consulting entry flagged as mandatory in `02-professional-background.md` appears somewhere in the CV — either as a standalone entry in `## CONSULTING` or as a bullet within the main consulting section — FAIL if absent entirely
- The "Earlier:" line appears as the final entry inside `## EXPERIENCE`, before the `## CONSULTING` section header — FAIL if Earlier appears after CONSULTING
- Claims about target market match `02-professional-background.md` (Role Facts)
- No tool or technology name of any kind inside experience bullets — not any tool, not even if named in the JD, not even as an example. Blanket ban. Approved bullets from `02-professional-background.md` are the only exemption.
- Every named role has a RoleOverview immediately below its RoleTitle — count must match (Earlier: exempt)

**Structure**
- No years on the Earlier line (Education/Languages are script-injected — skip them)
- No header or label between the SUMMARY banner and the summary text
- No opening verb appears 3+ times — common offenders: Built, Led, Developed, Created, Managed, Drove, Owned
- No 4+ word verbatim JD phrases in new bullets; standard terms like "go-to-market" are fine; approved bullets from `02-professional-background.md` exempt; quote both phrases when flagging

---

## Option 2 — Cover Letter Checks

**Format**
- Greeting: `Hi to the [Company name] team!` or `Hi to [Name]!` — for stealth roles (no public company name), `Hi to the team!` or `Hi to the [JD descriptor] team!` is accepted
- Role named in the first sentence of the body — it does not have to lead the sentence, but it must be explicit (Tier 2; FAIL if absent)
- Sign-off: "Looking forward to next steps," (default) or an archive-consistent variation, then "{{USER_FULL_NAME}}" on its own line. A P.S. after the name is permitted when archive-consistent (logistics, warmth) — flag only company-positioning commentary in a P.S.
- Body: maximum 320 words (excluding greeting and sign-off; no minimum — canonical rule per the cover-letter skill; the 270–320 band is the typical delivered-letter register)

**Personal-content exemption — read before running any content check**

If the user's Why I Want This Role content was passed alongside the cover letter, that is the user's own first-person material — not letter-writer invention. Do not fail on content checks for passages that clearly originate from her Why I Want This Role field. The signal: personal-content-derived text sounds like a personal reaction or genuine first-person opinion; copywriting-fabricated content sounds assembled and polished. When a specific personal claim about the company or role matches phrasing that could plausibly be the user speaking in her own voice, treat it as personal-content-derived and exempt it from Pattern C, Pattern H, the company character claims check, the analyst-paragraph body check, and the banned words/phrases list. A hedged inference in her words ("I believe X would demand Y") is an earned inference — exempt when named proof sits within two sentences. The exemption does NOT cover: the specificity-slot check (kept at full strength by explicit ruling), the CV-repetition prohibition, or fabricated/unevidenced factual claims. Apply the exemption only to plausibly personal statements — not to agent-constructed analytical claims about the company's strategy, market, or positioning. **Seniority step-down sentences derived from the user's own Why I Want This Role content are also exempt from the gap-volunteering check, provided they use affirmative framing (see above).** The exemption does NOT cover negation-form step-down framing, which fails regardless of source.

**Why I Want This Role point coverage — FAIL if triggered**

If the numbered [WIWTR-N] point list was passed alongside the letter: verify each point is substantively present in the letter text. A point is present if its actual substance (not just its theme) appears somewhere in the letter. Missing points = FAIL. List each missing point by number and quote it. If no [WIWTR-N] list was passed, skip this check and note "WIWTR point list not provided — coverage check skipped."

**CV repetition check — FAIL if triggered**

This check requires the final revised CV to be in scope. If the CV was not passed alongside the cover letter, report 'CV not provided — repetition check skipped' as a named line in your output — never skip silently. The pipelines are required to pass the CV; a missing CV is itself a finding.

Read every substantive claim, metric, credential, and fact in the letter body. For each one, check whether the same information already appears anywhere in the CV — in the summary, in any experience bullet, or in any other section. Flag as: "Letter repeats CV content: '[sentence or phrase]' restates '[location in CV]'." A sentence fails if it makes the same claim in different words — paraphrase is not a loophole. Enhancement is permitted: if the letter sentence contains material the CV bullet does not (context, story, decision logic, or new detail), it passes. Pure restatement fails.

**Content**
- Key proof signals from the most recent role in `02-professional-background.md` are woven naturally into the body (not as a standalone boilerplate sentence)
- No agent-drafted fit claims: "this role has my name on it", "I was made for this role", "I'm the perfect candidate", "perfect fit", "couldn't be a better fit". A fit or confidence claim verbatim from the user's Why I Want This Role (or her own edits) is personal content — exempt under the personal-content exemption; her delivered letters carry "meant for me"-class claims by choice
- No gap volunteering: "Full disclosure:" + scope claims; "whether that's the fit you need"; any sentence pre-empting a concern the hiring manager hasn't raised. **Seniority step-down framing:** negation form ("This isn't a stepping stone for me," "I'm not overqualified") is gap volunteering — FAIL. Affirmative form ("I've been building toward this role," "This is exactly the level I want") is a confidence statement — PASS even without the personal-content exemption.
- No analyst paragraph in the body: any paragraph describing the company's product, positioning, or market back to them; any market observation from outside ("in a crowded X market", "a genuinely differentiated story"); any capability announcement without named proof ("that translation is where I live", "that's the work I do", "that's where I operate"). The user must be the subject of every paragraph, speaking from named experience. FAIL if any paragraph reads as the user analysing the company rather than demonstrating her own work.
- **Specificity slot check — FAIL if triggered:** Scan every body paragraph for abstract quality claims — any word or phrase describing the user's character, capability, or working style (e.g., strategic, proactive, collaborative, creative, fast, effective, detailed, experienced, clear, communicative, quality-focused, supportive, or any comparable quality adjective) that appears without named proof within two sentences. Named proof means: a company name, a number, a specific deliverable, or a named methodology. Flag as: "Body contains '[claim word]' without named proof within two sentences — add a company name, number, or specific deliverable." One flag per violation; check all body paragraphs. Opening and closing prose are exempt — this check applies to proof paragraphs only.
- Closing is a direct ask — banned: "at your earliest convenience", "I hope you will consider", "I would welcome the chance to talk", "I hope to hear from you", "I look forward to the opportunity"
- If JD has a "good fit / you'll thrive here if" section, letter addresses at least one positive signal with named proof
- No claims about the company's character not traceable to the JD (e.g., "one of the few companies that...", "you get it in a way most don't")
- No em dash as list separator (e.g., "— email security, endpoint protection, XDR —")

**Opening paragraph — non-waivable**

This check cannot be waived by any upstream input — not coach output, not Strategy, not Role emphasis, not Gap handling. The first paragraph is always the user's personal reaction to this specific role.

Check for the following failure patterns — any one is a fail:

**Pattern A — Generic opener:** "I am writing to apply for...", "I am excited to apply for...", "I am reaching out regarding...", or any generic enthusiasm statement without specific content.

**Pattern B — Second-person analytical opener:** Opening paragraph dominated by sentences describing the company's product, buyers, or market back to them ("Your buyers are...", "Your product is...", "Your sales motion...", "Building GTM for [X] isn't the same as..."). Consulting-speak; the user is not the subject.

**Pattern C — Company language mirroring:** Opener echoes a JD/website phrase and frames the user's experience as "exactly that problem." Pattern: "[Company phrase] is exactly the problem I spent the last year living." Performs relevance instead of demonstrating it.

**Pattern D — Career summary dump:** Opening paragraph leads with a career achievement list. Pattern: "At [Company] I built [function] from zero to [X people] during [metric]: [list]." This belongs later, not as the opening move.

**Pattern E — Product or category flattery:** Opener compliments the company's **specific** terminology, product framing, or positioning. Pattern: "'[Company term]' is a genuinely smart framing" · "'Security Operations Resilience' is not just a buzzword" · "Calling it [Company name]" is a refreshingly honest take on [market]." Positions the user as an observer validating the company. **Scope clarification:** Pattern E is about company-specific compliments only — not about general market observations. Do NOT apply Pattern E to sentences about the industry broadly; those are Pattern G or Pattern G2.

**Pattern F — Availability statement:** Opener leads with the user's current status. Pattern: "I just wrapped up at [Company]..." as the first move. A recent exit belongs integrated into the letter, not as the opening sentence.

**Pattern G — Generic industry observation:** The opening paragraph's subject is a market category, stage, or type of company rather than the user. Pattern: "B2B tech companies hiring at the growth stage usually need someone who can operate at both ends simultaneously." · "The hardest part of selling security is that every vendor says the same thing."

**Pattern G2 — User-as-subject-but-market-as-claim:** The user IS the grammatical subject of the first sentence, but the sentence immediately pivots to a general claim about "the job," "the market," or "the problem" as if the user is explaining the industry to the reader. Pattern: "I've spent six years in [field], and the job — above everything else — is [general market observation]." [Example from your background] · "I've been doing this long enough to know that the real challenge in [space] is [general observation]." The tell: the clause after "and" or the subordinate clause is a market/industry insight, not a personal reaction to THIS role. The user sounds like she's lecturing about the market rather than saying why she wants this specific job.

**Pattern H — Company-specific hook substituting for a reaction:** Opener quotes the company's tagline, names a prior technical challenge as a credential hook, or names an exact client as domain proof. These feel researched but position the user as doing due diligence rather than reacting to the opportunity. Company-specific knowledge belongs in paragraph 2 as proof.

**Pattern I — Setup opener as first sentence:** The very first sentence of the opening paragraph frames the industry context, role stakes, or market problem before the user appears as a subject reacting to this specific opportunity. Pattern: "The hardest part of [industry] is [challenge]." · "In a market where [condition], what companies like [Company] need is someone who [requirement]." · "Finding the right words for [category] is harder than it looks." Applies even when the setup sentence is short and seems innocuous. The test: does the first sentence make a claim about the market, the role, or the company before the user says what SHE wants or what SHE recognises? If yes, flag Pattern I. **Note:** Pattern I overlaps with Pattern G2 when the user IS the subject — apply both labels.

**Sentence structure violations in the opening paragraph — FAIL**

The gatekeeper MUST flag and FAIL the following structural problems when they appear in the opening paragraph:

- **Gerund as subject:** Opening sentence begins with a gerund phrase ("Finding the right words for...", "Building GTM for...", "Having spent [time]..."). The subject must be the user (first person), not a gerund.
- **Prepositional phrase opener — agent-drafted only:** First sentence begins with a prepositional phrase ("In a market where...", "For companies at this stage...") with no archive precedent. Archive-consistent ramps ("After years in regulated, trust-dependent categories...", "On Fiverr, I write...") are the user's register — pass and note, do not fail.
- **Dependent clause opener — agent-drafted only:** First sentence leads with a subordinate clause framing the market or industry ("When half the vendors say the same thing...", "Because positioning in security is hard...") with no archive precedent. Archive-consistent ramps where the clause carries HER action or reaction ("When I heard that [Company] is hiring...", "When reading the [Company] posting...") are the user's register — pass and note, do not fail.
- **Wh-clause stacking:** Multiple "who/which/that" clauses chained within a single sentence, creating a sentence that sounds assembled rather than said.

These are not advisory. A sentence structure violation in the opening paragraph is a FAIL requiring revision.

**Banned term checking is a literal string search, not a semantic review.** For each banned term: search the letter text for that exact string (or close variants — e.g., "specialism", "Specialism", "SPECIALISM"). Do not rely on memory or a general read-through. Use the Grep tool or scan the letter text character by character for each term. A mental "I reviewed and found nothing" is not a valid completion of this check — the search must be performed for each term individually.

**Banned words and phrases** — advisory only; do not fail or loop

Note any of these in the end-of-pipeline feedback note. Do not return as a violation or trigger a revision.
- "specialism" — not a word; use "multi-disciplinary" or "[specific] disciplines" instead
- "genuinely"
- "actually" or "real" as emphasis intensifiers ("I actually did X", "real results")
- "straightforward"
- "dynamic"
- "extensive experience"
- "proven track record"
- "passionate about"
- "results-driven"
- "at the intersection" or "at an intersection"
- "I have" followed by "on exactly that" in the same sentence
- Any sentence matching "X is [something], not [something]" as a positioning claim
- Any phrase matching "What puts me closest to what [Company/you] is/are doing:" or "What puts me closest to what you need:"
- "I would welcome the chance to"
- "significant part of my career"
- Self-declaration of capability without evidence: "I know how to speak to buyers who [X]", "For a role in [space], that matters:", "where [thing] isn't a nice-to-have, it's [dramatic claim]"

**Banned structures** — advisory only; do not fail or loop

Note any of these in the end-of-pipeline feedback note. Do not return as a violation or trigger a revision.
- "Here's the thing" / "Here's the hard truth"
- "And honestly?" / "Let's be honest"
- "Unlock" / "Unleash" / "Harness"
- "In today's [X] world" / "As we look to the future" / "As we look ahead"
- "Today's landscape" / "navigating the landscape" / "the landscape"
- "Broke the mold"
- "In reality" as a transition
- "Hit home" / "How we show up" / "You're not imagining it"
- Any sentence beginning with "Just" + first-person verb
- Triadic negation: "No X. No Y. Just Z."
- Negation-then-assertion: "Don't just X. [Subject] Y."
- Staccato fragments substituting for full sentences
- "X isn't always about Y" / "X should be Y, not Z"
- Antithesis/pivot formula: "[Subject] does/has X, but [subject] is Y" where X is unnecessary context that adds nothing. Also: "It's not about X, it's about Y." / "This isn't just A, it's B." / "Not X — Y." Test: if removing the negated half makes the sentence clearer, it should be cut.
- Temporal motivation hedges: "the seat I want most right now" / "at this stage of my career" / "what I'm looking for right now" / any phrase implying the motivation is provisional or time-qualified. A genuine reaction to a specific role needs no time qualifier.

---

## Option 3 — Coach Output Fact Check

For each role in the coach's output, identify every specific factual claim about the user's background, experience, skills, or accomplishments. Find the supporting line in `01-writing-rules.md`.

**Verifiable:** directly traceable to a named section, sentence, or bullet in `01-writing-rules.md`.

**Unverifiable:**
- Names a company, client, product, or tool the user worked with that does not appear in the reference file
- Attributes a metric, outcome, or responsibility not found in the reference file
- Describes a skill or domain depth that is not documented

**Do not flag:**
- Claims about the role or company (from the JD, not the user's background)
- Role emphasis sentences describing what the role requires
- Strategy sentences that are framing instructions, not factual claims about the user's past
- Gap handling entries identifying what the user does NOT have (gaps are expected absences, not fabrications)
