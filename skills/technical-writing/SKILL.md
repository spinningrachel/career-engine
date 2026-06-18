---
name: technical-writing
description: Doctrine for the technical-writer agent. Contains core principles, the imperative rule, forbidden patterns, documentation modes, reference page style, document architecture, structure and style standards, quality indicators, and the review checklist. Load before any technical writing, editing, or review task.
---

# Technical Writing — Analysis Procedures

> **`career-data` data root (R-37).** When producing output for the user's own professional context — portfolio docs, bio text, personal brand copy, or career materials — load `${CAREER_DATA}/references/01-writing-rules.md` for voice preferences and attribution rules, and `${CAREER_DATA}/references/03-framework.md` → §Voice fingerprint for tone alignment. These files govern personal register; this skill governs document structure, clarity, and engineering style. For general technical documentation, the career-data files are optional. If `${CAREER_DATA}` was not provided (standalone invocation), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading.

---

## Working Approach

These behavioral rules govern every task — writing, editing, reviewing, and advising:

- Read existing content before suggesting changes. Match established patterns.
- Push back on ideas when doing so leads to better documentation. State the reason.
- Start with the smallest reasonable changes. Do not restructure what does not need restructuring.
- Never add content that serves the wrong audience for the guide being edited.
- When uncertain about a convention, check 2–3 existing sections of the document for precedent.

---

## Core Principles

- **Second person, active voice, confident delivery.** Address the reader as "you." State what the system does and what the reader does. Never use passive voice where active works.
- **Vary sentence length deliberately.** Very long sentences for complex relationships with multiple dependent clauses. Long sentences for procedures connecting related steps. Short sentences for emphasis and critical warnings. Never produce monotonous rhythm.
- **12th-grade reading level.** Precision over simplicity; brevity over exhaustiveness.
- **Full sentences with real connectors doing the work.** No artificial rhythm from fragmented prose broken into bullets. Reserve bullets for true lists.
- **Trust the reader.** State points directly. Remove filler words. Never explain what the reader can infer.
- **No pleasantries.** Never: "please", "kindly", "feel free to", "you may want to."
- **No hedging.** Never: "may", "might", "could potentially", "it is possible that." State capabilities as facts.
- **No marketing language.** Never: "revolutionize", "seamlessly", "leverage", "powerful", "best-in-class", "cutting-edge." State what the system does.
- **Professional, not formal.** Write like a capable colleague explaining a system — not a manual author performing expertise.

---

## The Imperative Rule

This is the most important structural rule in technical documentation.

**Imperative verbs signal "do this now."** They are reserved exclusively for procedural steps.

| Context | Correct register | Example |
|---|---|---|
| Procedures (numbered steps) | Imperative | "Run the following command." "Click **Save**." "Verify the output." |
| Chapter intros | Non-imperative | "This chapter walks through..." "The next step is to..." |
| Prerequisites | Non-imperative | "Before proceeding, X must be installed." "The following tools are required:" |
| Context and descriptions | Non-imperative | "These settings control..." "The backend connects to..." |
| Cross-references (exception) | Imperative acceptable | "See the Glossary." "See Chapter 3." |

**Never mix the two on the same line.** A sentence that begins descriptively and ends with an imperative confuses the reader about when to act.

---

## Forbidden Patterns

These patterns are prohibited in all technical documentation. They are not stylistic preferences — they are errors.

| Pattern | Reason | Correction |
|---|---|---|
| "refer to [X]" | Weak and indirect | "see [X]" with a direct anchor or link |
| "please", "kindly" | Pleasantries — use direct language | Remove; use imperative in steps, descriptive elsewhere |
| "feel free to", "you may want to", "you might consider" | Hedging | State directly what the reader does |
| "you should see", "you should be able to" | Reader-directed hedging | "The output shows..." / "Expected output:" |
| "this lets you", "this allows you to" | Describes the reader, not the system | Describe what the element or system does |
| "use this when", "good for", "when to use", "this is ideal for" | Task guidance disguised as reference | Move to a how-to article and cross-reference |
| "this is more than a cosmetic change" | Editorializing | State the technical fact directly |
| "note that", "please note" | Pleasantry wrapper | Bold the key term; use a Note or Warning block |
| "leverage", "utilize" | Inflated verbs | "use", "run", "apply" |
| "seamlessly", "revolutionize", "powerful", "best-in-class" | Marketing language | State the factual capability |
| "very", "really", "quite", "simply", "just" | Filler | Remove |
| Em dashes (—) | Disrupts scannability | Rephrase with comma, parenthesis, or a new sentence |
| Colons introducing a single item | Structural noise | "The setting controls X." not "The setting controls: X." |
| Triadic structures for rhetorical effect | Prose decoration | Write the actual content |
| Vague pronouns without named antecedents ("it", "this", "that") | Ambiguity | Name the subject |

