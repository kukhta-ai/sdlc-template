# SDLC Template Maintainer Repository

This repository maintains a reusable, stack-agnostic project template for BMAD-based agent development. The
repo root is the maintainer project. The generated-project scaffold lives under `template/`.

## Layout

```text
AGENTS.md                 Maintainer instructions for this repository.
CONTRIBUTING.md           Maintainer quality gate and contribution rules.
docs/template-design.md   Product design record for the template itself.
backlog/                  Real Backlog.md backlog for sdlc-template work.
scripts/init-project.sh   Creates a new project from the template payload.

template/                 Files copied into a generated project root.
  AGENTS.md               Generated-project agent front door.
  CONTRIBUTING.md         Generated-project engineering conventions.
  README.md               Generated-project onboarding.
  docs/                   Generated-project SDLC docs.
  backlog/                Empty generated-project seed backlog.
  scripts/setup.sh        Generated-project BMAD/Backlog bootstrap.
```

The root and payload intentionally have different meanings. When an agent is working in this repository, it
follows root `AGENTS.md`. When a new project is created from `template/`, that project follows the copied
`AGENTS.md` at its own root.

## Create A New Project

```bash
bash scripts/init-project.sh ../my-project --name "My Project"
```

Useful options:

```bash
bash scripts/init-project.sh ../my-project --name "My Project" --install-sdlc-tools
bash scripts/init-project.sh ../my-project --name "My Project" --force
bash scripts/init-project.sh ../my-project --name "My Project" --no-git
```

The init script copies `template/` into the destination root, replaces placeholders, initializes git unless
`--no-git` is used, checks out `dev`, updates the generated backlog project name when the `backlog` CLI is
available, and optionally runs the generated project's `scripts/setup.sh`.

## Maintain The Template

Use the root backlog for work on this repository:

```bash
backlog task list --plain
backlog sequence list
```

Run the maintainer quality gate before review:

```bash
bash -n scripts/init-project.sh
bash -n template/scripts/setup.sh
git diff --check
```

For payload changes, read the copied file in `template/` and reason from the perspective of a generated
project root. Do not add maintainer-only paths such as `template/...` to generated-project instructions.
