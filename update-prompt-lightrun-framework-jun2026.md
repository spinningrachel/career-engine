# career-data update prompt — Lightrun attribution fix in 03-framework.md
# Generated: 2026-06-19 | Apply in: Chat AND Code (if using both)

---

## Context (fixed — do not change this block)

You are updating a skill called **career-data**. This is a packaged `.skill` file installed via Customize → Skills in the Claude Desktop app. It contains personal career data — writing rules, professional background, and framework files.

To find career-data:
- Look for a directory containing `career-data-marker.json`
- It will be under your skills path (check `~/.claude/skills/career-data/` or the Desktop app's local session skills path)
- Confirm the marker file exists before editing

After making the edit below:
1. Verify the change is correct
2. Repackage the directory as a `.skill` file (zip the contents, rename to `.skill`)
3. Upload via Customize → Skills → replace the existing career-data skill
4. If you use both Chat/Cowork AND Claude Code, you must apply this update in both environments

⚠️ Do NOT paraphrase the new text. Copy it exactly as written below.

---

## The fix

**File:** `references/03-framework.md`
**Line:** 219 (in the PLG section, inside the "Documented PLG execution" sentence)

**Current text (incorrect):**
```
Snyk (B2D PLG; the in-app notification widget still running today; all UX microcopy), Lightrun, Comeet (full activation sequences — trigger logic, copy, user states, engineering coordination), Coro (self-serve onboarding content, [Chameleon.io](http://Chameleon.io) PM).
```

**Replace with (correct):**
```
Snyk (B2D PLG; the in-app notification widget still running today; all UX microcopy), Lightrun (GTM framework, knowledge base, messaging — no in-app work), Comeet (full activation sequences — trigger logic, copy, user states, engineering coordination), Coro (self-serve onboarding content, [Chameleon.io](http://Chameleon.io) PM).
```

**Why:** The previous version implied Lightrun had activation sequences and in-app work. `01-writing-rules.md` line 81 explicitly prohibits this claim: "NO notification widget, NO activation sequences, NO trigger logic at Lightrun." The activation sequences belong to Comeet. This fix adds a parenthetical to Lightrun clarifying its actual scope, matching the prohibition in writing-rules.

---

## Verification

After applying, confirm:
- Line 219 no longer implies in-app work for Lightrun
- "full activation sequences — trigger logic, copy, user states, engineering coordination" remains attributed to Comeet only
- `01-writing-rules.md` line 81 is unchanged
