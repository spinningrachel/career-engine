---
name: cover-letter-humanizer
description: Complete AI-pattern rule list for the cover-letter-humanizer agent. Contains every syntax, voice, and structure rule. This skill is loaded exclusively by the humanizer agent — it is not exposed to the letter-writer or gatekeeper.
---

# Cover Letter Humanizer — Complete Rule List

> **Letter pipeline file.** Before changing anything here, read the full file and confirm no load-bearing rule is being removed. Removing a rule is not the same as simplifying — check that the behavior it encodes is preserved elsewhere or explicitly retired by the user.

This is the complete and only rule list. Every rule lives here. Nothing is elsewhere.

**You cannot return output that contains any violation of any rule in this skill. Not one. If a violation exists, fix it. You are not done until zero violations remain across all five steps.**

**Shared rules source:** This skill enforces rules from `references/shared-voice-rules.md` (annotated below with §N) plus cover-letter-specific rules from `skills/cover-letter/SKILL.md`. Source annotations in the step tables are for audit only — the checklist is the authority.

**Before running any step:** Read the delivered letters AND the voice fingerprint. Go to `${CAREER_DATA}/references/delivered-letters/`, read `INDEX.md`, and read ALL letters in the archive — every file listed, not 2–3. Read `${CAREER_DATA}/references/03-framework.md` §Voice fingerprint for the quantitative targets. These are your positive calibration — what you are rewriting *toward*, not just what you are rewriting away from.

Then work through every step in order. Do not skip steps. Do not run steps in parallel. Do not return output until Step 5 is complete and no violations remain.

---

## Step 1 — MANDATORY: Top 4

Read every sentence in the letter one by one. For each sentence, compare it against every rule in this table one by one. Rewrite immediately if it violates any rule — even if that means rewriting the same sentence multiple times. Do not move to Step 2 until every sentence passes every rule in this step.

| # | Rule | What's banned / required | Fail | Fix |
|---|---|---|---|---|
| 1 | **Em dashes AND colons — absolute hard ban. Zero.** *(shared-voice-rules §1)* Before returning output, search the letter for `—` and `:`. Any hit means you are not done. | Any em dash or colon anywhere in the letter. | "[Company] — [descriptor]" / "The narrative: competitive positioning" | Period (new sentence), comma (tight aside), or restructure. |
| 2 | **Rule of three — bans the contrived agent tricolon, not the user's parallel lists.** *(shared-voice-rules §4)* Parallel lists and multi-part parallels are the user's style (her letters carry four- and five-part parallels) — keep them when archive-consistent. Banned: the contrived rhetorical tricolon assembled for effect in agent-drafted text, and the same sentence opening used three or more times producing a monotone run. Test for an agent tricolon: was it built to sound impressive rather than to list real things? | A contrived agent-drafted rhetorical tricolon; the same sentence opening three or more times in a row. | "the hook that makes someone stop scrolling, the offer architecture that converts, the brand story that turns a first purchase into a second." / three consecutive sentences opening with "I built" | Two items or a single direct claim for contrived tricolons; varied openings for monotone runs. Leave the user's real lists alone. |
| 3 | **-ing phrase appended after a main clause — max three per letter, every one content-bearing.** *(shared-voice-rules §4 [CL])* "Contributing to," "highlighting," "showcasing," "enabling," "supporting," "building on" tacked onto a sentence that already has a subject and verb. Each permitted one must carry real content — a real outcome or a real list of things built ("...headed strategy and execution, building the positioning, the website, the outbound motion") — never interpretive commentary or fake depth ("...showcasing expertise"). | More than three -ing appendages; any one that adds fake consequence or fake depth, regardless of count. | "I ran the pipeline, showcasing expertise." / "I built the GTM motion, contributing to $1M+ ACV." | "I ran the pipeline." / "I built the GTM motion. ARR grew to $3M." |
| 4 | **Subject first — drafting default; archive ramps are kept.** *(shared-voice-rules §5 [CL])* When drafting, prefer sentences opening with "I" or a proper named entity (a real proper name — not a career-phase descriptor, category label, or abstract container). Dependent-clause and prepositional ramps consistent with the delivered letters ("When I heard...", "After years in...", "On Fiverr, I...") are the user's register — keep them, do not rewrite. **HARD BAN, no carve-out:** expletive constructions ("There was / There is / There are") and abstract label noun-phrase subjects ("The founding-marketer part is..."). | An expletive construction; an abstract label noun phrase as subject; an agent-drafted gerund opener with no archive precedent. | "For most of my career, I've been brought into..." / "Before any of those go live, I run..." / "Building GTM for fifteen years has given me..." / "There was no team, no playbook, and no budget." / "The founding-marketer part is the work I just finished." | "I've spent most of my career..." / "I run a positioning conversation before any of those go live." / "I've spent fifteen years building GTM..." / "I built the function without a team, a playbook, or a budget." / "I just finished building [specific thing] at [Company]." |

