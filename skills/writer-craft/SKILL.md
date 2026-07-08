---
name: writer-craft
description: Consolidated writer-facing doctrine for two writer agents — cv-writer and letter-writer. Replaces skills/cv-writing, skills/cover-letter, references/cover-letter-self-check.md, and the CV/cover-letter-relevant portions of references/shared-voice-rules.md (§1-7, not §8 LinkedIn). Aggressively trimmed to rules with demonstrated evidence from real pipeline runs. Sections are tagged [ALL] / [CV] / [CL] for which surface they govern. Humanizer-specific mechanics (formerly §12 Humanizer Mechanics and §13 Voice Calibration Protocol) were relocated to skills/humanizer/SKILL.md and the remaining sections renumbered contiguously — this file no longer has a [HUM] tag or a humanizer reader.
---

# Writer Craft — Consolidated Doctrine

One file, two readers: `cv-writer`, `letter-writer`. Read the sections tagged for your surface plus every `[ALL]` section. This file replaces four prior files — nothing here is optional because it moved. (The humanizer reads its own dedicated skill, `skills/humanizer/SKILL.md`, which now carries the humanizer-specific mechanics this file used to hold at former §12 Humanizer Mechanics and §13 Voice Calibration Protocol.)

**Why this file is shaped the way it is.** Real production runs hit 7-round whack-a-mole revision loops. Forensic analysis of those runs plus condensed-prompt experiments found: (1) most violations trace to a small, repeatable set of rules — not the long tail; (2) a narrowly-scoped rule ("no em dash as list separator") gets gamed around the narrow scope — bans here are stated at full width; (3) loading 3-4 large files per writer spawn has a real token cost per revision round. This file is short on purpose. Every rule below either fired in a real traced violation this session or defines document correctness (not style).

---

## [ALL] §1 — Absolute Punctuation Bans

**Em dash (—): zero, anywhere, no exceptions, no carve-outs.** Not "as a list separator," not for asides, not as a colon substitute. This was the single largest violation category in condensed-prompt testing (5 of 6 advisory hits in one test) specifically because a narrower "as a list separator" framing let other em-dash uses through. Fix: period (new sentence), comma (tight aside), or restructure. Before returning any output, search for `—`. Any hit means not done.

**Colon (:) — banned in CV and cover letter body copy [CV][CL].** Not for role labeling, not for introducing explanations, not before lists, not as an em-dash substitute. A real test letter used two colons that only the humanizer caught — a narrower rule ("avoid colons in lists") would have missed both. If you reach for a colon, restructure the sentence.

---

## [ALL] §2 — Banned Vocabulary (curated, high-signal subset)

**AI-tell words — cut on sight, replace with plain language:**
crucial, pivotal, vibrant, showcase/showcasing, tapestry (figurative), underscore (verb), landscape (abstract noun, e.g. "the marketing landscape"), testament, enduring, foster/fostering, garner, interplay, intricate/intricacies, foundational, transformative, robust, seamless, comprehensive, leverage (verb), synergy, spearhead, paradigm, "know what it takes," land (verb, e.g. "make it land")

**Hollow self-description — replace with a specific named outcome:**
results-driven, passionate, dynamic, proactive, experienced, highly qualified, top performer, thought leadership, industry expert, motivated, track record, effective, seasoned, action-oriented

**Personal-voice exemption — same rule as the idiom exemption below, extended to this whole section.** A word on the lists above is banned as a *generic AI-tell* — the ban assumes an agent reached for it as filler. It stops being a violation when it's confirmed as the user's own authentic word choice: verbatim in her delivered-letters archive, her `01-writing-rules.md`, or her Why I Want This Role / personal input. Confirmed example: "passionate" and "at heart" identity idioms are her own voice, not agent filler — a gate that flags them without checking her own archive first is producing a false positive, not catching a real defect. When in doubt and no verbatim match is found in her own material, treat it as the generic AI-tell and flag it.

**[CV] Additional CV-only bans:** think outside the box, value add, go-to person, bottom line, big picture, cutting-edge, game-changer, guru, ninja, rockstar, world-class, paradigm shift, scalable, disruptive, innovative, holistic approach, agile. **Soft-skill filler is banned:** "works independently," "self-starter," "takes initiative," "manages own workload," "team player" as a standalone claim — demonstrate through bullet substance, never state it.

