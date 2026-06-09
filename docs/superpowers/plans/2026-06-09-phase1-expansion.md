# Phase 1 Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand the career-engine plugin with five new capabilities: LinkedIn MCP connector + coach research upgrade, job search skill, strategic company analysis in coach, personal brand skill, and LinkedIn coach skill.

**Architecture:** All changes follow the existing plugin architecture (agents = orchestration, skills = doctrine, references = source material). Three new skills are created (`job-search`, `personal-brand`, `linkedin-coach`). The employment-coach agent and skill are modified to incorporate LinkedIn MCP research and nates-substack strategic analysis methodology. Every change goes to both plugin versions. QA agent must pass before declaring done.

**Tech Stack:** Markdown file edits only. No code. Both plugin versions must be updated in sync.

---

## File Map

| Action | File |
|---|---|
| Modify | `cv-campaign-plugin/CONNECTORS.md` |
| Modify | `cv-campaign-plugin/agents/employment-coach.md` |
| Modify | `cv-campaign-plugin/skills/employment-coach/SKILL.md` |
| Create | `cv-campaign-plugin/skills/job-search/SKILL.md` |
| Create | `cv-campaign-plugin/skills/personal-brand/SKILL.md` |
| Create | `cv-campaign-plugin/skills/linkedin-coach/SKILL.md` |
| Sync all | `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/` — same changes |

---

## Task 1: LinkedIn MCP Connector + Employment Coach Research Upgrade

**Purpose:** Wire in the stickerdaniel LinkedIn MCP as an optional connector. Update the employment-coach agent tools list and research skill to use LinkedIn MCP tools for company profiles, hiring manager research, and team mapping. Also absorb the nates-substack strategic analysis methodology (red/green flag detection, GTM framing, weighted prioritization) into the research phase and strategy output.

**Files:**
- Modify: `cv-campaign-plugin/CONNECTORS.md`
- Modify: `cv-campaign-plugin/agents/employment-coach.md`
- Modify: `cv-campaign-plugin/skills/employment-coach/SKILL.md`
- Sync all three to: `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`

---

### Step 1.1: Add LinkedIn MCP to CONNECTORS.md

Read `cv-campaign-plugin/CONNECTORS.md`. Find the connectors table. Add a new row for LinkedIn after the existing rows:

```
| LinkedIn research | stickerdaniel/linkedin-mcp-server | No (user-installed) | — |
```

Also add a new section after the table:

```markdown
### LinkedIn MCP (stickerdaniel/linkedin-mcp-server) — Optional

When configured, the employment-coach agent uses this MCP for company and hiring manager research. Install it separately — it is not bundled with the plugin.

**Install:**
```bash
uvx linkedin-scraper-mcp@latest --login
```

**Configure in Claude Code settings** with server name `linkedin-mcp`. The employment coach will then have access to:
- `mcp__linkedin-mcp__get_company_profile` — company about page, posts, jobs
- `mcp__linkedin-mcp__get_company_employees` — employee demographics and profiles
- `mcp__linkedin-mcp__get_person_profile` — individual profile with experience, education
- `mcp__linkedin-mcp__search_people` — search by keywords, company, connection degree

The coach falls back to WebSearch if this MCP is not connected.
```

- [ ] Apply this change to open-source CONNECTORS.md
- [ ] Apply this change to installed canonical CONNECTORS.md

---

### Step 1.2: Add LinkedIn MCP tools to employment-coach agent

Read `cv-campaign-plugin/agents/employment-coach.md`. Find the frontmatter `tools:` line:

```
tools: Read, Glob, Grep, WebSearch, WebFetch, mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-update-page
```

Replace with:

```
tools: Read, Glob, Grep, WebSearch, WebFetch, mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-update-page, mcp__linkedin-mcp__get_company_profile, mcp__linkedin-mcp__get_company_employees, mcp__linkedin-mcp__get_person_profile, mcp__linkedin-mcp__search_people
```

Note: the open-source version uses the same tools line (no personal substitution needed here — the Notion MCP ID is a generic UUID, not personal data).

- [ ] Apply to open-source agents/employment-coach.md
- [ ] Apply to installed canonical agents/employment-coach.md

---

### Step 1.3: Add LinkedIn MCP research protocol to employment-coach skill

Read `cv-campaign-plugin/skills/employment-coach/SKILL.md`. 

**Part A — Add LinkedIn research sub-steps to Research Phase**

Find the section header `### Six research dimensions`. After it, find the sub-heading `**7. Company and org dynamics**`. That section currently starts with:

```
**7. Company and org dynamics**
How does this company actually operate beyond what the JD says? **Start by reading the About Us / Team page** — this is mandatory, not a fallback.
```

Replace the opening two sentences of dimension 7 with:

```
**7. Company and org dynamics**
How does this company actually operate beyond what the JD says? **Start with the LinkedIn company profile** — `get_company_profile(company_name, sections="posts,jobs")` if the LinkedIn MCP is connected; otherwise start with the About Us / Team page on the company website (this is mandatory, not a fallback).
```

**Part B — Add LinkedIn hiring manager research after dimension 8**