---

## Step 2 — MANDATORY: Sentence structure

Read every sentence in the letter one by one. For each sentence, compare it against every rule in this table one by one. Rewrite immediately if it violates any rule — even if that means rewriting the same sentence multiple times. Do not move to Step 3 until every sentence passes every rule in this step.

| Rule | What's banned | Fail | Fix |
|---|---|---|---|
| **"Most of my career has been [gerund]" — banned.** *(shared-voice-rules §5 [CL])* "Career" is not a subject that acts. | This construction in any form. | "Most of my career has been building PMM functions..." | "For most of my career, I've built PMM functions..." |
| **Dangling participle — banned.** *(cover-letter/SKILL.md)* The implied subject of a participial phrase must match the main clause subject. | A participial phrase whose implied subject differs from the main clause subject. | "The project expanded, building a partner network." | "The project expanded. I built the partner network." |
| **Noun clause or long noun phrase as subject — banned.** *(shared-voice-rules §5 [CL])* Starting with "What you need is..." or a long noun phrase with an embedded relative clause. | Any sentence whose subject is a long noun phrase with embedded relative clauses. | "The blend of experience I bring is exactly what you need." / "The mechanics are transferable." | "I bring X. I've built X." / "These mechanics transfer." |
| **Relative clause buried in object noun phrase — banned.** The object contains a deeply embedded relative clause — three syntactic levels before the sentence resolves. | Object noun phrases with two or more levels of embedding. | "I felt the pull consumer marketing has always had on me." | "Consumer marketing has always pulled at me." |
| **Wh-clause stacking — banned.** Two or more coordinated wh-clauses ("whether," "what," "where," "how") as objects inside a single predicate. | Two or more wh-clauses in one predicate. | "...understanding what the pain points look like, what's moving them toward Northwind, and where the messaging needs sharpening." | Break into separate sentences or reduce to one wh-clause. |
| **Inanimate subject performing human action — banned.** Only people build, craft, drive, navigate, champion, sharpen. | An inanimate noun as subject of an action verb. | "This role sharpened my instincts." | "Working in this role sharpened my instincts." |
| **Parallel structure in coordinated clauses — required.** If clause A has a subject and verb, clause B needs one too. | Active clause followed by passive clause in a coordinated list. | "I learned semiconductor inspection, led the full marketing function, and the company was acquired." | "I learned semiconductor inspection, led the full marketing function, and watched the company get acquired." |
| **"And...and...and..." stacking — banned.** | Three or more items connected by repeated "and" with no commas. | "I built it and ran it and owned it." | "I built it, ran it, and owned it." |
| **Sentence-length balance — required.** *(shared-voice-rules §5)* The letter should mix long and short sentences: a short sentence lands emphasis, a longer one carries nuance. This is a calibration target, not an exact metric — the delivered letters are the standard. Read each paragraph for rhythm; intervene only where it reads flat or assembled because the sentences run at one length. | A paragraph that reads monotone — noticeably same-length, same-shape sentences with no variation. Judge by ear against the delivered letters, not by counting words. | "I built the GTM motion at Acme. I led the analyst program there. I created the partner kit." | Vary where it genuinely improves the read: break one long sentence in two, fuse two short ones, or land the paragraph's point in one short sentence. Do not restructure a paragraph that already reads naturally. |

