---
name: career-content-bank
description: Accumulated approved career content and reusable motivation material. Contains approved CV summaries, role facts with approved bullets, testimonials, portfolio, and the motivation bank. Agents load this alongside 01-writing-rules.md for any task requiring approved language, role facts, or reusable motivation content.
---

# Career Content Bank

This file accumulates through pipeline use — it starts with the facts you know upfront (role history, contact, portfolio) and fills in over time as CVs are approved, letters land, and new Why I Want This Role content is promoted into the motivation bank.

> **Setup required.** Fill in Sections 6–10 before running the pipeline. Section 7 (Role Facts) is the most important — every CV bullet must be grounded here. The more complete and specific your role facts, the less agents will need to infer, and the fewer corrections you will need to make.

**Two types of content:**
- **Approved career content** (Sections 6–10): role facts, approved language, testimonials, portfolio — reference for CV and letter writing
- **Motivation bank** (Section 5): standing answers plus durable content promoted from Why I Want This Role — loaded by writers for voice calibration and reusable angles

---

## Section 6 — Approved CV Summaries

Approved for copy/paste and targeted adaptation. Add entries here as CVs are validated through the pipeline. No fine-tooth-comb review needed when the use case fits.

**The substitution pattern:** Summaries share structure but swap the named proof point. For [Domain 1] roles, anchor on [most relevant company or project]. For [Domain 2] roles, anchor on [most relevant company or project].

*What to put here: each summary targets a specific role type or domain. Build these up as you go — start with your broadest, most versatile summary and add specialized versions as the pipeline runs. Tag each with the domain and the role where it was validated.*

---

**[SUMMARY — placeholder: add your first approved summary here once a CV completes the pipeline]**

Tag format: `[SUMMARY — domain — validated: Company, Month Year]`

A strong summary for any profession follows this structure:
> [Professional category + years of experience + the core value you deliver]. [Named proof point from a specific company, project, or role — what you built, changed, or achieved and what it produced]. [Second proof point from a different context, showing range or consistency]. [What makes you distinctively qualified — your specific combination, not a list of generic competencies].

---

## Section 7 — Role Facts

Every CV claim must be grounded in this section. No inference, no extrapolation, no padding.

**Approved CV bullets** are listed per company where available. These have survived the recruiter + hiring manager review cycle. Use verbatim or adapt minimally. Do not rewrite from scratch what has already been approved.

*What to put here: for each role, document the facts an agent would need to write accurate CV bullets and cover letter proof points. The "What you built / delivered" block is deliberately more detailed than the CV — it's the source material agents draw from. Include things that are true and documentable even if they didn't make it onto the CV.*

---

### {{COMPANY_MOST_RECENT}} ({{START_DATE}} – {{END_DATE}})

- **Title:** {{ROLE_TITLE}}
- **Reporting to:** {{MANAGER_TITLE_OR_LEVEL}}
- **Function:** {{FUNCTION_DESCRIPTION}} *(e.g., IC, team lead, department head; built from scratch vs. inherited; solo vs. embedded in a larger team)*
- **Hired for:** {{HIRING_INTENT}} *(what specific problem were you hired to solve?)*
- **Team:** {{TEAM_DETAILS}} *(size, structure, who reported to you if anyone)*
- **Company:** {{COMPANY_DESCRIPTION}} *(size, stage, funding, industry, business model — enough for an agent to frame it in a CV RoleOverview)*
- **Key metrics:** {{KEY_METRICS}} *(the numbers that contextualise your work — revenue, headcount, growth rate, assets managed, caseload, patient volume, users, whatever is relevant to your field)*

**What you built / delivered:**
- {{DELIVERABLE_1}}
- {{DELIVERABLE_2}}
- {{DELIVERABLE_3}}

*What to put here: the honest, detailed account of your contribution. More expansive than the CV allows. Include outcomes with numbers where you have them. Include things that didn't make it to the CV but happened and are documentable. Agents use this as source material for bullets.*

**Framing notes:** {{FRAMING_NOTES}}

