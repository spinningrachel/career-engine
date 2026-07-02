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

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

**Writing personal data (R-37).** Every reference target in the map below lives in `${CAREER_DATA}/references/...`, not in the plugin. Apply the orchestrator's **Writing personal data** rule: in Claude Code, write the `career-data` files directly; in Cowork, stage the change to the output folder and emit the Appendix-A handoff (`${CLAUDE_PLUGIN_ROOT}/references/career-data-skill-handoff.md`) for the user to apply in Chat — never write a divergent copy. Refresh the `career-data` backup export after a direct write.

**Scope:** this skill handles materials the user brings to you — updated CVs, new testimonials, portfolio items, changed role facts, positioning documents, voice samples, new reference documents. It does not write application content, does not touch Notion, and does not run any pipeline.

---

**─── THE PRIME RULE — NEVER ASSUME ───**

When anything about an item is ambiguous — what it is, where it belongs, whether it updates or replaces existing content, or how a new file should be used — **stop and ask the user. Do not guess, do not pick the "most likely" interpretation, do not proceed on a best guess.** Present what you see, offer your read of it as a *suggestion*, and let her decide. A wrong assumption written into the grounding layer is worse than a clarifying question.

---

## The Reference Map

Classify every shared item against this map. Multiple items in one document are classified separately (e.g., a CV contains role facts AND a summary).

| Content type | Destination | Operation notes |
|---|---|---|
| Role facts — companies, dates, titles, teams, metrics, deliverables | `background/background-role-facts-<company>.md` (one file per company, loaded via router in `02-professional-background.md`) | **Approved CV bullets are protected** — see Protected Content below |
| CV summaries | `background/background-cv-summaries.md` | Tag with domain and validation status |
| Testimonials and recommendations | `background/background-testimonials.md` | Include name, title, company, relationship |
| Portfolio and work samples | `background/background-portfolio.md` | Include links |
| Motivation themes, standing answers, voice phrasings | `background/background-motivation-bank.md` | Append-only — same discipline as the Step 7f promotion |
| Rules, constraints, attribution and framing requirements, contact details | `references/01-writing-rules.md` | Rules changes affect every agent — confirm the intent explicitly |
| Positioning, voice profile, methodology, messaging, taglines, goals, ICP, career-shift posture, employment status | `references/03-framework.md` | **The primary source of truth about the user — see Framework Updates below.** Changes here alter agent behavior everywhere; every proposal must name the behavioral consequence, not just the text change. |
| Sent cover letters for voice calibration | `references/delivered-letters/` | **Do not write directly** — route through letter-writer Option 3 (Manage Letter Examples; cap 6) |
| LinkedIn profile PDF export (new or updated) | `references/linkedin-profile.md` | **Replace, wholesale** — extract the export into the file's structure (headline, About verbatim, skills, experience entries, education), stamp the snapshot date, and supersede the previous snapshot entirely. This is the canonical base for all LinkedIn recommendations; no usage questions needed — the wiring exists. |
| Word templates (.dotx) | `${CAREER_DATA}/references/` | Personalized version only — personal data, never the plugin repo (see line 83 / R-37) |
| Anything that fits none of the above | **Unknown — ask** | See New Files below |

## Operations

Each approved item gets exactly one operation:

- **Update** — merge new information into an existing entry or section, preserving what is still true. Use when the material extends or corrects part of an entry.
- **Replace** — supersede an existing entry, section, or file wholesale. Use when the material is the new authoritative version (e.g., "here's my updated CV — replace the old role facts for [Company]"). Replacing an **existing** file or entry whose purpose is already established needs no usage questions — the wiring already exists. Confirm only the scope of what gets replaced.
- **Add** — append a new entry to an existing section, or create a new file. New entries in established sections are routine. **New files are not** — see below.

**Removals are out of scope unless explicitly instructed.** Never propose deleting reference content. If the user explicitly asks for a removal, confirm exactly what gets removed, show it before deleting, and note it in the change summary.

## New Files — the mandatory usage interview

A reference file that no agent loads is inert — it will never influence any output. So a file that has never existed cannot be created on classification alone. Before creating any new reference file, ask the user:

1. **Purpose** — what is this material for? What should it change about the outputs?
2. **Consumers** — which tasks should use it: CV writing, cover letters, coaching, sourcing, LinkedIn, all of them?
3. **When** — loaded on every run of those tasks, or only in specific situations? Pulled from when relevant, or binding rules that always apply?
4. **Fit check** — offer the alternative: does this belong *inside* an existing reference file instead? Folding content into `01`/`02`/`03` is preferred when it fits — existing files are already wired into every agent's loading table. Create a new file only when the user confirms the content genuinely doesn't fit the existing structure.

**If she can't answer the usage questions yet, do not create the file.** Park the material, summarize what's pending, and let her come back to it.

**Creating a new file requires wiring it, in the same session:**
- Add a row to `references/REFERENCES.md` (what it contains, who loads it, what does NOT belong in it)
- Add the file to the loading table of every agent that should consume it, per the answers above
- If the file holds personal data, it belongs in `career-data` (not the plugin, not the repo). Add it under `${CAREER_DATA}/references/` and wire it into the agents' loading via the `${CAREER_DATA}` data root — never commit a personal reference file to the plugin repo

