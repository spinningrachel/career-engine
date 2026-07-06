---
name: gatekeeper-checks
description: 'Check definitions for the gatekeeper agent. Three checks: CV Check, Cover Letter Check, Coach Output Check. Load this skill before running any gatekeeper check.'
---

# Gatekeeper Check Definitions

> **Letter pipeline file.** Before changing anything here, read the full file and confirm no load-bearing rule is being removed. Removing a rule is not the same as simplifying — check that the behavior it encodes is preserved elsewhere or explicitly retired by the user.

**Why this file is shaped the way it is.** Aggressively trimmed to gates with demonstrated evidence, using the same evidence base and methodology as `skills/writer-craft/SKILL.md` (the writer-facing doctrine this file enforces): (a) real production violations traced from actual pipeline sessions, and (b) gaps found via condensed-prompt gatekeeper experiments this session. Every gate below either fired as a real traced violation, defines document correctness (not style), or closes a gap the writer doctrine states but no check previously enforced. **Coherence rule:** every gate here checks something `writer-craft/SKILL.md` actually tells the writer to do — no gate exists here for a rule the writer skill doesn't state. Structured as numbered gates, hard-fail vs advisory labeled per item, mirroring the condensed-prompt structure that tested well this session.

---

## CV Check

Run Gate 0 (ATS pre-check) first, then Gates 1-4 in order.

### Gate 0 — ATS Pre-Check (hard fail)

ATS failures mean the document may never reach a human reader regardless of quality.

**Keyword coverage.** Parse the Keywords property into three tiers (`Critical: ... | Important: ... | Nice-to-have: ...`). Search each term (case-insensitive) across the full CV body — summary, experience bullets, skills section.

| Tier | Requirement | Action if below threshold |
|---|---|---|
| **Critical** | ≥80% must appear | FAIL — list missing terms by name |
| **Important** | ≥60% must appear | FAIL — list missing terms by name |
| **Nice-to-have** | No threshold | Advisory only — end-of-pipeline feedback note, not a violation |

**Gap handling exception:** a missing Critical/Important term explicitly listed as a gap in the role's Gap handling property does not FAIL — add it to the advisory note instead.

**Standard section headings.** Search the full document (case-insensitive) for "SUMMARY", "EXPERIENCE", "SKILLS" — quote the line where found, or state explicitly it is absent. Headings may appear anywhere in the document.

| Required | Not acceptable |
|---|---|
| SUMMARY or PROFESSIONAL SUMMARY | Profile, About Me, Introduction |
| EXPERIENCE or WORK EXPERIENCE | Career History, Professional History, Work History |
| SKILLS | Core Competencies only (without SKILLS anywhere) |

FAIL if EXPERIENCE or SUMMARY headings are absent or substantially renamed.

**Macro-injected sections — FAIL if present, never FAIL on absence.** `## EDUCATION`, `## LANGUAGES`, `## ADDITIONAL` are injected automatically by the Word template — they must NOT appear in cv-writer's markdown output (duplication risk). FAIL immediately on any hit: "[SECTION] section must not be written — it is part of the Word template and will duplicate." Never FAIL on their absence.

**`## TOOLS` — optional, not a FAIL on absence.** If present, must use the literal `## TOOLS` heading — FAIL if present under any other heading name: "TOOLS section uses non-standard heading [heading] — rename to `## TOOLS`."

**BlueFont annotation check.** Scan for the pattern `[^]]{custom-style="BlueFont"}` — i.e. `{custom-style="BlueFont"}` not immediately preceded by `]` (an unbracketed span; pandoc renders the literal annotation string as body text). FAIL every hit: "Unbracketed BlueFont span: `[text here]` — wrap: `[text here]{custom-style=\"BlueFont\"}`."

---

### Gate 1 — Summary (hard fail unless marked advisory)

- No company, client, or conference names — descriptors only (`01-writing-rules.md` §1). **Hard fail.**
- ≤120 words, 1 paragraph, ≤4 sentences. No tool/platform names, consulting client names, or undocumented metrics. **Hard fail.**
- No motivation language — the summary states capability, not why she wants the job. **Hard fail.**
- Leads with language most relevant to the hiring manager and role; no specific role required to appear, including the most recent one. Do not FAIL on the absence of any particular role.
- **Single-instance trap.** For every concrete claim in the summary, count how many times the CV body demonstrates it across different roles. One instance → FAIL: "Summary sentence '[sentence]' implies a repeated pattern but the CV shows only one instance — move the specific detail to a bullet under [role], replace with the breadth claim." A dense, em-dash-stuffed, or bullet-shaped summary sentence is the signal to run this test. **Hard fail.**
- **Absolute-peak numbers.** A single absolute team-size or growth number (e.g. "a 13-person team," "300% YoY growth") implies sustained state — FAIL unless phrased as a range ("up to 13-person teams"). **Hard fail.**
- **Roster-level detail.** Listing the specific sub-functions of a team (e.g. "spanning editorial, technical writing, social, product marketing, field") is bullet-level detail — FAIL: "Summary lists specific team functions — abstract to 'multiple competencies' or equivalent scope language; move the roster to a bullet." **Hard fail.**
- Cliché filler ("comfortable operating across", "proven track record", "passionate about", "results-driven", "dynamic", "extensive experience") — **advisory only; do not FAIL or loop.**

### Gate 2 — Experience (hard fail)

- `## EXPERIENCE` = full-time employment only, reverse-chronological by end date.
- Consulting/fractional work belongs in `## CONSULTING`, never `## EXPERIENCE` — FAIL if found in Experience.
- Any consulting entry flagged mandatory in `02-professional-background.md` must appear (standalone entry in `## CONSULTING` or a bullet within it) — FAIL if absent entirely.
- "Earlier:" line is the final entry inside `## EXPERIENCE`, before `## CONSULTING` — FAIL if Earlier appears after CONSULTING.
- Claims about target market match `02-professional-background.md` (Role Facts).
- No tool or technology name of any kind inside experience bullets — blanket ban, even a tool named in the JD, even as an example. Approved bullets from `02-professional-background.md` are the only exemption.
- Every named role has a RoleOverview immediately below its RoleTitle — count must match (Earlier: exempt).

### Gate 3 — Structure (hard fail)

