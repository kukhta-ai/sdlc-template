# SDLC Template Maintainer Repository

This repository maintains a reusable, stack-agnostic project template for BMAD-based agent development. The
repo root is the maintainer project. The generated-project scaffold lives under `template/`.

## Layout

```text
AGENTS.md                 Maintainer instructions for this repository.
CONTRIBUTING.md           Maintainer quality gate and contribution rules.
docs/template-design.md   Product design record for the template itself.
docs/sdlc-persistent-subagent-sequence.html  Maintainer visual reference for the SDLC flow.
backlog/                  Real Backlog.md backlog for sdlc-template work.
scripts/init-project.sh   Creates a new project from the template payload.

template/                 Files copied into a generated project root.
  AGENTS.md               Generated-project agent front door.
  CONTRIBUTING.md         Generated-project engineering conventions.
  README.md               Generated-project onboarding.
  Next-Move-Theory-Canon/ Generated-project product-decision canon used by NMT skills.
  NextMoveTheory-README.md Reference README from the NMT skills source.
  .agents/skills/         Generated-project Codex NMT skills.
  .claude/                Generated-project backlog hooks and Claude NMT skills.
  .nmt-version            Generated-project NMT installed-version marker.
  docs/                   Generated-project SDLC docs.
  backlog/                Empty generated-project seed backlog.
  scripts/setup.sh        Generated-project BMAD/Backlog bootstrap.
```

The root and payload intentionally have different meanings. When an agent is working in this repository, it
follows root `AGENTS.md`. When a new project is created from `template/`, that project follows the copied
`AGENTS.md` at its own root.

## How To Use The Context

This repository has two contexts that must not be blended:

| Work you are doing | Use this context | Do not treat as active |
|---|---|---|
| Maintaining `sdlc-template` itself | Root `AGENTS.md`, root `README.md`, `docs/template-design.md`, root `backlog/` | `template/AGENTS.md`, `template/backlog/` |
| Changing what new projects receive | The relevant files under `template/`, read as if they are at a generated project root | Root-only paths such as `template/...` inside payload prose |
| Creating a new project | `scripts/init-project.sh` and this README | Root backlog tasks from this maintainer repo |
| Working in a generated project | The copied `AGENTS.md`, copied `docs/`, copied `backlog/` in that generated repo | This maintainer repository's root files |

For template-maintenance work, start with:

```bash
backlog task list --plain
backlog sequence list
```

Then read the root context that matches the change:

- Root workflow or contributor guidance: `AGENTS.md`, `CONTRIBUTING.md`, this `README.md`.
- Product intent and boundary decisions: `docs/template-design.md`.
- Generated-project behavior: the matching file under `template/`.
- Project initialization behavior: `scripts/init-project.sh` plus `template/scripts/setup.sh`.

When editing payload files, mentally remove the `template/` prefix. For example, `template/AGENTS.md` will
become `AGENTS.md` in the generated project. Text inside that file should therefore refer to `docs/SDLC.md`,
not `template/docs/SDLC.md`, unless it is explicitly explaining this maintainer repository.

When asking an agent to work here, be explicit about the context:

```text
Update the root maintainer README.
```

```text
Update the generated-project payload README under template/.
```

```text
Change the initializer script that copies template/ into a new repo.
```

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
