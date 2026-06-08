---
name: career-content-bank
description: Accumulated approved career content and reusable Q&A answers. Contains approved CV summaries, role facts with approved bullets, testimonials, portfolio, and the Q&A bank. Agents load this alongside 01-writing-rules.md for any task requiring approved language, role facts, or intake answers.
---

# Career Content Bank

This file accumulates through pipeline use — it starts with the facts you know upfront (role history, contact, portfolio) and fills in over time as CVs are approved, letters land, and Q&A answers are captured.

> **Setup required.** Fill in Sections 6–10 before running the pipeline. Section 7 (Role Facts) is the most important — every CV bullet must be grounded here. The more complete and specific your role facts, the less agents will need to infer, and the fewer corrections you will need to make.

**Two types of content:**
- **Approved career content** (Sections 6–10): role facts, approved language, testimonials, portfolio — reference for CV and letter writing
- **Q&A bank** (Section 5): reusable intake answers — checked by letter-writer before generating new Notion Q&A questions

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

**Delivered letters archive:** `{{OUTPUT_FOLDER}}/final-pdfs-delivered` — cover letters and CVs {{USER_FIRST_NAME}} approved and sent. These are the highest-fidelity voice anchors available. When writing a cover letter, read any letters for similar domains or role types before writing.

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

## Section 5 — Q&A Bank

Reusable intake answers indexed by topic. Letter-writer loads this before generating Notion Q&A questions — if an answer exists here, use it directly and do not ask {{USER_FIRST_NAME}} again.

*What to put here: answers to questions that will come up repeatedly during your job search. Answer honestly and specifically — vague answers produce vague letters. You can add questions as they arise in applications. The more of these you fill in, the less the pipeline will need to ask you.*

| Question | Answer | Details |
|---|---|---|
| What's the professional observation that defines your approach — the problem you exist to solve? | {{YOUR_ANSWER}} | Core identity statement. Agents use this as the foundation for cover letter openers. Write it in your own voice, not a polished elevator pitch. |
|---|---|---|
| What's your geographic filter for roles? | {{YOUR_GEO_FILTER}} | *(e.g., "Local first, then fully remote globally, then timezone-compatible remote — no relocation.")* Apply before investing time in any non-local application. |
| Is unfamiliarity with a domain ever a real blocker for you — or can you get up to speed? | {{YOUR_HONEST_ANSWER}} | This shapes how agents handle "gap" questions in cover letters. If you learn fast, say so and give the proof. If certain knowledge is genuinely required, say that too. |
| Do you have public speaking, writing, or on-camera experience? | {{YOUR_ANSWER}} | Relevant for roles calling for thought leadership, evangelism, or external representation. |
| What's driving a career transition or unconventional application? | {{YOUR_ANSWER_IF_APPLICABLE}} | Only fill in if you're making a deliberate change or applying outside your direct background. Agents use this to frame the cover letter honestly without telegraphing weakness. |
| Do you have warm contacts at any companies you're applying to? | {{YOUR_STANDING_ANSWER}} | *(e.g., "Always write letters as if there are no warm contacts — I adjust before sending.")* |
| What types of companies or missions genuinely excite you beyond your domain expertise? | {{YOUR_ANSWER}} | Agents use this when the JD mentions mission, values, or culture fit. Honest enthusiasm is more compelling than manufactured interest. |
