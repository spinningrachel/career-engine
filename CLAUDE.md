# CLAUDE.md — Career Engine Plugin

Working instructions for Claude when editing, extending, or maintaining this plugin.

---

## ⛔ MANDATORY STOP — READ BEFORE DOING ANYTHING ELSE

**You are not done with any plugin edit session until the QA agent has run and passed. No exceptions.**

This means: after completing any set of changes — no matter how small — you MUST invoke the QA agent (`agents/qa-plugin.md`) before telling the user the work is complete. This is not optional and cannot be skipped because the changes "seem clean" or because you "already checked manually." Manual checking is how drift accumulates silently.

**The plugin is a single build.** There is no second personalized copy to keep in sync: the user's personal data lives entirely in the external `career-data` skill (see *Data layer* below), which the plugin never contains. QA validates the one shipped artifact and confirms it holds zero personal data.

**How to invoke:** Spawn the QA agent by reading `agents/qa-plugin.md` and following its instructions. Pass it the repo path and the built `.plugin`.

This gate applies to: any content edit, any rename, any new file, any property name change, any structural change, any cross-version sync. If you edited even one file, run QA.

---

## Data layer: the `career-data` skill

**Single-build architecture** — the plugin ships as **one build**: the public repo. It contains only code (agents, skills) and **blank reference templates** carrying `{{...}}` placeholders — no personal data, no second version, nothing to keep in sync. The user's personal data lives entirely in the external `career-data` skill described below.

The user's personal data — filled `01/02/03`, delivered letters, LinkedIn snapshot, job preferences, pipeline preferences, personal `.dotx` — lives in a separate, user-installed skill named **`career-data`**, outside the plugin. Plugin upgrades never touch it. Agents resolve `career-data` at run start and read the user's real data from it; the plugin's blank templates are the new-user fallback only.

**Placeholder resolution.** The plugin's instruction files keep `{{...}}` placeholders literally — they are NOT substituted at install, because substituting them would personalize the shared build. Agents resolve them at runtime from `career-data`: identity values (`{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, `{{USER_LAST_NAME}}`, `{{USER_PROFESSION}}`, `{{USER_FUNCTION_SENIORITY_HIERARCHY}}`, city/country, etc.) from `career-data` `01-writing-rules.md` §8; all per-install config from the `career-data` config (`${CAREER_DATA}/references/pipeline-preferences.json`): `notion_database_id`, `output_folder`, `cv_template` (relative to `career-data`), `draft_dir_url_base`, `word_templates_path`, `notion_needs_editing_view_url`, `gap_handling`. Setup writes them all; the orchestrator and the standalone entry skills read them at run start and resolve every `{{CONFIG}}` placeholder from them, stopping if a required key (`output_folder`, `cv_template`, or — for Notion runs — `notion_database_id`) is missing (R-38). (The literal `{{PLACEHOLDER}}` template syntax in `linkedin-coach`/`personal-brand` agent-output instructions is a different thing and is unaffected — it stays literal in both contexts.)

### Skill ownership map — who reads what, from where

The Desktop app has three runtime environments. They do **not** share a skill store:

| Environment | Where it reads skills from | Notes |
|---|---|---|
| **Chat** | Desktop app skill store | Skills installed via Customize → Skills |
| **Cowork** | Desktop app skill store | Same store as Chat — same install |
| **Code (CLI)** | `~/.claude/skills/` on local disk | Separate location; synced one-way from Desktop app |

#### The plugin (`career-engine`)

Installed as a `.plugin` file via **Customize → Connectors → Personal plugins**. Available in all three environments after install. Contains only code — agents, skills, blank templates. No personal data.

#### The `career-data` skill

Installed as a `.skill` file via **Customize → Skills**. The Desktop app install is canonical — it serves Chat and Cowork. When the Desktop app installs a skill, it also writes a copy to `~/.claude/skills/` so Claude Code can read it.

#### Drift prevention (Desktop app users)

With a single plugin build there is no cross-version drift. The remaining drift risk is between **copies of `career-data`**: the canonical Desktop app install vs. a stale copy in `~/.claude/skills/`. This only applies to users running both the Desktop app and Claude Code CLI.

**One-way sync: Desktop app → Code.** The Desktop app writes to `~/.claude/skills/` at install time. Writing directly to `~/.claude/skills/` from the CLI does NOT propagate back to Chat or Cowork — it creates a divergent copy that drifts silently. Prevent it by never writing `~/.claude/skills/` directly; create and update `career-data` only through the Desktop app.

