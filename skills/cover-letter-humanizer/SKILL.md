---
name: cover-letter-humanizer
description: Complete AI-pattern rule list for the cover-letter-humanizer agent. Contains every syntax, voice, and structure rule. This skill is loaded exclusively by the humanizer agent — it is not exposed to the letter-writer or gatekeeper.
---

# Cover Letter Humanizer — Complete Rule List

This is the complete and only rule list. Every rule lives here. Nothing is elsewhere.

Work through the letter sentence by sentence. Check each sentence against this list before moving to the next. Fix violations as you find them.

---

## The top 3 — check these first, every letter

**1. Em dashes — zero. Absolute hard ban.**
The final letter contains no em dashes (—). Zero. Replace every one: period (new sentence), comma (tight aside), colon (introducing explanation), or restructure. Before returning output, search the letter for `—`. Any hit means you are not done.

**2. Rule of three/four — maximum once per letter.**
A tricolon (three parallel items used for rhetorical effect) may appear once per letter, only when it genuinely earns its place. Test: does the parallel structure land harder than two items or a single strong claim would? If no, reduce to two items or rewrite as a single sentence. If the letter already has one tricolon and you find another: remove the weaker one.
- Fail: "The hook that makes someone stop scrolling, the offer architecture that converts, the brand story that turns a first purchase into a second."
- Fix: Two items, or a single direct claim.

**3. -ing phrase appended after a main clause — maximum once per letter.**
"Contributing to," "highlighting," "showcasing," "enabling," "supporting," "building on" tacked onto a sentence that already has a subject and verb. The -ing phrase adds fake consequence or fake depth. Maximum one per letter. The permitted one must express a real outcome, not interpretive commentary.
- Fail: "I ran the campaign, showcasing expertise."
- Fail: "I built the GTM motion, contributing to $1M+ quarterly ACV."
- Fix: "I ran the campaign." / "I built the GTM motion. ARR grew to $3M."

---

## Sentence structure rules

**Subject first — always.**
Every sentence starts with "I" or a named entity. Never a gerund, prepositional phrase, or dependent clause as the opener.
- Fail: "Building GTM for fifteen years has given me..."
- Fail: "For most of my career, I've been brought into..."
- Fail: "Before any of those go live, I run..."
- Fix: "I've spent fifteen years building GTM..." / "I run a positioning conversation before any of those go live."

**"Most of my career has been [gerund]" — banned.**
"Career" is not a subject that acts.
- Fail: "Most of my career has been building PMM functions..."
- Fix: "For most of my career, I've built PMM functions..."

**Dangling participle — banned.**
The implied subject of a participial phrase must match the main clause subject.
- Fail: "The project expanded, building a partner network."
- Fix: "The project expanded. I built the partner network."

**Noun clause or long noun phrase as subject — banned.**
Starting a sentence with "What you need is..." or a long noun phrase with an embedded relative clause.
- Fail: "The blend of experience I bring is exactly what you need."
- Fail: "The mechanics are transferable."
- Fail: "A company that's ready to move needs that infrastructure..."
- Fix: "I bring X. I've built X." / "These mechanics transfer."

**Relative clause buried in object noun phrase — banned.**
The verb is fine but the object contains a deeply embedded relative clause. Three syntactic levels before the sentence resolves.
- Fail: "I felt the pull consumer marketing has always had on me."
- Fix: "Consumer marketing has always pulled at me."

**Wh-clause stacking inside one predicate — banned.**
Two or more coordinated wh-clauses ("whether," "what," "where," "how") as objects inside a single predicate.
- Fail: "...understanding what the pain points look like, what's moving them toward Ship4wd, and where the messaging needs sharpening."
- Fix: Break into separate sentences or reduce to one wh-clause.

**Inanimate subject performing human action — banned.**
Only people build, craft, drive, navigate, champion, sharpen.
- Fail: "This role sharpened my instincts."
- Fix: "Working in this role sharpened my instincts."

**Parallel structure in coordinated clauses — required.**
If clause A has a subject and verb, clause B needs a subject and verb.
- Fail: "I learned semiconductor inspection, led the full marketing function, and the company was acquired."
- Fix: "I learned semiconductor inspection, led the full marketing function, and watched the company get acquired."

**"And...and...and..." stacking — banned.**
- Fail: "I built it and ran it and owned it."
- Fix: "I built it, ran it, and owned it."

**Colon joining two independent clauses — banned.**
A colon introduces a list, an example, or an explanation — not a second complete sentence.
- Fail: "I have a confession: I daydream about consumer campaigns."
- Fix: "I have a confession to make. I daydream about consumer campaigns."

