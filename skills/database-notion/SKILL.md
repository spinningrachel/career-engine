---
name: database-notion
description: The Notion adapter — the complete mechanics for every database operation the pipeline performs against a Notion tracker (schema read, the A1→A2→B query ladder, view discovery, and property/page-body writeback). MANDATORY load whenever `database_backend` is `notion` (the default) and a skill needs to read from or write to the database. The pipeline skills speak in generic operations (query the queue, fetch a record, write a field, resolve a view); this skill is the only place those operations are spelled out in Notion-specific tool calls.
---

# Database adapter — Notion

This is the **Notion adapter**. It owns every Notion-specific mechanic in one place, so the pipeline skills can speak in backend-neutral operations and a future backend can be added as a sibling adapter without touching them.

**When to load (mandatory, conditional):** any time a pipeline skill needs to read from or write to the database **and** `database_backend` resolves to `notion` (the default; from `${CAREER_DATA}/references/pipeline-preferences.json`). The caller names the generic operation and the parameters (target status, properties to read, fields to write); this skill provides the *how*. If `database_backend` is ever something else, the caller loads that backend's adapter instead — never this one.

**Database ID:** `$NOTION_DATABASE_ID`, resolved from config (`database_id`, legacy `notion_database_id`) by the calling skill. Any `{{NOTION_DATABASE_ID}}` token in plugin text is a literal placeholder, not a value. `$NOTION_DATABASE_ID`/`$NOTION_NEEDS_EDITING_VIEW_URL` are this adapter's internal variable names.

**Generic operation → Notion mechanic:**

| Generic operation (what callers say) | Notion mechanic (below) |
|---|---|
| Read the schema reference | §1 Schema read |
| Query the queue for `Status = <target>` | §2 Read ladder (A1 → A2 → B) |
| Resolve a view by name | §3 View discovery |
| Fetch a record's full properties | §1/§2 per-page `notion-fetch` |
| Write a field / write-if-empty | §4 Writeback |
| Write the page body | §4 Page-body write |

---

## §1 — Schema read (always first)

Run `notion-fetch` on the configured database ID:

```
notion-fetch id="{{NOTION_DATABASE_ID}}"
```

If the fetch fails (tool error, empty response) or the response contains no `CREATE TABLE` block, **stop and report** — do not proceed without a schema and do not improvise one.

Extract the SQLite `CREATE TABLE` block: this is the **schema reference** for the run — the authoritative list of property names and valid select-option values. Keep it in context.

**Use it for every write.** When writing a select field, look up the valid options in the SQLite comment for that column (e.g. `-- one of ["Yes", "Remote-maybe", "No"]`) and write the exact string from the schema. Never hardcode select-option values. If an agent returns a value that doesn't match a schema option, map it to the closest option using the schema as the authority. Pass the SQLite block to any spawned agent that writes select values (e.g. the career coach) as a "Notion schema reference" section.

This same `notion-fetch` response also carries the `<data-sources>` and `<views>` blocks used in §2/§3.

---

## §2 — Read ladder: query the queue (A1 → A2 → B)

The caller supplies the **target status** (e.g. `Hold`, `Needs Editing`) and the properties it needs. Use **Path A1** (`ntn` CLI) when its gate passes; fall to **Path A2** (`notionApi`) when A1 is unavailable; use **Path B** (standard connector) when both A rungs are absent or unusable. **Falling down the ladder is sanctioned routing, never a reportable failure.**

### Path A1 — `ntn` CLI structured query (preferred where available)

The official Notion CLI returns the same structured JSON as the API, through Bash — so the result is trimmed in the shell and only the needed fields enter context. The **gate**, not the environment label, decides. The gate never installs the CLI and never prompts for credentials mid-run. In headless/sandboxed shells auth comes from `NOTION_API_TOKEN` (or `NOTION_KEYRING=0` file auth); if neither is present `ntn whoami` fails — the gate working as designed.

