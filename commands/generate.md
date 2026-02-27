---
description: Trigger Plaud AI transcription and summarization
argument-hint: "<file ref> [language]"
---

Trigger server-side AI processing (transcription + summarization) for a Plaud recording.

1. Call `get_recording(file_ref)` to check current processing state.
2. If the recording already has a summary:
   - Show a preview of the existing summary.
   - Ask: "This recording is already processed. Re-process it? (This will regenerate the transcript and summary.)"
   - If declined, stop here.
3. Call `trigger_processing(file_ref)`. If the user specified a language, pass `language=<code>`.
4. Report: "Processing started for [title]. This typically takes 2-5 minutes."
5. Offer next actions:
   - "Check status with `get_processing_status(file_ref)`"
   - "Continue working — I'll check status when you ask"
   - "/summary [ref] — view results once processing completes"
