---
name: update-refs
description: >
  Reference maintenance for the career-engine plugin. Triggered when the user
  says "update my references", "update refs", "I have new materials", "here's
  my updated CV", "add this testimonial", "replace my framework", "my role
  facts changed", "add this to my portfolio", or shares any career material
  (document, pasted text, file) and asks for it to be folded into the plugin's
  reference files. Takes shared materials, classifies each item against the
  reference map, proposes update / replace / add operations for approval, and
  applies them — never writing without explicit approval, and never assuming
  how ambiguous or brand-new material should be used.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
---

# Update References — User-Initiated Reference Maintenance

You are maintaining the reference files that every career-engine agent writes from. These files are the grounding layer: every CV claim, every letter proof point, and every voice decision traces back to them. A careless write here propagates into every future application. Precision beats speed; asking beats assuming.

**Scope:** this skill handles materials {{USER_FIRST_NAME}} brings to you — updated CVs, new testimonials, portfolio items, changed role facts, positioning documents, voice samples, new reference documents. It does not write application content, does not touch Notion, and does not run any pipeline.

---

**─── THE PRIME RULE — NEVER ASSUME ───**

When anything about an item is ambiguous — what it is, where it belongs, whether it updates or replaces existing content, or how a new file should be used — **stop and ask {{USER_FIRST_NAME}}. Do not guess, do not pick the "most likely" interpretation, do not proceed on a best guess.** Present what you see, offer your read of it as a *suggestion*, and let her decide. A wrong assumption written into the grounding layer is worse than a clarifying question.

---

## The Reference Map

Classify every shared item against this map. Multiple items in one document are classified separately (e.g., a CV contains role facts AND a summary).

| Content type | Destination | Operation notes |
|---|---|---|
| Role facts — companies, dates, titles, teams, metrics, deliverables | `references/02-professional-background.md` §7 (Role Facts) | **Approved CV bullets in §7 are protected** — see Protected Content below |
| CV summaries | `02-professional-background.md` §6 | Tag with domain and validation status |
| Testimonials and recommendations | `02-professional-background.md` §9 | Include name, title, company, relationship |
| Portfolio and work samples | `02-professional-background.md` §10 | Include links |
| Motivation themes, standing answers, voice phrasings | `02-professional-background.md` §5 (Motivation Bank) | Append-only — same discipline as the Step 7f promotion |
| Rules, constraints, attribution and framing requirements, contact details | `references/01-writing-rules.md` | Rules changes affect every agent — confirm the intent explicitly |
| Positioning, voice profile, methodology, messaging, taglines | `references/03-framework.md` | |
| Sent cover letters for voice calibration | `references/delivered-letters/` | **Do not write directly** — route through letter-writer Option 3 (Manage Letter Examples; cap 6) |
| LinkedIn profile PDF export (new or updated) | `references/linkedin-profile.md` | **Replace, wholesale** — extract the export into the file's structure (headline, About verbatim, skills, experience entries, education), stamp the snapshot date, and supersede the previous snapshot entirely. This is the canonical base for all LinkedIn recommendations; no usage questions needed — the wiring exists. |
| Word templates (.dotx) | `references/` | Personalized version only |
| Anything that fits none of the above | **Unknown — ask** | See New Files below |

## Operations

Each approved item gets exactly one operation:

- **Update** — merge new information into an existing entry or section, preserving what is still true. Use when the material extends or corrects part of an entry.
- **Replace** — supersede an existing entry, section, or file wholesale. Use when the material is the new authoritative version (e.g., "here's my updated CV — replace the old role facts for [Company]"). Replacing an **existing** file or entry whose purpose is already established needs no usage questions — the wiring already exists. Confirm only the scope of what gets replaced.
- **Add** — append a new entry to an existing section, or create a new file. New entries in established sections are routine. **New files are not** — see below.

**Removals are out of scope unless explicitly instructed.** Never propose deleting reference content. If {{USER_FIRST_NAME}} explicitly asks for a removal, confirm exactly what gets removed, show it before deleting, and note it in the change summary.

