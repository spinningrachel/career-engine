> **⚠️ RECORD CORRUPTED (noted 2026-06-11):** a later global find-replace rewrote the original (pre-rename) skill names in this plan, so Task 3's rename mapping now shows names mapping to themselves. The original names were the `cv-campaign-*` generation. Do not use this document as a rename reference — see CLAUDE.md regression row R-26.

# Career Engine Plugin Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the cv-campaign plugin to career-engine, consolidate the three plugin versions into two canonical copies, merge old.md into CLAUDE.md, repackage commands as skills, and add a QA agent.

**Architecture:** Three plugin locations exist (open-source repo, cowork session copy, live personal installation). The live personal installation (`local-desktop-app-uploads/career-engine/`) is the canonical personal version — changes there + in the repo are the sync pair. The cowork session copy is ephemeral and will not be maintained going forward. All skill/command renames are applied to both the repo and the live personal installation.

**Tech Stack:** Bash (file operations, find/replace), Python (plugin repackaging)

---

## Locations

| Identifier | Path |
|---|---|
| **REPO** | `/Users/rachel/cv-campaign-plugin/` |
| **LIVE** | `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/` |
| **COWORK** | `/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/` |

## Skill/Directory Name Mapping

| Old name | New name |
|---|---|
| `application-files-export` | `application-files-export` |
| `application-intake` | `application-intake` |
| `new-application-steps` | `new-application-steps` |
| `career-engine-setup` | `career-engine-setup` |
| `application-edit` | `application-edit` |
| `applications-orchestrator` | `applications-orchestrator` |

---

## Task 1: Establish canonical version and update CLAUDE.md

**Files:**
- Modify: `REPO/CLAUDE.md`
- Modify: `LIVE/CLAUDE.md`

- [ ] **Step 1: Read both CLAUDE.md files to understand current state**

```bash
cat /Users/rachel/cv-campaign-plugin/CLAUDE.md
cat "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/CLAUDE.md"
```

- [ ] **Step 2: Add canonical version declaration section to REPO/CLAUDE.md**

Insert after the `## Two-version architecture` table the following addition (replacing the existing vague "Personalized (installed)" row description):

The updated table should read:

```markdown
| Version | Location | Purpose |
|---|---|---|
| **Open-source repo** | `/Users/rachel/cv-campaign-plugin/` | Public distribution. Uses `{{USER_FIRST_NAME}}`, `{{USER_FULL_NAME}}`, `{{OUTPUT_FOLDER}}` placeholders. No personal info. |
| **Personalized (canonical)** | `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/` | Your live installation. Real names, real paths, personal background files, delivered letters archive. **This is the canonical personal version.** |
```

Also add a note below:

```markdown
> **Canonical personal version:** `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`  
> Do not maintain the cowork session copy at `~/Library/Application Support/Claude/local-agent-mode-sessions/...` — it is ephemeral and will drift. All personal edits go to the canonical path above.
```

- [ ] **Step 3: Apply same update to LIVE/CLAUDE.md**

Apply the identical change to `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/CLAUDE.md`.

---

## Task 2: Sync 02-professional-background.md to all locations

**Files:**
- Source: `COWORK/references/02-professional-background.md`
- Modify: `LIVE/references/02-professional-background.md`
- Note: `REPO/references/02-professional-background.md` contains placeholder content only — do NOT overwrite with personal data

- [ ] **Step 1: Read the authoritative source**

```bash
cat "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/references/02-professional-background.md"
```

- [ ] **Step 2: Copy verbatim to LIVE**

```bash
cp "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/references/02-professional-background.md" \
   "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/references/02-professional-background.md"
```

- [ ] **Step 3: Verify diff is zero**

```bash
diff "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/references/02-professional-background.md" \
     "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/references/02-professional-background.md"
```
Expected: no output (files identical).

---

## Task 3: Rename skill directories in REPO

**Files:**
- Rename: `REPO/skills/application-files-export/` → `REPO/skills/application-files-export/`
- Rename: `REPO/skills/application-intake/` → `REPO/skills/application-intake/`
- Rename: `REPO/skills/new-application-steps/` → `REPO/skills/new-application-steps/`
- Rename: `REPO/skills/career-engine-setup/` → `REPO/skills/career-engine-setup/`
- Rename: `REPO/skills/application-edit/` → `REPO/skills/application-edit/`
- Rename: `REPO/skills/applications-orchestrator/` → `REPO/skills/applications-orchestrator/`

