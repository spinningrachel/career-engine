# Career Coach — Analysis (Priority, Strategy, Properties)

Load this file after `coach-research.md` is complete and you are ready to analyze. It covers priority scoring, writing guidance, JD decoding, strategic property definitions, and patterns. When analysis is complete, load `coach-output.md` to format and return your output.

---

## Notion invocation context

The career-coach is always invoked by the intake pipeline after intake has queried the Notion database to build the Needs Research queue. The coach does not query Notion for its input list — that is intake's responsibility. This section documents the query protocol intake uses so the coach understands what state the database was in and what the ladder guarantees.

**How intake surfaces roles for the coach:** intake queries the database through the **Notion adapter** (`skills/database-notion/SKILL.md` → §2 read ladder, A1 → A2 → B, when `database_backend` is `notion`) and passes the coach fully-resolved rows. The coach does not need the mechanics — only the guarantees: rows arrive filtered to the target status with full per-page properties (Path B is discovery-only → per-page `notion-fetch`, never a parsed rendered table — R-1); and if every rung fails intake stops and reports rather than treating it as an empty queue or improvising `notion-search` (R-39).

**What the coach receives:** a list of roles with Page IDs, company names, position titles, Job URLs, and full Notion row content already resolved. The coach processes from that point forward; it does not re-query Notion for the role list.

---

## Analysis

### Settings pre-flight

Before any analysis, determine the gap handling mode in this order:

1. **Spawn prompt** — when invoked by a pipeline, the orchestrating skill passes `gap_handling_mode` in your prompt. Use it; skip the rest of this pre-flight.
2. **Career-data config** — otherwise (standalone), Read `${CAREER_DATA}/references/pipeline-preferences.json` (Read tool — you do not have Bash) and use its `gap_handling` value. **This is the user's real config and the authority** — resolve `${CAREER_DATA}` first (per the R-37 data-root block in the root SKILL.md) if it is not already set.
3. **Last-resort fallback** — only if career-data is unreachable: `~/.claude/settings.json`, then `${CLAUDE_PLUGIN_ROOT}/references/pipeline-preferences.json` (the **blank template**, which always ships the default — never the authority).
4. **Default** — if no source yields a value, use `enabled`.

- If the value is `"disabled"` (or the key is absent and you were invoked with "no gap handling" in the prompt): set a session flag `GAP_HANDLING = disabled`. **Disabling gap handling kills the gap-analysis behavior EVERYWHERE — not just the `Gap handling` property.** Specifically: skip all gap analysis in Part 2; do NOT populate the `Gap handling` property at all (do not write `N/A`); and **the coach context block's transfer/credibility line must NOT enumerate gaps, name "the X real gaps," catalog what she lacks, or do any gap framing.** A disabled feature that still parks gap analysis in the transfer note has leaked — that is the seam this rule closes. The transfer line may still state the one-line credibility-of-transfer argument (an affirmative "her [X] transfers because [Y]"), but never a gap inventory.
- If the value is `"enabled"` or the key is absent (default): set `GAP_HANDLING = enabled`. Proceed normally.
- A per-role override always wins: if the user included "no gap handling" in their prompt for this run, treat as disabled for this run only.

### Part 0 — Priority scoring (full research roles)

This step runs only for roles that reached full research (Priority 1–4 from triage, pre-scored roles, or `--full-research` runs). For Priority 5–6 triage-exit roles, Priority and Priority Reason were already written in Step 2c and are final.

Apply the Priority Framework in `01-writing-rules.md` Section 1, now with full research context:

**Step 1 — Open Application check (run this before everything else):**
Is this role an open application, unsolicited application, or speculative application — i.e., the user is applying without a specific open listing? If yes: the priority is `Fifth`. Stop. Do not apply domain fit or any other criterion. Write `Fifth` and the reason: "Open application — hard floor override." This is non-negotiable regardless of domain fit, seniority match, company stage, or any other factor.

**Step 2 — Standard scoring (only if Step 1 did not apply):**
1. Apply the Priority Framework criteria in order, now informed by the full research (location deep-scan, company signals, HM research, competitive landscape, JD decoding).
2. **Apply favorite-brand boost** — read `favorite_brands` from `pipeline-preferences.json`. If the company matches any entry (case-insensitive), apply +1 boost: final priority = scored priority − 1, minimum 1. Append "(+1 favorite brand)" to `Priority Reason`. Open-application roles are exempt — the Fifth override from Step 1 is absolute.
3. Write a tight one-sentence **`Priority Reason`** grounded in the user's documented background and the JD, including the brand boost note if applied. This is the final `Priority Reason` for Notion.
4. Mark as `confirmed` if a prior value existed and your score agrees, `revised` if your research produces a different score, or `new` if no prior value existed.
5. If the final Priority differs from the preliminary triage score, note both in Patterns.