**User voice alignment (personal-context output only).** When producing output the user will publish under their own name, also enforce the user's documented prohibitions from `${CAREER_DATA}/references/01-writing-rules.md` and the voice fingerprint from `${CAREER_DATA}/references/03-framework.md` → §Voice fingerprint. Technical writing standards govern structure; career-data governs personal register and tone.

---

## Workflow

### Before Writing

1. Identify the task type (Write / Edit / Review) and load this skill.
2. Identify the user's goal and the target audience's technical depth.
3. List prerequisites and assumptions. Name any missing technical specifications as explicit data gaps — do not fabricate.
4. Map the logical path from start to finish. Resolve the heading hierarchy before writing any content.
5. Gather all technical details: commands, paths, parameters, schemas. Request missing specifics.

### During Writing

1. Draft complete sections before refining. Do not polish sentence by sentence.
2. Verify every technical instruction. If verification is not possible (missing system access), flag the instruction as unverified.
3. Read each completed section for awkward phrasing and mixed register before moving to the next.
4. Verify heading hierarchy is logical and no levels are skipped.

### After Writing

1. Run the Review Checklist at the end of this skill.
2. Remove all forbidden patterns.
3. Verify all code samples are complete and runnable.
4. Verify all cross-references and links work.
5. Check sentence length variety throughout.

---

## Documentation Modes — Doctrine

### Write Mode

**Goal:** Create documentation that lets users complete the task without external help.

**Structure every document:**
1. Start with what the user will accomplish — stated as a fact, not a promise.
2. List prerequisites upfront, before any procedure.
3. Use clear, descriptive headings that match the reader's task ("Install the CLI", not "Installation").
4. Keep paragraphs focused: 3–5 sentences on one idea.
5. End with next steps or related resources.

**What strong Write Mode output achieves:**
- Users can complete the task without external help.
- Code samples run without modification.
- Prerequisites prevent false starts.
- Error messages are explained before the reader encounters them.
- Next steps are clear.

### Edit Mode

**Goal:** Improve existing documentation for clarity, accuracy, and usability. Preserve what works.

**Focus areas (in this order):**
1. Remove redundant explanations and restated content.
2. Strengthen weak verbs ("is used to" → "enables"; "can be found" → "lives in").
3. Eliminate jargon or define it inline on first appearance.
4. Verify technical accuracy — flag anything unverifiable.
5. Improve flow between sections.
6. Add missing context where gaps exist.

**Red flags that always require action:**
- Passive voice where active works: "The file is created by..." → "The command creates..."
- Vague pronouns without named antecedents: "It then processes..." → name what "it" is.
- Steps that assume knowledge not yet introduced.
- Code samples with no surrounding context.
- Missing error scenarios for any procedure with a failure mode.

### Review Mode

**Goal:** Evaluate documentation against quality standards. Return findings with verbatim citations.

Every finding must quote the specific offending text and state the required correction. Never paraphrase — cite exactly. Identify the three most critical issues (those that most impair usability for the target reader) and lead with them.

---

## Reference Page Style

Reference pages describe what UI elements are. They never explain how to use them, why they matter, or how things work — those belong in task articles, concept articles, and tutorials respectively.

**Required structure for every reference section:**
1. Heading
2. One sentence naming what this UI area is and where it lives
3. Optional screenshot
4. A table listing every element in the area
5. Optional: one sentence stating a non-obvious invariant (use sparingly)

**No paragraphs of prose between the intro sentence and the table.**

**Table as the default container.** If a section describes two or more UI elements, it must be a table. Bullet lists of UI elements are forbidden on reference pages.

**Table column patterns:**

| Pattern | Use when |
|---|---|
| Element \| Description | Simple UI element lists |
| Control \| Description | Action or button lists |
| Option \| Source \| Meaning | Toggles with provenance |
| # \| Name \| Description | Elements numbered in a layout screenshot |

**Cell content rules:**
- Max two sentences per cell. One is better.
- No feature-benefit language. State what the element is and what it does.
- No "you can" or "users can" — describe the element, not the user's action.
- Cross-references go inline in the cell as "See [X]", never as trailing paragraphs.
- Flag conditional elements with an italic prefix: *Conditional* — only appears when...

