---
name: upwork
description: "Upwork proposal writing, profile copy, and service catalog rules for the freelance-manager agent."
---

# Upwork Skill

## Platform Overview

Upwork is a contract marketplace where clients post jobs and freelancers submit proposals. Discovery happens two ways: clients find freelancers via profile search, or freelancers find and apply to job posts. Upwork uses a "Connects" credit system for proposals — each application costs 6–16 Connects depending on job budget.

**Rachel's use case:** positioning as a senior PMM / technical writing consultant. Her buyers are typically Series B+ startups or enterprise teams with real budget and a specific, time-boxed need.

**Key Upwork distinction from Fiverr:** Upwork buyers are more likely to read proposals carefully and compare. Quality of the proposal outweighs volume of applications. Fiverr is browse-and-click; Upwork is read-and-decide.

## MCP Tool Coverage

The Upwork MCP (`upwork_search_freelancers`) is available for **competitive research only** — checking market rates, positioning language, and how other senior PMM/TW freelancers present themselves. It does not manage Rachel's own account. All account actions (proposals, profile edits, contract management) require browser automation via `claude-in-chrome`.

## Profile Copy

### Headline

- Max 120 characters
- Most critical surface — it appears in search results and at the top of every proposal
- Format: [specific role] + [specific value] + [context or niche]
- Example structure: "Senior PMM | Technical Writing Strategy for Deep Tech Startups"
- No "guru", "ninja", "rockstar", "expert" (generic); name the specific expertise instead

### Overview (Bio)

**Structure (4 paragraphs, ~300–500 words total):**

1. **Who you are + what you do** — one concrete sentence. The specific intersection of roles and sectors.
2. **What clients get** — the specific outcomes you produce. Named deliverables, not aspirational claims. 2–3 sentences.
3. **Proof** — one or two specific proof points from `02-professional-background.md`. Real company names, real contexts. No invented metrics.
4. **How you work** — your process and what you need from clients to deliver well. Sets expectations.

**Voice rules (in addition to shared-voice-rules.md):**
- Write in first person but not confessionally — this is a professional document, not a cover letter
- No "passionate about", "love helping", "dedicated to" — state what you do, not how you feel about it
- No claims about being "top-rated" or "highly recommended" unless those are current Upwork badge statuses
- Specificity is the differentiator: the more specifically you describe your expertise, the more credible it reads

### Hourly Rate

Set from `freelance-config.md` floors. Upwork takes 20% on the first $500 with a client, then 10% up to $10k. Factor this into the floor: if your net floor is $X, your listed rate must be $X / 0.8.

## Proposals

### Proposal Structure

1. **Opening line** — address the specific problem in their job post. Prove you read it. No "Hi, I'm [Name] and I'm excited about this opportunity."
2. **Why you specifically** — 2–3 sentences connecting your documented experience to their stated need. Use real proof from `02-professional-background.md`.
3. **How you'd approach this** — brief outline of how you'd start. Shows you can think, not just execute.
4. **Clarifying questions (optional)** — 1–2 questions that demonstrate expertise. Questions that show you've thought about edge cases or dependencies they may not have considered.
5. **Rate and timeline** — one line. Don't bury it; buyers want to know early.
6. **Close** — one sentence. Direct, not performative.

**Length:** 200–350 words. Under 150 looks templated; over 400 loses busy clients.

**Proposal voice rules:**
- Open with their problem, not your biography
- The word "I" should not appear in the first sentence
- No "please find attached", "I look forward to hearing from you", "do not hesitate to contact me"
- One proposal = one job post. No boilerplate openers that could apply to any job.

### Proposal Checklist

Before submitting any proposal:

- [ ] Opening line references something specific from the job post
- [ ] Rate is at or above the floor in `freelance-config.md` (accounting for Upwork's 20% cut)
- [ ] All claimed credentials are in `02-professional-background.md`
- [ ] No prohibited vocabulary from `shared-voice-rules.md`
- [ ] Word count is 200–350
- [ ] No boilerplate opener

### Fixed-Price vs. Hourly

**Fixed-price:** use when scope is well-defined and bounded (e.g., "write onboarding documentation for X product"). Protects both parties.

**Hourly:** use when scope is exploratory or ongoing (e.g., "help us think through our PMM function"). Requires active time-tracking via the Upwork desktop app.

**Connects cost:** check the job post's stated budget before spending Connects. Jobs with "$15–$35/hr" budgets listed are not worth 12+ Connects at Rachel's rate floor.

## Service Catalog (Project Catalog)

Upwork's equivalent of Fiverr gigs — fixed-scope, fixed-price service listings that appear in search without requiring a proposal.

Structure follows the same logic as Fiverr gig descriptions:
- Lead with the deliverable, not the process
- Three tiers with distinct, unambiguous scopes
- All pricing at or above `freelance-config.md` floors (adjusted for Upwork's fee)
- Apply `skills/fiverr/SKILL.md` description structure — it applies equally here

## Competitive Research

Use `upwork_search_freelancers` to:
- Benchmark Rachel's rate against comparable senior PMM / technical writing freelancers
- Identify positioning language that's saturated (everyone says "results-driven" — avoid it)
- See what proof points top-performing profiles lead with

Search queries for benchmarking: "senior product marketing manager", "technical writing consultant B2B", "SaaS content strategist".
