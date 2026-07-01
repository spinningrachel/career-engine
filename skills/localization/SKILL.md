---
name: localization
description: >
  Terminology dictionary and doctrine for localizing a CV and cover letter from
  the user's default language into their second language. Consulted by the
  localization agent for all terminology decisions, cultural register guidance,
  and structural rules. Contains one table per category under the Hebrew section.
  Setup note: if the user's default language is not English, the setup agent
  rewrites the Default Language column during onboarding — see setup instructions
  at the bottom of the Opening section.
---

# Localization Skill

> **Registry:** this pipeline is listed in the Pipeline Registry in `skills/career-engine/SKILL.md`. Actions owned by another pipeline's registry row are out of scope here — route to that pipeline instead of improvising.

> **`career-data` data root (R-37).** The personal-data files — `01-writing-rules.md`, `02-professional-background.md`, `03-framework.md`, `linkedin-profile.md`, `pipeline-preferences.json`, `delivered-letters/`, and the user's `.dotx` — load from `${CAREER_DATA}/references/`, the path the orchestrator resolves in its `career-data` discovery preflight. Every other file (self-checks, `REFERENCES.md`, skill docs, default `.dotx` templates) stays on `${CLAUDE_PLUGIN_ROOT}`. If `${CAREER_DATA}` is not set (direct or standalone invocation outside the orchestrator), locate the `career-data` skill yourself, confirm `career-data-marker.json`, and apply the orchestrator's healthy / damaged / absent outcomes before reading. A configured user's missing `career-data` is a hard stop — never silently fall back to blank templates.

## Opening

### What this skill governs

This skill defines how to localize a CV and cover letter from **{{USER_DEFAULT_LANGUAGE}}** into **{{USER_SECOND_LANGUAGE}}**. It is a reference, not a procedure — the procedure lives in `agents/localization.md`. Consult this skill for:

- Which terms to keep in the source language vs. render in the target language
- How to transliterate loanwords
- Seniority titles and gender agreement
- Date formats and section heading mappings
- Cultural and tonal register guidance

---

### The hybrid register principle

The target reader operates in a hybrid professional register. They do not translate acronyms and SaaS-native English terms — those terms travel untouched into their native language because they are the lingua franca of global tech. Forcing a pure-language rendering of GTM, ARR, or ICP sounds like a government press release from a previous decade.

At the same time, leaving borrowed terms in English when a natural phonetic or native form exists signals the writer was uncertain how to express the concept in the target language — even if the word is technically intelligible.

**The test:** Would a senior professional in the target language write this word naturally in a Slack message, a Notion doc, or a professional email in the target language? If yes, write it in the target language. If they would say the English word as-is, keep English.

---

### The phonetic hierarchy — apply in this order

1. **Clear native equivalent exists** → use the native form. שיווק not marketing. מיצוב not positioning.
2. **Borrowed loanword in wide use** → write phonetically in target-language script. סטארטאפ. פלטפורמה. אונבורדינג.
3. **Company name with a natural phonetic rendering** → write phonetically. When a company name has no obvious rendering, keep Roman script.
4. **Software product and tool names** → keep in Roman script. HubSpot, Salesforce, Webflow. These are proper product names, not words.
5. **Standard acronyms** → keep in Roman script. PMM, ARR, GTM, SaaS, B2B, ICP — these are universal and unrecognizable if transliterated.

---

### Tonal register

Localization is re-expression, not translation. The same substance and confidence in a different linguistic register. Key principles:

- **Be direct.** Professional communication in many languages is shorter and more direct than English. Do not pad to match English word count. A compact, clean output signals fluency.
- **Cut hedging.** Translated English often preserves hedging phrases that sound unnatural in the target language. Cut them.
- **Match formality to context.** A CV targeting a tech company reads nothing like a government document. Avoid archaic or bureaucratic forms wherever the everyday equivalent works.
- **Lead with action or outcome** — not context.

---

### Sources of authority for Hebrew

