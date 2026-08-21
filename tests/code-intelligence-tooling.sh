#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="${REPO_ROOT}/tests/fixtures/fake-cli.sh"
TEST_TMP="$(mktemp -d)"
trap 'rm -rf "$TEST_TMP"' EXIT

# Keep default-behavior cases independent from the caller's exported setup configuration.
for variable in \
  BACKLOG_MD_VERSION BMAD_VERSION \
  CODEGRAPH_VERSION CODEGRAPH_PACKAGE SERENA_VERSION SERENA_PACKAGE SERENA_PYTHON_VERSION \
  INSTALL_CODEGRAPH INSTALL_SERENA CODEGRAPH_INIT_PROJECT SERENA_INIT_PROJECT SERENA_INDEX_PROJECT \
  CODEGRAPH_SETUP_CLIENTS SERENA_SETUP_CLIENTS MCP_PROJECT_ID \
  SERENA_PROJECT_NAME SERENA_INDEX_LOG_LEVEL SERENA_INDEX_TIMEOUT SERENA_LANGUAGES \
  CODEGRAPH_TELEMETRY CODEGRAPH_NO_DOWNLOAD DO_NOT_TRACK SERENA_USAGE_REPORTING \
  FAKE_CODEGRAPH_VERSION FAKE_SERENA_VERSION; do
  unset "$variable"
done

make_fake_bin() {
  local target="$1"
  local tool

  mkdir -p "$target"
  for tool in npm npx uv codegraph serena codex claude; do
    ln -s "$FIXTURE" "${target}/${tool}"
  done
}

make_setup_project() {
  local target="$1"

  mkdir -p "$target/scripts"
  cp "${REPO_ROOT}/template/scripts/setup.sh" \
    "${REPO_ROOT}/template/scripts/codegraph-telemetry-off.sh" \
    "${REPO_ROOT}/template/scripts/serena-telemetry-off.sh" \
    "$target/scripts/"
}

assert_no_client_calls() {
  local log="$1"

  if grep -Eq '^(codex|claude)\|' "$log"; then
    echo "unexpected MCP client registration:" >&2
    grep -E '^(codex|claude)\|' "$log" >&2
    exit 1
  fi
}

fake_bin="${TEST_TMP}/bin"
make_fake_bin "$fake_bin"
test_path="${fake_bin}:/usr/bin:/bin"
setup_project="${TEST_TMP}/setup project"
make_setup_project "$setup_project"
setup_script="${setup_project}/scripts/setup.sh"

if grep -Eq '\$\{[^}]*,,[^}]*\}' "${REPO_ROOT}/template/scripts/setup.sh"; then
  echo "setup uses Bash 4-only lowercase parameter expansion" >&2
  exit 1
fi

# Wrappers must replace hostile inherited values, disable shim downloads, and keep Serena MCP read-only.
wrapper_log="${TEST_TMP}/wrappers.log"
FAKE_TOOL_LOG="$wrapper_log" CODEGRAPH_TELEMETRY=1 CODEGRAPH_NO_DOWNLOAD=0 DO_NOT_TRACK=0 \
  PATH="$test_path" "${REPO_ROOT}/template/scripts/codegraph-telemetry-off.sh" status
FAKE_TOOL_LOG="$wrapper_log" SERENA_USAGE_REPORTING=true DO_NOT_TRACK=0 \
  PATH="$test_path" "${REPO_ROOT}/template/scripts/serena-telemetry-off.sh" project health-check .
FAKE_TOOL_LOG="$wrapper_log" SERENA_USAGE_REPORTING=true DO_NOT_TRACK=0 \
  PATH="$test_path" "${REPO_ROOT}/template/scripts/serena-telemetry-off.sh" \
  start-mcp-server --context=codex --project .
grep -Fq 'codegraph|cg=0|dnt=1|serena=|no_download=1|args=status' "$wrapper_log"
grep -Fq 'serena|cg=|dnt=1|serena=false|no_download=|args=project health-check .' "$wrapper_log"
grep -Fq 'serena|cg=|dnt=1|serena=false|no_download=|args=start-mcp-server --mode planning --context=codex --project .' "$wrapper_log"
wrapper_override_output="${TEST_TMP}/wrapper-mode-override.out"
if FAKE_TOOL_LOG="$wrapper_log" PATH="$test_path" \
  "${REPO_ROOT}/template/scripts/serena-telemetry-off.sh" \
  start-mcp-server --mode editing >"$wrapper_override_output" 2>&1; then
  echo "Serena wrapper allowed its fixed planning mode to be overridden" >&2
  exit 1
else
  test "$?" -eq 2
fi
grep -Fq 'ERROR: this wrapper fixes Serena MCP mode to planning' "$wrapper_override_output"

