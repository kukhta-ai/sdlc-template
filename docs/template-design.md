# SDLC Template — design record

*Meta-doc: this records why the template is shaped the way it is. It is **not** part of the process a
generated project follows — delete it once you've read it.*

## Purpose

Turn the proven SDLC infrastructure of an existing project (`work-package-manager`, "wpm") into a reusable,
**stack-agnostic** template that bootstraps new repositories with the same autonomous, BMAD-based agent SDLC.
The goal is to keep the *structure* (the valuable part) and strip all project- and language-specific
*content*.

## Source

wpm shipped: a BMAD install (`bmm` + `tea` + `automator`), a strong `AGENTS.md` front door, `docs/SDLC.md`
(the process as a Mermaid sequence) + `docs/task-writing-conventions.md`, an initialized Backlog.md backlog,
two hookify rules forbidding manual backlog edits, a TS/Node toolchain (Biome + Vitest + tsc + husky + matrix
CI), and a `FOUNDATION.md` describing the bootstrap.

## Decisions

1. **BMAD: installed at init, then committed to the project — not pre-bundled into the template.** The
   template itself ships **no** BMAD files (it stays lean). Instead `scripts/setup.sh` runs the standard `npx
   bmad-method install` when you start a project, creating `_bmad/` + `.claude/skills/bmad-*`, which are then
   **committed to that project** — the template's `.gitignore` (which becomes the project's) does not exclude
   them, matching the source project, so each project carries a pinned, in-repo copy of its SDLC tooling. Only
   personal `_bmad/custom/*.user.toml` stays local (BMAD's own nested ignore). This keeps the *template*
   lightweight without making *projects* re-install on every clone. (wpm's `_bmad/custom/` overrides were
   empty installer stubs — nothing project-specific to preserve.)

2. **Fully genericize.** A template carrying wpm's 33 hexagon tasks and `docs/00–14` references would be a
   copy, not a template. Project-specific content is replaced with placeholders (`__PROJECT_NAME__`,
   `<epic>`, `feature/<epic>`); the backlog ships empty; the SDLC docs describe the *process*, not wpm.

3. **Stack-agnostic (no language baked in).** The reusable value is the **process layer**, which is entirely
   language-neutral. The TS/Node **toolchain layer** is dropped. Everywhere wpm hardcoded `tsc + biome +
   vitest`, the template refers to the project's **quality gate** — an abstract contract (build/type-check
   clean, lint/format clean, tests green) that each project makes concrete in one place.

## The two-layer model

| Layer | Status | Files |
|---|---|---|
| **Process (kept, genericized)** | language-neutral | `AGENTS.md`, `CLAUDE.md`, `docs/SDLC.md`, `docs/task-writing-conventions.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `backlog/`, `.bmad/sdlc-state.yaml`, `.claude/hookify.*`, `scripts/setup.sh`, `.github/`, `.gitignore` |
| **Toolchain (dropped)** | language-specific | ~~`package.json`, `biome.json`, `tsconfig*.json`, `vitest.config.ts`, husky/lint-staged~~ → replaced by the **quality gate** abstraction + TODO slots |

## The quality-gate abstraction

The single idea that makes "stack-agnostic" coherent: a project declares its concrete build/lint/test
commands **once** (in `CONTRIBUTING.md` → "Quality gate"), and the same gate is wired identically into three
enforcement points:

- the **pre-commit hook** (staged files),
- **CI** (`.github/workflows/ci.yml`, across the support matrix), and
- the **backlog Definition of Done** (`backlog/config.yml` → `definition_of_done`).

"Same gate everywhere — no separate, stricter CI-only bar" was wpm's principle; abstracting the commands
preserves it for any language. The CI skeleton's placeholder steps **fail on purpose** so an unconfigured
gate is loudly red, never silently green.

## Generalization from wpm

wpm assumed a *pre-existing* committed spec (`docs/00–14`), so its planning phases were "conformance
reviews." The template defaults to **greenfield**: the BMAD planning personas (analyst → pm → architect)
*produce* the design set, with "spec already exists → conformance review" documented as a variant. This
makes the template useful both for projects that start from an idea and for those that start from docs.

## Backlog-CLI discipline

Backlog.md is operated **only** through its CLI; `backlog/` is never hand-edited. This is stated in
`AGENTS.md` (hard rule 1), repeated in `CONTRIBUTING.md`, and **mechanically enforced** by the two hookify
rules in `.claude/` (one for file writes, one for shell writes), which carry a `templates/` carve-out for
shipped scaffold content. The regexes are reused verbatim from wpm (tested); only the prose was genericized.

## Per-project customization points

`__PROJECT_NAME__` placeholders; the quality gate + its three mirrors; the language toolchain and its
`.gitignore` entries; the `docs/` design set; and deletion of the meta files (`README.md` rewrite, this
file).