---

## Step 3 — MANDATORY: Voice and vocabulary

Read every sentence in the letter one by one. For each sentence, compare it against every rule in this table one by one. Rewrite immediately if it violates any rule — even if that means rewriting the same sentence multiple times. Do not move to Step 4 until every sentence passes every rule in this step.

| Rule | What's banned | Fail | Fix |
|---|---|---|---|
| **AI vocabulary — cut every instance.** *(shared-voice-rules §2)* | *crucial, pivotal, vibrant, showcase/showcasing, tapestry (figurative), underscore (verb), know what it takes , land (verb), landscape (abstract noun), testament, enduring, foster/fostering, garner, interplay, intricate/intricacies, foundational, transformative, robust, seamless, comprehensive, leverage (verb), synergy, spearhead, paradigm* | Any of the listed words. | Replace with plain language or restructure. |
| **Passive voice — rewrite in active almost always.** *(shared-voice-rules §5)* Find the passive. Who did the action? Put them as the subject. | A passive construction where an active rewrite is possible. | "The company was acquired by Contoso." | "Contoso acquired the company." / "I watched the company get acquired by Contoso." |
| **"Serves as" / "stands as" / "acts as" — use "is."** *(shared-voice-rules §5 [CL])* | These phrases in any context. | "This serves as a foundation for..." | "This is a foundation for..." |
| **Approach-announcement via label — banned.** *(shared-voice-rules §4)* Announcing the methodology as a named label before demonstrating it. | Any sentence that names an approach or philosophy instead of showing it. | "My approach is deliberately slow-is-the-winner..." / "I treat team building as a core strategic capability, not an HR function." | "At [Company], I spent the first three weeks interviewing buyers before writing a line of copy." Show; don't label. |
| **Expert-claim — banned anywhere in the letter.** Agent-constructed claims about the candidate's insight, recognition, or perspective not from Why I Want This Role. | Any claim anywhere in the letter that came from agent analysis, not the candidate's own words. | "I know this buyer." / "This is the kind of mandate I'm looking for." / "I see the adoption problem from the inside." / "I recognized the core ask right away." | Use only content the candidate wrote. If nothing exists: `[CANDIDATE TO FILL IN]`. |
| **Appended negating contrast — absolute ban.** The construction "[claim], not [X]" or "[claim], not as [X]" appended to a sentence. No carve-outs. | Any sentence with a trailing ", not..." or ", not as..." clause. | "I've done both of those things together, not as separate jobs." / "I can execute quickly, not just strategize." | Make the positive claim and stop. Cut everything from the comma forward. |
| **Antithesis/pivot formula — absolute ban.** *(shared-voice-rules §4)* "Not X — Y." / "It's not about X, it's about Y." / "This isn't just A, it's B." / "Not X. [Subject] Y." The negation half is AI-drafted rhetorical scaffolding. Test: if removing the negating half makes the sentence clearer, cut the negating half. | Any sentence structured as a pivot from a negated claim to a positive one — leading or trailing. | "Feature adoption is won on rhythm, not launch day." / "This isn't just a PMM role — it's a builder role." / "Not execution. Strategy." | Make the positive claim directly. "I build launch rhythms that drive feature adoption." / "This role needs a builder." |
| **Agent-invented methodology — banned anywhere in the letter.** HOW the candidate works, their process, or their approach must come from their own words in Why I Want This Role or `02-professional-background.md`. The agent may not construct methodology from JD inference. | Any methodology claim the candidate did not write. | "I run discovery interviews before touching positioning." (if unsourced) | Trace to candidate's words or cut. Never infer HOW from the JD. |
| **False range "from X to Y" — banned.** *(shared-voice-rules §4)* X and Y are not endpoints on a meaningful scale. | Any "from X to Y" where X and Y aren't real endpoints. | "everything from messaging to competitive analysis" | Name the specific things. |
| **Idioms — absolute ban unless verbatim from WIWTR.** *(shared-voice-rules §6)* Any figurative phrase used non-literally: "hit the ground running," "wear many hats," "put my thinking cap on," "move the needle," "low-hanging fruit," "at the end of the day," "take it to the next level," or any similar expression. | Any idiom not copied verbatim from the user's Why I Want This Role content. | "I'm ready to hit the ground running." | "I can start delivering in week one." |
| **Vocabulary and phrase prohibitions — absolute ban.** *(shared-voice-rules §3)* Metaphors and similes; "I was just doing X"; "I know how to sell X"; "I knew this was mine" (any version); "I spent the better part of a decade..."; "that made it land"; "behind the [noun]" (e.g., "behind the coverage"); "at an inflection point"; "quietly [verb]ing" (e.g., "quietly building"); "rare" as a self-descriptor; "up close" | Any of the listed words, phrases, or constructions. | "I've spent the better part of a decade quietly building behind the scenes." / "I knew this role was mine." / "That's what made it land." | Name the actual work or outcome; name the specific transition; use the direct verb; demonstrate through specifics; cut "up close". |
| **Demonstrative determiner pointing at an agent-coined abstraction — banned.** The entire format **"[subject] [verbed] exactly that [object]"** and every variant where "that"/"this" modifies an abstraction the letter itself invented ("that exact loop," "exactly that motion," "this same playbook," "the same engine/motion/playbook" (bare "the same" + an abstraction the letter coined)). The noun does not rescue it — if the noun is a metaphor or category label coined earlier in the letter rather than a real, named thing, the sentence is the same pointing gesture as a bare demonstrative. | "That exact [noun]," "exactly that [noun]," "this same [noun]," or "[subject] [verbed] (in) exactly that [object]" where the object is an abstraction, metaphor, or category label rather than a named company, product, event, or deliverable. | "I lived in that exact loop at Acme." / "I ran exactly that motion at Initech." / "I built this same playbook before." | Name the actual work: "At Acme I adapted partner messaging across ten MSP relationships." Drop the bridge sentence entirely if the next sentence already names the proof. |
| **Filler phrases — cut, start with the claim.** *(shared-voice-rules §5)* | These phrases in any context. | "in order to" / "at this point in time" / "it is important to note that" / "due to the fact that" / "has the ability to" / "in the event that" | "to" / "now" / cut / "because" / "can" / "if" |

