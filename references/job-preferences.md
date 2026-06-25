---
name: job-preferences
description: Job search preferences — covering remote compatibility, target roles, seniority, industries, company stage, location, employment type, exclusions, and coaching prioritization. Load before any sourcing, scoring, or coaching step.
---

# Job Preferences

Load this file before any sourcing, scoring, or coaching step. It governs both what gets added to the pipeline and how the coach prioritizes across roles.

---

## Remote Compatibility

This check is mandatory before scoring priority. "Remote" does not mean the same thing everywhere, and misreading it wastes significant effort.

**NOT compatible:**
- Remote({{USER_COUNTRY_ABBR}}), Remote – {{USER_COUNTRY}}, Remote ({{USER_COUNTRY_ABBR}} only), "Must be authorized to work in {{USER_COUNTRY}}" — hard no if {{USER_LOCATION_COUNTRY}} is not the same
- Remote with a specific country qualifier that excludes {{USER_LOCATION_COUNTRY}}
- Any role requiring work authorization in a country {{USER_FIRST_NAME}} is not authorized to work in

**Confirmed worldwide compatible:**
- "Remote (Worldwide)", "Work from anywhere", "Open to candidates globally", "No timezone restrictions"
- Remote with no country qualifier AND the company's other open roles consistently show no country qualifier
- "Remote + [region that includes {{USER_LOCATION_COUNTRY}}]"
- Company About page explicitly states a distributed global team

**Ambiguous — requires research:**
- "Remote" with no qualifier on this role, BUT other roles at the same company have country-specific qualifiers → treat as NOT compatible unless confirmed otherwise
- "Remote" with no qualifier and company hiring pattern is unclear → flag as ambiguous and state what was checked
- Hybrid or remote-first language without geographic scope → research the company's hiring page

**Rule:** When in doubt, classify as `Ambiguous` rather than worldwide-compatible. A false positive here wastes more effort than a false negative. Set `Remote compatibility` in output accordingly.

---

## Target Roles and Seniority

**Target titles (in priority order):**
{{TARGET_TITLES_LIST}}

**Seniority floor:** {{SENIORITY_FLOOR}}. Individual contributor roles are excluded unless explicitly requested.

**Function:** {{TARGET_FUNCTION}}. Roles outside this function are low priority unless there is a clear match.

---

## Industry and Domain Preferences

**High-fit domains (prioritize):**
{{HIGH_FIT_DOMAINS}}

**Medium-fit domains:**
{{MEDIUM_FIT_DOMAINS}}

**Low priority / deprioritize:**
{{LOW_PRIORITY_DOMAINS}}

---

## Company Stage

**Preferred:** {{PREFERRED_COMPANY_STAGE}}

**Also viable:** {{VIABLE_COMPANY_STAGE}}

**Lower priority:** {{LOW_PRIORITY_COMPANY_STAGE}}

---

## Location and Work Mode

**Location:** {{USER_LOCATION}}. All roles must be remote-eligible from {{USER_LOCATION_COUNTRY}} — see Remote Compatibility section above.

**Work mode preference:** {{WORK_MODE_PREFERENCE}}.

**Time zones:** {{TIMEZONE_PREFERENCE}}

---

## Employment Type

**Preferred:** Full-time, permanent.

**Acceptable:** Contract-to-hire if the role is substantive and could become permanent.

**Excluded by default:** Pure contract, freelance, part-time, fractional (unless explicitly requested in a given session).

> **Standing screening answers live elsewhere.** Travel willingness, relocation, security clearance, compensation floor, and availability/notice are held as structured fields in `screening_answers` in `pipeline-preferences.json` — not here. The coach reads both (this file plus `screening_answers`) for a complete fit picture. Keep them there to avoid duplication; this file owns role-type, seniority, domain, stage, remote eligibility, and employment-type preferences.

---

## Exclusion Patterns

Exclude roles matching any of these patterns unless explicitly overridden:
{{EXCLUSION_PATTERNS}}

---

## Coaching Prioritization

When the coach must select or rank roles (e.g., when >5 are in the queue), apply this priority order:
{{COACHING_PRIORITIZATION}}