Gate (both must pass):
```bash
command -v ntn >/dev/null 2>&1 && ntn whoami >/dev/null 2>&1 && echo "Path A1 available"
```

Resolve the data-source ID once, then query:
```bash
ntn api /v1/databases/{{NOTION_DATABASE_ID}}   # read data_sources[0].id from the response
ntn datasources query <data-source-id> \
  --filter '{"property":"Status","status":{"equals":"<target status>"}}' \
  --limit 100 --json
```

Trim the JSON in the shell (`python3`/`jq`) to each row's page `id` plus the named properties — always by property name, never column position. If `has_more` is true, continue with `--start-cursor` until exhausted. `ntn pages get <page_id>` returns a full single row (properties + page body markdown) in one call.

Project at the source so bulk payloads never arrive: repeat `filter_properties==<property_id>` on a direct query call —
```bash
ntn api /v1/data_sources/<data-source-id>/query 'filter_properties==title' 'filter_properties==<property_id>' \
  -X POST -d '{"filter": {...}, "page_size": 100}'
```
— returns only the named properties (~3KB projected vs ~120KB unprojected). `filter_properties` takes property **IDs** read from the schema, not names.

`ntn api` is httpie-style: path given directly, no verb words (`ntn api /v1/pages/<page_id>`; method inferred, override `-X PATCH -d '{...}'`); query params are `name==value`. Verify rather than guess: `ntn api ls`, `ntn api <path> --docs`, `ntn api <path> --spec`.

If an A1 call errors after the gate passed (auth revoked, network), fall to A2 for the rest of the run.

### Path A2 — `notionApi` structured query

`notionApi` returns structured JSON keyed by property name — no column alignment to get wrong.

The `notionApi` tools are deferred; load the schema first:
```
ToolSearch query="select:notionApi__API-query-data-source"
```
If ToolSearch returns a schema, proceed. If nothing, try the full name `mcp__notionApi__API-query-data-source` directly (deferred tools are callable by full name). If the direct call returns **tool-not-found**, the server isn't connected — **execute Path B immediately**. If it returns **any other error** (401, Enterprise-gated, malformed, timeout), treat the server as unusable — **execute Path B immediately**. Neither is a reportable failure. Do NOT attempt `notion-search`, `notion-fetch` on a view URL, or any improvised route — the next action is always `notion-fetch id="$NOTION_DATABASE_ID"` (Path B step 1).

Call `API-query-data-source` (full name `mcp__notionApi__API-query-data-source`) with: database ID `$NOTION_DATABASE_ID`; filter `{"property": "Status", "status": {"equals": "<target status>"}}`; page_size 100. Returns a JSON array of page objects, each with `id` and a named `properties` object — read by name, not position.

### Path B — connector view query for discovery, per-page fetch for properties

Only when the `notionApi` server is absent or unusable. **Start with step 1 — `notion-fetch id="$NOTION_DATABASE_ID"` first.** Do not call `notion-fetch` on any other URL, do not call `notion-search`, and complete steps 1–4 in order. `notion-query-database-view` runs a *view's own saved filter/sort* and returns a *rendered table*. **Two hard constraints (R-39):** it accepts **no ad-hoc `filter`** (any filter is silently ignored) and requires a real **view URL** (`https://www.notion.so/<DB_ID>?v=<VIEW_ID>`), never the bare database URL. The rendered table is also prone to column misalignment (R-1: 17 companies, 16 status tags) and shows only visible columns, so it is **discovery only**; property values are always read per page. **A misaligned rendered table must never be parsed** — and in Path B no rendered table is ever parsed for property values, aligned or not.

