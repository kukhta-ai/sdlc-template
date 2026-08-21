---
id: TASK-7
title: Add selectable architecture-as-code component
status: Done
assignee: []
created_date: '2026-08-19 15:20'
updated_date: '2026-08-19 15:51'
labels: []
dependencies:
  - TASK-6
references:
  - docs/template-design.md
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Generated projects need an opt-in architecture authoring surface that is active when selected, absent from the base payload, and integrated through the generic process-extension contract.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Projects generated without architecture selection contain only the base payload and no architecture-specific files, process registration, or runtime requirement.
- [x] #2 Projects generated with architecture selection contain a parameterized, active Structurizr, Arc42, and ADR workspace with documented operating commands.
- [x] #3 The installed architecture process synchronizes canonical architecture after Full SDLC solutioning and supplies focused design context only for stories with matching architecture pressure.
- [x] #4 Both generation modes preserve their exact payload boundaries, and the selected workspace is valid under its Compose and DSL contracts.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the opt-in architecture overlay, collision-safe initializer path, provider-neutral process registration, Phase 3 synchronization, qualifying story design notes, pinned hardened Structurizr runtime, Arc42/ADR sources, and additive CI checks. Verified source-boundary rejection, base-versus-selected exact inventories, quoted/backslash placeholder substitution, no maintainer path leaks, Compose defaults/profiles, both DSL workspaces, target/baseline HTTP routes with the documented owner override, code-intelligence regression tests, YAML, scope exclusions, and whitespace.

Adversarial review hardening: the initializer now resolves destinations physically and rejects the maintainer repository or any descendant even with --force; CI proves that guard in an isolated source fixture; and the extension declares the exact Full SDLC story-shaping compatibility consumed by the generic loader.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Generated projects remain architecture-free by default; --with-architecture now adds an immediately active, validated Structurizr/Arc42/ADR component whose Full SDLC behavior stays inside the selected process extension.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
