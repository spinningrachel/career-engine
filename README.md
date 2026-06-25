# career-engine

![Career Engine Pipeline](assets/career-engine-pipeline-v2.png)

A Claude Code (and Cowork) plugin for senior technology professionals who want their career to work for them — landing the right next role, building a credible professional presence, and maintaining the materials and positioning that make both possible on short notice.

It connects your career materials to a Notion job-tracking database and runs a multi-agent workflow that researches roles, writes tailored CVs and cover letters, routes them through recruiter review, gatekeeps them against fabrication rules, exports them to DOCX, and writes results back to Notion — alongside standalone LinkedIn, personal-brand, and maintenance capabilities.

All of it draws from one source of truth: **`career-data`**, a separate skill that holds your positioning framework, career content bank, and approved voice. `career-data` lives on your own machine and is never modified by plugin runs or updates.

> 📖 **Full documentation lives in the [Wiki](https://github.com/spinningrachel/career-engine/wiki).** This page is just the quick start.

---

## Get started

**1. Install the plugin.**

[![Download career-engine.plugin](https://img.shields.io/badge/⬇%20Download-career--engine.plugin-2563eb?style=for-the-badge)](https://raw.githubusercontent.com/spinningrachel/career-engine/main/career-engine.plugin)

Open the Claude Desktop app → **Customize → Connectors → Personal plugins** → **+** → **Create plugin** → **Upload plugin**, and select the downloaded file. It becomes available in **Cowork** and **Claude Code** (not Chat).

Claude Code users can install via the marketplace instead, for automatic updates:

```
/plugin marketplace add spinningrachel/career-engine
/plugin install career-engine@cheyfitz
```

**2. Run setup (once).**

```
/career-engine:setup
```

Setup interviews you about your background, target roles, and positioning, then builds your `career-data` skill. The closing step installs that skill — in Cowork it hands you a prompt to paste into **Chat** (with `/skill-creator`). This is the step people get stuck on: read **[Installing career-data](https://github.com/spinningrachel/career-engine/wiki/Installing-career-data)** before you reach it.

**3. Run the pipeline.**

```
/career-engine:source-open-roles   # find roles
/career-engine --coach-skills      # research + strategy
/career-engine                     # write CVs + cover letters
```

See the **[Pipelines Overview](https://github.com/spinningrachel/career-engine/wiki/Pipelines-Overview)** for the full flow.

---

## Basic requirements

- **Claude Code** (desktop app or CLI) with MCP server support
- **[pandoc](https://pandoc.org/installing.html)** on your `PATH` — required for DOCX export
- **python-docx** — `pip install python-docx`
- A **local output folder** for generated files (iCloud or any local path)
- **Desktop Commander MCP** — file operations and pandoc from sandboxed sessions (required for Cowork)
- **`/skill-creator`** installed in Chat — builds your `career-data` skill during setup

Feature-specific: **Notion** (any pipeline run that reads/writes Notion) and the optional **LinkedIn MCP** (better research; falls back to WebSearch).

Full details and the environment-by-environment breakdown: **[Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Prerequisites)**.

---

## Documentation

Everything beyond this quick start lives in the **[Wiki](https://github.com/spinningrachel/career-engine/wiki)**:

| Section | Pages |
|---|---|
| **Getting Started** | [Installation](https://github.com/spinningrachel/career-engine/wiki/Installation) · [Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Prerequisites) · [Setup](https://github.com/spinningrachel/career-engine/wiki/Setup) · [Installing career-data](https://github.com/spinningrachel/career-engine/wiki/Installing-career-data) |
| **Your Data** | [career-data Overview](https://github.com/spinningrachel/career-engine/wiki/career-data-Overview) · [Updating career-data](https://github.com/spinningrachel/career-engine/wiki/Updating-career-data) · [Reference Files](https://github.com/spinningrachel/career-engine/wiki/Reference-Files) · [Configuration Keys](https://github.com/spinningrachel/career-engine/wiki/Configuration-Keys) |
| **Application Pipeline** | [Overview](https://github.com/spinningrachel/career-engine/wiki/Pipelines-Overview) · [Sourcing](https://github.com/spinningrachel/career-engine/wiki/Sourcing) · [Intake](https://github.com/spinningrachel/career-engine/wiki/Intake) · [New Application](https://github.com/spinningrachel/career-engine/wiki/New-Application) · [Edit](https://github.com/spinningrachel/career-engine/wiki/Edit) · [Fast Track](https://github.com/spinningrachel/career-engine/wiki/Fast-Track) · [Localization](https://github.com/spinningrachel/career-engine/wiki/Localization) · [Cover Letter Prerequisites](https://github.com/spinningrachel/career-engine/wiki/Cover-Letter-Prerequisites) · [Utility Modes](https://github.com/spinningrachel/career-engine/wiki/Utility-Modes) |
| **Standalone Capabilities** | [LinkedIn coach, personal brand, career coach, update references, plugin builder, technical writer](https://github.com/spinningrachel/career-engine/wiki/Standalone-Capabilities) |
| **Outputs & Operations** | [Output Files](https://github.com/spinningrachel/career-engine/wiki/Output-Files) · [Update Prompts](https://github.com/spinningrachel/career-engine/wiki/Update-Prompts) · [State File & Crash Recovery](https://github.com/spinningrachel/career-engine/wiki/State-File-and-Crash-Recovery) · [Token Usage Tracking](https://github.com/spinningrachel/career-engine/wiki/Token-Usage-Tracking) |
| **Reference & Architecture** | [Architecture](https://github.com/spinningrachel/career-engine/wiki/Architecture) · [External Connectors](https://github.com/spinningrachel/career-engine/wiki/External-Connectors) · [Capability Status](https://github.com/spinningrachel/career-engine/wiki/Capability-Status) |

---

## Changelog

### 2026-06-23

- **Documentation moved to the Wiki.** The README is now a quick start; full docs live in the [Wiki](https://github.com/spinningrachel/career-engine/wiki).
- **Marketplace install support.** The plugin is now installable as a Claude Code marketplace. Add it with `/plugin marketplace add spinningrachel/career-engine`, then `/plugin install career-engine@cheyfitz`. Direct `.plugin` download still works for manual installs.