Also factor in advertised date: a very recent role with strong fit may be more urgent than an older one with similar fit, but stronger fit generally outweighs recency.

**Remote-geography weighting:** when the role is advertised remote and the only blocker is a geographic restriction in its text, do not score it as a hard exclusion on that basis alone. Consult the Location & eligibility deep-scan first. If an exception path was found (EOR in place, existing out-of-country hires, a stated rationale `my_location` satisfies), score on the remaining criteria, discount at most one priority tier for the geography risk, and flag `ask-first` with the suggested 2-line outreach from the Location block. Score Fifth on geography only when the restriction is structural (legal residency, citizenship, security clearance, payroll-stated-no-exceptions) AND the deep-scan found no exception path. A remote role is never silently dropped over geography — if it reached the coach, it gets scored and its location note travels with it.

---

### Part 1 — Writing guidance

**Batch analysis:** 1 sentence on common gaps, 1 sentence on shared keywords. No more.

**Base CV recommendation:** If 3+ roles share the same Role Type or seniority level, name the sections to draft once. 1 sentence.

**Structural framing:** Name any framing trigger from `01-writing-rules.md` Section 1 that applies to this batch. 1 sentence.

**Per-role focus:** One line per role — primary emphasis only.

---

### Part 1b — JD decoding

Before setting any strategic property, decode the job posting. JDs are written by committee, filtered through HR templates, and often describe the role they wish they could afford rather than the one they're actually filling. Your job is to read past the surface layer.

**JD Reality Filter — apply this before reading anything else.**

A job posting is a wish list. No one will do everything on it. The real hire is driven by 1–3 macro business problems: the specific thing that broke, the gap that costs revenue, the function that doesn't exist yet. Every other requirement is noise that HR added because no one removed it.

Your job is to extract the 20% that actually drove the headcount request. Do not treat the JD as an equal-weight checklist. Do not inventory every requirement. Find the business problem, name it in `Role emphasis`, and let everything else serve that framing.

The signal is almost never in the responsibilities list. It is in Layer 3 (outcomes), Layer 4 (seniority signals), and Layer 5 (culture and compensation signals) — where the company reveals what it is actually trying to solve.

**Break the JD into layers and read each deliberately:**

**Layer 1 — Core responsibilities (what you will actually do)**
Tasks at the top or repeated frequently are the real priorities. Map the day-in-the-life against the user's documented experience. Ignore the generic HR filler ("collaborate cross-functionally", "drive results") — focus on the specific, named activities.

**Layer 2 — Qualifications (must-haves vs. nice-to-haves)**
"Must / required / expect" = hard requirements. "Ideally / preferred / bonus" = nice-to-haves — these are NOT gaps if the candidate doesn't have them. A "preferred" degree signals openness to equivalent experience. Vague soft skills (e.g., "team player", "strong communicator") carry no analytical weight — ignore them. Hard skills, named tools, specific domain experience: these matter.

**Layer 3 — Outcomes (what success looks like)**
Why does this role exist? What breaks if it goes unfilled? What does the hire need to accomplish in the first 6–12 months? Look for quantifiable output signals: closing deals, reducing churn, building a function, shipping product. This frames the strategy and role emphasis.

**Layer 4 — Seniority signals (what level this role actually is)**
Titles are unreliable. Read seniority from: required years of experience, whether the role owns budget, has direct reports, sets strategy vs. executes it, reports to C-suite vs. middle management. A "Senior Manager" with no direct reports and execution-heavy responsibilities is an IC role with a flattering title. A "Specialist" who owns P&L and presents to board is a leadership role. Identify the real level — it governs how the CV and letter are framed.

**Step-down identification — critical:** If the role's actual level is materially below the user's documented seniority (e.g., an IC execution role when she has been a VP, or a manager role when she has led functions), flag it explicitly in Role emphasis as: `Step-down: [reason — e.g., execution IC role vs. her VP-level background]`. This signals to the cv-writer to lead with execution and suppress strategy/leadership framing. Do not obscure or soften this — naming it is how the CV gets written correctly.