- [ ] **Step 1: Rename all skill directories in REPO**

```bash
cd /Users/rachel/cv-campaign-plugin/skills
mv application-files-export application-files-export
mv application-intake application-intake
mv new-application-steps new-application-steps
mv career-engine-setup career-engine-setup
mv application-edit application-edit
mv applications-orchestrator applications-orchestrator
ls
```
Expected output: `application-edit  application-files-export  application-intake  applications-orchestrator  career-engine-setup  coach  cover-letter  cover-letter-humanizer  cv-writing  employment-coach  gatekeeper-checks  new-application-steps`

---

## Task 4: Rename skill directories in LIVE

**Files:**
- Rename: `LIVE/skills/application-files-export/` → `LIVE/skills/application-files-export/`
- Rename: `LIVE/skills/application-intake/` → `LIVE/skills/application-intake/`
- Rename: `LIVE/skills/new-application-steps/` → `LIVE/skills/new-application-steps/`
- Rename: `LIVE/skills/career-engine-setup/` → `LIVE/skills/career-engine-setup/`
- Rename: `LIVE/skills/application-edit/` → `LIVE/skills/application-edit/`
- Rename: `LIVE/skills/applications-orchestrator/` → `LIVE/skills/applications-orchestrator/`

- [ ] **Step 1: Rename all skill directories in LIVE**

```bash
LIVE="/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills"
cd "$LIVE"
mv application-files-export application-files-export
mv application-intake application-intake
mv new-application-steps new-application-steps
mv career-engine-setup career-engine-setup
mv application-edit application-edit
mv applications-orchestrator applications-orchestrator
ls
```

---

## Task 5: Update all internal references to old skill names — REPO

Everywhere a skill is referenced by old name (in agents, commands, other skills, CLAUDE.md) must be updated.

**Files:** All `*.md` files in `REPO/agents/`, `REPO/commands/`, `REPO/skills/`, `REPO/CLAUDE.md`

- [ ] **Step 1: Find all references to old skill names in REPO**

```bash
cd /Users/rachel/cv-campaign-plugin
grep -rn "application-files-export\|application-intake\|new-application-steps\|career-engine-setup\|application-edit\|applications-orchestrator" --include="*.md" .
```

- [ ] **Step 2: Replace each old name with new name in REPO**

```bash
cd /Users/rachel/cv-campaign-plugin
find . -name "*.md" | xargs sed -i '' \
  -e 's/application-files-export/application-files-export/g' \
  -e 's/application-intake/application-intake/g' \
  -e 's/new-application-steps/new-application-steps/g' \
  -e 's/career-engine-setup/career-engine-setup/g' \
  -e 's/application-edit/application-edit/g' \
  -e 's/applications-orchestrator/applications-orchestrator/g'
```

- [ ] **Step 3: Verify no old names remain in REPO**

```bash
cd /Users/rachel/cv-campaign-plugin
grep -rn "application-files-export\|application-intake\|new-application-steps\|career-engine-setup\|application-edit\|applications-orchestrator" --include="*.md" .
```
Expected: no output.

---

## Task 6: Update all internal references to old skill names — LIVE

- [ ] **Step 1: Find all references to old skill names in LIVE**

```bash
LIVE="/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine"
grep -rn "application-files-export\|application-intake\|new-application-steps\|career-engine-setup\|application-edit\|applications-orchestrator" --include="*.md" "$LIVE"
```

- [ ] **Step 2: Replace each old name with new name in LIVE**

```bash
LIVE="/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine"
find "$LIVE" -name "*.md" | xargs sed -i '' \
  -e 's/application-files-export/application-files-export/g' \
  -e 's/application-intake/application-intake/g' \
  -e 's/new-application-steps/new-application-steps/g' \
  -e 's/career-engine-setup/career-engine-setup/g' \
  -e 's/application-edit/application-edit/g' \
  -e 's/applications-orchestrator/applications-orchestrator/g'
```

- [ ] **Step 3: Verify no old names remain in LIVE**

```bash
LIVE="/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine"
grep -rn "application-files-export\|application-intake\|new-application-steps\|career-engine-setup\|application-edit\|applications-orchestrator" --include="*.md" "$LIVE"
```
Expected: no output.

---

## Task 7: Merge old.md into CLAUDE.md and delete old.md

