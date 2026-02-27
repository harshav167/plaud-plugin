---
description: View the AI-generated summary or notes for a recording
argument-hint: "<file ref>"
---

Display the AI-generated summary and notes for a Plaud recording.

1. Call `get_recording(file_ref)` to fetch metadata and check `available_content`.
2. Based on what content is available:
   - **Summary available** → call `get_content(file_ref, content_type="summary")` and display it.
   - **Notes available** → call `get_content(file_ref, content_type="notes")` and display them.
   - **Both available** → retrieve and display both, with clear section headers.
   - **Neither available** → tell the user: "No summary or notes found for this recording. Want me to trigger AI processing?" If confirmed, call `trigger_processing(file_ref)` and inform them it takes 2-5 minutes.
3. Offer next actions:
   - "/transcribe [ref] — view full transcript"
   - "/download [ref] — get audio URL"
   - "/generate [ref] — re-process with Plaud AI"
