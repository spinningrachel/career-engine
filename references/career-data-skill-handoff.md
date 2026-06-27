# career-data skill handoff — create, install, update (Appendix A)

This is the canonical procedure for getting the `career-data` skill into the right place,
in every environment. Other files refer to it as **"Appendix A"** or **"the Appendix-A handoff."**
When they do, they mean this file.

It exists because the single hardest step of setup — turning the authored career-data files
into an installed, shared skill — depends on a platform reality that is easy to get wrong.

---

## The platform reality (read this first)

Three facts govern everything below:

1. **The career-engine plugin runs in Cowork and Claude Code only — NOT in Chat.** A
   non-technical user almost always runs setup from **Cowork**.
2. **Skills are shared between Chat and Cowork** (one Desktop app skill store). A skill
   created in Chat is immediately available in Cowork, and vice-versa.
3. **`/skill-creator` lives in Chat.** It is the reliable way to turn a folder of files into
   an installed `.skill`. Cowork cannot reliably save a skill itself — it writes `SKILL.md`
   to a nested session path and the "Save Skill" step fails with *"SKILL.md must be in the
   top-level folder."*

Put together: **the user runs setup in Cowork, but `career-data` must be born in Chat.** The
job of setup is therefore not to install the skill from Cowork — it is to hand the user a
ready-to-paste Chat prompt that does it for them. Because Chat and Cowork share a skill store,
once Chat creates `career-data` it is instantly usable back in Cowork with no extra step.

| Environment user is in | How `career-data` gets created/installed |
|---|---|
| **Cowork** (the common case) | Setup authors the files, then emits a `/skill-creator` handoff prompt. User copies it to **Chat**, runs `/skill-creator`, pastes, presses Enter. Skill appears in both Chat and Cowork. |
| **Claude Code (CLI)** | Setup writes the skill directly to `~/.claude/skills/career-data/`. No handoff needed. (Technical users only.) |
| **Chat** | The plugin does not run here, so setup never starts here. Chat is only the *destination* for the Cowork handoff. |

---

## The visual the agent must show (Cowork handoff)

When setup is in Cowork and reaches the build step, **lead with a visual, not a wall of text.**
Render this four-step strip (use an artifact/HTML visual if the environment supports it;
otherwise show the plain-text version). Keep words minimal — the user should grasp it in one
glance.

```
  ┌──────────────┐   ┌──────────────┐   ┌────────────────────┐   ┌──────────────┐
  │  ① COPY      │ → │  ② OPEN      │ → │  ③ TYPE            │ → │  ④ PASTE     │
  │  the prompt  │   │  Chat        │   │  /skill-creator    │   │  + press     │
  │  below ⤵     │   │  (not Cowork)│   │  (must be installed)│   │  Enter ⏎     │
  └──────────────┘   └──────────────┘   └────────────────────┘   └──────────────┘

  Chat and Cowork share skills — once Chat builds it, it's ready in Cowork too.
```

Then output the handoff prompt in a single copyable block (below). One sentence above it:
*"Copy everything in the box, paste it into Chat after `/skill-creator`, and press Enter."*

---

## The Cowork → Chat create prompt (handoff template)

Fill this with the user's authored content at runtime, then present it as one copyable block.
Embed the text files inline; for binary files (the `.dotx`) and the delivered-letter examples,
instruct the user to attach them in Chat.

