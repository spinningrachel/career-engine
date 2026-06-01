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

**Macro-injected sections — never check for these, never fail on their absence:** `EDUCATION`, `LANGUAGES`, and `ADDITIONAL` are injected automatically by {{USER_FIRST_NAME}}'s Word macros after DOCX export. They are intentionally absent from cv-writer's markdown output. Do not search for them, do not flag their absence, do not fail on them.

**`TOOLS` is optional.** Do not fail if absent. If present, confirm it uses the correct `## TOOLS` heading — no other form is acceptable. FAIL if present but not using `## TOOLS` — flag as: "TOOLS section uses non-standard heading [heading] — rename to `## TOOLS`."

**ATS-hostile formatting:** FAIL if any of these appear in the body:
- Tables in the Experience section
- Columns or side-by-side layouts
- Special character bullet markers (✓, →, ◆, ★, ••)
- Text boxes or sidebars

---

### Content Checks

**Summary**
- No company, client, or conference names — descriptors only (prohibited list in `who-rachel-is.md` Section 1)
- The summary should open with language most relevant to the hiring manager and the role being applied for. No specific role is required to appear — the summary's job is to lead with {{USER_FIRST_NAME}}'s strongest, most relevant credentials for this opening. Do not fail on the absence of any particular role, including the most recent one.
- ≤120 words, 1 paragraph, ≤4 sentences
- No tool/platform names, Contentabl client names, or metrics not documented as summary-appropriate
- None of these phrases: "comfortable operating across", "proven track record", "passionate about", "results-driven", "dynamic", "extensive experience" — **advisory only if found; do not fail or loop**

**Experience**
- `## EXPERIENCE` contains full-time employment only, in reverse-chronological order by end date
- Contentabl appears in `## CONSULTING`, not `## EXPERIENCE` — flag if found in the Experience section
- Lightrun appears somewhere in the CV — either as a standalone entry in `## CONSULTING` or as a bullet within Contentabl — FAIL if absent entirely
- Firebolt appears somewhere in the CV — either as a standalone entry in `## CONSULTING` or as a bullet within Contentabl — FAIL if absent entirely
- The "Earlier:" line appears as the final entry inside `## EXPERIENCE`, before the `## CONSULTING` section header — FAIL if Earlier appears after CONSULTING
- Coro target market matches `qa-bank.md` (Role Facts)
- No app/tool names inside bullets: HubSpot, Salesforce, Salesloft, Moosend, Webflow, Mintlify, Chameleon, HeyReach, ZoomInfo, Chorus.ai, Notion, Jira, Slack — approved bullets from `qa-bank.md` are exempt
- Every named role has a RoleOverview immediately below its RoleTitle — count must match (Earlier: exempt)

**Structure**
- No years on the Earlier line (Education/Languages are script-injected — skip them)
- No header or label between the SUMMARY banner and the summary text
- No opening verb appears 3+ times — common offenders: Built, Led, Developed, Created, Managed, Drove, Owned
- No 4+ word verbatim JD phrases in new bullets; standard terms like "go-to-market" are fine; approved bullets from `qa-bank.md` exempt; quote both phrases when flagging

---

## Option 2 — Cover Letter Checks

**Format**
- Greeting: `Hi to the [Company name] team!` or `Hi to [Name]!` — no other form accepted
- Sign-off: "Looking forward to next steps," then "{{USER_FULL_NAME}}" — nothing after the name
- Body: 230–290 words (excluding greeting and sign-off)

**Q&A exemption — read before running any content check**

If {{USER_FIRST_NAME}}'s Q&A answers or page body reactions were passed alongside the cover letter, those are {{USER_FIRST_NAME}}'s own first-person statements — not letter-writer invention. Do not fail on content checks for passages that clearly originate from her Q&A or page body answers. The signal: Q&A-derived content sounds like a personal reaction or genuine first-person opinion; copywriting-fabricated content sounds assembled and polished. When a specific personal claim about the company or role matches phrasing that could plausibly be {{USER_FIRST_NAME}} speaking in her own voice, treat it as Q&A-derived and exempt it from Pattern C, Pattern H, and the company character claims check. Apply the exemption only to plausibly personal statements — not to analytical claims about the company's strategy, market, or positioning.

**`Additional Letter Writer Details` gate — check before all content checks**

The orchestrator should pass whether `Additional Letter Writer Details` is populated or empty. Apply this rule:

