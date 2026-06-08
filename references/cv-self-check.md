---
name: cv-self-check
description: Mandatory pre-submission self-check for CV drafts and revisions. Run every item in order before returning any CV output. Covers ATS, summary, key achievements, experience, earlier line, header, and body word count.
---

# CV Pre-Submission Self-Check

Run every item in order before returning output. The gatekeeper runs the same checks — catching violations here prevents loops.

## Role emphasis — run this before ATS

- [ ] Re-read Role emphasis. In one sentence: what does the hiring manager actually need proven by this CV?
- [ ] Does the summary lead with the answer to that question?
- [ ] Are the most prominent bullets (first bullet of first two roles) the strongest evidence for what Role emphasis identified?
- [ ] If Role emphasis calls out a specific function (e.g., developer-facing, brand, team leadership, customer research) — is that function visibly present in the CV, not buried?

## ATS — run this first

- [ ] Keyword coverage: parse the Keywords property into Critical, Important, and Nice-to-have tiers; count coverage per tier (case-insensitive, summary + bullets + skills); Critical ≥80% and Important ≥60% required — incorporate missing terms naturally where possible without fabrication; Nice-to-have is best effort only; do not keyword-stuff
- [ ] SUMMARY and EXPERIENCE headings use standard names recognisable by ATS systems
- [ ] No tables, columns, or special-character bullet markers (✓, →, ◆) in the body

## Summary

- [ ] No company names, conference names, or named clients anywhere in the summary — descriptors only
- [ ] Paragraph 1 establishes the most recent role context with a descriptor, not a company name — acceptable descriptor signals are in `01-writing-rules.md` Section 1
- [ ] Word count is 120 words or fewer, counted explicitly
- [ ] Sentence count is 4 or fewer, counted explicitly
- [ ] Paragraph count is 1 (single paragraph only)
- [ ] No tool names, platform names, client names, or role-specific metrics in the summary
- [ ] None of these phrases appear: "comfortable operating across," "proven track record," "passionate about," "results-driven," "dynamic," "extensive experience"
- [ ] No section header or label sits between the `## SUMMARY` banner and the summary text

## Key Achievements block (when present)

- [ ] No two KA bullets reference the same outcome, metric, or achievement — scan for duplicate percentages, duplicate company-specific proof points, or duplicate event references; remove or consolidate any duplicates
- [ ] Each KA bullet is a distinct achievement — not a restatement of an experience bullet in the same document

## Experience

- [ ] `## EDUCATION`, `## LANGUAGES`, and `## ADDITIONAL` do NOT appear anywhere in the output — these sections are injected by {{USER_FIRST_NAME}}'s Word macros after DOCX export and must never be included in cv-writer's markdown
- [ ] `## EXPERIENCE` contains full-time employment only, in reverse-chronological order per `01-writing-rules.md` Section 7 — Contentabl must not appear here
- [ ] `## CONSULTING` section is present and contains Contentabl
- [ ] Every named role has a RoleOverview immediately below its RoleTitle — count them; the numbers must match (applies to both EXPERIENCE and CONSULTING sections)
- [ ] No tool or app names inside any experience bullet (exemption: approved bullets from Section 7 are pre-validated — do not alter them to satisfy this check)
- [ ] Each employer is described using only the approved target market from `01-writing-rules.md` Section 7
- [ ] No opening verb appears 3 or more times across all bullets — tally and fix before returning

## Tools section

- [ ] If the Role Type is Specialist or Builder AND the JD mentions tools or platform proficiency: `## TOOLS` section is present with a relevant selection from `01-writing-rules.md` Section 8
- [ ] If the Role Type is Leader or Scaler, OR the JD does not mention tools: `## TOOLS` section is absent

## Earlier

- [ ] No years on the Earlier line
- [ ] Earlier line appears as the last entry inside `## EXPERIENCE`, immediately before the `## CONSULTING` section header — not after CONSULTING

## Header

- [ ] Output markdown does NOT include `{custom-style="Name"}` or `{custom-style="ContactInfo"}` blocks
- [ ] **BlueFont bracket check:** scan the output for any occurrence of `}{custom-style="BlueFont"}` not preceded by `]`. Every BlueFont span must be written as `[text]{custom-style="BlueFont"}`. A missing opening bracket causes pandoc to render the literal annotation string into the DOCX. Fix any unbracketed spans before returning.

## Body word count

- [ ] Body word count (summary + experience bullets only, excluding banners/titles/dates/skills blocks) is 800 words or fewer — if over, cut the least-relevant bullets from lowest-priority roles before returning
