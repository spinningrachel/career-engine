---
name: content-orchestrator
description: "Format-mix rules, batch selection criteria, and dedup logic for the content-orchestrator agent."
---

# Content Orchestrator Skill

## Format Mix

The target mix ensures the content calendar doesn't become monotone. A feed of all Format A posts is dense and exhausting; all Format C posts signals a lack of depth. The mix keeps variety visible to followers.

**Target:** ~50% Format A / ~30% Format B / ~20% Format C

This is a target, not a hard constraint. Apply it across a batch of 3–5 posts. For a batch of 3:
- Ideal: 2A + 1B, or 1A + 1B + 1C
- Acceptable: 2A + 1C, or 1A + 2B
- Avoid: 3A (too dense), 3C (too thin), 2C + 1A (imbalanced)

For a batch of 5:
- Ideal: 2A + 2B + 1C, or 3A + 1B + 1C
- Avoid: 4A + 1C, or 3C + 2B

**Format assignment by idea content:**
- Assign Format A when the idea has a repeatable model or framework with 2+ real proof points — check the idea's Summary and Raw Notes before assigning
- Assign Format B when the idea is a sharp observation with one real example or scenario
- Assign Format C when the idea is procedural, tool-specific, or step-by-step

If the mix of available ideas doesn't support the target (e.g., all ideas are Format A candidates), note this in the batch proposal and proceed with the available formats rather than force-assigning the wrong format.

## Batch Selection Criteria

When selecting which ideas to include in a batch:

1. **Prefer ideas with fuller Raw Notes.** An idea with detailed notes produces a better post than one with a bare title. The Summary and Raw Notes fields are the evidence — if they're thin, flag the idea as "needs development" rather than including it.

2. **Topic variety within a batch.** Avoid two ideas from the same Topic Authority Area in the same batch. Readers see the whole batch over a few days — topic monotony is visible. Refer to `linkedin-post-strategy.md` for the authority areas.

3. **Category distribution.** Don't run a batch of all `LinkedIn Post` category ideas if `Content Framework` or `Personal Experience` ideas are available — different categories produce different post textures.

4. **Recency check.** Check the date on the idea if available. Older undrafted ideas aren't lower quality, but if a topical idea was captured more than 90 days ago, flag it: the timely angle may have passed.

## Dedup Logic

The purpose of dedup is to avoid running two posts on the same angle in close succession — not to avoid the same topic entirely. The same topic from a different angle is fine.

**What to compare:**
- The *angle* of the new idea vs. recently published posts (not just the topic)
- Named proof points: if a recently published post featured a specific company or outcome, another post leading with the same proof point within 30 days looks repetitive

**How to flag:**
- "Too similar" means: same angle + same proof point, or same angle + same conclusion within the lookback window
- "Same topic, different angle" is not a flag — it's healthy content rhythm

**Lookback window:** default 30 days (`content_calendar.dedup_lookback_days`). The user may change this.

**When in doubt, surface the flag.** The user decides whether the similarity is a problem — the orchestrator does not silently exclude.

## Handling Thin Batches

If fewer ideas exist than the requested batch size:

- Use all available `Status = Idea` ideas that meet the criteria
- Tell the user how many are available and how many were requested
- Do not pad the batch with ideas that need development

If zero qualifying ideas exist:
- Stop and report: "No ideas with Status = Idea in the bank. Run mind-dump to add more before batching."
