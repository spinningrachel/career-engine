---
name: remote-compatibility-rules
description: Rules for assessing whether a role is compatible with {{USER_FIRST_NAME}}'s Israel-based location. Load before scoring priority on any role. Covers not-compatible, confirmed-compatible, and ambiguous patterns with research guidance.
---

# Remote Compatibility Rules

This check is mandatory before scoring priority. "Remote" does not mean the same thing everywhere, and misreading it wastes significant effort.

## Rules (in priority order)

**NOT compatible with Israel-based candidates:**
- Remote(US), Remote – United States, Remote (US only), "Must be authorized to work in the US" — hard no
- Remote(UK), Remote(EU), Remote(Canada), Remote(Germany) etc. with a specific non-Israel country — NOT compatible unless Israel or EMEA broadly is explicitly included elsewhere
- Any role requiring work authorization in a specific country {{USER_FIRST_NAME}} is not authorized to work in

**Confirmed worldwide compatible:**
- "Remote (Worldwide)", "Work from anywhere", "Open to candidates globally", "No timezone restrictions"
- Remote with no country qualifier AND the company's other open roles consistently show no country qualifier
- "Remote + EMEA" or "Remote + [list that includes Israel or the EMEA region broadly]"
- Company About page explicitly states a distributed global team

**Ambiguous — requires research:**
- "Remote" with no country qualifier on this role, BUT other roles at the same company say "Remote(US)" → treat as NOT compatible
- "Remote" with no qualifier and the company's hiring pattern is unclear → flag as ambiguous and state what was checked
- Hybrid or remote-first language without geographic scope → research the company's hiring page

## Rule

When in doubt, classify as `Ambiguous` rather than worldwide-compatible. A false positive here (assuming worldwide when it's US-only) wastes more effort than a false negative.

Set `Remote compatibility` in your output accordingly. Your research may reveal more precise geographic scope than the JD text alone — if so, use your research reading and note the discrepancy.
