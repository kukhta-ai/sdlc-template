---
id: TASK-5
title: Move SDLC HTML diagram to maintainer docs
status: Done
assignee: []
created_date: '2026-06-14 11:11'
updated_date: '2026-06-14 11:12'
labels: []
dependencies: []
modified_files:
  - docs/sdlc-persistent-subagent-sequence.html
  - template/docs/sdlc-persistent-subagent-sequence.html
  - README.md
  - .github/workflows/ci.yml
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Treat the self-contained HTML SDLC diagram as maintainer documentation instead of generated-project payload.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The HTML SDLC diagram is present under root docs/.
- [x] #2 The generated-project payload no longer includes the HTML SDLC diagram.
- [x] #3 Root documentation and CI boundary checks reflect the HTML diagram's maintainer-doc location.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Moved sdlc-persistent-subagent-sequence.html from template/docs/ to root docs/. Updated README layout and CI boundary checks to treat it as maintainer documentation. Verified with html-boundary-ok, bash -n scripts/init-project.sh, bash -n template/scripts/setup.sh, git diff --check, and node --check on extracted inline JavaScript.
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
