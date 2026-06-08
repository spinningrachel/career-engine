# CLAUDE.md — Career Engine Plugin

Working instructions for Claude when editing, extending, or maintaining this plugin.

---

## ⛔ MANDATORY STOP — READ BEFORE DOING ANYTHING ELSE

**You are not done with any plugin edit session until the QA agent has run and passed. No exceptions.**

This means: after completing any set of changes — no matter how small — you MUST invoke the QA agent (`agents/qa.md`) before telling the user the work is complete. This is not optional and cannot be skipped because the changes "seem clean" or because you "already checked manually." Manual checking is how drift accumulates silently.

**The QA agent also checks for drift between the two plugin versions.** Every change must be applied to BOTH:
1. The open-source repo at the path shown in this file
2. The personal canonical version at `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`

If a change was made to one version and not the other, the QA agent will catch it. Do not declare work complete before it does.

**How to invoke:** Spawn the QA agent by reading `agents/qa.md` and following its instructions. Pass it both plugin paths.

This gate applies to: any content edit, any rename, any new file, any property name change, any structural change, any cross-version sync. If you edited even one file, run QA.

---

---

## Two-version architecture

This plugin exists in two versions that must stay in sync:

| Version | Location | Purpose |
|---|---|---|
| **Open-source repo** | `<repo-root>/` | Public distribution. Uses `{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, `{{OUTPUT_FOLDER}}` placeholders. No personal info. |
| **Personalized (canonical)** | `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/` | Your live installation. Real names, real paths, personal background files, delivered letters archive. |

> **Canonical personal version:** `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`  
> The cowork session copy at `~/Library/Application Support/Claude/local-agent-mode-sessions/...` is ephemeral — do not maintain it. All personal edits go to the canonical path above.

**The sync rule:** any change to one version must be applied to the other in the same session, with the exceptions below.

**Exceptions — do NOT sync:**
- Personal info in the personalized version (real names, real paths, personal candidate rules and company-specific examples) → stays in personalized only
- Placeholder values in the open-source version (`{{USER_FIRST_NAME}}` etc.) → never replaced with real names in the repo
- `references/delivered-letters/` — exists in personalized only; historical archive, never edit
- `references/{{USER_DOTX_FILE}}.dotx` — personalized only (your Word template for DOCX export)
- `references/02-professional-background.md`, `references/01-writing-rules.md`, `references/03-framework.md` — exist in both but contain personal content in personalized version; sync structural/procedural changes only, not personal data

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
**Source material.** Background facts, candidate rules, voice profile, self-check checklists, templates, and delivered letters. Agents read references; they never write to them except via explicit pipeline steps (e.g., `02-professional-background.md` Q&A promotion in Step 0.9).

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

1. Edit the **open-source repo** first — write with `{{USER_FIRST_NAME}}` placeholders
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
Delivered letters show openers that vary widely in structure — emotional reaction, existing relationship, personal tension, value claim, warm connection. The common thread is specificity: within two sentences the reader knows why this person is writing to this company right now. A fixed template produces generic letters. The rule is: establish that context; how is up to the Q&A content.

---

## QA Agent

See the mandatory stop gate at the top of this file. The QA agent lives at `agents/qa.md`. Run it after every edit session — it checks both plugin versions for drift, stale references, missing files, property name consistency, and structural integrity. The full check list is in the agent file itself.
