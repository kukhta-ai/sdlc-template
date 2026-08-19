#!/usr/bin/env bash
set -euo pipefail

tool="$(basename "$0")"
printf '%s|cg=%s|dnt=%s|serena=%s|no_download=%s|args=%s\n' \
  "$tool" \
  "${CODEGRAPH_TELEMETRY-}" \
  "${DO_NOT_TRACK-}" \
  "${SERENA_USAGE_REPORTING-}" \
  "${CODEGRAPH_NO_DOWNLOAD-}" \
  "$*" >> "${FAKE_TOOL_LOG:?FAKE_TOOL_LOG is required}"

if [ "$tool" = "codegraph" ] && [ "${1:-}" = "--version" ]; then
  printf '%s\n' "${FAKE_CODEGRAPH_VERSION:-1.1.2}"
fi

if [ "$tool" = "serena" ] && [ "${1:-}" = "--version" ]; then
  printf 'Serena %s\n' "${FAKE_SERENA_VERSION:-1.5.3}"
fi

if [ "$tool" = "serena" ] && [ "${1:-}" = "project" ] && [ "${2:-}" = "create" ]; then
  project_path=""
  for project_path in "$@"; do :; done
  mkdir -p "$project_path/.serena"
  printf 'project_name: fixture\nlanguages:\n- bash\nread_only: false\n' > "$project_path/.serena/project.yml"
fi