# Missing tools fail without falling through to package runners that could download them.
missing_bin="${TEST_TMP}/missing-bin"
mkdir -p "$missing_bin"
ln -s "$FIXTURE" "${missing_bin}/npx"
ln -s "$FIXTURE" "${missing_bin}/uv"
ln -s "$FIXTURE" "${missing_bin}/uvx"
missing_log="${TEST_TMP}/missing.log"
missing_codegraph_output="${TEST_TMP}/missing-codegraph.out"
if FAKE_TOOL_LOG="$missing_log" PATH="${missing_bin}:/usr/bin:/bin" \
  "${REPO_ROOT}/template/scripts/codegraph-telemetry-off.sh" status >"$missing_codegraph_output" 2>&1; then
  echo "missing CodeGraph unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 127
fi
grep -Fq 'ERROR: codegraph is not installed.' "$missing_codegraph_output"
missing_serena_output="${TEST_TMP}/missing-serena.out"
if FAKE_TOOL_LOG="$missing_log" PATH="${missing_bin}:/usr/bin:/bin" \
  "${REPO_ROOT}/template/scripts/serena-telemetry-off.sh" project health-check . >"$missing_serena_output" 2>&1; then
  echo "missing Serena unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 127
fi
grep -Fq 'ERROR: serena is not installed.' "$missing_serena_output"
test ! -s "$missing_log"

# Tool opt-outs dominate even explicit client lists and must not invoke installers, tools, or clients.
opt_out_log="${TEST_TMP}/opt-out.log"
FAKE_TOOL_LOG="$opt_out_log" \
  INSTALL_CODEGRAPH=0 INSTALL_SERENA=0 \
  CODEGRAPH_SETUP_CLIENTS='codex claude-code' SERENA_SETUP_CLIENTS='codex claude-code' \
  CODEGRAPH_TELEMETRY=1 DO_NOT_TRACK=0 SERENA_USAGE_REPORTING=true \
  PATH="$test_path" bash "$setup_script" >/dev/null
if grep -Eq '^(codegraph|serena|uv|codex|claude)\|' "$opt_out_log"; then
  echo "disabled code-intelligence tooling was invoked:" >&2
  grep -E '^(codegraph|serena|uv|codex|claude)\|' "$opt_out_log" >&2
  exit 1
fi
if grep -Fq '@colbymchenry/codegraph' "$opt_out_log"; then
  echo "CodeGraph package download was attempted while disabled" >&2
  exit 1
fi

# Default setup installs the tools but never registers a detected client.
default_log="${TEST_TMP}/default.log"
FAKE_TOOL_LOG="$default_log" \
  CODEGRAPH_INIT_PROJECT=0 SERENA_INIT_PROJECT=0 \
  CODEGRAPH_TELEMETRY=1 DO_NOT_TRACK=0 SERENA_USAGE_REPORTING=true \
  PATH="$test_path" bash "$setup_script" >/dev/null
assert_no_client_calls "$default_log"
grep -Fq 'codegraph|cg=0|dnt=1|serena=false|no_download=1|args=--version' "$default_log"
grep -Fq 'codegraph|cg=0|dnt=1|serena=false|no_download=1|args=telemetry off' "$default_log"
grep -Fq 'serena|cg=0|dnt=1|serena=false|no_download=1|args=--version' "$default_log"
grep -Fq 'serena|cg=0|dnt=1|serena=false|no_download=1|args=init' "$default_log"

# The enabled defaults initialize both indexes and make Serena's generated config read-only.
initialization_log="${TEST_TMP}/initialization.log"
FAKE_TOOL_LOG="$initialization_log" SERENA_LANGUAGES='bash yaml' \
  PATH="$test_path" bash "$setup_script" >/dev/null
grep -Fq "codegraph|cg=0|dnt=1|serena=false|no_download=1|args=init ${setup_project}" "$initialization_log"
grep -Fq "serena|cg=0|dnt=1|serena=false|no_download=1|args=project create --name setup project --language bash --language yaml --index --log-level WARNING --timeout 10 ${setup_project}" "$initialization_log"
grep -Eq '^read_only:[[:space:]]*true[[:space:]]*$' "${setup_project}/.serena/project.yml"

# Explicit registrations use caller-controlled, validated project identity plus project-local wrappers.
registration_log="${TEST_TMP}/registration.log"
FAKE_TOOL_LOG="$registration_log" MCP_PROJECT_ID=fixture-123 \
  CODEGRAPH_INIT_PROJECT=0 SERENA_INIT_PROJECT=0 \
  CODEGRAPH_SETUP_CLIENTS='codex claude-code' SERENA_SETUP_CLIENTS='codex claude-code' \
  PATH="$test_path" bash "$setup_script" >/dev/null
