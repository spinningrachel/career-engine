---
name: linkedin-post-reviewer
description: "Check sequence, grade criteria, and violation taxonomy for the linkedin-post-reviewer agent."
---

# LinkedIn Post Reviewer Skill

## Check Sequence

Run checks in this order. Stop at each FAIL and record it before continuing — do not stop the review early.

### Check 1 — Word count

Compare word count to format ceiling:
- Format A: ≤950w — PASS; >950w — FAIL: "Word count [N] exceeds Format A ceiling (950w)"
- Format B: ≤600w — PASS; >600w — FAIL
- Format C: ≤500w — PASS; >500w — FAIL

Also flag if the post is far below the floor (Format A <700w, Format B <350w, Format C <200w) — the post may be underdeveloped.

### Check 2 — Prohibited punctuation (§1)

Scan for:
- Em dashes (`—` or `--` used as em dash substitute) — FAIL: cite exact sentence
- Colons in X:Y structure on LinkedIn [LI] — FAIL: cite exact sentence
- Any other punctuation pattern banned in §1

### Check 3 — Banned vocabulary (§2)

Scan for any word from the banned vocabulary lists in §2:
- AI writing patterns: crucial, pivotal, vibrant, showcase, tapestry, underscore (verb), landscape (noun), testament, enduring, foster, garner, interplay, intricate, foundational, transformative, robust, seamless, comprehensive, leverage (verb), synergy, spearhead, paradigm, land (verb in marketing sense)
- Hollow self-description: results-driven, passionate, dynamic, etc.
- LinkedIn-specific bans: "In today's world", "Today's landscape", "Unlock/Unleash/Harness", "Broke the mold", "Actually" for emphasis, "In reality", "Hit home", "How we show up"

Each instance = one violation.

### Check 4 — Banned phrases and constructions (§3)

Check for:
- Named construction bans: "that made it land", "behind the [noun]", "at an inflection point", "quietly [verb]ing", "rare" as self-descriptor
- LinkedIn opening/transition bans: "Here's the hard truth", "Here's the thing", "And honestly?", "Real talk:", "Not gonna lie"
- False dichotomies: "It's not about X, it's about Y" structure
- Oppositional rhetoric: "everyone else does X, but I do Y"
- Vague phrases: "something clicked", "game-changer", "needle-mover"

### Check 5 — Structural anti-patterns (§4)

Check for:
- Antithesis/pivot formula: "[did X thing] → [realised Y the hard way]" arc
- False range: "from X to Y" where the range is manufactured rather than real
- Approach-announcement via label: "Here's my framework:", "My approach:", "The method I use:"
- Contrived tricolons: three parallel items that don't genuinely parallel each other
- Excessive -ing appendages: more than 3 in the post, or any that are content-free

### Check 6 — Sentence mechanics (§5)

Check for:
- Passive voice where active is possible (flag each instance)
- Subject buried: sentences where the actor appears late or not at all
- Synonym cycling / elegant variation: using different words for the same thing to avoid repetition
- Filler phrases: "It's worth noting that", "At the end of the day", "The fact of the matter is"

### Check 7 — Idiom prohibition (§6)

Scan for any idiom not present in {{USER_FIRST_NAME}}'s documented voice or the user's own phrasing. Common violations: "move the needle", "in the weeds", "at the table", "hit the ground running", "low-hanging fruit".

### Check 8 — Hook quality

Does the hook (first 1–3 lines) contain:
- A specific, credible claim or observation? If not → FAIL
- A rhetorical question? If yes → FAIL
- A vague value promise ("here are 5 things...")? If yes → FAIL
- An audience-address opener ("If you're a PMM...")? If yes → FAIL

### Check 9 — Proof grounding

Are all named outcomes, companies, and metrics present in `02-professional-background.md`? 

If the reviewer does not have access to `02-professional-background.md` in this session, flag: "Proof check skipped — background file not loaded. Load 02-professional-background.md to run this check."

If a claim appears fabricated or unverifiable → FAIL with the exact claim quoted.

### Check 10 — Close

Does the post end with an explicit engagement request / engagement bait ("like this if you agree", "comment below", "share with someone who needs this", "Agree?")? → FAIL

Does the post end with a *rhetorical* question used as a CTA — a generic, content-free prompt to comment ("What do you think?", "Have you experienced this?")? → FAIL

**Permitted (do NOT fail):** a specific, substantive implementation question tied to the framework — the Format A "Implementation CTA" mandated by `shared-voice-rules.md §8`. A close that asks a concrete question about applying or adapting the framework and invites substantive responses is correct, not a violation. Only fail closing questions that are rhetorical or engagement bait, not those that ask a real implementation/adaptation question.

## Grade Criteria

| Grade | Violation count | Verdict |
|---|---|---|
| A | 0 | PASS — save to Notion |
| B | 1–2 | PASS — save to Notion; violations noted for optional cleanup |
| C | 3–4 | FAIL — return to writer (revision loop) |
| D | 5+ | FAIL — return to writer (revision loop) |

**Hard fails (override grade, always FAIL regardless of count):**
- Fabricated proof (Check 9)
- Word count ceiling exceeded by more than 10% (Check 1)

**Loop cap:** 2 revision loops maximum. After loop 2, if still C/D, flag to user — do not loop further.

## Violation Taxonomy

Each violation report must include:
1. **Check number and name**
2. **Exact quoted text** (not a paraphrase)
3. **Rule violated** (e.g., "§2 banned vocabulary — 'transformative'")
4. **Fix type:** one of: delete / replace / restructure / rewrite sentence

Example:
```
Violation 1:
Check: 3 — Banned phrases
Quote: "Here's the thing about documentation strategy:"
Rule: §3 LinkedIn opening/transition bans — "Here's the thing"
Fix: restructure — remove the transition phrase; open with the claim directly
```