Find `**8. Recruitment criteria**` and its current content ending with `Aim for 2–3 specific criteria beyond what the JD states explicitly.`

After that section, insert a new research dimension:

```markdown
**10. Hiring manager and team research (LinkedIn MCP)**

Only run this step if the LinkedIn MCP is connected. If it is not, skip and note: "LinkedIn MCP not connected — HM research skipped."

1. Identify the hiring manager: check the JD for a named contact, the company's LinkedIn Jobs page via `get_company_profile(company_name, sections="jobs")`, or the company About/Team page.
2. If a hiring manager is found, run `get_person_profile(linkedin_username, sections="experience,education,posts")`. Extract: current title, tenure at this company, background before this company, any recent posts about hiring priorities or team direction.
3. Run `get_company_employees(company_name, keywords="marketing")` (substituting the relevant function keyword for the role). Skim the demographics — team size, seniority distribution, recent hires.
4. Produce a 3–5 line Hiring Manager & Team snapshot. Include: HM background relevance, tenure signal (new HM = flux; long-tenure = established culture), any public statements about what they value, team composition signal.
5. This snapshot feeds directly into the Strategy output and the `Strategy` Notion property.
```

**Part C — Add red/green flag analysis to Research Phase**

Find the `### Post-research self-check` heading. Insert a new section BEFORE it:

```markdown
### JD Signal Analysis (Red and Green Flags)

After completing all research dimensions, analyse the JD text itself for non-obvious signals. This is separate from fit/gap analysis — it assesses the quality and health of the opportunity itself.

**Red flag patterns (language signals):**
- "Wear many hats", "rockstar", "ninja", "self-starter in a fast-paced environment", "work hard play hard" — indicators of unclear scope or burn-out culture
- "Results-driven" with no metrics anywhere in the JD — performance expectations undefined
- Constant hiring for the same role type — check LinkedIn Jobs; if the same role appeared 3+ times in 12 months, flag it
- No salary range (in jurisdictions where this is now common) — negotiating leverage gap
- Vague responsibilities with over-complicated requirements — misaligned expectation of candidate vs. actual budget
- "Family-like atmosphere", "we move fast and break things" — culture warning labels

**Green flag patterns:**
- Essential vs. preferred requirements clearly distinguished
- Specific measurable goals in the JD ("build X, achieve Y in first 90 days")
- Transparent hiring process described (number of stages, timeline)
- Long-tenured employees visible on LinkedIn (check via `get_company_employees`)
- Hiring manager has been in role 2+ years (stability signal)
- Company blog or HM posts show substantive thinking about the domain, not just generic content

**Output:** Include a "Signals" block in the research output:

```
**Signals:**
- Red: [list any, or "None identified"]
- Green: [list any, or "None identified"]
- Net: [Proceed with caution | Neutral | Positive signals]
```

This feeds into the Priority scoring and Strategy output.

---
```

**Part D — Add GTM framing and weighted prioritization to Strategy output**

Find the section in the skill that describes the four Notion properties (`Role emphasis`, `JD proof`, `Keywords`, `Strategy`). This is typically in the section that begins with strategic property definitions.

Find the `Strategy` property definition. It currently describes what the strategy should contain. Add the following after the existing Strategy definition:

```markdown
**Strategic framing — GTM lens:**

The best strategies treat the application as a go-to-market problem: {{USER_FIRST_NAME}} is the product, the hiring manager is the buyer, the JD is the RFP. Frame the strategy around three questions:

1. **Why you** — what unique proof makes {{USER_FIRST_NAME}} the credible choice? (Not a list of skills — a specific, traceable result.)
2. **Why them** — what specifically about this company, this stage, this team makes this the right move? Flattery is not an answer. Business logic is.
3. **Why now** — what makes this the right moment for both parties?

These questions anchor the opening of the cover letter and the interview narrative. The cv-writer and letter-writer should receive the answers as strategic inputs, not generic positioning.

**Weighted prioritization model:**

When scoring priority across multiple roles, weight: Company culture and stage fit (40%) + {{USER_FIRST_NAME}}'s documented credential match (40%) + role level and growth trajectory (20%). A role that scores high on culture + credentials but offers a lateral move ranks above a role with a step up but culture misalignment or credential stretch.
```

- [ ] Apply all four sub-steps to open-source skills/employment-coach/SKILL.md
- [ ] Apply all four sub-steps to installed canonical skills/employment-coach/SKILL.md (substituting `{{USER_FIRST_NAME}}` with real name in the installed version — but the GTM questions use the placeholder format throughout, so no substitution is needed if the installed version already has the real name used elsewhere)

---

## Task 2: Job Search Skill

**Purpose:** Create a new standalone job search skill that searches LinkedIn (via LinkedIn MCP), Hacker News, and optionally other sources. Adapted from neonwatty's multi-source approach but using the LinkedIn MCP instead of browser automation, and dropping Twitter/X.

**Files:**
- Create: `cv-campaign-plugin/skills/job-search/SKILL.md`
- Create: `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/job-search/SKILL.md`

---

### Step 2.1: Create the job-search skill

