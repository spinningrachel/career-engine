# Generalize Setup Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `skills/career-engine-setup/SKILL.md` so any job seeker — regardless of country, language, or whether they need localization — can complete onboarding successfully without hitting Rachel-specific assumptions.

**Architecture:** All changes are confined to one file in the open-source repo (`skills/career-engine-setup/SKILL.md`), then synced to the installed version. Four discrete patches: (1) language configuration rewrite, (2) Languages column validation fix, (3) Notion template guidance clarification, (4) remote-compatibility phase framing. The reference files (`remote-compatibility-rules.md`, `localization.md`, `references/REFERENCES.md`) are already well-generalized with `{{USER_COUNTRY}}` and `{{USER_SECOND_LANGUAGE}}` placeholders — they do not need changes. QA agent must pass before declaring done.

**Tech Stack:** Markdown file edits only. No code. Both plugin versions must be updated (open-source repo + installed canonical).

---

## File Map

| Action | File |
|---|---|
| Modify | `cv-campaign-plugin/skills/career-engine-setup/SKILL.md` — all four patches |
| Sync | `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/career-engine-setup/SKILL.md` — same changes, personal version |
| Read to verify | `cv-campaign-plugin/references/remote-compatibility-rules.md` — confirm no changes needed |
| Read to verify | `cv-campaign-plugin/agents/localization.md` (or skills path) — confirm no changes needed |

---

## Task 1: Rewrite Language Configuration (Phase 1)

**Files:**
- Modify: `cv-campaign-plugin/skills/career-engine-setup/SKILL.md` (lines ~87–113, the `### Language configuration` section)

The current section names Hebrew explicitly in options (b) and (c), and the RTL warning is Hebrew-only. Any user whose second language is Hebrew gets the right experience; everyone else gets confused options that don't apply to them.

- [ ] **Step 1: Locate the section**

Open `cv-campaign-plugin/skills/career-engine-setup/SKILL.md`. Find `### Language configuration` (around line 86). The section ends at `Confirm: "Done. Let's move to your career materials."` (around line 114).

- [ ] **Step 2: Replace the language options block**

Replace the current ask block:

```
Ask:

> "What language(s) do your applications need to be in?
> (a) English only
> (b) Hebrew + English — bilingual; English is your default
> (c) Hebrew only — Hebrew is your default
> (d) Other — specify your default language and second language (or 'none' if single-language)"

Then ask: "What is your **default** language — the language you write in naturally and that the pipeline should produce first?"
```

With this generalized version:

```
Ask:

> "What language(s) do your applications need to be in?
> (a) One language only — all applications in the same language
> (b) Two languages — some roles may need outputs in a second language (e.g., bilingual markets, international applications)
>
> If (a): what is your primary application language? (e.g., English, French, German, Spanish — or whatever you write in naturally)
> If (b): what is your primary language, and what is your second language?"
```

- [ ] **Step 3: Replace the RTL warning**

Find the current RTL warning:

```
3. **If Hebrew is one of their languages:**
   > ⚠️ **RTL template required.** Hebrew text in a left-to-right Word template will render incorrectly — characters appear in the wrong order and alignment breaks. You will need a separate `.dotx` template configured for right-to-left layout before running the pipeline for Hebrew-output roles. See `skills/application-files-export/SKILL.md` for template setup instructions.
```

Replace with:

```
3. **If either language is right-to-left (RTL)** — this includes Hebrew, Arabic, Persian/Farsi, Urdu, and others:
   > ⚠️ **RTL template required.** RTL text in a left-to-right Word template will render incorrectly — characters appear in the wrong order and alignment breaks. You will need a separate `.dotx` template configured for right-to-left layout before running the pipeline for RTL-language roles. See `skills/application-files-export/SKILL.md` for template setup instructions.
```

- [ ] **Step 4: Remove the "If default language is not English" instruction**

Find and remove:

```
5. **If default language is not English:** update `skills/localization/SKILL.md` per the setup instruction at the bottom of its Opening section — rewrite the Default Language column to reflect the user's default language. See that skill for the exact algorithm.
```

Replace with a generalized version that always applies:

