#!/usr/bin/env bash
# Bootstrap the stack-agnostic SDLC tooling for this project.
#
# Backlog.md and BMAD require Node.js + npm. CodeGraph also uses npm; Serena requires uv. CodeGraph and
# Serena installation can be disabled independently. MCP client registration is always explicit opt-in.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEGRAPH_WRAPPER="${PROJECT_ROOT}/scripts/codegraph-telemetry-off.sh"
SERENA_WRAPPER="${PROJECT_ROOT}/scripts/serena-telemetry-off.sh"

# Pinned versions. Override deliberately, then record the result in .bmad/sdlc-state.yaml > tooling.
BACKLOG_MD_VERSION="${BACKLOG_MD_VERSION:-1.45.2}"
BMAD_VERSION="${BMAD_VERSION:-6.8.0}"
CODEGRAPH_VERSION="${CODEGRAPH_VERSION:-1.1.2}"
CODEGRAPH_PACKAGE="${CODEGRAPH_PACKAGE:-@colbymchenry/codegraph@${CODEGRAPH_VERSION}}"
SERENA_VERSION="${SERENA_VERSION:-1.5.3}"
SERENA_PACKAGE="${SERENA_PACKAGE:-serena-agent==${SERENA_VERSION}}"
SERENA_PYTHON_VERSION="${SERENA_PYTHON_VERSION:-3.13}"

# Installation and project-initialization switches.
INSTALL_CODEGRAPH="${INSTALL_CODEGRAPH:-1}"
INSTALL_SERENA="${INSTALL_SERENA:-1}"
CODEGRAPH_INIT_PROJECT="${CODEGRAPH_INIT_PROJECT:-1}"
SERENA_INIT_PROJECT="${SERENA_INIT_PROJECT:-1}"
SERENA_INDEX_PROJECT="${SERENA_INDEX_PROJECT:-1}"

# Client registration is off unless the caller names one or more clients, separated by spaces.
# Supported clients: codex, claude-code. INSTALL_*=0 always suppresses registration for that tool.
CODEGRAPH_SETUP_CLIENTS="${CODEGRAPH_SETUP_CLIENTS:-none}"
SERENA_SETUP_CLIENTS="${SERENA_SETUP_CLIENTS:-none}"

SERENA_PROJECT_NAME="${SERENA_PROJECT_NAME:-$(basename "$PROJECT_ROOT")}"
SERENA_INDEX_LOG_LEVEL="${SERENA_INDEX_LOG_LEVEL:-WARNING}"
SERENA_INDEX_TIMEOUT="${SERENA_INDEX_TIMEOUT:-10}"
SERENA_LANGUAGES="${SERENA_LANGUAGES:-}"

# These values are guarantees, not caller defaults. Hostile inherited values must not re-enable reporting.
export CODEGRAPH_TELEMETRY=0
export CODEGRAPH_NO_DOWNLOAD=1
export DO_NOT_TRACK=1
export SERENA_USAGE_REPORTING=false

lowercase() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

validate_boolean() {
  local name="$1"
  local value="$2"
  local normalized

  normalized="$(lowercase "$value")"
  case "$normalized" in
    1|0|true|false|yes|no|on|off) ;;
    *)
      echo "ERROR: ${name} must be one of: 1, 0, true, false, yes, no, on, off (got: ${value})." >&2
      exit 2
      ;;
  esac
}

is_enabled() {
  local normalized

  normalized="$(lowercase "$1")"
  case "$normalized" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

validate_clients() {
  local name="$1"
  local value="$2"
  local client
  local -a clients=()

  read -r -a clients <<< "$value"
  if [ "${#clients[@]}" -eq 0 ] || [ "${clients[0]}" = "none" ]; then
    if [ "${#clients[@]}" -gt 1 ]; then
      echo "ERROR: ${name}=none cannot be combined with another client." >&2
      exit 2
    fi
    return 0
  fi

  for client in "${clients[@]}"; do
    case "$client" in
      codex|claude-code) ;;
      *)
        echo "ERROR: unsupported ${name} entry: ${client}." >&2
        echo "Supported values: none, codex, claude-code (space-separated)." >&2
        exit 2
        ;;
    esac
  done
}

preflight_client_commands() {
  local client
  local value
  local needs_codex=0
  local needs_claude=0
  local -a clients=()

  for value in \
    "$(is_enabled "$INSTALL_CODEGRAPH" && printf '%s' "$CODEGRAPH_SETUP_CLIENTS" || printf 'none')" \
    "$(is_enabled "$INSTALL_SERENA" && printf '%s' "$SERENA_SETUP_CLIENTS" || printf 'none')"; do
    clients=()
    read -r -a clients <<< "$value"
    for client in "${clients[@]}"; do
      case "$client" in
        codex) needs_codex=1 ;;
        claude-code) needs_claude=1 ;;
      esac
    done
  done

  if [ "$needs_codex" -eq 1 ] && ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: an MCP client list includes codex, but codex is not available." >&2
    exit 1
  fi
  if [ "$needs_claude" -eq 1 ] && ! command -v claude >/dev/null 2>&1; then
    echo "ERROR: an MCP client list includes claude-code, but claude is not available." >&2
    exit 1
  fi
}