---

## Step 4 — MANDATORY: Structure

Read every sentence in the letter one by one. For each sentence, compare it against every rule in this table one by one. Rewrite immediately if it violates any rule — even if that means rewriting the same sentence multiple times. Do not move to Step 5 until every sentence passes every rule in this step.

| Rule | Required / banned | Fail | Fix |
|---|---|---|---|
| **Company name in first paragraph — required.** Stealth roles (no public company name): the JD's descriptor satisfies this. | Must appear in paragraph 1 (or the stealth descriptor). | First paragraph has no company name or descriptor. | Flag in change log. Do not invent a name. |
| **Role title in the first sentence — required.** The opening sentence must name the role. It does not have to lead the sentence, but it must be clear and specific. | Must appear in the first sentence of the letter. | First sentence doesn't name the role; role title appears only later or not at all. | If the title appears later in the letter, restructure the opener to include it using existing letter content. If no role title exists anywhere, flag in change log. Do not invent one. |
| **Company product problems — absolute ban.** The letter must never mention, imply, or hint at a problem, gap, or weakness in the company's products, features, or business — not even subtly, not even when WIWTR suggests the candidate identified one. | Any reference to a company product problem anywhere in the letter. | "Feature discoverability at 150M MAU, and I cannot wait to get started on the fix." | Cut entirely. The letter makes no claim about what the company needs to fix. |
| **Repeated example — banned.** The same proof point, company story, number, or anecdote must not appear more than once in the letter. | Any example, outcome, or proof point used twice. | The same ARR figure or company anecdote in paragraph 2 and again in the close. | Keep the instance where it works hardest; cut or replace the other. Do not invent a substitute example. |
| **Repeated phrase — banned.** A distinctive multi-word compound (2+ words that form a specific term or named concept) must not appear more than once in the letter. Catch: scan the full letter for any 2–3 word string that appears more than once. | Any compound phrase used twice. | "drumbeat campaigns" in paragraph 3 and again in paragraph 5. | Keep the instance where it lands hardest; replace or cut the other. |
| **Rhetorical questions — zero in opener, one maximum in entire letter.** | Zero in opener; max one total. | Rhetorical question as opener. | Remove; find the actual reaction or observation underneath. |
| **Manufactured opener — banned.** A constructed reveal or tease: "I read about [Company] and already have my first question." / "Before I write another word..." | Any opener structured as a manufactured reveal. | "I read about [Company] and already have my first question." | State the genuine reaction directly, or flag `[CANDIDATE TO FILL IN]`. |
| **Strategy analysis opener — banned.** Agent-constructed expert claims in the opener not from the candidate's own words. | Any opener claim the candidate did not write. | "I know this buying motion." / "This is the mandate I've been looking for." | If the candidate didn't write it: `[CANDIDATE TO FILL IN]`. |
| **Close must be its own paragraph.** | Closing paragraph must be separate from the body. | Close attached to the preceding paragraph. | Separate it. |
| **Greeting format — required.** "Hi to the [Company] team!" or "Hi to [Name]!" Never "Dear Hiring Manager." | Greeting follows the required format. | "Dear Hiring Manager" | Correct it. |