Create `cv-campaign-plugin/skills/job-search/SKILL.md` with this exact content:

```markdown
---
name: job-search
description: Search for jobs across LinkedIn (via LinkedIn MCP) and Hacker News Who's Hiring. Scores and ranks results against saved preferences. Use when the user wants to find jobs, search for positions, or explore open roles. Requires the LinkedIn MCP (stickerdaniel/linkedin-mcp-server) for LinkedIn results.
allowed-tools: Read, Write, Bash, WebSearch, WebFetch, mcp__linkedin-mcp__search_jobs, mcp__linkedin-mcp__get_job_details, mcp__linkedin-mcp__get_company_profile, mcp__linkedin-mcp__search_people
---

# Job Search

Multi-source job search across LinkedIn and Hacker News Who's Hiring. Scores results against your saved preferences, surfaces network and hiring manager signals, and saves structured output.

---

## Phase 1 — Load Preferences

Read `~/.career-engine-job-prefs.json`. Check for a `preferences` key.

**If no preferences found**, say:

> No search preferences saved. Let me set them up now — this takes about 2 minutes and you only do it once.

Then run the preference Q&A below. **Do not continue without preferences.**

**Preference Q&A:**

Ask the following in sequence. Collect all answers before saving.

1. **Target titles** — "What job titles are you targeting? List them all." (Free-form — accept a list, not a multiple choice.)
2. **Minimum salary** — "What's your minimum acceptable base salary? (e.g., $150K, €80K — or 'no minimum')"
3. **Remote preference** — "Remote only, hybrid, or open to all?"
4. **Exclude patterns** — "Any words that should automatically exclude a role? (e.g., 'junior', 'intern', 'contract' — or 'none')"
5. **Default time range** — "How far back should searches look by default? (last week / 2 weeks / month)"
6. **Primary location** — "What location should be used for LinkedIn searches? (city and country, e.g., 'Tel Aviv, Israel' or 'London, UK')"

Save to `~/.career-engine-job-prefs.json`:

```json
{
  "preferences": {
    "targetTitles": ["Title 1", "Title 2"],
    "minSalary": "$150K",
    "remotePreference": "remote only",
    "excludePatterns": ["junior", "intern"],
    "defaultTimeRange": "last week",
    "location": "Tel Aviv, Israel"
  }
}
```

Confirm: "Preferences saved. Starting search now."

---

## Phase 2 — Parse Overrides

The user may pass arguments when invoking:
- Time range override: `last week`, `2 weeks`, `month`
- Source filter: `linkedin`, `hn` (default: both)
- Extra keywords: any additional words to include alongside target titles

Display the active search config before proceeding:

> **Searching with:**
> - Titles: [list]
> - Salary floor: [value]
> - Remote: [value]
> - Time range: [value]
> - Sources: [LinkedIn / HN / both]

---

## Phase 3a — LinkedIn Search (LinkedIn MCP)

**Gate:** If the LinkedIn MCP is not connected (tools named `mcp__linkedin-mcp__search_jobs` are unavailable), skip this phase entirely and report: "LinkedIn MCP not connected — skipping LinkedIn search. Connect stickerdaniel/linkedin-mcp-server to enable this source."

**For each target title, run:**

```
search_jobs(
  keywords = "[title]",
  location = preferences.location,
  max_pages = 3,
  date_posted = [map time range: "last week" → "past_week", "2 weeks" → "past_month", "month" → "past_month"],
  work_type = [map remotePreference: "remote only" → "remote", "hybrid" → "hybrid", "open to all" → null],
  sort_by = "date"
)
```

Collect all `job_ids` from results. Deduplicate across title searches.

**For each job_id (up to 30 total):**

Run `get_job_details(job_id)`. Extract:
- Title, company, location, work type
- Posted date (derive approximate days-ago from "X days ago" text)
- Applicant count if present
- Hiring manager name and URL if present in references
- Easy Apply flag if mentioned

**Exclude any result** where the title text matches any `excludePatterns` (case-insensitive substring match).

---

## Phase 3b — Hacker News Who's Hiring (WebSearch + WebFetch)

1. Use `WebSearch` to find: `"Ask HN: Who is hiring?" site:news.ycombinator.com [current month] [current year]`
2. Extract the thread ID from the result URL (format: `https://news.ycombinator.com/item?id=XXXXXXXX`)
3. Fetch the thread data: `WebFetch("https://hacker-news.firebaseio.com/v0/item/{THREAD_ID}.json")`
4. Parse the `kids` array (up to first 100 comment IDs)
5. For each comment ID, fetch: `WebFetch("https://hacker-news.firebaseio.com/v0/item/{COMMENT_ID}.json")`
   - **Delay:** pause 0.5 seconds between API calls (use Bash `sleep 0.5`)
6. Parse each comment's `text` field. HN postings typically follow: `Company | Role | Location | Remote | Salary`
7. Extract: company, title, location, remote status, salary (if present), apply URL

**Filter against preferences:**
- Title must fuzzy-match at least one `targetTitles` entry (partial match acceptable)
- Exclude if text contains any `excludePatterns`
- Exclude if "remote only" preference and posting does not mention "remote"
- Skip if salary is listed and is below `minSalary`

