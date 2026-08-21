---
id: TASK-8
title: Remove bundled Next Move Theory content
status: Done
assignee: []
created_date: '2026-08-20 12:18'
updated_date: '2026-08-21 13:14'
labels: []
dependencies: []
references:
  - docs/template-design.md
modified_files:
  - .github/workflows/ci.yml
  - README.md
  - docs/template-design.md
  - template/.gitignore
  - template/AGENTS.md
  - template/README.md
  - template/.agents/skills/
  - template/.claude/skills/
  - template/Next-Move-Theory-Canon/
  - template/NextMoveTheory-README.md
  - template/.nmt-version
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove the CC BY-NC-SA Next Move Theory payload and every active integration claim so the current repository tree and newly generated projects contain only the retained SDLC template surfaces.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 No NMT canon, skill, contract, README copy, or version marker remains tracked in the current template payload.
- [x] #2 Base and architecture project generation produce no NMT path, invocation, marker, installer, or integration reference.
- [x] #3 Maintainer and generated-project documentation no longer claims NMT is bundled, supported, or optional.
- [x] #4 BMAD, Backlog.md, code-intelligence tooling, architecture, and backlog-protection hooks retain their existing behavior.
- [x] #5 CI and focused checks reject regenerated NMT surface and all maintained quality gates pass.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Delete the vendored NMT payload, remove its marker-delimited routing block and documentation claims, add generated-output negative assertions, and verify both initializer variants plus retained gates.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation used repository-native git/rg discovery in an isolated worktree; CodeGraph and Serena were not invoked. Removed 53 bundled NMT files and the marker-delimited routing block, updated maintainer/payload documentation, and added CI assertions over source plus both generated variants. Shell syntax, YAML parse, diff check, code-intelligence safety tests, base/architecture generation, inventory parity, Docker Compose config, and architecture validation passed. Private Git history still contains earlier NMT commits and was intentionally not rewritten.

Continuation review replaced the ignored .tmp spec reference with the durable design record. The completed task is archived so a later feature branch can retain its independently allocated active TASK-8 without an active-backlog collision.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
The current feature tree and both generated-project variants contain no bundled or optional NMT surface. Retained BMAD, Backlog.md, code-intelligence, architecture, symlink, and hook boundaries remain green.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