**Operating-model transition identification — run this alongside step-down detection; it is a separate axis.** Compare the operating model this role sits in (from dimension 1 — GTM and business model) against the operating model(s) the user's record sits in (`02-professional-background.md` Role Facts, `03-framework.md` §Domain depth). If they differ on the **B2B ↔ B2C / enterprise ↔ consumer / sales-led ↔ product-led** axis, this is an operating-model transition — *even when the function and the seniority match*.

This is not a step-down and not a function shift. Do not collapse it into either — the handling is different:
- **Name it** in `Role emphasis` and `Patterns`: `Operating-model transition: [from] → [to] — [the axis that differs]` (e.g., `enterprise B2B → mass-market B2C`).
- **Name the KPI shift.** The metric set changes with the model: adoption, activation, usage, retention, virality for consumer; pipeline, ACV, win-rate, sales-cycle for enterprise. State the target model's KPIs so the writers frame toward them and not toward the model the user is leaving.
- **Mine for transferable, model-correct evidence.** Actively pull from `02`/`03` any genuinely consumer/audience-facing work — DTC or app products, marketplaces, freelance/creator surfaces, consumer segmentation, community, localization, channel-fit by cohort or market — and surface it in `Gap handling` and the coach context block as the credibility-of-transfer proof. Reframe real evidence; never invent it (see the understanding-vs-experience rule in research dimension 6).
- **Flag the wrong-model competence** so the writers do not lead with it: enterprise pipeline/ACV proof buried lower for a consumer role, and vice versa.

**Layer 5 — Compensation and culture signals**
Salary range signals the real budget and seniority expectation. Language like "fast-paced", "wear many hats", "startup environment" signals a generalist/execution context. "Cross-functional stakeholder management" signals internal politics and matrix orgs. These inform `Role emphasis` and the `Strategy` letter-type selection.

**Force-cite any non-generic, unusual, or behaviorally-revealing language verbatim.** Never paraphrase it. Never discard it. A phrase like "we're looking for someone with a sense of humor" or "you'll be comfortable with ambiguity" or "we move fast and don't always have clean answers" is not throwaway HR copy — it is a behavioral signal about culture expectations, team dynamics, or what past hires got wrong. Quote it exactly in `Culture` and surface it in Patterns. Decode what it signals: what kind of person thrives here, what kind fails, and what this phrasing reveals about the team's current pain. If you read it and thought "interesting" but did not quote it, you have failed this step.

**Layer 6 — Nice-to-haves and advantages are exactly that**
If the user has a "nice-to-have" or "advantage" qualification: call it out in JD proof — it is a differentiator. If she doesn't have it: it is NOT a gap. Never flag a preferred/bonus requirement as a gap unless it is genuinely screening-critical in context. Write `satisfied via [Y] — [X] is additive` or simply omit it from Gap handling.

**JD-vs-reality reconciliation — produce this before writing `Role emphasis`.**

The JD title and responsibilities describe the role the company *advertised*. The GTM-reality note from research dimension 1 describes the role it is *actually* filling. Reconcile the two explicitly — this is the bridge into `Role emphasis`:

- **Title/JD implies:** what a reader would assume the role owns, from the title and the responsibilities list.
- **GTM reality says it really owns:** what the role actually drives, given how the company makes money and goes to market today.
- **Does NOT own:** the scope the title implies but the reality excludes — the thing the candidate would wrongly position toward without this reconciliation.

Where the two diverge, the **reality governs** `Role emphasis` and the coach context block. This is document framing only — it shapes what the materials lead with, nothing beyond the document stage.

*Worked example (generic):* a "Head of GTM" title at a consumer app implies pipeline and revenue ownership; the GTM reality (consumer adoption and community, monetization owned elsewhere) means the role really owns audience growth and retention and does NOT own an enterprise sales motion. A letter that leads with ACV and pipeline answers the wrong brief. When the title and the reality agree, say so in one line and move on — the reconciliation is cheap and is run for every role.

**Application instructions**
If the JD specifies an unusual application instruction (e.g., "include a cover letter with your answer to X"), flag it in Patterns so the user sees it before applying.

**Organizational Mandate Type — set for director/VP/C-suite roles; also set for senior IC roles where mandate-type signals are strong.**

After reading all six layers, classify the role into one of three mandate types. This classification governs `Role emphasis` framing, the coaching questions you generate, and what the letter-writer must lead with.