```
5. **If the user has a second language:** update `skills/localization/SKILL.md` per the setup instruction at the bottom of its Opening section — confirm the Default Language and Second Language columns reflect the user's configured languages. See that skill for the exact algorithm.
```

- [ ] **Step 5: Verify the section reads end-to-end**

Read the full `### Language configuration` section and confirm:
- No mention of Hebrew in the options or prompts
- RTL warning covers Hebrew, Arabic, Persian, and other RTL scripts
- The `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` placeholder substitution steps are unchanged
- The database reminder uses `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` (already correct — no change needed there)

---

## Task 2: Fix Languages Column Validation in Phase 5

**Files:**
- Modify: `cv-campaign-plugin/skills/career-engine-setup/SKILL.md` (lines ~340–380, inside Phase 5 Google Sheets and Other platform sections)

The Languages column validation currently hard-codes "English, Hebrew" in two places — the Google Sheets validation prompt and the Other platform prompt. A user who configured French + German would produce a setup with wrong dropdown values.

- [ ] **Step 1: Fix the Google Sheets validation prompt**

Find:

```
- Column "Languages": allow multiple selections from: English, Hebrew
```

Replace with:

```
- Column "Languages": allow multiple selections from: {{USER_DEFAULT_LANGUAGE}}, {{USER_SECOND_LANGUAGE}}
  (If single-language, allow only: {{USER_DEFAULT_LANGUAGE}})
```

Add a note before this validation prompt block (immediately before the code block that starts with `Set up data validation...`):

```
Before giving this prompt to the user, substitute `{{USER_DEFAULT_LANGUAGE}}` and `{{USER_SECOND_LANGUAGE}}` with the actual values configured in Phase 1. If the user is single-language, omit `{{USER_SECOND_LANGUAGE}}` from the Languages row entirely.
```

- [ ] **Step 2: Fix the Other platform prompt**

Find:

```
- Languages (multi-select): English | Hebrew
```

Replace with:

```
- Languages (multi-select): {{USER_DEFAULT_LANGUAGE}} | {{USER_SECOND_LANGUAGE}}
  (If single-language, only: {{USER_DEFAULT_LANGUAGE}})
```

- [ ] **Step 3: Verify**

Read both the Google Sheets section and the Other platform section end-to-end. Confirm "English, Hebrew" does not appear anywhere in the Languages validation rows.

---

## Task 3: Clarify the Notion Template Link

**Files:**
- Modify: `cv-campaign-plugin/skills/career-engine-setup/SKILL.md` (lines ~308–318, inside Phase 5 Option A — Notion)

The current instruction says to use the template at `certain-espadrille-82d.notion.site`. This is Rachel's public Notion share link. For public distribution, the setup skill should: (a) acknowledge this is a shared template others can duplicate, and (b) provide fallback instructions for creating the database manually in case the link ever goes stale.

- [ ] **Step 1: Add a fallback block after the template link**

Find the current step 1 in Option A — Notion:

```
1. Say: "Use this template — it has all the required columns and select values pre-configured:
   **[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**
   Click Duplicate, add it to your workspace, then come back."
```

Replace with:

```
1. Say: "Use this template — it has all the required columns and select values pre-configured:
   **[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**
   Click Duplicate, add it to your workspace, then come back.
   
   *If the template link is unavailable:* Create a new full-page database in Notion manually. Use the column schema from the Google Sheets fallback below — same column names, same select values. Do not rename any columns."
```

- [ ] **Step 2: Verify**

Read the full Option A — Notion section. Confirm the fallback instruction is present and references the Google Sheets column schema for manual setup.

---

## Task 4: Improve Remote-Compatibility Phase Framing

**Files:**
- Modify: `cv-campaign-plugin/skills/career-engine-setup/SKILL.md` (lines ~468–505, Phase 7)

Phase 7 is already reasonably generic — it uses `{{USER_COUNTRY}}` placeholders in the rules file. The gap is that the setup skill doesn't frame this phase clearly enough: users who are applying only domestically don't need it at all, and the current framing doesn't say that upfront.

- [ ] **Step 1: Add a skip condition at the top of Phase 7**