> **Note for setup and installation documentation:** the Desktop-sync constraint above should be explained to users during setup — not buried in developer notes. Users who only use Code (no Desktop app) are unaffected.

### Updating `career-data`

1. **Never write `~/.claude/skills/` directly from a CLI or pipeline.** Use update-prompt files instead — the user pastes them into Chat (or Code) to make the edit, then repackages and reinstalls via the Desktop app.
2. **To update `career-data`:** generate an update-prompt file → user pastes in Chat → Chat edits the skill → user repackages as `.skill` → uploads via Customize → Skills. This is the only update path that keeps all three environments in sync.
3. **Update-prompt format is mandatory:** Chat requires a specific prompt structure to reliably locate and edit the skill. Always use the canonical template in `references/career-data-update-prompt-format.md` — it includes the required context block (marker-file discovery, repackaging steps, verbatim-copy warning). A bare JSON block or informal instruction will confuse Chat. The personal prompt file is gitignored (`update-prompt-*.md`); the template itself is tracked in the repo.
4. **If the user uses both Chat/Cowork AND Code:** they must apply the update-prompt in both Chat and Code so both copies stay current. Update-prompt files include this reminder.
5. **Plugin agents that need `career-data`:** they receive `${CAREER_DATA}` from the orchestrator preflight (which locates it at run start). Standalone invocations do Step −0.5 self-locate. Never hardcode the path.

#### ⛔ Named anti-pattern: the June-18 direct-write rationalization

On 2026-06-18 an agent wrote directly to `career-data` from Claude Code, bypassed the update-prompt path, and then told the user:

> "I fixed career-data directly here today because I can reach that file from Code, and that's faster and safer than going through Chat. Worth knowing you can ask me to do career-data edits this way going forward."

**This was wrong on every count:**
- The write went to a session temp path, not the Desktop app canonical copy — it did not propagate to Chat or Cowork and was lost when the session ended.
- "Faster and safer" is backwards: direct writes bypass the packaging/verify/reinstall flow that keeps all three environments in sync, and create divergent copies that rot silently.
- The agent convinced the user this was the right workflow going forward — the opposite of R-37.

**The rationalization pattern to watch for:** an agent argues that the Chat update path is "broken" or "causes data loss" and offers to do the edit directly instead. This framing is backwards — the Chat path's friction exists because packaging a skill has integrity steps (file count + md5 verify). Skipping them doesn't remove the risk; it hides it. If the Chat update path is genuinely broken, fix the update-prompt or the instructions — don't bypass the path.

---

## File organization

Where to put content in the plugin. Each directory has a single job; placing content in the wrong directory is how agents get confused and how doctrine leaks into procedures.

| Directory | Purpose | Put here | Never put here |
|---|---|---|---|
| **`agents/`** | Orchestration only | Identity/expert framing (3–6 lines), invocation modes, file loading table, step procedures, options routing, output format spec, mandatory gates | Writing craft or doctrine, worked examples, templates, personal data |
| **`skills/`** | Doctrine and craft | Writing rules, positioning philosophy, use-case patterns, checklists, strategic frameworks, templates with `{{...}}` slots, worked examples | Procedural steps, file loading instructions, output format specs |
| **`references/`** | Source material | Background facts, candidate rules (blank `{{...}}` placeholders), voice profile template, self-check checklists, delivered-letter examples | Code, procedure, anything only an agent would read |
| **`commands/`** | Slash commands | Thin command files that invoke a skill or agent | Logic, implementation, doctrine |

Skills are loaded by agents via `Read` — they are not auto-activated by the platform based on context for pipeline agents. Each agent explicitly instructs itself to load the skills it needs. Agents read references; they never write to them except via explicit pipeline steps (e.g., the `02-professional-background.md` Why I Want This Role promotion in new-application Step 7f / edit Step E10.5).

---

## Packaging

One `.plugin` build, from the repo. The built `.plugin` is committed to the repo so non-technical users can download and install it directly without building it themselves. Rebuild and commit after every batch of changes. **Run from inside the repo root:**

```bash
cd <repo-root>
python3 -c "
import zipfile, os
exclude = {'.git', 'docs', '.mcpb-cache', '.claude', '__pycache__', '.DS_Store', '.in_use'}
with zipfile.ZipFile('career-engine.plugin', 'w', zipfile.ZIP_STORED) as zf:
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in exclude]
        for file in files:
            if file in exclude or file.endswith('.plugin'):
                continue
            zf.write(os.path.join(root, file), os.path.join(root, file)[2:])
print('Done.')
"
```