When in doubt on a Hebrew term, check in this order:
1. **Microsoft Hebrew documentation** — reference for technical and professional terms
2. **Academy of the Hebrew Language** terminology database (terms.hebrew-academy.org.il)
3. **Calcalist, TheMarker, Geektime** — Israeli tech press register
4. **Company careers pages in Hebrew** (Monday.com, Wix, AppsFlyer) — mirror their register exactly

---

### Gender agreement (Hebrew)

Hebrew is a grammatically gendered language. All verbs, adjectives, and role titles must match the candidate's gender throughout. Confirm gender from `references/01-writing-rules.md` Section 8 before writing. See the Seniority and Role Titles table for male/female forms.

---

### Setup instruction: if default language is not English

> **This section applies to the setup agent only — not to the localization agent at runtime.**

This skill is shipped with English as the default language column. If the user's configured default language is not English, the setup agent must rewrite the Hebrew section tables as follows:

1. **Rename the column header** from "Default Language" to "Default Language ({{USER_DEFAULT_LANGUAGE}})".
2. **For rows where English-as-is = Y** (the term is always kept in English even when writing in Hebrew): the Default Language column value stays as the English term. Update Notes to confirm: "This term is used in English even in {{USER_DEFAULT_LANGUAGE}} professional writing."
3. **For rows where English-as-is = —**: replace the Default Language value with the Hebrew value from the Hebrew column. Move the original English term to the English-as-is column (or a Notes annotation).
4. **Example (Stealth, English-as-is = Y, default = Hebrew):** Default Language = Stealth; Hebrew column = Stealth; Notes = "Term not translated in Hebrew professional context — always appears in English."
5. **Example (PR, English-as-is = —, default = Hebrew):** Default Language = יחסי ציבור; English column (formerly Hebrew) = PR / Public Relations.

---

## Hebrew

> The tables below cover: (1) Professional terminology from the Israeli B2B/SaaS context; (2) General job-function vocabulary; (3) Seniority and role titles; (4) Company name phonetics; (5) Date conversions; (6) CV section headings.

---