---

## Phase 4 — Scoring

Score every result (LinkedIn and HN) on a 0–100 scale.

### Scoring rubric

| Signal | Points | Notes |
|---|---|---|
| Title — exact match | 20 | Case-insensitive exact match to a target title |
| Title — partial match | 12 | Substring match |
| Salary meets/exceeds floor | 10 | Only when salary is listed |
| Remote match | 10 | Matches `remotePreference` exactly |
| Recency — posted ≤3 days ago | 5 | |
| Recency — posted 4–7 days ago | 3 | |
| Low competition — <50 applicants | 5 | LinkedIn only |
| Hiring manager identified | 20 | LinkedIn only — name present in job details |
| Easy Apply | 5 | LinkedIn only |
| Salary explicitly listed (HN) | 10 | HN only |
| Apply URL present (HN) | 10 | HN only |

**Max possible:** LinkedIn 75, HN 60. Normalize all to 0–100:
- LinkedIn: `score / 75 × 100`
- HN: `score / 60 × 100`

Round to nearest integer. Sort descending.

---

## Phase 5 — Output

### Terminal display

```
=================================================================
  Job Search Results
=================================================================
  Titles: [list]  |  Sources: LinkedIn ([N]), HN ([N])
  Filters: [remote] | [time range] | Salary >= [floor]
  Total: [N] results
=================================================================

Score | Source   | Title                     | Company       | Location       | Notes
----- | -------- | ------------------------- | ------------- | -------------- | -----
  94  | LinkedIn | Senior Product Manager    | Acme Corp     | Remote         | HM identified, Easy Apply
  81  | HN       | Product Manager (Senior)  | CoolStartup   | Remote ($180K) | Salary listed, Apply URL
  ...

=================================================================
  [N] with hiring managers  |  [N] with salary listed
=================================================================
```

### Save to file

Save full results to `{{OUTPUT_FOLDER}}/job-searches/search-[YYYY-MM-DD].md`:

```markdown
# Job Search — [date]

## Parameters
- Titles: [list]
- Salary floor: [value]
- Remote: [value]
- Time range: [value]

## Results (ranked)

### 1. [Title] — [Company] (Score: [N])
- **Source:** LinkedIn | HN
- **Location:** [value]
- **Salary:** [value or "not listed"]
- **Posted:** [value]
- **Hiring Manager:** [name and LinkedIn URL, or "not identified"]
- **Apply:** [URL or "Easy Apply" or "see HN thread"]
- **Applicants:** [N or "not shown"]

...
```

Create the `{{OUTPUT_FOLDER}}/job-searches/` directory if it doesn't exist.

### High-score prompt

If any results scored 75+, ask:

> **[N] jobs scored 75+. Add them to your intake queue?** (yes / no)

If yes: prompt the user to add the role URLs to the intake flow via `/career-engine:intake`.

**Never add to the Notion database directly** — that is the intake skill's job.

---

## Usage Examples

```
/career-engine:job-search
→ loads preferences, searches both sources, displays results

/career-engine:job-search 2 weeks
→ uses 2-week time range instead of default

/career-engine:job-search hn
→ searches Hacker News only

/career-engine:job-search linkedin
→ searches LinkedIn only (requires LinkedIn MCP)
```

---

## Safety Rules

1. Never enter credentials in any form
2. Never click Apply — this skill searches only
3. Max 30 LinkedIn job_ids, 100 HN comments per run
4. Delay 0.5 seconds between HN Firebase API calls
5. Never write to the Notion database directly
6. If a source fails, skip it and continue — report which sources succeeded
```

- [ ] Write open-source version to `cv-campaign-plugin/skills/job-search/SKILL.md`

---

### Step 2.2: Sync job-search skill to installed version

Copy the same file to the installed version. The only difference: replace `{{OUTPUT_FOLDER}}` with the real output folder path.

In the installed version, `{{OUTPUT_FOLDER}}` should be replaced with the real path (read `references/02-professional-background.md` or `CONNECTORS.md` in the installed version to find the configured output path — look for the path set during setup). If not found, leave the placeholder and add a comment: `# TODO: replace {{OUTPUT_FOLDER}} with your configured output path`.

- [ ] Write installed canonical version to `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/job-search/SKILL.md`

---

## Task 3: Personal Brand Skill

**Purpose:** Create a new standalone personal brand skill adapted from career-helper's Why You, Why Them, Why Now framework. Five capabilities: Brand Foundation, Audience Map, Content Pillars, Bio Library, Brand Refresh. Generic (not UK-specific, not Prosper AI-specific).

**Files:**
- Create: `cv-campaign-plugin/skills/personal-brand/SKILL.md`
- Create: `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/personal-brand/SKILL.md`

---

### Step 3.1: Create the personal-brand skill

Create `cv-campaign-plugin/skills/personal-brand/SKILL.md` with this exact content:

