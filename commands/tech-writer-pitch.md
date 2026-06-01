---
description: "Reframe CV for founding/first technical writer roles. Paste a job listing, URL, or company name. Output: a tailored CV framed around documentation architecture and GTM strategy — not a writer application."
argument-hint: "[job listing URL, company name, or paste JD]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - WebFetch
  - WebSearch
---

# Tech Writer Pitch

1. **Fetch the JD.** If {{USER_FIRST_NAME}} provides a URL, fetch it. If she provides a company name, search for the posting. If the JD cannot be fetched, ask {{USER_FIRST_NAME}} to paste the relevant sections.

2. **Spawn `cv-writer` with `option=reframe`.** Pass the full JD text and any instructions {{USER_FIRST_NAME}} has given (target person, channel preference, specific angle). `candidate-rules.md` is loaded by cv-writer — do not pre-load it here.

3. **Deliver cv-writer's output directly.** No post-processing. Do not produce any additional output at all.