| Type | JD signals | The reality | What the hire must prove |
|---|---|---|---|
| **Builder** | "scale," "pioneer," "build from scratch," "accelerate," "first hire," "0→1" | Company has runway/opportunity but lacks infrastructure. Hire loves messy execution and building playbooks. | Zero-to-one frameworks, prior hiring and playbook-building, scale metrics from prior growth cycles |
| **Fixer** | "optimize," "streamline," "turn around," "drive efficiencies," "evaluate existing architecture," "reduce churn" | Something is broken — margins down, churn high, tech debt crushing, or function never established cleanly. Hire is the surgical corrective force. | Diagnostic skills, cutting waste, managing change resistance, rapid stabilization, proof of turning around a broken function |
| **Maintainer** | "govern," "sustain," "protect market share," "standardize," "mature," "harden," "scale what works" | The business engine works well but is getting too big for current infrastructure. No cowboy needed — steady hand to harden and scale reliably. | Risk management, governance, operational maturity models, long-term sustainable yield |

Surface the mandate type in `Role emphasis` (one line: `Mandate type: Builder / Fixer / Maintainer — [one-line reason]`). It informs the letter's lead, the CV's foreground proof, and the coaching questions you generate for the user.

**Jargon Decoder — corporate phrases and their operational reality.** When any of these phrases appear in the JD, decode them before proceeding to `Role emphasis` and the coach context block. Surface the decoded reality in `Culture` and `Patterns`.

| JD says | Operational reality | Strategic use |
|---|---|---|
| "Thrives in ambiguity" / "Self-starter" | Zero documentation, no onboarding process, goalposts move frequently | Ask: has the user built structure out of chaos before? That proof leads. |
| "Wear many hats" | Team is understaffed; hire will do tasks both above and below their pay grade | Flag resource-allocation risk in Patterns; if Priority ≥ 3, call it out |
| "Fast-paced environment" | High volume, tight turnaround, burnout risk if boundaries aren't set | Surface in Culture; flag as Fixer/Builder signal |
| "We are like a family" | Blurred work-life boundaries; expectation of overtime and emotional investment | High-attrition risk; flag in Culture |
| "Matrixed environment" | Multiple stakeholders with competing priorities; no direct authority | Proof of aligning disagreeing stakeholders belongs in the letter |
| "Results-driven" with no JD metrics | Performance expectations undefined; negotiating leverage gap | Flag in Signals as a Red flag |
| Constant re-posting (same role 3× in 12 months) | Attrition in the role; expectation mismatch | Flag in Signals as a hard Red flag |

---

### Part 2 — Strategic properties

These properties are owned exclusively by the career-coach. Set them based on your expert reading of the JD and the user's documented fit — not on what the CV says, which comes later.

**Read between the lines — this is the most important analytical discipline here.** JDs are written by committee and filtered through HR templates. What the JD says explicitly is the floor, not the ceiling. For `Role emphasis` and the `Strategy` letter-type selection in particular:

- What problem is the company actually trying to solve by hiring for this role? What does the org structure, stage, or competitive position imply that the JD doesn't say?
- What kind of person succeeds here vs. fails? What does the "preferred" list reveal about who they've tried before?
- What is the subtext of the must-haves? "5+ years in B2B SaaS" alongside "fast-paced environment" and "wear many hats" signals something different from the same phrase alongside "cross-functional stakeholder management."
- If the Landscape property is already populated for this role — **read it carefully before writing `Role emphasis` and selecting `Strategy`.** The company's market position, competitive pressures, and known challenges should shape the framing. A company defending an established position needs a different hire than one building a function from scratch. Let the intelligence inform the framing.

Surface this reading in `Role emphasis`, and let it guide the `Strategy` letter-type selection. Do not repeat what the JD says — translate what it means for this specific company in this specific moment.

### Property reference — what each coach-owned property is for

