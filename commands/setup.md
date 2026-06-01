---
description: "First-run setup wizard for cv-campaign. Populates your profile, configures job tracking and output paths, and generates required permissions."
argument-hint: "[--phase <1-6> | --verify]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
  - WebFetch
---

# cv-campaign Setup

Load `skills/cv-campaign-setup/SKILL.md` and follow the procedure exactly.

**Arguments:**
- No argument: run full setup, skipping phases already complete
- `--phase <n>`: run only phase N (1=identity, 2=content-submission, 3=synthesis, 4=review-interview, 5=integration, 6=permissions)
- `--verify`: run the verification step only — scan for unfilled placeholders and check dependencies

Begin with the pre-flight scan. Report which phases are complete and which are outstanding, then proceed.