**Named phrase bans [ALL]:**

| Banned | Fix |
|---|---|
| "that made it land" | Name what it was and the result |
| "behind the [noun]" (e.g. "behind the coverage") | Name the actual work |
| "at an inflection point" | Name the specific moment |
| "quietly [verb]ing" | Name the action directly |
| "rare" as a self-descriptor | Demonstrate through specifics |
| "up close" | Cut it |
| "specialism" | Not a word — use "multi-disciplinary" or "[X] disciplines" |

**[CL] Cover-letter-only phrase bans:** "I was just doing X" (name company/role/outcome), "I know how to sell X" (name company and result), "I knew this was mine" (any variant — state the reaction directly), "I spent the better part of a decade..." (name the years), metaphors and similes (name the actual thing).

**Idioms — absolute ban [ALL], one exception.** Any figurative phrase used non-literally ("hit the ground running," "wear many hats," "move the needle," "low-hanging fruit," "at the end of the day," "take it to the next level," "raise the bar," "think outside the box," and all similar) is banned — UNLESS it appears verbatim in the user's own Why I Want This Role or personal input, in which case it is her voice and may be used exactly as written. When in doubt, treat it as an idiom and replace it.

---

## [ALL] §3 — Structural Anti-Patterns

**Antithesis / pivot formula — absolute ban.** Never write "[Subject] does/has X, but [subject] is Y." Includes: "It's not about X, it's about Y." / "This isn't just A, it's B." / "Not X — Y." **Test:** remove the "but" clause and everything before it. If what remains is clearer and stronger, the setup was unnecessary — cut it. This tripped as a real violation in condensed-prompt testing; treat it as fully non-negotiable, not a style preference.

**[CL] Appended negating contrast — absolute ban, no carve-outs.** The construction "[claim], not [X]" or "[claim], not as [X]" appended to a sentence. Fail: "I can execute quickly, not just strategize." Fix: make the positive claim and stop — cut everything from the comma forward.

**False range — totalizing-claim family, not one syntax.** "Everything from X to Y" is one surface form of a broader violation: claiming a scope spans "everything" or "every X" without naming the real things inside it. "Across every channel," "in every market," "across the whole funnel," "across the entire org" are the same violation in different words — not a narrower list to memorize, a family to recognize. Test: could you name the 2-4 real things this phrase stands in for? If not, cut the totalizing wrapper and name the specific things.

**Approach-announcement — method-before-demonstration family, not one phrase.** "My approach is..." is one surface form of a broader violation: naming or describing a methodology, depth of engagement, or way of working as a claim, with no specific instance attached. "I go deep on the product," "I take a [X] approach," "I make it a point to..." are the same violation. Test: does the sentence claim a way of working without immediately naming a specific company/artifact/outcome where she did it? Fail: "My approach is deliberately research-first: every deliverable is backed by a thinking process I can stand behind." Fix: "At [Company], I spent the first three weeks interviewing buyers before writing a line of copy." Show it in action; never announce it.

**Contrived tricolons — ban the rhetorical kind, keep real parallels.** A rhetorical tricolon assembled to sound impressive is banned. Parallel lists of real things (including 4-5 part parallels) are the user's style and are welcome. **Test:** was it built to sound impressive, or to list real things that happened? Also banned: the same sentence opening used 3+ times in a row (monotone run).

**[CL] -ing phrases appended after a main clause — max 3 per letter, every one content-bearing.** "Contributing to," "showcasing," "highlighting," "enabling" tacked onto a complete sentence. A tail with real content (a real outcome, a real list) is fine at low count; a decorative tail ("...showcasing expertise") is banned at any count.

**[CL] Unsubstantiated company-character claims and overreach — banned.** Never attribute something documented for only one past role to multiple roles, and never assert a fact about the company's business, culture, or product the user has not sourced from her own words or documented background. A real test overreach: claiming "AI agents doing the execution both times" when only one employer's bullets supported it. Every claim about scope, attribution, or pattern must be checkable against the specific role(s) it's grounded in — not generalized because it sounds better.

---

## [ALL] §4 — Sentence Mechanics

**Passive voice — rewrite active almost always.** Find the passive, ask who did the action, make them the subject. Fail: "The company was acquired by Contoso." Fix: "Contoso acquired the company."

