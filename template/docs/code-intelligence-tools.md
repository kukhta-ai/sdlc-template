# Code Intelligence Tools

CodeGraph and Serena support optional, read-only discovery in the process catalog. Their presence does not
start Full SDLC development and does not authorize source edits, backlog changes, or BMAD state changes.

## Telemetry-off contract

Project-supplied launch paths force these values on every invocation, replacing inherited values:

```bash
export CODEGRAPH_TELEMETRY=0
export CODEGRAPH_NO_DOWNLOAD=1
export DO_NOT_TRACK=1
export SERENA_USAGE_REPORTING=false
```

Use the wrappers for manual commands and MCP server launches:

```bash
scripts/codegraph-telemetry-off.sh status
scripts/codegraph-telemetry-off.sh explore "request routing"
scripts/serena-telemetry-off.sh project health-check .
scripts/serena-telemetry-off.sh start-mcp-server --context=codex --project .
```

The wrappers run an already-installed CLI only. If a tool is unavailable, they exit `127` and direct the
caller to setup or repository-native tools. The CodeGraph wrapper also disables its installed shim's release
download fallback, so a missing platform bundle fails instead of fetching code on demand. Serena MCP launches
are forced into planning mode, and setup makes the project configuration read-only.

## Installation and project state

`scripts/setup.sh` installs pinned defaults and initializes local project indexes:

- CodeGraph: `@colbymchenry/codegraph@1.1.2` through npm. The `.codegraph/` index is local and ignored.
- Serena: `serena-agent==1.5.3` through `uv` with Python 3.13. Commit `.serena/project.yml`; caches, logs,
  and `.serena/project.local.yml` remain local.

Override versions deliberately with `CODEGRAPH_VERSION`, `CODEGRAPH_PACKAGE`, `SERENA_VERSION`,
`SERENA_PACKAGE`, or `SERENA_PYTHON_VERSION`, then record installed versions in
`.bmad/sdlc-state.yaml`.

Installation opt-outs are authoritative:

```bash
INSTALL_CODEGRAPH=0 INSTALL_SERENA=0 bash scripts/setup.sh
```

A disabled tool is not downloaded, initialized, indexed, or registered with a client, even if a client list
is also supplied. The wrappers remain safe to call after an opt-out because they do not install missing
tools. Project initialization can be disabled separately with `CODEGRAPH_INIT_PROJECT=0`,
`SERENA_INIT_PROJECT=0`, or `SERENA_INDEX_PROJECT=0`.

Boolean switches accept `1/0`, `true/false`, `yes/no`, and `on/off`, case-insensitively. Invalid values and
unsupported client names fail before any installer runs.

## Explicit MCP client registration

Setup does not register MCP clients by default. Opt in by naming one or more supported clients:

```bash
CODEGRAPH_SETUP_CLIENTS=codex SERENA_SETUP_CLIENTS=codex bash scripts/setup.sh

CODEGRAPH_SETUP_CLIENTS="codex claude-code" \
SERENA_SETUP_CLIENTS="codex claude-code" \
bash scripts/setup.sh
```

Supported values are `none`, `codex`, and `claude-code`. Each registration:

- has a project-specific name ending in `-codegraph` or `-serena`;
- launches the absolute wrapper path from this project, so telemetry controls cannot be bypassed;
- binds the server to this project's absolute root instead of whichever directory the client later uses; and
- uses Claude Code's local scope when that client is selected.

The project identity defaults to a sanitized directory name plus a checksum of the absolute project path,
preventing projects with different locations from replacing one another's registration. To use a stable
identity across a deliberate project move, set a validated lowercase `MCP_PROJECT_ID` explicitly.

## Process use

- In fallback focused work, use the tools only as read-only discovery helpers for a code-focused request.
- In Full SDLC development, use story-size preflight to decide whether discovery runs. It is required for
  `M`, `L`, and human-approved `XL`, and conditional for `S` at an unfamiliar boundary.
- Prefer CodeGraph for entry points, flows, call paths, relevant source, and blast radius.
- Prefer Serena for symbol overview and reference lookup. Do not use symbol-editing operations during the
  discovery sub-process.
- If a tool or index is unavailable, fall back to `rg` and repository-native read-only tools. In focused
  work, report the fallback without changing BMAD or backlog state. In Full SDLC development, record it in
  `.bmad/sdlc-state.yaml` and the task notes.

See `AGENTS.md` for process selection, the pre-claim XL gate, and the canonical state fields.
