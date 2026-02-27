#!/usr/bin/env bash
# Cost/safety gate for Plaud MCP tools that consume ElevenLabs credits.
#
# Exit codes:
#   0 = allow the tool call
#   2 = block the tool call (with reason on stdout)
#
# Receives hook JSON on stdin with shape:
#   { "tool_name": "...", "tool_input": { ... } }

set -euo pipefail

AUDIT_LOG="/tmp/plaud-mcp-audit.log"
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

log_audit() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $1" >> "$AUDIT_LOG"
}

case "$TOOL_NAME" in
  mcp__plaud__transcribe)
    # Transcription always allowed — cached transcripts are free,
    # and individual transcriptions are low cost. Log for audit.
    FILE_REF=$(echo "$TOOL_INPUT" | jq -r '.file_ref // "unknown"')
    log_audit "ALLOW transcribe file_ref=$FILE_REF"
    exit 0
    ;;

  mcp__plaud__memory_ingest)
    SOURCE=$(echo "$TOOL_INPUT" | jq -r '.source // "all"')
    DRY_RUN=$(echo "$TOOL_INPUT" | jq -r '.dry_run // false')

    if [[ "$SOURCE" == "cache" ]] || [[ "$DRY_RUN" == "true" ]]; then
      log_audit "ALLOW memory_ingest source=$SOURCE dry_run=$DRY_RUN"
      exit 0
    fi

    # source=all with dry_run=false → block to prevent accidental bulk spend
    log_audit "BLOCK memory_ingest source=$SOURCE dry_run=$DRY_RUN (requires dry_run or source=cache)"
    echo "Use dry_run=true first to estimate costs, or source='cache' for free ingestion"
    exit 2
    ;;

  *)
    # Unknown tool — allow by default
    log_audit "ALLOW unknown tool=$TOOL_NAME"
    exit 0
    ;;
esac