**[CL] Subject-first rule.** Prefer "I" or a named entity as the sentence subject. Archive-consistent ramps (dependent clauses, prepositional openers matching the delivered letters) are the user's register and pass. **Hard ban, no carve-out:** expletive constructions ("There was/is/are") and abstract label noun-phrase subjects ("The founding-marketer part is..."). Fix: "I just finished building [thing] at [Company]."

**Sentence-length variation [ALL].** Mix long and short deliberately — short lands emphasis, long carries nuance. A paragraph that reads monotone — noticeably same-length, same-shape sentences with no variation — needs intervention: break a long sentence in two, fuse two short ones, or land the point in one short sentence. This is a calibration target judged by ear against the delivered letters, not a word-count formula; do not restructure a paragraph that already reads naturally.

**[CL] Sentence-rhythm floor — non-negotiable, not just a calibration target.** At least one sentence ≤8 words AND one ≥25 words must appear somewhere in the body. This is the gatekeeper's Gate 7 rhythm check and the humanizer's own Quantitative Final Gate — a letter with zero short sentences (flat rhythm) is a real, confirmed failure mode that has reached export before. Do not rely on a later stage to introduce this; write it in from the draft.

**Synonym cycling — ban [ALL].** Pick the right word and repeat it. Rotating synonyms to avoid repetition is an AI tell.

**[CL] Copula avoidance.** "Serves as / stands as / acts as" where "is" works. Use "is."

**Filler phrases — cut without replacement [ALL]:** "in order to" → "to"; "at this point in time" → "now"; "it is important to note that" → cut, start with the claim; "due to the fact that" → "because"; "has the ability to" → "can"; "in the event that" → "if."

---

## [CV] §5 — CV Document Shape (correctness, not style)

These define what a passing CV even is. Cutting them changes correctness, not polish.

**Required sections:** `## SUMMARY`, `## SKILLS` or `## SKILLS & EXPERTISE`, `## EXPERIENCE`, `## CONSULTING` (with an "Earlier:" line) when applicable.

**FORBIDDEN sections — hard stop, no exceptions:** `## EDUCATION`, `## LANGUAGES`, `## ADDITIONAL`. These are already in the Word template and formatted correctly — writing them here duplicates them in the final DOCX. The gatekeeper FAILs on any of these headings appearing.

**`## TOOLS` — optional.** Include only when the JD calls out tools or Role Type is Specialist/Builder and the JD discusses tooling. Omit for Leader/Scaler roles regardless of JD content. No tool or technology name of any kind belongs inside experience bullets, ever — not even one named in the JD, not even as illustration. Tool identity lives only in `## TOOLS`.

**`## PUBLICATIONS` — optional, rarely used.** Include only when `background-portfolio.md` documents 2+ published/bylined pieces or original-POV talks AND thought leadership is genuinely relevant to this role's positioning (visible in Role emphasis, the JD, or company culture signals — e.g. analyst-facing, evangelist, or community-facing roles). When in doubt, omit — most CVs never need this section, and the underlying content already works as cover-letter proof (§10) whether or not it appears here.

**`## SKILLS` content rules — a format contract is not a content contract.** Every item in this section must pass a three-way test:
- **Skill (belongs here):** a verb-backed capability she *does* — something she can perform, not something she merely knows about or has been called.
- **Knowledge (does NOT belong here):** a subject-matter area she knows *about* — a domain, a technology category, a regulatory area. Domain knowledge belongs in the Summary or in Role-emphasis framing (sourced from `03-framework.md` §Domain depth), never in `## SKILLS`. ✗ "Cybersecurity | Identity & access management (IAM/PAM) | Non-human identity (NHI)" is a domain-knowledge list, not a skills list.
- **Title/role label (does NOT belong here):** a job title or role descriptor is never a skill. ✗ "Founding Marketer" is a title, not a capability — cut it.

**Cap: 3 skill groups maximum.** Each item appears in exactly one group; groups must be conceptually distinct from each other — run a de-dup pass before returning a draft. ✗ "Cross-Functional Leadership" (Product-Marketing-Sales alignment | Sales enablement | Partner and channel enablement) sitting alongside "Product Marketing & Growth" (Cross-functional work with product, engineering, and data) is the same idea claimed twice under two headings — merge or cut one.

