---
description: "Standalone research pipeline for Hold roles. Researches companies, spawns the employment coach for full strategic property generation, spawns letter-writer to generate Q&A interview questions, writes all results to Notion, updates Status to Researched. Run before the full campaign so advice and Q&A are ready. No CVs generated."
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - TodoWrite
  - WebFetch
  - WebSearch
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-fetch
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-query-database-view
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-update-page
  - mcp__5cd94b8e-1498-421b-bc5d-1bbb07682cf7__notion-create-pages
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__get_job_details
  - mcp__140d3f8f-6ad4-4b39-9df9-84514cae0207__search_jobs
  - mcp__89f52ca2-1cd0-442d-af81-06fc3dac6f6c__search_jobs
  - mcp__c7718911-054e-4537-aa99-e7c6cc691fae__search_jobs
---

# Standalone Research Pipeline

Load the `coach` skill and follow it exactly.