`old.md` exists only in COWORK. Current `CLAUDE.md` in COWORK/LIVE/REPO is the single source of truth. Merge any content from `old.md` not already present in `CLAUDE.md`, then delete `old.md`.

**Files:**
- Read: `COWORK/old.md`
- Modify: `COWORK/CLAUDE.md` (merge unique content in)
- Delete: `COWORK/old.md`

- [ ] **Step 1: Read old.md in full**

```bash
cat "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/old.md"
```

- [ ] **Step 2: Diff old.md against COWORK CLAUDE.md to identify unique content**

```bash
diff "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/old.md" \
     "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/CLAUDE.md"
```

- [ ] **Step 3: Add any unique/missing content from old.md into CLAUDE.md (COWORK, REPO, LIVE)**

For each section in old.md that isn't covered in CLAUDE.md, append it to `CLAUDE.md` in all three locations. Current CLAUDE.md wins in conflict — do not overwrite existing sections.

- [ ] **Step 4: Delete old.md from COWORK**

```bash
rm "/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/old.md"
```

---

## Task 8: Remove archive command

**Files:**
- Delete: `REPO/commands/archive.md`
- Delete: `LIVE/commands/archive.md`
- Grep: remove any references to `archive` command in other files

- [ ] **Step 1: Read archive.md to confirm it's safe to delete**

```bash
cat /Users/rachel/cv-campaign-plugin/commands/archive.md
```

- [ ] **Step 2: Check for cross-references**

```bash
grep -rn "archive" /Users/rachel/cv-campaign-plugin --include="*.md" | grep -v "^/Users/rachel/cv-campaign-plugin/commands/archive.md"
grep -rn "archive" "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine" --include="*.md" | grep -v "archive.md"
```

- [ ] **Step 3: Delete archive.md from both locations**

```bash
rm /Users/rachel/cv-campaign-plugin/commands/archive.md
rm "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/commands/archive.md"
```

- [ ] **Step 4: Remove any cross-references found in step 2**

For each cross-reference found, edit the file to remove the reference.

---

## Task 9: Repackage commands as skills (best practices alignment)

According to Claude Code docs: a skill at `.claude/skills/deploy/SKILL.md` creates `/deploy` just like `.claude/commands/deploy.md`. Commands can be migrated into skills to gain subdirectory support, frontmatter control, and auto-activation.

Current commands: `career-engine.md`, `coach.md`, `setup.md` (archive deleted in Task 8).

Strategy: migrate each command into its own skill folder or merge into the closest existing skill.

- `career-engine.md` → `skills/career-engine/SKILL.md` (new skill folder — this is the main entry point)
- `coach.md` → `skills/coach/` already exists — move coach command content into `skills/coach/SKILL.md` or create a top-level `SKILL.md` there
- `setup.md` → `skills/career-engine-setup/` already exists — merge

**Files:**
- Create: `REPO/skills/career-engine/SKILL.md`
- Create: `LIVE/skills/career-engine/SKILL.md`
- Modify or create: `REPO/skills/coach/SKILL.md`
- Modify or create: `LIVE/skills/coach/SKILL.md`
- Merge into: `REPO/skills/career-engine-setup/SKILL.md`
- Merge into: `LIVE/skills/career-engine-setup/SKILL.md`
- Delete: `REPO/commands/career-engine.md`, `REPO/commands/coach.md`, `REPO/commands/setup.md`
- Delete: `LIVE/commands/career-engine.md`, `LIVE/commands/coach.md`, `LIVE/commands/setup.md`

- [ ] **Step 1: Read existing command files**

```bash
cat /Users/rachel/cv-campaign-plugin/commands/career-engine.md
cat /Users/rachel/cv-campaign-plugin/commands/coach.md
cat /Users/rachel/cv-campaign-plugin/commands/setup.md
```

- [ ] **Step 2: Read existing skill SKILL.md files (if any) to avoid losing content**

```bash
ls /Users/rachel/cv-campaign-plugin/skills/coach/
ls /Users/rachel/cv-campaign-plugin/skills/career-engine-setup/
```

- [ ] **Step 3: Create `skills/career-engine/SKILL.md` in REPO**

The content of this file should be the exact content of `commands/career-engine.md` with a frontmatter block added at the top:

```markdown
---
name: career-engine
description: Run Rachel's multi-agent CV and cover letter campaign pipeline
---

[content of commands/career-engine.md verbatim below]
```