**BlueFont annotation syntax and pandoc custom-style annotations** (RoleTitle, RoleOverview, RoleActivitiesList, RoleActivitySingle, SkillsHeading, Skills, Salutation, Signature Char) — apply exactly as documented in `skills/career-engine-export/SKILL.md`. Output without these annotations produces an unstyled DOCX.

**"Earlier:" line placement.** `## CONSULTING` always comes AFTER the "Earlier:" aggregation line, never before it. Document order: named full-time roles → "Earlier:" line → `## CONSULTING`.

**RoleOverview mandatory for every named role** except the "Earlier:" line — a one-sentence company-context + scope line in italic immediately under RoleTitle. Count RoleTitles and RoleOverviews before returning a draft; they must match.

**Consulting-section placement and completeness.** Any consulting/fractional engagement flagged as requiring a standalone entry in `02-professional-background.md` must appear — never omit an entry flagged mandatory.

---

## [CV] §6 — CV Content Rules (demonstrated failure modes)

**The single-instance trap — most common summary failure.** A summary sentence implies a repeated pattern. If the CV shows the claim only once, the sentence overreaches. **Test, run on every summary sentence:** "Does this imply a repeated competency? How many times does the CV actually show it?" Once → move the specific detail to a bullet under that role; replace the summary sentence with the generalized capability claim. Twice or more across different roles → the pattern is real, the summary can claim it.

**Range language for peaks.** A single absolute number ("a 13-person team," "300% YoY growth") implies that was the sustained state. Use "up to X" when the number reflects a peak or single point in time. Example: "up to 13-person teams" not "a 13-person team," "up to 300% YoY growth" not "300% YoY growth."

**Abstract the roster; carry the scope.** Listing the specific sub-functions of a team ("editorial, technical writing, social, product marketing, field") is bullet-level detail — the summary carries the scale and unified outcome, not the org chart.

**Verb tally — no opening verb 3+ times.** Tally bullet-opening verbs before returning any draft. A real gatekeeper catch: "Built" used 5 times. No verb may repeat 3 or more times across all bullets in the document.

**No verbatim JD phrase-lifting.** Do not lift a 4+ word phrase verbatim from the JD into a bullet. Paraphrase the requirement in the user's documented language; exact-string ATS matching belongs in `## SKILLS`/`## SUMMARY` keyword placement, not in bullet prose copied from the posting.

**Fabrication rule.** Every claim traces to `01-writing-rules.md` and the `background-role-facts-*.md` files. If a claim can't be traced, it does not exist. Consulting/fractional scope must use the correct verb pattern (`01-writing-rules.md` §1) — never overclaim fractional work as full function ownership.

**Bullet formula (XYZ) — for new composition only, when no approved bullet maps to a JD requirement:**
> Accomplished [X — the outcome] as measured by [Y — the metric/proof] by doing [Z — the method].

X is always required. Y is optional when the outcome is specific without a number. Z is optional when the method is obvious. Lead with the outcome, not the action, where possible. Third person, no "I." One bullet, one job. No phrase repeats verbatim across bullets.

**Tailoring and dedupe discipline.** A tailored CV is not the master CV with keywords swapped in:
- Dedupe stats — the same metric earns its place once; if it appears in two bullets, keep the stronger placement and cut the other.
- Combine overlapping bullets describing the same initiative.
- Cut role-irrelevant bullets, even excellent ones, if they don't serve *this* role's mandate.
- Cut priority order when trimming for length: role-irrelevant bullets first, then duplicated stats, then the weaker of an overlapping pair, then wording — never cut the proof the role most needs.

---

## [CL] §7 — Cover Letter Universal Shape (correctness, not style)

**Three blocks, every letter:** Greeting → Opener (1-3 sentences) → Proof (1-3 paragraphs, one job each) → Close (1-3 sentences) → Sign-off.

**Greeting:** exactly "Hi to the [Company] team!" or "Hi to [Name]!" — never "Dear Hiring Manager." Stealth roles (no public company name): "Hi to the team!"

**Word count:** maximum 320 words on the body (excluding greeting/sign-off), no minimum — **except when `Strategy = Strategic`, where the maximum is 250 words.** 270-320 is the typical delivered-letter register for an `IC` or `Hybrid` letter; aim there when content supports it. For a `Strategic` letter, aim for 220-250 instead — the letter argues at organizational altitude rather than stacking IC-level proof, and that argument doesn't need the extra room. This is a round-aware advisory at the gatekeeper (first pass returns to writer; later passes defer to the humanizer), never a hard block past round 1 — the 250 ceiling for `Strategic` follows the exact same advisory mechanics as the 320 ceiling for everything else, just a lower number.

