---
name: career-content-bank
description: Router to background/ sub-files containing the career content bank. Load this file first, then follow the routing table to load the sub-files you need.
---

# Career Content Bank — Router

**v1.5.0+: This file is a router.** All content lives in `references/background/background-*.md` sub-files. Load this file first, then follow the routing table below to load the sub-files your task requires.

> **Sub-files are load-bearing by filename.** Never rename or remove them; agents reference them by exact path. Do not add content directly to this file — add it to the appropriate sub-file.

## Routing Table

| What you need | Sub-file | Notes |
|---|---|---|
| **Motivation Bank** — standing motivations in the user's own words | `background/background-motivation-bank.md` | The `\| Tags \| Motivation \|` verbatim table — the letter-writer's primary content and voice source; append-only |
| **Approved CV summaries** by domain | `background/background-cv-summaries.md` | Validated through the pipeline; tag each by domain and role where validated |
| **Approved CV bullets** (cross-role) | `background/background-approved-bullets.md` | Bullets that survived recruiter + hiring-manager review and apply across contexts |
| **Role facts** for a specific company | `background/background-role-facts-<company>.md` | Per-company: title, reporting, team, metrics, deliverables, framing notes, approved RoleTitle/RoleOverview; one file per company |
| **Testimonials** and recommendations | `background/background-testimonials.md` | LinkedIn recommendations, client feedback, performance review excerpts |
| **Portfolio** and work samples | `background/background-portfolio.md` | Work samples grouped by type with selection guide by domain |
| **Cross-cutting skills** | `background/background-cross-cutting-skills.md` | Skills and capabilities that span multiple roles |

> **New users:** A `background-role-facts-COMPANY1.md` template is provided — copy and rename it for each company in your history (e.g. `background-role-facts-acme.md`). Fill in at least one company before running the pipeline. Role facts are the most important content — every CV bullet must be grounded here.

## Career History Table

*Summary view for quick reference. Agents use this for career narrative framing. Maintain this table here in the router so the full arc is available without loading every role-facts file.*

| Period | Role | Company | Team | Key outcome |
|---|---|---|---|---|
| {{YEAR_RANGE}} | {{ROLE_TITLE}} | {{COMPANY}} | {{TEAM_SIZE_OR_STRUCTURE}} | {{KEY_OUTCOME}} |
| {{YEAR_RANGE}} | {{ROLE_TITLE}} | {{COMPANY}} | {{TEAM_SIZE_OR_STRUCTURE}} | {{KEY_OUTCOME}} |
