---
name: cv-writing
description: CV writing reference for {{USER_FIRST_NAME}}'s job search pipeline. Contains the full list of words and phrases to avoid in CV bullets and summaries, and the approved action verb library organized by category. Load whenever writing or reviewing CV bullets. Does NOT apply to cover letters — those are governed by the cover-letter skill.
---

# CV Writing Reference

**Scope: CV bullets, summaries, and skills sections only.** These rules govern how {{USER_FIRST_NAME}}'s CV is written. They do not apply to cover letters. Cover letter guidance lives in `skills/cover-letter/SKILL.md`.

## Templates and Examples

| File | Purpose | When to load |
|---|---|---|
| `references/cv-example.pdf` | Approved full CV (HoneyBook application, May 2026) | Always — calibrate layout, bullet density, summary length, and quality standard against this. Do not copy content. |
| `references/rachel-{{USER_LAST_NAME}}.dotx` | The Word template used for DOCX export | Reference when formatting output or checking style annotations |
| `qa-bank.md` (Portfolio) | Portfolio — work samples with direct PDF links | When the role signals that demonstrated output would strengthen the application |
| `qa-bank.md` (Testimonials) | Testimonials — client endorsements | For freelance, consulting, or fractional roles where third-party validation is relevant |

---

## ATS Formatting Rules

These rules exist because ATS systems parse CVs mechanically before a human sees the document. A CV that fails ATS never reaches the recruiter — quality bullets are irrelevant if the document doesn't parse correctly.

### Keyword coverage target

The employment coach provides 8–15 Keywords in three tiers (format: `Critical: ... | Important: ... | Nice-to-have: ...`). Parse each tier separately and apply the thresholds below. Count coverage explicitly before returning any draft.

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

## Bullet Writing Formula

Use this when writing a new bullet — i.e., when no approved bullet in `qa-bank.md` (Role Facts) maps to a JD requirement. The approved bullets are always the first choice; this formula governs new composition only.

### The XYZ formula

> **Accomplished [X] as measured by [Y] by doing [Z].**

- **X** — the outcome or result (what changed)
- **Y** — the documented metric or named proof (the evidence that X happened)
- **Z** — the method or action (what {{USER_FIRST_NAME}} specifically did to produce X)

Not every bullet will have all three elements. Y is optional when the outcome is named and specific without a number. Z is optional when the method is obvious from the role context. But X is always required — a bullet without an outcome is a duty statement, not an accomplishment.

### Weak → strong transformations

These use {{USER_FIRST_NAME}}'s documented experience. Every claim in the strong version traces to `candidate-rules.md`.

| Weak (duty statement) | Strong (XYZ formula) |
|---|---|
| Responsible for managing the PMM team at Coro. | Built and led a 13-person PMM function — PR/analyst, social, field, PMM, technical writing — during 300% YoY revenue growth and $1M+ quarterly ACV. |
| Managed documentation for the Camtek integration. | Delivered five production-grade integration guides for two distinct audiences (Camtek internal engineers and end customers) — the complete knowledge transfer infrastructure for a multi-million-dollar acquisition. |
| Worked on developer portal at Lytx. | Built a 300-page developer portal that reduced partner onboarding time by 35%. |

### Rules for new bullet composition

- **Lead with the outcome, not the action.** "Reduced partner onboarding by 35% by building a 300-page developer portal" > "Built a 300-page developer portal that reduced onboarding by 35%." Both are acceptable; outcome-first is stronger.
- **Every metric must trace to `candidate-rules.md`.** If a number is not documented, do not write it. Write the named outcome without the number.
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

## Writing Structure Rules

These apply to all CV copy — bullets, summaries, and skills sections.

- **No hollow buzzwords** — "unlock," "harness," "navigate the landscape," "drive synergies," "holistic" add no information. Name the actual thing.
- **No antithesis/pivot formulas** — never write "It's not about X, it's about Y" or "This isn't just A, it's B." This kind of writing is neither clever nor persuasive and is far from {{USER_FIRST_NAME}}'s voice.
- **No triadic phrasing** — three parallel items as a rhetorical device ("the positioning, the messaging, the strategy") reads as AI-generated. Use a colon list or a single specific claim instead.
- **No em dashes as catch-all punctuation** — use commas, periods, or transition words. Em dashes are for genuine parenthetical asides, not as a substitute for thinking about sentence structure.
- **Mix sentence lengths deliberately** — very long for complex relationships, long for connected ideas, short for emphasis. Uniform length reads as template output.

---

## Words and Phrases to Avoid

These apply to CV bullets and summaries. For every generic claim removed, replace it with what {{USER_FIRST_NAME}} actually did — a specific role, outcome, or named result from `candidate-rules.md`. Never invent replacement metrics.

Do not eliminate industry-specific terminology. "SEO" or "content strategy" are legitimate descriptors in the right context. The test: does the phrase describe something specific {{USER_FIRST_NAME}} did, or does it describe a generic ideal candidate?

### Terms to avoid outright in CV copy

Results-driven, Passionate, Dynamic, Proactive, Experienced, Highly qualified, Top performer, Think outside the box, Value add, Synergy, Go-to person, Thought leadership, Industry expert, Bottom line, Big picture, Motivated, Track record, Effective, Seasoned, Action-oriented, Customer-focused, Fast-paced, Strong work ethic, Cutting-edge, Groundbreaking, Hit the ground running, Game-changer, Guru, Ninja, Rockstar, World-class, Paradigm shift, Scalable, Disruptive, Innovative, Holistic approach, Agile, Pioneer, **"translating technically complex"** (overused — name what was translated, for whom, and what changed)

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

## Reframe CV

### The Argument

{{USER_FIRST_NAME}} is not a technical writer who also does strategy. She is a product marketer and documentation architect who has spent her career at the exact inflection point where a company realizes its documentation is either an asset or a liability — and it becomes an asset on her watch. A founding technical writer will write what exists. They will not tell the company what the documentation should accomplish, where it should live, how it should be maintained, what the market needs to understand, or how to build a system that works after the writer leaves. {{USER_FIRST_NAME}} does all of that. When the company eventually needs a full-time writer, they will have something worth handing off.

This argument governs every CV produced for a Reframe role. It is not in the summary — it is the lens through which bullet selection and framing are made.

### How to write the Reframe CV

**Summary:** Do not frame {{USER_FIRST_NAME}} as an applicant for the technical writer role. Frame her as the person the company needs when it reaches the inflection point — "you don't need a writer, you need this." Use the standard summary template but anchor it in documentation architecture and GTM strategy, not writing as a craft. The summary should make it clear that {{USER_FIRST_NAME}} builds the infrastructure, not just the content.

**Bullet selection:** Choose bullets that show breadth the company cannot get from a solo writer: GTM strategy, product marketing, developer portals that cut onboarding time, compliance content that enabled sales, knowledge systems that served multiple functions. Prioritize Lytx, VL, and Coro over earlier roles for this framing. The approved bullets from `qa-bank.md` (Role Facts) are the starting point — select for breadth and strategic impact, not writing craft.

**Skills section:** Lean toward strategy and system-building skills (GTM, documentation architecture, product marketing, knowledge infrastructure). Writing tools belong but do not lead.

**Self-check:** Run `references/cv-self-check.md` in full, then run the Reframe section at the bottom of that file.