```markdown
---
name: personal-brand
description: Build or refresh a personal brand for {{USER_FIRST_NAME}}. Uses the Why You, Why Them, Why Now framework to produce a positioning statement, audience and channel map, content pillars with cadence, and a library of bios for different contexts. Use when the user asks to build their personal brand, find their niche, position themselves, work on their online presence, refresh their bio, or think about thought leadership.
---

# Personal Brand Helper

Strategic positioning for your online presence, built around three questions: **Why You, Why Them, and Why Now.**

## Capabilities

| # | Capability | When to Use |
|:--|:-----------|:------------|
| A | Brand Foundation | You need a clear positioning statement before anything else |
| B | Audience and Channel Map | You know roughly what you stand for but not who for or where to show up |
| C | Content Pillars and Cadence | You have positioning and need a sustainable content plan |
| D | Bio Library | You need bios that read consistently across LinkedIn, speaker decks, podcast guesting, and your own site |
| E | Brand Refresh | You have an existing presence that has drifted from where you want to be |

---

## A. Brand Foundation

**What you need:** rough sense of expertise, target audience, and why you're investing in this now.

Walk through Why You, Why Them, and Why Now in three conversational blocks. Synthesise into:

- A one-paragraph positioning statement (4–6 sentences)
- A one-line elevator version
- Three-word brand summary: proof + point of view + audience
- The "permission slip" — the specific experience that earns the right to speak on this topic

**Questions to ask:**

**Why You:**
1. What is the one thing you are genuinely better at than most people in your field? (Not a skill — a perspective or approach.)
2. What experience have you had that others haven't, that changes how you see this domain?
3. What results have you produced that are traceable, specific, and verifiable?

**Why Them:**
4. Who is the specific person you are trying to reach? (Job title, stage of career or company, the problem they're sitting with right now.)
5. What does that person believe that is wrong, or what do they wish someone would say plainly?
6. What do they read, attend, watch, or follow?

**Why Now:**
7. What has changed in the world, the market, or the profession that makes your perspective more relevant now than 2 years ago?
8. Why are you building this now — what's the personal motivation?

**Synthesis:**

From the answers, produce:

```
## Positioning Statement

[One paragraph — 4–6 sentences. Opens with the specific result or experience that earns credibility. Names the audience explicitly. States the point of view plainly. Closes with why now.]

## Elevator Version

[One sentence. Format: "I help [specific audience] [achieve specific outcome] through [distinctive approach]."]

## Three-Word Summary

[Proof word] + [POV word] + [Audience word]
Example: "Evidence-based AI positioning for product leaders"

## Permission Slip

[One or two sentences. The specific experience — named company, named outcome, named role — that gives the right to speak on this.]
```

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/brand-foundation.md` (or `applications/[role-slug]/brand-foundation.md` if tied to a specific role).

**Content integrity rules:**
- Never invent metrics, titles, employers, awards, or publications. Use `{{PLACEHOLDER}}` when a fact has not been confirmed.
- If the positioning rests on a claim the user hasn't yet verified, mark it: `[UNVERIFIED — confirm before publishing]`
- If the user says "I want to be known for X" but their documented experience doesn't yet support X, say so directly and offer two options: (1) build the proof first (6–12 month plan), or (2) pick adjacent positioning that matches current proof.

---

## B. Audience and Channel Map

**What you need:** a positioning statement (from Capability A or your own draft) and realistic weekly time commitment.

Translate Why Them into a concrete audience and channel plan:

- Ideal audience profile: job title, sector, career stage, the room they're in
- Three-tier engagement strategy: industry voices (10–20 accounts to follow and engage with), peers (50–100 similar practitioners), rising voices (newer voices to amplify)
- Channel matrix: where the audience actually spends time — LinkedIn, X/Twitter, Substack, podcast guesting, in-person speaking, GitHub, YouTube, niche communities
- Time-budgeted options: low (30 min/week), medium (2 hrs/week), high (5+ hrs/week)

**Ask:**
1. How much time can you realistically commit to content and networking per week?
2. Are there channels you've already started (even sporadically)?
3. Are there channels you actively dislike or want to avoid?

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/audience-channels.md`

---

## C. Content Pillars and Cadence

**What you need:** a positioning statement and an audience map.

Translate positioning into three to five content pillars, then a sustainable cadence:

- Derive each pillar from Why You and Why Them — each pillar must be a topic you can write about from direct experience, not from research alone
- For each pillar: 10 specific prompt starters (questions, provocations, case observations — not generic topics)
- Repurposing logic: one long-form piece → thread → short post → talk abstract
- Content mix: long-form (1/week or biweekly), mid-form (2–3/week), short-form (daily or as-happens)
- Voice rules derived from the foundation: what you always do, what you never do, what signals your point of view

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/content-plan.md`

---

## D. Bio Library

**What you need:** a positioning statement (from Capability A).

Produce a coherent set of bios so every surface tells the same story at the right length:

- LinkedIn About — long version (2,000 chars), mid version (600 chars), trimmed (200 chars)
- LinkedIn Headline (120 chars max — cross-reference Capability A of the LinkedIn Coach skill if a deeper headline session is needed)
- X/Twitter bio (160 chars)
- Speaker bio — one paragraph, three sentences, one line
- Podcast guest bio (one paragraph, third person)
- Conference proposal bio (one paragraph, third person, credentials-first)
- About page for personal site (first person, 300–400 words)
- Email signature line (one sentence)

