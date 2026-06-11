---
name: linkedin-profile
description: Snapshot of the user's current LinkedIn profile. The canonical base for every LinkedIn recommendation the plugin produces — the orchestrator's Step 8 LinkedIn updates file and every linkedin-coach mode analyse against THIS content, never against an imagined profile. Replaced wholesale (via update-refs) whenever the user exports a fresh LinkedIn PDF after making changes.
---

# LinkedIn Profile Snapshot

> **Snapshot date:** {{LINKEDIN_SNAPSHOT_DATE}}
> **Source:** LinkedIn PDF export ("Save to PDF" on your own profile)
> **How to update:** export a new PDF from LinkedIn after any profile change and say "update my references" — the new export replaces this file wholesale. Recommendations are only as good as this snapshot is current.
> **Optional:** this reference may be skipped at setup. While it is missing or still templated, LinkedIn outputs run in fallback mode (raw market signals, no profile analysis).

---

## Headline

{{LINKEDIN_HEADLINE}}

## Location

{{LINKEDIN_LOCATION}}

## Contact and links

{{LINKEDIN_CONTACT_LINKS}}

## Top Skills

{{LINKEDIN_TOP_SKILLS}}

## Languages

{{LINKEDIN_LANGUAGES}}

## Certifications

{{LINKEDIN_CERTIFICATIONS}}

## About

{{LINKEDIN_ABOUT_VERBATIM}}

## Experience

*(One entry per role, verbatim from the export: company, title, dates, location, description.)*

### {{COMPANY}} — {{TITLE}} ({{DATES}})

{{ENTRY_TEXT}}

## Education

{{LINKEDIN_EDUCATION}}