- **If populated:** Company positioning references that match what {{USER_FIRST_NAME}} specified in that field are permitted — do not fail on them.
- **If empty or not passed:** FAIL if the letter contains any of the following — any sentence analysing, describing, commenting on, or referencing the hiring company's positioning, messaging, or how they frame their product in the market. This includes: direct positioning observations ("your framing of X as Y is interesting"), indirect references that imply positioning awareness ("a company that understands the X problem"), and any sentence where {{USER_FIRST_NAME}} positions herself as having studied their market strategy. The "no analyst paragraph" check below is the specific violation to flag.

**Content**
- VL EXIT signal woven into the body (not a standalone boilerplate sentence): "Visual Layer", "ARR from $1M to $3M", "acquisition", "Camtek", "$7M"
- No fit claims: "this role has my name on it", "I was made for this role", "I'm the perfect candidate", "perfect fit", "couldn't be a better fit"
- No gap volunteering: "Full disclosure:" + scope claims; "whether that's the fit you need"; any sentence pre-empting a concern the hiring manager hasn't raised
- No analyst paragraph in the body: any paragraph describing the company's product, positioning, or market back to them; any market observation from outside ("in a crowded X market", "a genuinely differentiated story"); any capability announcement without named proof ("that translation is where I live", "that's the work I do", "that's where I operate"). {{USER_FIRST_NAME}} must be the subject of every paragraph, speaking from named experience. FAIL if any paragraph reads as {{USER_FIRST_NAME}} analysing the company rather than demonstrating her own work. **This check is always active, regardless of `Additional Letter Writer Details` — even when that field is populated, analyst paragraphs that are not directly sourced from {{USER_FIRST_NAME}}'s instructions in that field still fail.**
- **Specificity slot check — FAIL if triggered:** Scan every body paragraph for abstract quality claims — any word or phrase describing {{USER_FIRST_NAME}}'s character, capability, or working style (e.g., strategic, proactive, collaborative, creative, fast, effective, detailed, experienced, clear, communicative, quality-focused, supportive, or any comparable quality adjective) that appears without named proof within two sentences. Named proof means: a company name, a number, a specific deliverable, or a named methodology. Flag as: "Body contains '[claim word]' without named proof within two sentences — add a company name, number, or specific deliverable." One flag per violation; check all body paragraphs. Opening and closing prose are exempt — this check applies to proof paragraphs only.
- Closing is a direct ask — banned: "at your earliest convenience", "I hope you will consider", "I would welcome the chance to talk", "I hope to hear from you", "I look forward to the opportunity"
- If JD has a "good fit / you'll thrive here if" section, letter addresses at least one positive signal with named proof
- No claims about the company's character not traceable to the JD (e.g., "one of the few companies that...", "you get it in a way most don't")
- No em dash as list separator (e.g., "— email security, endpoint protection, XDR —")

**Opening paragraph — non-waivable**

This check cannot be waived by any upstream input — not coach output, not Strategy, not Role emphasis, not Gap handling. The first paragraph is always {{USER_FIRST_NAME}}'s personal reaction to this specific role.

Check for the following failure patterns — any one is a fail:

**Pattern A — Generic opener:** "I am writing to apply for...", "I am excited to apply for...", "I am reaching out regarding...", or any generic enthusiasm statement without specific content.

**Pattern B — Second-person analytical opener:** Opening paragraph dominated by sentences describing the company's product, buyers, or market back to them ("Your buyers are...", "Your product is...", "Your sales motion...", "Building GTM for [X] isn't the same as..."). Consulting-speak; {{USER_FIRST_NAME}} is not the subject.

**Pattern C — Company language mirroring:** Opener echoes a JD/website phrase and frames {{USER_FIRST_NAME}}'s experience as "exactly that problem." Pattern: "[Company phrase] is exactly the problem I spent the last year living." Performs relevance instead of demonstrating it.

**Pattern D — Career summary dump:** Opening paragraph leads with a career achievement list. Pattern: "At [Company] I built [function] from zero to [X people] during [metric]: [list]." This belongs later, not as the opening move.

**Pattern E — Product or category flattery:** Opener compliments the company's **specific** terminology, product framing, or positioning. Pattern: "'[Company term]' is a genuinely smart framing" · "'Security Operations Resilience' is not just a buzzword" · "Calling it [Company name]" is a refreshingly honest take on [market]." Positions {{USER_FIRST_NAME}} as an observer validating the company. **Scope clarification:** Pattern E is about company-specific compliments only — not about general market observations. Do NOT apply Pattern E to sentences about the industry broadly; those are Pattern G or Pattern G2.

