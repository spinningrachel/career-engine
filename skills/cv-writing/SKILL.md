---
name: cv-writing
description: CV writing reference for the user's job search pipeline. Contains the full list of words and phrases to avoid in CV bullets and summaries, and the approved action verb library organized by category. Load whenever writing or reviewing CV bullets. Does NOT apply to cover letters — those are governed by the cover-letter skill.
---

# CV Writing Reference

**Scope: CV bullets, summaries, and skills sections only.** These rules govern how the user's CV is written. They do not apply to cover letters. Cover letter guidance lives in `skills/cover-letter/SKILL.md`.

## Templates and Examples

| File | Purpose | When to load |
|---|---|---|
| `references/{{CV_TEMPLATE_FILE}}` | The Word template used for DOCX export | Reference when formatting output or checking style annotations |
| `02-professional-background.md` (Portfolio) | Portfolio — work samples with direct PDF links | When the role signals that demonstrated output would strengthen the application |
| `02-professional-background.md` (Testimonials) | Testimonials — client endorsements | For freelance, consulting, or fractional roles where third-party validation is relevant |

---

## ATS Formatting Rules

These rules exist because ATS systems parse CVs mechanically before a human sees the document. A CV that fails ATS never reaches the recruiter — quality bullets are irrelevant if the document doesn't parse correctly.

### Keyword coverage target

The career coach provides 8–15 Keywords in three tiers (format: `Critical: ... | Important: ... | Nice-to-have: ...`). Parse each tier separately and apply the thresholds below. Count coverage explicitly before returning any draft.

| Tier | Required | Placement priority |
|---|---|---|
| **Critical** | ≥80% | Summary first, then bullets |
| **Important** | ≥60% | Bullets and skills section |
| **Nice-to-have** | Best effort | Wherever natural — never force |

If a term cannot be included without fabrication, leave it out. Missing terms that are genuine gaps will surface as advisory notes at the end of the pipeline — they do not trigger revision loops.

**Use the exact JD phrasing** where possible — ATS matches on exact strings. "Go-to-market strategy" and "GTM strategy" are not equivalent in many systems.

### Section heading standards

ATS systems identify sections by heading name. Non-standard names cause misclassification.

| Use | Not |
|---|---|
| SUMMARY or PROFESSIONAL SUMMARY | Profile, About Me, Introduction, Overview |
| EXPERIENCE or WORK EXPERIENCE | Career History, Professional History, Work History |
| EDUCATION | Academic Background, Qualifications, Degrees |
| SKILLS | Core Competencies only (without the word SKILLS anywhere) |

### ATS DO / DON'T

| DO | DON'T |
|---|---|
| Use standard hyphens or dashes as bullet markers | Use special characters as bullets: ✓, →, ◆, ★, ➔, •• |
| Place Keywords in body text (summary + bullets + skills) | Cluster keywords only in a skills block where they lose context |
| Spell out acronyms at least once: "Search Engine Optimization (SEO)" | Use acronyms only — ATS may not match both forms |
| Keep the document as a single-column linear flow | Use tables, columns, or sidebars in body content |
| Write dates in a consistent, parseable format | Use date formats ATS struggles with (e.g., "Spring 2022") |
| Use plain section headings as running text | Put headings inside tables or text boxes |

---

## Summary

The summary is a strategic positioning statement. Its job is to make the hiring manager's selection decision easier by immediately establishing why this specific candidate is the right person for this specific role.

**What it is not:**
- A biography or career timeline
- A list of credentials or everything the candidate has done
- A general-purpose statement that could accompany any application
- A personality declaration ("results-driven," "passionate," "dynamic")

**What it must do:**

Stake out a position. "B2B product marketing director who..." is a claim. "Experienced marketing professional with X years across..." is a description. Descriptions don't position. The summary must make the one claim the hiring manager needs to believe in order to move forward.

**How to write it — in order:**

1. **Identify the role's primary objective** — what this role exists to accomplish. Not the list of responsibilities; the underlying goal.
2. **Identify the candidate's strengths that speak most directly to that objective** — not the most recent, not the most impressive in the abstract, the most relevant to this goal.
3. **Lead with those.** The first sentence establishes the claim. Everything after it supports it.
4. **Omit anything that doesn't serve the claim** — if a credential is impressive but irrelevant to this role, leave it out.

**The alignment test:** Read the summary, then read the job description. If the connection between the two isn't immediately obvious, the summary isn't aligned enough. The hiring manager should finish the summary knowing exactly what problem this candidate solves — for this role.

**Format constraints** (enforced by gatekeeper — do not duplicate in copy):
≤120 words · 1 paragraph · ≤4 sentences · no company or client names · no tool names · no metrics unless summary-appropriate.