**Rules:**
- Every bio must be derivable from the same positioning statement — they are the same story, not different stories
- No bio should contradict another
- The permission slip should appear (in appropriate form) in at least the long LinkedIn About and the speaker bio
- No fabrication — every credential, title, and metric must be confirmed

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/bio-library.md`

---

## E. Brand Refresh

**What you need:** access to current online presence (LinkedIn, personal site, recent talks or posts) + clarity on where you want to be.

Run a diagnostic before a rebuild:

1. Ask the user to paste or describe their current LinkedIn About, headline, and any recent content
2. Map current signals: what does this presence say you stand for, who for, and why now?
3. Compare against intended positioning (run Capability A inline if no foundation exists)
4. Identify drift: outdated bios, inconsistent voice across channels, content pillars that no longer fit
5. Produce a prioritised refresh plan: keep / cut / add, in what order

**Output:** Save to `{{OUTPUT_FOLDER}}/personal-brand/refresh-plan.md`

---

## Output Standards

- Write in the user's preferred language. Do not default to UK or US English — match what the user writes in.
- No em dashes. Use commas, semicolons, colons, or full stops instead.
- No marketing hyperbole: no "game-changing", "world-class", "thought leader" (use it only if the user specifically uses it about themselves). The framework works when the writing earns trust on its own merits.
- Address the user as "you" throughout the Q&A. In bio drafts, use the tense and person appropriate to the format (first or third person as required).
- Push back gently when positioning is too generic, too aspirational, or unsupported by documented experience. The point is to make the work findable and credible, not to manufacture a persona.

---

## Related Skills

- **/career-engine:linkedin-coach** — LinkedIn-specific tactics (headline mechanics, post review, content strategy). This skill builds the brand strategy layer; LinkedIn Coach turns it into LinkedIn-shaped output.
- **/career-engine:employment-coach** — for role-specific positioning, use the employment coach's GTM framing to align the personal brand with a specific application.
```

- [ ] Write open-source version to `cv-campaign-plugin/skills/personal-brand/SKILL.md`
- [ ] Write installed canonical version to `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/personal-brand/SKILL.md` (replace `{{USER_FIRST_NAME}}` in the description with real name if applicable, replace `{{OUTPUT_FOLDER}}` with real path)

---

## Task 4: LinkedIn Coach Skill

**Purpose:** Create a standalone LinkedIn coach skill with five modes: Full Profile Audit, Content Review, Content Strategy, Headline Optimisation, Video Introduction. Adapted from career-helper's LinkedIn Coach. Uses LinkedIn MCP for profile fetching where available.

**Files:**
- Create: `cv-campaign-plugin/skills/linkedin-coach/SKILL.md`
- Create: `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/linkedin-coach/SKILL.md`

---

### Step 4.1: Create the linkedin-coach skill

Create `cv-campaign-plugin/skills/linkedin-coach/SKILL.md` with this exact content:

