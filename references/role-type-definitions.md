---
name: role-type-definitions
description: Definitions for the Role Type property in the job applications database, and the effect each type has on CV structure. Loaded by the career coach (sets the value) and the cv-writer (uses it to select CV structure). The orchestrator does not use this table directly.
---

# Role Type Definitions

`Role Type` is a multi-select property set exclusively by the career coach. Choose all that apply — roles commonly combine types.

| Value | Definition |
|---|---|
| `Builder` | First or founding hire; building the function or infrastructure from zero with no team or existing motion |
| `Scaler` | Growing an existing function, managing a team, scaling what's already working |
| `Specialist` | Deep domain expert hired for a specific craft without a function-building mandate |
| `Leader` | Explicitly managing people; leadership-team membership expected from day one |

Multi-select examples: "Builder, Leader" = founding hire who also owns people management. "Scaler, Specialist" = growing a specialist function (e.g., scaling a PMM team with deep product marketing craft required).

**Effect on CV structure:** Builder or Leader → one-line skills, no Key Achievements section (function-builder framing). Scaler or Specialist → categorized skills block, compact Key Achievements acceptable (craft/scaling framing). When combined, lead with the stronger signal for the specific JD.