The plugin contains code + blank templates only — no personal data. QA validates the built `.plugin` (unzip + checks) and asserts zero personal data before it ships.

---

## Cross-file contracts

These are the load-bearing relationships between files that are not obvious from reading either file alone. Breaking one without updating the other causes silent drift. The pre-commit hook (`scripts/check-invariants.sh`) catches the mechanical ones automatically; this table covers the rest.

**Pre-commit hook setup** (one-time, per clone): `ln -sf ../../scripts/check-invariants.sh .git/hooks/pre-commit`

| Contract | Source of truth | Dependent file(s) | What breaks if they drift |
|---|---|---|---|
| Grade table (A/B/C/D, advisory thresholds, round-aware decisions) | `skills/gatekeeper-checks/SKILL.md` | `agents/gatekeeper.md` (output templates) | Gatekeeper returns wrong PASS/FAIL; agent output contradicts skill routing |
| CAREER_DATA pass-through pattern (`CAREER_DATA=${CAREER_DATA}`) | `skills/career-engine-new-application/SKILL.md`, `skills/career-engine-edit/SKILL.md` | `agents/cover-letter-humanizer.md`, `agents/cv-writer.md`, `agents/gatekeeper.md` | Subagents can't locate personal data at runtime |
| Humanizer input boundary (letter + CAREER_DATA only) | `agents/cover-letter-humanizer.md` §What I receive | `skills/career-engine-new-application/SKILL.md` Step 5.9, `skills/career-engine-edit/SKILL.md` Step E8 | Orchestrator passes forbidden role context; humanizer scope creep |
| R-41 output protocol (write to `$PIPE/`, return 1-line status) | Glossary entry R-41 in this file | All pipeline subagents: `gatekeeper`, `cv-writer`, `letter-writer`, `recruiter-reviewer`, `cover-letter-humanizer` | Subagent returns full content inline; bloats orchestrator context |
| Gatekeeper option values (`cv`, `cover-letter`, `coach-output`) | `agents/gatekeeper.md` | Both pipeline skills (new-application, edit) at every gatekeeper spawn call | Wrong option passed; gatekeeper runs wrong check set |
| Pipeline file names (OUTPUT_PATH values) | `skills/career-engine-new-application/SKILL.md` | `agents/gatekeeper.md`, `agents/cv-writer.md`, `agents/letter-writer.md` | File written to wrong path; next step can't find it |
| Notion read ladder (A1 → A2 → B, no improvised search) | `skills/career-engine-intake/SKILL.md` Step 0b | `agents/career-coach.md` (intake mode), `skills/career-engine-edit/SKILL.md` Step E0 | Agent falls through to semantic search; picks up wrong rows |
| Shared voice rules (WI7): the four writing skills are pruned to surface-specific deltas and defer here for all shared prohibitions | `references/shared-voice-rules.md` | Skills that defer to it: `cv-writing`, `cover-letter`, `cover-letter-humanizer`, `linkedin-coach`. Agents/skills that must load it: `agents/cv-writer.md`, `agents/letter-writer.md`, `agents/cover-letter-humanizer.md`, `agents/linkedin-post-writer.md`, `agents/linkedin-post-reviewer.md`, `agents/freelance-manager.md`, and the `linkedin-coach` standalone skill | A skill is pruned but its consuming agent doesn't load shared-voice-rules.md → those rules vanish at runtime (the WI7 failure mode). Adding a rule here without adding it to gatekeeper-checks → a letter passes the gate but violates the writer's rules |

---

## Agent file content types

Use this as a checklist when writing or reviewing any agent file.

