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

**Placeholder resolution.** The plugin's instruction files keep `{{...}}` placeholders literally — they are NOT substituted at install, because substituting them would personalize the shared build. Agents resolve them at runtime from `career-data`: identity values (`{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, `{{USER_LAST_NAME}}`, `{{USER_PROFESSION}}`, `{{USER_FUNCTION_SENIORITY_HIERARCHY}}`, city/country, etc.) from `career-data` `01-writing-rules.md` §8; all per-install config from the `career-data` config (`${CAREER_DATA}/references/pipeline-preferences.json`): `database_backend`, `database_id`, `output_folder`, `cv_template` (relative to `career-data`), `draft_dir_url_base`, `word_templates_path`, `database_edit_view_url`, `database_interested_view_url`, `database_hold_view_url`, `database_researched_view_url`, `database_cv_ready_view_url` (all five view URL keys are optional fast-paths; when populated, pipelines skip the 59KB DB discovery fetch), `gap_handling`. Setup writes them all; the orchestrator and the standalone entry skills read them at run start and resolve every `{{CONFIG}}` placeholder from them, stopping ONLY if a **required** key (`output_folder`, `cv_template`, or — when a database backend is configured — `database_id`) is missing (R-38). **Every other key is optional: a run completes without it and a config-health notice lists what is empty/missing, so an older config never breaks a pipeline.** **Backward compatibility:** legacy names `notion_database_id` (→ `database_id`), `notion_needs_editing_view_url` (→ `database_edit_view_url`), and `location_compatibility.notion_property` (→ `database_property`) are still read; prefer the `database_*` names. (The internal `$NOTION_DATABASE_ID`/`$NOTION_NEEDS_EDITING_VIEW_URL` shell vars are the Notion adapter's names and are unchanged — see the *Database backend* glossary entry.) (The literal `{{PLACEHOLDER}}` template syntax in `linkedin-coach`/`personal-brand` agent-output instructions is a different thing and is unaffected — it stays literal in both contexts.)

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
Skills are loaded by agents via `Read` — they are not auto-activated by the platform based on context for pipeline agents. Each agent explicitly instructs itself to load the skills it needs. Agents read references; they never write to them except via explicit pipeline steps (e.g., the `02-professional-background.md` Why I Want This Role promotion in new-application Step 7f / edit Step E10.5).

---

## Packaging

One `.plugin` build, from the repo. The built `.plugin` is committed to the repo so non-technical users can download and install it directly without building it themselves. Rebuild and commit after every batch of changes. **Run from inside the repo root:**

