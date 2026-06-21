---
name: plugin-builder
description: >
  Working doctrine for plugin-builder sessions: where content belongs, how to
  make a clean change, how to check for regressions, how to package, and how to
  open a PR. Loaded by the plugin-builder agent at the start of every session.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
---

# Plugin Builder — Working Doctrine

This skill is the craft layer for plugin-builder sessions. The governing rules live in `CLAUDE.md` — read that first. This skill gives you the decision trees, checklists, and conventions you need to apply those rules without re-deriving them every time.

---

## The Three Questions Before Every Change

Before touching any file, answer these three questions:

1. **What content type is this?** (See content-type decision tree below.)
2. **Which file owns this content type?** (See content placement rules in CLAUDE.md.)
3. **Is it personal data?** If yes, it belongs in `career-data`, never the plugin.

If you cannot answer all three confidently, ask the user before writing.

---

## Content-Type Decision Tree

```
Is it a rule about what to write, how to write it, or a writing philosophy?
  → skill file (skills/<name>/SKILL.md)

Is it a step-by-step procedure, a routing decision, or an output format spec?
  → agent file (agents/<name>.md)

Is it the user's personal data — role facts, voice profile, sent letters, .dotx?
  → career-data skill (never the plugin)

Is it a blank template with {{...}} placeholders for the user to fill at setup?
  → references/ in the plugin

Is it a slash command that invokes a skill or agent?
  → commands/ in the plugin
```

When something could fit two categories, the tie-break is: **does it apply every time this task runs?** If yes → skill. If it varies by session input → agent.

---

## Before Writing a New Agent

A new agent needs all of the following in the same session. Do not close the session until every item is done:

- [ ] Agent file at `agents/<name>.md` with frontmatter (`name`, `description`, `tools`)
- [ ] Skill directory at `skills/<name>/SKILL.md` with frontmatter (`name`, `description`, `allowed-tools`)
- [ ] If it introduces a new pipeline: a row in the Pipeline Registry in `CLAUDE.md` and in the `career-engine` entry skill
- [ ] If it reads reference files: a loading table in the agent file pointing at the right files
- [ ] If it writes new reference files: those files added to `references/REFERENCES.md` and wired into every consuming agent
- [ ] QA run and `.plugin` rebuild

A half-wired agent is worse than no agent — it will silently fail at runtime.

---

## Before Editing an Existing Agent or Skill

**Letter pipeline files require special care.** `letter-writer.md`, `cover-letter/SKILL.md`, `gatekeeper-checks/SKILL.md`, `cover-letter-humanizer/SKILL.md`, `gatekeeper.md`, and `cover-letter-humanizer.md` require full read-before-edit and explicit rule-removal confirmation from the user before any rule is deleted or weakened.

1. Read the file you are editing in full, not just the section you intend to change.
2. Check the regression table in `CLAUDE.md` for any row that mentions this file. Read the "Confirmed fix" column — your change must not undo it.
3. If you are moving content between files (e.g., from agent to skill), confirm the move does not break any other file that references it by path or by name.
4. If you are renaming anything: update every file that references the old name, excluding QA ban lists and plan docs from find-replace (update those by hand, as noted in R-26).

---

## Regression Check Discipline

After making any change, scan the CLAUDE.md regression table for every file you touched. For each match:

- State the regression number and name
- State whether your change affects the confirmed fix
- If it does affect it, confirm the fix is still intact or explain why the change is safe

Do not write "regression checks: N/A." Every edit touches at least one file; every file has at least one regression that mentions its directory. Show your work.

---

## Packaging

After QA passes, rebuild the plugin:

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

Confirm `career-engine.plugin` was produced and its timestamp is current. Do not report the session complete until the rebuilt `.plugin` exists.

---

## PR Checklist

Any user may open a PR. Before committing:

- [ ] `git status` is clean except for the files you changed
- [ ] The `.plugin` is rebuilt and included in the commit
- [ ] No personal data is in the diff (`grep -r "@" --include="*.md"` and scan for emails, real company names from the user's history, real file paths)
- [ ] The commit message follows the pattern: `<verb> <what>: <one-line why>` — e.g., `Add plugin-builder agent and skill: self-service plugin editing workflow`
- [ ] QA passed

PR body should include:
- What changed (one bullet per file or logical group)
- Why (the user request or regression being fixed)
- QA result (PASS or the check number that failed and was addressed)

To open the PR:

```bash
git add <files>
git commit -m "your message"
git push -u origin <branch>
gh pr create --title "..." --body "..."
```

If working on `main` directly (no feature branch), confirm with the user before pushing.

---

## Common Mistakes to Avoid

**Writing doctrine in agent files.** If you find yourself writing "how to write a strong opener" or "the voice rule for X" in an agent, stop — that belongs in the skill.

**Writing personal data in the plugin.** Real company names, the user's email, actual file paths, real `.dotx` filenames — none of these belong in any plugin file. Use `{{...}}` placeholders.

**Forgetting to wire a new file.** A new reference file that no agent loads is invisible. A new agent that no command or entry skill invokes is unreachable. Wire everything in the same session.

**Skipping the QA gate.** The mandatory stop in `CLAUDE.md` is not optional. Even a one-line change requires a QA run. The QA agent catches drift that looks fine locally.

**Running find-replace on ban lists.** When renaming a file or agent, exclude QA ban lists and the CLAUDE.md regression table from find-replace. Those files enumerate old names intentionally (to catch them) — overwriting them defeats the check.