```markdown
---
name: linkedin-coach
description: Optimise {{USER_FIRST_NAME}}'s LinkedIn presence across five modes: full profile audit, content review, content strategy, headline optimisation, and video introduction script. Use when the user asks to review their LinkedIn profile, optimise LinkedIn, write a LinkedIn headline, build a content strategy, review a LinkedIn post, or create a video introduction.
allowed-tools: Read, Write, mcp__linkedin-mcp__get_my_profile, mcp__linkedin-mcp__get_person_profile
---

# LinkedIn Coach

Comprehensive LinkedIn optimisation across five modes. Choose the one that fits your situation.

## Capabilities

| # | Capability | When to Use |
|:--|:-----------|:------------|
| A | Full Profile Audit | Complete profile review and optimisation for a target role or audience |
| B | Content Review | Analyse existing posts for audience alignment and impact |
| C | Content Strategy | Build a sustainable 3x/week posting strategy |
| D | Headline Optimisation | Quick headline-only focus |
| E | Video Introduction | 30-second profile video script |

---

## A. Full Profile Audit

**What you need:** LinkedIn profile content (from MCP fetch, screenshots, copy-paste, or PDF export) + career goals or target role.

**Step 1 — Fetch profile (if LinkedIn MCP is connected)**

If `mcp__linkedin-mcp__get_my_profile` is available:
- Run `get_my_profile(sections="experience,education,skills,contact_info")`
- Use the result as the profile source

If not available:
- Ask: "Please paste your LinkedIn About section, current headline, and your most recent 3 experience entries. Or share a screenshot."

**Step 2 — Profile sections review**

Review each section against the target role or audience:

**Headline (120 chars):**
- Does it function as a value statement, not a job title?
- Does it name who it's for (audience signal) or what outcome it creates?
- Is it discoverable — would a recruiter searching for this candidate's skills find it?
- Provide 3 rewrite options with trade-off notes.

**About section:**
- Does it open with a hook that earns the reader's next 30 seconds?
- Does it answer: what do I do, who for, what's different about how I do it, and what's the proof?
- Does it close with a clear call to action?
- Word count: aim for 1,500–2,000 characters (LinkedIn shows ~300 before "see more").
- Provide a rewritten version.

**Experience entries:**
- Are bullets results-first (outcome → action) or task-first (action → implied outcome)?
- Is each role's contribution to the headline narrative clear?
- Are metrics used where available, and are they specific enough to be credible?
- Flag any entry that does more harm than good (gaps, unexplained departures, misaligned roles).

**Skills section:**
- Are the top 3 skills (shown before "see more") the most strategically important ones?
- Are there obvious skills missing that the target role would search for?

**Activity / content:**
- Is there visible activity? LinkedIn's algorithm deprioritises inactive profiles.
- Does recent activity reinforce the headline narrative?

**Step 3 — Discoverability check**

- Is the profile set to "open to work" or "hiring"? (Confirm intent before recommending change.)
- Are keywords from the target JD present in the headline, About, and experience entries?
- Custom URL configured?

**Output:** Save to `{{OUTPUT_FOLDER}}/applications/[role-slug]/linkedin-profile-review.md` (or workspace root for general improvement).

---

## B. Content Review

**What you need:** one or more existing posts + target audience description.

For each post, analyse:

1. **Hook:** Does the first line earn the scroll-stop? Would a target audience member keep reading?
2. **Core idea:** Is there one clear, arguable idea — or is it a list with no point of view?
3. **Proof:** Is the claim supported by specific experience, data, or example — or is it generic advice?
4. **CTA:** Does it end with something that invites a response, or does it just stop?
5. **Voice:** Is this distinctly the author's voice, or does it sound like it could have been written by anyone in their field?

Provide a score (1–5) for each dimension and a specific rewrite suggestion for the weakest dimension.

**Output:** Inline in conversation (copy-paste ready).

---

## C. Content Strategy

**What you need:** role, expertise areas, career goals, target audience, and realistic time commitment.

**Step 1 — Discover content pillars**

Ask:
1. What are the 3–5 topics you could write about from direct experience, not research? (Not what you *should* write about — what you *can* write about with authority.)
2. What do you believe about your field that most people in it get wrong or understate?
3. What questions do you get asked by peers, clients, or candidates that you always have a good answer to?

Map answers to content pillars. Each pillar must pass this test: "Could I write 20 posts on this topic from my own experience without repeating myself?"

**Step 2 — Cadence design**

LinkedIn algorithm rewards consistency above volume. Recommend:
- 3x/week as the standard cadence
- Format mix: Tactical (how-to, lessons learned) / Strategic (point of view, industry observation) / Story (personal experience, behind-the-scenes)
- One post per week should be high-effort (original thinking, strong hook, invites discussion)
- Two posts per week can be lower-effort (share + brief commentary, short insight, question)

Adapt cadence down to 1x/week if the user has less than 2 hours/week.

**Step 3 — Engagement network**

A content strategy without an engagement network reaches no one. Recommend:
- Follow 20–30 accounts in three tiers: industry voices (10), peers (10), rising voices (10)
- Spend 15 minutes/day engaging with these accounts before posting (comment, not just like)
- This builds the network that amplifies the user's own posts

**Step 4 — 4-week content calendar**

Produce a specific 4-week calendar with:
- Week, day, format (Tactical / Strategic / Story)
- Specific topic or prompt (not "post about AI" — "the mistake I see most product managers make when writing AI prompts")
- Target length (100 words / 300 words / 600 words)

**Output:** Save to `{{OUTPUT_FOLDER}}/applications/[role-slug]/content-strategy.md` and `{{OUTPUT_FOLDER}}/applications/[role-slug]/content-calendar.md`.

---

## D. Headline Optimisation

**What you need:** career goals and target audience. Current headline (optional — provide if one exists).

LinkedIn headlines work as value statements, not job titles.

**Goal-first headline design:**

Ask: "What is the primary goal of your LinkedIn presence right now?"
- Job search → headline signals readiness and target role
- Thought leadership → headline signals domain and audience
- Client acquisition → headline signals outcome you create for clients
- Networking → headline signals who you are and what you're building
- Board / advisory → headline signals sector expertise and governance lens

**Headline structure options:**

1. **Value statement:** "[Outcome] for [Audience] | [Proof signal]"
   - Example: "AI go-to-market for B2B SaaS | Former VP @ [Company]"

2. **Role + differentiation:** "[Title] | [What makes this different]"
   - Example: "Product Director | Building AI teams that ship"

3. **Audience-first:** "Helping [Audience] [achieve outcome] | [Credential]"
   - Example: "Helping Series A founders hire their first product team | Ex-Google"

4. **POV signal:** "[Claim or belief] | [Title] @ [Company or stage]"
   - Example: "AI is a GTM problem, not a tech problem | Head of Product"

Provide 3 options with trade-off notes. State the keyword strategy for each (which searches it would and wouldn't surface in).

**Output:** Inline in conversation (copy-paste ready). No file save needed.

---

## E. Video Introduction

**What you need:** career goals, target audience, key messages.

LinkedIn profile videos display on the profile photo — they are the first impression in a search result or connection request.

**Structure:** Hook (5 sec) → Value (10 sec) → Proof (10 sec) → CTA (5 sec)

**Script options by goal:**

**Job search:**
```
Hook: "I'm [Name] — I help companies [specific outcome]."
Value: "I've spent [N] years working on [specific problem space] — specifically [most relevant angle]."
Proof: "Most recently at [Company], I [specific achievement in one sentence]."
CTA: "I'm open to [role type] roles. Connect with me or message me directly."
```

**Client acquisition:**
```
Hook: "[Specific problem your clients face] — that's what I work on."
Value: "I work with [specific client type] on [specific problem] using [distinctive approach]."
Proof: "[Result or client type you've helped] — [one specific example or metric]."
CTA: "If that sounds like your situation, let's talk."
```

**Thought leadership:**
```
Hook: "[Provocative claim or question about your domain]."
Value: "I'm [Name]. I [role/work] — and I write and speak about [specific topic]."
Proof: "[Why you're credible — specific experience or publication]."
CTA: "Follow me for [type of content]."
```

Provide all three options as complete scripts. User picks one, then receive:
- Recording tips (eye contact, background, lighting in 3 points)
- Technical setup checklist (phone vs. webcam, landscape vs. portrait, max length 30 seconds)

**Output:** Inline in conversation (copy-paste ready).

---

## Output Standards

- Write in the user's preferred language — do not default to any specific regional variant.
- No em dashes. Use commas, semicolons, colons, or full stops.
- No hyperbole: no "game-changing", "revolutionary", "supercharge". Brand and professional writing earns trust through specificity, not adjectives.
- Use the Oxford comma (serial comma: "skills, experience, and qualifications").
- Never fabricate credentials, metrics, employers, or publications. Use `{{PLACEHOLDER}}` if a fact is unconfirmed.
- Address the user as "you" in coaching dialogue. In drafts (bios, posts, scripts), use the appropriate person and tense for the format.

---

## Related Skills

- **/career-engine:personal-brand** — builds the brand strategy layer above LinkedIn tactics. Run that first if the user needs a full positioning framework.
- **/career-engine:employment-coach** — for role-specific LinkedIn optimisation tied to an active application.
```