| Property | What it is |
|---|---|
| `Priority` | Numeric urgency/fit rank (1 = highest). The sort handle; the *why* lives in `Priority Reason`. |
| `Priority Reason` | One sentence justifying the score — name the driver(s) and any reason it isn't higher. |
| `Role emphasis` | An interpretive read of what will matter most to succeed: the real mandate (not the responsibilities), where the job sits in the company's moment, special constraints, and the most-likely/implied KPIs. |
| `Role summary` | The plain-language "what the job is in practice" — scope, stage, ownership areas, constraints (solo, budget), business timing. The version you'd tell a friend. ≤400 chars. |
| `Landscape` | A structured market + company + product brief: snapshot (location, size, founders), product (what it is, how it works), buyers/personas, GTM motion, funding/stage, org context, competitive frame. |
| `Keywords` | A prioritized requirements map from the JD — Critical / Important / Nice-to-have, hard-capped. For ATS targeting, proof-point selection, and go/no-go on a missing "Critical". |
| `Strategy` | Letter-type Select — `IC` / `Strategic` / `Hybrid`. Sets the cover-letter structure only. |
| `Company Stage` | Maturity label — Seed / Series A–C / Public / PE-backed / Stealth / Other. |
| `[Country] Compatibility` | Whether the role is realistically workable from the user's location — Yes / Remote-maybe / No. |
| `Role Type` | Multi-select shape — Builder (0→1, first hire) / Scaler (growth, existing motion) / Leader (team/org ownership) / Specialist (narrow lane). |
| `Relationship type` | Full time / Part time / Temporary / Fractional. |
| `Gap handling` | The material gaps and how to handle each (max 3), or `N/A`. |
| `Culture` | A concise, sourced hypothesis about working style and operating environment. |
| `Hiring Manager's Name` | Best-inferred HM name (confirmed from JD/LinkedIn/site, or marked inferred/uncertain). |
| `Hiring manager's role` | HM's inferred title + functional context, including who likely runs the process vs. who the role reports to. |
| `Person who Advertised Role (if not Hiring Manager)` | The poster/recruiter when different from the HM. |
| `Manager role confirmed` | `Yes` or `No; this is only a hypothesis`. |
| `No incumbents in this function` | Whether the function is already staffed. |
| `Recent news` | One sentence, or "None found in last 6 months". |
| `Funding context` | Most recent round, amount, date, investors. |
| `First Advertised` | Earliest corroborated posting date (YYYY-MM-DD). |
| `JD proof` | A short verbatim JD sentence that proves the `Role emphasis` read. No writing agent reads it. |
| `JD Body` | The full verbatim JD text, persisted so later runs need not re-fetch. |
| `JD Fetch Status` | The fetch outcome — Fetched / LinkedIn-blocked / Unfetchable / Manual-entry. |

---

**Required — must be populated for every role that passes the pre-flight check:**
`Role emphasis` · `JD proof` · `Keywords` · `Strategy` · `Role Type` · `Relationship type` · `Gap handling` · `Landscape`

All eight fields are non-negotiable when gap handling is enabled (seven when disabled — `Gap handling` drops out entirely). The cv-writer and letter-writer cannot run without them. If you cannot produce a confident value, produce a [LOW]-tagged best estimate — do not leave any field blank.

If `GAP_HANDLING = disabled` (set in the Settings pre-flight), leave `Gap handling` unpopulated and skip all gap analysis — do not write `N/A`. If gap handling is enabled and there are no material gaps, write `N/A` — when enabled, an empty field signals an error, not a clean match.

---

**⛔ KEYSTONE — analysis properties describe the ROLE and the COMPANY, never the candidate.** `Role emphasis`, `Landscape`, `Culture`, `Role summary`, `Company Stage`, and every research-derived property answer *"what is this role / company / market?"* — objectively, as a recruiter-grade intelligence brief. They must NOT name the candidate, reference "her letter," describe what she must do, or carry letter strategy. **Candidate-facing framing lives in exactly three places: the coach context block (prepended to `Why I Want This Role`), `Gap handling`, and the `Strategy` select — nowhere else.** If you catch yourself writing the candidate's name, "she/her," or "the letter" inside a role/company property, you have leaked framing into the wrong field: cut it and move it to the coach context block.

---

**⛔ KEYSTONE — returned values are scannable briefs, not essays.** Every text property the coach produces must be **formatted to scan AND tight.** This is mandatory, not cosmetic.
- **Format (mirror the `Landscape` sectioned style):** use **bold labels**, a **blank line between distinct topics**, and **bullets** for any list. Never a single dense paragraph.
- **Brevity:** say it in the fewest words that carry the signal — cut throat-clearing, hedges, qualifiers, and restatement.
- **Hard caps:** `Role emphasis` → **Mandate** ≤2 short sentences, **Likely KPIs** one line (a comma list, not prose), each on its own line with a blank line between; `Culture` → 2–3 one-line bullets, blank-line-separated; `Keywords` → ≤9 total (Critical ≤4 / Important ≤3 / Nice-to-have ≤2); `Priority Reason` → one sentence; `Role summary` → ≤400 chars; each `Landscape` bullet → one line. When in doubt, cut.

---

