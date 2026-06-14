# AGENTS.md - sdlc-template maintainer front door

This file governs work in this repository, which maintains the reusable SDLC template. It is not the
front door that generated projects receive. Generated-project instructions live at `template/AGENTS.md` and
become active only after `template/` is copied to a new project root.

## Repository Boundary

- Root files describe and maintain the `sdlc-template` product itself.
- `template/` is the payload copied into new repositories.
- `backlog/` is the real maintenance backlog for this repository.
- `template/backlog/` is an inert seed backlog fixture for generated repositories.
- `scripts/init-project.sh` creates a new repository from `template/`.
- `template/scripts/setup.sh` is the bootstrap script generated projects run after creation.

When editing the payload, preserve paths as they will appear after copying to a generated project root. Do
not make payload files refer to `template/` unless the text is explicitly about this maintainer repository.

## Before Work

1. Read `README.md` for the maintainer workflow.
2. Read `docs/template-design.md` for the product design record.
3. If the change touches the payload, read the relevant files under `template/` as generated-project source.
4. Read `backlog task list --plain` and `backlog sequence list` before changing tracked work state.

Do not use `template/AGENTS.md` as the active instruction file while working in this repository. It is a
fixture whose contents are part of the product.

## Backlog Rules

Operate the root maintenance backlog only through the Backlog.md CLI. Never hand-edit files under root
`backlog/`.

Common commands:

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

`template/backlog/` is copied as a fixture. Change it deliberately only when changing the generated-project
seed, and do not confuse it with the active root backlog.

## Quality Gate

For this repository, the current quality gate is the maintainer gate in `CONTRIBUTING.md`:

```bash
bash -n scripts/init-project.sh
bash -n template/scripts/setup.sh
git diff --check
```

Also run any focused checks that match the files you touched. For example, if you change the HTML diagram,
syntax-check or execute its inline script in the same way the change requires.

## Branching

Use feature branches from `dev` for template-maintenance work. Keep generated-project branch conventions in
`template/CONTRIBUTING.md`; root branch guidance describes this repository only.

## User Gates

Stop for a human decision before changing the template contract in a way that would break existing generated
projects, before deleting payload surface area, or before merging to `dev` or `main`.