---

## Voice and vocabulary rules

**AI vocabulary — cut every instance.**
*crucial, pivotal, vibrant, showcase/showcasing, tapestry (figurative), underscore (verb), landscape (abstract noun), testament, enduring, foster/fostering, garner, interplay, intricate/intricacies, foundational, transformative, robust, seamless, comprehensive, leverage (verb), synergy, spearhead, paradigm.*
Replace with plain language or restructure.

**Passive voice — rewrite in active almost always.**
Find the passive construction. Who did the action? Put them as the subject.
- Fail: "The company was acquired by Camtek."
- Fix: "Camtek acquired the company." / "I watched the company get acquired by Camtek."

**"Serves as" / "stands as" / "acts as" — use "is."**
- Fail: "This serves as a foundation for..."
- Fix: "This is..."

**Approach-announcement via label — banned.**
Announcing the methodology as a named label before demonstrating it.
- Fail: "My approach is deliberately slow-is-the-winner: every deliverable I produce is backed by a thinking process."
- Fail: "I treat team building as a core strategic capability, not an HR function."
- Fix: "At Visual Layer, I spent the first three weeks interviewing buyers before writing a line of copy." Show; don't label.

**Demonstrative declaration — banned.**
Pointing at an abstraction with "that's where," "that's what," "that's the kind of."
- Fail: "That's where I want my marketing to land."
- Fail: "That's the work I do best."
- Fix: Name the outcome and the company.

**Synonym cycling (elegant variation) — banned.**
AI cycles synonyms to avoid repetition. Pick the right word and use it again.
- Fail: "The protagonist faces challenges. The main character overcomes obstacles. The central figure triumphs."
- Fix: "The protagonist faces challenges but eventually triumphs."

**Expert-claim opener — banned.**
Agent-constructed claims not from Q&A or page body.
- Fail: "I know this buyer." / "This is the kind of mandate I'm looking for."
- Fix: Use only content the candidate wrote. If nothing exists, leave `[CANDIDATE TO FILL IN]`.

**Pronoun pointing at abstraction — banned.**
"That," "this," "it" without a clear, named referent.
- Fail: "ZyG is where I'd do that."
- Fix: Name what "that" refers to, or drop the sentence.

**Methodology narration in opener — banned.**
Narrating process steps as a case study in the opening.
- Fail: "customer interviews across five verticals, competitive analysis, longitudinal PMF assessment..."
- Fix: Name the HOW in one clause. Save the proof for the body.

**Filler phrases — cut, start with the claim.**
- "in order to" → "to"
- "at this point in time" → "now"
- "it is important to note that" → cut entirely
- "due to the fact that" → "because"
- "has the ability to" → "can"
- "in the event that" → "if"

**False range "from X to Y" — ban.**
X and Y are not endpoints on a meaningful scale.
- Fail: "everything from messaging to competitive analysis"
- Fix: Name the specific things.

**Word-stem echo within three lines — fix.**
- Fail: "crafted...having crafted" / "designed the design"
- Fix: Synonym or restructure.

**Abstract noun stacking after em dash — banned.**
(Already banned by em dash rule, but flag this specifically when it occurs.)
- Fail: "the creative arc, the instinct, the brand moment" after an em dash.
- Fix: Named company + specific deliverable.

---

## Structure rules

**Company name in first paragraph — required.**
If absent, flag in the change log. Do not invent a company name — flag only.

**Role title in letter body — required.**
If absent, flag in the change log. Do not invent one.

**Rhetorical questions — zero in opener, one maximum in entire letter.**
If the opener is a rhetorical question: remove it and find the actual reaction or observation underneath.

**Manufactured opener — banned.**
A constructed reveal: "I read about [Company] and already have my first question." / "Before I write another word..."
Fix: If the reaction is genuine, state it directly. If not, flag `[CANDIDATE TO FILL IN]`.

**Strategy analysis opener — banned.**
Agent-constructed expert claims in the opener: "I know this buying motion." / "This is the mandate I've been looking for."
Fix: If the candidate didn't write it, flag `[CANDIDATE TO FILL IN]`.

**Close must be its own paragraph.**
If the close is attached to the paragraph before it: separate it.

**Greeting — must be "Hi to the [Company] team!" or "Hi to [Name]!"**
Never "Dear Hiring Manager." If wrong: correct it.

---

## The instinct check

After running every rule: read the letter aloud (mentally). Does any sentence sound like something a person would actually say to someone they're trying to impress? If a sentence sounds assembled rather than spoken — even if it passes every named rule — flag it and fix it. You are a linguistics expert. Trust the instinct.
