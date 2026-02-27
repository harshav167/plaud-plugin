#!/usr/bin/env bash
# Auth gate — verifies the plaud MCP server is reachable and OAuth is configured.
#
# Exit codes:
#   0 = allow the tool call
#   2 = block the tool call (with reason on stdout)
#
# Receives hook JSON on stdin (ignored — we only check connectivity).

set -euo pipefail

# The MCP server uses GitHub OAuth — Claude handles auth automatically.
# This hook just verifies the server is configured (not that auth works,
# since OAuth tokens are managed by the MCP client, not env vars).

MCP_URL="${PLAUD_MCP_URL:?Set PLAUD_MCP_URL to your Plaud MCP server URL (e.g. https://your-server.example.com/mcp)}"

# Quick check: can we reach the OAuth discovery endpoint?
if ! curl -sf --max-time 3 "${MCP_URL%/mcp}/.well-known/oauth-authorization-server" >/dev/null 2>&1; then
  cat <<MSG
Cannot reach the Plaud MCP server at ${MCP_URL}.

The server uses GitHub OAuth — no manual token setup needed.
Claude handles authentication automatically when you connect.

If the server is down, check: docker compose ps plaud-memory
MSG
  exit 2
fi

exit 0
