---
id: TASK-4
title: Document README context usage
status: Done
assignee: []
created_date: '2026-06-14 11:05'
updated_date: '2026-06-14 11:05'
labels: []
dependencies: []
modified_files:
  - README.md
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make the maintainer README clearer about which repository context applies when maintaining the template, editing payload files, creating a project, or working in a generated project.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 README explains which root files are active context for maintaining sdlc-template.
- [x] #2 README explains how to reason about files under template/ as generated-project root files.
- [x] #3 README gives concrete examples for asking an agent to work in the intended context.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Added README section 'How To Use The Context' with a context table, root context reading guidance, payload path guidance, and example agent prompts. Verified with bash -n scripts/init-project.sh, bash -n template/scripts/setup.sh, and git diff --check.
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
