# Voice Calibration Method

**Important Note**: If you're looking for the user's calibrated voice, the correct file/s are located in the career-data skill. 

A reusable methodology for producing a voice calibration file from a corpus of delivered writing. This is not a live pipeline component — it is a reference procedure a human runs manually, or that a future agent can follow on demand, whenever a fresh calibration is needed.

**Two report formats, chosen by whether the surface has a structure-templates doc:**
- **Templates-aware format (below)** — use when a `cover_letter_templates.md`-style structure doc exists for this surface (i.e. cover letters, which have `${CAREER_DATA}/references/templates/cover_letter_templates.md`, or any future surface that gets its own equivalent). The calibration file's job is then to set the *voice/execution* layer on top of a structure the templates doc already owns — it does not re-derive sentence-length/punctuation/opener patterns from scratch, because the templates doc's Dial Sheet and Shared Invariants already specify those quantitatively.
- **Six-dimension format (Fallback Report Format below)** — use for a surface with no structure-templates doc (e.g. LinkedIn posts, if that surface ever needs this treatment and has no template file of its own), or when the archive is unreachable/empty for a templated surface.

**When to run this:**
- Generating a user's first calibration file during `career-engine-setup` (after cover letters have been approved and stored in `references/delivered-letters/`)
- Refreshing an existing calibration file after new delivered letters are added to the archive
- Producing a calibration file for a new output type that needs its own voice anchor
- Any new user or new writing surface that needs this treatment from scratch

**What it produces:** a single markdown file (e.g. `voice-calibration-coverletters.md`) written to `${CAREER_DATA}/references/`. That file becomes the durable, pre-computed calibration anchor the writing agents read directly — no per-run analysis needed.

---

## Templates-aware format (use when a structure-templates doc exists for this surface)

Write three sections. Keep it short — this file is an execution brief, not an analysis. It should assume the reader has already loaded (or will load) the structure-templates doc; it does not repeat that doc's content, it tells the writing agent how to use it.

```markdown
# Voice Calibration — [surface, e.g. Cover Letters]

## 1. Role & Intent
[1-2 sentences: who the agent is writing as, and the one thing the voice must never sound like — e.g. "an authentic, high-ownership, active first-person voice, cutting out corporate theater, fluff, or formal transition words."]

## 2. Structural Execution (Strict Blueprint)
You must execute the layout, formatting, and structural constraints defined in [name and path of the structure-templates doc, e.g. `references/templates/cover_letter_templates.md`].
- Parse the [JD/brief/context] first.
- Select [Template A / Template B / etc.] per the template doc's own selection criteria.
- Adhere strictly to the Dial Sheet metrics (word counts, sentence ranges, numerals, punctuation caps). Missing a dial constraint or a banned punctuation mark is a total execution failure, not an advisory note.

## 3. Syntax & Generation Guardrails
[2-4 corpus-derived rules that are genuinely distinctive to this user's writing and NOT already covered by the templates doc's own invariants — e.g. a specific register-shift risk ("when the register goes warm, syntax must stay flawless — no dangling modifiers"), a subject-opener variety rule, or any recurring failure mode found while analyzing the corpus. If the templates doc already fully covers mechanics, this section can be short.]
```

Extraction procedure for this format: read the corpus (Step 1 below) and the structure-templates doc together, identify what the templates doc does NOT already constrain (voice/register/persona framing, and any corpus-specific syntax risk), and write only that — do not duplicate the templates doc's own dials, invariants, or banned-phrase lists into the calibration file.

---

## Fallback: six-dimension format (use when no structure-templates doc exists for this surface)

## Procedure

**Step 1 — Read the archive**

Read the corpus index (e.g. `${CAREER_DATA}/references/delivered-letters/INDEX.md`).

- **If the folder or index is unreachable:** stop and use the Fallback Report procedure below instead.
- **If count is 0 and no content files are present:** read `${CAREER_DATA}/references/03-framework.md` §Voice and tone instead and populate the Fallback Report from that section.