*What to put here: context agents need to avoid misrepresentation. Examples: "These are team outcomes — do not attribute to me personally." "I was one of three contributors to this result." "The project ended early due to [reason] — do not frame as abandoned or failed." "The acquisition was a success — do not frame as a layoff."*

**Approved RoleTitle:** `{{ROLE_TITLE}} | {{COMPANY_NAME}} | {{LOCATION}} | {{DATE_RANGE}}`

**Approved RoleOverview:** `{{COMPANY_DESCRIPTION_ONE_LINE}}`

*One sentence describing the company: what it does, its scale, and any context that makes the role meaningful.*

**Approved CV bullets:**
*(Add here after the pipeline validates them. Leave blank and note "[pending first pipeline run]" until then.)*

---

### {{COMPANY_2}} ({{START_DATE}} – {{END_DATE}})

*(Repeat the structure above for each role in your career history, most recent first.)*

- **Title:** {{ROLE_TITLE}}
- **Reporting to:** {{MANAGER_TITLE_OR_LEVEL}}
- **Function:** {{FUNCTION_DESCRIPTION}}
- **Hired for:** {{HIRING_INTENT}}
- **Team:** {{TEAM_DETAILS}}
- **Company:** {{COMPANY_DESCRIPTION}}
- **Key metrics:** {{KEY_METRICS}}

**What you built / delivered:**
- {{DELIVERABLE_1}}
- {{DELIVERABLE_2}}

**Framing notes:** {{FRAMING_NOTES}}

**Approved RoleTitle:** `{{ROLE_TITLE}} | {{COMPANY_NAME}} | {{LOCATION}} | {{DATE_RANGE}}`

**Approved RoleOverview:** `{{COMPANY_DESCRIPTION_ONE_LINE}}`

**Approved CV bullets:**
*(pending first pipeline run)*

---

### Earlier Experience

*What to put here: for roles earlier in your career, abbreviated facts are usually enough. Add full role fact blocks only if you actively use them as proof points in CVs and cover letters. A single aggregation line or short entry per role is fine for roles more than 10–15 years back.*

**Aggregation line (use when CV space is tight):**
> *Earlier: [Job Title], [Company] · [Job Title], [Company] · [Job Title], [Company]*

**{{EARLY_COMPANY_1}} ({{DATE_RANGE}}):** {{SHORT_DESCRIPTION}}

**{{EARLY_COMPANY_2}} ({{DATE_RANGE}}):** {{SHORT_DESCRIPTION}}

---

### Career History Table

*Summary view for quick reference. Agents use this for career narrative framing.*

| Period | Role | Company | Team | Key outcome |
|---|---|---|---|---|
| {{YEAR_RANGE}} | {{ROLE_TITLE}} | {{COMPANY}} | {{TEAM_SIZE_OR_STRUCTURE}} | {{KEY_OUTCOME}} |
| {{YEAR_RANGE}} | {{ROLE_TITLE}} | {{COMPANY}} | {{TEAM_SIZE_OR_STRUCTURE}} | {{KEY_OUTCOME}} |

---

## Section 9 — Testimonials

*What to put here: LinkedIn recommendations, client feedback, performance review excerpts, and manager quotes. Agents select the most relevant for each application context. Include the person's name, title, company, and relationship to you.*

Use for consulting pitches and cover letters where social proof strengthens the case. For formal enterprise CVs, use metrics and named outcomes instead. Select the 1–2 most relevant to the specific engagement — do not cite the full list generically.

**{{RECOMMENDER_NAME}} — {{RECOMMENDER_TITLE}}, {{RECOMMENDER_COMPANY}}**
"{{RECOMMENDATION_TEXT}}"

**{{RECOMMENDER_NAME}} — {{RECOMMENDER_TITLE}}, {{RECOMMENDER_COMPANY}}**
"{{RECOMMENDATION_TEXT}}"

### Selection Guide

*Tag each testimonial by the type of role or context it supports best. Agents use this to select the most relevant.*

