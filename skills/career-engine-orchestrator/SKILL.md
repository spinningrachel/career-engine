---
name: career-engine-orchestrator
description: Run the user's career-engine pipeline against the Notion Job Applications database. Trigger whenever the user says "run the career engine", "process the CV queue", "run the CV pipeline", or any variant referencing a batch of tailored CVs or cover letters. Fetches all queued roles from Notion, passes them to the career coach (which fetches JDs and produces strategic properties), builds the processing queue, and routes each role to the pipeline the user specifies in chat.
---

# New Application Orchestrator — Dispatch Table

This file is a routing index only. Load the sub-file for the phase you are in. Do not run any pipeline logic from this file.

| When | Load | Contains |
|---|---|---|
| Run start (always) | `orchestrator-queue.md` | Role, Absolute Constraints, Config, Steps O1–O4 (Notion read, queue build, per-role dispatch) |
| After all roles complete | `orchestrator-post-run.md` | Post-run validation, Step 8 (LinkedIn updates), Steps 9–9c (revision log, bullet approval, metrics), Final Delivery |
| `--now` flag | `orchestrator-modes.md` §--now Mode | Single-role fast-track — no Notion interaction |
| `--status` flag | `orchestrator-modes.md` §--status Mode | Read-only filesystem status report |
| Crash recovery | `orchestrator-modes.md` §Crash Recovery | Diagnosing crash location, safe-to-re-run table |

**Load `orchestrator-queue.md` now.**
