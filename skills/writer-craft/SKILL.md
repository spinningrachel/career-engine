---
name: writer-craft
description: Consolidated writer-facing doctrine for two writer agents — cv-writer and letter-writer. Replaces skills/cv-writing, skills/cover-letter, references/cover-letter-self-check.md, and the CV/cover-letter-relevant portions of references/shared-voice-rules.md (§1-7, not §8 LinkedIn). Aggressively trimmed to rules with demonstrated evidence from real pipeline runs. Sections are tagged [ALL] / [CV] / [CL] for which surface they govern. Humanizer-specific mechanics (formerly §12 Humanizer Mechanics and §13 Voice Calibration Protocol) were relocated to skills/humanizer/SKILL.md and the remaining sections renumbered contiguously — this file no longer has a [HUM] tag or a humanizer reader.
---

# Writer Craft — Consolidated Doctrine

**Reader change (2026-07-18, per the user's approved rulebook reduction):** the letter-writer no longer loads this file — it loads `skills/letter-core/SKILL.md`, a ~1,500-word working core (preloaded via its frontmatter). This file's `[CL]` sections remain in place as the **gatekeeper's enforcement reference** (gates cite them by section number) and the maintainer's source of truth; every `[CL]` rule is either carried in letter-core or enforced at a gate — see `docs/rule-map-letter-core.md` for the complete mapping. No rule was removed.

One file's current readers: `cv-writer` (sections tagged `[CV]` plus every `[ALL]` section), the `humanizer` (`[ALL]` sections), and the `gatekeeper` (as reference). This file replaces four prior files — nothing here is optional because it moved. (The humanizer reads its own dedicated skill, `skills/humanizer/SKILL.md`, which now carries the humanizer-specific mechanics this file used to hold at former §12 Humanizer Mechanics and §13 Voice Calibration Protocol.)

**Why this file is shaped the way it is.** Real production runs hit 7-round whack-a-mole revision loops. Forensic analysis of those runs plus condensed-prompt experiments found: (1) most violations trace to a small, repeatable set of rules — not the long tail; (2) a narrowly-scoped rule ("no em dash as list separator") gets gamed around the narrow scope — bans here are stated at full width; (3) loading 3-4 large files per writer spawn has a real token cost per revision round. This file is short on purpose. Every rule below either fired in a real traced violation this session or defines document correctness (not style).

---


## Where the doctrine lives (context-diet split, 2026-07-22)

The consolidated doctrine was split into three sub-files in this directory so each reader loads
only what governs its surface. Section numbers (§1–12) are globally unique and preserved — a
citation like "writer-craft §8" resolves unambiguously to exactly one sub-file.

| Sub-file | Sections | Who loads it |
|---|---|---|
| `core.md` | [ALL] §1 Punctuation Bans · §2 Banned Vocabulary · §3 Structural Anti-Patterns · §4 Sentence Mechanics · §12 Positive Writing Standards | cv-writer, humanizer (every spawn) |
| `cv.md` | [CV] §5 CV Document Shape (Detailed) · §5b (Brief) · §6 CV Content Rules · §6b Compression and Dedup Rules | cv-writer (every spawn) |
| `letter.md` | [CL] §7 Universal Shape · §8 Opener Doctrine (incl. Annotated Exemplar) · §9 Use-Case Structures · §10 Claims and Framing · §11 Self-Check | gatekeeper (enforcement reference); maintainers. The letter-writer loads `skills/letter-core/SKILL.md` instead (2026-07-18 reader change above) |

**Loading rule:** an agent's file-loading table names the sub-files directly — do not load this
routing file at spawn time. Every rule lives in exactly one sub-file; nothing was removed in the
split (verified by byte-identical reassembly at split time).