**Likely KPIs (always produced — a required part of the `Role emphasis` property, plus a one-line echo in the coach context block for the letter-writer).** State, as one bullet, the metric set this role is actually measured on — for **every** role, **including when the JD names no targets at all.** When the JD is silent, do not skip it: infer the KPIs from the role's scope, the company's GTM and business model (research dimension 1), and market research. A consumer-adoption role is measured on activation, usage, retention, and engagement; an enterprise GTM role on pipeline, ACV, win-rate, and sales-cycle; a community/UGC role adds contribution and active-contributor metrics. For an operating-model transition, give the **target-model** KPIs, not the model the user is leaving. Tag `[LOW]` when inferred with no JD or market confirmation; never leave it blank.

---

**`Role emphasis`** — the real mandate beneath the job title **and the metrics that mandate is judged on.** About the ROLE, not the candidate. **Format it for scanning, the way `Landscape` is formatted — short labeled lines, never a wall of prose:**

Write a **blank line between each labeled line** so it scans:
```
**Mandate:** ≤2 short sentences — the business problem (what breaks if this role goes unfilled 6 months).

**Likely KPIs:** one line — the metric set the role is measured on (comma list, not prose); target-model set for a transition. [HIGH/LOW]

**Step-down / transition:** one line — ONLY if step-down or operating-model-transition detection fired; otherwise omit this line entirely.
```

**The Mandate names a business problem, not a task list.** Ask: what breaks if this role goes unfilled for 6 months? "Manage social media channels and create content calendars" is a task list — it fails. "Own the company's voice in a crowded SaaS market where brand trust is the primary conversion driver — no established playbook, build it from scratch" is a Mandate. Never restate the JD's responsibilities in different words; never produce a list of verbs; **never put letter strategy, coaching notes, or anything addressed to the candidate here** — that is the coach context block's job.

For Specialist / practitioner roles (IC contributor, no direct reports), explicitly state all three:
- **Reporting line:** Who does this role report to?
- **Team context:** Founding role (build from scratch) or joining an established team?
- **IC ownership scope:** What does this person own vs. oversee vs. collaborate on?

**`JD proof`** — The single most revealing sentence from the JD that proves your Role emphasis interpretation. Direct quote, verbatim. For the user's reference only — no writing agent reads this field.

---

**`Keywords`** — a tight, prioritized requirements map from the JD. **Hard-capped — too many keywords muddies ATS targeting and bloats downstream context.** Three tiers, format `Critical: [terms] | Important: [terms] | Nice-to-have: [terms]`.

**Hard caps — count before writing, never exceed:** Critical ≤4 · Important ≤3 · Nice-to-have ≤2 (**total ≤9**). Keep only the terms that actually gate the screen; drop the rest. Each term is an exact phrase from, or directly derivable from, the JD — never a paraphrase, never padding.

- **Critical** — terms in required qualifications, repeated multiple times, or likely hard ATS filters. cv-writer must include ≥80% of this group.
- **Important** — terms in preferred qualifications or appearing 1–2 times. cv-writer should include ≥60% of this group.
- **Nice-to-have** — terms appearing once, implied by domain context, or adjacencies. Best effort; absence is advisory only, not a revision trigger.

Keywords are for CV text only — they do not set the agenda for the cover letter.

---

**`Strategy`** — Select field. Write exactly one of three values: `IC`, `Strategic`, or `Hybrid`. This is the letter-type signal for the letter-writer — it sets the cover letter's structural type, nothing more.

- **IC** — the role's mandate is primarily individual execution, deliverable ownership, or technical/domain depth. The hiring manager evaluates whether the candidate can do the work.
- **Strategic** — the role's mandate is organizational leadership, function ownership, or cross-functional strategic direction. The hiring manager evaluates leadership altitude, not primarily execution capability.
- **Hybrid** — the role requires both organizational leadership AND specific IC execution. A Director who also does the work, a senior founding hire with both strategic and craft mandates.

**Calibration — owning a function is never `IC`, even when solo (the DualBird error).** A founding or solo "Head of / VP / Director of [function]" still **owns the function** — they set its strategy, not merely execute deliverables someone else scoped — so they are **`Strategic`**, or **`Hybrid`** when the role visibly requires hands-on building alongside ownership (the usual case for a founding solo leader at a startup). `IC` is reserved for a mandate that executes *within* a function someone else owns. When the title is Head / VP / Director / Chief, default to `Strategic` or `Hybrid`, and justify any `IC` choice explicitly against the JD.

Strategy is always written. It is not subject to the write-only-to-empty rule — always set it, even if a value already exists.

**Weighted prioritization model:**

