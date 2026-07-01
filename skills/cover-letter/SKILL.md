---
name: cover-letter
description: Apply the user's voice, tone, and writing identity when writing a cover letter for the user, applying for jobs and/or opportunities. Use this skill whenever the user asks to write, edit, review, or improve any professional content designed for generating income - consulting proposals, Fiverr service descriptions, and especially cover letters for the purpose of cold outreach. Also use when she asks to draft any content of this kind "in my voice" or "the way I'd say it." If the content is meant to represent the user as an individual professional seeking opportunities for new income, this skill applies.
---

# Cover Letter Skill

> **Letter pipeline file.** Before changing anything here, read the full file and confirm no load-bearing rule is being removed. Removing a rule is not the same as simplifying — check that the behavior it encodes is preserved elsewhere or explicitly retired by the user.

The authoritative source for cover letter mechanics, structure, and use-case patterns. Write the letter first — then use this file to check it.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `job-preferences.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

---

**Note:** `cv-writing` skill does NOT apply to cover letters. Cover letters are held to different, looser standards on tone.

**Prohibited content:** Syntax and AI-pattern rules are defined in the Mandatory Revision Pass section of this skill file. Fabrication traps, strategic forbidden structures, opening source rules, and voice vocabulary bans are defined in `references/cover-letter-self-check.md`.

**Voice profile:** The user's voice description is in `references/01-writing-rules.md` Section 5.

---

## The Letter as a Positioning Exercise

At its core, writing this letter is a positioning, messaging, and strategy exercise. The user is the product. The hiring manager is the buyer. The JD is the brief. The letter is the positioning document.

**Positioning** means taking a specific, chosen stance: who the user is *for this role*, against the implicit alternatives, on the dimension of value this particular HM cares about. Position is selected, not described. A letter that tries to cover everything has no position.

**Messaging** means selecting which true things to say and in what order. The same proof points land differently depending on who's reading. Messages are chosen and sequenced for *this* buyer, not for the general case.

**Strategy** means the letter has an argument with an arc: what leads, what it builds toward, what the reader should believe — and want to do — after the last line. Every structural decision is a strategic choice.

---

## What the Letter Must Do

**Unique fit — not generic competence.** The CV lists what the user can do. The letter makes the case that her specific background is non-generically right for this company's specific problem, right now. Test: could this letter have been sent to a different company without changing a word? If yes, it is not a cover letter yet.

**Personality and soft skills — through proof only.** CVs are blunt instruments for character. The letter is where judgment, curiosity, adaptability, and working style become visible — but only through proof. "I'm adaptable" is noise. A story about a cancelled initiative, a pivot, a hard call — that is a story about adaptability. Show; never claim.

**Context the CV cannot carry.** A bullet point states an outcome. The letter explains what it required — what the user learned, what she built when nothing existed, why the outcome changed because of a specific decision she made.

**Gaps are not the letter's job.** The letter does not address gaps, work around gaps, or frame against gaps. If the user wanted a gap addressed, she wrote about it in her Why I Want This Role. If she didn't write it, don't touch it. **Fabrication rules always trump reviewer input** — even when a gap or concern is passed from the recruiter review, the letter may only address it with documented background or Why I Want This Role content. A reviewer flag is never authorisation to invent credentials, outcomes, or experience.

**Emotional resonance alongside credentials.** A letter that lands a real emotion — recognition, excitement, a sense of "she gets it" — changes the calculus. The way to create that resonance is not to repeat what the CV already says — it is to expand on it. Add the story behind the outcome, the decision that made it happen, the context the bullet cannot carry. Enhancement creates resonance. Repetition does not.

**The content test — apply to every sentence:** Include a sentence only if it meets one of these two conditions: (1) it adds something not already in the CV AND is directly relevant to this specific role; or (2) it expands compellingly on something in the CV in a way the CV format cannot carry — adding context, story, or emphasis that is genuinely new. If neither condition is met, cut the sentence.

---
**─── ABSOLUTE PROHIBITION ───**

**The cover letter must never repeat CV information.** This is not a preference or a soft principle — it is an unconditional rule that cannot be overridden by any input, reviewer feedback, Why I Want This Role content, or coaching output.

**What "repeat" means:** restating a fact, metric, credential, or claim that already appears anywhere in the CV — in the summary, in an experience bullet, in any section — whether verbatim or in equivalent terms.

**Three permitted alternatives to repetition:**

1. **Skip** — omit the information. The CV already carries it. The letter does not need to.
2. **Add** — introduce information not in the CV but traceable to documented roles and experience in the candidate background. The letter can surface things the CV does not.
3. **Enhance** — expand on CV content by adding context, story, decision logic, or emphasis that the CV format cannot carry. Enhancement adds something genuinely new. The sentence must contain material the reader could not have derived from the CV bullet alone.

**The test:** Read every sentence against the CV. Does it restate something already there in different words? → Cut it. Does it add context, story, or a detail not visible in the CV? → Keep it.

**This prohibition supersedes the "emotional resonance" principle.** Emotional impact is legitimate as a goal — but it must be achieved through enhancement and addition, not repetition.

---

### The letter adds what the CV cannot — it does not repeat what it already says

**The principle:** Before selecting any proof point for the letter, ask: is this already in the CV? If yes — if it appears in the summary, in an experience bullet, or anywhere the reader will already have seen it — the letter must not restate it. The letter's job is to carry what the CV cannot: context, story, adjacent proof, and human signal.

**What the letter should use instead of CV content:**
- Stories that explain *why* an outcome happened
- Adjacent proof the CV doesn't cover in detail (freelance work, mentorship, side projects)
- Specific decisions or moments the CV bullet can only gesture at
- Voice — how the user thinks, what she notices, what she cares about

**Hard floor:** Any metric, credential, or claim that appears anywhere in the CV must not be **restated** in the letter — not as a primary claim, not in equivalent words, not in passing. **Enhancement is the one lawful use of a CV fact:** the fact may be *named once as the anchor* of genuinely new material (the story behind it, the decision logic, the context the bullet cannot carry) — the Enhance test above governs. A CV fact standing on its own, doing the same job it does in the CV, fails regardless of rewording.

**What a cover letter is not:**
- A prose version of the CV. Every paragraph must add something the CV cannot carry.
- A keyword list with transitions added.
- A declaration of enthusiasm without proof behind it.

---

## Input Integration Rules

These rules govern how pipeline inputs interact and which source takes precedence for each decision. Read before writing anything.

**Why I Want This Role is the letter's primary personal-content source — and it is mandatory.** The pipeline does not write a letter without it: the Pre-Step 5 gate skips the letter entirely when the field is empty, and it is the sole source for the opener. Everything *must* appear somewhere in the letter. Whatever IS used must comply fully with every rule and prohibition in this skill. However, the order of the information provided must be according to all rules, prohibitions, and mandatory components and structures. Do NOT blindly copy/paste the user's input - not in the same order nor necessarily with the same exact wording. If something the user wrote in Why I Want This Role would produce a bad opener, violate the analyst paragraph ban, break a framing rule, or fail the context gate, set that piece aside — but place it elsewhere in the letter where it fits. The rules always win on placement and form; they never license dropping a point.

**The integration model:** Coach output sets the frame — `Strategy` fixes the letter's structural type (`IC` / `Strategic` / `Hybrid`; see Letter Type below), and the coach context block (the Priority lines prepended to Why I Want This Role) plus Gap handling define what the letter must accomplish. Why I Want This Role is the source of voice, angle, and raw material — used only where the content is genuinely usable and compliant. A letter that follows the frame but ignores Why I Want This Role sounds like a template — but a letter that forces unusable Why I Want This Role content into a compliant shape is worse than either.

**The integration rule:** Read `Strategy` first to fix the letter type, then read the coach context block to understand what this letter needs to accomplish. Then read Why I Want This Role to find the user's voice, her specific angles, and her raw content. Write the letter so her own words are doing the strategic work the coach identified.

**Opener source — non-negotiable.**
Why I Want This Role is the sole source for the opener's content and angle. The user's genuine reaction to the role, her specific angle on this company, and the raw material she wrote goes first, in her voice — polished to be appropriate for formal writing, but not replaced with generic professional language. The Use-Case Structures tell you how to frame it — not what to say, not in what order, not in which paragraph. Take the user's input and place each part where it best serves the Use-Case Structure you choose.

**NEVER open with strategy analysis.** No market observations, no industry framing, no role-stakes setup, and no expert claims derived from reading the role — regardless of whether the user is the grammatical subject. "I know this buyer" is strategy analysis. "I understand this buying motion" is strategy analysis. If she didn't write it, it doesn't belong in the opener.

**NEVER open with a plan.** "My first priority at [Company] will be..." / "The first thing I'd do is..." / "Before writing a word of copy, I'd..." — these describe what you'd do if hired, not why you're writing. They answer the wrong question. Plans and approach descriptions belong in the body. The opener answers: why is the user writing to this company right now?

**When Why I Want This Role mirrors the CV.** Sometimes her proudest story IS a CV bullet, or her written motivation restates CV facts. Her voice and angle still govern the opener — but the CV-repetition prohibition is not waived by the personal-content exemption (that exemption covers voice and personal claims, not duplication). Resolution: keep her framing and vocabulary, and write the *enhancement* of the fact — the why, the story, the decision — rather than the fact itself. If a piece of her content cannot be used without restating the CV, use its angle, not its words, and log the set-aside.

**Beyond the opener — use all of it, throughout.** Why I Want This Role is the sole source for the opener, but it is NOT confined to the opener — and the opener is not its only job. Leverage it across the entire letter: wherever a piece of her content fits the structure — a proof paragraph, a transition, the close — work it in.

**MANDATORY: every distinct point the user wrote in Why I Want This Role must appear somewhere in the letter.** Not thematically covered — actually present. The integration mechanism:
- Before drafting: parse Why I Want This Role into a numbered list of distinct points (each bullet, sentence, or idea is one point). Store as [WIWTR-1], [WIWTR-2], etc.
- After drafting: verify each [WIWTR-N] is substantively present in the letter. "Thematically covered" does not count — the actual substance of the point must appear.
- Syntax can be fixed, placement can vary, length can be adjusted — but the point itself cannot be dropped.
- The ONLY exception: a point that fails the fabrication rule (it claims something not in the user's documented background) may be set aside. Log it explicitly as a set-aside with reason.
- A point that is syntactically awkward, off-strategy, or redundant with another paragraph is NOT exempt. Fix it, place it, integrate it — but include it.

Wherever her content is in play, default to her tone and vocabulary over polished alternatives. Integration must be logical — place each piece where it does real work for the letter, never bolt it on just to hit coverage.

**Proof-point partitioning — run before drafting.** The CV and the letter draw from the same documented background, and the CV is written first — so list what the CV already spends (summary claims, bullet outcomes, metrics) before selecting the letter's proof. The letter's named proof comes from what the CV does NOT carry: the detail layers in `02-professional-background.md` §7 ("What you built / delivered" runs deeper than any bullet), adjacent engagements, stories and decision logic behind the bullets, §9 testimonials, §10 portfolio artifacts. If every documented proof point is CV-spent, enhance the strongest one (story behind it) instead of importing a restatement — and a named non-numeric specific (deliverable, methodology, artifact) satisfies any need for concreteness when all numbers are CV-spent.

**Why I Want This Role governs proof selection.** Which outcomes to lead with, what the proof paragraphs need to demonstrate — this comes from the user's WIWTR content. If the coach prepended a context block (above the `---` separator), treat it as directional framing; treat everything below the separator as the user's voice and content source. If the story is interesting but misses a coaching cue, include it where it fits — setting a piece of her content aside entirely is a last resort, reserved for content that is non-compliant or genuinely unusable.

**Discarded and unreadable input is always surfaced — never silent.** When the fabrication rule sets aside a piece of the user's own input (a claim not traceable to her documented background), or any input is uninterpretable (garbled tokens like a stray "cfx", instructions referencing text that no longer exists, degenerate properties): exclude it from the letter, log it in the revision log, and surface it in the final chat delivery as a named ask-back — "Set-aside personal input for [Company]: '[fragment]' — confirm it, correct it, or add it to 02-professional-background.md and re-run." She can only fix what she can see.

**Do not reference the hiring company's positioning.** Do not analyse, describe, or comment on the company's positioning, public messaging, or how they frame their product in the market — anywhere in the letter. This includes indirect references ("a company that gets the importance of X"), framing that implies you've studied their positioning, and any sentence where the user reads as an observer of their market strategy. When in doubt, cut it.

---

## Letter Type

Every letter is one of three structural types, set by the `Strategy` Select value the career coach writes. The mapping is exact:

| `Strategy` value | Letter type | Central question the HM is asking |
|---|---|---|
| `IC` | Type 1 — Team member / Specialist / Builder | Can this candidate do the work? |
| `Strategic` | Type 2 — Senior / Executive / Strategic | Is this the right person to lead this organization? |
| `Hybrid` | Hybrid — Strategic + Builder | Both — can they lead *and* do the work? |

Read the `Strategy` value to determine type. If the field is empty, determine from the coaching context block in `Why I Want This Role` (the block above the `---` separator, if present) or infer from Role emphasis. All three types follow every other rule in this skill unchanged — fabrication guards, opener sourcing, CV-repetition prohibition, and word count apply equally. What changes between types is the central argument, the credential scope (deliverable level vs. function-ownership level), and the body-paragraph sequence below.

**Type 1 (`Strategy` = `IC`) — Team member/Specialist/Builder**

Use when the role's mandate is primarily individual execution: build this function, do this specific work, demonstrate technical or domain depth. The hiring manager is evaluating whether the candidate can perform the work — not whether they can lead an organization.

**Central argument:** I have exactly the skills and experience this role requires.

- **Opener:** Genuine reaction + immediate capability claim or domain match. Energy and specificity. ("I do both!")
- **Body:** Proves the claim at deliverable and domain-fluency level — named companies, specific things built, technical fluency demonstrated, concrete outputs. Every paragraph adds something the CV can't carry about specific execution.
- **Close:** Forward-looking about the specific work she'd do here.
- **Credential scope:** Deliverable and domain level. "I built the founding PMM function at X" / "I speak Kubernetes fluently."

**Type 2 (`Strategy` = `Strategic`) — Senior/Executive/Strategic/Strategic IC/IC in an enterprise environment**

Use when the role's mandate is organizational leadership, function ownership, cross-functional influence, or strategic direction — and the hiring manager is evaluating whether the candidate thinks and leads at the right altitude, not primarily whether they can execute specific deliverables.

**Central argument:** I believe I’m the right person to lead this organization. My professional ethos will support the organization.

- **Opener:** Same rules as Type 1 — personal reaction, Why I Want This Role as sole source. If provided in WIWTR, the user's reaction may center on *why she believes in the organization* or her long-held conviction about the domain, in addition to capability match.
- **Paragraph 2 — Strategic POV + identity claim:** Stakes a conviction about what the role or function genuinely requires — from her point of view as someone who has owned it — AND claims that identity. "I know that X and Y go hand in hand — and I'm [identity]." This is earned conviction, not analyst commentary about the company.
- **Paragraph 3 — Function-level credentials:** Proves the conviction at organizational scope. Disciplines owned ("led positioning, messaging, technical documentation, thought leadership"), cross-functional influence, commercial impact at scale. Not individual deliverables — the function as a whole.
- **Paragraph 4 — Organizational differentiator:** Evidence that she thinks at organizational altitude. A product she built, a decision she made, an approach she took — framed through the buyer's or organization's challenge, not through her skill set.
- **Close — leadership identity:** Who she is as a leader and steward of the function. Team development, future contribution, organizational identity — not just task enthusiasm.
- **Credential scope:** Function ownership level. "I've led [disciplines]" / "influenced millions in pipeline."

**Hybrid (`Strategy` = `Hybrid`) — Strategic + Builder**

Use when the role requires both organizational leadership AND specific IC execution — a Director who also does the work, a founding senior hire who will set direction and build, a Head role at a company where the mandate is both strategic and craft-level. The hiring manager is evaluating leadership judgment AND demonstrated execution capability.

**Central argument:** I believe I’m the right person to lead this organization AND I am an expert at this kind of work.

- **Opener:** Same rules as Types 1 and 2. The reaction may blend both — responding to the company/mission (Type 2 register) and to the specific craft challenge (Type 1 energy).
- **Paragraph 2 — Strategic POV + specific deliverable:** Stakes a conviction about the domain, then grounds it immediately with a specific named deliverable or technical proof point — not just function ownership. The move: "I know that [X] — here's the specific thing I built that proves it."
- **Paragraph 3 — Function-level AND craft credentials:** Demonstrates both the function owned AND specific things built within it. "I led [function] — and within that, I built [specific thing that shows craft depth]."
- **Paragraph 4 — Execution differentiator:** A specific IC output that demonstrates craft, domain depth, or hands-on capability at the level the role requires. Shows she can do the work, not just lead it.
- **Close — leadership + builder identity:** Stakes both who she is as a leader AND her enthusiasm for the craft. Not just "I am a strategic leader" but "I build what I lead."
- **Credential scope:** Both function ownership AND specific deliverable level, present in the same letter.

**The key distinctions:** Type 1 answers *why can she do this work?* Type 2 answers *why is she the right leader for this organization?* Hybrid answers both. A Type 2 letter written at Type 1 altitude underpositions a senior candidate. A Hybrid written in pure Type 2 mode undersells the execution capability the role needs.

---

## Writing Mechanics

**Before writing a single word — this step is MANDATORY and must NEVER BE SKIPPED:** Open ALL delivered letters from `${CAREER_DATA}/references/delivered-letters/` — read every file in the archive, not just 2–3 — AND the voice fingerprint in `03-framework.md` §Voice fingerprint. Read them for three purposes:

1. **Voice calibration** — sentence patterns, paragraph openers, rhythm, punctuation habits. Your draft must mirror them.
2. **Content mining** — proof points, phrasings, or framings that worked and could apply here. Approved content from past letters is fair game.
3. **Structure and syntax** — the balance of short and long sentences, the use of bullets, the paragraph structure, and the way they framed their openers and closes.

**If the delivered-letters archive is unreachable (path invalid, permission error, career-data absent):** hard stop — do not write. Report the failure. This is not a fallback trigger.

**If the archive exists but is genuinely empty (count = 0 AND no letter files present):** fall back to `references/03-framework.md` §Voice and tone for voice calibration. Note in the revision log: "Delivered-letters archive is empty — voice calibrated against 03-framework.md §Voice and tone."

**The full syntax rule list lives with the humanizer agent**, which runs after you. Your job is to write a strong, honest letter. The humanizer's job is to fix the language. Trust the division of labour: you focus on strategy and content, not on policing every sentence structure.

That said — these principles will keep you out of the most egregious patterns:

### Drafting principles

**Always:**
- "I" or a named entity as the subject — the drafting default. Archive-consistent ramps (dependent clauses, prepositional openers, as in the delivered letters) are the user's register and are fine. Never an expletive ("There was/is") or an abstract label noun-phrase subject ("The X part is...")
- Complexity after the verb, not before it — via appositive or short follow-on sentence
- Vary sentence length deliberately. Short sentences land emphasis. Longer ones carry nuance.
- Specific company names, numbers, and named outcomes. Never generic claims.

**The top 3 — treat these as absolute during drafting:**
1. **Zero em dashes.** Use a period or comma instead. Every time, without exception.
2. **Rule of three: don't build contrived tricolons.** Parallel lists of real things are the user's style and are welcome. What's banned is the rhetorical tricolon assembled to sound impressive rather than to list real things, and reusing the same sentence opening three or more times in a row. The humanizer will catch any you miss.
3. **-ing phrases appended to a main clause: three per letter maximum, every one content-bearing.** A tail that lists real things or states a real outcome is fine; a decorative tail ("...showcasing expertise," "...highlighting my ability to...") is banned at any count.

**Composition lens — What you bring vs. How you work:** During drafting, hold these two things separately. *What you bring* is the credential layer — named companies, outcomes, numbers, specific deliverables. This is the "why pick me" content. *How you work* is the methodology layer — the user's research-first approach, operating philosophy, the frameworks in `references/03-framework.md` §Professional methodology and POV. Both belong in the letter body but do different jobs and should not be collapsed into the same paragraph. Credentials prove she can do the work. Methodology signals how she thinks — which is what seniority looks like on paper.

**For senior roles especially:** Hiring managers evaluating Director, Head, or VP candidates are not primarily looking for credential lists — they are evaluating whether the candidate thinks at the right altitude. A letter that primarily focuses on how the user approaches the function (methodology, conviction, diagnostic discipline) signals seniority more clearly than a letter that stacks company names and outcomes. When a role is senior, look to `03-framework.md` §Professional methodology and POV before credential paragraphs.

**Half the words, twice the examples.** If a paragraph makes a claim, cut half the claim and replace it with a specific named example. Density of proof beats length of argument every time. A three-sentence paragraph with two named companies and a number beats a six-sentence paragraph making the same point in generalities.

**Frame as judgment, not as promised outcomes — protect the user from KPI traps.** A letter that commits the user to a result she would own *before she has ramped* ("I'll lift activation 20%," "I'll rebuild the funnel in 90 days") hands the reader a number to hold her to and a reason to doubt her, since no one can predict that result from outside. Write how she *thinks* about the problem — her approach, her diagnostic discipline, the questions she would ask first — not the outcome she guarantees. The distinction is tense: *past* outcomes that are documented and already achieved are proof and belong in the letter as fact; *future* outcomes are commitments and do not. This matters most in operating-model transitions and senior roles, where the honest, more senior-sounding position is "here is how I would approach this," not "here is what I will deliver by Q2." Naming an approach is not the banned approach-*announcement* label (that is naming a methodology instead of showing it) — show the thinking through a specific past example, then let the reader infer how she would work.

**One example, one appearance per application.** If you've already used an example in the letter, don't use it again. If an example already appears in the related CV, don't reuse it in the letter unless the letter adds context the CV doesn't have.

**Opener rule — non-negotiable:**
FIRST AND FOREMOST, AND COMPLETELY MANDATORY AND NON-NEGOTIABLE: The first sentence must name the role the user is applying for. The role does not have to lead the sentence, but it must be clear and specific. The opener MUST express the user's genuine reaction to this specific role, based solely on Why I Want This Role — her actual tone, vocabulary, and phrasing, polished for formal writing. If Why I Want This Role is empty or too sparse to write from, write `[{{USER_FIRST_NAME}} TO FILL IN]`. Do not construct an opener from your own reading of the JD. Do not write strategy analysis, expert claims, or methodology descriptions as openers.

---

**Voice permissions (not rules — use when warranted):**
- Self-correction mid-letter when the company earns it: assertion → pause → correction. Never manufactured.
- "I'll be honest" only when the JD or company tone signals informality is welcome. Never for enterprise or formal contexts.

**Naming requirements:**
- Company name in the first paragraph, ideally the first two sentences. **Stealth roles** (no public company name — Company Stage `Stealth` or a placeholder company): the JD's own descriptor ("your agentic SecOps platform," "this stealth ISR team") satisfies this — never invent a name, and the greeting becomes "Hi to the team!"
- Role title somewhere in the letter, using the exact job description phrasing — and named in the first sentence per the Opener rule.

---

## The Letter Structure {#structure}

The CV shows what the user did. The cover letter shows **why** this company, **why** this role, and **what** the CV cannot say. If a paragraph could be replaced by pointing to a CV bullet, it should **not** be in the letter at all. Every sentence must add something new — a perspective, a reaction to something in the JD, or a story that proves a claim the CV only states.

**The core principle for every opener:**
An analyst describes the market. A candidate tells you what the opportunity did to them when they read it, then demonstrates why they're credible to have that reaction. The user is always the candidate — never the analyst.

### What paragraph 1 must do

The opener has one job: within the first two sentences, the reader must know exactly why this specific person is writing to this specific company right now. That context must be non-transferable — it could not appear in a letter to a different company.

How it achieves that varies. Delivered letters have used:
- A genuine emotional reaction + the credential that earns it ("I nearly screamed when I saw this role. Because I was just doing it at [Company]...")
- An existing relationship ("I've worked for [Company] already when I was freelancing...")
- A personal tension that explains the application ("I daydream about consumer campaigns. I've spent 15 years in B2B...")
- A value claim that names their mandate and pivots to the user's answer ("You're looking for a strategic builder — that's the work I do.")
- A warm connection that sets human context first ("Thanks for the [prior conversation]...")

There is no required sentence count and no required sequence. The only test: finish reading the opener and ask — does the reader now know why this person, why here, why now? If not, rewrite it.

**The opener is never:**
- Generic enthusiasm that could apply to any company ("I am excited to apply")
- A market observation or industry framing the reader already knows
- An expert claim derived from reading the JD ("I know this buyer," "I understand this motion")
- A description of the company's own product or positioning back to them
- A methodology announcement ("My research-first approach means...")
- **An anonymous opener that doesn't name the company or role.** Phrases like "Reading this posting," "When I saw this role," "This opportunity," or "This position" leave the reader without context — they don't know what the user is responding to. The opener must name the company, the role title, or both. "Reading [Company]'s [Role Title] posting" sets context. "Reading this posting" does not.

### Opener Execution Protocol

Run this before and during writing the opener. It is not a post-draft check — it governs composition itself.

**Before writing the first sentence:**
1. Open **Why I Want This Role** for this role. This is the sole source for the opener — not the JD, not coach output. The opening sentence must be explicit and give the hiring team immediate context for why the user is writing to them.
2. Identify the substance: what angle did the user take? What specific reactions, comparisons, or ideas did she provide? What is she actually saying she wants from this role?
3. Your opener must express that angle and those ideas — not a different framing you derived from reading the JD, and not a generic opener that could fit any application.
4. **Why I Want This Role is raw material — not a draft paragraph.** It is notes: first-person, often unpolished, written to herself. Your job is to write a paragraph from it, not to copy it. Extract the angle, the specific reaction, the thing she's saying — then write a letter paragraph that expresses that. The paragraph should sound like a letter, not like her notes.
5. Preserve her specific content AND her specific language. The comparisons she drew, the aspects she named, the reactions she expressed — and the words she used to express them. Where her phrasing can function as letter language, carry it forward. Do not replace her vocabulary with polished alternatives. Do not invent new reactions she didn't write. Do not replace her substance with analysis of the JD. Do write it — craft sentences, create flow, ensure it reads as a coherent opening paragraph — but shape the structure, not the words. The result should be recognisably hers, polished to be appropriate for formal writing.

**The balance:** shape the structure; preserve the language. Notes become a paragraph through connectors, sequence, and flow — not by replacing her words with generic professional vocabulary.

**Hard stop — invention is fabrication. No exceptions.**

Step 4 says "write a paragraph from it." That means: from what she actually wrote — the words, phrases, reactions, and comparisons that appear in Why I Want This Role. It does not mean: use her notes as a prompt and construct a paragraph using your own reasoning about what she would say or feel.

**Sparse notes are not a gap to fill. They are a signal to stop.** If Why I Want This Role is sparse — one sentence, a few words, no specific angle or reaction — write `[{{USER_FIRST_NAME}} TO FILL IN]` for the opener. Do not expand sparse notes into a full paragraph. The notes either contain enough to write from, or they do not. If they do not: placeholder, not invention.

**The traceability test — run before finalising the opener:** Can you point to a specific word, phrase, or reaction in Why I Want This Role that every sentence of the opener is built from? If you cannot trace a sentence directly back to something she wrote, that sentence is invented. Delete it, or replace the opener with `[{{USER_FIRST_NAME}} TO FILL IN]`.

**Failure mode A — verbatim paste:** Transcribing Why I Want This Role nearly verbatim into the opener. Her notes are not a paragraph. If the opener reads like it was copied from her field rather than written as a letter, it will sound abrupt, unstructured, and out of context.

**Failure mode B — full rewrite:** Extracting only the topic or angle from her notes and then writing entirely fresh sentences in polished professional language that removes all traces of how she actually said it. The result sounds well-crafted but carries none of her voice. This is not a better outcome than failure mode A — it is the same failure in the opposite direction.

**Failure mode C — expansion of sparse notes:** Why I Want This Role contains one sentence or a few words. The opener is a full paragraph expressing enthusiasm, specific reactions, and personal observations she did not write. This is fabrication. The model treated sparse notes as permission to invent what she would have said. It is not "helping" — it is putting words in her mouth and calling them her voice. The correct output when notes are this sparse is `[{{USER_FIRST_NAME}} TO FILL IN]`.

The fix for A and B: read her notes, understand what she's saying AND how she's saying it, then write a paragraph that says it well in her words. The fix for C: write the placeholder.

**After writing the opening sentence:**
Write the first sentence of the opener. Stop. Read it against the delivered letters from the Voice Gate. Ask: does this sentence sound like it belongs in those letters — same register, same directness, same rhythm? If not, rewrite it. Only when the first sentence sounds like it belongs in those letters: continue drafting the rest of the letter.

**Step 6 — Context gate (mandatory before writing any body sentence):**
Read the completed opener paragraph. Apply the single test: *could this paragraph appear unchanged in a letter to a different company?* If the answer is anything other than "no, clearly not" — the opener has not set context. It is not done. Rewrite it before writing a single body sentence. A well-crafted opener that doesn't establish specific context is still a failed opener.

---

### The universal shape

Every letter — regardless of tone, role, or opener strategy — has exactly three blocks:

**Block 1 — Opener (1–3 sentences).** Why this letter exists. Always short. Nobody opens with a wall. Choose an opener strategy from the Use-Case Structures below.

**Block 2 — Proof (1–3 paragraphs).** Where proof and connection live. One job per paragraph. Every paragraph must add something the CV cannot carry — a story, a significance, a context. Test: could this paragraph appear unchanged in a letter to a different company? If yes, rewrite it.

**Block 3 — Close (1–3 sentences).** One ask. Direct. Always tight. Options below.

**Formatting — white space is not optional:**
- Maximum 3–4 lines per paragraph. Hard stop. Then a blank line.
- Short paragraphs hit harder than long ones. A letter that breathes reads faster than a wall of text. If a paragraph runs over 4 lines, split it.
- The close is always its own paragraph — never attached to the paragraph before it.

**Bulleted lists — the WHEN matters more than the format:**

A bullet list is appropriate in exactly two situations:

**1. Transferability or pivot letter** — when the letter has spent its proof paragraphs making the case that skills from a different domain transfer here, a brief bullet list of capabilities at the end signals: "here is the full range that moves with me." The bullets land the breadth argument after the prose has established the narrative. They are not the proof — they are the summary after the proof has done its work.

**2. Multi-mandate role requiring range** — when the role explicitly requires coverage across several distinct capability areas and a bulleted list makes the range visible at a glance in a way prose cannot.

**Do not use bullets when:**
- The letter is a direct domain match — prose makes a stronger case than a list
- You haven't already made the narrative case in the proof paragraphs — bullets without proof are just a CV in list form
- You're lifting language from an existing CV bullet — letter language is fresh

**JD mirroring exception — bullets only:** The general ban on JD-dimension mirroring does not apply to transferability bullet lists. When the purpose of the list is to show that your skills map to what the role requires, using the JD's own language is the signal, not the failure. The bullets should reflect the JD's vocabulary deliberately — that's what makes the transferability argument land.

**Bullet format:** Short — 2–5 words each. No periods. Parallel grammatical form. Introduced by a complete sentence (period, no colon). The list sits between the proof paragraphs and the close.

---

1. **Greeting.** Always "Hi to the [Company] team!" — or "Hi to [Name]!" if writing directly to a named person. Never "Dear Hiring Manager."

2. **Opener paragraph.** Choose from the Use-Case Structures below. The user's reaction or observation comes first. Her background enters in service of that, not as the subject. If no documented reaction exists in Why I Want This Role, write `[{{USER_FIRST_NAME}} TO FILL IN]` — do not manufacture enthusiasm.

3. **Proof paragraph(s) — one job each.** One to three paragraphs, each doing exactly one thing: a pattern of experience across companies, a specific story that adds something the CV doesn't say, or documented product/company familiarity.

   **The central failure to avoid:** Key credentials from recent roles have appeared as verbatim, unchanged standalone paragraphs across many letters — producing 60–70% identical prose. These facts belong in sentences doing a specific job for THIS letter, connected to why this role at this company is the right next move.

   **No restatement with different adjectives.** "Established, structured team" followed by "stable, mature organization where the foundational infrastructure is already built" is one idea said twice. Pick the sharper phrasing and cut the other. Each sentence should introduce something the previous one didn't.

   **The coverage paragraph — entry beat, substance, exit beat.** The paragraph that handles career background, gap coverage, or career-pivot context is the paragraph most likely to read as a CV dump. Every coverage paragraph needs three things: (1) an **entry beat** — a connector from the prior paragraph, not a fresh restart. "My career started at..." restarts the letter from zero; "That function built on..." continues from the proof just given. (2) the **substance** — named companies, numbers, specific context. (3) an **exit beat** — one sentence that answers "so what?" for this specific hiring manager and connects the evidence to the mandate of the role. Without an entry and exit beat, the reader says "who cares?" The letter should never make the hiring manager do the interpretive work of connecting evidence to relevance. That is the letter's job.

   **Deliberate fragments — protected user voice.** A single sentence fragment used for conviction or pacing ("Because that's where I've always done my best work.") is the user's deliberate voice. Do not flag it for revision unless it is genuinely ambiguous in intent (i.e. it does not follow a complete sentence and does not add emphasis). The test: does it follow a complete sentence? Does it add a beat of conviction rather than state a fact? Does it appear only once? If yes to all three: it is intentional — protect it.

4. **Closing.** Choose from the options below. One ask, direct, always tight.

5. **Sign-off.** Default: "Looking forward to next steps," on its own line, "{{USER_FULL_NAME}}" on the next. Variation is allowed when it fits the letter's register — the delivered letters vary ("Excited for what's ahead!", "Can't wait to hear back from you!", or a direct closing line with no sign-off phrase). Keep it short and warm; the name always follows on its own line.

**Word count:** maximum 320 words total, excluding greeting and sign-off — no minimum. The 320 ceiling is a **round-aware advisory, not a hard fail**: on the gatekeeper's first pass a body over 320 returns to the letter-writer to trim; on any later pass it is logged and deferred to the humanizer (which holds word-count calibration authority and trims to register) — the pipeline never blocks past the first loop on word count alone. The 270–320 band is the typical register of the delivered letters — aim there when the content supports it, but a shorter letter that says everything needed beats a padded one. Length below the ceiling is a calibration choice. This is the single canonical rule — every other file defers to it.

### Close options

All of these work. Choose based on the role and the user's genuine register for this application:

- *Function-builder tricolon:* "I've built [this function / this type of work] from [scratch / different angles / more than once]. I loved it every time. I'd love to build it at [Company]." — three sentences mandatory, all three required
- *Capability statement:* Names the specific problem the role is trying to solve, states that the user has solved it, and names what she'd do here
- *Direct enthusiastic:* "I can't wait to speak with you about this role." / "I can't wait to hear more about the opportunity."
- *Active CTA:* "If you're ready for these results, I'd love to have that conversation." / "I'm looking forward to speaking with you further."

The test for any close: does it name the outcome and ask for it directly? Or does it ask permission to be considered?

---

## Claims and Framing Rules

These rules apply to every claim and every framing decision in the letter body.

**Managed-vs-executed:** When the user managed a team or function, language credits her with management and ownership — not personal execution of every deliverable. "Oversaw analyst relations" not "ran analyst relations." "Managed the AR owner" not "led analyst relations personally." If in doubt, check `01-writing-rules.md` Section 1 for the approved phrasing.

**Demand-gen framing:** When a JD signals demand-gen ownership, do not frame the absence of a standalone pipeline attribution number as a gap or limitation in the letter. Surface the builder evidence instead: outbound infrastructure at VL, content production, G-CMO Early Stage Marketing training. For seed/early Series A build roles this is a match, not a gap.

**Unfamiliar domains:** Do NOT frame any domain as "not her background." Do not call it out. Lead with what transfers — see Use-Case Structure #2 below.

**The twist as a narrative tool.** When the user's background doesn't map directly to the role, that gap is not a weakness to manage — it is a story to tell. Name the unexpected credential, name what it proves at the level of skill or judgment, name why that is actually exactly what this role needs. A twist is more memorable than a straight line. The failure mode: apologizing for the gap instead of reframing it as an asset.

**Research company pains, not just company values.** When a role warrants deep research, go beyond the JD and the about page. Primary sources — investor relations pages, annual reports, quarterly earnings letters, earnings calls — reveal what the company is actually worried about right now. Opening from a documented company challenge (sourced from their own words) is categorically stronger than opening from admiration of their product or culture. The discipline: the user names the pain in the company's own language, then immediately names a parallel moment from her own history. She does not analyze their pain — she parallels it. **Critical caveat:** this approach is only valid when the user connects the company's challenge to her OWN parallel experience in first person, immediately and specifically. The opener must still be the user speaking — not an analysis frame about the company. If the first sentence describes the company's challenge before the user appears as a reacting subject, it fails Pattern I (setup opener) in the gatekeeper. The company's pain is the context; the user's reaction to it is the opener.

**"I am drawn to [Company]'s approach/commitment to..."** — permitted when genuine. One clause, move to proof immediately. Never as a standalone paragraph.

**JD-dimension mirroring — forbidden in prose.** Never write as though addressing a JD section, requirement, or dimension by name. "I can also speak to the OEM engagement dimension directly" → "I also have broad experience working with OEMs." The letter must feel like the user is naturally describing her own experience — not reading from the JD and checking boxes.

**Exception — transferability bullet lists only.** When a bullet list is used to demonstrate skill transferability, using the JD's vocabulary in the bullets is correct and deliberate. The whole point is to show the mapping. This exception applies only to the bullet list itself, not to prose anywhere in the letter.

**Colons — entirely forbidden.** No colons anywhere in the letter body. Not for role labeling, not for introducing explanations, not before lists, not as an em dash substitute. If you find yourself reaching for a colon, restructure the sentence.

**"Most of my career has been [gerund]" — forbidden.** "My career" is not a subject. This construction buries the user. Write "For most of my career, I've [verb]..." — the user is the subject, the career is the context.

**"I'm passionate about..."** — not banned, but do not overdo it. Once per letter at most.

**Antithesis and pivot formulas — forbidden.** Never write "[Subject] does/has X, but [subject] is Y." If X doesn't need to exist for the sentence to work, cut it. The formula signals that the writer needed a rhetorical move rather than having something direct to say. This includes: "It's not about X, it's about Y." / "This isn't just A, it's B." / "Not X — Y." The fix is always the same: drop the negated half, lead with the affirmative. **The test:** remove the "but" clause and everything before it. If what remains is clearer and stronger, the setup was unnecessary and should be cut.

**Temporal motivation hedges — forbidden.** Phrases like "the seat I want most right now," "at this stage of my career," "what I'm looking for right now" make motivation sound provisional and shopping-among-options. A genuine reaction to a specific role needs no time qualifier. Cut any phrase that implies "…as opposed to what I'll want later." If the motivation is real, state it directly without the temporal hedge.

**Voice mechanics for self-description:** When describing the user's approach or working style, use first-person direct construction — not analysis from outside. "In my work, I emphasize..." not "My approach emphasizes..." / "I tend to..." not "My style involves..." The content is the same; the subject is the user, not a description of the user.
- **Approach-announcement via label — forbidden:** "My approach is deliberately X: Y, Z, W." / "I take a research-first approach to positioning." These announce the methodology as a named label before demonstrating it. Show the approach in action. **Fail:** "My thought leadership approach is deliberately slow-is-the-winner: every deliverable I produce is backed by a thinking process I can stand behind." **Fix:** "At [Company], I spent the first three weeks interviewing buyers before writing a line of copy."

---

## Use-Case Structures

Use these for the opening paragraph when a specific situation calls for it. Each has a literal template — fill in the bracketed slots with the user's actual content. Nothing should remain as-is from the template. The user's example for each structure lives below it.

**IMPORTANT:** The names in quotes below (e.g. "I was just doing this job") are structural labels — identifiers for the pattern type. They are NOT phrases to use in the letter. Do not write them. Do not quote them. They are shorthand for the agent only.

---

**1. Direct parallel** *[label: the job overlap]*

**When:** The user's most recent role was doing essentially the same thing this role requires — same product category, same buyer, same GTM challenge.

**The move:** Optional identity fragment ("[Name] here."), then the reaction to the coincidence, then land the credential as a causal fragment.

**Template:**
> [Optional: "[Name] here." as identity fragment.] [Reaction — why this specific overlap hit differently when you read it]. Because I was just doing it — as [role] at [Company], a [one-phrase descriptor] that [key outcome].

**Example:** [from `${CAREER_DATA}/references/delivered-letters/`: see any letter with an "existing relationship" or "just did it" opener]

---

**2. Unfamiliar domain** *[label: the transfer argument]*

**When:** The role requires domain experience the user doesn't have, but her experience is genuinely transferable at the level of buyer motion, technical complexity, or GTM challenge.

**The move:** Lead with what she knows — domain breadth and why it transfers. Name the connecting insight. Map specifically to this company. Never name the gap.

**Template:**
> I know how to [the transferable skill] because I've worked across [list of domains/verticals]. [The connecting insight — what usually stays the same: buyer motion, trust barriers, procurement logic]. [One sentence mapping to this specific company/role.]

**Example:**
I know how to learn new domains quickly and deeply, and I know how to find the buyer insights that make the GTM work because I've worked across an incredibly broad range of verticals — from cybersecurity to computer vision to developer tools. So often though, the target persona buyers are the same or similar. I'm sure that speaking to a health IT person that is a potential buyer for Hyro would be similar to, if not the same as, IT folk in any other compliance-dense industry.

---

**3. Compliance or regulated buyer** *[label: the buyer pattern]*

**When:** The buying motion is risk-mitigation-first, not ROI-first — healthcare, cybersecurity, financial services, defense.

**The move:** Story-led: name the real buyer insight plainly from your own experience. Name one specific thing you built in response. Land the application to this role in one sentence.

**Template:**
> At [Company], [the buyer insight in plain language — what they actually care about, not features]. [One specific thing you built to respond to that]. [Company/role you're applying to] follows the same logic.

**Example:** [Example from your background — see your worked examples in your `career-data` background]

---

**4. PLG / product-led role** *[label: the PLG insight]*

**When:** The role centers on self-serve, product-led growth, or developer/user-led adoption.

**The move:** Open with genuine passion (not a claim — a real statement). Then proof: first exposure and what you saw. Then range: success, failure, the full picture. Then the substantive insight: what you know now.

**Template:**
> [Genuine passion statement — why this work specifically, not "I'm passionate about PLG"]. [First exposure: company, what you did or saw]. [What you've seen since — success, failure, the range]. [Substantive insight: what you know now that you didn't then — when PLG works, what it requires, what kills it.]

**Example:** [Example from your background — see your worked examples in your `career-data` background]

---

**5. Function-builder close** *[label: the build culture close]*

**When:** The role is explicitly a founding hire, build-from-scratch mandate, or first function of its kind.

**The move — minimum (closing lines):** Three sentences, all mandatory. Scope claim → emotional sentence → company landing.

**Template (minimum):**
> I've built [this function / this type of work] from [scratch / multiple angles / more than once]. I loved it every time. I'd love to build it at [Company].

**Expanded version:** For roles where building is the central mandate, a longer build-culture paragraph can precede the tricolon — show what you love about it and how you operate in a new-build context, then close with the tricolon.

**Example:**
I absolutely love building things from scratch and that's probably why I'm also really good at it. I've built functions from scratch more than once. No matter where it is, the first challenge is making sure I learn the ropes and hear all of the stakeholders out. You can't build if you don't really have a clear vision of what might be missing, what might be broken, what the biggest pain points are inside the company and what my manager's and the business's priorities are.

---

**6. Multi-domain pattern** *[label: the range proof]*

**When:** The user needs to show she's encountered the same underlying problem across multiple companies — rapid proof that a pattern is real, not a one-off.

**The move — two options:**
- **(A) Horizontal competence claim:** Lead with what she knows how to do, ground it with breadth evidence, then name what's consistently true.
- **(B) Rapid-fire list:** One clause per company, then the connecting insight.

**Template (A):**
> I know how to [the competence] because I've worked across [domains/verticals]. [What's consistently true no matter where I am: what I do first, what I look for, what makes it work.]

**Template (B):**
> At [Company A] it was [specific angle of the same challenge]. At [Company B] it was [different angle, same challenge]. At [Company C] it was [third angle]. [One sentence naming what all of these share.]

**Example:**
I know how to learn new domains quickly and deeply, and I know how to find the buyer insights that make the GTM work because I've worked across an incredibly broad range of verticals — from cybersecurity to computer vision to developer tools. No matter where it is that I'm working, the first challenge is making sure I learn the ropes and hear all of the stakeholders out. You can't build if you don't really have a clear vision of what might be missing, what might be broken, what the biggest pain points are inside the company and what my manager's and the business's priorities are.

---

**7. Proof bullets that earn their place** *[label: the earned list]*

**When:** The user has 2–3 metric-backed outcomes that land harder as a short bulleted list than as prose.

**The move:** A confident, direct setup line earns the list — with energy, not "as you can see from the following."

**Template:**
> [Setup line — specific and confident, names the claim you're about to prove]:
> - [Metric-backed outcome, Company]
> - [Metric-backed outcome, Company]

---

**8. Warm connection / referral** *[label: the human in the room]*

**When:** The user has spoken to someone at the company directly, or has a named referral who opened the door.

**The move:** Name the person and the context (one sentence), move immediately to proof. The connection front-loads trust; the proof earns the interview. Do not spend more than one sentence on the connection itself.

**Template:**
> [One sentence naming the connection and the context — how you met or spoke, not who they are as a person]. [Move directly to proof — named company, named outcome, why it maps to this role.]

**Example:**
> Thanks for the brief chat via WhatsApp earlier. When I was reviewing Sweet Security before applying, my dog Messi asked if we could visit you in the office. I told him it's up to you ;)

---

**9. Anticipated question** *[label: the preemptive answer]*

**When:** There is an obvious question the reader will have about the user's application — a domain gap, a seniority mismatch, a non-linear background — and addressing it directly is stronger than hoping they won't notice.

**The move:** Name the question the reader is silently holding, then answer it immediately with proof. Write *to* the reader, not about yourself. Carmen's structure.

**Template:**
> [Name the reader's likely question or hesitation — directly, without apology]. [Answer it immediately with named proof — company, outcome, or specific experience that closes the gap].

**Example:**
> [Example from your background — see your worked examples in your `career-data` background]

---

**10. Problem-first** *[label: the observation opener]*

**When:** The user has a genuine professional observation about the recurring problem she's spent her career solving — and this role is the next instance of that problem. Best for senior, founding, or strategically complex roles.

**The move:** Open with the user as the subject — her experience, her position in the room. The market observation follows as supporting context, not as the opener. **The user must be the grammatical subject of the first sentence.** Opening with "So many marketers..." or any market-category claim is Pattern G in the gatekeeper — a hard fail. The observation from her Why I Want This Role content (or the motivation bank in `02-professional-background.md` §5) belongs in sentence 2 or 3, after the user has established her position.

**Core observation (from the motivation bank — use as supporting context after the user is established as subject):**
> "So many marketers lack the technical know-how to truly understand why or what is so different about the product itself — and this is often the case even for seemingly 'not' technical products."

**Template:**
> I've spent [X] years being the one who [does the thing most marketers don't] — at [Company], at [Company]. [The market observation as context: most marketers don't get there, even for products that look straightforward]. [One sentence: why this role/company is the same problem.]

**Example:**
> [Example from your background — see your worked examples in your `career-data` background]

---

**11. Value claim opener** *[label: the direct pitch]*

**When:** The best, most natural opener. Use whenever the role allows a confident, direct statement of what the user does and why this company is the right fit for it. Especially strong for strategic/senior roles, regulated-industry companies, and roles where the user's positioning/research edge is the core credential.

**The move:** Name the company and the posting (one clause) → observe what they need → pivot immediately to the value claim ("that's the work I do") → state HOW in one concise clause → thread the domain connection (why this company is the natural next chapter, not just a job) → close with a warm, confident one-liner.

**The rule:** The user is the subject by the second sentence at the latest. The company observation is the setup; the user's claim is the payload. Do not narrate methodology — name it in a clause.

**Template:**
> Reading the [Company] posting, it was clear you're looking for [what they need] — and that's the work I do. [Value proposition in one sentence — what the user does, what integrity/outcome it produces.] I get there by [HOW in a brief, non-exhaustive clause]. [Domain connection — why this company is the natural next step, grounded in a specific, named thread from the user's background.] And I'm confident the team at [Company] won't be sorry.

**Example:** [Example from your background — see your worked examples in your `career-data` background]

**What makes this work:** The company is named twice. The value claim arrives in sentence two. The methodology is named in a clause, not narrated as a case study. The domain connection is specific and earned (insurance → insurance). The close is warm and confident, not a permission-ask.

---

## Annotated Exemplar

One paragraph from the Ultralytics letter, annotated for the syntactic choices that make it work. Mirror these choices when writing — not just the content.

> *[Name] here.*

"[Name]" as grammatical subject — a proper noun, two syllables, nothing embedded. The predicate is implied. Deliberate identity fragment: complete as a sentence.

> *I'll be honest — I nearly screamed when I saw this role.*

"I" as subject. Short finite verb ("nearly screamed"). The em dash introduces a second independent clause — not a subordinate clause embedded inside the predicate. "When I saw this role" is a short adverbial — not a wh-clause stacked into the predicate object.

> *Because I was just doing it over the last year as the [function] leader at [Company A], a direct competitor of [Company B] that [key outcome metric] and was [exit/milestone].*

Deliberate causal fragment. "I" as subject. "Was just doing it" — short finite verb, predicate complete in five words. All complexity enters after the predicate via appositives: "as the [function] leader at [Company A]" (adverbial), "a direct competitor of [Company B]" (appositive bolted to the noun), "that [key outcome]" (relative clause on the appositive — not on the main predicate). The main predicate stays clean.

---

## The Analyst Paragraph — Hard Ban (applies to the ENTIRE letter, not just the opener)

This pattern is absolutely banned everywhere.

**What it looks like:**
- Describing the company's product, positioning, or market back to them: "What I see in [Company] is a technically rigorous product that deserves equally rigorous positioning."
- Making a market observation from outside the room: "Runtime-first detection is a genuinely differentiated story in a crowded CNAPP market."
- Announcing a capability instead of naming proof: "That translation is where I live." / "That's the work I do." / "That's where I operate best." / "That's where I want my marketing to land." Demonstrative pointing at abstraction ("that's where...", "that's what...", "that's the kind of...") points at an abstraction rather than naming a result. Replace with a company name and an outcome.
- Telling the hiring team what their buyers need or how their market works.
- Any sentence where the user is the analyst commenting on the company rather than the practitioner speaking from her own experience.

**Why it keeps appearing:** It sounds like research. It isn't. It positions the user as an outside observer who has done homework, not as someone who belongs in the room. It is presumptuous regardless of how accurate it is — nobody needs to be told about their own product.

**The test for every body paragraph:** Is the user the subject, speaking from her own named experience? Or is she describing the company/market/buyer from outside? If the latter: cut it or rewrite it so the user is the subject and the proof is a company name, number, or named deliverable.

**Replacement pattern:** One sentence naming what the user has done, from her own experience, that is directly parallel to what this company needs. No market commentary. No capability announcements. Named proof only.

---

## Opening Paragraph Pre-Flight

Run before writing the first sentence.

**Q1 — What is the one specific thing the user reacted to?** Must be specific to THIS role, THIS company, THIS moment. Test: could this sentence appear unchanged in a letter to a different company? If yes, it fails.
- Pass: "Direct competitor — she just wrapped the exact same job at [Company]." / "Compliance is the GTM motion AND build-from-scratch AND PLG — three things she loves, all in one role."
- Fail: "I love building PMM from scratch." (true of every letter)

**Q2 — What makes that reaction credible, in one sentence?** A company name, a number, or a named deliverable. One sentence only.

**Q3 — What do we know about the hiring manager?** The opener must connect to the HM — their likely priorities, background, or the specific problem they're trying to solve by filling this role. If a named HM is confirmed: check their LinkedIn briefly before writing — a specific signal (their background, a post they made, a company they came from) can anchor the first sentence in a way that reads as genuine and not generic. If HM is unknown or unconfirmable: the connection can be implicit (a Head of Marketing at a seed-stage AI company will almost certainly care about X) — make the implicit explicit. Write `[{{USER_FIRST_NAME}} TO FILL IN — HM CONNECTION]` only if the connection requires something the user would know from direct personal contact that no research could surface.

**Opener structure:** Sentence 1 → the reaction, belief, or hook. Sentence 2 → the credential. Rest → optional expansion, including HM-connected framing if it fits naturally.

**Manufactured opener — forbidden.** A hook that sounds like a genuine reaction but is actually a constructed reveal: "I read about [Company] and already have my first question." / "Before I write another word, I want to ask one thing." These announce that a clever move is coming — which signals exactly the opposite of genuine engagement. If the reaction is genuine, state it directly. If it isn't, write `[{{USER_FIRST_NAME}} TO FILL IN]`. Do not set up a reveal.

**Fallback:** If no genuine specific reaction exists in the reference material, write `[{{USER_FIRST_NAME}} TO FILL IN]` and flag it. Do not manufacture a reaction.

---

## Mandatory Revision Pass

> **Shared rules** — the agent loading this skill also loads `references/shared-voice-rules.md`. All prohibitions in §§1–6 of that file apply to cover letters. Rules tagged **[CL]** in shared-voice-rules.md are cover-letter-specific. The steps below enforce those rules plus cover-letter-only process requirements.

After producing the draft, enter revision mode. Read the letter sentence by sentence and run each sentence against the DON'T table in Writing Mechanics. Fix every violation before moving to the next sentence. This is not optional and does not depend on whether you believe the draft is already strong.

### Step 1 — Voice calibration

Before starting the revision, confirm the voice you're editing toward. Read `${CAREER_DATA}/references/delivered-letters/INDEX.md` — if the archive is reachable and count > 0, read ALL letters in it (every file, not 2–3). **If the archive is unreachable:** hard stop — do not proceed with the revision. **If count is 0 AND no letter files present:** fall back to `references/03-framework.md` §Voice and tone — read the voice samples there instead. Note these six dimensions:

1. **Sentence length** — short and punchy? Long and flowing? Mixed?
2. **Word choice level** — casual? somewhere between?
3. **Paragraph openers** — jumps right in? Sets context first?
4. **Punctuation habits** — parenthetical asides? No dashes at all?
5. **Transitions** — explicit connectors, or just starts the next point?
6. **Verbal tics** — any recurring phrases or patterns?

Match these patterns in your revision. Don't just remove AI tells — replace them with patterns from the delivered letters. If the samples use short sentences, don't produce long ones in their place. If they don't use semicolons, don't introduce them.

Also check for **content to lift**: if the delivered letters contain a proof point, analogy, or phrasing that is directly relevant to the current letter's argument, use it. Approved content from past letters is already validated — drawing from it is not repetition, it is efficiency.

When no domain-similar delivered letters are available, match the voice described in `references/03-framework.md` §Voice and tone.

### Step 2 — Audit: scan for AI writing patterns

**See `references/shared-voice-rules.md` §§1–6 for the complete prohibition list.** Every rule in that file applies to cover letters. Cover-letter-specific rules are tagged **[CL]** in that file. Scan the draft against all of them.

Quick reference — what to scan for:
- **§1** — Zero em dashes (`—`); zero colons in body copy **[CL]**. Search for `—` before returning. Any hit = not done.
- **§2** — No AI vocabulary (crucial, pivotal, vibrant, showcase, tapestry, underscore, landscape, testament, enduring, foster, garner, interplay, foundational, transformative, robust, seamless, comprehensive, leverage, synergy, spearhead, paradigm). No hollow self-description.
- **§3** — No absolute phrase prohibitions ("specialism," "that made it land," "behind the [noun]," "at an inflection point," "quietly [verb]ing," "rare" as self-descriptor, "up close"). No idioms unless verbatim from WIWTR **[CL]**.
- **§4 [CL]** — No contrived tricolons (real parallel lists pass); ≤3 -ing appendages each carrying real content; no false range ("from X to Y"); no antithesis/pivot formula.
- **§5 [CL]** — Active voice throughout; no "serves as / stands as / acts as"; no heavy noun-phrase subjects; no synonym cycling; no filler phrases ("in order to" → "to," etc.).
- **§6** — No idioms unless verbatim from the user's Why I Want This Role content.

### Step 3 — Audit question (mandatory)

Before rewriting, write out the answer to: **"What makes this draft so obviously AI-generated?"** Name 2–3 specific instances from the scan above. This forces genuine scrutiny rather than surface-level pattern matching. Do not skip this step.

### Step 4 — Rewrite

Produce the revised draft. It must:
- Contain the same number of paragraphs as the original
- Cover everything the original covered (no facts or proof points dropped)
- Preserve all meaning, specifics, and Why I Want This Role content
- Match the voice calibrated in Step 1

### Step 5 — Final scan before handing to gatekeeper

Run the `references/shared-voice-rules.md` §§1–6 checklist. Then verify:
- Search for `—`. Any hit = not done (§1).
- No contrived agent-drafted tricolons; no same-opening monotone runs (§4).
- No more than three -ing appendages, each carrying real content (§4 [CL]).
- No AI vocabulary words (§2).
- At least one short sentence used deliberately for conviction or rhythm (§5).