An unwired file is a failed add — do not report success until the wiring is in place.

## Protected Content

- **Approved CV bullets (§7)** survived the full review cycle and are locked by the bullet-approval flow. Never silently overwrite them. If new material contradicts an approved bullet, surface the conflict: show both versions and ask which wins.
- **Approved summaries (§6)** carry validation tags. Replacing one removes its validation history — say so when proposing the replacement.
- **Motivation Bank (§5)** is append-only for pipeline writes; this skill may edit §5 entries only on explicit instruction.
- **Fabrication rule applies in full.** Everything written must be traceable to what the user provided — her words, her documents. Never embellish, infer, or fill gaps with plausible content. If material is incomplete (a role with no dates, a metric with no number), ask or store it incomplete and flagged — never complete it yourself.
- **Documented writing rules and prohibitions are protected.** Voice and tone preferences refine register, vocabulary, and style — they never implicitly weaken, modify, or create exceptions to any documented writing rule or prohibition (in `01-writing-rules.md` or `skills/writer-craft/SKILL.md`). If a stated preference conflicts with a documented behavior, surface the conflict and ask whether she **explicitly rejects that specific documented behavior**. Only an explicit rejection changes a rule — and the change is then written into the rule's home file as part of the approved proposal, never inferred from a preference.

## Framework Updates — the user changes over time

`03-framework.md` is the primary source of truth about who the user is and what she is positioning toward — and people change, grow, and shift. This skill is the standing mechanism for keeping the framework current between setup runs. Rules specific to framework updates:

- **Direct statements are valid input.** A framework update does not require a document. "I'm now primarily pursuing a shift," "add Chief of Staff to my off-limits list," "I've started a new role at [Company]," "my target stage changed" — said in chat — are exactly the material this section exists for. Capture her wording; the normal proposal-and-approval flow still applies.
- **User-confirmed means no `[DRAFT]` markers.** The `[DRAFT — confirm in interview]` discipline belongs to setup Phase 3, where the agent *infers*. Updates arriving through this skill come from the user directly and are approved before writing — write them as confirmed content. Never re-mark a confirmed section as draft.
- **Name the behavioral consequence in every proposal.** Framework changes change how agents behave — a posture change alters how every shift role is treated; an off-limits addition stops agents from ever emphasizing that direction; an ICP change shifts priority scoring. The proposal must state what will behave differently, so she approves the consequence, not just the wording.
- **Enum fields stay enums.** §Career-shift posture's Posture field takes exactly one of: `Not open` / `Open — case-by-case` / `Primarily pursuing a shift`. If her statement doesn't map cleanly to one value, ask — do not coin a fourth state.
- **Bigger than a patch?** When the change is a genuine life shift (new role, career change, pivot in goals) that touches several framework sections, offer the relevant Phase 4 questions from `career-engine-setup` for those sections instead of patching piecemeal — a short re-interview beats a guessed rewrite. Her call which to run.
- **Framework primacy cuts both ways.** Because every agent reads this file first, never let a framework update sit only in conversation — if she states a change and it is approved, it gets written. A stated-but-unwritten change is invisible to every future run.

## Procedure

1. **Intake.** Receive the materials — pasted text, file paths, or attachments. Read everything fully. Build an item inventory: one line per distinct piece of content found.

2. **Classify.** Map each item using the Reference Map. Mark each as `update` / `replace` / `add-to-section` / `new-file` / `unclear`.

3. **Clarification gate.** Collect every `unclear` and `new-file` item and every protected-content conflict into one grouped set of questions. Ask them together — one round of questions beats five interruptions. Apply the Prime Rule: suggestions are fine, assumptions are not. Do not proceed to step 4 for any item still unresolved.

4. **Proposal.** For every resolved item, show: target file and section, operation, and the exact content as it will be written (a before/after diff for updates and replacements). Then ask for approval — item by item or as a batch, her choice. **Nothing is written without approval.**

5. **Apply to `career-data`.** Write the approved changes to the `career-data` skill per the orchestrator's **Writing personal data** rule: in Claude Code, write `career-data` directly; in Cowork, stage the change to the output folder and emit the Appendix-A handoff (`${CLAUDE_PLUGIN_ROOT}/references/career-data-skill-handoff.md`) for the user to apply in Chat. Refresh the `career-data` backup export after a direct write. Never write reference updates to a session-local path and call it done.

6. **Data vs code.** Personal data goes only to `career-data`, never to the plugin repo. A genuinely new *reference-file type* and its agent wiring (REFERENCES.md rows, loading-table entries) are code changes and go to the repo with `{{...}}` placeholders. When in doubt whether something is data or code — ask.

7. **Repackage** `career-engine.plugin` if the tree changed.

8. **Report.** Summarize per item: what was written, where, and which operation. List anything parked at the clarification gate. Remind the user that the live installation picks up the changes only after the updated `career-engine.plugin` is re-uploaded.

9. **QA gate.** Per `CLAUDE.md`, the session is not complete until the QA agent has run and passed.