make_project_id() {
  local base
  local safe
  local checksum

  base="$(basename "$PROJECT_ROOT")"
  safe="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  safe="${safe:0:36}"
  [ -n "$safe" ] || safe="project"
  checksum="$(printf '%s' "$PROJECT_ROOT" | cksum | awk '{print $1}')"
  printf '%s-%s' "$safe" "$checksum"
}

MCP_PROJECT_ID="${MCP_PROJECT_ID:-$(make_project_id)}"
if [[ ! "$MCP_PROJECT_ID" =~ ^[a-z0-9][a-z0-9_-]{0,51}$ ]]; then
  echo "ERROR: MCP_PROJECT_ID must be 1-52 lowercase letters, digits, underscores, or hyphens." >&2
  exit 2
fi
CODEGRAPH_MCP_NAME="${MCP_PROJECT_ID}-codegraph"
SERENA_MCP_NAME="${MCP_PROJECT_ID}-serena"

for boolean_name in \
  INSTALL_CODEGRAPH \
  INSTALL_SERENA \
  CODEGRAPH_INIT_PROJECT \
  SERENA_INIT_PROJECT \
  SERENA_INDEX_PROJECT; do
  validate_boolean "$boolean_name" "${!boolean_name}"
done
validate_clients CODEGRAPH_SETUP_CLIENTS "$CODEGRAPH_SETUP_CLIENTS"
validate_clients SERENA_SETUP_CLIENTS "$SERENA_SETUP_CLIENTS"
preflight_client_commands

if is_enabled "$INSTALL_SERENA" && ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: Serena requires uv. Install uv first, or run INSTALL_SERENA=0 bash scripts/setup.sh." >&2
  exit 1
fi

run_codegraph() {
  "$CODEGRAPH_WRAPPER" "$@"
}

run_serena() {
  "$SERENA_WRAPPER" "$@"
}

verify_codegraph_version() {
  local actual
  local resolved

  resolved="$(command -v codegraph 2>/dev/null || true)"
  if [ -z "$resolved" ]; then
    echo "ERROR: CodeGraph was installed but codegraph is not available on PATH." >&2
    exit 1
  fi
  if ! actual="$(run_codegraph --version 2>/dev/null)"; then
    echo "ERROR: could not read the CodeGraph version from ${resolved}." >&2
    exit 1
  fi
  actual="$(printf '%s\n' "$actual" | head -n 1 | tr -d '\r')"
  if [ "$actual" != "$CODEGRAPH_VERSION" ]; then
    echo "ERROR: expected CodeGraph ${CODEGRAPH_VERSION}, but ${resolved} reports ${actual:-no version}." >&2
    exit 1
  fi
}

verify_serena_version() {
  local actual
  local resolved

  resolved="$(command -v serena 2>/dev/null || true)"
  if [ -z "$resolved" ]; then
    echo "ERROR: Serena was installed but serena is not available on PATH." >&2
    exit 1
  fi
  if ! actual="$(run_serena --version 2>/dev/null)"; then
    echo "ERROR: could not read the Serena version from ${resolved}." >&2
    exit 1
  fi
  actual="$(printf '%s\n' "$actual" | head -n 1 | tr -d '\r')"
  case "$actual" in
    "$SERENA_VERSION"|"Serena $SERENA_VERSION") ;;
    *)
      echo "ERROR: expected Serena ${SERENA_VERSION}, but ${resolved} reports ${actual:-no version}." >&2
      exit 1
      ;;
  esac
}

enforce_serena_read_only() {
  local config="${PROJECT_ROOT}/.serena/project.yml"
  local rewritten

  [ -f "$config" ] || return 0
  if ! grep -Eq '^read_only:[[:space:]]*true[[:space:]]*$' "$config"; then
    if ! grep -Eq '^read_only:' "$config"; then
      echo "ERROR: Serena project config has no read_only field: ${config}" >&2
      exit 1
    fi
    rewritten="$(mktemp "${config}.tmp.XXXXXX")"
    if ! sed -E 's/^read_only:.*/read_only: true/' "$config" > "$rewritten"; then
      rm -f "$rewritten"
      echo "ERROR: could not rewrite Serena project config: ${config}" >&2
      exit 1
    fi
    mv "$rewritten" "$config"
  fi
  if ! grep -Eq '^read_only:[[:space:]]*true[[:space:]]*$' "$config"; then
    echo "ERROR: could not enforce read-only Serena project config: ${config}" >&2
    exit 1
  fi
}

setup_codegraph_clients() {
  local client
  local -a clients=()

  read -r -a clients <<< "$CODEGRAPH_SETUP_CLIENTS"
  [ "${clients[0]:-none}" != "none" ] || return 0

  for client in "${clients[@]}"; do
    case "$client" in
      codex)
        echo "==> Registering ${CODEGRAPH_MCP_NAME} for Codex"
        codex mcp add "$CODEGRAPH_MCP_NAME" -- \
          "$CODEGRAPH_WRAPPER" serve --mcp --path "$PROJECT_ROOT"
        ;;
      claude-code)
        echo "==> Registering ${CODEGRAPH_MCP_NAME} for Claude Code (local scope)"
        claude mcp add --scope local "$CODEGRAPH_MCP_NAME" -- \
          "$CODEGRAPH_WRAPPER" serve --mcp --path "$PROJECT_ROOT"
        ;;
    esac
  done
}

