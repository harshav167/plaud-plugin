---
description: List Plaud AI recordings with optional filtering
argument-hint: "[filters like: source desktop, since 3d, untranscribed, limit 50]"
---

List the user's Plaud AI recordings using MCP tools.

1. Parse arguments for filters. Map natural language to `find_recordings` parameters:
   - "last 50" / "limit 50" → `limit=50`
   - "desktop" / "source desktop" → `source="desktop"` (also: `call`, `note`)
   - "since 3d" / "last 3 days" → `since="3d"`
   - "transcribed" → `transcribed=true`
   - "untranscribed" → `transcribed=false`
   - No arguments → `find_recordings(limit=20)`
2. Call `find_recordings(...)` with the parsed filters.
3. Present results as a numbered table:

   | # | Title | Date | Duration | Source | Transcribed |
   |---|-------|------|----------|--------|-------------|

4. After the table, offer next actions:
   - "Pick a number to see details, or try `/transcribe N`, `/summary N`, `/search <query>`"