```
Create a skill called career-data using /skill-creator.

career-data is a personal data store for the career-engine plugin. It holds my writing
rules, professional background, positioning framework, and pipeline configuration. Build it
as a skill with this exact structure, then package and install it via Customize → Skills:

career-data/
├── SKILL.md
├── career-data-marker.json
└── references/
    ├── _STRUCTURE-DO-NOT-CHANGE.md   ← the structure contract; preserve section structure
    ├── 01-writing-rules.md
    ├── 02-professional-background.md
    ├── 03-framework.md
    ├── linkedin-profile.md
    ├── job-preferences.md
    ├── pipeline-preferences.json
    ├── <cv-template>.dotx        ← I will attach this file
    └── delivered-letters/        ← I will attach these files, if any

SKILL.md contents:
[FULL SKILL.md CONTENT — the description must say this is the career-engine personal data
store, loaded on request, never auto-applied]

career-data-marker.json contents:
[FULL MARKER JSON — including expected_files list, which MUST list
references/_STRUCTURE-DO-NOT-CHANGE.md alongside every other file]

references/_STRUCTURE-DO-NOT-CHANGE.md contents:
[FULL CONTENT, untruncated — a verbatim copy of the plugin's
references/career-data-structure.md. This is the structure contract: it lists every
load-bearing file and section heading and the Section 5 Motivation Bank table format.
Keep it inside the skill so it sits in front of you on every future edit. Edit content
WITHIN sections freely; do NOT rename, renumber, reorder, or delete any section or file,
and do NOT change the Motivation Bank table format — structural changes go through the
career-engine update-refs skill, not an ad-hoc edit.]

references/01-writing-rules.md contents:
[FULL CONTENT, untruncated]

references/02-professional-background.md contents:
[FULL CONTENT, untruncated]

references/03-framework.md contents:
[FULL CONTENT, untruncated]

references/linkedin-profile.md contents:
[FULL CONTENT, untruncated]

references/job-preferences.md contents:
[FULL CONTENT, untruncated]

references/pipeline-preferences.json contents:
[FULL JSON, untruncated]

For the .dotx template and any delivered-letter files: I am attaching them to this message —
place them in references/ (and references/delivered-letters/ for the letters).

After building:
1. Confirm career-data-marker.json lists every file above in expected_files —
   including references/_STRUCTURE-DO-NOT-CHANGE.md.
2. Confirm references/_STRUCTURE-DO-NOT-CHANGE.md is present and matches the structure
   contract verbatim; preserve its section structure on any future edit (edit content
   within sections; structural changes go through the update-refs skill).
3. Package the directory as a .skill and install via Customize → Skills.
4. Tell me the skill is installed so I can return to Cowork and continue.

⚠️ Do NOT paraphrase any file content above. Copy it exactly as written.
```

**If the prompt is too long for one Chat message,** split at a file boundary and label
`Part 1 of N — wait for all parts before building`. The final part carries the "After building"
checklist.

---

## Claude Code path (direct write, then offer the Chat handoff)

When setup runs in Claude Code, write the skill directly to `~/.claude/skills/career-data/`
with the same structure, confirm `career-data-marker.json` lists every file in `expected_files`,
and write the first backup export to the output folder. Tell the user it is installed **in
Claude Code specifically**, and that this copy is local to Code.

Then **proactively offer the Chat handoff** — do not just mention it in passing. Chat and Cowork
share a separate skill store; a Code-only skill is invisible to them, so a user who also uses
Chat/Cowork needs `career-data` created in Chat too. Ask, with a minimal-text visual, whether
they also use Chat/Cowork and want the prompt, or are all set with Code only:

```
  career-data is installed in Claude Code ✅

  Do you also use Chat or Cowork?

  ┌──────────────────────────────┐   ┌──────────────────────────────┐
  │  YES — Chat/Cowork too        │   │  NO — Code only               │
  │  → I'll hand you a prompt to  │   │  → You're all set ✅          │
  │    create it in Chat          │   │                               │
  └──────────────────────────────┘   └──────────────────────────────┘
```

This is a question — present it and wait for the reply. If they also use Chat/Cowork, generate
the Cowork → Chat create prompt above (full file contents inline; `.dotx` and letters attached)
and present it led by the four-step visual. If Code-only, confirm done — no handoff needed.

---

## Ongoing updates (after the skill already exists)

This file covers first-time creation. For **edits to an already-installed** `career-data`
(new facts, preference changes, corrections), the mechanism is the same Cowork → Chat handoff,
but the prompt is an *update* prompt, not a create prompt. Use the format in
[`career-data-update-prompt-format.md`](career-data-update-prompt-format.md):

- **In Claude Code:** write the change directly to `career-data`, then refresh the backup export.
- **In Cowork:** the skills mount is read-only — never write a divergent copy. Stage the change
  to the output folder as `pending-career-data-updates.md` and emit the update-prompt for the
  user to apply in Chat.

Either way: if the user runs both Chat/Cowork and Code, the update must be applied in both.
