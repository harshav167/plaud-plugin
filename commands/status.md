---
description: Daily recording briefing — recent recordings, account health, unprocessed items
argument-hint: "[since, e.g. 3d or 1w]"
---

Generate a comprehensive daily briefing of Plaud recording activity and account status.

1. Call `get_account_info()` to retrieve account and device details.
2. Call `find_recordings(since="1d")` for today's recordings. If the user provided a time range argument (e.g., "3d", "1w"), use that instead.
3. Call `find_recordings(transcribed=false, limit=20)` to find untranscribed recordings.
4. Call `memory_search(query="status", search_type="entities", last="1d")` to check memory index activity.
5. Present the briefing:

   ## Plaud Briefing — [today's date]

   **Account**: [name] ([membership tier])
   **Device**: [model] ([firmware version])

   ### Today's Recordings
   | # | Title | Duration | Source | Transcribed |
   |---|-------|----------|--------|-------------|
   [table of today's recordings, or "No recordings today"]

   ### Untranscribed Backlog
   [count] recordings without transcripts
   [show up to 5 oldest untranscribed recordings if any]

   ### Memory Index
   [Active: N passages indexed / Inactive: no recent activity]

6. Offer actions:
   - "Transcribe all untranscribed? (uses ElevenLabs credits for uncached recordings)"
   - "Index cached transcripts into memory? (free — call `memory_ingest`)"
   - "/search <query> — search recent conversations"
   - "/ls — browse all recordings"
