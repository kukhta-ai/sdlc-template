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
root backlog/            Real maintenance backlog for sdlc-template tasks.
template/backlog/        Empty seed backlog fixture for generated projects.
scripts/init-project.sh  Maintainer script that creates a project from template/.
template/scripts/setup.sh Generated-project bootstrap for Backlog.md and BMAD tooling.
```

Root `AGENTS.md` is the active instruction file for this repository. `template/AGENTS.md` is product content.
After `template/` is copied into a destination project, that copied `AGENTS.md` becomes active for the new
project.

## Generated Project Contract

A generated project should see the same shape the original template promised:

- `AGENTS.md` at repo root
- `CONTRIBUTING.md` at repo root
- `docs/SDLC.md` and `docs/task-writing-conventions.md`
- an empty initialized `backlog/`
- `.bmad/sdlc-state.yaml`
- `.claude/` backlog-protection hooks and Claude-compatible Next Move Theory skills
- `.agents/skills/` Codex-compatible Next Move Theory skills
- `Next-Move-Theory-Canon/`, `.nmt-version`, and `NextMoveTheory-README.md` for the installed NMT skill
  family
- `.github/` CI and PR template
- `scripts/setup.sh` for Backlog.md and BMAD installation

The payload should not mention `template/` in normal generated-project instructions, because that directory
will not exist after copying.

## Initializer Contract

`scripts/init-project.sh` copies the payload to a destination directory, replaces project placeholders,
initializes git unless disabled, checks out `dev`, updates the generated backlog project name when the
Backlog.md CLI is available, and can optionally run the generated-project setup script.

No separate `verify-template` script is part of the design at this point. Structural checks can live inline
in CI and in the maintainer quality gate.
