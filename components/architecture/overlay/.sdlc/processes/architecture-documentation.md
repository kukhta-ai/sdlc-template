# Architecture documentation process

This installed process is active; the extension loader in `AGENTS.md` registers it alongside the built-in
process catalog without another activation step.

- **Trigger:** The user asks to create, change, review, or render C4 models, Arc42 documentation, deployment
  views, or ADRs. Full SDLC invokes it after Phase 3 `create-architecture`, and during story shaping for an
  `S` story that changes a documented boundary, an `M` story with material design pressure, every `L` story,
  and every human-approved `XL` story.
- **May touch:** `architecture/**`, `docs/architecture.md`, and BMAD architecture or story artifacts that
  point to those canonical sources. Standalone use does not own backlog status, BMAD phase state, branches,
  or PRs; during Full SDLC, the parent process retains that ownership.
- **Required context:** Read `docs/architecture.md`, `architecture/README.md`, the existing target DSL,
  relevant Arc42 sections and ADRs, the task acceptance criteria and design docs, and the smallest useful
  product/code context. Consume the CodeGraph/Serena discovery note when one is available. For brownfield
  work, read the baseline too.
- **Gates/checks:** Run `bash scripts/architecture.sh validate`. Render affected views and documentation in
  Structurizr Local when the change affects user-visible output. Stop for a human before changing accepted
  scope, a public contract, an established system boundary, or an accepted consequential decision; also stop
  before promoting target state to baseline or deleting documented architecture.
- **Exit:** Canonical source is internally consistent, validation passes, affected browser output is usable,
  generated state remains ignored, and the design note, decisions, or remaining risks are explicit.
- **Compatibility:** May run alone for focused architecture work. It is compatible with Full SDLC Phase 3
  and Full SDLC story shaping; the Full SDLC process retains ownership of task, BMAD, branch, and review
  state.

## Operating rules

1. Keep one source of truth. Update the target DSL, Arc42 section, or ADR that owns the fact; do not duplicate
   it in `docs/architecture.md` or a BMAD artifact.
2. Use the smallest useful documentation set. Context and important container views, driving qualities,
   risks, and consequential decisions are more valuable than mechanically filling every Arc42 heading.
3. For greenfield work, model the target directly from `base/`. For brownfield redesign, capture the as-is
   system in `baseline/` before making target inheritance explicit.
4. ADRs are drafted as Proposed. Only a human gate changes a consequential decision to Accepted.
5. Immediately after Full SDLC Phase 3 `create-architecture`, reconcile its output with the canonical C4,
   Arc42, and ADR sources, then make the BMAD artifact link back to `docs/architecture.md` rather than
   restating those sources.
6. During matching story shaping, consume the task acceptance criteria, relevant design documents, and the
   code-intelligence discovery note when available. Produce a short architecture note covering the selected
   design, rejected alternatives, affected boundaries or contracts, test strategy, and rollback or
   decomposition risk. Feed that note into `create-story` and `dev-story`.
7. Update canonical C4, Arc42, or ADR sources during a story only when implementation changes a documented
   boundary, runtime, deployment, quality tradeoff, or consequential decision. Do not create diagram churn
   for local implementation detail.
8. Stop at the human gate instead of silently deciding a scope, public-contract, system-boundary, or accepted
   consequential-decision change.
9. Before exit, validate both target and baseline. When visible behavior changed, start the affected
   workspace, inspect diagrams, documentation, and decisions, then run the documented `down` command.