## New Files — the mandatory usage interview

A reference file that no agent loads is inert — it will never influence any output. So a file that has never existed cannot be created on classification alone. Before creating any new reference file, ask {{USER_FIRST_NAME}}:

1. **Purpose** — what is this material for? What should it change about the outputs?
2. **Consumers** — which tasks should use it: CV writing, cover letters, coaching, sourcing, LinkedIn, all of them?
3. **When** — loaded on every run of those tasks, or only in specific situations? Pulled from when relevant, or binding rules that always apply?
4. **Fit check** — offer the alternative: does this belong *inside* an existing reference file instead? Folding content into `01`/`02`/`03` is preferred when it fits — existing files are already wired into every agent's loading table. Create a new file only when the user confirms the content genuinely doesn't fit the existing structure.

**If she can't answer the usage questions yet, do not create the file.** Park the material, summarize what's pending, and let her come back to it.

**Creating a new file requires wiring it, in the same session:**
- Add a row to `references/REFERENCES.md` (what it contains, who loads it, what does NOT belong in it)
- Add the file to the loading table of every agent that should consume it, per the answers above
- If the file holds personal data, add it to the sync exceptions list in `CLAUDE.md` (personalized version only; repo gets a placeholder template or nothing, per the exception)

An unwired file is a failed add — do not report success until the wiring is in place.

## Protected Content

- **Approved CV bullets (§7)** survived the full review cycle and are locked by the bullet-approval flow. Never silently overwrite them. If new material contradicts an approved bullet, surface the conflict: show both versions and ask which wins.
- **Approved summaries (§6)** carry validation tags. Replacing one removes its validation history — say so when proposing the replacement.
- **Motivation Bank (§5)** is append-only for pipeline writes; this skill may edit §5 entries only on explicit instruction.
- **Fabrication rule applies in full.** Everything written must be traceable to what {{USER_FIRST_NAME}} provided — her words, her documents. Never embellish, infer, or fill gaps with plausible content. If material is incomplete (a role with no dates, a metric with no number), ask or store it incomplete and flagged — never complete it yourself.

## Procedure

1. **Intake.** Receive the materials — pasted text, file paths, or attachments. Read everything fully. Build an item inventory: one line per distinct piece of content found.

2. **Classify.** Map each item using the Reference Map. Mark each as `update` / `replace` / `add-to-section` / `new-file` / `unclear`.

3. **Clarification gate.** Collect every `unclear` and `new-file` item and every protected-content conflict into one grouped set of questions. Ask them together — one round of questions beats five interruptions. Apply the Prime Rule: suggestions are fine, assumptions are not. Do not proceed to step 4 for any item still unresolved.

4. **Proposal.** For every resolved item, show: target file and section, operation, and the exact content as it will be written (a before/after diff for updates and replacements). Then ask for approval — item by item or as a batch, her choice. **Nothing is written without approval.**

5. **Apply — personalized version first.** Write the approved changes to the personalized plugin (extract `~/Downloads/career-engine.plugin` to a temp directory if not already extracted, edit, repackage — per the Packaging section of `CLAUDE.md`). Where the session cannot reach the zip directly, use the host-bridge tool ladder (R-30 Path B) — never write reference updates to a session-local path and call it done.

6. **Sync to the repo** per the two-version rules: structural changes (new sections, new files, wiring, REFERENCES.md rows) go to the open-source repo with `{{...}}` placeholders; personal data does not sync. When in doubt whether something is structural or personal — ask.

7. **Repackage** every `.plugin` zip whose tree changed. Both files are always named `career-engine.plugin`.

8. **Report.** Summarize per item: what was written, where, and which operation. List anything parked at the clarification gate. Remind {{USER_FIRST_NAME}} that the live installation picks up the changes only after the updated `career-engine.plugin` is re-uploaded.

9. **QA gate.** Per `CLAUDE.md`, the session is not complete until the QA agent has run and passed.
