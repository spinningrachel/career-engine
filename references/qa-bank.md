---
name: qa-bank
description: {{USER_FIRST_NAME}}'s reusable Q&A answers for cover letter intake. Letter-writer loads this before generating Notion Q&A questions. If an answer exists here, use it directly — do not ask {{USER_FIRST_NAME}} again. Only send genuinely unanswered or role-specific questions to Notion Q&A.
---

# Q&A Bank

> **Setup required.** This file ships empty. Populate it during setup by answering each question type below in your own voice. The goal is to capture your GENUINE reactions — the raw material letter-writers use instead of asking you the same question repeatedly. Terse, honest, first-person answers work better than polished prose. New entries are auto-promoted here from Notion Q&A at the end of every pipeline run.

---

| Question | Answer | Details |
|---|---|---|
| What's the professional observation that defines your approach — the problem you exist to solve? | {{USER_ANSWER_CORE_IDENTITY}} | Core identity statement. Use as the foundation for problem-first letter openers. |
|---|---|---|
| What's the most recent research you commissioned or ran yourself that directly changed a positioning or messaging decision? | {{USER_ANSWER_RESEARCH_EXAMPLE}} | → Canonical methodology: `references/framework.md` §Research-first methodology. |
| Does {{USER_FIRST_NAME}} have experience with a domain she hasn't worked in before — is unfamiliarity with a domain a blocker? | {{USER_ANSWER_FAST_LEARNING}} | → Canonical argument: `references/framework.md` §The Fast Learning Argument. |
| What is {{USER_FIRST_NAME}}'s geographic filter for roles? | {{USER_ANSWER_GEO_FILTER}} | Apply before investing in any application for a non-local role. |
| Does {{USER_FIRST_NAME}} ever have warm contacts at companies? | Always write letters as though there are no warm contacts — these are things {{USER_FIRST_NAME}} tweaks before sending. | General process rule. Never reference a warm contact in a letter unless {{USER_FIRST_NAME}} explicitly provides the name and context for that specific application. |
| Does {{USER_FIRST_NAME}} have public speaking or on-camera experience? | {{USER_ANSWER_PUBLIC_SPEAKING}} | Use for roles that call for evangelism, thought leadership, or external-facing work. |
| Do you have any personal exposure to AI tools or vibe-coding tools as a hands-on user? | {{USER_ANSWER_AI_TOOLS}} | → Canonical framing: `references/framework.md` §AI-architected operating leverage and human thought leadership. |
| Give me a specific moment from your experience where the ambiguity was real — a consequential call with incomplete information that shaped the whole direction. | {{USER_ANSWER_AMBIGUITY_MOMENT}} | Use for roles requiring strategic judgment under uncertainty. |
| Do you have a concrete example of writing or significantly shaping conversion copy where you can point to a measurable outcome? | {{USER_ANSWER_CONVERSION_COPY}} | Use for roles with explicit conversion or growth-copy requirements. |
| {{USER_CUSTOM_QUESTION_1}} | {{USER_CUSTOM_ANSWER_1}} | {{USER_CUSTOM_CONTEXT_1}} |
| {{USER_CUSTOM_QUESTION_2}} | {{USER_CUSTOM_ANSWER_2}} | {{USER_CUSTOM_CONTEXT_2}} |

---

**How to add entries:** Any time you answer a Q&A question in Notion that you'd answer the same way again, promote it here. The letter-writer checks this bank first before prompting for new answers. Entries here eliminate repeated intake questions across runs.