- [ ] **Step 4: Merge `commands/coach.md` into `skills/coach/SKILL.md` in REPO**

Read `commands/coach.md`. If `skills/coach/` has a `SKILL.md`, merge the command content in (non-duplicating). If not, create `skills/coach/SKILL.md` with the command content plus frontmatter:

```markdown
---
name: coach
description: Run Rachel's employment coach in direct coaching mode
---
```

- [ ] **Step 5: Merge `commands/setup.md` into `skills/career-engine-setup/SKILL.md` in REPO**

Same pattern — read `commands/setup.md` and merge into `skills/career-engine-setup/SKILL.md`.

- [ ] **Step 6: Delete old command files in REPO**

```bash
rm /Users/rachel/cv-campaign-plugin/commands/career-engine.md
rm /Users/rachel/cv-campaign-plugin/commands/coach.md
rm /Users/rachel/cv-campaign-plugin/commands/setup.md
rmdir /Users/rachel/cv-campaign-plugin/commands 2>/dev/null || true
```

- [ ] **Step 7: Apply same changes (Steps 3–6) to LIVE**

Mirror all file creates/merges/deletes in `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`.

---

## Task 10: Verify and fix plugin.json

Per docs: add `.claude-plugin/plugin.json` to a skill folder to load it as a plugin named `<name>@skills-dir`. Check current state and fix if needed.

**Files:**
- Check/Create: `REPO/career-engine.plugin` (the top-level .plugin file — this is the packaged zip)
- Check/Create: skill-level `plugin.json` files if needed

- [ ] **Step 1: Inspect current plugin.json location**

```bash
find /Users/rachel/cv-campaign-plugin -name "plugin.json" 2>/dev/null
find "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine" -name "plugin.json" 2>/dev/null
```

- [ ] **Step 2: Read existing plugin.json**

```bash
cat <path-found-above>
```

- [ ] **Step 3: Verify plugin.json has correct name and structure**

A valid plugin.json for a skill folder should be:

```json
{
  "name": "career-engine",
  "version": "1.0.0",
  "description": "Multi-agent CV and cover letter campaign pipeline",
  "skills": "skills/",
  "agents": "agents/"
}
```

If the file is missing or incorrect, create/update it in both REPO and LIVE.

---

## Task 11: Create QA agent

Create a new agent `qa.md` that validates the entire plugin structure, file alignment, skill/command name consistency, pipeline reference integrity, and cross-version sync status.

**Files:**
- Create: `REPO/agents/qa.md`
- Create: `LIVE/agents/qa.md`
- Modify: `REPO/CLAUDE.md` (add QA agent documentation section)
- Modify: `LIVE/CLAUDE.md`

- [ ] **Step 1: Create `REPO/agents/qa.md`**

```markdown
# QA Agent — Career Engine Plugin

## Role

You are the quality assurance agent for the Career Engine plugin. You perform a pedantic, structured audit of the plugin's file system, internal consistency, and cross-version alignment. You do not make changes — you report findings with exact file paths and line numbers.

You are invoked by Claude after any significant change to the plugin. You report PASS or FAIL per check, with full details on failures. You never skip checks. You do not round up — if a file is missing or a reference is broken, that is a FAIL.

---

## When Invoked

Claude invokes you after completing any of the following:
- Adding or renaming a skill, agent, or command
- Editing any agent or skill file
- Updating references/ files
- Repackaging the .plugin files
- Any structural change to the plugin directory

---

## Inputs

The invoker must tell you:
1. Which locations to check (REPO and/or LIVE)
2. What changes were just made (if known)

If not told, check both REPO and LIVE.

---

## Check Procedure

Run ALL checks in order. Never skip. Report PASS or FAIL per check.

### Check 1 — Directory structure integrity

Verify the following directories exist in each location being checked:
- `agents/`
- `skills/`
- `references/`

For LIVE only: also verify `references/delivered-letters/` exists.
For REPO only: verify `scripts/` exists.

**FAIL condition:** any expected directory is missing.

### Check 2 — Agent files complete

For each `.md` file in `agents/`, verify:
- File is non-empty
- File contains a `## Role` section
- File contains at least one `## ` section defining procedure or steps

**FAIL condition:** any agent file is empty or missing required sections.

### Check 3 — Skill directories have a primary content file

