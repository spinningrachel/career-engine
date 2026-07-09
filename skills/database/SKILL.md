---
name: database
description: Pipeline-level database vocabulary — Status values, Priority values, and property ownership rules. Backend-neutral: these concepts apply regardless of whether the tracker is Notion, Airtable, or anything else. Load this skill whenever you need to understand what status values mean, how priority ordering works, or which agent owns which field. For Notion-specific mechanics (query ladder, view discovery, writeback syntax), also load `database-notion`. For other backends, load the corresponding adapter.
---

# Database — Pipeline Concepts

Backend-neutral vocabulary for the job applications tracker. Any database backend implements the same concepts here. Field names, tool calls, and query mechanics are backend-specific — see the adapter skill for those.

**Backend adapters:**
- **Notion (default):** `skills/database-notion/SKILL.md` — read ladder, view discovery, writeback syntax, schema

---

## Status Values

Status is the single property that drives what the pipeline does with a role. The user sets and updates it; agents update it at pipeline completion only.

| Status | Who sets it | Meaning |
|---|---|---|
| `New` | user (manual add, or any future sourcing pipeline) | True entry point — where a role sits immediately after being added, before Prioritization has touched it. Not yet triaged: no JD fetch, no location read, no priority score. **This is what the Prioritization pipeline fetches by default.** |
| `Needs Research` | user, or Prioritization pipeline (on completion) | Being researched before a decision to apply. **NOT handled by the CV-writing pipeline.** Use the intake pipeline (`--coach-skills`) to research Needs Research roles. That pipeline runs the career coach, writes strategic properties, and promotes Needs Research roles to Researched. (Renamed from `Hold` — same meaning, same trigger, purely a label change.) |
| `Interested` | user | The user has decided to apply. **This is what the New Application pipeline fetches.** Move a role from Needs Research → Interested (or add directly as Interested) when a CV and cover letter need to be produced. Intake does not process Interested roles — it only processes Needs Research roles. |
| `Needs editing` | user | Queued for the editing pipeline. Pipeline starts from existing outputs — does not run fresh. |
| `CV Ready for Review` | pipeline (on completion) | Pipeline finished; the user needs to review before sending. |
| `Applied` | user | Sent. |
| `Researched` | intake pipeline (on completion) | Coach has run market intelligence — competitive landscape, priority scoring, strategic properties. Role is ready for the user to decide whether to move to Interested. |

**Pipeline reads:** Prioritization reads `New` (default) or `Needs Research` (on explicit request, e.g. to refresh a stale Priority before running full intake). Intake reads `Needs Research` (renamed from `Hold`). New Application reads `Interested`. Editing reads `Needs editing`. All other statuses — including `Researched` — are ignored by those pipelines.

**The upstream pipelines are separate:**
- Prioritization → cheap triage of **New** roles (optionally **Needs Research** roles on request) → sets Status to **Needs Research**
- Intake → researches **Needs Research** roles → sets Status to **Researched**
- New Application → fetches **Interested** roles directly → feeds the CV writing pipeline

---

## Priority Values

`Priority` is the sole queue ordering signal. Set by the career coach during intake — that is where scoring happens. The New Application pipeline never scores: it reads the `Priority` intake already wrote and uses it purely for queue order. An unscored role still processes, ordered last.

| Label | Tracker value | Meaning |
|---|---|---|
| `Highest` | `1` | Urgent — drop everything, run this role first |
| `First` | `2` | Excellent fit — strong domain, right seniority, right stage, no red flags |
| `Second` | `3` | Strong fit — domain or seniority match is clear; minor friction elsewhere |
| `Third` | `4` | Reasonable fit — worth applying but the cover letter has work to do |
| `Fourth` | `5` | Weaker fit — possible if the user wants to stretch |
| `Fifth` | `6` | Weakest fit in this batch. Also the hard floor for Open Application entries regardless of any other criterion. |

**Always write the numeric tracker value (1–6) when setting Priority** via the database adapter. The label names are internal shorthand — the tracker rejects them as select values.

Roles with `Priority` already set are always selected into the queue before unscored roles, ordered 1 → 6. In the New Application pipeline the coach is **not** spawned to score them (R-42 — the coach runs only in standalone intake); an unscored role is still processed, and `Priority` affects ordering only.

**Open Application hard floor:** Roles identifiable as open/speculative/unsolicited applications must always sort and be treated as `6` (Fifth) in the queue, regardless of any Priority value in the tracker. The coach will write `6` during intake (Step 0.8). If the coach is skipped (all coach-complete), verify any open application entry is set to `6` before queue ordering — correct it inline if not.

---

## Property Ownership

Each property in the job applications database has a single designated owner. Agents write each piece of information once, to the correct field, and must not duplicate content across properties.

