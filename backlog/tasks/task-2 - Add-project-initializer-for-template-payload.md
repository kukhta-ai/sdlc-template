---
id: TASK-2
title: Add project initializer for template payload
status: Done
assignee: []
created_date: '2026-06-14 10:46'
updated_date: '2026-06-14 10:50'
labels: []
dependencies: []
modified_files:
  - scripts/init-project.sh
  - template/scripts/setup.sh
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Provide a root maintainer script that creates a new project by copying template/ into a destination and preparing the generated scaffold for first commit.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A root initialization command copies the template/ payload, including dotfiles, into a chosen destination directory.
- [x] #2 Project placeholders for name and slug are replaced in copied text files.
- [x] #3 The initializer can prepare a dev branch, set the generated backlog project name when Backlog.md is available, and optionally run the generated-project setup script.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Added scripts/init-project.sh. Smoke test initialized /tmp/sdlc-template-smoke from template/, copied dotfiles and payload docs, replaced placeholders, set Backlog.md projectName to Smoke Project, and checked out dev. --install-sdlc-tools remains optional and was not run to avoid network installs.
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