**What does not belong on a reference page:**
- Numbered procedures or step lists → move to the how-to article and cross-reference
- Multi-paragraph explanations of behavior → compress to one cell or move to a concept article
- "Use this when..." or "Good for..." framing → task guidance, not reference
- Tips and notes that explain why → reference describes what, not why
- Concluding paragraphs that synthesize multiple ideas

**Cross-reference pattern for reference pages:**

| This content | Lives in | Reference page does |
|---|---|---|
| "Click X to do Y" procedures | How-to articles | Cross-reference: "For the step-by-step, see [X]" |
| "How X works" concepts | Concept articles | Cross-reference: "For the concepts, see [X]" |
| End-to-end walkthroughs | Tutorial articles | Cross-reference: "For the walkthrough, see [X]" |
| "What the X panel shows" | Reference page | Table of elements |

---

## Document Architecture

A documentation set follows this hierarchy:

1. **About This Documentation** — scopes the guide, identifies the audience, references glossary and vendor docs
2. **Conceptual chapters** — explain architecture, components, how things work. Non-imperative throughout.
3. **Procedural chapters** — step-by-step installation, configuration, or usage. Imperatives in numbered steps only.
4. **Administration chapters** — settings, user management, configuration. Mixed concept and procedure.
5. **Reference pages** — describe every UI element, control, and panel as a lookup. Follow Reference Page Style rules. No procedures, no concepts, no tutorials.
6. **Appendices** — reference tables (env vars, CLI reference, services), troubleshooting, glossary, vendor documentation

Each guide targets a specific persona. All content must be pitched to that persona's technical depth.

---

## Structure Guidelines

### Heading Hierarchy

- H1: Page title (one per document)
- H2: Major sections
- H3: Subsections
- H4: Specific procedures or concepts
- Never skip levels.

### Introductory Text Rule

Every heading must be followed by at least one sentence of introductory text before any procedure, list, table, code block, or child heading. No exceptions. This grounds the reader before they encounter structured content.

### Prerequisites Section

Include when users need specific tools installed, access permissions, prior configuration, or baseline knowledge.

```markdown
## Prerequisites

Before you begin, verify you have:
- Tool X installed (version Y or later)
- Access to Z
- Completed [previous step]
```

### Procedural Writing

Every procedure follows this structure:
1. A heading with an anchor ID
2. Introductory text explaining what the procedure accomplishes
3. Numbered steps using imperative verbs
4. Verification steps showing expected output
5. Cross-reference to troubleshooting if applicable

**Actions are on their own line.** Never share a line between an action and its explanation. Separate explanation from command with a line break.

**Verification steps use descriptive language for results.** "The output shows..." or "Expected output:" — never "You should see..."

### Terminology and Capitalization

- **Product and feature names:** Establish the canonical spelling and capitalization once, then apply it exactly throughout the document set.
- **Named roles are proper nouns:** When a product defines roles (Admin, Editor, Viewer), capitalize them.
- **"user" is a common noun:** Lowercase unless starting a sentence.
- **UI elements are bold:** Button labels, panel names, menu items, and field names in bold in running text, matching their on-screen wording exactly.
- **Acronyms:** Spell out on first appearance ("OpenID Connect (OIDC)"), then acronym only. Widely recognized technology names do not need expansion.

---

## Style Standards

### Sentence and Paragraph Structure

- Short paragraphs. Sentences rarely exceed 20 words.
- Full sentences with real connectors doing the work.
- No fragmented prose broken into bullets to avoid writing.

### Feature-Benefit Pattern

Connect features to user outcomes.

**Weak:** "The API supports batch processing."
**Strong:** "Process multiple requests in a single API call to reduce latency and simplify error handling."

### Code Samples

- Always include a language identifier: ` ```python`, ` ```bash`, ` ```json`
- Show complete, runnable examples. No pseudocode in procedures.
- Add comments for non-obvious steps.
- Document expected output in comments: `# Expected output: ...`
- Multi-line commands use backslash continuation.
- Use `<placeholder>` for values the reader must replace. State immediately what to replace it with.

```python
# Fetch user data from the API
response = requests.get(f"{BASE_URL}/users/{user_id}")

# Raises an exception if the request failed
response.raise_for_status()

# Returns parsed JSON
return response.json()
```

### Tables

- Use markdown tables for short, simple data.
- Header rows are always bold.
- First column typically 25–30% width; second column fills the rest.
- Do not use tables where a simple sentence would do.

### Cross-References

- Reference other sections by display text and anchor: `[Troubleshooting](#troubleshooting)`
- When referencing another guide, use the full guide name: "see the **Deployment Guide**"
- Troubleshooting references must be specific: "Troubleshooting — Cluster Deployment" not "see Troubleshooting"

### Error Guidance

State the error condition, the cause, and the exact fix.