For each subdirectory in `skills/`, verify it contains either:
- A file named `SKILL.md`, OR
- At least one `.md` file

**FAIL condition:** any skill directory is empty.

### Check 4 — No stale skill/command name references

Scan all `.md` files in `agents/`, `skills/`, `commands/` (if it still exists), `CLAUDE.md` for the following banned names:
- `application-files-export`
- `application-intake`
- `new-application-steps`
- `career-engine-setup`
- `application-edit`
- `applications-orchestrator`

**FAIL condition:** any occurrence found.

### Check 5 — Skill names referenced in agents actually exist

For each skill name referenced in any agent `.md` file (look for `Load`, `read`, skill name patterns like `cover-letter`, `applications-orchestrator`, etc.), verify the corresponding directory exists in `skills/`.

**FAIL condition:** a referenced skill name has no matching directory.

### Check 6 — References files present in LIVE

Verify the following files exist in `LIVE/references/`:
- `01-writing-rules.md`
- `02-professional-background.md`
- `03-framework.md`
- `rachel-cheyfitz.dotx`

**FAIL condition:** any file missing from LIVE references.

### Check 7 — 02-professional-background.md sync

Verify `LIVE/references/02-professional-background.md` matches the authoritative source. The authoritative source is the COWORK copy at:
`/Users/rachel/Library/Application Support/Claude/local-agent-mode-sessions/11906df4-9f28-4511-8085-4befd04174cb/2b278ad5-82b4-467a-850f-c4b08857f38c/rpm/plugin_01MMSuwGKBmo5Ycms6qVdW6N/references/02-professional-background.md`

If the COWORK copy no longer exists (session deleted), skip this check and note it.

```bash
diff "COWORK/references/02-professional-background.md" "LIVE/references/02-professional-background.md"
```

**FAIL condition:** diff is non-empty.

### Check 8 — No old.md exists anywhere

```bash
find /Users/rachel/cv-campaign-plugin -name "old.md"
find "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine" -name "old.md"
```

**FAIL condition:** `old.md` found in REPO or LIVE.

### Check 9 — archive command absent

Verify `commands/archive.md` does NOT exist in REPO or LIVE.

**FAIL condition:** `archive.md` found.

### Check 10 — CLAUDE.md canonical version declaration present

Read `CLAUDE.md` in REPO and LIVE. Verify it contains the string "canonical personal version" or "Canonical personal version".

**FAIL condition:** string not present.

### Check 11 — Pipeline skill chain integrity (REPO)

The following pipeline skill chain must exist as directories in `REPO/skills/`:
1. `application-intake`
2. `new-application-steps`
3. `application-files-export`
4. `applications-orchestrator`
5. `application-edit`
6. `career-engine-setup`
7. `coach`
8. `cover-letter`
9. `cover-letter-humanizer`
10. `cv-writing`
11. `employment-coach`
12. `gatekeeper-checks`

**FAIL condition:** any directory missing.

### Check 12 — Pipeline skill chain integrity (LIVE)

Same check as Check 11 but for LIVE. Additionally check for `pipeline-export` — if present, note it as a legacy skill to evaluate.

### Check 13 — Agent count parity

Count `.md` files in `REPO/agents/` and `LIVE/agents/`. They should be equal.

**FAIL condition:** counts differ.

### Check 14 — Skill count parity

Count subdirectories in `REPO/skills/` and `LIVE/skills/`. They should be equal (±1 allowed only if explicitly documented).

**FAIL condition:** counts differ by more than 1.

### Check 15 — plugin.json present and valid

Verify `plugin.json` exists in the expected location in both REPO and LIVE. Read and validate it contains `name` and `version` fields.

**FAIL condition:** plugin.json missing or malformed.

---

## Output Format

```
## QA Report — Career Engine Plugin
**Date:** YYYY-MM-DD
**Locations checked:** REPO, LIVE
**Changes reviewed:** [what was just changed]

### Results

| # | Check | REPO | LIVE | Notes |
|---|-------|------|------|-------|
| 1 | Directory structure | PASS | PASS | |
| 2 | Agent files complete | PASS | FAIL | agents/qa.md missing Role section |
...

### Failures Requiring Action

**Check 2 — LIVE/agents/qa.md missing ## Role section**
File: `/Users/rachel/.../agents/qa.md`
Fix: Add ## Role section as first section after title.

### Summary
X checks passed. Y checks failed. Invoke with --fix if you want me to list exact edits.
```

