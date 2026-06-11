---
name: personal-brand
description: Build or refresh a personal brand for {{USER_FIRST_NAME}}. Uses the Why You, Why Them, Why Now framework to produce a positioning statement, audience and channel map, content pillars with cadence, and a library of bios for different contexts. Use when the user asks to build their personal brand, find their niche, position themselves, work on their online presence, refresh their bio, or think about thought leadership.
---

# Personal Brand Helper

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

Strategic positioning for your online presence, built around three questions: **Why You, Why Them, and Why Now.**

## Capabilities

| # | Capability | When to Use |
|:--|:-----------|:------------|
| A | Brand Foundation | You need a clear positioning statement before anything else |
| B | Audience and Channel Map | You know roughly what you stand for but not who for or where to show up |
| C | Content Pillars and Cadence | You have positioning and need a sustainable content plan |
| D | Bio Library | You need bios that read consistently across LinkedIn, speaker decks, podcast guesting, and your own site |
| E | Brand Refresh | You have an existing presence that has drifted from where you want to be |

---

## A. Brand Foundation

**What you need:** rough sense of expertise, target audience, and why you're investing in this now.

Walk through Why You, Why Them, and Why Now in three conversational blocks. Synthesise into:

- A one-paragraph positioning statement (4–6 sentences)
- A one-line elevator version
- Three-word brand summary: proof + point of view + audience
- The "permission slip" — the specific experience that earns the right to speak on this topic

**Questions to ask:**

**Why You:**
1. What is the one thing you are genuinely better at than most people in your field? (Not a skill — a perspective or approach.)
2. What experience have you had that others haven't, that changes how you see this domain?
3. What results have you produced that are traceable, specific, and verifiable?

**Why Them:**
4. Who is the specific person you are trying to reach? (Job title, stage of career or company, the problem they're sitting with right now.)
5. What does that person believe that is wrong, or what do they wish someone would say plainly?
6. What do they read, attend, watch, or follow?

**Why Now:**
7. What has changed in the world, the market, or the profession that makes your perspective more relevant now than 2 years ago?
8. Why are you building this now — what's the personal motivation?

**Synthesis:**

From the answers, produce:

```
## Positioning Statement

[One paragraph — 4–6 sentences. Opens with the specific result or experience that earns credibility. Names the audience explicitly. States the point of view plainly. Closes with why now.]

## Elevator Version

[One sentence. Format: "I help [specific audience] [achieve specific outcome] through [distinctive approach]."]

## Three-Word Summary

[Proof word] + [POV word] + [Audience word]
Example: "Evidence-based AI positioning for product leaders"

## Permission Slip

[One or two sentences. The specific experience — named company, named outcome, named role — that gives the right to speak on this.]
```

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/brand-foundation.md` (or `applications/[role-slug]/brand-foundation.md` if tied to a specific role).

**Content integrity rules:**
- Never invent metrics, titles, employers, awards, or publications. Use `{{PLACEHOLDER}}` when a fact has not been confirmed.
- If the positioning rests on a claim the user hasn't yet verified, mark it: `[UNVERIFIED — confirm before publishing]`
- If the user says "I want to be known for X" but their documented experience doesn't yet support X, say so directly and offer two options: (1) build the proof first (6–12 month plan), or (2) pick adjacent positioning that matches current proof.

---

## B. Audience and Channel Map

**What you need:** a positioning statement (from Capability A or your own draft) and realistic weekly time commitment.

Translate Why Them into a concrete audience and channel plan:

- Ideal audience profile: job title, sector, career stage, the problem they're sitting with
- Three-tier engagement strategy: industry voices (10–20 accounts to follow and engage with), peers (50–100 similar practitioners), rising voices (newer voices to amplify)
- Channel matrix: where the audience actually spends time — LinkedIn, X/Twitter, Substack, podcast guesting, in-person speaking, GitHub, YouTube, niche communities
- Time-budgeted options: low (30 min/week), medium (2 hrs/week), high (5+ hrs/week)

**Ask:**
1. How much time can you realistically commit to content and networking per week?
2. Are there channels you've already started (even sporadically)?
3. Are there channels you actively dislike or want to avoid?

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/audience-channels.md`

---

## C. Content Pillars and Cadence

**What you need:** a positioning statement and an audience map.

Translate positioning into three to five content pillars, then a sustainable cadence:

- Derive each pillar from Why You and Why Them — each pillar must be a topic you can write about from direct experience, not from research alone
- For each pillar: 10 specific prompt starters (questions, provocations, case observations — not generic topics)
- Repurposing logic: one long-form piece becomes a thread, then a short post, then a talk abstract
- Content mix: long-form (weekly or biweekly), mid-form (2–3 per week), short-form (daily or as-happens)
- Voice rules derived from the foundation: what you always do, what you never do, what signals your point of view

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/content-plan.md`

---

## D. Bio Library

**What you need:** a positioning statement (from Capability A).

Produce a coherent set of bios so every surface tells the same story at the right length:

- LinkedIn About — long version (2,000 chars), mid version (600 chars), trimmed (200 chars)
- LinkedIn Headline (120 chars max)
- X/Twitter bio (160 chars)
- Speaker bio — one paragraph, three sentences, one line
- Podcast guest bio (one paragraph, third person)
- Conference proposal bio (one paragraph, third person, credentials-first)
- About page for personal site (first person, 300–400 words)
- Email signature line (one sentence)

**Rules:**
- Every bio must be derivable from the same positioning statement — they tell the same story, not different stories
- No bio should contradict another
- The permission slip should appear (in appropriate form) in at least the long LinkedIn About and the speaker bio
- No fabrication — every credential, title, and metric must be confirmed

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/bio-library.md`

---

## E. Brand Refresh

**What you need:** access to current online presence (LinkedIn, personal site, recent talks or posts) and clarity on where you want to be.

Run a diagnostic before a rebuild:

1. Ask the user to paste or describe their current LinkedIn About, headline, and any recent content
2. Map current signals: what does this presence say you stand for, who for, and why now?
3. Compare against intended positioning (run Capability A inline if no foundation exists)
4. Identify drift: outdated bios, inconsistent voice across channels, content pillars that no longer fit
5. Produce a prioritised refresh plan: keep / cut / add, in what order

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/refresh-plan.md`

---

## Output Standards

- Write in the user's preferred language — do not default to any specific regional variant
- No em dashes. Use commas, semicolons, colons, or full stops instead
- No marketing hyperbole: no "game-changing", "world-class", "thought leader" (unless the user specifically uses it about themselves)
- Address the user as "you" throughout the Q&A. In bio drafts, use the person and tense appropriate to the format
- Push back gently when positioning is too generic, too aspirational, or unsupported by documented experience
- Never fabricate credentials, metrics, employers, or publications. Use `{{PLACEHOLDER}}` if a fact is unconfirmed

---

## Related Skills

- **/career-engine:linkedin-coach** — LinkedIn-specific tactics (headline mechanics, post review, content strategy). This skill builds the brand strategy layer; LinkedIn Coach turns it into LinkedIn-shaped output.
- **/career-engine:employment-coach** — for role-specific positioning, use the employment coach's GTM framing to align the personal brand with a specific application.