**Weak:** "Make sure you don't forget to set the API key or everything will break."
**Strong:** "Set your API key in the environment file. Without it, authentication requests return a 401 error."

### Troubleshooting Format

Use a two-column table:

| Issue | Solution |
|---|---|
| Error message or symptom (`monospace` if literal) | Instructive fix with exact commands |

Organize by deployment phase or component. Include foreseeable error scenarios, not just known ones.

### Documenting Gated or Limited-Availability Features

Before describing any feature as generally available, verify against the shipping configuration — not the in-code default.

| Label | Criteria |
|---|---|
| Generally available | Enabled for all users, no restricting allowlist |
| Limited rollout / beta | Globally disabled, enabled for a diverse external allowlist |
| Plan-gated | Available only on specific subscription tiers |
| Deployment-specific | Available only in certain deployment modes |
| Pre-release | Enabled in staging but not in production |
| Internal only | Do not document. Omit entirely. |
| Not shipped | Disabled everywhere, no allowlist |

**Two non-negotiable rules:**
1. Read the production configuration directly before calling anything generally available. In-code defaults are a fallback, not the authority.
2. Internal-only means do not document — no notes, no caveats, no "coming soon."

A backend flag confirms a feature is enabled in the pipeline. It does not confirm a frontend component exists. Verify the interface separately.

### When to Add Detail

Add explanation when:
- The step is non-obvious
- Multiple options exist and the choice impacts security or performance
- Users commonly make mistakes here

Skip explanation when:
- The action is standard practice for readers with the stated prerequisites
- The detail belongs in a different document — link to it instead

---

## Quality Indicators

**Strong documentation:**
- Users can complete the task without external help
- Code samples run without modification
- Prerequisites prevent false starts
- Error messages are explained before the reader encounters them
- Next steps are clear

**Weak documentation:**
- Requires expertise beyond the stated prerequisites
- Jumps between abstraction levels
- Leaves gaps in the workflow
- Uses jargon without inline definition
- Ends without direction

---

## Review Checklist

Run this checklist on every output before delivery. Each item is a binary pass/fail.

**Structure and hierarchy**
- [ ] Every heading has at least one sentence of introductory text before any list, table, procedure, code block, or child heading
- [ ] Heading hierarchy is logical and no levels are skipped (H1 → H2 → H3, never H2 → H4)
- [ ] Actions are on their own line, never sharing a line with explanatory text

**Language and register**
- [ ] Imperative verbs appear only in procedural steps — not in intros, prerequisites, or descriptive text
- [ ] No forbidden phrases: "please", "kindly", "feel free to", "you may want to", "you should see", "you should be able to", "this lets you", "refer to [X]", "use this when", "this is more than", "note that", "please note"
- [ ] No marketing language: "leverage", "utilize", "seamlessly", "revolutionize", "powerful", "best-in-class"
- [ ] No filler words: "very", "really", "quite", "simply", "just"
- [ ] No em dashes (—); no colons introducing a single item
- [ ] No triadic structures for rhetorical effect
- [ ] No vague pronouns without named antecedents ("it", "this", "that")
- [ ] Verification steps use descriptive language ("The output shows..."), never "you should see"
- [ ] Sentence length varies throughout — no monotonous rhythm

**Terminology and formatting**
- [ ] Named roles capitalized; "user" lowercase
- [ ] Product and feature names match their canonical spelling and capitalization throughout
- [ ] UI elements are bold and match their on-screen wording exactly
- [ ] Acronyms spelled out on first use

**Code and technical content**
- [ ] All code blocks have a language tag
- [ ] Placeholders use `<angle-bracket>` notation with a statement of what to replace
- [ ] Code samples are complete and runnable, not pseudocode
- [ ] Expected output is shown or documented in comments

**Reference pages, reference sections, and appendices only**
- [ ] Every section with two or more UI elements uses a table, not a bullet list
- [ ] Section intros are one sentence, not a paragraph
- [ ] No numbered procedures or step lists
- [ ] No "how it works" prose subsections
- [ ] Cross-references are inline in table cells, not trailing paragraphs

**Gated features**
- [ ] Every feature is labeled by availability (GA, beta, plan-gated, etc.)
- [ ] Availability verified against the shipping configuration, not in-code defaults
- [ ] Internal-only features are omitted entirely

**Audience and completeness**
- [ ] Content is pitched to the correct persona for this guide
- [ ] No assumptions about reader knowledge that have not been introduced
- [ ] Troubleshooting covers foreseeable errors, not just known ones
- [ ] Prerequisites prevent false starts
- [ ] The document ends with next steps or related resources
