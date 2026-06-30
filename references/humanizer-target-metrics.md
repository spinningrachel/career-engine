---
name: humanizer-target-metrics
description: Quantitative targets and measurable thresholds for cover-letter humanization. Loaded by the cover-letter-humanizer agent. These are cover-letter-specific adaptations of general burstiness and voice metrics — adapted from linguistic research on human vs AI writing patterns.
---

# Humanizer Target Metrics — Cover Letter

These are the measurable targets the humanizer must verify before returning output. They are checkpoints, not aspirations — every letter that passes the Final Gate must hit them.

**Why numbers matter here.** The humanizer's sentence-structure and voice rules define what to remove. These metrics define what the finished letter must look like. A letter that passes every named rule but has uniform sentence lengths and zero paragraph variance still reads as assembled. The burstiness targets are what catches that.

---

## 1 — Sentence Burstiness

**Target:** Range between the shortest and longest sentence in the letter ≥ 20 words.

**Minimum anchor:** At least one sentence ≤ 8 words. At least one sentence ≥ 25 words.

**Why 20?** General human writing has a range of 25+ words (vs. AI's <15). Cover letters are shorter and more focused, so 20 is the floor, not the ceiling. A tight letter with a 30-word range is excellent.

**How to measure:** Find the shortest sentence (count words). Find the longest sentence. Subtract. If the result is <20, intervene: break a long sentence in two, or make a transition into a standalone short sentence.

**Calibration against the voice report:** The delivered-letters calibration (from `$PIPE/voice-calibration.md` or the direct archive read) shows the user's actual burstiness pattern. Match it where it exceeds the floor.

---

## 2 — Paragraph Burstiness

**Target:** No two adjacent paragraphs within 20 words of each other in length. At least one paragraph ≤ 40 words (short anchor) and at least one paragraph ≥ 90 words (longer anchor).

**Note for a 3-paragraph letter:** If only three paragraphs exist, the opener, body, and close should each land at a meaningfully different length. A 90/120/40 distribution passes. A 95/105/100 distribution fails.

**How to measure:** Count words in each paragraph. Compare adjacent pairs. If two adjacent paragraphs are within 20 words of each other and the letter is reading monotone, split or merge to create a length contrast.

---

## 3 — Passive Voice Density

**Target:** ≤ 25% passive constructions. Aim for ≤ 20%.

**How to measure:** Count total sentences. Count sentences with passive constructions ("was [past participle]", "is [past participle] by", "[noun] gets [past participle]"). Divide. In a 15-sentence letter, more than 3–4 passive sentences is a fail.

**Note:** The humanizer's Step 2 table catches passive constructions already. This metric is the Final Gate verification — at that point, scan the full letter for passive density as a number, not just per-sentence.

**Exception:** Passive used for intentional voice effect, consistent with the delivered-letters archive, is not counted against the threshold. If the archive shows she uses passive occasionally for rhythm, trust the calibration.

---

## 4 — Hedging Density

**Target:** 0 hedging phrases per letter. Cover letters must commit to every claim.

**What counts as hedging:**
- Epistemic hedges: "arguably," "perhaps," "seemingly," "it seems," "I believe," "I think," "I feel"
- Modal hedges: "could be," "might be," "may be," "seem to," "tend to," "appear to"
- Soft qualifiers: "to some extent," "in a sense," "in some ways," "somewhat," "rather," "fairly," "quite"
- Boilerplate softeners: "I hope to," "I would love to," "I would be interested in"

**Note:** Direct modals used as future tense ("I will," "I can," "I am") are not hedging. Conditional modals that name a dependency ("If selected, I would lead...") are not hedging.

**Threshold:** 0. If one appears, cut or reword. This is not a density target — it is a zero-tolerance rule for cover letters.

---

## 5 — Transition Density

**Target:** ≤ 1 paragraph opener that begins with a transitional word. "And," "but," and "so" do not count. The prohibited class: "Furthermore," "Moreover," "Additionally," "However" (at paragraph start), "Therefore," "Consequently," "In addition," "That said," "With that," "On the other hand," "In contrast," "To that end."

**How to measure:** Read the first word of each paragraph. If 2+ paragraphs open with a word from the prohibited class, cut or reword to let the content lead.

---

## 6 — Vocabulary Diversity (spot-check)

**Target:** Distinctive compound phrases (2+ words forming a named concept) must not repeat within the letter. No individual high-value word should appear more than twice (excluding articles and prepositions).

This is already enforced in Step 4 (Repeated phrase ban). The metric here is the verification: scan the letter for any 2–3 word compound that appears more than once. If found, cut the weaker instance.

---

## 7 — Final Gate Metric Check (ordered)

Run these at the Final Gate, in order, after all step passes are complete:

1. **Sentence burstiness ≥ 20 words:** [shortest] ___w / [longest] ___w / range ___ → PASS / FAIL
2. **Paragraph burstiness — no adjacent pair within 20 words:** [P1] ___w / [P2] ___w / [P3] ___w / [P4] ___w → PASS / FAIL
3. **Passive density ≤ 25%:** ___ passive / ___ total sentences = ___% → PASS / FAIL
4. **Hedging density = 0:** scan for hedging words above → PASS / FAIL
5. **Transition density ≤ 1 paragraph opener:** count paragraph-opening transitions → PASS / FAIL
6. **No repeated compound phrases:** scan 2–3 word compounds for duplicates → PASS / FAIL

**Any FAIL here = fix and re-run the Final Gate from Step 1 of the humanizer skill's checklist.**