**Paragraph length:** max 3-4 lines per paragraph, then a blank line. The close is always its own paragraph, never attached to the paragraph before it.

**Sign-off:** default "Looking forward to next steps," on its own line, full name on the next. Archive-consistent variation is fine.

**Fabrication rule and personal-content exemption — correctness, not style.** Every claim traces to the user's documented background or her own Why I Want This Role / Motivation Bank words. This is absolute — reviewer feedback never authorizes invention. **The exemption:** content sourced from WIWTR or the Motivation Bank is the user's own voice and personal claim, not "invented" — do not gatekeeper-flag it as fabrication. This exemption does NOT cover CV-repetition (a WIWTR point that restates a CV fact must still be enhanced, not repeated verbatim) — the exemption is about authorship (hers, not invented), not about the separate repetition rule in §8.

**Never repeat CV information — absolute, unconditional.** Restating any fact, metric, credential, or claim from anywhere in the CV — verbatim or in equivalent words — is banned. Three lawful alternatives: **Skip** it (the CV already carries it), **Add** new information traceable to documented background, or **Enhance** (expand with story, context, or decision logic the CV format cannot carry — the CV fact may be named once as the anchor for genuinely new material, never repeated on its own).

---

## [CL] §8 — Cover Letter Opener Doctrine

**The opener rule is a principle, not a template.** Within the first two sentences the reader must know why this specific person is writing to this specific company right now. That context must be non-transferable — it could not appear in a letter to a different company. How it achieves that varies; the Use-Case Structures below are named patterns for a genuinely hard, high-variance task — not a rigid formula.

**Opener source — non-negotiable.** The opener's content and angle come from the user's own words: Why I Want This Role (WIWTR) when present, otherwise the role-matched Motivation Bank entries. Never invented, never derived from the writer's own reading of the JD. Polish for formal writing; do not replace her vocabulary with generic professional language.

**Information Sequencing — professional fit leads, personal proof follows.** The opener earns the reader's attention through professional relevance — the role, the fit, the why-now. Personal details, even highly relevant ones, earn more weight mid-letter once the professional case is already established. Never open with personal attachment, fandom, or biographical detail unless the personal fact is itself the professional credential.

**The test for opener-eligible personal content:** is the personal fact the direct qualification for the role, or is it evidence of passion/affinity? If the former, it may lead. If the latter, it belongs in the body, after at least one proof anchor.

- ✓ **Opener-eligible:** "I've spent 25 years in the Tel Aviv ecosystem" — for a role marketing Tel Aviv. The personal fact is the credential.
- ✗ **Not opener-eligible:** "I grew up cheering for the Orioles" — for a sports media role. Relevant, but affinity is not qualification. Move to body after the professional case is made.

**Never explain personal relevance — that's labeling, cut it.** If a personal detail belongs mid-letter, place it there and let the reader make the connection. Sentences that explain why a personal detail matters ("That's who I am as a fan, and it's also how I think about audience") are labeling — cut them, wherever in the letter they appear, not just the opener.

**Role named in the first sentence — mandatory.** Does not have to lead the sentence, but must be clear and specific.

**Satisfy this jointly with the Subject-first rule (§4) in the same draft — do not write the sentence one way and let the gatekeeper find the conflict.** A real production run took 4 gatekeeper rounds on one letter because the writer fixed "role in sentence 1" in isolation, which broke "her as grammatical subject," then fixed that, which produced a banned cliché ("...was mine the moment I saw it" — see the phrase ban in §2). The two constraints are jointly satisfiable in one pass: keep her as the grammatical subject and name the role as the object of what she wants or reacted to. Fix pattern: "I want the [Role Title] at [Company]..." or "[Role Title] at [Company] is the reason I'm writing..." — not "[Role Title] at [Company] was mine/meant for me" (satisfies role-placement, breaks subject-first in spirit, and risks the banned fit-declaration family in §2). Draft the opener against both rules at once, not one then the other.

**Company name in the first paragraph** (or the stealth descriptor).