- No years on the Earlier line (Education/Languages are script-injected — skip them).
- No header or label between the SUMMARY banner and the summary text.
- **No opening verb 3+ times** — common offenders: Built, Led, Developed, Created, Managed, Drove, Owned.
- **No 4+ word verbatim JD phrases in new bullets** (standard terms like "go-to-market" are fine; approved bullets exempt); quote both phrases when flagging.
- **No em dash (—) anywhere** — zero exceptions, no carve-outs (not as a list separator, not for asides, not as a colon substitute — the full-width ban per `writer-craft/SKILL.md` §1). **Hard fail.**
- **No colon (:) anywhere in body copy** — not for role labeling, introducing explanations, before lists, or as an em-dash substitute (`writer-craft/SKILL.md` §1). **Hard fail.**
- **Soft-skill filler banned as a standalone claim:** "works independently," "self-starter," "takes initiative," "manages own workload," "team player" — FAIL if present without bullet-level substantiation. **Hard fail.**
- **AI-tell vocabulary** (`writer-craft/SKILL.md` §2): crucial, pivotal, vibrant, showcase/showcasing, tapestry, underscore (verb), landscape (abstract noun), testament, enduring, foster/fostering, garner, interplay, intricate/intricacies, foundational, transformative, robust, seamless, comprehensive, leverage (verb), synergy, spearhead, paradigm, "know what it takes," land (verb). CV-only additions: think outside the box, value add, go-to person, bottom line, big picture, cutting-edge, game-changer, guru, ninja, rockstar, world-class, paradigm shift, scalable, disruptive, innovative, holistic approach, agile. **Advisory — scored, does not independently block.**
- **Named phrase bans** (`writer-craft/SKILL.md` §2): "that made it land," "behind the [noun]," "at an inflection point," "quietly [verb]ing," "rare" as self-descriptor, "up close," "specialism." **Advisory.**

### Gate 4 — Sentence Mechanics (advisory, scored — flag but do not independently block)

Cross-referenced from `writer-craft/SKILL.md` §3-4; these are style-quality checks, not the hard-fail document-correctness checks above.

- **False range** ("everything from X to Y" where X/Y are filler, not real endpoints).
- **Approach-announcement via label** (naming a methodology before demonstrating it — e.g. "My approach is deliberately research-first:").
- **Contrived tricolon** built to sound impressive (real parallel lists of 4-5 real things pass) — also flag the same sentence opening used 3+ times in a row.
- **Passive voice** where an active rewrite is available.
- **Synonym cycling** — rotating synonyms for the same concept instead of repeating the right word.
- **Filler phrases** left uncut: "in order to," "at this point in time," "it is important to note that," "due to the fact that," "has the ability to," "in the event that."

---

## Cover Letter Check

**Calibration authority:** the humanizer holds calibration authority over voice register and word-count decisions around the 320-word target. The 320-word body limit is a round-aware advisory, not a hard fail (see Grading). The gatekeeper enforces the mandatory structure gates below and flags word overage as advisory only — it does not apply voice register judgments that conflict with the humanizer's calibration output.

### Gate 1 — Format (hard fail unless noted advisory)

