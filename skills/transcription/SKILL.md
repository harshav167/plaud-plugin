---
name: transcription
description: Guide for transcribing Plaud recordings using ElevenLabs Scribe v2. Use when the user wants a transcript, asks to transcribe a recording, or needs speaker-diarized text from their recordings. IMPORTANT -- transcription costs API credits.
---

# Transcription

Transcribe Plaud recordings using ElevenLabs Scribe v2 with speaker diarization, or trigger Plaud's built-in (free, lower quality) processing.

## COST WARNING

`transcribe()` calls ElevenLabs API and costs real credits. Before transcribing:

1. **Check cache first:** `get_recording(file_ref)` -- if `transcript_cached: true`, the call is FREE (returns from cache)
2. **If not cached:** warn the user before proceeding
3. **For bulk:** use `memory_ingest(dry_run=true)` to estimate cost first (see bulk-operations skill)

## Tools

### `transcribe`

High-quality transcription via ElevenLabs Scribe v2. Synchronous -- returns full transcript in one call.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `file_ref` | string | null | Plaud recording ID, prefix, or row number |
| `file_path` | string | null | Local audio file path (MP3, WAV, M4A, AAC, OGG, FLAC) |
| `language` | string | `"eng"` | 3-letter ISO 639-3 code |

Provide `file_ref` OR `file_path`, never both.

**Response:** `{ "status": "complete", "text": "...", "speakers": [...], "language": "eng" }`

**Timing:** Cached transcripts return instantly. Uncached recordings take 60-120s (downloads audio, calls ElevenLabs, caches result). No polling needed.

### `trigger_processing`

Trigger Plaud's built-in server-side transcription + summarization. Free but lower quality.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `file_ref` | string | **required** | File ID, prefix, or row number |
| `language` | string | `"en"` | 2-letter Plaud code (NOT 3-letter ElevenLabs) |
| `diarization` | bool | true | Enable speaker identification |

Idempotent -- safe to call on already-processed files. Processing takes 2-5 minutes on Plaud servers.

### `get_processing_status`

Check Plaud's AI processing queue. No parameters. Returns list of files currently being processed with status.

### `list_languages`

Show all supported transcription languages with codes. No parameters.

## ElevenLabs vs Plaud Comparison

| | ElevenLabs (`transcribe`) | Plaud (`trigger_processing`) |
|---|---|---|
| Quality | High accuracy, speaker diarization | Basic |
| Cost | ElevenLabs API credits | Free |
| Speed | ~30s-2min per recording | 2-5 minutes |
| Language codes | 3-letter (`eng`, `fra`, `deu`) | 2-letter (`en`, `fr`, `de`) |
| Caching | RustFS local cache | Plaud servers |
| Local files | Supported (`file_path`) | Not supported |

**Common ElevenLabs language codes:** `eng` (English), `fra` (French), `deu` (German), `jpn` (Japanese), `zho` (Chinese), `spa` (Spanish), `kor` (Korean)

## Pipeline

```
Plaud S3 --> RustFS audio cache --> ElevenLabs Scribe v2 --> RustFS transcript cache --> Cognee ingestion
```

## Workflows

### "Transcribe recording X"
1. `get_recording(file_ref="<id>")` -- check `transcript_cached`
2. If cached: `transcribe(file_ref="<id>")` -- instant, free
3. If not cached: warn user about cost, then `transcribe(file_ref="<id>")`
4. Format speaker segments with timestamps

### "Transcribe a local audio file"
1. `transcribe(file_path="/path/to/recording.mp3")`
2. No Plaud account needed -- uses ElevenLabs directly

### "Process recording with Plaud (free)"
1. `trigger_processing(file_ref="<id>", language="en")`
2. `get_processing_status()` -- confirm queued
3. Tell user it takes 2-5 minutes
4. Use `get_content(file_ref, content_type="summary")` after processing completes

### "What languages are supported?"
1. `list_languages()` -- returns full list with codes for both systems

## Anti-Patterns (NEVER DO)

- **Never call `transcribe()` without checking cache first** -- always `get_recording` first to avoid unnecessary cost
- **Never mix language code formats** -- ElevenLabs uses 3-letter (`eng`), Plaud uses 2-letter (`en`)
- **Never use `trigger_processing` for local files** -- it only works with Plaud recordings
- **Never bulk-transcribe without dry_run** -- use the bulk-operations skill with `dry_run=true` first
