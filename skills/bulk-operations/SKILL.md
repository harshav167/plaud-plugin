---
name: bulk-operations
description: Guide for bulk ingestion and batch processing of Plaud recordings into the memory search index. Use when the user wants to index multiple recordings, set up auto-ingestion, check job progress, or do batch operations.
---

# Bulk Operations

Batch ingestion of Plaud recordings into the memory search index (Cognee with Qdrant vectors + Neo4j graph). Handles transcription, chunking, embedding, and graph construction at scale.

## SAFETY PROTOCOL

1. **ALWAYS run `dry_run=true` first** for any bulk operation
2. **Review the cost estimate** with the user before proceeding
3. **Prefer `source="cache"`** (free) over `source="all"` (costs ElevenLabs credits)
4. **Use `since` to limit scope** when possible
5. **Track progress** with `job_id` returned from initial call

## Tools

### `memory_ingest`

Main bulk ingestion tool. Transcribes, chunks, embeds, and indexes recordings into the memory search pipeline.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `source` | `"all"` \| `"cache"` | `"all"` | `"all"`: transcribe missing (COSTS CREDITS). `"cache"`: cached only (FREE) |
| `mode` | `"once"` \| `"auto"` | `"once"` | `"once"`: single run. `"auto"`: background poller |
| `action` | string | null | Required when `mode="auto"`: `"start"`, `"stop"`, or `"status"` |
| `file_ref` | string | null | Ingest a single recording only |
| `since` | string | null | Only recordings after date (`"7d"`, `"30d"`, `"2026-01-01"`) |
| `language` | string | `"eng"` | ElevenLabs 3-letter language code |
| `dry_run` | bool | false | Show cost estimate without processing |
| `job_id` | string | null | Poll status of a running job |

## Usage Patterns

```
memory_ingest(dry_run=true)                    # Cost estimate for all recordings
memory_ingest(source="cache")                  # Index only cached transcripts (FREE)
memory_ingest(source="all")                    # Transcribe + index everything (COSTS CREDITS)
memory_ingest(file_ref="abc123")               # Ingest a single recording
memory_ingest(since="7d")                      # Only recent recordings
memory_ingest(since="7d", dry_run=true)        # Cost estimate for recent only
memory_ingest(job_id="abc-123")                # Poll job progress
memory_ingest(mode="auto", action="start")     # Start background auto-poller
memory_ingest(mode="auto", action="status")    # Check auto-poller status
memory_ingest(mode="auto", action="stop")      # Stop auto-poller
```

## Workflows

### "Index all my recordings"
1. `memory_ingest(dry_run=true)` -- review cost estimate
2. Present estimate to user, get confirmation
3. If user approves: `memory_ingest(source="all")`
4. Track with returned `job_id`: `memory_ingest(job_id="<id>")`

### "Index only what's already transcribed (free)"
1. `memory_ingest(source="cache")` -- no ElevenLabs cost
2. Track with `job_id`

### "Index just the last week"
1. `memory_ingest(since="7d", dry_run=true)` -- estimate
2. `memory_ingest(since="7d")` -- execute

### "Index a single recording"
1. `memory_ingest(file_ref="<id>")` -- transcribes + indexes one recording

### "Set up continuous ingestion"
1. Explain: auto-poller will continuously monitor for new recordings and transcribe them (costs credits for each new recording)
2. Get user confirmation
3. `memory_ingest(mode="auto", action="start")`
4. Check status: `memory_ingest(mode="auto", action="status")`
5. Stop when done: `memory_ingest(mode="auto", action="stop")`

### "Check job progress"
1. `memory_ingest(job_id="<id>")` -- returns progress, count, errors

## source="all" vs source="cache"

| | `source="all"` | `source="cache"` |
|---|---|---|
| Cost | ElevenLabs API credits per uncached recording | Free |
| Coverage | All recordings (transcribes missing ones) | Only already-transcribed recordings |
| Speed | Slower (transcription per recording) | Fast (skip transcription step) |
| Use when | User wants everything indexed | User wants to avoid cost |

## Anti-Patterns (NEVER DO)

- **Never run `memory_ingest(source="all")` without `dry_run=true` first** -- always estimate cost
- **Never start auto-poller without explaining** that it will continuously transcribe new recordings at cost
- **Never ignore `job_id`** -- always poll for completion to confirm success
- **Never run bulk ingestion without user confirmation** -- cost can be significant
- **Never assume ingestion succeeded** -- check `job_id` status and verify with `memory_search`