grep -Fq "codex|cg=0|dnt=1|serena=false|no_download=1|args=mcp add fixture-123-codegraph -- ${setup_project}/scripts/codegraph-telemetry-off.sh serve --mcp --path ${setup_project}" "$registration_log"
grep -Fq "codex|cg=0|dnt=1|serena=false|no_download=1|args=mcp add fixture-123-serena -- ${setup_project}/scripts/serena-telemetry-off.sh start-mcp-server --context=codex --project ${setup_project}" "$registration_log"
grep -Fq "claude|cg=0|dnt=1|serena=false|no_download=1|args=mcp add --scope local fixture-123-codegraph -- ${setup_project}/scripts/codegraph-telemetry-off.sh serve --mcp --path ${setup_project}" "$registration_log"
grep -Fq "claude|cg=0|dnt=1|serena=false|no_download=1|args=mcp add --scope local fixture-123-serena -- ${setup_project}/scripts/serena-telemetry-off.sh start-mcp-server --context=claude-code --project ${setup_project}" "$registration_log"

# Without an override, names include a sanitized project directory and path-derived numeric suffix.
generated_name_log="${TEST_TMP}/generated-name.log"
FAKE_TOOL_LOG="$generated_name_log" \
  CODEGRAPH_INIT_PROJECT=0 SERENA_INIT_PROJECT=0 \
  CODEGRAPH_SETUP_CLIENTS=codex SERENA_SETUP_CLIENTS=codex \
  PATH="$test_path" bash "$setup_script" >/dev/null
grep -Eq '^codex\|cg=0\|dnt=1\|serena=false\|no_download=1\|args=mcp add setup-project-[0-9]+-codegraph -- ' "$generated_name_log"
grep -Eq '^codex\|cg=0\|dnt=1\|serena=false\|no_download=1\|args=mcp add setup-project-[0-9]+-serena -- ' "$generated_name_log"

# Invalid switches and client names fail before any installer or client command can run.
invalid_bool_log="${TEST_TMP}/invalid-bool.log"
invalid_bool_output="${TEST_TMP}/invalid-bool.out"
if FAKE_TOOL_LOG="$invalid_bool_log" INSTALL_CODEGRAPH=maybe \
  PATH="$test_path" bash "$setup_script" >"$invalid_bool_output" 2>&1; then
  echo "invalid boolean unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 2
fi
grep -Fq 'ERROR: INSTALL_CODEGRAPH must be one of:' "$invalid_bool_output"
test ! -s "$invalid_bool_log"

invalid_client_log="${TEST_TMP}/invalid-client.log"
invalid_client_output="${TEST_TMP}/invalid-client.out"
if FAKE_TOOL_LOG="$invalid_client_log" CODEGRAPH_SETUP_CLIENTS=unknown \
  PATH="$test_path" bash "$setup_script" >"$invalid_client_output" 2>&1; then
  echo "invalid client unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 2
fi
grep -Fq 'ERROR: unsupported CODEGRAPH_SETUP_CLIENTS entry: unknown.' "$invalid_client_output"
test ! -s "$invalid_client_log"

# Requested clients are preflighted before installers or any registration can mutate external state.
missing_client_bin="${TEST_TMP}/missing-client-bin"
make_fake_bin "$missing_client_bin"
unlink "${missing_client_bin}/claude"
for utility in awk basename cksum dirname sed tr; do
  ln -s "$(command -v "$utility")" "${missing_client_bin}/${utility}"
done
missing_client_log="${TEST_TMP}/missing-client.log"
missing_client_output="${TEST_TMP}/missing-client.out"
if FAKE_TOOL_LOG="$missing_client_log" INSTALL_SERENA=0 CODEGRAPH_SETUP_CLIENTS=claude-code \
  PATH="$missing_client_bin" /bin/bash "$setup_script" >"$missing_client_output" 2>&1; then
  echo "missing requested client unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 1
fi
grep -Fq 'ERROR: an MCP client list includes claude-code, but claude is not available.' "$missing_client_output"
test ! -s "$missing_client_log"

# A shadowing or stale executable is rejected before initialization or client registration.
wrong_version_log="${TEST_TMP}/wrong-version.log"
wrong_version_output="${TEST_TMP}/wrong-version.out"
if FAKE_TOOL_LOG="$wrong_version_log" FAKE_CODEGRAPH_VERSION=0.0.0 INSTALL_SERENA=0 \
  PATH="$test_path" bash "$setup_script" >"$wrong_version_output" 2>&1; then
  echo "wrong CodeGraph version unexpectedly succeeded" >&2
  exit 1
else
  test "$?" -eq 1
fi
grep -Fq 'ERROR: expected CodeGraph 1.1.2' "$wrong_version_output"
if grep -Fq 'args=telemetry off' "$wrong_version_log"; then
  echo "wrong CodeGraph executable was invoked beyond version inspection" >&2
  exit 1
fi

# Supported mixed-case booleans remain portable without Bash 4-only expansion.
mixed_case_log="${TEST_TMP}/mixed-case.log"
FAKE_TOOL_LOG="$mixed_case_log" INSTALL_CODEGRAPH=FALSE INSTALL_SERENA=Off \
  PATH="$test_path" bash "$setup_script" >/dev/null
if grep -Eq '^(codegraph|serena|uv|codex|claude)\|' "$mixed_case_log"; then
  echo "mixed-case disabled tooling was invoked" >&2
  exit 1
fi

echo "code-intelligence tooling tests passed"
