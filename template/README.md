# SDLC Template

A **stack-agnostic** starting point for a new repository that is developed by an **autonomous, BMAD-based
agent SDLC**: specialist agent personas, a Backlog.md task graph, sequential git branching, and human gates
at the points that matter. Clone it, point an agent at `AGENTS.md`, and the project builds itself task by
task under a process you can audit.

It ships the **process layer** plus product-decision skills — nothing here assumes a language or toolchain.
You plug in your stack's build/lint/test commands in one place (the **quality gate**), and the whole process
(pre-commit, CI, the backlog Definition of Done) refers back to it.

## What's in it

```
AGENTS.md            Agent front door: 3 hard rules, the 7-phase BMAD SDLC, state tracker, per-story loop.
CLAUDE.md            → symlink to AGENTS.md (so Claude Code reads the same front door).
docs/
  SDLC.md            The full process as a Mermaid sequence diagram (the authoritative flow).
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
scripts/setup.sh     Installs the agent tooling (Backlog.md + BMAD modules) at pinned versions.
.gitignore           Transient/local state only — BMAD's install is committed to your project, not ignored.
```

The template itself ships **without** the BMAD install, but it does include Next Move Theory canon + skills.
You add BMAD in your project: `scripts/setup.sh` runs the standard `npx bmad-method install` at init,
creating `_bmad/` + `.claude/skills/bmad-*`, which you then **commit** — the `.gitignore` does not exclude
them, so the SDLC tooling lives in your repo at a pinned version (the same as the source project). Only
personal `_bmad/custom/*.user.toml` stays local.

## Bootstrap a new project

1. **Start the repo from this template** (clone, copy, or "Use this template" on GitHub). Initialize git and
   create the working branches: `git checkout -b dev`.
2. **Install the agent tooling:**
   ```
   bash scripts/setup.sh
   ```
   This installs the Backlog.md CLI and the BMAD modules at pinned versions — see
   [Dependencies](#dependencies) for what each is and the by-hand commands.
3. **Name the project** (via the CLI — never hand-edit `backlog/`):
   ```
   backlog config set project_name "<your-project>"   # see: backlog config --help
   ```
   and replace `__PROJECT_NAME__` wherever it appears.
4. **Define your quality gate** — fill in `CONTRIBUTING.md` → "Quality gate" with your stack's real
   build/lint/test commands, then mirror them into `.github/workflows/ci.yml`, the pre-commit hook, and
   `backlog/config.yml` → `definition_of_done`.
5. **Point your agent at `AGENTS.md`** and begin the SDLC at Phase 1. For a greenfield project the early
   phases produce the design set; if you already have committed design docs in `docs/`, the early phases
   become conformance reviews (see `AGENTS.md` → "How the design set maps onto BMAD").

## What to customize per project

- **`__PROJECT_NAME__`** placeholders (backlog config, etc.).
- **The quality gate** (`CONTRIBUTING.md`) and its mirrors (CI, pre-commit, backlog DoD).
- **Your language toolchain** — add it as your first groundwork, and its ignores (`.gitignore`).
- **`docs/`** — add your design set; `AGENTS.md` mandates reading it before any work.
- **Rewrite this README** for your project once the scaffold is initialized.

## Dependencies

This template ships the **process layer** and the Next Move Theory product-decision canon + skills. The BMAD
agent SDLC tooling is installed at project init by `scripts/setup.sh` (the standard `npx bmad-method
install`) at pinned versions and **committed to your project** (the `.gitignore` does not exclude `_bmad/`
or `.claude/skills/`; only personal config stays local):

- **[Backlog.md](https://github.com/MrLesk/Backlog.md)** — the markdown task tracker the whole SDLC runs on
  (`backlog/`). Installed as a global CLI.
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

**To run that tooling at all** you need **Node.js + npm** (only to *run* Backlog.md and BMAD via `npx`) and
an agent harness that reads `AGENTS.md` / `CLAUDE.md` and can invoke the BMAD skills (e.g. Claude Code).

> `scripts/setup.sh` installs the **agent tooling only.** Your project's own language toolchain (compiler,
> linter, test runner) is a separate concern — add it as your first groundwork and wire its commands into
> the **quality gate** (`CONTRIBUTING.md`), CI, the pre-commit hook, and `backlog/config.yml`.
