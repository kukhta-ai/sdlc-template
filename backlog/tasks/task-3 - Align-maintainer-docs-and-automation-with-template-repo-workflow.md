---
id: TASK-3
title: Align maintainer docs and automation with template repo workflow
status: Done
assignee: []
created_date: '2026-06-14 10:46'
updated_date: '2026-06-14 10:50'
labels: []
dependencies: []
modified_files:
  - CONTRIBUTING.md
  - .github/PULL_REQUEST_TEMPLATE.md
  - .github/workflows/ci.yml
  - .gitignore
  - .bmad/sdlc-state.yaml
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make root contributor guidance, PR prompts, and CI describe how to maintain the template repository instead of how a generated application should be built.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Root contributor documentation distinguishes maintainer files from template payload files.
- [x] #2 Root PR guidance asks reviewers to check whether a change affects the maintainer repo, the payload, or both.
- [x] #3 Root CI runs maintainer checks without generated-project quality-gate placeholders that intentionally fail.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Updated root CONTRIBUTING.md, PR template, CI workflow, .gitignore, and maintainer state. CI now runs maintainer shell syntax and boundary checks instead of generated-project placeholder failures. Verified with bash -n scripts/init-project.sh, bash -n template/scripts/setup.sh, git diff --check, and boundary checks.
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