Otherwise: read every file listed in the index — all of them, not a sample. Thoroughness here is the entire point: it removes the need for any future run to re-load the archive itself.

**Step 2 — Extract the six dimensions**

Analyse the corpus as a whole (not per-item). Extract:

1. **Sentence length** — short and punchy? long and flowing? what is the typical range?
2. **Word choice level** — formal? conversational? professional-casual?
3. **Paragraph/section openers** — does the writer jump right in, or set context first? Any recurring opener structure?
4. **Punctuation habits** — em dashes absent? commas vs semicolons? parenthetical asides?
5. **Transitions** — explicit connectors ("because", "which means"), or does the next point just start?
6. **Verbal tics** — any recurring phrases, clause structures, or stylistic patterns across the corpus?

**Step 3 — Select representative phrases and content to lift**

From the corpus, pull:
- 2–3 **verbatim phrases** that best represent the voice
- 1–2 **content items to lift**: proof points, analogies, or phrasings a future piece of writing could reuse (note the source context)

**Step 4 — Note what NOT to do**

Identify 2–3 patterns absent from the corpus (semicolons? passive voice? em dashes? formal hedging?) that must not appear in future output calibrated against this file.

**Step 5 — Write the report**

Write the file using the Report Format below to `${CAREER_DATA}/references/` (filename should indicate the surface it calibrates, e.g. `voice-calibration-coverletters.md`).

---

## Report Format

```markdown
# Voice Calibration Report — [surface, e.g. Cover Letters]
Source: N delivered [letters/items]
Generated: [date]

## Six Dimensions

1. **Sentence length:** [description]
2. **Word choice level:** [description]
3. **Paragraph/section openers:** [description — include an example opener if helpful]
4. **Punctuation habits:** [description]
5. **Transitions:** [description]
6. **Verbal tics:** [recurring patterns, or "none identified"]

## Representative phrases
- "[verbatim phrase from corpus]"
- "[verbatim phrase from corpus]"
- "[third phrase — include if 3+ items in corpus]"

## Content to lift
- "[proof point or phrasing]" — [brief context: approximate role/company if identifiable, or item number]

## What NOT to do
- [pattern absent from corpus]
- [pattern absent from corpus]
- [third pattern — include if clearly consistent across the corpus]
```

---

## Fallback Report Format

When the archive is unreachable or empty, populate the report from `${CAREER_DATA}/references/03-framework.md` §Voice and tone instead:

```markdown
# Voice Calibration Report — [surface]
Source: FALLBACK — delivered corpus unavailable. Populated from 03-framework.md §Voice and tone.
Generated: [date]

## Six Dimensions

[Extracted from §Voice and tone — use the same six headings]

## Representative phrases
[Verbatim voice samples from §Voice and tone if present, else "— not available"]

## Content to lift
— not available (no delivered corpus)

## What NOT to do
[Any negative voice guidance in §Voice and tone, else "— see shared-voice-rules.md prohibitions"]
```

---

## Notes for whoever runs this

- This is a one-time (or occasional refresh) task, not a per-pipeline-run step. The output file is durable — it does not change unless someone regenerates it on purpose.
- Once the file exists at `${CAREER_DATA}/references/voice-calibration-coverletters.md`, the letter-writer and humanizer read it directly (a plain file read, no agent spawn) and skip loading the archive entirely — see `skills/humanizer/SKILL.md` Voice Calibration Protocol and `agents/letter-writer.md` Voice Gate.
- If regenerating an existing calibration file (e.g. after adding new delivered letters), overwrite the file in place — the corpus has changed, so the calibration should reflect the full current archive, not be appended to.
- This methodology was originally implemented as a per-run pipeline agent (`voice-analyst`, spawned before every letter-writer/humanizer run). It has been retired as a pipeline component in favor of this durable, manually-regenerated file — see the `CLAUDE.md` cross-file-contracts entry for the Humanizer input boundary for the current pipeline wiring.
