---
name: gatekeeper-checks
description: 'Check definitions for the gatekeeper agent. Three checks: CV Check, Cover Letter Check, Coach Output Check. Load this skill before running any gatekeeper check.'
---

# Gatekeeper Check Definitions

> **Letter pipeline file.** Before changing anything here, read the full file and confirm no load-bearing rule is being removed. Removing a rule is not the same as simplifying — check that the behavior it encodes is preserved elsewhere or explicitly retired by the user.

**Why this file is shaped the way it is.** Aggressively trimmed to gates with demonstrated evidence, using the same evidence base and methodology as `skills/writer-craft/SKILL.md` (the writer-facing doctrine this file enforces): (a) real production violations traced from actual pipeline sessions, and (b) gaps found via condensed-prompt gatekeeper experiments this session. Every gate below either fired as a real traced violation, defines document correctness (not style), or closes a gap the writer doctrine states but no check previously enforced. **Coherence rule:** every gate here checks something `writer-craft/SKILL.md` actually tells the writer to do — no gate exists here for a rule the writer skill doesn't state. Structured as numbered gates, hard-fail vs advisory labeled per item, mirroring the condensed-prompt structure that tested well this session.

---


## Where the checks live (context-diet split, 2026-07-22)

The three check definitions were split into sub-files in this directory so each gatekeeper spawn
loads only the check it was asked to run. Gate numbers are preserved verbatim.

| Sub-file | Check | Load when the spawn prompt says |
|---|---|---|
| `cv-gates.md` | CV Check (Gates 0–5) | "CV Check" |
| `letter-gates.md` | Cover Letter Check (Gates 1–9 + Grading and Pass Threshold) | "Cover Letter Check" |
| `coach-gates.md` | Coach Output Check | "Coach Output Check" |

**Loading rule:** the gatekeeper reads exactly ONE sub-file per spawn — the one matching the
check named in its spawn prompt. The Tier 1 / Tier 2 grading thresholds (100% / ≥70%) live in
`letter-gates.md` § "Cover Letter Check — Grading and Pass Threshold" and remain the source of
truth for `agents/gatekeeper.md`'s output templates (cross-file contract). Nothing was removed
in the split (verified by byte-identical reassembly at split time).
