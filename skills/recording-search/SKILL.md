---
name: recording-search
description: Guide for finding and browsing Plaud recordings using metadata filters. Use when the user asks to list, find, filter, or browse their recordings by date, source type, title, or transcription status.
---

# Recording Search

Find and browse Plaud AI recordings by metadata: title, date, source type, and transcription status.

## Tools

### `find_recordings`

Browse and filter recordings. Returns a list with metadata previews.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | null | Partial title match (case-insensitive) |
| `source` | `"call"` \| `"meeting"` \| `"desktop"` | null | Filter by recording type |
| `transcribed` | bool | null | Filter by transcript availability |
| `since` | string | null | Relative (`"7d"`, `"30d"`) or absolute (`"2026-01-15"`) |
| `until` | string | null | Same format as `since` |
| `limit` | int | 20 | Max results (capped at 100) |

**Response fields per recording:**

| Field | Description |
|-------|-------------|
| `id` | 32-char hex file ID (use for all other tools) |
| `title` | Recording title |
| `source` | `call`, `meeting`, or `desktop` |
| `duration` | Human-readable (`"1h 52m"`) |
| `recorded` | Human-readable date |
| `has_transcript` | Whether transcript exists |
| `has_summary` | Whether AI summary exists |

### `get_recording`

Full metadata for a single recording.

| Parameter | Type | Description |
|-----------|------|-------------|
| `file_ref` | string | **Required.** File ID, short prefix, or row number |

Returns all `find_recordings` fields plus `available_content`, `transcript_cached`, `audio_cached`, `indexed` status, `ai_headline`, and `ai_keywords`.

### `get_audio_url`

Get a presigned download URL for the recording audio.

| Parameter | Type | Description |
|-----------|------|-------------|
| `file_ref` | string | **Required.** File ID, short prefix, or row number |

Returns a presigned S3 URL valid ~5 minutes. Present to user immediately -- it expires fast.

## File Reference Formats

All tools accepting `file_ref` support three formats:

| Format | Example | Description |
|--------|---------|-------------|
| Full ID | `4f757af256ecba4fab502739c122dc78` | Exact 32-char hex match |
| Short prefix | `4f75` | Unambiguous prefix of any file ID |
| Row number | `3` | 1-based index from most recent `find_recordings` |

**Best practice:** Call `find_recordings` first, then use the `id` field directly.

## Examples

Browse recent recordings:
```
find_recordings(limit=10)
```

Find meetings from the last week:
```
find_recordings(source="meeting", since="7d")
```

Find untranscribed recordings:
```
find_recordings(transcribed=false)
```

Search by title keyword:
```
find_recordings(query="standup")
```

Check a recording's full status (cached, indexed):
```
get_recording(file_ref="4f75")
```

Get audio download link:
```
get_audio_url(file_ref="4f75")
```

## Workflows

### "Show me my recent recordings"
1. `find_recordings(limit=10)`
2. Present as table: date, title, duration, transcript/summary status

### "Find my meeting from last Tuesday"
1. `find_recordings(source="meeting", since="7d")`
2. If multiple results, ask user to pick
3. `get_recording(file_ref="<id>")` for full details

### "Get the audio for recording X"
1. `get_audio_url(file_ref="<id>")`
2. Present URL immediately (expires in ~5 minutes)

## Tips

- Combine filters for precision: `source="call"` + `since="30d"` + `query="client"`
- Use `get_recording` to check `transcript_cached` and `indexed` status before transcribing or searching
- Every response includes a `next_steps` field guiding your next action -- follow it
