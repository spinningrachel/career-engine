# CLAUDE.md — Career Engine Plugin

Working instructions for Claude when editing, extending, or maintaining this plugin.

---

## ⛔ MANDATORY STOP — READ BEFORE DOING ANYTHING ELSE

**You are not done with any plugin edit session until the QA agent has run and passed. No exceptions.**

This means: after completing any set of changes — no matter how small — you MUST invoke the QA agent (`agents/qa-plugin.md`) before telling the user the work is complete. This is not optional and cannot be skipped because the changes "seem clean" or because you "already checked manually." Manual checking is how drift accumulates silently.

**The QA agent also checks for drift between the two plugin versions.** Every change must be applied to BOTH:
1. The open-source repo at the path shown in this file
2. The personal canonical version at `~/Downloads/career-engine.plugin` (a zip archive — extract to edit, repackage when done)

If a change was made to one version and not the other, the QA agent will catch it. Do not declare work complete before it does.

**How to invoke:** Spawn the QA agent by reading `agents/qa-plugin.md` and following its instructions. Pass it both plugin paths.

This gate applies to: any content edit, any rename, any new file, any property name change, any structural change, any cross-version sync. If you edited even one file, run QA.

---

---

## Two-version architecture

This plugin exists in two versions that must stay in sync:

| Version | Location | Purpose |
|---|---|---|
| **Open-source repo** | `<repo-root>/` | Public distribution. Uses `{{USER_FULL_NAME}}`, `{{USER_FIRST_NAME}}`, `{{OUTPUT_FOLDER}}` and other `{{...}}` placeholders throughout. No personal info. |
| **Personalized (canonical)** | `~/Downloads/career-engine.plugin` | Your live installation. Real names, real paths, personal background files, delivered letters archive. Maintained as a zip — extract to edit, repackage when done. |

> **Canonical personal version:** `~/Downloads/career-engine.plugin`  
> This is a zip archive. To edit: extract to a temp directory, make changes, repackage. The session copy at `~/Library/Application Support/Claude/local-agent-mode-sessions/...` is ephemeral — do not maintain it.

**The sync rule:** any change to one version must be applied to the other in the same session, with the exceptions below.

**Exceptions — do NOT sync:**
- Personal info in the personalized version (real names, real paths, personal candidate rules and company-specific examples) → stays in personalized only
- Placeholder values in the open-source version (`{{USER_FULL_NAME}}` etc.) → never replaced with real names in the repo
- `references/pipeline-preferences.json` — exists in both versions; the repo ships defaults (`gap_handling: enabled`), the personalized version carries the user's actual choices. Sync new keys and structure only — never overwrite the personalized values with repo defaults.
- `references/delivered-letters/` — exists in both versions; personalized version contains real sent letters; open-source version contains only INDEX.md with placeholder guidance. Managed via Option 3 of the letter-writer agent. Cap: 6 letters.
- `references/{{USER_DOTX_FILE}}.dotx` — personalized only (your Word template for DOCX export)
- `references/02-professional-background.md`, `references/01-writing-rules.md`, `references/03-framework.md` — exist in both but contain personal content in personalized version; sync structural/procedural changes only, not personal data
- `references/linkedin-profile.md` — exists in both; the repo ships the placeholder template, the personalized version carries the user's real LinkedIn snapshot (replaced wholesale via update-refs from a fresh LinkedIn PDF export). Sync template/structure changes only, never profile content. Optional by design — agents fall back when missing or templated.
- `agents/qa-plugin.md` — exists in both with the same checks and structure; the personalized version carries the literal installation values (paths, database ID, name/email mapping, banned-string greps), the repo carries `<your-...>` placeholders in those positions. Sync check logic and structure only — never copy literal values into the repo or placeholders into the personalized copy.
- `docs/` (planning archives) — personalized version only. The public repo ships no planning docs; they contain personal session context.

---

## Content placement rules

### Agents (`agents/`)
**Orchestration only.** An agent file defines identity (what this agent is), invocation modes, what files to load, what steps to follow, and what to return. It does not contain:
- Writing craft or doctrine (→ belongs in the relevant skill)
- Personal examples, company names, or candidate-specific rules (→ belongs in references)
- Fabrication rules or voice profile (→ `01-writing-rules.md`)

The agent's Role section should be 3–6 lines max. Everything else is procedure.

### Skills (`skills/`)
**Doctrine and craft.** Writing rules, positioning philosophy, use-case patterns, checklists, and strategic frameworks live here. If a rule applies every time a task is performed, it belongs in the skill, not the agent.

Skills are loaded by agents via `Read` — they are not auto-activated by the platform based on context for pipeline agents. Each agent explicitly instructs itself to load the skills it needs.

### References (`references/`)
**Source material.** Background facts, candidate rules, voice profile, self-check checklists, templates, and delivered letters. Agents read references; they never write to them except via explicit pipeline steps (e.g., the `02-professional-background.md` Why I Want This Role promotion in new-application Step 7f / edit Step E10.5).

### Commands (`commands/`)
Slash commands. Thin — they invoke skills, not implement logic directly.