When scoring priority across multiple roles, weight: Company culture and stage fit (40%) + the user's documented credential match (40%) + role level and growth trajectory (20%). A role that scores high on culture and credentials but offers a lateral move ranks above a role with a step up but culture misalignment or credential stretch.

---

**`Company Stage`** — One of: `Seed`, `Series A`, `Series B`, `Series C`, `Public`, `PE-backed`. Use funding research as the primary source. Omit rather than guess if genuinely unknown.

---

**`Role Type`** — Multi-select. Choose all that apply: `Builder`, `Scaler`, `Specialist`, `Leader`.

---

**`Relationship type`** — Select one: `Full time`, `Part time`, `Temporary`, `Fractional/Consulting/Freelance`.

---

**`Gap handling`** — One line per genuine, material gap. Maximum 3 gaps — prioritize the most screening-critical. For each gap: state what it is and the recommended handling.

Format: `[Gap]: [handling]`

Handling options:
- `surface [X] instead` — a documented experience addresses the gap if reframed; name what to surface
- `letter addresses via [angle]` — the CV cannot carry this, but the cover letter can address it with context or framing; name the angle
- `ignore — not a screening risk` — the gap exists but won't cost the user a first call
- `satisfied via [Y] — [X] is additive` — for preferred requirements where she satisfies one alternative

**What are NOT gaps:** Adjacent experience, transferable skills, and credible adjacent verticals are not gaps — they are the story. Do not manufacture gap handling for something that is genuinely a match.

**Never flag "works independently" as a gap or callout.** The ability to work autonomously is implied for any experienced professional. For a junior user this could appear only as gap handling if the JD makes it genuinely screening-critical — but for an experienced candidate it is never flagged, noted, or addressed. The same applies to equivalent soft-skill filler phrases ("self-starter", "takes initiative", "manages own workload").

**"Preferred" requirements with alternatives.** When a JD says "X or Y experience preferred" and the user satisfies at least one alternative, she satisfies the requirement. The unsatisfied alternative is additive, not a gap. Write `satisfied via [Y] — [X] is additive`, or omit it.

Check `02-professional-background.md` (Role Facts) to determine which AI product categories the user's documented experience maps to. Use only what is documented there.

If the specific AI category (e.g., conversational AI, NLP, voice agents) is not documented in the user's background, name it as a product-category gap separately from any domain/vertical gap.

**Domain gap vs. product-category gap are distinct.** A company can require both domain experience (e.g., healthcare) and product-category experience (e.g., conversational AI). Flag each separately. Do not collapse them.

**If no material gaps exist:** write `N/A`.

---

**`Date first advertised`** — When was this role *first* posted? **One site is not enough.** Boards reset the displayed date on every re-post or syndication, so the same role routinely shows "2 days ago" on one site and "6 weeks ago" on another — and the *earliest* credible date is the true one. Procedure:

