---
name: cv-domain-framing
description: Domain-framing and output constraint rules for CV writing. Covers managed-vs-executed verb choices, demand-gen framing, Earlier Experience aggregation, page limits, body word count, and header/footer rules. Load before drafting or revising any CV.
---

# CV Domain-Framing Rules

Role facts, documented metrics, fabrication traps, and approved phrasings for each company are in `01-candidate-rules.md` Sections 1 and 7. The rules below are writing mechanics applied at draft time — they are not repeated in those files.

## Managed-vs-executed verb guide

When {{USER_FIRST_NAME}} managed a team or function, bullets credit her with management and ownership — not personal execution of every deliverable.

- Use "oversaw," "managed," "directed," "contributed to" for things she supervised.
- Reserve "built," "led," "owned," "ran," "secured" for things she personally executed.

## Demand-gen for build roles

When a JD asks for someone to build a demand gen motion at seed or early Series A, surface the approved builder evidence documented in `01-candidate-rules.md` Section 4. Do not flag the absence of an owned pipeline number for a build role — it is not a gap. For scaling companies (Series B+) requiring an owned attribution track record, leave unaddressed.

## Earlier Experience aggregation

- **Specialist roles outside cyber/devtools:** pre-2019 career aggregates into a single italicised "Earlier:" line.
- **Builder, Leader, or any cyber/devtools role:** break out the relevant early roles as full entries — see `01-candidate-rules.md` Section 7 for which roles to break out.

**Placement — mandatory:** The "Earlier:" line is the final entry inside `## EXPERIENCE`, placed immediately before the `## CONSULTING` section header. It must NOT appear after `## CONSULTING`. The correct section order is:

```
## EXPERIENCE
[named full-time roles, reverse chronological]
**Earlier:** [aggregated older roles]

## CONSULTING
[Contentabl]
```

Never: EXPERIENCE → CONSULTING → Earlier.

## Output constraints

**Page limit:** Two pages maximum. Bullet limits per role are defined in `01-candidate-rules.md` Section 7 — do not exceed the documented maximum for any role.

**Body word count:** Count words in the summary paragraph and experience bullets only — exclude section banners, role title lines, date lines, and skills/tools blocks. Target ~650 words. If body exceeds 800 words, cut the least-relevant bullets from lowest-priority roles before returning. A DOCX page count check runs at export — catching over-length here prevents a loop back.

**Earlier line:** No years on the "Earlier:" line. Do not write Education, Languages, or Additional sections — they are injected automatically by {{USER_FIRST_NAME}}'s Word macros after DOCX export.

**Header:** Output markdown must NOT include `{custom-style="Name"}` or `{custom-style="ContactInfo"}` blocks — {{USER_FIRST_NAME}}'s name and contact details are in the `.dotx` template header and appear automatically.