- [ ] Write open-source version to `cv-campaign-plugin/skills/linkedin-coach/SKILL.md`
- [ ] Write installed canonical version to `.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/skills/linkedin-coach/SKILL.md` (replace `{{USER_FIRST_NAME}}` with real name in description; replace `{{OUTPUT_FOLDER}}` with real path in the skill body)

---

## Task 5: QA, Sync Verification, and Repackage

**Purpose:** Run the QA agent to confirm both plugin versions are consistent and no regressions were introduced. Then repackage both .plugin files.

**Files:**
- Read: `cv-campaign-plugin/agents/qa-plugin.md`

---

### Step 5.1: Run the QA agent

Read `cv-campaign-plugin/agents/qa-plugin.md` and follow its instructions. Pass both plugin paths:
- Open-source: `/Users/rachel/cv-campaign-plugin/`
- Installed canonical: `/Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine/`

- [ ] Run QA agent
- [ ] Fix any FAIL findings
- [ ] Re-run until PASS

---

### Step 5.2: Repackage both .plugin files

Run the packaging commands from `cv-campaign-plugin/CLAUDE.md`:

```bash
# Open-source plugin
cd /Users/rachel/cv-campaign-plugin
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
```

```bash
# Personal plugin
cd /Users/rachel/.claude/plugins/marketplaces/local-desktop-app-uploads/career-engine
python3 -c "
import zipfile, os
exclude = {'.git', '__pycache__', '.DS_Store', '.in_use', 'rachel-cheyfitz.dotx.bak'}
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

- [ ] Rebuild open-source .plugin
- [ ] Rebuild personal .plugin

---

## Self-Review

**Spec coverage:**
- LinkedIn MCP connector documented ✓ (Task 1)
- Employment coach updated to use LinkedIn MCP for research ✓ (Task 1)
- Nates-substack red/green flag analysis integrated ✓ (Task 1)
- Nates-substack GTM framing and weighted prioritization integrated ✓ (Task 1)
- Job search skill created — LinkedIn MCP + HN approach ✓ (Task 2)
- Personal Brand skill created ✓ (Task 3)
- LinkedIn Coach skill created ✓ (Task 4)
- Both versions synced ✓ (each task)
- QA gate ✓ (Task 5)

**Placeholder scan:** No TBDs, no "implement later", no "similar to Task N". Every step contains the exact text to write.

**Out of scope (Phase 2, not in this plan):**
- Employer Footprint upgrade (8-agent scored version)
- Career Transitions skill
- Career Navigator skill
- Career Coach orchestrator

**Architecture compliance:**
- New skills contain doctrine only (no procedural steps) ✓
- Agent modification adds tools only, no doctrine ✓
- No personal data in open-source files ✓
- Both versions updated per sync rule ✓