---

## Bullet Writing Formula

Use this when writing a new bullet — i.e., when no approved bullet in `02-professional-background.md` (Role Facts) maps to a JD requirement. The approved bullets are always the first choice; this formula governs new composition only.

### The XYZ formula

> **Accomplished [X] as measured by [Y] by doing [Z].**

- **X** — the outcome or result (what changed)
- **Y** — the documented metric or named proof (the evidence that X happened)
- **Z** — the method or action (what the user specifically did to produce X)

Not every bullet will have all three elements. Y is optional when the outcome is named and specific without a number. Z is optional when the method is obvious from the role context. But X is always required — a bullet without an outcome is a duty statement, not an accomplishment.

### Weak → strong transformations

These use the user's documented experience. Every claim in the strong version traces to `01-writing-rules.md`.

| Weak (duty statement) | Strong (XYZ formula) |
|---|---|
| Responsible for managing the [function] team at [Company]. | Built and led a [N]-person [function] team — [sub-disciplines] — during [metric: growth/revenue/etc.]. |
| Managed documentation for the [integration/product]. | Delivered [specific deliverable] for [audiences] — [named outcome or scope of impact]. |
| Worked on [project] at [Company]. | Built [specific output] that [named, measurable outcome]. |

### Rules for new bullet composition

- **Lead with the outcome, not the action.** "Reduced partner onboarding by 35% by building a 300-page developer portal" > "Built a 300-page developer portal that reduced onboarding by 35%." Both are acceptable; outcome-first is stronger.
- **Every metric must trace to `01-writing-rules.md`.** If a number is not documented, do not write it. Write the named outcome without the number.
- **One bullet, one job.** If a bullet is doing two things, split it or cut one.
- **Third person, no "I".** "Led," not "I led."

### Bullet rules

| Rule | Detail |
|---|---|
| **Outcomes first** | Lead with action verbs; describe what changed, not what the job involved. |
| **Proof** | At least one metric or named outcome per bullet where reference files support it. |
| **Third person** | Write "Led," not "I led." |
| **No tool names** | HubSpot, Salesforce, Salesloft, Moosend, Webflow, Mintlify, Chameleon, HeyReach, ZoomInfo, Chorus.ai, Notion, Jira, Slack — banned inside bullets. Approved Section 7 bullets are exempt — do not alter them. |
| **Verb tally** | No opening verb may appear 3 or more times across all bullets. Tally before returning. |
| **No repetition** | No phrase may appear verbatim in more than one bullet. |

---

## SKILLS Section

### Always include it

The SKILLS section is never optional. Every CV the user produces must contain a `## SKILLS` (or `## SKILLS & EXPERTISE`) section. Do not omit it because the JD feels execution-focused or because the experience bullets seem self-sufficient — the section serves ATS matching, skim-reading, and positioning simultaneously.

### Strategic framing, not a keyword dump

The SKILLS section is a positioning tool, not a checklist. A raw list of keywords reads as filler and leaves no impression. The section must be written with intent: what picture does it build of this candidate, and does that picture serve this specific role?

**For executive and leadership roles this matters most.** A VP of Marketing or CMO candidate who lists "Email Marketing · HubSpot · Demand Generation" looks like a practitioner, not a leader. The section should reflect the scope and strategic nature of the role being applied for — disciplines owned, functions built, domains led — not the tools used to execute them.

### Rules by role seniority

**Leadership / executive roles (VP, SVP, CMO, or equivalent):**
- Lead with functional ownership and scope: categories like "Revenue Marketing", "Brand & Positioning", "GTM Strategy", "Team Building & Org Design", "Board & Exec Communication"
- Execution-layer keywords still belong, but they sit behind or below strategic ones — they signal range, not primary identity
- Avoid leading with tool names, task-level skills, or anything that would appear on an IC's CV as a primary credential
- Use `## SKILLS & EXPERTISE` heading when the role is at this level — it signals seniority over the plain `## SKILLS` heading

**Mid-level / senior IC roles:**
- Mix of functional disciplines, key methodologies, and high-signal tools is appropriate
- Lead with the capabilities most relevant to the JD, not alphabetically or by familiarity
- Group related terms together rather than listing them flat — clusters signal coherence

**All roles:**
- Keywords from the `Keywords` property (Critical and Important tiers) must appear here if they aren't already in the summary or bullets — this is the ATS catch-all
- No hollow terms: "Results-driven", "Strategic thinker", "Passionate about marketing" — banned entirely
- No tool names that appear nowhere else in the CV as primary credentials — use `## TOOLS` for those instead
- Sequence intentionally: strongest, most role-relevant credentials first

### Format

Use a pipe-separated single line or short comma-separated groups. Do not use bullet points inside the SKILLS section — they visually compete with Experience bullets and collapse the section's skimmability.