1. **Resolve the view URL by name — ONE fetch is enough** (verified against the live `notion-fetch`, 2026-06). Call `notion-fetch id="$NOTION_DATABASE_ID"`. **This single response contains BOTH:** a `<data-sources>` block (each `<data-source url="{{collection://UUID}}">` is the data-source id used by `API-query-data-source`) **and** a `<views>` block listing every view as `<view url="{{view://UUID-with-dashes}}">` with config JSON including `"name":"<view name>"`.
   - **Find the view in that same response:** scan `<views>` for the one whose JSON `"name"` matches the target; strip the `{{...}}` wrapper (all URLs are wrapped) to get `view://<UUID-with-dashes>`.
   - **Do NOT fetch the `collection://` URL to find views** — a `notion-fetch` on a `collection://` returns **only** the data-source schema (properties + SQLite table), with **no `<views>` block**. Views live only in the database fetch. (Fetching `collection://` is for reading the schema.)
   - **Build the query URL:** take the view UUID, **remove all dashes**, construct `https://www.notion.so/<DB_ID_NO_DASHES>?v=<VIEW_ID_NO_DASHES>`. View IDs change when views are reorganised, so the by-name lookup is always the source of truth.
2. Call `notion-query-database-view` with `view_url` = that URL and **no other arguments**. The view already restricts to the target status; do not construct a filter.
3. **Discovery only.** Extract page IDs/links from the result (unambiguous even in a misaligned table). Read no property value from the rendered table.
4. **Fetch full properties per page:** `notion-fetch id="<page_id>"` on each candidate page; read its complete property set from the structured response. Discard pages whose Status doesn't match. Every downstream read uses these per-page property sets, never the rendered table.

---

## §3 — View discovery (resolve a view by name)

This is Path B step 1 above, also used wherever a skill needs a view URL: one `notion-fetch` on the DB id → read the `<views>` block → match `"name"` → strip `{{...}}` → dash-remove → `?v=` URL. **Fast path (skip the fetch when a URL is already known):** the calling skill passes its pre-resolved view URL (e.g. `$NOTION_INTERESTED_VIEW_URL`, `$NOTION_HOLD_VIEW_URL`, `$NOTION_NEEDS_EDITING_VIEW_URL`, etc., resolved from `pipeline-preferences.json`). When the URL is non-empty and not stale, proceed directly to step 2 (`notion-query-database-view`). When the URL is empty, stale, or the query fails, fall back to this by-name lookup — it is always the fallback because saved URLs break when views are reorganised. **Never fetch the `collection://` URL to find a view.**

---

## §4 — Writeback (write a field / write-if-empty / page body)

**Write to the EXISTING property of that exact name — never create a property or a numbered variant** (the "Strategy 1" bug: an agent that couldn't write `Strategy` cleanly made a duplicate). If a target property is missing, rejects the write, or its type doesn't match the schema (§1), **stop and report** — never invent a field.

**Write-only-to-empty** (where the caller specifies it): read the current value first; if populated (including `N/A`), skip — do not overwrite. The caller names any always-overwrite exceptions (e.g. `JD proof`, `Strategy`).

**Mechanism:**
- On Path A1 (the `ntn` gate passed), writes may go through `ntn api /v1/pages/<page_id> -X PATCH -d '{"properties": {...}}'` — same write-only-to-empty rule, same parallelism.
- Otherwise use the connector: `notion-update-page` on the page ID, properties keyed by exact name, select values exactly matching the schema options.

**Write to properties, not the page body**, except where a caller explicitly sanctions a page-body block (e.g. the intake outreach map). For a sanctioned page-body write: use `notion-update-page`; prepend above existing content separated by `---`; never delete existing content.

---

## Rules for all paths

- **Never create, update, or modify Notion views.** Do not call `create-database-view`, `update-database-view`, or any equivalent — not as a workaround, not to filter, not to fix misalignment.
- **On Paths A2 and B, do not Bash/Grep the query result** — process it from the tool response in context. On Path A1 the result arrives through the shell and trimming it there (`python3`/`jq`) is the sanctioned mechanism.
- Process only rows matching the target status; discard non-matching in memory and log a warning.
- **All paths fail → stop and report.** Never treat a failed query as zero results, and **never fall back to `notion-search` or any semantic/keyword search to enumerate queue rows (R-39)** — it is relevance-ranked and capped, cannot enumerate the queue, and silently misses roles, producing a false "no roles" when roles exist.