setup_serena_clients() {
  local client
  local -a clients=()

  read -r -a clients <<< "$SERENA_SETUP_CLIENTS"
  [ "${clients[0]:-none}" != "none" ] || return 0

  for client in "${clients[@]}"; do
    case "$client" in
      codex)
        echo "==> Registering ${SERENA_MCP_NAME} for Codex"
        codex mcp add "$SERENA_MCP_NAME" -- \
          "$SERENA_WRAPPER" start-mcp-server --context=codex --project "$PROJECT_ROOT"
        ;;
      claude-code)
        echo "==> Registering ${SERENA_MCP_NAME} for Claude Code (local scope)"
        claude mcp add --scope local "$SERENA_MCP_NAME" -- \
          "$SERENA_WRAPPER" start-mcp-server --context=claude-code --project "$PROJECT_ROOT"
        ;;
    esac
  done
}

echo "==> Installing Backlog.md CLI (backlog.md@${BACKLOG_MD_VERSION}) globally"
npm install -g "backlog.md@${BACKLOG_MD_VERSION}"

echo "==> Installing BMAD core method + test architecture (modules: bmm, tea)"
npx --yes "bmad-method@${BMAD_VERSION}" install --modules bmm,tea

echo "==> Installing the autonomous build loop (module: automator)"
npx --yes "bmad-method@${BMAD_VERSION}" install --modules automator

chmod +x "$CODEGRAPH_WRAPPER" "$SERENA_WRAPPER"

if is_enabled "$INSTALL_CODEGRAPH"; then
  echo "==> Installing CodeGraph (${CODEGRAPH_PACKAGE}) with telemetry disabled"
  npm install -g "$CODEGRAPH_PACKAGE"
  verify_codegraph_version
  run_codegraph telemetry off
  if is_enabled "$CODEGRAPH_INIT_PROJECT"; then
    run_codegraph init "$PROJECT_ROOT"
  fi
  setup_codegraph_clients
else
  echo "==> Skipping CodeGraph installation, initialization, and client registration"
fi

if is_enabled "$INSTALL_SERENA"; then
  echo "==> Installing Serena (${SERENA_PACKAGE}) with usage reporting disabled"
  uv tool install -p "$SERENA_PYTHON_VERSION" "$SERENA_PACKAGE"
  verify_serena_version
  run_serena init

  if is_enabled "$SERENA_INIT_PROJECT"; then
    serena_languages=()
    serena_create_args=(--name "$SERENA_PROJECT_NAME")
    serena_index_args=(--name "$SERENA_PROJECT_NAME" --log-level "$SERENA_INDEX_LOG_LEVEL" --timeout "$SERENA_INDEX_TIMEOUT")

    read -r -a serena_languages <<< "$SERENA_LANGUAGES"
    for language in "${serena_languages[@]}"; do
      serena_create_args+=(--language "$language")
      serena_index_args+=(--language "$language")
    done

    if is_enabled "$SERENA_INDEX_PROJECT"; then
      serena_create_args+=(--index --log-level "$SERENA_INDEX_LOG_LEVEL" --timeout "$SERENA_INDEX_TIMEOUT")
    fi

    if [ -f "${PROJECT_ROOT}/.serena/project.yml" ]; then
      if is_enabled "$SERENA_INDEX_PROJECT"; then
        run_serena project index "${serena_index_args[@]}" "$PROJECT_ROOT"
      fi
    else
      run_serena project create "${serena_create_args[@]}" "$PROJECT_ROOT"
    fi
  fi

  enforce_serena_read_only
  setup_serena_clients
else
  echo "==> Skipping Serena installation, initialization, indexing, and client registration"
fi

cat <<EOF

==> Bootstrap complete.

Next steps:
  1. Set this project's name in the backlog (operate backlog ONLY via the CLI, never by hand):
       backlog config set projectName "<name>"     # see: backlog config --help
  2. Fill in the Quality gate in CONTRIBUTING.md, and mirror it into:
       - backlog/config.yml  > definition_of_done
       - .github/workflows/ci.yml  (the gate steps)
       - your pre-commit hook
  3. Record exact versions for installed tools in .bmad/sdlc-state.yaml > tooling; leave a disabled
     code-intelligence tool null.
  4. Read AGENTS.md and select the narrowest process matching the request.

MCP client registration remains off unless CODEGRAPH_SETUP_CLIENTS or SERENA_SETUP_CLIENTS explicitly
names a client. This project's registration suffix is: ${MCP_PROJECT_ID}

NOTE: this installed the language-agnostic SDLC tooling only.
TODO: install your project's own language toolchain and wire its build / lint / test commands into the
      quality gate above.
EOF
