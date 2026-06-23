---
name: linkedin-post-writer
description: "Format selection logic, hook writing rules, proof sourcing rules, and revision rules for the linkedin-post-writer agent."
---

# LinkedIn Post Writer Skill

## Format Selection

Choose the format based on the idea's content depth and evidence available.

| Format | Word range | Use when |
|---|---|---|
| **A** — Strategic framework | 800–950w | The idea has a repeatable model, multiple named proof points, or a framework the reader can immediately apply. Requires at least 2 distinct real examples. |
| **B** — Insight / analysis | 400–600w | A sharp observation backed by one or two real examples. The claim is specific; the evidence is real but limited. |
| **C** — Tactical deep-dive | 300–500w | A specific tool, technique, or step-by-step workflow. Concrete and actionable. Limited need for narrative or arc. |

**When in doubt, choose B.** Format A requires evidence depth — a weak Format A produces a padded post. Format C requires a genuinely tactical topic — a strategic observation forced into Format C produces an underdeveloped fragment.

**Never exceed the ceiling.** If a Format B idea keeps expanding past 600w, it either belongs in A (with proper evidence) or needs editing down.

## Hook Writing

The hook is the first 1–3 lines — what appears before LinkedIn's "see more" cut. It is the only thing many readers will see.

**Hook rules:**
- The hook must earn the click. It must create a specific, credible reason to keep reading — not a generic teaser.
- The hook must not mislead about the content. If the post is about documentation strategy, the hook is about documentation strategy — not a vague "here's what I learned."
- One specific claim or observation in the hook. Not a question. Not a mystery. Not "you won't believe this."

**Hook patterns that work:**
- A counterintuitive specific claim: "Most API documentation fails at the same moment — when it describes what the call does, not what the user is trying to accomplish."
- A concrete observed gap: "I've reviewed 40+ technical writing samples this year. The most common problem isn't accuracy. It's that the writer knew the answer but never explained why the reader needed it."
- A named tension the reader recognises: "PMM and technical writing teams in deep tech companies are usually solving the same problem from opposite ends. They rarely talk."

**Hook patterns that don't work (do not use):**
- Rhetorical question openers: "Have you ever wondered why...?"
- False stakes: "This changed everything for me."
- Audience-address openers: "If you're a PMM in deep tech, this is for you."
- Vague value promises: "Here are 5 things I wish I'd known earlier."

## Proof Sourcing

All named proof must come from `02-professional-background.md`. Do not invent outcomes, companies, or timelines.

**Using proof correctly:**
- Name the company and context, not just "a company I worked with"
- Pair the context with the specific outcome or observation, not a generic claim
- If documented proof is thin for a specific claim, use a weaker claim form: "I've seen this pattern" rather than inventing a metric

**Proof level by format:**
- Format A: 2+ distinct real examples with named context
- Format B: 1–2 named examples or one well-detailed real scenario
- Format C: 1 real example or detailed enough procedural specificity that the reader can verify the approach themselves

## Structure by Format

### Format A — Strategic Framework (800–950w)

1. **Hook** (2–3 lines) — specific claim or counterintuitive observation
2. **The problem / tension** (100–150w) — what breaks down and why; must be specific to the domain
3. **The framework** (400–500w) — 3–5 distinct components, each with: name, what it is, why it matters, one real example
4. **The synthesis** (100–150w) — what holds the framework together; what changes when you apply it
5. **Close** (1–2 lines) — direct, no call-to-action that asks for engagement

### Format B — Insight / Analysis (400–600w)

1. **Hook** (1–2 lines)
2. **The observation** (100–150w) — what you noticed and when; specific context
3. **The evidence** (150–200w) — the real example(s) that grounded the observation
4. **The implication** (100–150w) — what this means in practice; who it matters to and why
5. **Close** (1–2 lines)

### Format C — Tactical Deep-Dive (300–500w)

1. **Hook** (1–2 lines)
2. **The problem this solves** (50–75w) — the specific situation this applies to
3. **The steps / approach** (150–250w) — concrete, numbered or bulleted, actionable
4. **The caveat or edge case** (50–75w) — where this breaks down; this signals expertise, not weakness
5. **Close** (1 line)

## Revision Rules

When applying reviewer feedback:

1. **Surgical-only.** Touch only the exact sentences or phrases the reviewer cited. Everything else stays word-for-word.
2. **No new content without evidence.** If fixing a violation requires adding a claim, that claim must be in `02-professional-background.md`.
3. **Fix the rule, not the surface.** If the reviewer flagged an em dash, the fix is deletion or restructuring — not swapping it for a semicolon and hoping the reviewer doesn't notice the same pause.
4. **Word count discipline.** After revision, the post must still be within the format ceiling. If fixing violations would push past the ceiling, cut elsewhere in the same section — do not expand other sections.
5. **Do not address the reviewer in the revision.** Return the corrected draft only. No "I've addressed your feedback by..." preamble.