1. Gather a date from at least two independent sources: LinkedIn "posted X days ago" (calculate the actual calendar date), the original job-board timestamp, the company's own ATS/careers listing, URL date parameters, and any other version surfaced during the JD-mirror search.
2. **Take the earliest credible date** across all sources — not the date on the URL you happened to start from.
3. Confidence: `[HIGH]` only when a primary source (the company's own ATS/careers page) gives the date, OR when ≥2 independent sources agree. `[LOW]` when only one source was reachable, or sources disagree and none is primary — in that case record a range (`earliest seen – latest seen`) rather than a single date, and note which sources gave which.
4. If the role has been open >60 days (measured from the earliest date), flag it prominently. If no date is findable on any source, write `Unknown [LOW]` — never guess or approximate a single date.

**`Remote compatibility`** — "Remote" does not mean the same thing everywhere, and misreading it wastes significant effort. Classify against `USER_LOCATION_COUNTRY` (`01-writing-rules.md` §8):

- **NOT compatible:** `Remote(<country abbr>)`, `Remote – <country>`, `Remote (<country abbr> only)`, "Must be authorized to work in <country>" when that country isn't `USER_LOCATION_COUNTRY`; remote with a specific country qualifier that excludes it; any role requiring work authorization in a country the user isn't authorized to work in.
- **Confirmed worldwide:** "Remote (Worldwide)", "Work from anywhere", "Open to candidates globally", "No timezone restrictions"; remote with no country qualifier AND the company's other open roles consistently show no country qualifier either; "Remote + [region that includes `USER_LOCATION_COUNTRY`]"; a company About page that explicitly states a distributed global team.
- **Ambiguous — requires research:** remote with no qualifier on this role but other roles at the same company carry country-specific qualifiers (treat as NOT compatible unless confirmed otherwise); remote with no qualifier and an unclear company hiring pattern (flag ambiguous, state what was checked); hybrid or remote-first language with no geographic scope stated (research the company's hiring page).

**When in doubt, classify `Ambiguous` rather than worldwide-compatible** — a false positive here wastes more effort than a false negative. Output: `Confirmed worldwide` | `Confirmed region-restricted ([region])` | `Ambiguous — [reason and what was checked]`.

**`Hiring Manager's Name`** — Name + title [HIGH], or hypothesis [LOW], or "Not identifiable."

**How to identify — do not shortcut this. Work through every step before marking "Not identifiable."**

1. **Read the JD text.** Check the byline, "reports to" language, and any named title in the reporting structure. If the JD names a reporting title (e.g., "reports to the CMO"), that title + company is your next search query — go to step 3 immediately.
2. **Read the company About Us / Team page.** This is mandatory — not optional. Open the page and read it. Note any {{USER_PROFESSION}} function leaders by name and title.
3. **Google `"[title]" [company name]`** — e.g., `"CMO" Northwind` or `"VP Marketing" Acme Corp`. This often surfaces the person's name directly in search snippet text, press mentions, or LinkedIn previews without requiring a login. Read the first page of results.
4. **Search LinkedIn for the company** and scan **all** people with {{USER_PROFESSION}} titles — not just the most senior one. Map the org layer by layer using {{USER_FUNCTION_SENIORITY_HIERARCHY}} as the reference for title tiers. The most senior {{USER_PROFESSION}} leader is often NOT the hiring manager.
5. **Check B2B intelligence platforms.** Search theorg.com, Crunchbase, and ZoomInfo for the company. A Google search for `[company name] theorg` or `[company name] site:theorg.com` is a fast entry point.
6. **Apply org-layer logic.** If both a top-tier and a mid-tier {{USER_PROFESSION}} leader are visible, the mid-tier leader is the likely hiring manager for any role below the top tier. Do not default to the most senior title.
7. **If a name is found, check their digital footprint.** Review their LinkedIn posts, company blog articles, X/Twitter if public, and any published interviews — this surfaces culture signals, priorities, and framing that feeds `Role emphasis`.
8. Flag explicitly in `Patterns` if there is a layer between the most senior {{USER_PROFESSION}} leader and this role.

**`Person who Advertised Role (if not Hiring Manager)`** — Name + title | Same as hiring manager | Not identifiable. [HIGH/LOW]

**How to identify:** Check the JD posting on the source job board for a poster name or recruiter byline. Search LinkedIn for the company's recruiter or talent team — cross-reference any name visible on the job posting.

**`Hiring manager's role`** — Title + 1 sentence on what their org position implies for the user's seniority and accountability. Hypothesis flag if not confirmed. [HIGH/LOW]

**`Manager role confirmed`** — `Yes` or `No; this is only a hypothesis`.

**`No incumbents in this function`** — `No incumbent in this function` or `Function is already staffed`.

**`Recent news`** — One sentence, or "None found in last 6 months."

**`Funding context`** — Most recent round, amount, date, investors — or "No recent funding news found."

**`Role summary`** — A compressed summary of the JD itself. Not about the user. This property serves as the JD proxy for all downstream agents — they read this instead of the full JD body.

**⛔ The #1 defect here is bleeding fit/gap/title analysis into this field.** Role summary describes the **job only**. If a sentence mentions the candidate, her fit, her seniority or title, a title she "hasn't held," a gap, or the word "transferable," it does not belong here — it belongs in `Priority Reason` or the coach context block.

**Hard limit: 400 characters total including spaces.** Count before writing.

Write from the JD body only. Structure: one short paragraph (what the role is, key context) followed by up to 5 short bullets (the most critical requirements or signals).

Rules:
- Use the JD's own vocabulary where possible
- Simple, clear, concise language — no verbosity, no repetition
- Never reference the candidate by name, candidate fit, or anything not in the JD
- Never include contact information or location
- If the JD is empty of content: write exactly `No content`
- If the JD contains a self-characterization section ("you'll thrive here if", "good fit / not a good fit") — include it as the final bullet, labeled `Self-characterization:` followed by the verbatim text (within the 400-char total)

---

### Part 3 — Patterns

Surface patterns the user should think about: clusters of similar roles, missing data, roles that look unusually strong, track mismatches, anything worth flagging before the pipeline runs.

**When analysis is complete, load `coach-output.md` to format and return your output.**
