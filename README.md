# Plaud Plugin for Claude Code

Manage Plaud AI recordings, transcripts, summaries, and memory search directly from Claude Code.

## Quick Start

1. Install as a Claude Code plugin (see [Installation](#installation))
2. Set your server URL in `.mcp.json`
3. On first use, Claude will open a GitHub OAuth flow — authorize once and you're connected.
4. Try these commands:
   - `/status` -- Daily briefing
   - `/ls` -- Browse recordings
   - `/transcribe <ref>` -- Get transcript
   - `/search <query>` -- Search recordings + memory

## Installation

```bash
# Clone into your Claude Code plugins directory
git clone https://github.com/harshav167/plaud-plugin ~/.claude/plugins/plaud
```

Then edit `.mcp.json` in the plugin directory to point to your Plaud MCP server:

```json
{
  "mcpServers": {
    "plaud": {
      "type": "http",
      "url": "https://your-server.example.com/mcp"
    }
  }
}
```

Set the `PLAUD_MCP_URL` environment variable for the session-check hook:

```bash
export PLAUD_MCP_URL="https://your-server.example.com/mcp"
```

## Authentication

The server uses **GitHub OAuth** — no manual tokens or env vars needed. Claude handles the OAuth flow automatically when you first connect to the MCP server.

## What's Included

### Agent
- **Aria** -- Recording assistant with cost awareness, dual-path search, and memory pipeline intelligence

### Commands (8)

| Command | Description |
|---------|-------------|
| `/status` | Daily briefing -- recent recordings, index health, backlog |
| `/ls` | Browse and filter recordings |
| `/transcribe` | Get transcript (checks cache first) |
| `/search` | Dual-path search (metadata + semantic memory) |
| `/summary` | View AI summary or meeting notes |
| `/download` | Get audio download URL |
| `/fetch-all` | Bulk export recordings |
| `/generate` | Trigger Plaud AI processing |

### Prompts (4)

| Prompt | Purpose |
|--------|---------|
| `daily_briefing` | Status overview — recent recordings, queue, memory |
| `analyze_transcript` | Deep analysis of a recording |
| `search_memory` | Guided dual-path search |
| `bulk_summary` | Summarize multiple recordings |

### Skills (6)

| Skill | Scope |
|-------|-------|
| recording-search | Find and browse recordings |
| memory-search | Semantic search across transcripts |
| transcription | ElevenLabs transcription with cost awareness |
| bulk-operations | Batch ingestion and auto-polling |
| using-plaud-mcp | Quick-start MCP tool reference |
| using-plaud-cli | CLI usage guide |

> **Skills as Resources:** The MCP server exposes all 6 skills as MCP resources (12 total: `SKILL.md` + `_manifest` each). Any MCP client can discover and read skill documentation without installing the plugin.

### Hooks
- **Cost safety** -- Warns before credit-consuming operations (transcribe, bulk ingest)
- **Auth check** -- Verifies the MCP server is reachable on first tool call

## MCP Tools (11)

All tools are prefixed `mcp__plaud__`:

| Tool | Purpose | Cost |
|------|---------|------|
| find_recordings | Browse/filter recordings | Free |
| get_recording | Recording metadata | Free |
| get_audio_url | Download URL (5min expiry) | Free |
| transcribe | ElevenLabs transcript | Credits* |
| get_content | Summary/notes | Free |
| trigger_processing | Plaud AI processing | Free |
| get_account_info | Account info | Free |
| get_processing_status | Queue status | Free |
| list_languages | Language codes | Free |
| memory_search | Search indexed transcripts | Free |
| memory_ingest | Bulk index recordings | Credits** |

\*Cached transcripts return free. \*\*With `source="all"` only; `source="cache"` is free.

**Session state:** Tools accepting `file_ref` support persistent row-number resolution across calls — call `find_recordings` once, then use row numbers in subsequent `transcribe`, `get_content`, etc. calls within the same session.

**Elicitation:** `transcribe` and `memory_ingest(source="all")` prompt for confirmation before consuming credits. Older MCP clients that don't support elicitation skip the prompt and proceed directly.

## Server Setup

This plugin connects to a [plaud-cli](https://github.com/harshav167/plaud-cli) MCP server. See that repo for server deployment instructions.

## Architecture

```
Claude Code -> Plugin (skills, commands, hooks, agent)
    -> MCP server via HTTPS + GitHub OAuth
        -> Your Plaud MCP server (FastMCP)
            Features: 11 tools, 4 prompts, 12 resources
            Session state (row-number persistence)
            Elicitation (credit-consuming confirmations)
            Skills Provider (plugin skills as MCP resources)
            -> Plaud S3 (recordings)
            -> RustFS (audio + transcript cache)
            -> ElevenLabs (transcription)
            -> Cognee (Qdrant vectors + Neo4j graph)
```

## License

MIT