| Content type | Belongs in agent? | Notes |
|---|---|---|
| **Identity / expert framing** | ✅ Yes | 3–6 lines. What kind of expert. What the output achieves. What makes this agent distinct. |
| **Scope boundary** | ✅ Yes | What this agent explicitly does NOT handle. One line per boundary. |
| **Invocations** | ✅ Yes | How the agent is called: pipeline mode (what inputs arrive, from where) vs standalone. |
| **Procedural gates** | ✅ Yes | Non-negotiable prerequisite checks. Binary: pass or stop. |
| **File loading table** | ✅ Yes | Mandatory files before doing anything. One row per file; what it contains. |
| **Input list** | ✅ Yes (brief) | What each pipeline input IS and its routing function. Not how to use it — that's doctrine and goes in the skill. |
| **Options routing** | ✅ Yes | Named modes; one line each; pointer to section. |
| **Procedural steps** | ✅ Yes | Step-by-step: what to do, in what order. No explanatory doctrine — steps reference the skill for rules. |
| **Decision logic** | ✅ Yes | Ordered conditionals for revision or exception handling. Decision 1 → 2 → 3. |
| **Mandatory gates** | ✅ Yes | Non-negotiable final step before returning output. Never skippable. |
| **Output format spec** | ✅ Yes | Exact format of what to return. Per option if they differ. |
| **Integration rules** | ❌ No → Skill | How inputs interact; which source governs what. This is doctrine, not procedure. |
| **Craft rules / how to write** | ❌ No → Skill | What to write, how to write it, forbidden patterns. |
| **Templates** | ❌ No → Skill | Fill-in-the-blank patterns with labeled slots. |
| **Worked examples** | ❌ No → Skill | Before/after pairs, annotated exemplars. |
| **Personal info / candidate rules** | ❌ No → references/ | Any content specific to the candidate. |

---

## Skill file content types

Use this as a checklist when writing or reviewing any skill file.

| Content type | Belongs in skill? | Notes |
|---|---|---|
| **Core knowledge / philosophy** | ✅ Yes | Why the task matters; the mental model to hold. Sets the frame before any rules. |
| **What it must do** | ✅ Yes | Positive obligations with a test for each. |
| **What it must not do** | ✅ Yes | Prohibitions and named anti-patterns. Each with a correction or alternative. |
| **Integration rules** | ✅ Yes | How inputs from outside interact. Which source governs which decision. |
| **Input execution rules** | ✅ Yes | How to use specific inputs during composition (opener source, strategy analysis ban, etc.). |
| **Quantitative thresholds** | ✅ Yes | Exact numbers: word counts, keyword percentages, occurrence limits. |
| **Templates** | ✅ Yes | Fill-in-the-blank patterns with labeled slots. Named and numbered. |
| **Worked examples** | ✅ Yes | Concrete weak → strong pairs or annotated exemplars from real source material. |
| **Rules list** | ✅ Yes | Named, testable prohibitions. State the rule; state the correction. |
| **Mandatory checklists** | ✅ Yes | Ordered steps to run after drafting. Each step has a pass/fail criterion. |
| **Vocabulary — banned** | ✅ Yes | Words and phrases to cut outright, with explanation. |
| **Vocabulary — approved** | ✅ Yes | Alternatives organized by category or situation. |
| **Voice permissions** | ✅ Yes | Conditional allowances: things permitted but not required. |
| **Procedural steps** | ❌ No → Agent | What to do in what order belongs in the agent as Option steps. |
| **File loading instructions** | ❌ No → Agent | What to read before starting belongs in the agent's file table. |
| **Output format** | ❌ No → Agent | What to return and in what format belongs in the agent. |

---

## Key design decisions

**Why doctrine lives in skills, not agents:**
Agent files are open-source. Personal writing philosophy, specific candidate rules, and strategic framing would leak into the public repo if kept in agents. Skills hold doctrine and blank `{{...}}` templates only; the user's personal content lives entirely in the external `career-data` skill, never in the plugin.

**Why the pipeline cap is 5 roles:**
The career coach runs as a single subagent with all roles in context. Beyond 5, context quality degrades. The intake skill processes all roles when there are ≤5 (no priority ordering needed); priority ordering only applies when there are >5 and a selection must be made.

