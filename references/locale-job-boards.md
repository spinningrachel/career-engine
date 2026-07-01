---
name: locale-job-boards
description: Per-country starter catalog of common job boards (ATS, VC portfolio boards, local aggregators) for source-open-roles Tier 5 and the setup locale seed. Public board data only — no personal data.
---

# Locale Job Boards — Starter Catalog

A per-country map of the boards that dominate a given locale but are missing from the default US/global catalog. `source-open-roles` reads this for **Tier 5 — Locale boards**; setup's job-preferences seed proposes a country-filtered shortlist the user edits into `preferred_job_sites` / `local_job_sites`.

This file holds **public, generic board lists only** — never personal data. The user's chosen boards live in their `career-data` config, not here.

How to use a row: search each board with the run's Keyword Expansion (each title variant), via the `site:<domain> "[title]"` pattern or the board's own search where a direct fetch works. Skip boards already in the user's configured set.

| Country | ATS / startup hubs | VC portfolio boards | Local aggregators | Localized majors |
|---|---|---|---|---|
| **Israel** | Comeet (dominant Israeli startup ATS — `site:comeet.com [title]` / `site:comeet.co [title]`) | Vertex Ventures, Aleph, Pitango, Team8, TechAviv portfolio job boards | Jobify, Secret Hunter, Happly | `il.indeed.com`, LinkedIn (Israel), AllJobs, Drushim |
| **United Kingdom** | Greenhouse/Lever/Ashby (UK orgs) | Balderton, Index, LocalGlobe portfolio boards | Otta, WelcometotheJungle UK | `uk.indeed.com`, LinkedIn (UK), Reed, Totaljobs |
| **Germany** | Personio-hosted, Greenhouse/Lever | Cherry, HV Capital, Project A portfolio boards | WelcometotheJungle DE | `de.indeed.com`, LinkedIn (DE), StepStone, Xing |
| **United States** | Greenhouse, Lever, Ashby, Workday, Rippling | a16z, Sequoia, First Round, General Catalyst portfolio boards | BuiltIn (city editions), Wellfound | `indeed.com`, LinkedIn (US), Glassdoor |
| **Generic / default** (no country row matches) | Greenhouse, Lever, Ashby, Workday | a16z, First Round portfolio boards | Wellfound, Welcome to the Jungle | LinkedIn (localized), Indeed (country edition), Glassdoor |

**Adding a country:** append a row with the same columns. Keep entries to real, well-known public boards. Do not include any board that requires the user's personal credentials or that is specific to one person.
