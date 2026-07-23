---
name: role-prioritizer
description: "Doctrine for the role-prioritizer agent. Prioritization has no scoring or writing rubric of its own by design — this file states that constraint explicitly so a future edit doesn't quietly duplicate the career coach's Priority Framework or Role Summary rule into a second, drifting copy."
---

# Role Prioritizer — Doctrine

## Why this pipeline has no rubric of its own

Prioritization exists to be cheap and fast, not to be a second brain. Every judgment call it makes — what counts as a good Priority score, what a Role Summary should contain, how to fetch a JD — already has a single authoritative source elsewhere in the plugin. Prioritization's entire discipline is: **use those sources exactly as written, never approximate them, never maintain a lighter parallel version.**

This is a deliberate, load-bearing design choice, not an oversight:

- **Scoring doctrine drift** is exactly the failure mode the plugin's cross-file-contracts table exists to prevent. Two scoring rubrics — even two nearly-identical ones — will diverge the first time either one is edited without the other in mind, and a role could get a different Priority depending on which pipeline touched it last.
- **A second Role Summary content rule** risks a Prioritization-written summary looking or reading differently from a coach-written one, which would be a visible seam to the user between "cheap triage" and "full research" output on the same property.

## What Prioritization borrows, and from where

| Judgment | Source of truth | Prioritization's obligation |
|---|---|---|
| How to score `Priority` | `01-writing-rules.md` §1 — Priority Framework | Apply exactly, JD-only (no company/culture/landscape research — that's what full intake adds later) |
| How to fetch a JD | `career-engine-intake/SKILL.md` Step 0.5 fetch ladder | Reuse exactly — same fallback order, same fetch markers |
| What a `Role Summary` looks like | `career-coach/coach-output.md` → Output Format, the `Role summary` line | Same ≤400-char, JD-vocabulary-only content rule |
| What counts as coach-complete | `career-engine-intake/SKILL.md` Step 0.8 | Prioritization never writes enough fields to satisfy this list (it writes 5 of 13–14 required fields) — a role that only went through Prioritization must always still reach the coach |

## What Prioritization explicitly does not do

- **No company, culture, or landscape research.** Those are full-intake-only dimensions; running them here would make Prioritization expensive, defeating its purpose.
- **No location deep-scan.** `source-open-roles` runs a multi-source location compatibility scan; Prioritization does a single plain read of the JD's stated location field. If the JD doesn't state it, the value is `Unknown` — Prioritization does not go looking for it.
- **No `Priority Reason`.** That property belongs to the career coach. Writing a second, cheaper "reason" here would create two competing explanations for the same score.
- **No gap analysis, keyword extraction, strategy selection, or any of the other coach-owned properties.** See `skills/database/SKILL.md` → Property Ownership for the full list of what Prioritization does and does not write.

## Environment portability — scores-only fallback

The agent's declared database tools are bound to specific MCP server instances that not every session exposes (a Cowork VM session may carry only a different generic Notion connector). When the agent reports `SCORES-ONLY MODE`, the calling context becomes the I/O layer: it fetches the queue (database adapter §2), passes each role's data to the agent, receives the structured scores block, and performs the writeback (adapter §4) under exactly the rules in the agent's Step 3 — including the ≤400-char verification, the liveness re-check, and the Status promotion condition. The judgment stays in the agent; only the I/O moves. Never let the agent bail with a "no database tools" blocker — that is a mode switch, not an error.

## Overwrite semantics — the reason this pipeline exists

Prioritization's five written values (`Role Summary`, `Location`, `Priority`, `JD Fetch Status`, `JD Body`) are provisional by design. When a role reaches full intake, the career coach **always overwrites** `Role Summary`, `Location`, and `Priority` from scratch using full research — it never treats Prioritization's values as a draft to confirm or correct (see the cross-file-contract row in `CLAUDE.md` and `career-engine-intake/SKILL.md` Step 0.9a). Prioritization's job is narrower than it might look: help the user (and the next intake run's 5-role selection) triage a large `New` queue cheaply — not produce a value that has to be "good enough" to survive unedited.