**Why view discovery replaces hardcoded view URLs:**
Notion view URLs change when views are reorganised. Every Path B query site — intake (Step 0b), coach (Step 2), edit (Step E0), and source-open-roles (Deduplication) — fetches the database, reads the `Views` list, and finds the view **by name** ("Hold" / "Interested" / "Needs Editing" / a broad view) rather than relying on a hardcoded URL that silently breaks. A known URL may be used as a fast path (e.g. edit's `{{NOTION_NEEDS_EDITING_VIEW_URL}}`), but the by-name lookup is always the fallback.

**The canonical Notion read ladder (consistent across all query sites):** A1 (`ntn` CLI, gated, server-side filter) → A2 (`notionApi` `API-query-data-source`, structured filter) → B (standard connector `notion-query-database-view`). Path B is the connector-only fallback and has two hard constraints (R-39): `notion-query-database-view` accepts **no ad-hoc `filter` argument** (it runs the view's own saved filter) and requires a real **view URL** (`...?v=<id>`), never the bare database URL — so Path B is always *fetch-DB → find view by name → query that view URL (no filter) → discovery-only → per-page `notion-fetch` → discard non-matching Status*. If every rung fails, **stop and report** — never treat it as zero results, and never improvise `notion-search`/semantic search to discover queue rows. The full ladder with syntax lives in `skills/career-engine-intake/SKILL.md` → Step 0b; coach/edit/source-open-roles reference it.

**Why the opener rule is a principle, not a template:**
Delivered letters show openers that vary widely in structure — emotional reaction, existing relationship, personal tension, value claim, warm connection. The common thread is specificity: the reader knows that role the user is applying for in the first sentence; within the first two sentences the reader knows why this person wants this role (sum total: why this person is writing now to this company). A fixed template produces generic letters. The rule is: establish that context; how is up to the Why I Want This Role content.

---

## Glossary

Shared terminology used throughout the plugin. When a term appears in an agent, skill, or this file, it means the thing defined here — not a colloquial sense.

| Term | Definition |
|---|---|
| **Pipeline** | A complete end-to-end workflow with a named trigger, entry skill, and owned Status transitions. Defined in the Pipeline Registry in `skills/career-engine/SKILL.md`. Examples: New Application, Edit, Intake. |
| **Agent** | A spawnable subagent that performs one discrete task (write a CV, run a gatekeeper check, review as a recruiter). Lives in `agents/`. Spawned by the orchestrator or entry skill — never auto-activated. |
| **Skill** | A doctrine or craft file loaded explicitly by an agent via `Read`. Not a pipeline step — it holds the rules, templates, and philosophy the agent applies. Lives in `skills/`. |
| **Check** (gatekeeper) | One of the three document-type check sets the gatekeeper can run: **CV Check** (`option=cv`), **Cover Letter Check** (`option=cover-letter`), **Coach Output Check** (`option=coach-output`). Not optional — which check runs depends on what the pipeline is validating at that step. |
| **Option** (agent invocation) | A named invocation mode for an agent that has more than one way to run. Example: `letter-writer option=draft` vs `option=revision` vs `option=standalone`. Options are agent-specific; they are not the same concept as gatekeeper checks. |
| **Hard fail** | A gatekeeper violation that always blocks the pipeline and returns the document to the writer, regardless of grade. |
| **Advisory violation** | A gatekeeper finding that counts toward the cover letter grade but does not independently block the pipeline. 0–2 advisory violations = PASS to humanizer (Grade A/B); 3+ = FAIL back to letter-writer (Grade C/D). |
| **Grade** | The A/B/C/D score the gatekeeper assigns to a cover letter based on advisory violation count. A = 0 violations, B = 1–2, C = 3–4, D = 5+. Hard fails override the grade. |
| **Tier** (keywords) | Classification of JD keywords into Critical / Important / Nice-to-have for the gatekeeper's ATS pre-check. Thresholds: Critical ≥80%, Important ≥60%, Nice-to-have = advisory only. |
| **R-41** | Output protocol requiring pipeline subagents to write their full output to a `$PIPE/` file and return only a 1-line status. Keeps orchestrator context small. Violations bloat the run. |
| **R-37** | Data root rule: personal-data files load from `${CAREER_DATA}/references/`. Plugin files load from `${CLAUDE_PLUGIN_ROOT}/`. Never hardcode paths. |
| **WIWTR** | Why I Want This Role — the user's first-person notes about a specific role, stored in the Notion job row. Sole source for the cover letter opener. All distinct points must appear somewhere in the letter. |
| **Surgical-only revision** | Letter-writer rule: reviewer feedback authorises touching only what was flagged. Every sentence not explicitly called out stays word-for-word. |
| **Fabrication** | Inventing credentials, outcomes, or experience not present in the user's documented background or WIWTR. Always prohibited. Reviewer flags never authorise fabrication. |

---

## QA Agent

See the mandatory stop gate at the top of this file. The QA agent lives at `agents/qa-plugin.md`. Run it after every edit session. It validates the single shipped `.plugin` artifact (unzipped) for stale references, missing files, property-name consistency, structural integrity, and that it contains zero personal data. The full check list is in the agent file itself.