- **Greeting:** `Hi to the [Company name] team!` or `Hi to [Name]!` — stealth roles (no public company name): `Hi to the team!` or `Hi to the [JD descriptor] team!`. **Hard fail.**
- **Role named in the first sentence of the body** — need not lead the sentence, but must be explicit. **Hard fail.**
- **Sign-off:** a brief forward-looking close (default "Looking forward to next steps,"), then `{{USER_FULL_NAME}}` on its own line. The gatekeeper does not judge sign-off voice/register against the delivered-letters archive (humanizer's calibration authority — see Calibration authority above); accept any reasonable forward-looking sign-off. Flag structurally only: missing sign-off, name not on its own line, or a P.S. containing company-positioning commentary (a P.S. for logistics/warmth is fine). **Hard fail on structural flags only.**
- **Body: maximum 320 words** (excluding greeting/sign-off; no minimum; 270-320 is the typical delivered-letter register). **Count mechanically — write the body text to a scratch file and run `wc -w` via the Bash tool; never estimate.** A real production run had the writer's self-reported count under the true figure by 20-40 words on every letter (two shipped over 320 as a direct result) — treat any writer-supplied count as unverified until you've recounted it yourself. **Advisory — round-aware** (see Grading): block-and-trim on round 1, deferred to humanizer on round 2+. Never block past round 1 on word count alone.
- **Language skills — FAIL if present.** Language proficiency statements ("Fluent in Hebrew and English," "native speaker of [language]," any language-as-credential statement) belong in the CV only. FAIL: "Language skills must not appear in the cover letter — this belongs in the CV." **Hard fail.**

### Personal-content exemption — read before running any content gate

If the user's Why I Want This Role content was passed alongside the cover letter — **or the letter draws on the Motivation Bank (`02-professional-background.md` → Section 5), which is the letter-writer's primary source and is especially the case when Why I Want This Role is empty** — that is the user's own first-person material, not letter-writer invention. Do not FAIL content gates for passages that clearly originate from her Why I Want This Role field **or a Motivation Bank entry**. The signal: personal-content-derived text sounds like a personal reaction or genuine first-person opinion; agent-fabricated content sounds assembled and polished. A specific personal claim about the company or role that matches phrasing plausibly the user's own voice is exempt from Gate 3, the company-character-claims gate, the analyst-paragraph gate, the banned words/phrases gate, and the Hollow/vague/presumptuous constructions gate. A hedged inference in her words ("I believe X would demand Y") is an earned inference — exempt when named proof sits within two sentences.

**The exemption does NOT cover:** the CV-repetition prohibition, fabricated/unevidenced factual claims, or **the Opening Paragraph gate's pattern checks (see the non-waivable carve-out below — this exemption never extends there, even when the flagged phrasing traces to her own WIWTR words).** Apply the exemption only to plausibly personal statements — not to agent-constructed analytical claims about the company's strategy, market, or positioning. Seniority step-down sentences derived from WIWTR are also exempt from the gap-volunteering gate when they use affirmative framing (see Gate 3) — the exemption does NOT cover negation-form step-down framing, which FAILs regardless of source.

**Verifying provenance:** the gatekeeper already reads `02-professional-background.md` for the fabrication checks — when a suspected-personal passage is in doubt, check it against the Motivation Bank (`02` → Section 5). A match is personal-content-derived and exempt. When WIWTR is empty, the letter's motivational and voice content legitimately comes from the Bank — verify there before flagging as fabricated.

### Gate 2 — Why I Want This Role point coverage (hard fail if triggered)

If the numbered [WIWTR-N] point list was passed alongside the letter: verify each point is substantively present in the letter text (not just its theme — its actual substance). Missing points = FAIL, listed by number with quote. If no [WIWTR-N] list was passed, skip and note "WIWTR point list not provided — coverage check skipped."

### Gate 3 — CV repetition (hard fail if triggered)

Requires the final revised CV in scope. If not passed alongside the letter, report "CV not provided — repetition check skipped" as a named line — never skip silently; the pipelines are required to pass the CV, and a missing CV is itself a finding.

Read every substantive claim, metric, credential, and fact in the letter body. For each, check whether the same information already appears anywhere in the CV. Flag: "Letter repeats CV content: '[sentence or phrase]' restates '[location in CV]'." A sentence FAILs if it makes the same claim in different words — paraphrase is not a loophole. Enhancement passes: if the letter sentence contains material the CV bullet does not (context, story, decision logic, new detail), it passes. Pure restatement FAILs.

### Gate 4 — Content and Claims (hard fail unless noted advisory)

- **No agent-drafted fit claims:** "this role has my name on it," "I was made for this role," "I'm the perfect candidate," "perfect fit," "couldn't be a better fit." A fit/confidence claim verbatim from WIWTR (or her own edits) is exempt under the personal-content exemption. **Hard fail.**
- **No gap volunteering or scope qualification framing:** "Full disclosure:" + scope claims; "whether that's the fit you need"; any sentence pre-empting a concern the hiring manager hasn't raised. Scope-as-limitation framing ("one product, not a portfolio," "narrower than full-time," "smaller than the rest of my CV," or any sentence framing a domain/vertical/engagement type as a limitation) is the same violation. **Seniority step-down:** negation form ("This isn't a stepping stone for me") FAILs; affirmative form ("I've been building toward this role") PASSes even without the personal-content exemption. **Hard fail.**
- **No analyst paragraph anywhere in the letter** — describing the company's product/positioning back to them; a market observation from outside ("in a crowded X market"); a capability announcement without named proof ("that translation is where I live," "that's where I operate"). The user must be the subject of every paragraph, speaking from named experience. **Hard fail.**
- **Closing is a direct ask — never hedge:** "at your earliest convenience," "I hope you will consider," "I would welcome the chance to talk," "I hope to hear from you." **Hard fail.**
- If the JD has a "good fit / you'll thrive here if" section, the letter addresses at least one positive signal with named proof.
- **No claims about the company's character not traceable to the JD** (e.g. "one of the few companies that...," "you get it in a way most don't"). **Hard fail.**
- **No unsubstantiated company-character claims or overreach** (`writer-craft/SKILL.md` §3): never attribute something documented for only one past role to multiple roles; every scope/attribution/pattern claim must be checkable against the specific role(s) it's grounded in. **Hard fail.**
- **Temporal motivation hedges — forbidden.** Any phrase that frames the motivation as provisional, temporary, or tied to a specific career stage rather than a stated, unqualified want — the hedge undercuts the claim instead of adding real context. **Advisory** — kept advisory, not promoted to hard fail, because this pattern is genuinely harder to reliably identify than most Gate 4 items (closer to Gate 3's CV-repetition fuzziness); a hard block on an unreliably-detected rule risks the exact endless-revision-loop problem this whole check design exists to avoid.
- **Future-outcome commitments — avoid.** A promised, quantified result she'd own before she's actually started the role. Documented past outcomes are proof; promised future outcomes are not. **Advisory**, same reasoning as above.

### Gate 5 — Opening Paragraph (hard fail, non-waivable)

This gate cannot be waived by any upstream input — not coach output, not Strategy, not Gap handling. The first paragraph is always the user's personal reaction to this specific role.

**⛔ Non-waivable carve-out — even when WIWTR echoes JD language.** These pattern checks apply even when the candidate's own WIWTR notes happen to echo similar phrasing to the JD or company's public materials. Tracing an opener sentence back to her own WIWTR words does NOT exempt it from the pattern check below — if her WIWTR phrasing reproduces JD or company-tagline language closely enough to read as mirroring, it still FAILs. "It came from her own words" is never sufficient justification on its own.

Check for these failure patterns — any one FAILs:

- **Pattern A — Generic opener:** "I am writing to apply for...," "I am excited to apply for...," any generic enthusiasm statement without specific content.
- **Pattern B — Second-person analytical opener:** dominated by sentences describing the company's product, buyers, or market back to them ("Your buyers are...," "Your product is..."). The user is not the subject.
- **Pattern C — Company language mirroring:** echoes a JD/website phrase and frames the user's experience as "exactly that problem." Performs relevance instead of demonstrating it.
- **Pattern D — Career summary dump:** leads with a career achievement list. Belongs later, not as the opening move.
- **Pattern E — Product or category flattery:** compliments the company's **specific** terminology or positioning, positioning the user as an observer validating the company. Scope: company-specific compliments only, not general market observations (those are Pattern G/G2).
- **Pattern F — Availability statement:** leads with the user's current status ("I just wrapped up at [Company]...") as the first move.
- **Pattern G — Generic industry observation:** subject is a market category or company type, not the user.
- **Pattern G2 — User-as-subject-but-market-as-claim:** user is grammatically the subject of sentence 1, but immediately pivots to a general market/industry claim rather than a personal reaction to THIS role.
- **Pattern H — Company-specific hook substituting for a reaction:** quotes the company's tagline, names a prior challenge as a credential hook, or names an exact client as domain proof — positions the user as doing due diligence rather than reacting. Belongs in paragraph 2 as proof, not the opener.
- **Pattern I — Setup opener as first sentence:** frames industry context, role stakes, or market problem before the user appears as a subject reacting to this specific opportunity. Applies even when short and seemingly innocuous. Test: does sentence 1 make a market/role/company claim before the user says what SHE wants or recognises? If yes, FAIL. Overlaps with G2 when the user IS the subject — apply both labels.
- **Pattern J — Personal-affinity opener without professional credential (Information Sequencing violation):** leads with personal attachment, fandom, or biographical detail that is evidence of passion/affinity rather than the direct professional qualification for the role. Test: is the personal fact itself the credential for this role, or is it evidence that she cares? If affinity only, it must not lead — it belongs in the body, after at least one proof anchor. ✓ Passes: "I've spent 25 years in the Tel Aviv ecosystem" leading a letter for a role marketing Tel Aviv — the fact IS the credential. ✗ FAILs: "I grew up cheering for the Orioles" leading a letter for a sports-media role — relevant, but affinity is not qualification. **Labeling sub-check, applies wherever in the letter the personal detail eventually appears, not just the opener:** FAIL if a sentence explains why the personal detail matters ("That's who I am as a fan, and it's also how I think about audience") instead of just stating the fact and letting the reader make the connection.

**Non-transferability forcing function — run after the Pattern A-J checks, before concluding Gate 5.** Name explicitly — in the violation file on FAIL, or as your own working note on PASS — the single most specific, non-transferable anchor the opening paragraph contains: a named real referrer, a named product she's personally used, a specific dated event, or a specific verbatim JD/company detail reacted to. Quote it. **If none can be named — if every sentence in the opener would read identically with the company name swapped out — that is itself a FAIL, independent of whether any single Pattern A-J matched:** "No non-transferable anchor found in the opening paragraph — every sentence would read the same for a different company. Name the specific anchor, or the opener fails this test regardless of pattern-matching." This turns the existing "could this apply to any company?" test from a silent verdict into a forced, checkable output — a Gate 5 PASS with no anchor named is an incomplete check, not a completed one.

**Sentence structure violations in the opening paragraph — FAIL:**
- **Gerund as subject:** "Finding the right words for...," "Building GTM for...," "Having spent [time]..." — subject must be the user (first person).
- **Prepositional phrase opener — agent-drafted only:** "In a market where...," "For companies at this stage..." with no archive precedent. Archive-consistent ramps ("After years in regulated, trust-dependent categories...") pass.
- **Dependent clause opener — agent-drafted only:** "When half the vendors say the same thing..." with no archive precedent. Archive-consistent ramps where the clause carries HER action/reaction ("When I heard that [Company] is hiring...") pass.
- **Wh-clause stacking:** multiple "who/which/that" clauses chained in one sentence.

These are not advisory. A sentence structure violation in the opening paragraph is a FAIL requiring revision.

### Gate 6 — Banned Terms (split by tier — see below)

**Split by tier, added 2026-07-05.** The curated literal-string lists below are **Tier 1 (100% required, no exceptions)** — a fixed word/phrase list match requires zero semantic judgment, so it doesn't qualify as "style, taste, or choice" any more than Gates 1-5 do. Only the idiom/metaphor/simile item stays **Tier 2** — recognizing whether a phrase is figurative genuinely requires judgment a fixed list can't fully cover, the same reasoning that keeps Gate 4's hedge items out of Tier 1.

**Banned term checking is a literal string search, not a semantic review.** Use the Grep tool for every banned term search — a mental "I reviewed and found nothing" is not a valid completion of this check.

**Personal-voice exemption applies to every list below, at either tier** (`writer-craft/SKILL.md` §2): a hit is not a violation if it's confirmed verbatim in the user's own delivered-letters archive, `01-writing-rules.md`, or WIWTR/personal input — it's her authentic voice, not agent-generated filler. Confirmed live example: "passionate" and the "at heart" identity idiom are the user's own established voice, not AI filler — check her own material before flagging, every time.

#### Tier 1 — literal, zero-judgment bans (100% required, no exceptions)

Every violation requires a `→ resolution` per the Resolution format below. A hard fail here blocks every round, same as Gates 1-5.

*Cliché and vague filler:* "specialism," "genuinely," "actually"/"real" as emphasis intensifiers, "straightforward," "dynamic," "extensive experience," "proven track record," "passionate about," "results-driven," "at the intersection," "I have ... on exactly that" in one sentence, "I would welcome the chance to," "significant part of my career," "up close," "at an inflection point," "rare" as self-descriptor, "that made it land," "behind the [noun]," "quietly [verb]ing," self-declaration of capability without evidence ("I know how to speak to buyers who [X]"), "What puts me closest to what [Company/you] is/are doing," "X is [something], not [something]" as a positioning claim.

*AI vocabulary — ban every instance* (`writer-craft/SKILL.md` §2): crucial, pivotal, vibrant, showcase/showcasing, tapestry (figurative), underscore (verb), landscape (abstract noun), testament, enduring, foster/fostering, garner, interplay, intricate/intricacies, foundational, transformative, robust, seamless, comprehensive, playbook (abstract concept), leverage (verb), synergy, spearhead, paradigm.

*Cover-letter-only phrase bans* (`writer-craft/SKILL.md` §2): "I was just doing X" without naming company/role/outcome, "I know how to sell X" without naming company/result, "I knew this was mine" (any variant), "I spent the better part of a decade..." without naming the years.

*Fit-declaration family* — **"any variant" is not a single string; Grep for the family, not the exact phrase.** A live production run shipped "I knew the Director of ... role at Gilat was mine the moment I saw it" — a variant that a literal Grep for "I knew this was mine" would miss entirely, and it shipped uncaught. The construction is a fit-declaration claiming the role recognized/chose her (or vice versa) before she's demonstrated why. Grep for the recurring fragments, not one fixed sentence — at minimum: `was mine`, `meant for me`, `meant to be`, `the moment I saw`, `knew.*mine`, `recognized.*immediately`, `this is the seat`, `this is the one`. Any hit is the same violation regardless of which fragment matched; do not narrow the search to the one worked example in the rule. **Confirmed live example of this exact family, a different surface form:** "This is the seat." — a bare, unearned fit-declaration with no traceable source, same defect as "was mine," just four words instead of a full sentence. Short doesn't exempt it.

#### Tier 2 — judgment-dependent (scored against the ≥70% threshold)

*Idioms, clichés, metaphors, similes, self-deprecating humor* — any instance ("put my thinking cap on," "hit the ground running," "wear many hats," and all similar), UNLESS it appears verbatim in the user's own WIWTR or personal input (her voice, exempt). When in doubt, treat as an idiom and flag it.

### Gate 7 — Banned Structures (Tier 2 — scored against the ≥70% threshold)

Every violation counts toward its Tier 2 check type and requires a `→ resolution`.

- **Em dashes anywhere in the letter body — zero permitted.** → Replace with a period, comma, or restructure.
- **Antithesis/pivot formula — absolute ban:** "[Subject] does/has X, but [subject] is Y." / "It's not about X, it's about Y." / "This isn't just A, it's B." / "Not X — Y." Test: remove the negated half — if what remains is clearer, cut the setup.
- **Appended negating contrast — no carve-outs:** "[claim], not [X]" or "[claim], not as [X]" appended to a sentence (e.g. "I can execute quickly, not just strategize."). → Make the positive claim and stop.
- **False range — totalizing-claim family, not one syntax.** The underlying violation is a claim that a scope spans "everything" or "every X" without naming the real things inside it — "everything from messaging to competitive analysis" is one surface form; "across every channel," "in every market," "across the whole funnel" are the same violation in different words. Grep for the family, not the literal "everything from X to Y" string: at minimum `across every`, `every single`, `in every`, `everything from`, `across the entire`, `across the whole`. Any hit is the same violation regardless of which fragment matched — do not narrow the search to the one worked example in this rule. Test: could you name the 2-4 real things this phrase stands in for? If not named anywhere, this is the violation. → Name the specific things, or cut the totalizing wrapper.
- **Approach-announcement — method-before-demonstration family, not one phrase.** The underlying violation is naming or describing a methodology, depth of engagement, or way of working as a claim, without a specific instance attached — "my approach is..." is one surface form; "I go deep on the product," "I take a [X] approach," "I make it a point to..." are the same violation. Grep for the family: at minimum `my approach is`, `I go deep`, `I take a .* approach`, `I make it a point`, `I like to really`. Any hit is the same violation regardless of which fragment matched. Test: does the sentence claim a way of working without immediately naming a specific company/artifact/outcome where she did it? → Show it in action instead: name the specific instance that demonstrates the claimed practice.
- **Sentence-rhythm floor (redundant with the humanizer's own Final Gate — belt and suspenders).** At least one sentence ≤8 words AND one ≥25 words somewhere in the body. **FAIL if both anchors are absent** — a letter with zero short sentences (monotone rhythm) is the same failure mode the humanizer's Quantitative Final Gate item 1 checks; this gate exists so a flat-rhythm letter is flagged before the humanizer ever sees it, and so the pipeline has a second, independent check if the humanizer's own gate silently under-runs. A short, terse letter is not itself a violation — the test is variation (at least one short AND one long sentence present), not overall length. → Add one short (2-5 word) sentence and confirm one long (25+ word) sentence exists; do not rely on the humanizer alone to introduce rhythm.
- **Syntax correctness (general grammar, distinct from the named-pattern bans above).** Run-on sentences, sentence fragments used as errors (not deliberate stylistic ones), subject-verb disagreement, dangling/misplaced modifiers, incorrect pronoun-antecedent agreement. Same territory as the humanizer's Step 0 ("native, idiomatic English"), checked here too as an independent gatekeeper-stage pass.
- **-ing phrases appended after a main clause — max 3 per letter, every one content-bearing.** A decorative tail ("...showcasing expertise") is banned at any count.
- **Contrived tricolon** built to sound impressive (real 4-5 part parallels of actual things pass). Also: the same sentence opening used 3+ times in a row.
- **Subject-first violations — hard ban, no carve-out:** expletive constructions ("There was/is/are..."), abstract label noun-phrase subjects ("The founding-marketer part is..."). Archive-consistent dependent-clause/prepositional-opener ramps pass.
- **Copula avoidance:** "serves as / stands as / acts as" where "is" works.
- **Synonym cycling:** rotating synonyms to avoid repetition.
- **Filler phrases left uncut:** "in order to," "at this point in time," "it is important to note that," "due to the fact that," "has the ability to," "in the event that."
- "Here's the thing" / "Here's the hard truth" / "And honestly?" / "Let's be honest" / "Unlock" / "Unleash" / "Harness" / "In today's [X] world" / "As we look to the future" / "Today's landscape" / "navigating the landscape" / "Broke the mold" / "In reality" as a transition / "Hit home" / "How we show up" / "You're not imagining it."
- Any sentence beginning with "Just" + first-person verb.
- Triadic negation ("No X. No Y. Just Z.") and negation-then-assertion ("Don't just X. [Subject] Y.").
- Staccato fragments substituting for full sentences.
- "X isn't always about Y" / "X should be Y, not Z."

**Generic-default-template verbatim reuse — new users only, never a user's own personalized templates file.** This check applies ONLY when the letter was drafted against the plugin's generic `cover-letter-templates-default.md` (a brand-new user with no personalized file yet) — **never** against a user's own `references/templates/cover_letter_templates.md`. The reason for the distinction: a personalized templates file is built from the user's own delivered-letters archive (`cover-letter-templates-default.md` → Setup Integration) — its variants are frequently her own real, previously-delivered sentences captured as reusable patterns, and reusing them verbatim is the same "reuse your own proven words" principle already established as good practice elsewhere in this doctrine, not a violation. **Confirmed directly by the user:** a phrase this check originally flagged ("With a small team, I would never want to hide") was her own authentic sentence, written for a real prior letter as a deliberate nod to a JD's remote-work framing, later captured into her personal templates file — reusing it was never a defect. The generic default template's variants, by contrast, are synthetic scaffolding meant only to illustrate tone and shape for a user with no voice history yet — reusing THOSE verbatim is a real defect, since the sentence isn't anyone's authentic voice.

**When the generic default was used:** read its **Variants** lists (the bracketed illustrative example sentences under each block). For each of the letter's structural blocks, check whether its sentence is the matching variant with only the bracketed placeholders filled in — strip the brackets from the variant and the corresponding filled content from the letter's sentence; if the remaining fixed wording and clause structure still match closely, the letter copied the template's illustrative text instead of writing an original sentence. **FAIL per instance.** → Rewrite the sentence from scratch; the variant is a register/shape example only, never a sentence to fill in.

**When a personalized templates file was used, do not run this check at all.** If a variant in the user's own file reads as weak or formulaic on a close read, that's a personal-file quality question for her own periodic review — note it once in Patterns for the user's attention, never as a letter FAIL. (Confirmed real example of a variant worth her review, not a letter defect: "I just finished [SPECIFIC RECENT PROOF] at [COMPANY], so the [ROLE] role reads like the natural next build" and "When I saw the [ROLE] role, I wrote the same day" — both read as generic on reflection, per the user's own assessment, and are candidates for her to replace in her own file via the update-prompt path, not something the gatekeeper polices.)

### Gate 8 — Hollow / Vague / Presumptuous Constructions (Tier 2 — scored against the ≥70% threshold)

The letter must SHOW with specifics, not TELL with confident-sounding sentences that say nothing. **Personal-content exemption applies:** a sentence verbatim from WIWTR or the Motivation Bank is her voice — exempt. These catch *agent-constructed* filler.

- **Generic aphorism/maxim** — abstract general truth with an abstract noun (not the user) as subject: "Specificity is what moves a deal." → Cut, or replace with her specific experience demonstrating it.
- **Presumptuous verdict on the company's business** — flatly telling them what they need: "...and this is the transition [Company] needs." → Cut. (A confident value claim in her own voice — "It sounds like you're looking for me" — is exempt; a flat agent-constructed verdict on their business is not.)
- **Vague bare assertion / hollow-object capability claim — forcing function, run for every capability claim in the letter.** A capability claim is any sentence of the form "I [verb — own/led/built/handled/manage] [object]." For every one found, resolve explicitly: (a) the named object — the noun phrase after the verb; (b) does the object resolve to something concrete — a named company, artifact/deliverable, or outcome/metric, either in the same sentence or the same paragraph? A bare function or skill name ("messaging," "positioning," "growth," "the roadmap") is NOT concrete on its own — only when anchored to a company, artifact, or outcome nearby. Two outcomes, same violation:
  - **Object entirely absent** ("I've made it before" — made *what*?) → FAIL: name the missing object, or cut.
  - **Object present but unresolved/generic** ("I've owned messaging and positioning," "I go deep on the product" — names a function, not a concrete instance) → FAIL: "Named object '[object]' is a bare function/skill name with no company, artifact, or outcome attached nearby. → Anchor it: name the company, the specific artifact, or the specific outcome this claim refers to, or cut the claim."
  This closes the gap where a technically-named-but-generic object ("messaging") passed a literal-read check for "no named object at all."
- **Hollow metaphor** — vivid but no concrete proof: "a story that lived in the founders' heads." → Replace with the named result, or cut.
- **Generic filler** — a sentence that could appear in any letter for any role. → Cut or make role-specific.

### Gate 9 — Structural Completeness (Tier 1 — 100% required, no exceptions)

**Skip this gate entirely if no `Template selected` value was passed to this check.** Every user should have `references/templates/cover_letter_templates.md` at minimum (the generic default, installed at setup) — a missing `Template selected` value is a rare fallback (an account set up before this feature existed) or a genuine wiring bug, not a normal case. Log it distinctly: "Template selection not provided — Gate 9 skipped (expected a value; confirm the coach's pre-draft outline step actually ran)." This is not itself a violation, but it should never pass unremarked.

**When a template was selected, read `${CLAUDE_PLUGIN_ROOT}/references/cover-letter-templates-default.md` (or the user's own `references/templates/cover_letter_templates.md` from career-data, when it exists — prefer the user's file) for the selected template's Block list and Dial Sheet row.** Check the letter against the selected template only — never both templates' Block lists in the same pass.

**Block presence — all five, each independently checked, no averaging.** A block that exists structurally but doesn't do its job fails the same as an absent one — do not credit a block for merely occupying that position in the letter.

- **Opening.** Delegates to Gate 5 — do not re-run separate logic. If Gate 5 passed, Opening passes. If Gate 5 failed, Opening fails here too (the same failure, not a second violation).
- **Philosophy.** A paragraph — may be as short as one sentence — that states a belief or POV about the discipline/problem the role sits in, in her own voice, distinct from a proof claim. **FAIL if absent, or if the paragraph in that position is actually another proof point or an analyst observation about the company instead of a stated philosophy:** "No philosophy-before-proof paragraph found — add one belief statement before the first proof paragraph."
- **Proof.** At least one paragraph with a named, documented outcome substantiating a claim. **FAIL if every paragraph is assertion without a named result, or no proof content is distinct from the Opening.**
- **Objection-Preemption.** A passage that names and answers the reader's most likely hesitation (domain gap, seniority mismatch, scope question) with proof — never as apology, never as volunteered weakness (same family as Gate 4's gap-volunteering ban; a passage reading as apology fails both gates, not just this one). **FAIL if entirely absent, or if the passage in that position is actually gap-volunteering language rather than a preemptive answer.**
- **Close.** A direct, forward-looking, unhedged ask, its own paragraph. **FAIL if missing, merged into the prior paragraph, or hedged** (overlaps Gate 4's closing-is-a-direct-ask rule — flag under both if it fails both).

**Identity idiom.** **FAIL if the letter uses a self-descriptive identity label ("I'm a builder," "I'm a translator between X and Y," "I'm a connector") as a bare claim with no proof attached nearby.** "Nearby" means the same sentence, the immediately adjacent sentence, **or** the immediately adjacent paragraph — in either direction. A label substantiated by named proof that comes right before it (a close-paragraph callback after proof already ran, e.g. "...led that turnaround at [Company]. I'm a builder at heart.") passes exactly like proof that comes right after — direction doesn't matter, adjacency does. A label with no proof anywhere near it — proof only several paragraphs away, or absent entirely — fails. **This is not "proof exists somewhere in the letter": a label sitting alone in the opener while the only proof is in the close, three paragraphs later, still fails** — the reader hits the bare claim long before the proof arrives, and that gap is the defect. Distinct from Gate 6's general idiom-as-filler ban — this check is specifically about identity-claiming shorthand substituting for demonstrated proof.

**Dial-sheet checks — Tier 2, not Tier 1 (see Grading section below). Maximum only, never minimum:**
- Word count against the template's ceiling
- Sentence count against the template's ceiling
- Contraction density against the template's ceiling
- Exclamation count against the template's ceiling
- Numeral density against the template's ceiling

A short letter with no padding is not a violation of anything in this gate — there is no floor on any of these.

**Optional: real computed ceilings instead of the template's generic defaults.** `skills/humanizer/scripts/corpus-stats.py` (a generic, standard-library-only script — see `skills/humanizer/SKILL.md`) can compute the user's own sentence-length, contraction-rate, and numeral-density figures from her `${CAREER_DATA}/references/delivered-letters/` archive when one exists. When available, compare the draft against those real, per-user figures instead of the template's generic dial-sheet defaults — the template's defaults remain the fallback when no archive exists.

---

### Cover Letter Check — Grading and Pass Threshold

**Run this after completing all gates (1-9) on every Cover Letter Check pass.**

The letter must meet **100% of Tier 1** (structure and hard-fail correctness) **and ≥70% of Tier 2** (calibration and polish, scored as a checklist of distinct check types). There is no partial credit inside Tier 1 and no letter grades — PASS or FAIL only, with the Tier 2 percentage always stated.

#### Tier 1 — 100% required, always, no exceptions

- Gate 1 (Format) — all hard-fail items (greeting, role-in-sentence-1, sign-off structure, language-skills ban). Word count overage is NOT in Tier 1 — see Tier 2.
- Gate 2 (Why I Want This Role point coverage)
- Gate 3 (CV repetition)
- Gate 4 (Content and Claims) — all hard-fail items. The two advisory items (temporal motivation hedges, future-outcome commitments) are NOT in Tier 1 — see Tier 2.
- Gate 5 (Opening Paragraph) — non-waivable
- **Gate 6 (Banned Terms) — the curated literal-string lists only (added 2026-07-05): cliché/vague-filler, AI vocabulary, cover-letter-only phrase bans, fit-declaration family. The idiom/metaphor/simile item is NOT in Tier 1 — see Tier 2.**
- Gate 9 (Structural Completeness) — Block presence (all five blocks) and the Identity idiom check. The Dial Sheet numeric checks are NOT in Tier 1 — see Tier 2.

**Step 1 — Run all Tier 1 checks.** Any single failure anywhere in Tier 1 = **FAIL immediately**, regardless of the Tier 2 outcome. Do not compute a Tier 2 percentage when Tier 1 has failed — name the Tier 1 violation(s) and stop.

Hard fails block **every round**, exactly as before — the set of what counts as Tier 1 simply grew to include Gate 9's structural checks.

**Step 2 — If Tier 1 is clean, run all Tier 2 checks and compute the percentage.**

#### Tier 2 — aggregate ≥70% required

Tier 2 is a checklist of **32 distinct, named check types**, not raw violation-instance counts. Each check type is binary across the whole letter: **0 violations of that type anywhere = the check type passes; 1+ violations anywhere = the check type fails**, regardless of how many instances occur. A letter with five instances of the antithesis formula fails that one check type exactly the same as a letter with one instance.

**Tier 2 score = (check types passed ÷ 32) × 100. PASS if ≥70%. FAIL if <70%,** naming the score and every failing check type by name.

**Mechanical execution — run this as two passes, not one mental read-through of all 32.**
1. **One Bash grep-battery, one tool call**, covering every literal-pattern-matchable check type below (the antithesis test, the false-range/approach-announcement families, the filler-phrase list, the transition/cliché-phrase list, the template-variant-reuse diff). The gatekeeper already has Bash. (The Gate 6 curated word/phrase lists and the fit-declaration family are now Tier 1 — run those in the same grep battery, but they gate the letter before Tier 2 is even scored; see Grading above.)
2. **A focused second pass for the remaining genuinely-semantic checks** (idiom/metaphor recognition, hollow metaphor, presumptuous verdict, the Gate 8 forcing function, syntax correctness, sentence-rhythm) — a much smaller set once the mechanical pass has cleared most of the list.

**The full Tier 2 check-type list:**

*From Gate 6 (Banned Terms — judgment-dependent item only; the curated lists moved to Tier 1, 2026-07-05):*
1. No unexempted idiom/cliché/metaphor/simile/self-deprecating-humor hit

*From Gate 7 (Banned Structures):*
2. Zero em dashes
3. No antithesis/pivot formula
4. No appended negating-contrast construction
5. No false-range family
6. No approach-announcement family
7. No decorative -ing appendage (max-3-content-bearing rule violated, or any decorative one present)
8. No contrived tricolon (including same-opening 3+ times in a row)
9. No subject-first violation
10. No copula-avoidance hit
11. No synonym-cycling issue
12. No filler phrases left uncut
13. No hit on the named transition/cliché-phrase list
14. No "Just" + first-person-verb opener
15. No triadic negation or negation-then-assertion
16. No staccato-fragment substitution
17. No "X isn't always about Y" / "X should be Y, not Z" construction
18. Sentence-rhythm floor met
19. Syntax correctness (no run-ons, fragment errors, subject-verb disagreement, dangling modifiers, pronoun-antecedent errors)

*From Gate 8 (Hollow/Vague/Presumptuous):*
20. No generic aphorism/maxim
21. No presumptuous verdict on the company's business
22. No vague bare assertion / hollow-object capability claim (Gate 8 forcing function)
23. No hollow metaphor
24. No generic filler sentence

*From Gate 9 (Dial Sheet — calibration, not structure):*
25. Word count ≤ template's ceiling
26. Sentence count ≤ template's ceiling
27. Contraction density ≤ template's ceiling
28. Exclamation count ≤ template's ceiling
29. Numeral density ≤ template's ceiling

*From Gate 4 (advisory items):*
30. No temporal motivation hedge
31. No future-outcome commitment

*From Gate 7 (template-variant reuse — added 2026-07-05):*
32. No near-verbatim reuse of the generic default template's illustrative variant text (new users only — this check does not run at all when a personalized templates file was used)

**Round-aware behavior:**
- **Round 1, Tier 1 clean, Tier 2 <70%:** FAIL → letter-writer, naming the percentage and every failing check type.
- **Round 1, Tier 1 clean, Tier 2 ≥70%:** PASS → coach review.
- **Round 2+, Tier 1 clean, any Tier 2 %:** PASS → defer remaining Tier 2 misses to the humanizer, logging the percentage and failing check types (same trigger/outcome as the old "round 2+ advisory-only" rule — only the measurement changed from a violation count to a percentage).
- **Any round, Tier 1 FAIL:** always blocks.

**Resolution format — required for every failing Tier 2 check type (and every Tier 1 violation):**

Every violation must include a suggested resolution. Do not just quote the offending text — tell the letter-writer what to do. Use one of these forms:

- `→ Delete.`
- `→ Rewrite as: "[suggested replacement text]"`
- `→ Delete unless this comes from Why I Want This Role. If it does, replace with the user's exact words from that field.`

The third form ("delete unless from WIWTR") applies to any sentence that expresses the user's motivation, reaction to the company, personal connection to the role, or opinion about the opportunity — when that sentence sounds agent-constructed rather than drawn from the user's own Why I Want This Role content. The test: could the user have written this sentence herself? If not, it is agent-fabricated motivation and must be flagged this way.

**Resolution examples (apply the same logic to new violations):**

| Offending text | Resolution |
|---|---|
| "the Head of Marketing role at DualBird is one I understood the moment I read it" | Delete unless from WIWTR — if so, use the user's exact words. |
| "a story I didn't have to put my thinking cap on to picture telling" | Delete — idiom ("put my thinking cap on") plus agent-constructed framing. |
| "that shaped how I work" | Delete unless from WIWTR — if so, use the user's exact words. |
| "Wolt counting Israel as a priority market with real stakes is a big part of why this matters to me." | Delete unless from WIWTR — if so, use the user's exact words. |
| "WalkMe's position inside SAP excites me most." | Delete unless from WIWTR — if so, use the user's exact words. |
| "Feature adoption is won on rhythm, not launch day." | Delete unless from WIWTR — if so, use the user's exact words. Antithesis formula. |
| "The consumer and UGC stretch is the one worth making." | Delete unless from WIWTR — if so, use the user's exact words. If the substance is present in WIWTR, rewrite as a direct first-person statement: e.g., "I have been looking for an opportunity to focus more on consumer-facing products and user-generated content." |
| "Knowing when a motion won't scale matters just as much." | Rewrite as: "I also know when a tactic or strategy will most likely not scale." |
| "Media relations runs on the same muscle" | Rewrite as: "I need the same skill in order to properly manage media relations." |
| "I write it as a buyer's first trust signal, not a legal afterthought" | Rewrite as: "Content is the very first opportunity to build real trust with prospects. My goal is to create clarity, ensuring that the first signal a buyer receives is one of transparency and reliability." |
| "I've reviewed WalkMe several times over the years, and most of the Learning Arc competitive set already lives in my 1000+ tool research catalog." | Rewrite as: "I have reviewed WalkMe several times over the years, and I already have most of its competitors in my research catalog of more than 1,000 tools." |
| "Getting users to discover what Waze can actually do for them is the work I want to do." | Rewrite as: "I can't wait to get started investigating how we can increase user adoption together." |
| "The work here is ..." | Delete it |
| Adoption is where most of these efforts die.  | Unfortunately, adoption is often a failpoint in any case. |
| "The work I love most is ..." | Rewrite as: "I love to" |
| Adoption is where most of these efforts die.  | Unfortunately, adoption is often a failpoint in any case. |

---

## Coach Output Check

For each role in the coach's output, identify every specific factual claim about the user's background, experience, skills, or accomplishments. Find the supporting line across the **full background set** — not the rules file alone:
- `01-writing-rules.md` — fabrication rule, framing rules, identity values
- `02-professional-background.md` — Role Facts, approved CV bullets, approved summaries, testimonials, portfolio (**this is where most proof actually lives** — named companies, metrics, outcomes, events, responsibilities)
- `03-framework.md` §Domain depth — per-vertical narratives (this is where domain/vertical credibility lives, e.g. defense, healthcare, developer audiences)

A claim is verifiable if it traces to **any** of these three files. Checking against `01` alone produces false positives on real, documented claims (a defense event documented in `02`, a vertical narrative in `03` §Domain depth) — that is a check failure, not a fabrication. Read `02` and `03` §Domain depth before flagging anything as unverifiable.

**Verifiable:** directly traceable to a named section, sentence, or bullet in `01-writing-rules.md`, `02-professional-background.md`, or `03-framework.md` §Domain depth.

**Unverifiable:**
- Names a company, client, product, or tool the user worked with that does not appear in **any** of the three background files
- Attributes a metric, outcome, or responsibility not found in **any** of the three background files
- Describes a skill or domain depth that is not documented in `02` Role Facts or `03` §Domain depth

**Do not flag (for the fabrication check):**
- Claims about the role or company (from the JD, not the user's background)
- Role emphasis sentences describing what the role requires
- Coach context-block framing instructions (the Priority lines prepended to Why I Want This Role) — directional guidance, not factual claims about the user's past
- Gap handling entries identifying what the user does NOT have (gaps are expected absences, not fabrications)

### Field-fit and format checks

The fabrication check above verifies *traceability*. It does NOT catch content that is true but **in the wrong field**, **over a length cap**, or that **leaks a disabled feature** — the recurring coach defects. Run these in addition; **any hit is a FAIL** that returns to the coach for revision, exactly like a fabrication FAIL. (These examine field placement and format; they do not re-judge the framing the fabrication check already exempts.)

1. **Role summary contamination — JD-only.** FAIL if `Role summary` references the candidate ("she/her", her name), her fit, her seniority or title, a title she "hasn't held," a gap, or "transferable." `Role summary` describes the job only. Quote the offending sentence.
2. **Culture contamination — working-style only, no Landscape data.** FAIL if `Culture` contains specific financial or structural FACTS: dollar/revenue/funding figures, EBITDA numbers, named acquisitions or prices, exchange tickers (NYSE/NASDAQ), founding year, employee headcount, or segment names. Those belong in `Landscape`. A qualitative culture framing that references a posture ("profitability-first culture") is fine; the financial *data* is not.
3. **Gap leak when gap handling is disabled.** ONLY when the spawner states gap handling is disabled for this run: FAIL if any coach property OR the `Why I Want This Role` coach context block enumerates gaps — "gap", "the X real gaps", "doesn't have / lacks / missing", or any catalog of what the candidate lacks. A disabled feature must suppress the behavior everywhere, including the transfer note.
4. **Transfer note length.** FAIL if the coach context block's transfer/credibility line runs longer than **one line** (cap: one line, ≤25 words).
5. **Outreach self-contact / advice.** FAIL if the outreach map's `Email / WhatsApp` section contains the user's own email, phone, or contact line, or any drafting/application advice ("lead with…", "available now"). That section is the hiring target's reachability only.
6. **Length caps.** FAIL if `Keywords` exceeds 9 total (Critical >4, Important >3, or Nice-to-have >2); or `Culture` exceeds 3 bullets; or `Role emphasis` is missing its labeled **Mandate** / **Likely KPIs** structure.
7. **Mandatory-field presence.** For every role in the coach's output that completed full research (not a triage exit, Priority 1–4), FAIL if any of the following has no value at all — not even `Unknown`/`[LOW]`/`N/A` where the property's own rules permit that as a valid value: `Role summary`, `Priority`, `Priority Reason`, `Role emphasis`, `Keywords`, `Strategy`, `Role Type`, `Relationship type`, `Culture`, `Landscape`, `JD proof`, `Company Stage`, `Hiring manager's role`, `Manager role confirmed`, `Gap handling` (skip this one check if the spawner states gap handling is disabled for this run), `Location` (skip this one check if the spawner states the database has no `Location` property), `JD Body` (skip this one check for a role marked `content-exists` or `needs-manual` in Step 0.5 — only check it for a role marked with any `url-fetched*` marker this run), and `Date first advertised`/`First Advertised`. This list must stay in parity with the Step 0.8 coach-complete list and the Step 0.9a confirmation-pass list in `skills/career-engine-intake/SKILL.md` — see the Cross-file contracts table in `CLAUDE.md`. Name every missing field by role; this is a structural presence check independent of the fabrication and field-fit checks above, which cannot catch an omitted field.
8. **Outreach map structural purity.** The outreach map is the ONLY page-body content in the entire intake pipeline, and it must have identical structure every run. FAIL if the coach's `**Outreach map:**` return, for any role, contains anything beyond exactly these four parts: the `## Outreach — <Company>` heading, the ≤3-row table, `**Note angles**`, `**Email / WhatsApp**`. In particular, FAIL on a "Writing Angle" section, a "Message angle" section, numbered interview-style questions embedded in or adjacent to the map, or any other free-text commentary that isn't one of the four named parts — none of these have a defined format and none belong in page body. Quote the offending content and name the role. This check runs before intake ever writes to Notion (Step 0.8.5, ahead of the Step 0.9e page-body write) — it is the first line of defense; Step 0.9e's own extraction rule is the second.

Each FAIL names the property, quotes the offending text (or states "missing entirely" for check 7), and states the fix.