**Role prioritizer owns provisionally, for `New`-status roles only:**
`Role Summary`, `Location`, `Priority`, `JD Fetch Status`, `JD Body`. These are cheap, JD-only values meant to inform which roles reach full intake next — not a substitute for the career coach's research-informed versions. **The career coach always overwrites `Role Summary`, `Location`, `Priority`, and `JD Fetch Status` when a role reaches full intake** — the coach redoes them from scratch using full research and never treats Prioritization's values as a starting point to confirm or correct. This is intake's general default (see the cross-file-contract row in `CLAUDE.md` and `career-engine-intake/SKILL.md` Step 0.9a): every coach-owned property is always-overwrite except three named exceptions (`JD Body`, `Gap handling`, and the `wiwtr_questions` WIWTR append). `JD Body` stays write-only-to-empty for the coach too, same as any other role's — Prioritization's fetched JD is reused, not re-fetched, when already present.

**Career coach owns exclusively:**

*Written for all roles (triage-exit and full-research):*
`Priority`, `Priority Reason`, `JD Body`, `JD Fetch Status`, `Role Type`, `Relationship type`, and the location compatibility property (name from `pipeline-preferences.json` → `location_compatibility.database_property`; written only if configured).

*Written for full-research roles only (Priority 1–4, pre-scored, or `--full-research`):*
`Role emphasis`, `JD proof`, `Keywords`, `Strategy`, `Gap handling`, `Role summary`, `Company Stage`, `Culture`, `Landscape`, `Person who Advertised Role (if not Hiring Manager)`, `Hiring Manager's Name`, `Hiring manager's role`, `Manager role confirmed`, `No incumbents in this function`, `First Advertised`, `Recent news`, `Funding context`, and conditionally `Job URL`.

**`Role emphasis` conditionally carries a CV-type recommendation.** When `pipeline-preferences.json` → `cv_type.mode` is `"Variant"`, the coach appends a one-line CV-type recommendation with rationale (Detailed or Brief) to the end of the `Role emphasis` text it already writes — see `skills/career-coach/coach-analysis.md`'s CV Type Recommendation Matrix. This is advisory only; it does not write to the user-owned `CV Type` field below. When `cv_type.mode` is `Detailed` or `Brief`, `Role emphasis` carries no such clause — this is not a separate property, just conditional content within an existing one.

No other agent rewrites or second-guesses any of these. **`Gap handling` is the exception to the carry-forward rule — if the user has edited it in the tracker, the pipeline reads her version as authoritative. The write-only-to-empty rule enforces this: if the field is non-empty, the coach skips writing. This exception only applies when `gap_handling_mode` is not `disabled` — see config.**

**`Job URL` is written only when a correction exists, never as a routine write.** The coach never writes Notion directly (same as every other property here) — it returns `Corrected Job URL` only when its own backstop verification (`coach-research.md` → Job URL verification) confirms the original URL is broken and finds a matching working alternate; intake (Step 0.9a) is still the sole writer, and only intake decides whether to apply the correction (preferring the coach's value over Step 0.5's `Working URL` capture when both exist for the same role). A role whose original URL still works never touches this property.

**Mandatory value rule:** Every coach-owned property the coach returns (and intake writes) must receive an explicit value — `N/A` when genuinely inapplicable. A blank field signals agent failure, not inapplicability. This applies to `Company Stage` and `Role Type` in particular. **Prerequisite:** `N/A` must be present as a valid option in the tracker's select fields for `Company Stage` and `Role Type`.

**Triage-exit roles** (Priority 5–6, non-`--full-research`): only the first group of properties above is written. Full-research properties are skipped.

**`Why I Want This Role`** is set manually by the user. Agents never write to it. If it is empty when the pipeline runs, the letter-writer still runs and writes from the **Motivation Bank** (its primary source); it skips the letter for that role (CV only) only when neither `Why I Want This Role` nor any role-relevant Motivation Bank entry has usable material — that decision belongs to the letter-writer's Sufficiency Gate.

**The `Note` field is the user's space. Agents never write to it.**

**`CV Type`** (select: `Detailed`/`Brief`) is set manually by the user, per role — a fixed field name (setup instructs the user to add it directly; there is no configurable name like `location_compatibility.database_property`, since this property has no pre-existing name to reconcile with). Agents read it only when `pipeline-preferences.json` → `cv_type.mode` is `"Variant"`, to decide which CV format to produce for that role; they never write to it. Empty defaults to `Detailed`. See `skills/career-coach/coach-analysis.md` for the recommendation the coach surfaces (in `Role emphasis`, above) to help the user decide.

---

## Role Type Definitions

See `references/role-type-definitions.md`. Loaded by the career coach (sets the value) and the cv-writer (uses it to select CV structure).
