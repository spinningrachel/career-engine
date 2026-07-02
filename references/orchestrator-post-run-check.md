---
name: orchestrator-post-run-check
description: Post-run validation checklists for the New Application pipeline orchestrator. Run after all roles complete — validate at least 2 CV + cover letter pairs per run. Append results to each role's revision log file.
---

# Orchestrator Post-Run Validation

Validate at least 2 pairs (CV + cover letter) from this run — the first role produced and one other chosen at random. If fewer than 2 roles were produced, validate all of them. This step is not optional. A self-reporting cv-writer or letter-writer is not validation.

---

## CV Validation

For each CV being validated:

1. Convert to plain text: `pandoc "<output-path>/<cv>.docx" -t plain`
2. **Experience ordering:** Confirm the most recent full-time role appears first in `## EXPERIENCE` (see `02-professional-background.md` for the correct ordering), followed by other full-time roles in reverse-chronological order. Flag if any consulting/fractional entry appears in `## EXPERIENCE` — it belongs in `## CONSULTING`. Flag if `## CONSULTING` section is absent from the document.
3. **Tagline:** Confirm the subtitle under the user's name is the exact role title from the JD — not a generic descriptor. It must be the job title the user applied for (e.g., "[Role Title]"). Flag if absent, if it is a generic tagline, or if it differs from the JD role title.
4. **Repetition:** Flag any opening action verb appearing more than twice. Flag any phrase appearing verbatim in more than one bullet.
5. **Fabrication:** (Skip — enforced upstream by the cv-writer's mandatory self-check and the gatekeeper. Any CV reaching this step has already passed both gates.)
6. **JD language:** Flag any bullet that uses JD phrasing verbatim to describe something the user did, where that language does not appear in the references. **Exemption:** skip this check for any bullet that matches a bullet in `02-professional-background.md` (Role Facts) exactly or with only minor role-specific adaptation — approved bullets predate the JD and cannot have been lifted from it.

**Results:** If flags found — append to the matching role's revision log file (`revision-log-<roletitle>-<company>-<monYYYY>.md`) under `## CV Validation Issues`. If no flags — append: `CV validation passed.`

---

## Cover Letter Validation

For each cover letter being validated:

1. Convert to plain text: `pandoc "<output-path>/<cover-letter>.docx" -t plain`
2. **Greeting:** Confirm the letter opens with "Hi to the" — not "Dear" or any formal variant.
3. **Word count:** Count body words (excluding greeting and sign-off). Flag if over 320 words (no minimum).
4. **Key proof signals:** Confirm that key proof signals from `02-professional-background.md` (Role Facts) — the most recent role's key outcomes — are woven naturally into the body. Flag if the body contains no named outcomes from the candidate's background.
5. **Sign-off:** Confirm the letter closes with "Looking forward to next steps," followed by the user's full name and nothing else. Flag any additional text after the name.
6. **Opening paragraph:** Confirm the first paragraph is the user's personal reaction to this specific role — first person, her response to the opportunity, before any credential or company description. This check cannot be waived by coach output or Strategy. Flag if the first paragraph: leads with company analysis; leads with a career credential; leads with an availability statement; OR has the user as the grammatical subject of the first sentence but the sentence pivots immediately to a general market/industry observation rather than her reaction to THIS role (Pattern G2). Also flag if the very first sentence frames an industry challenge or market condition before the user appears as a reacting subject (Pattern I).
7. **Fabrication:** (Skip — enforced upstream by the letter-writer's mandatory self-check and the gatekeeper. Any letter reaching this step has already passed both gates.)
8. **Voice:** Flag any sentence that opens with a gerund, prepositional phrase, or dependent clause instead of the user as subject. Flag any hollow phrase from the banned list in `skills/writer-craft/SKILL.md`.

**Results:** If flags found — append to the matching role's revision log file under `## Cover Letter Validation Issues`. If no flags — append: `Cover letter validation passed.`
