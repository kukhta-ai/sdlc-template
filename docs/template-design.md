# SDLC Template Design Record

This repository is itself a product: a reusable repository template for BMAD-based, agent-led software
development. The central design decision is to separate the maintainer project from the generated-project
payload.

## Problem

When the generated-project files lived at the repository root, agents working on `sdlc-template` treated
payload files such as `AGENTS.md`, `docs/SDLC.md`, and `backlog/` as if they governed this maintainer repo.
That made template improvements awkward: the instructions for future generated projects were indistinguishable
from instructions for changing the template product.

## Boundary Model

```text
root repository          Maintains and evolves the template product.
template/                Payload copied into a new generated project root.
components/              Optional payload overlays copied only when selected at generation.
root backlog/            Real maintenance backlog for sdlc-template tasks.
template/backlog/        Empty seed backlog fixture for generated projects.
scripts/init-project.sh  Maintainer script that creates a project from template/.
template/scripts/setup.sh Generated-project bootstrap for Backlog.md, BMAD, CodeGraph, and Serena tooling.
```

Root `AGENTS.md` is the active instruction file for this repository. `template/AGENTS.md` is product content.
After `template/` is copied into a destination project, that copied `AGENTS.md` becomes active for the new
project.

## Generated Project Contract

A generated project should see the same shape the original template promised:

- `AGENTS.md` at repo root
- `CONTRIBUTING.md` at repo root
- `docs/SDLC.md`, `docs/code-intelligence-tools.md`, and `docs/task-writing-conventions.md`
- an empty initialized `backlog/`
- `.bmad/sdlc-state.yaml`
- `.claude/` backlog-protection hooks
- `.github/` CI and PR template
- `licenses/SDLC-TEMPLATE-MIT.txt` for the copied scaffold's MIT notice without licensing application code
- `scripts/setup.sh` for Backlog.md, BMAD, CodeGraph, and Serena installation
- `scripts/codegraph-telemetry-off.sh` and `scripts/serena-telemetry-off.sh` for reporting-disabled tool launch

The payload should not mention `template/` in normal generated-project instructions, because that directory
will not exist after copying.

## Process Routing Contract

`AGENTS.md` is a process router. Focused work is the default for ordinary questions, setup, repository
operations, investigation, and narrow edits. Backlog planning owns task structure without claiming work.
Full SDLC development starts only for an explicit full-process request or a qualifying Backlog.md
implementation task. Locally present `.sdlc/processes/*.md` files can register additional processes through
the same trigger, state, gate, exit, and compatibility contract; absent extensions are never inferred.

Full SDLC story work performs size preflight before claiming a task. An XL task remains To Do, with no story
branch and no active-story state, until it is split or a human explicitly accepts continuation.

## Code-Intelligence Contract

CodeGraph and Serena provide optional, read-only discovery. Their wrappers replace inherited telemetry and
usage-reporting values with disabled values on every launch, block CodeGraph's release-download fallback,
and force Serena MCP use into read-only planning mode. Setup pins and verifies versions, makes Serena project
configuration read-only, validates switches before installation, and treats installation opt-outs as
authoritative over initialization and client registration.

MCP registration is disabled by default. Explicit registrations have project-specific names and launch the
absolute wrappers from the generated project. Missing tools or indexes fall back to repository-native
read-only discovery, with the fallback recorded in the seeded SDLC state fields.

## Optional Component Contract

Optional components live outside `template/` so base generation does not receive dormant component files.
The initializer copies a selected component's `overlay/` after the base payload, then applies the same
project placeholders to both sources. Component overlays must not overwrite base files; shared integration
uses provider-neutral extension seams such as `.sdlc/processes/*.md`.

The architecture component is selected with `--with-architecture`. If omitted, the generated project has no
architecture workspace, process registration, wrapper, workflow, or Docker dependency. If selected, those
surfaces are present and active immediately; there is no second activation flag. Runtime services still
start only when the user runs the documented command.

## Initializer Contract

`scripts/init-project.sh` copies the base payload and any explicitly selected component overlays to a
destination directory, replaces project placeholders in those copied sources, initializes git unless
disabled, checks out `dev`, updates the generated backlog project name when the Backlog.md CLI is available,
and can optionally run the generated-project setup script. It resolves both its source and destination
physically and rejects the maintainer repository and all of its descendants before copying, including when
`--force` is set.

No separate `verify-template` script is part of the design at this point. Structural checks can live inline
in CI and in the maintainer quality gate.