Example for a senior marketing leader role:
```
## SKILLS & EXPERTISE
GTM Strategy · Revenue Marketing · Brand & Positioning · Product Marketing · Pipeline Programs · Content & Thought Leadership · Partner Marketing · Team Building · Budget Ownership · Exec & Board Communication
```

---

## Writing Structure Rules

These apply to all CV copy — bullets, summaries, and skills sections.

- **No hollow buzzwords** — "unlock," "harness," "navigate the landscape," "drive synergies," "holistic" add no information. Name the actual thing.
- **No antithesis/pivot formulas** — never write "It's not about X, it's about Y" or "This isn't just A, it's B." This kind of writing is neither clever nor persuasive and is far from the user's voice.
- **No triadic phrasing** — three parallel items as a rhetorical device ("the positioning, the messaging, the strategy") reads as AI-generated. Use a colon list or a single specific claim instead.
- **No em dashes as catch-all punctuation** — use commas, periods, or transition words. Em dashes are for genuine parenthetical asides, not as a substitute for thinking about sentence structure.
- **Mix sentence lengths deliberately** — very long for complex relationships, long for connected ideas, short for emphasis. Uniform length reads as template output.

---

## Words and Phrases to Avoid

These apply to CV bullets and summaries. For every generic claim removed, replace it with what the user actually did — a specific role, outcome, or named result from `01-writing-rules.md`. Never invent replacement metrics.

Do not eliminate industry-specific terminology. "SEO" or "content strategy" are legitimate descriptors in the right context. The test: does the phrase describe something specific the user did, or does it describe a generic ideal candidate?

**Never mention "works independently" or equivalent soft-skill filler.** Any experienced professional can work independently — stating it wastes a line and signals that the candidate has nothing more specific to say. The same applies to: "self-starter", "takes initiative", "manages own workload", "strong communicator" (unless communication is the literal product of the role), "team player" used as a standalone claim. If the JD requires independent work, the CV demonstrates it through the substance of the bullets — it never states it.

### Terms to avoid outright in CV copy

Results-driven, Passionate, Dynamic, Proactive, Experienced, Highly qualified, Top performer, Think outside the box, Value add, Synergy, Go-to person, Thought leadership, Industry expert, Bottom line, Big picture, Motivated, Track record, Effective, Seasoned, Action-oriented, Customer-focused, Fast-paced, Strong work ethic, Cutting-edge, Groundbreaking, Hit the ground running, Game-changer, Guru, Ninja, Rockstar, World-class, Paradigm shift, Scalable, Disruptive, Innovative, Holistic approach, Agile, Pioneer, **"translating technically complex"** (overused — name what was translated, for whom, and what changed)

**Absolute prohibitions — banned in all CV copy including summaries:**
- **"specialism"** — not a word; use "multi-disciplinary" or "[specific] disciplines" instead
- **"that made it land"** — vague AI-assembly phrase; name what it was and what happened instead
- **"behind the [noun]"** (e.g., "behind the coverage", "behind the strategy") — agent-coined abstraction; name the actual work
- **"at an inflection point"** — generic AI phrase; name the specific moment or transition instead
- **"quietly [verb]ing"** (e.g., "quietly building", "quietly scaling") — performative modesty; just name the action
- **"rare"** as a self-descriptor or claim — never self-apply; if it's true, a specific outcome demonstrates it
- **"up close"** — filler phrase; cut it

---

## Action Verbs by Category

Use these to open bullets. No verb may appear more than twice in the entire CV.

### Team Players

Acknowledged, Amassed, Anchored, Assimilated, Assisted, Augmented, Blended, Collaborated, Coalesced, Contributed, Coordinated, Cultivated, Diversified, Embraced, Enabled, Energized, Enlisted, Encouraged, Facilitated, Fostered, Forged, Gathered, Guided, Harmonized, Helped, Ignited, Joined, Melded, Merged, Motivated, Partnered, Participated, Supported, Teamed, United, Volunteered, Wove

### Leadership

Accelerated, Appointed, Authorized, Boosted, Chaired, Coached, Cultivated, Delegated, Developed, Directed, Engineered, Enabled, Evaluated, Executed, Facilitated, Fostered, Galvanized, Guided, Headed, Hosted, Implemented, Inspired, Initiated, Mentored, Mobilized, Motivated, Nurtured, Operated, Orchestrated, Oversaw, Pioneered, Presided, Reorganized, Sculpted, Spearheaded, Strengthened, Supervised, Transformed, Trained, Unified

### Instead of "Responsible for"