Find the opening of Phase 7:

```
## Phase 7 — Remote-compatibility configuration

**Purpose:** The pipeline produces CVs and cover letters. By default, it writes content in the first person and uses phrasing calibrated for direct applications. Some users submit through recruiters, apply to roles where the CV is read without the candidate present, or operate in contexts (international applications, platform submissions, agency placements) where different conventions apply. This phase asks whether remote-compatibility rules are needed and, if so, whether the defaults are appropriate.

Ask: "Does your job search involve any of the following? (You can select more than one, or say none):
1. Applications submitted through a recruiter or agency (you won't see the JD before they do)
2. Roles in a country or market where you're based remotely
3. Platform submissions (LinkedIn Easy Apply, Workday, Greenhouse) where formatting and length rules differ
4. Applications in a language other than your primary language

If none of these apply, skip this phase."
```

Replace with:

```
## Phase 7 — Remote-compatibility configuration

**Purpose:** Some job searches involve geographic friction — applying internationally, working through recruiters, or submitting through platforms with strict formatting rules. This phase configures rules to handle those situations correctly. **Skip this phase entirely if the user is applying only to roles in the country they live in, in one language, submitted directly by themselves.**

Ask: "Does your job search involve any of the following? Say 'none' to skip this phase entirely.
1. Applications submitted through a recruiter or agency (you won't see the JD before they do)
2. Applying to roles in a country or market different from where you're based
3. Platform submissions (LinkedIn Easy Apply, Workday, Greenhouse) where formatting and length rules differ from a direct application
4. Applications in a language other than your primary language

If none of these apply, say 'none' and I'll skip to verification."
```

- [ ] **Step 2: Verify the skip path works**

Read the full Phase 7 section. Confirm:
- The skip-if-domestic instruction is present at the top
- The "If none apply" path clearly skips to Phase 7's confirm line
- No Israeli-specific wording appears anywhere in Phase 7

---

## Task 5: Sync Changes to Installed Version

**Files:**
- Modify: `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/career-engine-setup/SKILL.md`

- [ ] **Step 1: Apply all four patches to the installed version**

Apply exactly the same changes from Tasks 1–4 to the installed canonical version. The installed version may have personal content in other sections — do not touch those. Only apply the four patches.

- [ ] **Step 2: Verify no personal content was overwritten**

Confirm that the installed version's personal sections (any real names, real paths, personal candidate rules if any) are intact after the sync.

---

## Task 6: Run QA Agent

**Files:**
- Read: `cv-campaign-plugin/agents/qa-plugin.md`

- [ ] **Step 1: Invoke the QA agent**

Read `agents/qa-plugin.md` and follow its instructions. Pass it both plugin paths:
- Open-source: `/Users/rachel/cv-campaign-plugin/`
- Installed: `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`

- [ ] **Step 2: Resolve any findings**

If the QA agent returns FAIL, fix the reported violations before declaring done. Re-run until PASS.

- [ ] **Step 3: Repackage both .plugin files**

Run the packaging commands from `CLAUDE.md` to rebuild both `.plugin` archives after the changes.

---

## Self-Review

**Spec coverage:**
- Language configuration generalized ✓ (Task 1)
- RTL warning generalized ✓ (Task 1)
- Languages column validation fixed ✓ (Task 2)
- Notion template fallback added ✓ (Task 3)
- Remote-compatibility phase framing improved ✓ (Task 4)
- Both versions synced ✓ (Task 5)
- QA gate ✓ (Task 6)

**Placeholder scan:** No TBDs, no "implement later", no "similar to Task N". Every step contains the exact old text to find and the exact new text to write.

**Out of scope confirmed not changed:**
- `remote-compatibility-rules.md` — already uses `{{USER_COUNTRY}}` throughout; no changes needed
- `agents/localization.md` — already uses `{{USER_DEFAULT_LANGUAGE}}` / `{{USER_SECOND_LANGUAGE}}`; no changes needed
- `references/he-terminology-guide.md` — Hebrew-specific reference file; appropriate for users who configure Hebrew; stays as-is
- All other pipeline agents and skills — untouched
