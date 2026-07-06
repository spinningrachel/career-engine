---
name: career-engine
description: "Run the career-engine pipeline. Main entry point for all career-engine commands."
argument-hint: "[--edit | --coach-skills | --coach | --now <url> | --check | --review | --write-letter]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
  - Agent
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-fetch
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-query-database-view
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-update-page
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-create-pages
  # notion-search is intentionally NOT allowlisted: it cannot enumerate the queue (R-39).
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__get_job_details
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__search_jobs
  - mcp__89f52ca2-1cd0-442d-af81-06fc3dac6f6c__search_jobs
  - mcp__c7718911-054e-4537-aa99-e7c6cc691fae__search_jobs
  - WebFetch
  - WebSearch
---

# Career Engine — Pipeline Map

Read this file. Identify the pipeline from the table. Load only the entry skill(s) listed — all logic lives there. Do not load `01-writing-rules.md` at this level; writing subagents load it themselves via `${CAREER_DATA}`.

## Pipelines

| Pipeline | Triggers | Entry skill(s) to load |
|---|---|---|
| **New Application** | *(no flag)* | `career-engine-orchestrator`, `career-engine-new-application`, `career-engine-export` |
| **Edit** | `--edit` | `career-engine-edit`, `career-engine-export` |
| **Prioritization** | "run prioritization" · "triage new roles" · "prioritize my roles" · "prioritize new roles" | `role-prioritizer` |
| **Intake** | `--coach-skills` · "run intake" · "rerun intake" · "process Needs Research roles" · "CV Ready for Review" | `career-engine-intake` |
| **Fast track** | `--now <url or JD>` | `career-engine-orchestrator` (--now section) · `career-engine-new-application` · `career-engine-export` |
| **Setup** | `/career-engine:setup` · "set up the plugin" | `career-engine-setup` |
| **Sourcing** | "find open roles" · "source roles" · "find me jobs" | `source-open-roles` |
| **LinkedIn coach** | "review my LinkedIn" · "optimise my profile" | `linkedin-coach` |
| **Personal brand** | "build my personal brand" · "refresh my bio" · "help me with my positioning" | `career-coach` (Option 3) |
| **Update references** | "update my references" · "update refs" · "here's my updated CV" | `update-refs` |
| **Plugin builder** | "help me work on the career-engine" · any request to modify or extend the plugin | `plugin-builder` |
| **Technical writer** | "write documentation" · "draft a README" · "create a PRD" · "write a runbook" · "write a spec" | `technical-writer` |
| **Mind dump** | "mind dump" · "capture an idea" · "I have an idea to save" | `mind-dump` |
| **Content pipeline** | "draft my posts" · "run the content pipeline" · "batch my LinkedIn posts" | `content-orchestrator` |
| **LinkedIn post** | "write a LinkedIn post" · "draft a post" · "review this post" | `linkedin-post-writer` |
| **Freelance manager** | "create/update a Fiverr gig" · "write an Upwork proposal" · "respond to a freelance inquiry" | `freelance-manager` |
| **Localization** | automatic when `Languages` includes the second language | `localization` |

## One-Pass Utility Modes

No loops, no Notion writeback. Spawn the agent directly.

| Flag | Action |
|---|---|
| `--coach` | Spawn `career-coach` in direct coaching mode |
| `--check` | Spawn `gatekeeper` with `option=cv` or `option=cover-letter` |
| `--review` | Spawn `recruiter-reviewer` with the document and JD |
| `--write-letter` | Spawn `letter-writer` in standalone mode |
| `--status` | Load `career-engine-orchestrator` (status section only) |