**The opener is never:**
- Generic enthusiasm ("I am excited to apply")
- A market observation or industry framing the reader already knows
- An expert claim derived from reading the JD ("I know this buyer")
- A description of the company's own product/positioning back to them
- A methodology announcement
- Anonymous — must name the company or role, not "Reading this posting..."
- Personal attachment/fandom/biographical detail leading before the professional case is made, unless that detail is itself the credential (see Information Sequencing above)

**⛔ Non-waivable carve-out — even when WIWTR echoes JD language.** The opening-paragraph pattern checks (market-framing, setup-before-subject, JD/company language mirroring) apply even when the candidate's own WIWTR notes happen to echo similar phrasing to the JD or the company's public materials. A real hard fail occurred when a writer "faithfully" traced an opener sentence back to WIWTR text that itself echoed a JD tagline — tracing content back to her own words does not exempt it from the pattern check. If her WIWTR phrasing reproduces JD or company-tagline language closely enough to read as mirroring, rewrite it in a way that keeps her substance and angle but does not mirror the source language. "It came from her own words" is never sufficient justification on its own — the pattern check runs regardless of source.

**Analyst-paragraph ban — applies to the ENTIRE letter, not just the opener.** Never describe the company's product/positioning back to them, make a market observation from outside, or announce a capability instead of naming proof ("That's the work I do"). Test: is the user the subject, speaking from her own named experience, or is she describing the company/market from outside? The latter gets cut or rewritten with a company name and outcome.

**Opener Execution Protocol (run before and during writing):**
1. Open WIWTR (or role-matched Bank entries if WIWTR absent/sparse). This is the source — not the JD.
2. Identify the substance: her specific angle, reactions, comparisons.
3. Write a letter paragraph from her notes — not a copy of them, not a full rewrite that erases her voice. Preserve her specific content AND her specific language.
4. **Traceability test:** can every sentence be traced to a word, phrase, or reaction she actually wrote? If not, delete it or fall back to the Bank.
5. **Context gate:** after writing the opener, ask — could this paragraph appear unchanged in a letter to a different company? If yes, it has not set context; rewrite before writing a single body sentence.

**Sparse notes are not a gap to fill.** Do not expand a one-sentence WIWTR into a full invented paragraph. Check the Bank first. If nothing usable exists anywhere, write `[{{USER_FIRST_NAME}} TO FILL IN]` — this is the correct outcome, not a failure to paper over. (The genuinely-empty case — no WIWTR AND no relevant Bank entry — is caught upstream by the Sufficiency Gate, which skips the role.)

**Two failure modes on opposite ends — both are real, both recur:**
- **Failure mode A — verbatim paste.** Transcribing WIWTR nearly word-for-word into the opener. Her notes are not a paragraph; copied raw, they read abrupt and out of context.
- **Failure mode B — full rewrite.** Extracting only the topic from her notes and writing entirely fresh sentences in polished professional language that erases how she actually said it. This is not better than Failure mode A — it is the same failure in the opposite direction; the result carries none of her voice.

The fix for both: read her actual words (WIWTR and the role-matched Bank entries), understand what she's saying AND how she's saying it, then write a letter paragraph that says it well in her words — shape the structure, preserve the language.

---

## [CL] §9 — Use-Case Structures for the Opener

Named patterns for the opener paragraph. Fill the bracketed slots with the user's actual content — nothing stays as-is from the template. Pattern names in brackets are internal labels only; never write them into the letter.

1. **Direct parallel** — most recent role overlaps this one directly. Move: reaction to the coincidence → causal fragment landing the credential ("Because I was just doing it — as [role] at [Company]...").

2. **Unfamiliar domain (transfer argument)** — role needs domain experience she lacks, but the underlying skill transfers. Move: lead with the transferable skill and breadth evidence → name the connecting insight (what stays the same across domains) → map to this company. Never name the gap.

3. **Compliance/regulated buyer** — risk-mitigation-first buying motion (healthcare, cyber, fin services, defense). Move: name the real buyer insight plainly → name one thing built in response → land the application in one sentence.

4. **PLG/product-led role** — self-serve or developer-led adoption is the mandate. Move: genuine passion statement → first exposure → range (success and failure) → substantive insight (what she knows now).

5. **Function-builder close** — founding-hire or build-from-scratch mandate. Minimum three-sentence close, all mandatory: scope claim → emotional sentence → company landing ("I've built X from scratch. I loved it every time. I'd love to build it at [Company].").