- {{ROLE_TYPE_OR_CONTEXT_1}} → {{RECOMMENDER_NAMES}}
- {{ROLE_TYPE_OR_CONTEXT_2}} → {{RECOMMENDER_NAMES}}

---

## Section 10 — Portfolio and Work Samples

**Delivered letters archive:** `references/delivered-letters/` (inside the plugin; cap 6, managed via letter-writer Option 3) — cover letters {{USER_FIRST_NAME}} approved and sent, exactly as sent. These are the highest-fidelity voice anchors available. When writing a cover letter, read any letters for similar domains or role types before writing.

**Portfolio URL:** {{USER_PORTFOLIO_URL}}

*What to put here: your strongest work samples, grouped by type. For each item: title, company or context, what it demonstrates about your capabilities, and a link if publicly available. Agents reference these when writing proposals and cover letters.*

*What counts as a portfolio sample varies by profession: code repositories, design files, published papers, case studies, reports, writing samples, data analyses, presentation decks, regulatory filings, documentation, legal briefs, financial models, or anything else that demonstrates your work directly.*

### {{PORTFOLIO_CATEGORY_1}}

*(e.g., Technical Work / Published Papers / Case Studies / Design Work / Writing Samples / Code / Reports)*

| Title | Company / Context | What it demonstrates | Link |
|---|---|---|---|
| {{SAMPLE_TITLE}} | {{COMPANY_OR_CONTEXT}} | {{WHAT_IT_SHOWS}} | {{LINK_OR_AVAILABLE_ON_REQUEST}} |

### {{PORTFOLIO_CATEGORY_2}}

| Title | Company / Context | What it demonstrates | Link |
|---|---|---|---|
| {{SAMPLE_TITLE}} | {{COMPANY_OR_CONTEXT}} | {{WHAT_IT_SHOWS}} | {{LINK_OR_AVAILABLE_ON_REQUEST}} |

### Selection Guide

*Tag samples by role type or domain. Agents use this to quickly identify the most relevant work for a given application.*

- {{DOMAIN_OR_ROLE_TYPE_1}} → {{SAMPLE_TITLES}}
- {{DOMAIN_OR_ROLE_TYPE_2}} → {{SAMPLE_TITLES}}

---

## Section 5 — Motivation Bank

{{USER_FIRST_NAME}}'s standing motivations and reactions, in **her own words**, tagged for retrieval. This is the **letter-writer's primary content and voice source** — the writer loads and uses this section first, ahead of any constructed alternative. The richer this bank, the less per-role `Why I Want This Role` input the pipeline needs.

**Verbatim rule (load-bearing):** every cell in the **Motivation** column is {{USER_FIRST_NAME}}'s exact words, kept **word-for-word**. Correct only grammar and spelling — never rephrase, paraphrase, summarize, "clean up," or synthesize a smoother version. The exact wording is the asset; scrappy real beats polished.

**Tags** are a comma-separated list describing where/when the entry applies in a cover letter — persona, theme, vertical, opener-vs-body, audience. The writer matches tags to the role, then uses the matching Motivation text verbatim or close to it.

**Format is fixed (a two-column `| Tags | Motivation |` table) and append-only.** Add a new row; never rewrite, merge, reorder, or delete existing rows, and never change the column layout. The pipeline's `Why I Want This Role` promotion step (new-application Step 7f; edit Step E10.5) appends new rows here, quoting {{USER_FIRST_NAME}}'s verbatim words with a source suffix. **There is no separate "Promoted from Why I Want This Role" section** — promoted content is simply new rows in this table. When the source is known, suffix the Motivation cell with *(source — e.g. Why I Want This Role — Company, YYYY-MM-DD)*.

*Seed this during setup and grow it over time. The single highest-leverage thing you can do for letter quality is to write honest, specific, emotional motivation entries in your own voice. Take your time with these — vague entries produce vague letters; the better these are, the better your letters, and the less per-role writing you have to do.*

| Tags | Motivation |
|---|---|
| core identity, problem-first opener, the problem you exist to solve | {{YOUR_CORE_OBSERVATION — the professional observation that defines your approach, in your own voice, not a polished elevator pitch}} |
