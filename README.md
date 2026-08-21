# SDLC Template

A reusable, stack-agnostic project template for BMAD-based agent development. It combines a compact process
router, a Backlog.md work graph, safe code-intelligence setup, and an optional architecture-as-code component.
The repository root maintains the product; the generated-project scaffold lives under `template/`.

## Project Status

This project is in early, pre-1.0 development. `dev` is the integration branch and `main` is the releasable
branch. The template is usable today, but its generated-project contract may still change between minor
releases while the project is pre-1.0.

## Layout

```text
AGENTS.md                 Maintainer instructions for this repository.
CONTRIBUTING.md           Maintainer quality gate and contribution rules.
CHANGELOG.md              Public release notes.
LICENSE                   MIT terms for repository-authored content.
docs/template-design.md   Product design record for the template itself.
docs/sdlc-persistent-subagent-sequence.html  Maintainer visual reference for the SDLC flow.
backlog/                  Real Backlog.md backlog for sdlc-template work.
scripts/init-project.sh   Creates a new project from the template payload.
.serena/project.yml       Shared Serena configuration for this maintainer repository only.
components/               Optional payload overlays selected during project generation.
  architecture/           Structurizr, Arc42, and ADR authoring component.

template/                 Files copied into a generated project root.
  AGENTS.md               Generated-project agent front door.
  CONTRIBUTING.md         Generated-project engineering conventions.
  README.md               Generated-project onboarding.
  .claude/                Generated-project backlog-protection hooks.
  docs/                   Generated-project SDLC, code-intelligence, and task-writing docs.
  licenses/SDLC-TEMPLATE-MIT.txt  License notice for copied scaffold material.
  backlog/                Empty generated-project seed backlog.
  scripts/setup.sh        Generated-project BMAD/Backlog/CodeGraph/Serena bootstrap.
  scripts/*-telemetry-off.sh  Generated-project safe code-intelligence launchers.

tests/code-intelligence-tooling.sh  Controlled setup/wrapper contract checks.
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

## Prerequisites

- Bash, Git, Perl, and standard Unix command-line tools are required to generate a project.
- Node.js with npm and `uv` are required only when installing the generated project's agent tooling.
- Docker with Compose is required only to run the optional architecture component.

## Create A New Project

Clone this maintainer repository, then generate a project into a separate destination:

```bash
git clone https://github.com/kukhta-ai/sdlc-template.git
cd sdlc-template
```

```bash
bash scripts/init-project.sh ../my-project --name "My Project"
```

Useful options:

```bash
bash scripts/init-project.sh ../my-project --name "My Project" --install-sdlc-tools
bash scripts/init-project.sh ../my-project --name "My Project" --with-architecture
bash scripts/init-project.sh ../my-project --name "My Project" --force
bash scripts/init-project.sh ../my-project --name "My Project" --no-git
```

`--force` overlays the scaffold without deleting unrelated files already in the destination.
`--install-sdlc-tools` runs the generated setup script, which uses the network and installs npm packages and
Serena's `uv` tool outside the generated repository.

The init script copies `template/` into the destination root and, when selected, layers an optional component
from `components/` on top. It then replaces placeholders, initializes git unless `--no-git` is used, checks
out `dev`, updates the generated backlog project name when the `backlog` CLI is available, and optionally
runs the generated project's `scripts/setup.sh`. For source safety, the destination cannot be the maintainer
repository or a path inside it, even with `--force`.

`--with-architecture` includes and immediately activates the architecture-as-code process, workspace, and
validation workflow. Without that option, no architecture-specific files or Docker requirement are copied.

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
bash -n template/scripts/codegraph-telemetry-off.sh
bash -n template/scripts/serena-telemetry-off.sh
bash -n components/architecture/overlay/scripts/architecture.sh
bash tests/code-intelligence-tooling.sh
git diff --check
```

For payload changes, read the copied file in `template/` and reason from the perspective of a generated
project root. Do not add maintainer-only paths such as `template/...` to generated-project instructions.

## Support and Contributions

Use [GitHub Issues](https://github.com/kukhta-ai/sdlc-template/issues) for reproducible bugs and focused
feature requests. Include the command, environment, and smallest useful reproduction; support is provided on
a best-effort basis. Contributions are welcome through pull requests; read
[`CONTRIBUTING.md`](./CONTRIBUTING.md) for the backlog, branch, review, and quality-gate conventions.

## License and Third-Party Notices

Repository-authored content is available under the [MIT License](./LICENSE). Third-party material keeps its
own license: the optional architecture component records source revisions, local adaptations, and retained
notices in [`architecture/UPSTREAM.md`](./components/architecture/overlay/architecture/UPSTREAM.md) and
[`architecture/licenses/`](./components/architecture/overlay/architecture/licenses/). Tools installed by the
generated setup script are also governed by their respective upstream licenses.

Generated projects receive the template notice at `licenses/SDLC-TEMPLATE-MIT.txt`. They remain responsible
for licensing their own application code and preserving notices that apply to copied template or selected
component material.