6. **Multi-domain pattern** — needs to show the same underlying problem recurred across companies. Either: (A) horizontal competence claim (lead with the competence, ground with breadth, name what's consistently true), or (B) rapid-fire list (one clause per company, then the connecting insight).

7. **Proof bullets that earn their place** — 2-3 metric-backed outcomes land harder as a short list than prose. A confident setup line earns the list. **Bullets are appropriate in exactly two situations: a transferability/pivot letter, or a multi-mandate role requiring visible range.** Format: 2-5 words each, no periods, parallel form, positioned between proof and close. JD-language mirroring is fine and deliberate in this bullet list only — the whole point is showing the mapping; this exception does not extend to prose anywhere else in the letter.

8. **Warm connection/referral** — she has spoken to someone at the company or has a referral. Move: name the person and context in one sentence, move immediately to proof.

9. **Anticipated question** — an obvious hesitation exists (domain gap, seniority mismatch). Move: name the reader's likely question directly, without apology → answer immediately with named proof.

10. **Problem-first (observation opener)** — she has a genuine professional observation about a recurring problem, and this role is the next instance of it. **The observation must itself be sourced from her documented WIWTR/Motivation Bank content — a reaction she has already articulated — never constructed from the writer's own reading of the JD, the company, or the market.** This is the same §8 sourcing mandate, not an exception to it: an analyst-style claim about "the problem underneath" a role, dressed up as her observation, is exactly the violation §8 already bans. If no such documented observation exists, this pattern is not available for this letter — use a different Use-Case Structure, or defer to the Sufficiency Gate. **The user must be the grammatical subject of the first sentence** — opening with a market-category claim ("So many marketers...") is a hard fail. The observation is supporting context in sentence 2 or 3, after she is established as subject.

11. **Value claim opener** — the most natural default. Move: name the company/posting → observe what they need → pivot to a confident value claim in her own voice ("It sounds like you're looking for me! I'm a strategic builder...") → name HOW in one clause → thread the domain connection → close warm and confident. The user is the subject by the second sentence at the latest. **When a required voiced phrase like "strategic builder" is part of the source material for this opener, it must survive every revision round — a real whack-a-mole failure dropped it mid-revision; a targeted fix to one flagged sentence must never silently delete a phrase that was correct and required.**

---

## [CL] §10 — Cover Letter Claims and Framing Rules

**Strength first — never volunteer scope or qualifications.** Different domains, verticals, or engagement types are never framed as a gap, weakness, or limitation. Forbidden: "one product, not a portfolio," "smaller than the rest of my CV," "narrower than full-time." Lead with what transfers.

**The twist as a narrative tool.** A background gap is a story to tell, not a weakness to manage: name the unexpected credential, name what it proves, name why that's exactly what this role needs.

**JD-dimension mirroring — forbidden in prose,** except inside a transferability bullet list (§9.7), where it's the point.

**Managed-vs-executed.** Credit management and ownership, not personal execution, when the user managed a team: "Oversaw analyst relations," not "ran analyst relations personally."

**Temporal motivation hedges — forbidden.** "The seat I want most right now," "at this stage of my career" — cut any phrase implying "...as opposed to what I'll want later." Genuine motivation needs no time qualifier.

**Future-outcome commitments — avoid; past outcomes are proof.** Never commit to a result she'd own before ramping ("I'll lift activation 20% in 90 days") — that hands the reader a number to hold her to. Documented past outcomes are fact and belong in the letter; promised future outcomes do not. Write how she thinks about the problem, not what she guarantees.

**Interview-trigger gaps** (from recruiter review, when passed): address proactively only where WIWTR or documented background gives a real answer, woven into the narrative — never as Q&A. Fabrication rules always override — a reviewer flag never authorizes invention.

**Proof-point partitioning — run before drafting.** The CV is written first and spends the strongest documented proof (summary claims, bullet outcomes, metrics). Before selecting the letter's proof, list what the CV already spent. The letter's proof comes from what the CV does NOT carry: the detail layers in the role-facts files, adjacent engagements, the story or decision logic behind a bullet, testimonials, portfolio artifacts. If every documented proof point is CV-spent, enhance the strongest one (the story behind it) rather than importing a restatement.

**Published/bylined writing and original-POV talks are unusually strong letter proof — prefer them when a qualifying one exists.** Unlike most portfolio artifacts, a publication or a talk where she originated the point of view is rarely CV-spent (a CV bullet almost never cites one verbatim), so it's genuinely fresh information the reader hasn't already seen elsewhere in the application — not a restatement dressed up differently. When `background-portfolio.md` has a relevant published piece or talk for this role, prefer it over a restated CV-adjacent portfolio item.

**Discarded and unreadable input is always surfaced — never silent.** When the fabrication rule sets aside a piece of the user's own input, or any input is uninterpretable (garbled text, a directive referencing content that no longer exists): exclude it from the letter, log it in the revision log, and surface it in the final delivery as a named ask-back — she can only fix what she can see.

---

## [CL] §11 — Cover Letter Self-Check (run before returning any draft)

**Top 3 — check first, these caused the real 7-round loops:**
- [ ] Zero em dashes — search for `—`
- [ ] No contrived tricolon; no 3+ repeated sentence openings
- [ ] Max 3 content-bearing -ing appendages; zero decorative ones

**Structure:**
- [ ] Greeting exactly "Hi to the [Company] team!" / "Hi to [Name]!"
- [ ] Word count ≤320, or ≤250 if `Strategy = Strategic` (excluding greeting/sign-off), counted via `wc -w` on the body text — not estimated
- [ ] Role title appears using exact JD phrasing
- [ ] Every proof paragraph does exactly one thing — nothing restates a CV bullet
- [ ] No paragraph over 4 lines; close is its own paragraph

**Opening (run first):**
- [ ] Traced to WIWTR or role-matched Bank entries — not the JD, not coach output
- [ ] Role named in the first sentence; company named in paragraph 1
- [ ] First sentence does not make a market/industry/role claim before the user appears as subject
- [ ] Not anonymous ("Reading this posting..." with no company/role named)
- [ ] Passes the non-waivable JD-mirroring carve-out (§8) even if traced to WIWTR

**Fabrication traps:**
- [ ] No scope, attribution, or seniority claim undocumented in `01-writing-rules.md`/`02-professional-background.md`
- [ ] No fractional/consulting work described as full function ownership
- [ ] No numeric claim untraceable to reference files
- [ ] No expansion of sparse WIWTR into invented paragraph — Bank checked first, `[USER TO FILL IN]` only if Bank adds nothing

**Forbidden structures:**
- [ ] No scope-volunteering or qualification framing
- [ ] No antithesis/pivot formula
- [ ] No analyst paragraph anywhere in the letter body
- [ ] No manufactured opener hook; no expert-claim/strategy-analysis opener

**Content:**
- [ ] Every sentence adds something not in the CV, or expands compellingly on something the CV can't carry — otherwise cut it
- [ ] No CV fact repeated (verbatim or equivalent words) anywhere in the letter
- [ ] At least one specific number or named outcome
- [ ] No overreach — no claim generalized across roles beyond what's documented for each

**Gut check:**
- [ ] Does the first sentence sound like a person, not a form letter?
- [ ] Does it sound like the candidate, calibrated against the delivered letters?
- [ ] Redundancy pass: does paragraph 2 or 3 restate paragraph 1? Cut or compress.

---

## [ALL] §12 — Positive Writing Standards

- Direct statements without hedging; specific details, not abstractions
- Concrete examples and named outcomes; active voice and clear causality
- Trust the reader's intelligence; show expertise through specifics, never through labels
- Specific company names, numbers, and named outcomes — never generic claims
- Name the mechanism behind why something worked, not just that it worked
- One good example beats three paragraphs of argument

**Verbatim-preservation principle.** If the user's own words already say something well — in career-data, in WIWTR, or in a previous delivered letter — reuse them directly. Do not paraphrase, "clean up," or synthesize a smoother version, the same discipline already mandated for the Motivation Bank. This is a positive instruction, not just a permission: reusing exact phrasing that already worked isn't merely allowed, it's actively better — the sentiment lands more convincingly, and the user is far more likely to recognize the syntax as genuinely her own. Actively pull proven phrasing from the delivered-letters archive when it fits a new letter, rather than reworking it into something new because it happened to appear elsewhere already. Verbatim reuse across letters is not a defect — writing every letter from scratch is exhausting, and reusing proven, working phrasing is efficient.
