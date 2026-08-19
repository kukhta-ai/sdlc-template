# SDLC Template

A **stack-agnostic** starting point for a new repository that is developed by an **autonomous, BMAD-based
agent SDLC**: a lightweight process router for everyday work plus specialist agent personas, a Backlog.md
task graph, sequential git branching, and human gates for full development tasks. Clone it and point an
agent at `AGENTS.md`; the router selects the narrowest matching process.

It ships the **process layer** plus product-decision skills — nothing here assumes a language or toolchain.
You plug in your stack's build/lint/test commands in one place (the **quality gate**), and the whole process
(pre-commit, CI, the backlog Definition of Done) refers back to it.

## What's in it

```
AGENTS.md            Process router, focused-work default, and full BMAD development process.
CLAUDE.md            → symlink to AGENTS.md (so Claude Code reads the same front door).
docs/
  SDLC.md            The full process as a Mermaid sequence diagram (the authoritative flow).
  code-intelligence-tools.md    CodeGraph + Serena safety, install, and discovery contract.
  task-writing-conventions.md   The what-not-how acceptance-criteria contract every task obeys.
CONTRIBUTING.md      Quality gate (you fill in) + branching / PR / versioning conventions.
CHANGELOG.md         Keep-a-Changelog stub.
backlog/             Backlog.md, initialized: config.yml (placeholder name + DoD) + empty task dirs.
.bmad/sdlc-state.yaml  Blank SDLC state tracker — Step 0 fills it in.
.claude/             Hookify backlog-protection rules + Claude-compatible Next Move Theory skills.
.agents/skills/      Codex-compatible Next Move Theory skills, invoked as $nmt-...
Next-Move-Theory-Canon/        Canon read by the Next Move Theory skills.
NextMoveTheory-README.md       Reference README for the installed Next Move Theory skill family.
.nmt-version         Installed Next Move Theory version marker.
.github/             CI workflow (placeholder quality gate) + PR template.
scripts/setup.sh     Installs Backlog.md, BMAD, CodeGraph, and Serena at pinned versions.
scripts/codegraph-telemetry-off.sh  Runs installed CodeGraph reporting-off with self-download disabled.
scripts/serena-telemetry-off.sh     Runs installed Serena reporting-off; MCP starts read-only.
.gitignore           Transient/local state only — BMAD's install is committed to your project, not ignored.
```

The template itself ships **without** the BMAD install, but it does include Next Move Theory canon + skills.
`scripts/setup.sh` installs BMAD and the code-intelligence CLIs. Commit BMAD's `_bmad/` and
`.claude/skills/bmad-*` plus Serena's `.serena/project.yml`; CodeGraph's index, Serena caches/logs, and
personal configuration stay local.

An installed extension may register a process under `.sdlc/processes/`. If that directory is absent, no
process extension is active and agents must not infer or fetch one.

## Bootstrap a new project

1. **Start the repo from this template** (clone, copy, or "Use this template" on GitHub). Initialize git and
   create the working branches: `git checkout -b dev`.
2. **Install the agent tooling:**
   ```
   bash scripts/setup.sh
   ```
   This installs the Backlog.md CLI, BMAD modules, CodeGraph, and Serena at pinned versions — see
   [Dependencies](#dependencies) for what each is and the by-hand commands.
3. **Name the project** (via the CLI — never hand-edit `backlog/`):
   ```
   backlog config set project_name "<your-project>"   # see: backlog config --help
   ```
   and replace `__PROJECT_NAME__` wherever it appears.
4. **Define your quality gate** — fill in `CONTRIBUTING.md` → "Quality gate" with your stack's real
   build/lint/test commands, then mirror them into `.github/workflows/ci.yml`, the pre-commit hook, and
   `backlog/config.yml` → `definition_of_done`.
5. **Point your agent at `AGENTS.md`.** Focused work is the default. A qualifying Backlog.md implementation
   task enters or resumes Full SDLC from the recorded state; an explicit greenfield full-process request
   starts at Phase 1. With committed design docs, early phases become conformance reviews.

## What to customize per project

- **`__PROJECT_NAME__`** placeholders (backlog config, etc.).
- **The quality gate** (`CONTRIBUTING.md`) and its mirrors (CI, pre-commit, backlog DoD).
- **Your language toolchain** — add it as your first groundwork, and its ignores (`.gitignore`).
- **`docs/`** — add your design set; `AGENTS.md` mandates reading it before Full SDLC development.
- **Rewrite this README** for your project once the scaffold is initialized.

## Dependencies

This template ships the **process layer** and the Next Move Theory product-decision canon + skills. BMAD,
CodeGraph, and Serena are installed at project init by `scripts/setup.sh`. BMAD is committed to your project;
code-intelligence indexes and personal configuration remain local:

- **[Backlog.md](https://github.com/MrLesk/Backlog.md)** — the markdown task tracker the whole SDLC runs on
  (`backlog/`). Installed as a global CLI.
- **[CodeGraph](https://github.com/colbymchenry/codegraph)** — indexed structural discovery for entry
  points, flows, call paths, and blast radius. Project wrappers force telemetry off.
- **[Serena](https://github.com/oraios/serena)** — semantic discovery for symbol overview and references.
  Project wrappers force usage reporting off.
- **[Next Move Theory](https://github.com/zamesin/Next-Move-Theory-Canon-and-Skills)** — preinstalled canon
  and NMT skills for product strategy, market research, value proposition, PRD, go-to-market, diagnosis, and
  interview analysis. Claude Code invokes them as `/nmt-...`; Codex invokes them as `$nmt-...`.
- **BMAD** modules, via `npx bmad-method install`:
  - `bmm` — the core method: the planning + build personas (analyst, pm, architect, sm, dev, tea, …) and
    their workflows.
  - `tea` — test architecture: the `testarch-*` workflows.
  - `automator` — the autonomous per-story build/review loop (SDLC Phase 5).

  By hand, equivalently:
  ```
  npx bmad-method install --modules bmm,tea
  npx bmad-method install --modules automator
  ```
  After installing, record the exact versions into `.bmad/sdlc-state.yaml` → `tooling`.

**To run that tooling** you need **Node.js + npm** (Backlog.md, BMAD, CodeGraph), **uv** (Serena), and an
agent harness that reads `AGENTS.md` / `CLAUDE.md` and can invoke the BMAD skills.

Code-intelligence installation can be disabled without triggering a download or client registration:

```bash
INSTALL_CODEGRAPH=0 INSTALL_SERENA=0 bash scripts/setup.sh
```

MCP client registration is also disabled by default. Enable it explicitly with `CODEGRAPH_SETUP_CLIENTS`
and `SERENA_SETUP_CLIENTS`; setup assigns project-specific names and launches only this project's
telemetry-off wrappers. See `docs/code-intelligence-tools.md` for supported clients and safety guarantees.

> `scripts/setup.sh` installs the **agent tooling only.** Your project's own language toolchain (compiler,
> linter, test runner) is a separate concern — add it as your first groundwork and wire its commands into
> the **quality gate** (`CONTRIBUTING.md`), CI, the pre-commit hook, and `backlog/config.yml`.
