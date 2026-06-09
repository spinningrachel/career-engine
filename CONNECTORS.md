# Connectors

## How tool references work

Plugin agents reference external services by MCP tool calls. This file documents which services this plugin connects to, what category each serves, and what alternatives exist in each category.

## Plugin path convention

Agents and skills in this plugin reference internal files using `${CLAUDE_PLUGIN_ROOT}` rather than hardcoded absolute paths. Claude Code resolves this variable to the plugin's installation root at runtime, so paths survive session ID changes, reinstalls, and moving the plugin folder.

- Reference files: `${CLAUDE_PLUGIN_ROOT}/references/`
- Skills: `${CLAUDE_PLUGIN_ROOT}/skills/`

Do not hardcode the full absolute path (e.g., `/Users/.../local-agent-mode-sessions/.../rpm/plugin_.../`) in any agent or skill file. If you add a new agent or skill that needs to read reference files, use `${CLAUDE_PLUGIN_ROOT}/references/` and point to `REFERENCES.md` as the index.

## Connectors for this plugin

| Category | In use | Included in .mcp.json | Alternatives |
|---|---|---|---|
| Job tracking | Notion | Yes | CSV/Google Sheets (setup agent configures either) |
| File storage | iCloud (local path via Desktop Commander) | n/a — filesystem access, not MCP | Any local folder; setup agent sets the output path |
| File system | Desktop Commander | Yes | MacOS-MCP |
| Job search | Indeed, Dice, ZipRecruiter | Yes | LinkedIn |
| Document conversion | pandoc (CLI tool) | n/a — not an MCP server | — |
| LinkedIn research | stickerdaniel/linkedin-mcp-server | No (user-installed) | — |

### LinkedIn MCP (stickerdaniel/linkedin-mcp-server) — Optional

When configured, the employment-coach agent uses this MCP for company and hiring manager research. Install it separately — it is not bundled with the plugin.

**Install:**
```bash
uvx linkedin-scraper-mcp@latest --login
```

**Configure in Claude Code settings** with server name `linkedin-mcp`. The employment coach will then have access to:
- `mcp__linkedin-mcp__get_company_profile` — company about page, posts, jobs
- `mcp__linkedin-mcp__get_company_employees` — employee demographics and profiles
- `mcp__linkedin-mcp__get_person_profile` — individual profile with experience, education
- `mcp__linkedin-mcp__search_people` — search by keywords, company, connection degree

The coach falls back to WebSearch if this MCP is not connected.

## Notion setup

The plugin expects a specific database schema. The fastest way to get started:

**[Duplicate the Notion template →](https://certain-espadrille-82d.notion.site/d8606ae1fb9282f4872381cd819c1abd?v=d2006ae1fb928355a14388715d96a782)**

After duplicating:
1. Copy the database ID from the URL (`notion.so/<workspace>/<DATABASE_ID>?v=...`)
2. Run `/cv-campaign:setup` — it will ask for the ID and write it to the plugin config

## CSV / Google Sheets alternative

If you don't use Notion, the setup agent can configure a CSV-based job tracking workflow instead. During setup, choose "CSV / spreadsheet" when prompted and provide the file path or Google Sheets URL. The pipeline will read from and write to the spreadsheet instead of Notion.