**Pattern F — Availability statement:** Opener leads with {{USER_FIRST_NAME}}'s current status. Pattern: "I just wrapped up at [Company]..." as the first move. The VL exit belongs integrated into the letter, not as the opening sentence.

**Pattern G — Generic industry observation:** The opening paragraph's subject is a market category, stage, or type of company rather than {{USER_FIRST_NAME}}. Pattern: "B2B tech companies hiring at the growth stage usually need someone who can operate at both ends simultaneously." · "The hardest part of selling security is that every vendor says the same thing."

**Pattern G2 — {{USER_FIRST_NAME}}-as-subject-but-market-as-claim:** {{USER_FIRST_NAME}} IS the grammatical subject of the first sentence, but the sentence immediately pivots to a general claim about "the job," "the market," or "the problem" as if {{USER_FIRST_NAME}} is explaining the industry to the reader. Pattern: "I've spent six years in cybersecurity PMM, and the job — above everything else — is finding the right words for a market where half the vendors say the same thing." · "I've been doing this long enough to know that the real challenge in [space] is [general observation]." The tell: the clause after "and" or the subordinate clause is a market/industry insight, not a personal reaction to THIS role. {{USER_FIRST_NAME}} sounds like she's lecturing about the market rather than saying why she wants this specific job.

**Pattern H — Company-specific hook substituting for a reaction:** Opener quotes the company's tagline, names a prior technical challenge as a credential hook, or names an exact client as domain proof. These feel researched but position {{USER_FIRST_NAME}} as doing due diligence rather than reacting to the opportunity. Company-specific knowledge belongs in paragraph 2 as proof.

**Pattern I — Setup opener as first sentence:** The very first sentence of the opening paragraph frames the industry context, role stakes, or market problem before {{USER_FIRST_NAME}} appears as a subject reacting to this specific opportunity. Pattern: "The hardest part of [industry] is [challenge]." · "In a market where [condition], what companies like [Company] need is someone who [requirement]." · "Finding the right words for [category] is harder than it looks." Applies even when the setup sentence is short and seems innocuous. The test: does the first sentence make a claim about the market, the role, or the company before {{USER_FIRST_NAME}} says what SHE wants or what SHE recognises? If yes, flag Pattern I. **Note:** Pattern I overlaps with Pattern G2 when {{USER_FIRST_NAME}} IS the subject — apply both labels.

**Sentence structure violations in the opening paragraph — FAIL**

The gatekeeper MUST flag and FAIL the following structural problems when they appear in the opening paragraph:

- **Gerund as subject:** Opening sentence begins with a gerund phrase ("Finding the right words for...", "Building GTM for...", "Having spent [time]..."). The subject must be {{USER_FIRST_NAME}} (first person), not a gerund.
- **Prepositional phrase opener:** First sentence begins with a prepositional phrase ("In a market where...", "After six years in...", "For companies at this stage...") instead of {{USER_FIRST_NAME}} as subject.
- **Dependent clause opener:** First sentence leads with a subordinate clause ("When half the vendors say the same thing...", "Because positioning in security is hard...") before {{USER_FIRST_NAME}} appears.
- **Wh-clause stacking:** Multiple "who/which/that" clauses chained within a single sentence, creating a sentence that sounds assembled rather than said.

These are not advisory. A sentence structure violation in the opening paragraph is a FAIL requiring revision.

**Banned words and phrases** — advisory only; do not fail or loop

Note any of these in the end-of-pipeline feedback note. Do not return as a violation or trigger a revision.
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

---

## Option 3 — Coach Output Fact Check

For each role in the coach's output, identify every specific factual claim about {{USER_FIRST_NAME}}'s background, experience, skills, or accomplishments. Find the supporting line in `who-rachel-is.md`.

**Verifiable:** directly traceable to a named section, sentence, or bullet in `who-rachel-is.md`.

**Unverifiable:**
- Names a company, client, product, or tool {{USER_FIRST_NAME}} worked with that does not appear in the reference file
- Attributes a metric, outcome, or responsibility not found in the reference file
- Describes a skill or domain depth that is not documented

**Do not flag:**
- Claims about the role or company (from the JD, not {{USER_FIRST_NAME}}'s background)
- Role emphasis sentences describing what the role requires
- Strategy sentences that are framing instructions, not factual claims about {{USER_FIRST_NAME}}'s past
- Gap handling entries identifying what {{USER_FIRST_NAME}} does NOT have (gaps are expected absences, not fabrications)