```bash
cd <repo-root>
python3 -c "
import zipfile, os
exclude = {'.git', 'docs', '.mcpb-cache', '.claude', '__pycache__', '.DS_Store', '.in_use', 'session.jsonl'}
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
| Humanizer input boundary (letter + CAREER_DATA + voice-calibration only) | `agents/cover-letter-humanizer.md` §What I receive | `skills/career-engine-new-application/SKILL.md` Step 5.9, `skills/career-engine-edit/SKILL.md` Step E8 | Orchestrator passes forbidden role context; humanizer scope creep. The one non-role pipeline artifact allowed: `$PIPE/voice-calibration.md` (pre-computed from career-data, not role-specific). |
| R-41 output protocol (write to `$PIPE/`, return 1-line status) | Glossary entry R-41 in this file | All pipeline subagents: `career-coach` (intake Option 2 — writes to `$PIPE/coach-output.md`), `gatekeeper`, `cv-writer`, `letter-writer`, `recruiter-reviewer`, `cover-letter-humanizer` | Subagent returns full content inline; bloats orchestrator context |
| Gatekeeper option values (`cv`, `cover-letter`, `coach-output`) | `agents/gatekeeper.md` | Both pipeline skills (new-application, edit) at every gatekeeper spawn call | Wrong option passed; gatekeeper runs wrong check set |
| Pipeline file names (OUTPUT_PATH values) | `skills/career-engine-new-application/SKILL.md` | `agents/gatekeeper.md`, `agents/cv-writer.md`, `agents/letter-writer.md` | File written to wrong path; next step can't find it |
| Notion read/write mechanics (A1 → A2 → B ladder, view discovery, writeback, no improvised search) | `skills/database-notion/SKILL.md` (the Notion adapter) | `skills/career-engine-intake/SKILL.md` Step 0a/0b/0.9a, `skills/career-engine-orchestrator/SKILL.md` Step O1, `skills/career-engine-edit/SKILL.md` Step E0, `skills/source-open-roles/SKILL.md` (Deduplication), `agents/mind-dump.md`, `agents/content-orchestrator.md` — all delegate here | A consumer re-describes the mechanics and drifts (e.g. the `collection://` two-step bug living in several files); agent falls through to semantic search |
| Coach-property writeback ownership (the coach WRITES its analysis to `$PIPE/coach-output.md` (R-41) and returns a 1-line status; **intake Step 0.9a is the single Notion writer** — reads the file, schema-validates select values, write-only-to-empty, plus a confirmation pass; the coach has no Notion write tool). Now includes `wiwtr_questions`: the coach includes a `[COACH PROMPTS]` questions block in `$PIPE/coach-output.md`; intake writes it to WIWTR below the coach context block (write-only-to-empty: only when WIWTR was empty pre-write). | `skills/career-engine-intake/SKILL.md` Step 0.8 (R-41 file write) + Step 0.9a (Notion writeback) | `agents/career-coach.md` (writes `$PIPE/coach-output.md`, returns 1-line status, no Notion write), `skills/career-coach/coach-output.md` (Output Protocol R-41 section + Output Rules + WIWTR Question Generation), `skills/career-engine-orchestrator/SKILL.md` (`--now` coach-output handling) | Two writers each assume the other wrote → properties (`Role summary`, `Priority Reason`) silently dropped; or invalid select values error a batch and drop siblings |
| Intake's own run-scoped `$PIPE` (Step 0a.5 — established once per intake run, Notion-fetch mode only, ahead of Step 0b so the delegated per-page fetch has somewhere to write; Step 0.4 is now just a checkpoint that confirms it; distinct from New Application's per-role/per-company `$PIPE`) carrying `$PIPE/hold-role-properties.md` (per-page Notion properties for the Hold queue, written by a delegated subagent spawned from Step 0b — mirrors the orchestrator's Step O1 fix — read by Steps 0.6/0.8/0.9a) + `$PIPE/queue.md` (JD text and row payload, written by Step 0.5, read by the coach, never pasted inline into the coach spawn prompt) + the 5-role hard cap on every coach spawn (Step 0.7 selects, Step 0.8 re-checks defensively, the coach itself refuses a queue.md with more than 5 roles) + `$PIPE/writeback-status.md` (a per-role checklist ledger that makes Step 0.9a resumable on interruption) + the prohibition on hand-editing `$PIPE/coach-output.md` (only the coach edits its own file; a gatekeeper FAIL always re-spawns the coach with the violation file's path via `OUTPUT_PATH`, never an orchestrator self-edit) | `skills/career-engine-intake/SKILL.md` Steps 0a.5, 0b, 0.4, 0.5, 0.7, 0.8, 0.8.5, 0.9a | `agents/career-coach.md` (reads `$PIPE/queue.md`, enforces the 5-role cap, writes `coach-output.md` incrementally per role), `agents/gatekeeper.md` Output format (the Coach Output Check's `OUTPUT_PATH` file-write contract — same fix also closed a pre-existing inline-vs-file contradiction in the CV Check and Cover Letter Check sections, which the file's own top-of-file R-41 protocol line had already specified but the Output format templates never matched, surfacing two callers in `skills/career-engine-edit/SKILL.md` Step E0.7 — the baseline CV/cover-letter checks — that had never supplied `OUTPUT_PATH` even though their violation lists are read back downstream at Steps E3 and E7) | A 25-role batch reached a single coach spawn in a real run: the coach hit the model's output-token ceiling and crashed after 111 minutes, the orchestrator then hand-edited the coach's output file across 5 gatekeeper FAIL rounds (77 raw edits) instead of re-spawning the coach, and the run crashed again mid-writeback with no ledger to resume from — 24 of 25 roles' completed, gatekeeper-passed analysis never reached Notion. Separately, Step 0.4 establishing `$PIPE` without a stop-condition on missing `output_folder`, and the two unwired E0.7 baseline-check spawns, would each have produced ambiguous behavior rather than a clean failure. Separately (this QA pass): Step 0b's per-page Hold-queue fetch ran directly in the pipeline's own context with no delegation and no cap-before-fetch — the same failure shape as the orchestrator's Step O1 incident — fixed by moving `$PIPE` establishment ahead of Step 0b and delegating the fetch the same way. |
| Shared voice rules (WI7): §§1-7 (all but the LinkedIn-only §8) are now also carried inside `skills/writer-craft/SKILL.md` for the three writer agents; `references/shared-voice-rules.md` remains canonical and unmodified for its other six consumers | `references/shared-voice-rules.md` | Skills that still defer to it directly: `linkedin-coach`, `fiverr`, `upwork`. Agents that still load it directly: `agents/linkedin-post-writer.md`, `agents/linkedin-post-reviewer.md`, `agents/freelance-manager.md`. `cv-writer`, `letter-writer`, and `cover-letter-humanizer` no longer load this file — they load `skills/writer-craft/SKILL.md` instead (see the writer-craft contract row below), which carries the same §1-7 prohibitions (trimmed) inline. | A skill is pruned but its consuming agent doesn't load its rule source → those rules vanish at runtime (the WI7 failure mode). If a shared rule changes, it must be updated in both `shared-voice-rules.md` (for its six remaining consumers) and `writer-craft/SKILL.md` (for the three writer agents) — they are no longer the same file for the writer surfaces, so a fix in one does not propagate to the other. Adding a rule to either without adding it to gatekeeper-checks → a letter passes the gate but violates the writer's rules |
| Writer-craft consolidation: `cv-writer`, `letter-writer`, and `cover-letter-humanizer` load one aggregated skill instead of the four/five files each used to load separately (`cv-writing/SKILL.md`, `cover-letter/SKILL.md`, `cover-letter-humanizer/SKILL.md`, `references/cover-letter-self-check.md`, `references/humanizer-target-metrics.md`, plus `references/shared-voice-rules.md` §1-7 — all five prior files retired; `shared-voice-rules.md` itself survives for its other six consumers). Content was aggressively trimmed to rules with demonstrated evidence from real pipeline runs and condensed-prompt testing, not a straight merge. | `skills/writer-craft/SKILL.md` | `agents/cv-writer.md` (loads `[ALL]` + `[CV]` sections), `agents/letter-writer.md` (loads `[ALL]` + `[CL]` sections), `agents/cover-letter-humanizer.md` (loads `[ALL]` sections + §12 Humanizer Mechanics + its Quantitative Final Gate) | An agent still points at one of the five retired file paths → the load silently 404s or (worse) an old copy lingers and drifts from the consolidated version. A rule trimmed out of this file without confirming it wasn't load-bearing → a real failure mode (whack-a-mole revision loop, false-positive fabrication flag, JD-mirroring hard fail) recurs silently. Any new writer-facing rule must be added here, not resurrected in a per-surface file. |
| Motivation-Bank / WIWTR gate (Bank is primary; WIWTR is supplementary and non-mandatory; Sufficiency Gate decides write-vs-skip). **Option A coaching-prompts detection:** before the Case 1/2 dispatch, the Sufficiency Gate strips the coach context block (everything above the first `---`) and checks whether the remaining content contains `[COACH PROMPTS` — if so, treats as WIWTR-absent and routes to Case 2. | `agents/letter-writer.md` (Motivation Bank Gate + Sufficiency Gate + Option A pre-check) | `skills/writer-craft/SKILL.md` §7-8; `skills/career-engine-new-application/SKILL.md` (WIWTR pre-gate removed — always spawn the letter-writer; Step 7f promotes durable content to the Bank table); `skills/career-engine-edit/SKILL.md` (E7 gate + E10.5 promotion); `skills/gatekeeper-checks/SKILL.md` (personal-content exemption extended to Bank-derived content); `skills/career-engine-intake/SKILL.md` Step 0.9a Write B (the only source of `[COACH PROMPTS` content) | The letter-writer skips a writable role or writes inconsistently, or the gatekeeper false-flags Bank-derived sentences as fabricated. If the pre-check drifts from the intake write format (e.g. header wording changes), the letter-writer fails to detect unanswered coaching prompts and uses them as voiced motivation |
| **Mandatory coach-field list parity — three lists that must always match.** (1) Step 0.8's `coach-complete` field checklist (decides whether a role even needs the coach); (2) Step 0.9a's confirmation-pass mandatory-property list (decides which fields get a retry-then-surface if still empty after writeback); (3) the gatekeeper's Coach Output Check presence-check (structural backstop — FAILs if a full-research role's output is missing a mandatory field entirely). A field mandatory in (2) or (3) but absent from (1) lets a role skip the coach with that field silently empty forever. | `skills/career-engine-intake/SKILL.md` Step 0.9a (confirmation-pass list, the list the other two must match) | `skills/career-engine-intake/SKILL.md` Step 0.8 (coach-complete list), `skills/gatekeeper-checks/SKILL.md` → Coach Output Check (presence-check list), `skills/career-coach/coach-output.md` (must have a literal template slot for every fixed-name mandatory field — a field only ever mentioned in prose has nothing prompting the coach to literally emit it) | **Confirmed production failure:** Step 0.8's list omitted `Location` and `First Advertised` while Step 0.9a's list already required both; two independent live intake runs produced 10 roles (2 batches of 5) with zero occurrences of either field, because the coach's spawn-prompt checklist (built from Step 0.8's list) never asked for them, and the gatekeeper's Coach Output Check had no presence-check of any kind to catch the omission. Fixed by restoring parity across all three lists and adding a literal `Location` template slot in `coach-output.md` (the location-compatibility verdict, which has a per-install-configured property name, stays prose-only by design — it can't be a fixed-name template line). |
| **Batch-queue per-page fetch delegation — same fix, three query sites.** The orchestrator's Step O1 (Interested queue), intake's Step 0b (Hold queue), and edit's Step E0 (Needs-editing queue) each discover a queue's page IDs via a view, then must fetch full per-page properties for the whole queue before any per-role cap is applied. Running that per-page fetch loop directly in the pipeline's own context — rather than delegating it to a subagent that returns one bounded block — has caused context exhaustion in production (orchestrator) and was a latent, unaddressed structural gap in the other two until this QA pass. All three must delegate the per-page fetch to a lightweight subagent and write its one returned block to a run-scoped scratch file in a single `Write` call, never accumulating raw `notion-fetch` results turn-by-turn in the pipeline's own context. | `skills/career-engine-orchestrator/orchestrator-queue.md` Step O1 (original fix; the pattern the other two mirror) | `skills/career-engine-intake/SKILL.md` Steps 0a.5/0b (`$PIPE/hold-role-properties.md`), `skills/career-engine-edit/SKILL.md` Step E0 (`$RUN_PIPE/needs-editing-role-properties.md`, a run-scoped scratch dir distinct from edit's later per-role `$PIPE` at Step E0.pipe) | A consumer that fetches per-page properties inline instead of delegating reproduces the same context-exhaustion failure the orchestrator fix was built to prevent — silently, since nothing in that consumer's own file would flag the drift without tracing it back to the orchestrator's incident. |

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
Notion view URLs change when views are reorganised. The view-discovery mechanism lives once in the Notion adapter (`skills/database-notion/SKILL.md` §3); every Path B query site — intake, the orchestrator, coach, edit, and source-open-roles — delegates to it. It fetches the database, reads the `<views>` list from that single response, and finds the view **by name** ("Hold" / "Interested" / "Needs Editing" / a broad view) rather than relying on a hardcoded URL that silently breaks. Any of the five optional config keys (`database_edit_view_url`, `database_interested_view_url`, `database_hold_view_url`, `database_researched_view_url`, `database_cv_ready_view_url`) can be pre-filled in `pipeline-preferences.json` to use as a fast path — skipping the 59KB DB discovery fetch — but the by-name lookup is always the fallback when a URL is empty or stale.

**The canonical read ladder — the Notion adapter's implementation (consistent across all query sites; see the *Database backend* glossary entry):** A1 (`ntn` CLI, gated, server-side filter) → A2 (`notionApi` `API-query-data-source`, structured filter) → B (standard connector `notion-query-database-view`). Path B is the connector-only fallback and has two hard constraints (R-39): `notion-query-database-view` accepts **no ad-hoc `filter` argument** (it runs the view's own saved filter) and requires a real **view URL** (`...?v=<id>`), never the bare database URL — so Path B is always *fetch-DB → find view by name → query that view URL (no filter) → discovery-only → per-page `notion-fetch` → discard non-matching Status*. If every rung fails, **stop and report** — never treat it as zero results, and never improvise `notion-search`/semantic search to discover queue rows. **The full ladder, view discovery, and writeback mechanics with syntax live in one place — the Notion adapter skill `skills/database-notion/SKILL.md`, loaded whenever `database_backend` is `notion` (the default).** Intake, the orchestrator, edit, and source-open-roles speak in generic operations (query the queue, fetch a record, write a field, resolve a view) and **delegate to the adapter** rather than re-describing it — so a mechanics fix is one edit, not many. (The career coach does no Notion ops — it returns its analysis and intake Step 0.9a writes it.)

