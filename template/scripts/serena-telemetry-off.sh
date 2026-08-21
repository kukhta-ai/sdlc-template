#!/usr/bin/env bash
# Run an already-installed Serena CLI with usage reporting disabled for every invocation.
set -euo pipefail

export SERENA_USAGE_REPORTING=false
export DO_NOT_TRACK=1

if command -v serena >/dev/null 2>&1; then
  if [ "${1:-}" = "start-mcp-server" ]; then
    shift
    for argument in "$@"; do
      case "$argument" in
        --mode|--mode=*)
          echo "ERROR: this wrapper fixes Serena MCP mode to planning; do not pass --mode." >&2
          exit 2
          ;;
      esac
    done
    exec serena start-mcp-server --mode planning "$@"
  fi
  exec serena "$@"
fi

echo "ERROR: serena is not installed. Run scripts/setup.sh or use repository-native tools." >&2
exit 127
