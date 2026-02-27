---
description: Transcribe a Plaud recording via ElevenLabs Scribe
argument-hint: "<file ref> [language]"
---

Transcribe a Plaud recording. The file ref can be a row number from `/ls`, a short hex prefix, or a full 32-char ID.

1. Call `get_recording(file_ref)` to fetch recording metadata.
2. Check the `transcript_cached` field in the response:
   - **If cached** → call `transcribe(file_ref)` immediately. This is free (uses cached result).
   - **If NOT cached** → warn the user: "This recording has no cached transcript. Transcribing will use ElevenLabs Scribe credits. Proceed?" Wait for confirmation before continuing.
3. On confirmation (or if cached), call `transcribe(file_ref)`. If the user specified a language, pass `language=<code>` (e.g., `eng`, `fra`, `jpn`).
4. Present the transcript with speaker diarization labels (Speaker 1, Speaker 2, etc.) and timestamps.
5. Offer next actions:
   - "/summary [ref] — view AI summary"
   - "/search <query> — search across all transcripts"
   - "Index this transcript into memory? (call `memory_ingest`)"