**Why the opener rule is a principle, not a template:**
Delivered letters show openers that vary widely in structure — emotional reaction, existing relationship, personal tension, value claim, warm connection. The common thread is specificity: the reader knows that role the user is applying for in the first sentence; within the first two sentences the reader knows why this person wants this role (sum total: why this person is writing now to this company). A fixed template produces generic letters. The rule is: establish that context; how is up to the user's own words — the Why I Want This Role content when present, otherwise the role-matched Motivation Bank entries.

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
| **Advisory violation** | A gatekeeper finding that counts toward the cover letter grade but does not independently block the pipeline. The pass/fail decision is **round-aware** (authoritative grade table in `skills/gatekeeper-checks/SKILL.md`): 0 advisory violations (Grade A) = PASS to humanizer every round; 1–2 (Grade B), 3–4 (Grade C), and 5+ (Grade D) all FAIL back to letter-writer on round 1 but PASS to humanizer on round 2+ (logging the violations). Hard fails override the grade and block every round. |
| **Grade** | The A/B/C/D score the gatekeeper assigns to a cover letter based on advisory violation count. A = 0 violations, B = 1–2, C = 3–4, D = 5+. Hard fails override the grade. |
| **Tier** (keywords) | Classification of JD keywords into Critical / Important / Nice-to-have for the gatekeeper's ATS pre-check. Thresholds: Critical ≥80%, Important ≥60%, Nice-to-have = advisory only. |
| **R-41** | Output protocol requiring pipeline subagents to write their full output to a `$PIPE/` file and return only a 1-line status. Keeps orchestrator context small. Violations bloat the run. Applies to inputs too, not just outputs: large content (JD text, row payloads, a subagent's prior output) passed between pipeline steps belongs in a `$PIPE/` file referenced by path, never pasted inline into a spawn prompt or re-read in repeated chunks. A `$PIPE/` file's content belongs to the agent that wrote it — another agent (including the orchestrator itself) reads it, but never hand-edits it; a revision goes back through the owning agent, always. |
| **R-37** | Data root rule: personal-data files load from `${CAREER_DATA}/references/`. Plugin files load from `${CLAUDE_PLUGIN_ROOT}/`. Never hardcode paths. |
| **Database backend** | The tracker that holds the user's job-application records. The pipeline speaks in generic operations — query the queue, fetch a record, write a field, resolve the edit view — implemented by **the Notion adapter** (the only backend shipped today). Its mechanics — the A1→A2→B read ladder, view discovery, and property/page-body writeback — are spelled out once in the **`database-notion` skill** (`skills/database-notion/SKILL.md`), a MANDATORY load whenever `database_backend` is `notion`; pipeline skills delegate to it. A future backend is a sibling adapter skill (e.g. `database-airtable`) with the same generic operations. Config names the backend via `database_backend` (default `notion`) + `database_id` + five optional view URL keys (`database_edit_view_url`, `database_interested_view_url`, `database_hold_view_url`, `database_researched_view_url`, `database_cv_ready_view_url`); the user-facing config is backend-neutral. Notion is an implementation, not an assumption. Internal `$NOTION_*` shell vars are the adapter's names and stay as-is. |
| **WIWTR** | Why I Want This Role — the user's first-person notes about a *specific* role, stored in the Notion job row. **Role-specific motivation, supplementary to the Motivation Bank** (the standing primary source). It is the primary role-specific input *when present*, but it is **not mandatory**: when WIWTR is empty, the letter-writer writes from the role-matched Motivation Bank entries if a genuine opener is possible, otherwise skips the role (Sufficiency Gate). When WIWTR is present, its distinct points must still all appear in the letter. |
| **Motivation Bank** | The `\| Tags \| Motivation \|` verbatim table in `background/background-motivation-bank.md` (reached via the router in `02-professional-background.md`). The letter-writer's **mandatory primary content/voice source** — loaded and used ahead of any constructed alternative. Each Motivation cell is the user's own words, kept word-for-word; the table is append-only. The WIWTR promotion step (new-application Step 7f; edit Step E10.5) appends new tagged verbatim rows; there is no separate "Promoted from Why I Want This Role" section. |
| **Surgical-only revision** | Letter-writer rule: reviewer feedback authorises touching only what was flagged. Every sentence not explicitly called out stays word-for-word. |
| **Fabrication** | Inventing credentials, outcomes, or experience not present in the user's documented background or WIWTR. Always prohibited. Reviewer flags never authorise fabrication. |

---

## Changelog rules

The changelog lives in `README.md` under `## Changelog`. Rules that must never be violated:

1. **Newest at the top.** Each new entry goes above all prior entries — never below them.
2. **Previous entries are never removed.** Existing entries must remain intact exactly as written. Condensing, rewording, or deleting old entries is prohibited.
3. **Entry heading format:** `### YYYY-MM-DD — <label>` where `YYYY-MM-DD` is the release date and `<label>` describes the shipment — e.g. `Bug fixes`, `Performance improvements`, `New features`, `Consolidated overhaul`. Use whatever label fits the contents; it is not fixed to the word "updates."
4. **One entry per release.** All changes in a single shipped `.plugin` belong under one date heading.

When documenting a release, use this structure (sub-headings within an entry are encouraged when the release is large):

```markdown
### 2026-MM-DD — <label>

**New features**
- **Feature name** — one-line description.

**Improvements**
- **Improvement name** — one-line description.

**Bug fixes**
- **Fix name** — what was broken and how it was fixed.
```

---

## QA Agent

See the mandatory stop gate at the top of this file. The QA agent lives at `agents/qa-plugin.md`. Run it after every edit session. It validates the single shipped `.plugin` artifact (unzipped) for stale references, missing files, property-name consistency, structural integrity, and that it contains zero personal data. The full check list is in the agent file itself.