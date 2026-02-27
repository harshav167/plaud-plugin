---
description: Bulk review and export transcripts, summaries, and notes
argument-hint: "[limit]"
---

Bulk review recordings and export their content via MCP tools.

1. Call `find_recordings(limit=100)` to get all recordings.
2. Present an overview:
   - Total recordings found
   - Transcribed vs untranscribed count
   - Table: # | Title | Date | Transcribed | Has Summary

3. Ask what to export: "What would you like to retrieve?"
   - **Transcripts only** — for each transcribed recording, call `transcribe(file_ref)`
   - **Summaries only** — for each recording with summaries, call `get_content(file_ref, content_type="summary")`
   - **Everything** — transcripts + summaries + notes for all available recordings

4. **Cost warning**: If any selected recordings lack cached transcripts, warn:
   "N recordings have no cached transcript. Transcribing them will use ElevenLabs credits. Include them or skip?"

5. Process selected recordings, reporting progress:
   - "Processing 1/N: [title]..."
   - "Done: X transcripts, Y summaries, Z notes retrieved"

6. Present all retrieved content organized by recording.
