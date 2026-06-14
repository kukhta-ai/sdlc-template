---
id: TASK-1
title: Separate maintainer repo from generated-project payload
status: Done
assignee: []
created_date: '2026-06-14 10:46'
updated_date: '2026-06-14 10:50'
labels: []
dependencies: []
modified_files:
  - AGENTS.md
  - README.md
  - docs/template-design.md
  - template/README.md
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Clarify the repository boundary so agents working on sdlc-template follow root maintainer instructions while generated projects receive their own copied scaffold from template/.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Generated-project scaffold files live under template/ with the same relative paths they will have at a generated project root.
- [x] #2 Root maintainer instructions identify template/ as payload and root backlog/ as the active sdlc-template work tracker.
- [x] #3 Generated-project onboarding in template/ does not reference maintainer-only files that are absent after copying.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented root/template boundary: generated-project scaffold copied under template/, root AGENTS/README/CONTRIBUTING/docs now describe template maintenance, template README no longer references maintainer-only docs/template-design.md. Verified with root-boundary-ok, payload-boundary-ok, maintainer gate, and init-project smoke test.
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
