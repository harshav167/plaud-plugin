---
description: Get a presigned audio download URL for a recording
argument-hint: "<file ref>"
---

Retrieve a temporary download URL for a Plaud recording's audio file.

1. Call `get_recording(file_ref)` to fetch recording metadata. Display: title, date, duration, source.
2. Call `get_audio_url(file_ref)` to get the presigned download URL.
3. Present the URL prominently:

   **Audio URL** (expires in ~5 minutes):
   `<url>`

4. List other available content for this recording based on metadata:
   - Transcript: available / not available
   - Summary: available / not available
   - Notes: available / not available
5. Offer next actions:
   - "/transcribe [ref] — view transcript"
   - "/summary [ref] — view AI summary"
   - "Retrieve any of the above content?"