### Professional Terminology

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| LOB (Line of Business) | קו עסקי / תחום עסקי | LOB (קו עסקי) | Y | Keep as LOB in CVs; Hebrew gloss on first mention only |
| GTM (Go-to-Market) | אסטרטגיית חדירה לשוק (Wikipedia HE, StartPlan) / תוכנית חדירה לשוק | אסטרטגיית GTM | Y | Industry shorthand; use Hebrew gloss on first mention; thereafter GTM alone |
| ARR (Annual Recurring Revenue) | הכנסה שנתית חוזרת (Colman MBA) / הכנסה שנתית צפויה (lastartup.co.il) | ARR | Y | Never translate in a CV; lingua franca of Israeli SaaS. Model: "הובלת צמיחת ARR מ-X ל-Y דולר" |
| PMM (Product Marketing Manager) | מנהל/ת שיווק מוצר; Hebrew acronym: פמ"מ (Mako/Nexter; podcast "פרודקט, מרקטינג ומה שביניהם") | Product Marketing Manager (PMM) / מנהל/ת שיווק מוצר (PMM) | — | Both PMM and פמ"מ accepted; Hebrew title valid in narrative |
| ACV (Annual Contract Value) | שווי חוזה שנתי (rare in published writing) | ACV | Y | Less ubiquitous than ARR; always keep in English |
| PE (Private Equity) | פרייבט אקוויטי (transliteration, very common) / הון פרטי | חברה בבעלות קרן פרייבט אקוויטי (PE) | — | "פרייבט אקוויטי" is the most common Hebrew rendering in VC/finance contexts |
| ICP (Ideal Customer Profile) | פרופיל לקוח אידיאלי; Hebrew acronym: פל"א (mnemir.com, imtec.co.il) | הגדרת ה-ICP / פרופיל לקוח אידיאלי | Y | ICP dominates in tech CVs; פל"א recognized but rarer |
| ABM (Account-Based Marketing) | שיווק מבוסס חשבון / שיווק מבוסס לקוח (Leos, Fialkov Digital) | אסטרטגיית ABM / שיווק מבוסס חשבון (ABM) | Y | Use full Hebrew on first mention |
| SDR (Sales Development Representative) | נציג/ת פיתוח מכירות (Drushim, TechMonster, Jolt) | SDR | Y | Title on CV is invariably SDR or BDR; Hebrew gloss acceptable in narrative |
| AR (Analyst Relations) | קשרי אנליסטים (Calcalist: "מנהלת קשרי אנליסטים") | Analyst Relations (קשרי אנליסטים) | Y | "AR" alone is ambiguous — also Augmented Reality and Accounts Receivable; always include gloss |
| SMB | עסקים קטנים ובינוניים | SMB | Y | No Hebrew acronym; SMB is the standard Israeli SaaS segmentation label |
| Mid-Market | — | Mid-Market | Y | No Hebrew equivalent in B2B segmentation; always English. "שוק ביניים" is not used in this context |
| Win/Loss analysis | ניתוח עסקאות שזכינו/הפסדנו / ניתוח Win/Loss | ניהול תוכנית Win/Loss / ניתוח עסקאות זכייה/הפסד | Y | Framework name kept in English; Hebrew gloss in narrative is acceptable |
| AppSec (Application Security) | אבטחת אפליקציות / אבטחת קוד (ALM Toolbox, YouCC) | AppSec | Y | Cybersecurity CV standard |
| SCA (Software Composition Analysis) | ניתוח רכיבי תוכנה / ניתוח הרכב התוכנה (Bynet, Israelclouds) | SCA | Y | Always kept in Latin |
| SAST (Static Application Security Testing) | בדיקה סטטית של אבטחת יישומים (Mr Coral) / סריקת קוד סטטי (ALM Toolbox) | SAST | Y | All AppSec acronyms (SAST, DAST, IAST) kept in Latin |
| IC (Individual Contributor) | — | Individual Contributor / ללא אחריות ניהולית ישירה | Y | No established Hebrew equivalent in Israeli tech HR; describe role concretely in narrative |
| DevRel (Developer Relations) | קשרי מפתחים / ניהול קשרי מפתחים (Geektime) | DevRel | Y | Hebrew gloss for explanatory articles only; "DevRel" is the live standard |
| PM (Product Manager) | מנהל/ת מוצר (universal in job ads) | מנהל/ת מוצר (PM) | — | Both PM and Hebrew title valid; use appropriate gender form. PM ≠ Project Manager (= מנהל/ת פרויקטים or PMO) |
| UX Microcopy | מיקרו-קופי (Kinneret Yifrah's book, Hebrew Wikipedia, microcopim.co.il community) | כתיבת מיקרו-קופי / תוכן UX | — | מיקרו-קופי is the codified standard Hebrew industry term; do NOT use "UX Microcopy" in Hebrew prose |
| BSS/OSS | מערכות תמיכה עסקיות/תפעוליות (Wikipedia HE, Microsoft Hebrew docs) | BSS/OSS | Y | Israeli telecom CVs (Amdocs, Comverse alumni); Hebrew gloss on first mention only |
| ERP (Enterprise Resource Planning) | מערכת לתכנון משאבי הארגון (TheMarker; explanatory gloss only) | מערכת ERP | Y | "ERP" always in Latin; Hebrew form in parentheses on first mention only |
| PR (Public Relations) | יחסי ציבור (universal); informal: יח"צ | ניהול יחסי ציבור | — | Hebrew dominates; do NOT write "PR" alone in Hebrew prose |
| Stealth / Stealth Mode | מצב חשאי (Calcalist: "פועלת עדיין במצב חשאי (Stealth Mode)") | סטארטאפ ב-Stealth Mode / חברה במצב חשאי (Stealth) | Y | "סטלת'" is not used in published Israeli tech writing; keep "Stealth" or use Hebrew form |
| Outbound | שיווק יוצא (Masa Media, Ice, Rosh Digital) | Outbound motion | Y | Keep English in CV titles ("Outbound Sales", "Outbound SDR"); "שיווק יוצא" acceptable in narrative prose |
| Onboarding | אונבורדינג (Mr Coral, 12Buy, Hybridiyot) / קליטה / קליטה והטמעה | אונבורדינג לקוחות | — | Both work; אונבורדינג preferred for customer onboarding in B2B context |
| Roadmap | מפת דרכים (Academy of Hebrew Language; Hebrew Wikipedia; Product Community Israel) | מפת דרכים למוצר / Product Roadmap | — | Formally codified by the Academy. Note: "רודמאפ" (transliteration) is less standard — prefer מפת דרכים |
| Use Case | מקרה שימוש (Wikipedia HE) / תרחיש שימוש | Use Case / מקרה שימוש | Y | "יוז קייס" appears in speech only, not in written professional prose |
| Full Stack (marketer context) | — | Full Stack | Y | Engineering meaning only in Israeli Hebrew; marketing extension ("full-stack marketer") has no Hebrew equivalent |
| Seed (funding stage) | שלב הסיד / סיבוב סיד / סבב גיוס Seed (BDO, lastartup.co.il) | סבב גיוס Seed | Y | "סיד" transliteration is in widespread use |
| Series C (funding stage) | סבב גיוס C (Geektime, Semperis) / סדרה C | סבב גיוס C / Series C | Y | Hebrew form "סבב גיוס C" dominates in articles; CVs often write "Series C" |
| Thought Leadership | מנהיגות מחשבתית (Microsoft HE, Reverso) / מוביל/ת דעת קהל | תוכן Thought Leadership / מנהיגות מחשבתית | Y | Very common in marketing CVs; both forms used |
| Fleet Intelligence | — | Fleet Intelligence | Y | No established Hebrew term in Israeli automotive/fleet-tech (Ituran, Pointer, Ottopia) |
| Video Telematics | — | Video Telematics | Y | No fixed Hebrew rendering; "טלמטיקה" covers telematics generally; keep specific term in English |
| Computer Vision | ראייה ממוחשבת (Calcalist "מהפכת הראייה הממוחשבת", SCE academic program) | ראייה ממוחשבת / Computer Vision | — | Both acceptable; Hebrew more established than most other AI sub-fields |
| ML / Machine Learning | למידת מכונה (SCE, Yael Group, Whatisai.co.il) | ML / Machine Learning | Y | ML always in Latin in CVs; "למידת מכונה" in narrative paragraphs |
| AI | בינה מלאכותית (universal) | AI / בינה מלאכותית | Y | Both coexist freely; AI in skills sections, Hebrew in narrative descriptions |
| Data Engineering | הנדסת נתונים (formal) / הנדסת דאטה (everyday tech) | Data Engineering / Data Engineer | Y | Almost always English in CVs (Drushim listings confirm); Hebrew in narrative |
| Payroll | שכר / חשבות שכר (accounting function) / תלוש שכר (pay stub) / חשב/ת שכר (job title) | Payroll (product category) / חשבות שכר (HR function) | — | Hebrew dominates for the HR/finance function; English kept when describing a payroll product category |
| Targeting (ABM context) | טירגוט / טרגוט (TheMarker "טירגוט קונטקסטואלי", Calcalist) | טירגוט | — | "טירגוט" dominant in Hebrew prose; "Targeting" also common in CVs; verb "לטרגט" is standard |
| Briefing (analyst briefing) | תדריך (dictionary) / בריפינג (marcom/PR practice) | תדריך אנליסטים / Analyst Briefing | Y | Often kept as "Briefing" in AR/PR CV bullets |
| Annotation / Data Annotation | תיוג / תיוג נתונים (Geektime: "תהליך תיוג נתונים") | תיוג נתונים (Data Annotation/Labeling) | — | "תיוג" is common in Hebrew prose; "Annotation" sometimes kept in ML role CVs |
| Nasdaq | נאסד״ק (with gershayim; Calcalist standard) / נאסדק | חברה נסחרת בנאסד״ק | — | Hebrew transliteration is the standard newspaper spelling; both forms acceptable in CVs |
| A/B Testing | מבחני A/B / טסטים A/B | A/B Testing | Y | No accepted pure-Hebrew translation — mnemir.com notes: "אין לה שם טוב עדיין בעברית" |
| FAQ | שאלות נפוצות (universal) | כתיבת שאלות נפוצות (FAQ) | — | Hebrew dominates; "FAQ" alone fine in product/marketing contexts |
| From-To messaging | — | From-To messaging | Y | Niche PMM framework name; no Hebrew equivalent in Israeli content |

---

### Job Function Vocabulary

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| marketing (function) | שיווק (native) / מרקיטינג (phonetic) | שיווק (in section headings) / מרקיטינג (in prose) | — | שיווק preferred in formal headings; מרקיטינג reads more naturally in free prose |
| product marketing | פרודקט מרקיטינג | פרודקט מרקיטינג | — | Combined form is standard in Israeli tech |
| product (noun) | מוצר (standalone) / פרודקט (modifier in titles) | מוצר | — | "פרודקט מנג'ר" not "מוצר מנג'ר" in job title context |
| competitive intelligence | מודיעין תחרותי | מודיעין תחרותי | — | |
| sales enablement | הכשרת מכירות / אפשור מכירות | הכשרת מכירות | — | |
| positioning | מיצוב (native) / פוזיציונינג (phonetic) | מיצוב | — | Native term preferred; phonetic acceptable in prose |
| go-to-market | גו-טו-מארקט (phonetic) / GTM (acronym) | אסטרטגיית GTM | Y | See GTM row in Professional Terminology for full guidance |
| demand generation | יצירת ביקוש | יצירת ביקוש | — | |
| content (marketing) | תוכן | תוכן | — | |
| analyst relations | קשרי אנליסטים | קשרי אנליסטים | — | See AR row in Professional Terminology |
| launch | השקה | השקה | — | |
| market share | נתח שוק | נתח שוק | — | |
| revenue | הכנסות | הכנסות | — | |
| growth | צמיחה | צמיחה | — | |
| pipeline | פייפליין | פייפליין | — | |
| enablement | הכשרה / אפשור | הכשרה | — | |
| compliance | ציות / רגולציה | ציות | — | |
| enterprise (adjective) | ארגוני | ארגוני | — | |
| enterprise (market segment noun) | אנטרפרייז | שוק האנטרפרייז | — | English noun used as a market segment label in Israeli SaaS sales contexts |
| startup | סטארטאפ | סטארטאפ | — | |
| platform | פלטפורמה | פלטפורמה | — | |
| portfolio | פורטפוליו | פורטפוליו | — | |
| battlecard | בטלקארד | בטלקארד | — | |
| cybersecurity | אבטחת סייבר | אבטחת סייבר | — | |
| procurement | רכש | רכש | — | |
| acquisition (M&A) | רכישה | רכישה | — | |
| acquisition (customer) | גיוס לקוחות | גיוס לקוחות | — | |
| direct reports | כפיפים ישירים | כפיפים ישירים | — | |
| team | צוות | צוות | — | |
| founding [role] | [תפקיד] מייסד/ת | [תפקיד] מייסד (m.) / [תפקיד] מייסדת (f.) | — | Apply gender form matching the candidate |

---

### Seniority and Role Titles

> Apply the correct gender form throughout. Confirm from `references/01-writing-rules.md` Section 8.

| Default Language | Hebrew (feminine) | Hebrew (masculine) | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|---|
| Head of [Function] | ראשת [פונקציה] / מנהלת [פונקציה] | ראש [פונקציה] / מנהל [פונקציה] | ראשת [פונקציה] (f.) / ראש [פונקציה] (m.) | — | Both "ראשת" and "מנהלת" accepted |
| Director of [Function] | מנהלת [פונקציה] | מנהל [פונקציה] | מנהלת [פונקציה] (f.) | — | |
| VP of [Function] | סמנכ"לית [פונקציה] | סמנכ"ל [פונקציה] | סמנכ"לית [פונקציה] (f.) | — | |
| Senior Manager | מנהלת בכירה | מנהל בכיר | מנהלת בכירה (f.) | — | |
| Founding [role] | [תפקיד] מייסדת | [תפקיד] מייסד | [תפקיד] מייסדת (f.) | — | |
| Head of Product Marketing | ראשת פרודקט מרקיטינג / מנהלת פרודקט מרקיטינג | ראש פרודקט מרקיטינג / מנהל פרודקט מרקיטינג | ראשת פרודקט מרקיטינג (f.) | — | |
| Director of Product Marketing | מנהלת פרודקט מרקיטינג | מנהל פרודקט מרקיטינג | מנהלת פרודקט מרקיטינג (f.) | — | |
| VP of Marketing | סמנכ"לית שיווק | סמנכ"ל שיווק | סמנכ"לית שיווק (f.) | — | |
| VP of Product Marketing | סמנכ"לית פרודקט מרקיטינג | סמנכ"ל פרודקט מרקיטינג | סמנכ"לית פרודקט מרקיטינג (f.) | — | |

**Repo setup note:** The generic rows above ("Head of [Function]", etc.) are templates. Fill in your specific title rows during setup — add one row per title that appears in your CV.

---

### Company Name Phonetics

> Software product and tool names (HubSpot, Salesforce, Webflow, etc.) always stay in Roman script — they are product proper nouns, not words.

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| {{COMPANY_1}} | {{COMPANY_1_HEBREW}} | {{COMPANY_1_HEBREW}} | — | Add your company phonetics here during setup |
| {{COMPANY_2}} | {{COMPANY_2_HEBREW}} | {{COMPANY_2_HEBREW}} | — | |

*Fill in your company name rows during setup. For each company you worked at: confirm whether a standard Hebrew phonetic form exists in Israeli media, careers pages, or press. If none exists clearly, keep Roman script.*

---

### Date Conversions

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| January / Jan | ינואר / ינו' | ינו' | — | Use abbreviated form in date ranges |
| February / Feb | פברואר / פבר' | פבר' | — | |
| March / Mar | מרץ | מרץ | — | No abbreviation needed — short enough |
| April / Apr | אפריל / אפר' | אפר' | — | |
| May | מאי | מאי | — | |
| June / Jun | יוני / יונ' | יונ' | — | |
| July / Jul | יולי / יול' | יול' | — | |
| August / Aug | אוגוסט / אוג' | אוג' | — | |
| September / Sep | ספטמבר / ספט' | ספט' | — | |
| October / Oct | אוקטובר / אוק' | אוק' | — | |
| November / Nov | נובמבר / נוב' | נוב' | — | |
| December / Dec | דצמבר / דצמ' | דצמ' | — | |
| Present / Current | היום / כיום | היום | — | Both acceptable; היום slightly more common |
| Date range format | — | אפר' 2025 -- היום | — | Same dash syntax as English; Hebrew months substituted |

---

### CV Section Headings

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| SUMMARY | סיכום | ## סיכום | — | |
| SKILLS & EXPERTISE | מיומנויות ומומחיות | ## מיומנויות ומומחיות | — | |
| EXPERIENCE | ניסיון | ## ניסיון | — | |
| CONSULTING | ייעוץ | ## ייעוץ | — | |
| TOOLS | כלים | ## כלים | — | |

---

### Hebrew Cover Letter — Greeting and Style

| Default Language | Hebrew | Standard Phrasing | English-as-is | Notes |
|---|---|---|---|---|
| Dear [Name], | שלום ל[Name]! | שלום ל[Name]! | — | Warm, direct, natural Israeli informal opening |
| Dear [Company] team, | שלום לצוות [Company-in-Hebrew]! | שלום לצוות [Company-in-Hebrew]! | — | Use company name in Hebrew phonetics per company table |
| Signature | — | [Full Name in Hebrew phonetics]{custom-style="Signature Char"} | — | Use candidate's name in Hebrew phonetics from `01-writing-rules.md` |
| Body word count target | — | maximum 250 Hebrew words, no minimum (body only; greeting and sign-off excluded) | — | Hebrew is naturally more concise than English; the ceiling is proportional to the 320-word English ceiling — the upper half mirrors the English 270–320 typical band |
