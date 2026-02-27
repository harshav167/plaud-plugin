---
description: Search recordings by title and memory by content
argument-hint: "<query>"
---

Search Plaud recordings and indexed memory for a query.

1. Call `find_recordings(query="<user query>")` to search recording titles/metadata.
2. Call `memory_search(query="<user query>", search_type="smart")` to search indexed transcript content semantically.
3. Present both result sets:

   **Recordings matching title** (N results):
   | # | Title | Date | Duration | Source |
   |---|-------|------|----------|--------|

   **Transcript passages matching content** (M results):
   Show each result with a snippet of the matching passage and the recording it came from.

4. If no results from either source, suggest:
   - "Try different keywords"
   - "Run `/ls` to browse all recordings"
   - "Index more transcripts with `memory_ingest` to improve content search"
5. If results found, offer: "Pick a number to read the full transcript"
