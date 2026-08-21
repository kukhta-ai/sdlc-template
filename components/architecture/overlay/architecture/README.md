# Architecture as code for __PROJECT_NAME__

This component is active in this project. It provides a local Structurizr workspace for C4 diagrams, Arc42
documentation, and Architecture Decision Records (ADRs). The source files are canonical; generated
Structurizr Local state is ignored.

Docker with the Compose plugin is the only runtime prerequisite. It is not installed or started by the
project bootstrap.

## Everyday commands

Run commands from the project root:

```bash
bash scripts/architecture.sh up
bash scripts/architecture.sh validate
bash scripts/architecture.sh down
```

The target workspace opens at <http://127.0.0.1:8081/>. Its direct views are:

- diagrams: <http://127.0.0.1:8081/workspace/1/diagrams>
- documentation: <http://127.0.0.1:8081/workspace/1/documentation>
- decisions: <http://127.0.0.1:8081/workspace/1/decisions>

The target is the only default service. To inspect the optional baseline separately:

```bash
bash scripts/architecture.sh up baseline
```

It opens at <http://127.0.0.1:8082/>. `bash scripts/architecture.sh down` deliberately selects the optional
profile too, so it removes either workspace and the Compose network.

Override a conflicting host port without editing Compose:

```bash
STRUCTURIZR_TARGET_PORT=18081 bash scripts/architecture.sh up
```

If two checkouts of the same project run at once, give each one a distinct Compose project name and reuse it
for shutdown:

```bash
COMPOSE_PROJECT_NAME=my-project-architecture-review bash scripts/architecture.sh up
COMPOSE_PROJECT_NAME=my-project-architecture-review bash scripts/architecture.sh down
```

## Source layout

```text
architecture/
  base/       shared Structurizr archetypes and styles
  baseline/   optional as-is model for an existing system
  target/     canonical target model, views, Arc42 sections, and ADRs
```

For a greenfield project, edit `target/model.dsl`, `target/views.dsl`, the relevant files under
`target/docs/src/`, and `target/adrs/`. The target initially extends `base/workspace.dsl`.

For brownfield redesign, first model the current system in `baseline/`, validate it, then change the
`workspace extends` declaration in `target/workspace.dsl` to extend `../baseline/workspace.dsl`. Do not
inherit an empty placeholder baseline merely because the directory exists.

Keep the documentation useful rather than exhaustive. A context view, the important containers, driving
quality requirements, risks, and consequential ADRs are normally enough; complete additional Arc42 sections
only when they help a reader make or verify a decision.

## Authoring and recovery

Structurizr Local saves diagram positions and other UI state under the active workspace. These generated
files are ignored; DSL, Arc42, and ADR source remain versioned.

Compose uses UID:GID `1000:1000` by default. If the active directory is not writable by that identity on
Linux, use the owner of your checkout:

```bash
STRUCTURIZR_USER="$(id -u):$(id -g)" bash scripts/architecture.sh up
```

Inspect startup failures with:

```bash
docker compose -f architecture/compose.yaml logs target-architecture
```

The application-side URL allowlist is empty. Keep themes, icons, includes, and other runtime inputs in this
repository rather than loading them remotely.

## Provenance and licenses

This component is a curated integration rather than a complete copy of MASAD. Source revisions and local
adaptations are recorded in [`UPSTREAM.md`](UPSTREAM.md). Third-party license notices are under `licenses/`.