---

## Drift prevention

Drift happens when one version gets an edit and the other doesn't. To check for drift:

```bash
# Compare a specific file between versions (adapt paths to your installation)
diff <repo-root>/agents/letter-writer.md \
     <plugin-cache>/agents/letter-writer.md
```

Common drift sources:
- Linters or auto-formatters modifying the installed version
- Session compaction causing a change to be applied to only one version
- Personal edits made directly in the installed version without updating the repo

When you notice a drift, resolve it before making further changes. Establish which version is authoritative (usually: whichever has the most recent intentional change) and bring the other into alignment.

---

## Sync procedure

When making a content change:

1. Edit the **open-source repo** first — write with `{{USER_FULL_NAME}}` / `{{USER_FIRST_NAME}}` etc. placeholders. **Carve-out:** the `update-refs` skill legitimately applies the personalized version first (the user's materials arrive personal); its structural slice still syncs to the repo with placeholders in the same session, and Check 6c backstops leaks.
2. Apply the **same change** to the personalized version — substitute real names/paths, add personal specifics where appropriate
3. If the change involves personal data (e.g., candidate rules, background facts) — edit the personalized version only
4. After a batch of changes, **repackage both .plugin files** (see below)

---

## Packaging

Both `.plugin` files are zip archives. Rebuild after any batch of changes:

```bash
# Open-source plugin (run from repo root — adapt path to your installation)
cd <repo-root>
python3 -c "
import zipfile, os
exclude = {'.git', '__pycache__', '.DS_Store', '.in_use'}
with zipfile.ZipFile('career-engine.plugin', 'w', zipfile.ZIP_STORED) as zf:
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in exclude]
        for file in files:
            if file in exclude or file.endswith('.plugin'):
                continue
            zf.write(os.path.join(root, file), os.path.join(root, file)[2:])
print('Done.')
"

# Personal plugin (adapt paths and dotx backup filename to your installation)
cd <plugin-cache>
python3 -c "
import zipfile, os
exclude = {'.git', '__pycache__', '.DS_Store', '.in_use', '<user-dotx-file>.dotx.bak'}
with zipfile.ZipFile(os.path.expanduser('~/Downloads/career-engine.plugin'), 'w', zipfile.ZIP_STORED) as zf:
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in exclude]
        for file in files:
            if file in exclude or file.endswith('.plugin'):
                continue
            zf.write(os.path.join(root, file), os.path.join(root, file)[2:])
print('Done.')
"
```

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
Agent files are open-source. Personal writing philosophy, specific candidate rules, and strategic framing would leak into the public repo if kept in agents. Skills can hold personal content in the personalized version while the open-source skill uses generic placeholders.

**Why the pipeline cap is 5 roles:**
The employment coach runs as a single subagent with all roles in context. Beyond 5, context quality degrades. The intake skill processes all roles when there are ≤5 (no priority ordering needed); priority ordering only applies when there are >5 and a selection must be made.

**Why view discovery replaces hardcoded view URLs:**
Notion view URLs change when views are reorganised. The intake skill now fetches the database, reads the view list, and finds the view by name ("Hold" or "Interested") rather than relying on a hardcoded URL that silently breaks.

**Why the opener rule is a principle, not a template:**
Delivered letters show openers that vary widely in structure — emotional reaction, existing relationship, personal tension, value claim, warm connection. The common thread is specificity: within two sentences the reader knows why this person is writing to this company right now. A fixed template produces generic letters. The rule is: establish that context; how is up to the Why I Want This Role content.

---

## QA Agent

See the mandatory stop gate at the top of this file. The QA agent lives at `agents/qa-plugin.md`. Run it after every edit session — it checks both plugin versions for drift, stale references, missing files, property name consistency, and structural integrity. The full check list is in the agent file itself.

---

## Known regression checks

These bugs were confirmed in live intake runs, diagnosed, and fixed. Every future edit session that touches the affected files must verify that none of these have regressed. The QA agent checks structural compliance; these are behavioral compliance checks that require reading the relevant sections.

**Rule: when a new bug is found, diagnosed, and fixed in any session, add it here before closing.**

| # | Bug name | Root cause | Confirmed fix | Where to verify |
|---|---|---|---|---|
| R-1 | **Misaligned rendered tables must never be parsed** | `notion-query-database-view` returned misaligned tabular output — 17 companies, 16 status tags, causing parsing failures | Step 0b uses `notionApi` `API-query-data-source` (Path A) whenever the server is connected and working; where it is absent or unusable (e.g. Cowork), `notion-query-database-view` is sanctioned as Path B for page discovery only — property values are always read per page via `notion-fetch`, never from the rendered table; the same discovery-only rule applies to the edit pipeline's E0 view query and the coach pipeline's Step 2 view query (refined by R-25) | `skills/career-engine-intake/SKILL.md` → Step 0b; `skills/career-engine-edit/SKILL.md` → Step E0; `skills/career-engine-coach/SKILL.md` → Step 2 |
| R-2 | **No Notion view creation or modification** | Agent created `_intake_hold_temp` view as a workaround when query failed, burning tokens and leaving a permanent stale artifact | `create-database-view`, `update-database-view`, and all equivalent tools are prohibited under any circumstance | `skills/career-engine-intake/SKILL.md` → Step 0b prohibition |
| R-3 | **Indeed URLs must use connector fallback** | Indeed's authentication wall blocks plain `WebFetch`; agent marked roles as unfetchable instead of routing through the Indeed connector | When a Job URL contains `indeed.com`, attempt `search_jobs(keyword="[title] [company]")` before marking as unfetchable | `skills/career-engine-intake/SKILL.md` → Step 0.5 |
| R-4 | **No Bash/Grep on Notion MCP sandbox files** | Notion MCP saves query results inside its sandbox — the path is unreachable by host-side Bash or Grep, causing silent failures | All Notion result processing must happen through MCP tools in context, never via host-side file reads | `skills/career-engine-intake/SKILL.md` → Step 0b |
| R-5 | **Always fetch URL even when JD Body is populated** | Agent skipped URL fetch when `JD Body` was already populated, missing updated requirements and recruiter info | Must attempt `WebFetch` on Job URL for every role that has one, regardless of whether `JD Body` is already populated | `skills/career-engine-intake/SKILL.md` → Step 0.5 |
| R-6 | **Edit pipeline JD-unavailable hard-drop** | Step E0.5 said "log the failure and skip this role" but did not explicitly remove the role from subsequent steps, leaving the agent free to silently continue with no JD | When JD Body is empty AND coach cannot access the URL, the role must be **hard-dropped from E0.7 onward** with a specific log message; E0.5 now reads "Remove from all subsequent steps (E0.7 onward)" | `skills/career-engine-edit/SKILL.md` → Step E0.5, point 2 |
| R-7 | **Edit Step E0 missing tool path** | Step E0 said "Query the database" with no tool specified, leaving the agent to pick any Notion tool. On a live run the agent used `notionApi` (broken, 401) instead of `notion-query-database-view` | Step E0 now specifies `notion-query-database-view` with the pre-built "Needs Editing" view URL and a named fallback via `notion-fetch` view-list discovery if the URL breaks | `skills/career-engine-edit/SKILL.md` → Step E0 |
| R-8 | **Edit Preflight state.json discovery fragile** | Preflight described the `cv_path` format as `applications-<YYYY-MM-DD>/<filename>.docx` and assumed a single naming convention, but actual state.json files live in legacy `cv-campaign-YYYY-MM-DD/` folders from earlier pipeline runs | Preflight now searches both `applications-<YYYY-MM-DD>/` and `cv-campaign-YYYY-MM-DD/` patterns and derives the run folder from the directory containing the matching state.json | `skills/career-engine-edit/SKILL.md` → Preflight, point 1 |
| R-9 | **Humanizer misses "that exact [abstraction]" determiner pattern** | A delivered letter contained "I lived in that exact loop at [Company]" — the Demonstrative-declaration rule only banned sentence-initial "that's where/what/the kind of" contractions, and the Pronoun-pointing rule only covered bare pronouns; "that" as a *determiner* modifying an agent-coined noun ("loop") slipped through both | New Step 3 rule bans the entire format "[subject] [verbed] exactly that [object]" and all variants where "that"/"this" modifies an abstraction the letter itself coined ("that exact loop," "exactly that motion," "this same playbook"); Final Gate checklist updated to match | `skills/cover-letter-humanizer/SKILL.md` → Step 3 table + Final Gate Step 3 line |
| R-10 | **Setup substitution breaks config guard** | The setup script replaced `{{NOTION_DATABASE_ID}}` inside the guard sentence itself, so the guard read "if the ID reads `<real-id>`, stop" — halting every correctly configured run | Guard wording is now substitution-proof: it checks whether the value "still contains the characters `{{` and `}}`" rather than naming the placeholder token | `skills/career-engine-intake/SKILL.md` → Step 0 guard; `skills/career-engine-edit/SKILL.md` → Step E0 guard |
| R-11 | **Stale Step 0.9c reference** | Intake steps go 0.9a → 0.9b → 0.9d; two files pointed at a nonexistent "Step 0.9c" for Status cleanup | Both references now point at Step 0.9d | `skills/career-engine-intake/SKILL.md` → queue selection; `skills/career-engine-orchestrator/SKILL.md` → pipeline list |
| R-12 | **--status reads a `languages` field state.json never writes** | Orchestrator `--status` inferred Hebrew outputs from a `languages` field absent from the Step 7b state.json schema, so the inference always failed | Hebrew detection now uses filenames: a `-he` suffixed DOCX in the company subdirectory marks the role as having Hebrew outputs | `skills/career-engine-orchestrator/SKILL.md` → --status section |
| R-13 | **Edit-pipeline gatekeeper loops uncapped** | Steps E3.5, E6.5, E7.3, E7.7 said "Repeat until PASS" with no cap, unlike the main pipeline's 3-pass cap — an unresolvable violation looped indefinitely | All four loops now carry "Cap: 3 revision passes" with log-flag-and-continue fallback | `skills/career-engine-edit/SKILL.md` → E3.5, E6.5, E7.3, E7.7 |
| R-14 | **State-file clarification drift (REPO behind LIVE)** | The R-8 crash-recovery clarification in the State file section was applied to LIVE only, leaving REPO with the old single-path wording | REPO State file section now matches LIVE ("append to the state.json in the role's run folder, identified in Preflight step 1") | `skills/career-engine-edit/SKILL.md` → State file section |
| R-15 | **Edit E0.7 baseline check ran without a JD for needs-fetch roles** | E0.7 spawned the gatekeeper "passing the structured JD" — but a role marked `needs-fetch` in E0.5 has no JD until the coach fetches it in E1, so the baseline check ran against an empty JD | E0.7 now defers the baseline check for `needs-fetch` roles until after E1 confirms a JD; hard-dropped roles get no baseline check | `skills/career-engine-edit/SKILL.md` → Step E0.7 |
| R-16 | **needs-manual roles could receive Status = Researched** | Step 0.8 removed `needs-manual` roles from the *coach* queue but Step 0.9d wrote `Researched` to "every role in the processing queue" — a literal reading marked an uncoached role Researched, hiding it from future intake runs | `needs-manual` roles are now removed from the processing queue entirely (excluded from all of Step 0.9 including 0.9d); their Status stays unchanged so they reappear next run | `skills/career-engine-intake/SKILL.md` → Step 0.8 pre-coach filter + Step 0.9d |
| R-17 | **Page body survived a requested full elimination + "optional content" contradiction** | A prior session was asked to eliminate page body entirely but it survived in 13 files per version; worse, `cover-letter/SKILL.md` declared Why I Want This Role "optional supplemental material — not mandatory", directly contradicting the Pre-Step 5 hard gate (letter skipped when empty), the sole-opener-source rule, and the letter-writer Intake Gate | All page body references removed from both versions (letter inputs, gatekeeper passing, intake manual-JD fallback, coach Q&A location, setup CSV columns, README, self-check); the integration-rules paragraph now states Why I Want This Role is the mandatory primary personal-content source — individual pieces may be set aside if non-compliant, but the letter is never written without the field | grep `-i "page body"` across both versions must return zero hits outside CLAUDE.md/docs; `skills/cover-letter/SKILL.md` → Input Integration Rules |
| R-18 | **--now mode promised a letter the Intake Gate refuses to write** | `--now` roles have no Notion row, so Why I Want This Role is necessarily absent — Pre-Step 5 was skipped, letter-writer was spawned, and its Intake Gate refused, while the orchestrator deliverables table promised a cover letter | Step N4 now collects Why I Want This Role from the user in chat before Step 5; if declined, the letter track is skipped and CV only is delivered; deliverables table updated to match | `skills/career-engine-orchestrator/SKILL.md` → Step N4 + run-modes table |
| R-19 | **Edit pipeline E7 had no Why I Want This Role gate** | Step E7 said "include if populated; skip if empty" and spawned letter-writer regardless — with the field empty the Intake Gate refused and E7.25–E7.7 had no defined behavior for a refused spawn | New gate at the top of E7: empty field → Edit type `Both` continues CV-only (skip E7–E8); Edit type `Letter` skips the role entirely; both log a fill-it-in-and-re-run message | `skills/career-engine-edit/SKILL.md` → Step E7 gate |
| R-20 | **Orchestrator hand-assembled a final letter** | When the letter-writer regressed twice, the orchestrator spliced fixes onto a base it picked itself — the assembled text bypassed every gate and shipped with 5+ named rule violations ([Company], June 2026) | New Absolute Constraint: orchestrator never authors document content beyond the explicitly authorized mechanical inline fixes; writer failure at cap → deliver last passing version flagged for manual review | `skills/career-engine-orchestrator/SKILL.md` → Absolute Constraints; `skills/career-engine-edit/SKILL.md` → Hard rules |
| R-21 | **Writer agents regressed previously fixed violations** | Revision spawns received only the latest violation list, so the writer freely reverted to older bases and reintroduced fixed violations (twice in one role) | Every revision loop now passes an accumulated per-document fix log with the locked-fixes instruction; reintroducing a fixed violation is itself a FAIL; regression → re-spawn with the regression named, never hand-patch | `skills/career-engine-orchestrator/SKILL.md` → Absolute Constraints; all revision loops in `career-engine-new-application` and `career-engine-edit` |
| R-22 | **Humanizer PASS trusted on self-report; exported text never re-verified** | The humanizer modifies text after the final gate, and the pipeline trusted its self-reported PASS — a letter violating the humanizer's own Step 1 rules four times was exported | New final-bytes rule: any change after a PASS invalidates it. Step 5.95 (main) / E8.5 (edit): mechanical pre-export checklist + one gatekeeper pass on the exact markdown being converted; cap 2; after cap revert to last gate-passed text and flag | `skills/career-engine-new-application/SKILL.md` → Step 5.95; `skills/career-engine-edit/SKILL.md` → Step E8.5 |
| R-23 | **needs-manual without exhausting retrieval fallbacks** | Intake Step 0.5 had only domain-specific fallbacks (LinkedIn/Indeed URLs); a JavaScript-rendered career page or any other blocked URL went straight to `needs-manual`, even though the LinkedIn MCP keyword search and a web search for mirrored postings usually find the JD elsewhere — the employment coach's own fetch ladder (`agents/employment-coach.md` Step 2) already did this, but `needs-manual` roles never reach the coach (Step 0.8 pre-coach filter) | Step 0.5 now has a universal fallback ladder (LinkedIn MCP `search_jobs` → company careers page → ATS/board mirrors → exact-title search) mirroring the coach's fetch ladder, applied to every failed fetch regardless of domain; a fetch returning a page with no JD content (JS shell, cookie wall) counts as failed; `needs-manual` is valid only after the full ladder is attempted and the attempts are logged | `skills/career-engine-intake/SKILL.md` → Step 0.5 |
| R-24 | **Pre-launch scope re-asking despite an explicit pipeline command** | The user asked to "run a new application pipeline"; after queueing the 5 Interested roles the orchestrating agent paused with a blocking question proposing to reroute to the edit pipeline because the rows showed recent `Last Pipeline Run` dates and `Edit type: Letter` — second-guessing an explicit command using row metadata | New Absolute Constraint: the named pipeline command is the routing authority; row metadata (`Edit type`, `Last Pipeline Run`, prior outputs) is context, never a veto; observations go in the briefing as a one-line note and the run proceeds | `skills/career-engine-orchestrator/SKILL.md` → Absolute Constraints |
| R-25 | **notionApi mandate made the pipeline unrunnable in Cowork** | The June 8 fix for R-1 banned `notion-query-database-view` outright and the June 10 hardening added "stop immediately, no fallback" — but the `notionApi` server only exists in the Claude Code environment, while the user runs output pipelines in Cowork (standard Notion connector only). Step 0b therefore could never legitimately pass in the primary runtime; one live agent proceeded only by violating R-1, and a second run hit the same wall on intake | Step 0b is now two-tier: Path A (`notionApi`, preferred) / Path B (`notion-query-database-view` for page discovery only, properties read per page via `notion-fetch`, sanctioned when the server is absent or unusable — including non-tool-not-found errors like a 401); the same fallback applies to the source-open-roles dedup query (fail open: skip dedup with a warning rather than parse a misaligned table) | `skills/career-engine-intake/SKILL.md` → Step 0b; `skills/source-open-roles/SKILL.md` → Deduplication; `agents/source-open-roles.md` → Step 1 |
| R-26 | **Three naming generations coexisted; rename passes corrupted their own records** | The June 1 rename (cv-campaign → career-engine) skipped the local repo folder, skill IDs, and prose; the June 8 refactor renamed skills to application-* but its global find-replace rewrote the OLD names inside the plan doc and QA Check 4's banned list — leaving Check 4 banning the live skill names and the plan doc mapping names to themselves; "CV campaign"/"campaign" prose survived in the README, orchestrator triggers, and skill descriptions | All pipeline skills renamed to `career-engine-*` (intake, orchestrator, new-application, edit, export, coach); local repo folder renamed to `~/career-engine`; campaign branding prose eliminated; Check 4 rewritten to ban both retired generations (with the legacy `cv-campaign-YYYY-MM-DD` folder-pattern exception) and Check 4b added for terminology; rule: when renaming, exclude QA ban lists and plan docs from global find-replace and update them by hand | `agents/qa-plugin.md` → Checks 4/4b; `skills/` directory names |
| R-27 | **Fallback ladder relied on WebFetch alone; JS shells and auth walls dead-ended fetchable JDs** | Two live intake runs marked two fetchable roles `needs-manual` after running the full R-23 ladder — every rung fetched with plain `WebFetch`, which cannot render JavaScript career pages or pass LinkedIn auth walls, and the mirror rung's `site:` list missed investor career boards and BuiltIn mirrors; meanwhile rendering-capable extractors connected to the session (Tavily advanced extract, Exa fetch) retrieved both JDs on the first try — including straight through the LinkedIn auth wall | New rung 1 of the intake ladder and step 2 of the coach fetch ladder: discover rendering-capable extraction tools via ToolSearch (`extract`/`crawl`/`scrape`/`browser`) and use the strongest available on the original URL and on every candidate mirror; mirror searches widened beyond the `site:` list (investor career boards, BuiltIn, open search); a JS shell or auth wall is a fetcher-switch signal, not a dead end; also fixed coach writing nonexistent `Fetched-alternative` schema option (now `Fetched` + source-URL note in JD Body) | `skills/career-engine-intake/SKILL.md` → Step 0.5 ladder; `agents/employment-coach.md` → fetch ladder |
| R-28 | **gap_handling preference written to a machine-local file the runtime can't see** | Setup Phase 5 wrote `gap_handling` to `~/.claude/settings.json` on the user's machine; intake Step −1 and the coach pre-flight read it from there — but Cowork sessions cannot reach the user's home directory, so the key read as missing and the documented default (`enabled`) silently overrode the user's `disabled` choice; the coach pre-flight also used a Bash command the coach agent (no Bash tool) cannot run, and instructed writing `N/A` to `Gap handling` in direct contradiction of intake Step −1's do-not-populate rule | Preference moved into the plugin: `references/pipeline-preferences.json` (ships in the zip, readable via Read in every environment); intake Step −1 reads plugin file → legacy `~/.claude/settings.json` → default; coach pre-flight uses spawn-prompt value → plugin file → default (Read tool, no Bash) and never writes `N/A`; setup Phase 5 writes the plugin file and warns against the home-dir location | `references/pipeline-preferences.json`; `skills/career-engine-intake/SKILL.md` → Step −1; `skills/employment-coach/SKILL.md` → Settings pre-flight; `skills/career-engine-setup/SKILL.md` → Phase 5 |
| R-29 | **Q&A property retired in Notion but wiring survived; answers had no read path** | The `Q&A` Notion property was removed from the database, but coach pipeline Step 4.5 still spawned `letter-writer` with `option=interview-questions` (an option deleted from the letter-writer agent, whose options are 1/1b/3 with an explicit "Do NOT generate questions" rule) and wrote to the nonexistent property; meanwhile no writing pipeline ever read Q&A answers — letter-writer inputs, new-application, edit, and orchestrator had zero references — so any user content there was silently ignored; stale mentions survived in gatekeeper Option 2 ("Q&A answers" plus an `Additional Letter Writer Details` property referenced nowhere else), humanizer Step 3, REFERENCES.md, 02-professional-background §5, README, and the coach skill description | All Q&A and interview-question wiring removed (coach Step 4.5 deleted; gatekeeper Option 2 input reduced to Why I Want This Role; humanizer, REFERENCES.md, README, coach description cleaned); 02-professional-background §5 rebranded as the Motivation Bank with a "Promoted from Why I Want This Role" subsection; new feedback loop added — new-application Step 7f and edit Step E10.5 promote new durable Why I Want This Role content into §5 verbatim (append-only; new Section 7-grade facts are flagged for approval, never auto-written); Why I Want This Role doctrine rescoped: sole source for the opener, leveraged throughout the entire letter with a strong preference to use all provided info and default to the user's tone and vocabulary | `skills/career-engine-coach/SKILL.md`; `agents/gatekeeper.md` → Option 2; `skills/cover-letter/SKILL.md` → Input Integration Rules; `agents/letter-writer.md` → inputs; `skills/career-engine-new-application/SKILL.md` → Step 7f; `skills/career-engine-edit/SKILL.md` → Step E10.5; `references/02-professional-background.md` → §5 |
| R-30 | **Output-path preflight assumed sandbox Bash; Cowork runs hard-stopped despite available host access** | The orchestrator path verification and edit-pipeline preflight verified the iCloud output folder with sandbox Bash (`ls`/`mkdir -p`) and mandated "stop immediately, do not fall back to any other path" — but in Cowork the sandbox cannot reach the user's filesystem, so a live edit run stopped at preflight and reported the folder unreachable, even though Desktop Commander MCP tools (which setup explicitly allowlists, and which a successful new-application run used the same day for reads, writes, and host-side pandoc via `start_process`) had full access; the no-scratchpad rule had been conflated with "only sandbox Bash counts as access"; a second run also lost Desktop Commander mid-run with no defined behavior | Path verification is now a two-tier ladder mirroring R-25: Path A (direct filesystem Bash) / Path B (host-bridge MCP — discover Desktop Commander or equivalent host filesystem/process tools via ToolSearch, verify by listing the output folder, then route ALL run file operations through them, with pandoc via the host process tool and intermediate markdown written host-side because sandbox `/tmp/` is invisible to host pandoc); both fail → stop with connect-folder/enable-tool guidance; no-scratchpad rule unchanged on both paths; mid-run host-access loss → retry once, then deliver remaining file contents in chat flagged for manual save — never a substitute path | `skills/career-engine-orchestrator/SKILL.md` → Mandatory path verification; `skills/career-engine-edit/SKILL.md` → Preflight; `skills/career-engine-export/SKILL.md` → Step 6 environment note |
| R-31 | **Two delivered-letters locations; the drafting agent's archive was empty** | Setup stored approved sent letters in an iCloud output-folder subdirectory (`final-pdfs-delivered/`), which only the humanizer and gatekeeper read — while the letter-writer's mandatory pre-draft voice calibration and the cover-letter skill read the in-plugin `references/delivered-letters/` archive, which had never been populated (count 0). Every draft was written with zero delivered-letter calibration, silently falling back to framework-only voice — a major driver of heavy manual post-editing; the iCloud path was also unreachable from sandboxed runtimes (the R-30 class of problem) and the user had explicitly requested the iCloud location be eliminated | Single canonical archive: `references/delivered-letters/` (in-plugin, ships in the zip, cap 6, letter-writer Option 3 format). All four consumers repointed (letter-writer and cover-letter skill already there; gatekeeper Option 2 and humanizer agent step 1 repointed with `${CLAUDE_PLUGIN_ROOT}` prefix); setup Phases 2/3/4/5 store to and reference only the archive; 02-professional-background §10 pointer updated; the personalized archive populated with 5 as-sent letters + INDEX; Check 4d bans the retired location | `agents/gatekeeper.md` → Option 2 note; `agents/cover-letter-humanizer.md` → step 1; `skills/career-engine-setup/SKILL.md` → Phases 2/3/4/5; `references/delivered-letters/INDEX.md`; `agents/qa-plugin.md` → Check 4d |
| R-32 | **Rule list encoded an anti-AI aesthetic that fought the user's real voice; the drafting agent calibrated against an empty archive while named rules outranked sent letters** | The humanizer/cover-letter style rules (subject-first openers, demonstrative-declaration bans, sign-off mandate, vocabulary strictures) were calibrated against agent failure modes but enforced as absolute style truths; the user's actual sent letters violate many of them (4–5 of 5 letters open with dependent/prepositional ramps; one contains the literal ban-table example "that's the work I do"); the R-9 precedent resolved rule-vs-delivered-letter conflicts by banning the pattern; multi-pass revision loops ratcheted drafts toward the doctrine register and away from the user; meanwhile every rewrite stage lacked quantitative voice targets | Voice calibration package: (0) archive recomposed to the user's curated five letters (em dashes in one letter documented as editing-fatigue artifacts — the em-dash ban stands); (1) quantitative voice fingerprint added to `03-framework.md` §Voice (constants as targets, flex variables never mandated, hard slop prohibitions retained); (2) HIERARCHY rewritten as tiers — Tier 1 truth absolute over all inputs including the user's, Tier 2 structure (opener sourcing/content + letter structure) fully intact and strict, Tier 3 voice/register governed by archive + fingerprint with conflicts flagged for rule audit, never silently fixed toward the rule; (3b) humanizer loads the full stack: rule skill + archive + fingerprint + framework voice sections; letter-writer pre-read includes the fingerprint; rules audit of Tier 3 rules vs the five letters delivered as per-rule proposals for user adjudication | `skills/cover-letter/SKILL.md` → HIERARCHY; `skills/cover-letter-humanizer/SKILL.md` → preamble; `agents/cover-letter-humanizer.md` → loading steps; `references/03-framework.md` → §Voice fingerprint; `references/delivered-letters/INDEX.md`; `agents/qa-plugin.md` → Check 21h |
| R-33 | **Public repo carried real installation values and personal context** | The QA agent's own file shipped the real Notion database ID, output-folder path, machine paths, email, dotx filename, and banned-string greps in the public repo (Check 6c excluded the file that contained the leaks); the source-open-roles preferences schema example carried a real database ID and location; the export skill carried a half-templated dotx filename and an un-templated candidate-name doctrine line; CLAUDE.md regression rows and skill worked examples named real companies from the user's application history; planning docs with personal context were tracked in the public repo | Full scrub, repo side only, personal version preserved untouched: qa-plugin.md repo copy now carries `<your-...>` placeholders for every installation value (new sync exception — values live only in the personalized copy); schema example genericized; export skill templated; regression rows genericized in the repo copy; shared worked examples fictionalized (Acme/Initech/Globex/Northwind/Contoso/NovaSec) identically in both versions; `docs/` removed from the repo (personalized only). Note: git history retains pre-scrub values — rotating the Notion database ID is the only complete remedy for it | `agents/qa-plugin.md`; `skills/source-open-roles/SKILL.md` → schema example; `skills/career-engine-export/SKILL.md`; `CLAUDE.md` → regression rows + sync exceptions; worked examples in cover-letter/humanizer/employment-coach/source-open-roles |
| R-34 | **Ten-letter shakedown exposed plumbing and rule-coverage gaps the per-file checks could not see** | Two observation runs (5 edit-track, 5 from-scratch letters on live roles) found: four incompatible word-count ranges (230–275 / 230–290 ×2 / 270–320) with a live humanizer deadlock (it may shrink below a floor it cannot repair); the CV-repetition prohibition unenforceable in all four gatekeeper letter checks (CV never passed; the check self-skipped silently) while its own hard-floor wording contradicted the permitted Enhance operation and collided with opener sourcing when the user's motivation mirrors the CV; the gatekeeper never received the R-32 calibration authority — dependent-clause/prepositional archive ramps were hard opening-paragraph FAILs, "nothing after the name" banned archive P.S. lines, "I believe" was banned while praised in the archive INDEX, and the personal-content exemption did not cover the analyst check or banned-word lists; MANDATORY role-named-in-first-sentence had no checker anywhere; the export greps missed "the same [abstraction]"; the edit track keyed on `CV File Name`/`Letter File Name` properties absent from the live schema; stealth roles could never satisfy greeting/company-name checks; Tier 1 discarded the user's own claims silently with no ask-back | Canonical word count: maximum 320, no minimum — floor removed by user ruling (typical band 270–320) at all eight sites; the humanizer floor rule was added then removed with the floor; CV text now passed in all four letter gatekeeper spawns with named skip reporting; hard floor rewritten to "must not be restated" with Enhance as the lawful anchor use; WIWTR-mirrors-CV resolution and proof-point partitioning added; gatekeeper Option 2 got the Calibration authority preamble, agent-drafted-only scoping on ramp violations, stealth greeting/descriptor provisions, role-in-first-sentence check, sign-off default-with-variation + archive P.S.; personal-content exemption extended to analyst check and banned lists with earned-inference carve-out (specificity-slot check explicitly kept full-strength); "the same" added to the abstraction-pointing coverage; file-name properties given run-folder-convention fallbacks; discarded/unreadable input now always surfaced as a named ask-back in final delivery | `skills/cover-letter/SKILL.md`; `skills/gatekeeper-checks/SKILL.md`; `skills/cover-letter-humanizer/SKILL.md`; `agents/letter-writer.md`; `agents/gatekeeper.md`; `skills/career-engine-new-application/SKILL.md`; `skills/career-engine-edit/SKILL.md`; `references/cover-letter-self-check.md`; `skills/career-engine-export/SKILL.md`; `skills/career-engine-orchestrator/SKILL.md` |
| R-35 | **Official Notion CLI adopted as the preferred structured-query rung** | Notion shipped an official CLI (`ntn`, beta, May 2026); a supervised trial against the live database verified keychain auth (no plaintext-token dependency — the token-clobber failure class is structurally closed on this path), server-side filtered queries in under a second with shell-side trimming (raw 388KB for 10 rows reduced to ~100 bytes/row before anything enters context), property writeback via `ntn api PATCH`, and full row-as-markdown reads via `ntn pages get`; the existing ladder had only MCP paths, paying full-payload context costs even in Claude Code where Bash was available all along | The R-25 query ladder gains a top rung: Path A is now A1 (`ntn` CLI, gated on `command -v ntn` + `ntn whoami`, falls through silently when absent) / A2 (`notionApi`, unchanged); Path B unchanged; the gate, not the environment label, decides (a sandboxed session with the CLI installed and a token configured passes; one without falls through — sanctioned routing, never a reportable failure; the gate never installs or prompts for credentials mid-run); the no-Bash-on-query-results rule is scoped to tool responses (A2/B) while A1 shell trimming is the sanctioned mechanism; coach Step 2 and edit E0 get direct-filter A1 equivalents to their pre-built views (filters verified against the live schema); source-open-roles dedup prefers A1; intake 0.9a property writes may use `ntn api PATCH` where A1 is active, same write-only-to-empty rule | `skills/career-engine-intake/SKILL.md` → Step 0b + 0.9a; `skills/career-engine-coach/SKILL.md` → Step 2; `skills/career-engine-edit/SKILL.md` → Step E0; `skills/source-open-roles/SKILL.md` → Deduplication; `agents/source-open-roles.md` → Step 1; `agents/qa-plugin.md` → Check 21 |
| R-36 | **Location clues overlooked; careers page never re-checked; remote roles hard-excluded on geography as written** | A live coach run on a remote-advertised role (exact target title, first-tier on every other criterion) scored it as a hard exclusion because the JD said "fully remote position in the US... primarily EST timezone" — but the JD's own stated reason for EST was "healthy overlap with European business hours" (which the user's timezone satisfies better than EST does), the company hires through a global EOR (Deel) and hires directly in Germany, and a LinkedIn hiring post showed the role open/re-posted for ~17 months — all discoverable, all overlooked; the company careers page was only a fallback fetch rung, never a verification step, so existence and freshness were never confirmed; sourcing had no protection against silently dropping remote roles over geography, which equally harms any user hunting remote roles from outside the restricted country | Sourcing: new mandatory Verification Pass before output (careers-page cross-check with existence/extra-detail/staleness outcomes, full-text + metadata location deep-scan, remote-geography rule — a remote-advertised role is NEVER excluded for a geographic restriction; it is surfaced and included in the Notion-add offer regardless of score with the restriction, its stated reason, and exception-path evidence noted), wired as agent Step 4.5 with `[location: ask-first]` marking. Coach: new agent Step 2b careers-page cross-check (always, including `content-exists` roles; ROLE MAY BE CLOSED flag; 90+ day staleness signal), new Location & eligibility deep-scan section (scan everything including the restriction's stated REASON; exception paths: EOR, out-of-country hires, rationale-vs-location; Location block with suggested 2-line ask-first outreach feeding Priority and Strategy), Part 0 Remote-geography weighting (max one-tier discount when a path exists; Fifth only for structural restrictions with no path; remote roles never silently dropped), Israel Compatibility derived from the deep-scan; Priority Framework criteria 4/5 aligned in both versions | `skills/source-open-roles/SKILL.md` → Verification Pass + Exclusion Rules; `agents/source-open-roles.md` → Steps 4.5/5; `agents/employment-coach.md` → Step 2b + Step 3; `skills/employment-coach/SKILL.md` → Location & eligibility deep-scan + Part 0; `references/01-writing-rules.md` → Priority Framework 4/5; `agents/qa-plugin.md` → Check 21j |
