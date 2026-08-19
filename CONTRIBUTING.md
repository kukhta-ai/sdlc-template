# Contributing

This guide covers work on the `sdlc-template` maintainer repository. Generated projects receive their own
copy of the process and contribution rules from `template/CONTRIBUTING.md`.

## Quality Gate

The current maintainer gate is intentionally small and stack-agnostic:

```bash
bash -n scripts/init-project.sh
bash -n template/scripts/setup.sh
bash -n template/scripts/codegraph-telemetry-off.sh
bash -n template/scripts/serena-telemetry-off.sh
bash -n components/architecture/overlay/scripts/architecture.sh
bash tests/code-intelligence-tooling.sh
git diff --check
```

Add focused checks for the files you changed. Examples:

- For the HTML SDLC diagram, extract or execute the inline JavaScript enough to catch syntax/runtime errors.
- For GitHub Actions changes, inspect the workflow YAML and keep the inline structural checks explicit.
- For setup or code-intelligence changes, use controlled fake commands to prove telemetry overrides,
  installation opt-outs, registration defaults, and validation failures without network access.
- For optional components, generate both base and selected variants and prove that their inventories differ
  only by the selected overlay. Run the component's own validation from the selected output.
- For backlog changes, use `backlog task list --plain` and `backlog sequence list` to confirm the active root backlog is readable.

Do not add a separate `verify-template` script unless the project explicitly decides to introduce one later.

## Root Versus Template Payload

- Root `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `docs/`, `scripts/`, `.serena/`, and `backlog/` are for maintaining this repository.
- `template/` contains the base files copied into every new project.
- `components/*/overlay/` contains optional files copied only when that component is selected.
- `template/AGENTS.md` is product content, not the active instruction file for this repository.
- `template/backlog/` is a seed fixture, not the active work tracker.

When editing payload files, check that paths and instructions make sense after the contents of `template/`
are copied into a new repository root.

## Backlog

All `sdlc-template` work is tracked in the root `backlog/` directory and must be operated through the
Backlog.md CLI. Never hand-edit files under root `backlog/`.

```bash
backlog task list --plain
backlog sequence list
backlog task <id> --plain
backlog task create "Title" --ac "Observable outcome"
backlog task edit <id> -s "In Progress"
backlog task edit <id> --check-ac <n>
backlog task edit <id> --check-dod <n>
backlog task edit <id> -s "Done"
```

## Branching

Use `dev` as the integration branch and create feature branches for template work:

```bash
git checkout dev
git checkout -b feature/<topic>
```

Generated-project branch conventions are part of the payload and live in `template/CONTRIBUTING.md`.

## Pull Requests

A PR should explain whether it changes the maintainer repo, the generated-project payload, or both. Include
the root backlog task ID and the checks you ran. Do not self-merge to `dev` or `main`.