---

## Step 5 — MANDATORY: Instinct check

Before returning the letter, do all four of the following:

1. Re-read the delivered letters you loaded before starting this pass.
2. Read your revised letter aloud (mentally), sentence by sentence.
3. For each sentence, ask: does this sentence sound like it belongs in those letters — same register, same directness, same rhythm?
4. If any sentence sounds assembled rather than spoken — even if it passed every named rule — rewrite it and note it in the change log.

**You are a linguistics expert. The delivered letters are your calibration standard. Trust the instinct; name the fix.**

---

## Final Gate — NON-NEGOTIABLE: Zero violations before output

Before returning anything, run this checklist in order. If any item fails, fix it before continuing.

- [ ] Step 1: No em dashes or colons (no carve-out). No contrived agent-drafted rhetorical tricolons; no same-opening monotone runs (the user's real parallel lists pass). No more than three -ing appendages, each carrying real content. Sentence openings: no expletives ("There was/is/are") and no abstract label noun-phrase subjects — these two carry no carve-out; archive-consistent dependent-clause and prepositional ramps are the user's register and pass.
- [ ] Step 2: No dangling participles. No long noun phrase subjects. No deeply embedded relative clauses in objects. No wh-clause stacking. No inanimate subjects performing human actions. Parallel structure intact. No "and...and...and..." stacking. Long and short sentences balanced — no paragraph that reads monotone, judged against the delivered letters rather than by counting.
- [ ] Step 3: No AI vocabulary. Active voice throughout. No "serves/stands/acts as." No approach-announcement labels. No demonstrative declarations. No demonstrative determiners pointing at agent-coined abstractions ("that exact [noun]" / "exactly that [noun]" / "this same [noun]"). No synonym cycling. No appended negating contrast (", not [X]" / ", not as [X]"). No antithesis/pivot formula ("Not X — Y" / "It's not about X, it's about Y" / "This isn't just A, it's B"). No expert-claims anywhere in the letter. No agent-invented methodology. No filler phrases. No false ranges. No word-stem echoes. No prohibited vocabulary phrases.
- [ ] Step 4: Company name in paragraph 1. Role title named in the first sentence. No example, proof point, or number repeated. No distinctive multi-word phrase repeated anywhere in the letter. No company product problems mentioned or implied. No rhetorical questions in opener. No manufactured opener. No strategy analysis opener. Close is its own paragraph. Greeting format correct.
- [ ] Step 5: Every sentence sounds like it belongs in the delivered letters. Nothing sounds assembled.

**If any box cannot be checked: fix the violation and rerun the checklist from the top. You are not done until every box passes.**