Accomplished, Acquired, Achieved, Acted As, Administered, Assigned, Authorized, Carried Out, Chaired, Completed, Consolidated, Coordinated, Created, Delegated, Developed, Directed, Enhanced, Established, Executed, Exceeded, Expanded, Facilitated, Finished, Forged, Improved, Implemented, Managed, Made, Navigated, Negotiated, Operated, Orchestrated, Organized, Partnered, Performed, Planned, Prepared, Prioritized, Produced, Resolved, Secured, Streamlined, Strengthened, Succeeded In, Supervised, Undertook

### Communication

Advocated, Addressed, Advertised, Announced, Answered, Articulated, Authored, Broadcasted, Clarified, Composed, Consulted, Conveyed, Convinced, Corresponded, Defined, Disclosed, Disseminated, Documented, Explained, Expressed, Fielded, Illustrated, Influenced, Informed, Interpreted, Liaised, Mediated, Moderated, Negotiated, Presented, Promoted, Persuaded, Publicized, Reported, Shared, Summarized, Transmitted

### Achievement (instead of "achieved")

Accelerated, Accomplished, Advanced, Amplified, Attained, Boosted, Completed, Created, Delivered, Elevated, Enacted, Enhanced, Exceeded, Expanded, Expedited, Executed, Generated, Improved, Increased, Lifted, Managed, Maximized, Optimized, Outpaced, Produced, Realized, Stimulated, Surpassed

### Worked on (instead of "worked on")

Arranged, Assembled, Built, Compiled, Composed, Constructed, Coordinated, Crafted, Created, Developed, Devised, Engaged In, Engineered, Established, Executed, Fashioned, Forged, Formulated, Improved, Launched, Made, Operated, Organized, Perfected, Prepared, Processed, Pursued, Refined, Resolved, Set Up, Spearheaded, Transformed, Undertook

### Improvement (instead of "improved")

Amplified, Boosted, Converted, Customized, Enhanced, Expanded, Grew, Integrated, Lifted, Maximized, Merged, Optimized, Overhauled, Raised, Redesigned, Refined, Remodeled, Reorganized, Restructured, Revamped, Revitalized, Saved, Simplified, Slashed, Streamlined, Strengthened, Transformed, Updated, Upgraded

### Research and Analysis

Analyzed, Assessed, Audited, Calculated, Checked, Classified, Collected, Critiqued, Defined, Diagnosed, Discovered, Evaluated, Examined, Explored, Identified, Inspected, Interpreted, Investigated, Mapped, Measured, Probed, Proved, Quantified, Reviewed, Studied, Surveyed, Systemized, Tested, Tracked, Uncovered, Verified

### Creativity and Problem-Solving

Altered, Built, Conceptualized, Corrected, Crafted, Designed, Determined, Devised, Drafted, Engineered, Enhanced, Established, Fashioned, Fixed, Formulated, Improvised, Initiated, Innovated, Invented, Modified, Overhauled, Patched, Piloted, Pioneered, Rebuilt, Redesigned, Reimagined, Resolved, Revised, Simplified, Streamlined

### Instead of "managed"

Administered, Aligned, Chaired, Coordinated, Cultivated, Delegated, Directed, Enabled, Facilitated, Fostered, Guided, Headed, Hired, Inspired, Mentored, Mobilized, Motivated, Organized, Oversaw, Planned, Recruited, Regulated, Shaped, Spearheaded, Steered, Supervised, Taught, Trained, Unified, United

### Instead of "assisted"

Abetted, Advanced, Aided, Boosted, Coached, Collaborated, Cooperated, Counseled, Dispatched, Encouraged, Endorsed, Expedited, Facilitated, Guided, Helped, Intervened, Maintained, Promoted, Propped, Reinforced, Salvaged, Served, Supported, Sustained, Uplifted

### Instead of "utilized"

Adopted, Applied, Deployed, Employed, Executed, Exerted, Handled, Implemented, Mobilized, Operated, Optimized, Promoted, Restored, Revived, Specialized In

### Instead of "built"

Analyzed, Developed, Directed, Authored, Prepared, Implemented, Collaborated, Liaised, Assessed, Created, Improved, Designed, Defined, Guided, Revamped, Proposed, Advised, Conducted, Arranged, Budgeted, Composed, Conceived, Controlled, Eliminated, Investigated, Operated, Organized, Planned, Processed, Produced, Redesigned, Reduced, Refined, Resolved, Revised, Scheduled, Simplified, Solved, Streamlined, Transformed, Devised, Established, Generated, Initiated, Introduced, Launched, Led, Pioneered, Started, Consolidated, Converted, Decreased, Expanded, Increased, Innovated, Reorganized, Restructured, Saved, Unified, Accelerated, Achieved, Completed, Convinced, Discovered, Mastered, Revitalized, Spearheaded, Upgraded

---