---

## Scope note

This agent checks structural and referential integrity. It does not evaluate content quality, writing quality, or pipeline logic correctness. As new skills and agents are added to the plugin, Checks 11–14 will naturally evolve — the agent should always look at what skills/agents actually exist and note any it cannot categorize rather than hard-failing on unknown additions.
```

- [ ] **Step 2: Copy `REPO/agents/qa.md` to `LIVE/agents/qa.md`**

(LIVE qa.md is functionally identical — no personal data involved.)

```bash
cp /Users/rachel/cv-campaign-plugin/agents/qa.md \
   "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/agents/qa.md"
```

- [ ] **Step 3: Add QA agent section to REPO/CLAUDE.md**

Append the following section to `REPO/CLAUDE.md`:

```markdown
---

## QA Agent

A QA agent (`agents/qa.md`) performs structural and consistency checks across both plugin versions after any significant change.

**When Claude invokes it:** After completing any rename, restructure, new file addition, or cross-version sync operation, Claude MUST invoke the QA agent before reporting the work complete.

**What it checks:**
- Directory structure integrity
- Agent and skill file completeness
- No stale skill name references (old cv-campaign-* names)
- Skill names referenced in agents exist on disk
- Reference files present in personal version
- 02-professional-background.md sync
- No old.md present
- No archive command present
- CLAUDE.md canonical version declaration present
- Pipeline skill chain integrity in both versions
- Agent and skill count parity between versions
- plugin.json present and valid

**To invoke:** Spawn `qa` agent with the list of locations (REPO and/or LIVE) and a brief description of what changed.
```

- [ ] **Step 4: Apply same CLAUDE.md addition to LIVE/CLAUDE.md**

---

## Task 12: Run QA agent and validate

- [ ] **Step 1: Spawn the QA agent**

Invoke `agents/qa.md` with:
- Locations: REPO (`/Users/rachel/cv-campaign-plugin/`) and LIVE (`/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`)
- Changes: "All tasks in the career-engine refactor plan (2026-06-07): skill renames, CLAUDE.md canonical declaration, 02-professional-background sync, old.md merge and deletion, archive command removal, commands-to-skills migration, plugin.json verification, qa.md creation"

- [ ] **Step 2: Review QA report**

Read the full report. For each FAIL:
- Identify the exact fix
- Apply the fix
- Re-run the specific check to confirm PASS

- [ ] **Step 3: Iterate until all checks pass**

Re-run QA agent after fixes until report shows 0 failures.

---

## Task 13: Repackage both .plugin files

- [ ] **Step 1: Repackage REPO plugin**

```bash
cd /Users/rachel/cv-campaign-plugin
python3 -c "
import zipfile, os
exclude = {'.git', '__pycache__', '.DS_Store', '.in_use', 'docs'}
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

- [ ] **Step 2: Repackage LIVE plugin (personal)**

```bash
cd "/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine"
python3 -c "
import zipfile, os
exclude = {'.git', '__pycache__', '.DS_Store', '.in_use', 'rachel-cheyfitz.dotx.bak'}
with zipfile.ZipFile(os.path.expanduser('~/Downloads/career-engine-personal.plugin'), 'w', zipfile.ZIP_STORED) as zf:
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in exclude]
        for file in files:
            if file in exclude or file.endswith('.plugin'):
                continue
            zf.write(os.path.join(root, file), os.path.join(root, file)[2:])
print('Done.')
"
```

- [ ] **Step 3: Run final QA pass**

Spawn QA agent one final time. All 15 checks must PASS.

---

## Self-Review Checklist

- [x] Task 1 covers canonical version declaration in CLAUDE.md
- [x] Task 2 syncs 02-professional-background.md from the authoritative COWORK source
- [x] Tasks 3–6 cover all 6 skill renames in both REPO and LIVE
- [x] Task 7 covers old.md merge and deletion
- [x] Task 8 covers archive command removal
- [x] Task 9 covers commands-to-skills migration for all 3 remaining commands
- [x] Task 10 covers plugin.json verification
- [x] Task 11 creates the QA agent with all 15 checks
- [x] Task 12 runs QA and iterates until clean
- [x] Task 13 repackages both .plugin files
- No placeholders or TBDs found in plan steps
- Type/name consistency verified across all tasks — new names used consistently from Task 3 onward
