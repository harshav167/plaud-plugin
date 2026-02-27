---
name: memory-search
description: Guide for searching across indexed Plaud transcripts using semantic, keyword, graph, and entity extraction. Use when the user asks to search conversation content, find mentions of topics, people, decisions, or action items across recordings.
---

# Memory Search

Search across indexed Plaud transcripts using vector similarity (Qdrant), knowledge graph (Neo4j), and keyword matching. Unlike `find_recordings` which searches metadata, memory search searches inside transcript content.

## Tools

### `memory_search`

Main search tool across indexed transcripts.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | **required** | Natural language search query |
| `search_type` | string | `"smart"` | Search strategy (see table below) |
| `since` | string | null | Relative (`"7d"`) or absolute (`"2026-01-15"`) |
| `until` | string | null | Same format as `since` |
| `last` | string | null | Shorthand temporal filter (`"7d"`, `"2w"`, `"1m"`) |
| `speaker` | string | null | Filter by speaker name |
| `source` | `"call"` \| `"meeting"` \| `"desktop"` | null | Filter by recording type |
| `file_ref` | string | null | Restrict to one recording. Required for `"related"` type |
| `limit` | int | 10 | Max results |

## Search Types

| search_type | Method | Best for |
|-------------|--------|----------|
| `smart` | Hybrid (keyword + vector) | General questions -- start here |
| `keyword` | Exact matching | Specific terms, names, acronyms |
| `semantic` | Vector similarity | Conceptual queries ("discussions about scaling") |
| `deep` | Chain-of-thought reasoning | Complex, multi-hop questions |
| `graph` | Neo4j entity graph | Relationships, connections between people/topics |
| `related` | Similar content | "More like this" -- requires `file_ref` |
| `entities` | Entity extraction | Who, what, decisions, action items |

## Search Strategy (Simple to Thorough)

1. **Start with `smart`** -- hybrid search covers most queries
2. **Try `keyword`** -- if searching for exact names, terms, or acronyms
3. **Try `deep`** -- if smart results are insufficient for complex questions
4. **Use `graph`** -- for relationship questions ("who talked to whom about X")
5. **Use `entities`** -- for summaries of speakers, decisions, action items
6. **Use `related`** -- to find recordings similar to a specific one

## Examples

General topic search:
```
memory_search(query="product roadmap discussion")
```

Search by speaker in recent recordings:
```
memory_search(query="budget", speaker="Alice", last="30d")
```

Find exact terms:
```
memory_search(query="Series B", search_type="keyword")
```

Complex multi-hop question:
```
memory_search(query="what decisions were made about the API redesign and who owns the follow-ups", search_type="deep")
```

Entity extraction:
```
memory_search(query="Q1 planning meetings", search_type="entities")
```

Find relationships:
```
memory_search(query="Alice", search_type="graph")
```

Find similar recordings:
```
memory_search(query="similar content", search_type="related", file_ref="4f75")
```

## Prerequisites

Recordings must be indexed via `memory_ingest` before they appear in search results. Use `get_recording(file_ref)` to check `indexed` status. If a recording is not indexed, use the bulk-operations skill to ingest it.

## Anti-Patterns (NEVER DO)

- **Never assume zero results means nothing exists** -- try alternative queries, different search types, or broaden terms
- **Never use only `keyword` for conceptual queries** -- use `smart` or `semantic` instead
- **Never use `related` without `file_ref`** -- it will error
- **Never skip the prerequisites check** -- unindexed recordings return no results silently
- **Never present unsorted results** -- sort by relevance or date (most recent first)
