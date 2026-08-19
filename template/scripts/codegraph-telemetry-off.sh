#!/usr/bin/env bash
# Run an already-installed CodeGraph CLI with telemetry disabled for every invocation.
set -euo pipefail

export CODEGRAPH_TELEMETRY=0
export CODEGRAPH_NO_DOWNLOAD=1
export DO_NOT_TRACK=1

if command -v codegraph >/dev/null 2>&1; then
  exec codegraph "$@"
fi

echo "ERROR: codegraph is not installed. Run scripts/setup.sh or use repository-native tools." >&2
exit 127
