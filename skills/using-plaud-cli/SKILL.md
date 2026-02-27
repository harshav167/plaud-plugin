---
name: using-plaud-cli
description: Guide for using the plaud CLI to manage Plaud AI recordings, transcripts, summaries, and audio files. Use when the user asks about Plaud recordings, transcription, or wants to interact with their Plaud AI data via the command line.
---

# Plaud CLI Usage Guide

The `plaud` CLI is an unofficial tool for [Plaud AI](https://plaud.ai) — manage recordings, transcripts, summaries, and audio. Uses **ElevenLabs Scribe v2** for transcription. Also includes a built-in MCP server for AI agent integration.

## Install & Run

```bash
# From GitHub (any machine)
uvx --from git+https://github.com/harshav167/plaud plaud --help

# Local development
uv run --directory /path/to/plaud-cli plaud --help
```

## Environment Variables

| Variable | Purpose |
|---|---|
| `PLAUD_TOKEN` | Plaud API bearer token (overrides config file) |
| `ELEVENLABS_API_KEY` | ElevenLabs API key (required for ElevenLabs transcription) |

## Authentication

### Option 1: Email/password (recommended)

```bash
plaud login
```

Prompts for email and password. Token saved to `~/.config/plaud/config.json`.

### Option 2: Token from browser

1. Open https://web.plaud.ai and log in
2. DevTools → Console → `localStorage.getItem('tokenstr')`
3. Copy the value (starts with `bearer eyJ...`)

```bash
plaud login --token "bearer eyJhbGciOi..."
```

### Option 3: Environment variable

```bash
export PLAUD_TOKEN="bearer eyJhbGciOi..."
```

## File ID Resolution

Most commands accept a file identifier in three formats:

| Format | Example | Description |
|---|---|---|
| Row number | `3` | 1-based index from `plaud ls` output |
| Short prefix | `34bc` | Unique prefix of the 32-char hex ID |
| Full ID | `34bc4c6dcabb929062c48f434e9bd287` | Complete file ID |

## Commands Reference

### Account & Setup

```bash
plaud login                           # Interactive login (email/password)
plaud login --token "bearer eyJ..."   # Login with browser token
plaud me                              # Show profile & membership info
plaud config                          # Show config path, email, token, expiry
plaud logout                          # Clear saved token
plaud devices                         # List connected Plaud hardware
plaud tags                            # List file tags/labels
```

### Listing & Browsing

```bash
plaud ls                     # Last 30 recordings
plaud ls -n 50               # Last 50
plaud ls -a                  # All recordings
plaud ls --source desktop    # Desktop recordings only (also: call, note)
plaud ls -t                  # Only transcribed files
plaud ls --untranscribed     # Only files WITHOUT transcripts
plaud ls --json              # Raw JSON for scripting

plaud recent                 # 5 most recently edited files
plaud search "meeting"       # Search by title

plaud show 34bc              # File metadata, content tabs, AI headline/keywords
plaud open 34bc              # Open in web browser
```

### Content Retrieval

```bash
# Transcription (ElevenLabs Scribe v2 — default)
plaud transcribe 34bc                  # ElevenLabs transcription
plaud transcribe 34bc --plaud          # Use Plaud's built-in transcript instead
plaud transcribe 34bc --no-cache       # Force re-transcription
plaud transcribe 34bc -l fra           # Transcribe in French
plaud transcribe 34bc --plain          # Plain text (no timestamps)
plaud transcribe 34bc --raw            # Raw JSON output
plaud transcribe 34bc -o out.json      # Save to file

# Batch transcription (concurrent)
plaud transcribe 34bc 79634c 58ab2e    # Multiple files at once
plaud transcribe --all                 # All untranscribed recordings
plaud transcribe --all -j 10           # With 10 concurrent workers (default: 5)
plaud transcribe --all -o ./exports/   # Save each as {file_id}.json in directory

# Summary & Notes
plaud summary 34bc                     # AI-generated summary (markdown)
plaud notes 34bc                       # Meeting notes
```

### Export & Download

```bash
plaud download 34bc                    # Download everything for a file
plaud audio 34bc                       # Download MP3 audio
plaud fetch-all                        # Bulk export all transcribed files
plaud fetch-all --include-audio        # Include MP3 audio files
```

### AI Generation

```bash
plaud generate 34bc                    # Trigger AI transcription + summary
plaud generate 34bc --wait             # Wait for processing to complete
plaud languages                        # List supported transcription languages
plaud status                           # Check AI processing queue
```

### MCP Server

```bash
plaud mcp                             # Start MCP stdio server
```

For Claude Desktop / MCP hosts, see the `using-plaud-mcp` skill.

### Global Flags

| Flag | Description |
|---|---|
| `--version` / `-V` | Show version number and exit |
| `--help` | Show help text and exit |

Many commands support `--json` for raw JSON output and `-o` for saving to file.

## Transcript Caching

ElevenLabs transcripts are cached at `~/.cache/plaud/transcripts/{file_id}_{lang}.json` (permissions `0600`). Cached transcripts return instantly on subsequent calls. Use `--no-cache` to force re-transcription.

First transcription of a recording takes 60-120 seconds (download audio + ElevenLabs API). All subsequent calls return from cache instantly.

## Common Workflows

### Transcribe a specific recording

```bash
plaud ls                          # Find the recording
plaud transcribe 3                # Transcribe by row number
plaud transcribe 3 --plain        # Plain text for piping
```

### Batch transcribe all recordings

```bash
plaud transcribe --all                    # Transcribe everything not yet cached
plaud transcribe --all -j 10 -o ./out/    # 10 concurrent, save to directory
```

### Bulk export all recordings

```bash
plaud fetch-all --include-audio
```

### Pipe transcript to clipboard

```bash
plaud transcribe 34bc --plain | pbcopy
```

### Get raw JSON for scripting

```bash
plaud ls --json | jq '.[] | select(.has_transcript) | .title'
```

## Architecture

- **Plaud** handles recording (hardware), file storage, AI summaries, and meeting notes
- **ElevenLabs Scribe v2** handles transcription (speaker diarization, higher accuracy)
- **Transcripts cached locally** at `~/.cache/plaud/transcripts/`
- Config stored at `~/.config/plaud/config.json`
- MCP server runs via `plaud mcp` subcommand over stdio transport

## Limitations

- ElevenLabs API key required for transcription (use `--plaud` flag for built-in fallback)
- Search is client-side substring matching on titles only
- Limited write operations — cannot rename files, move to trash, or create tags
- Presigned S3 URLs expire in 5 minutes
