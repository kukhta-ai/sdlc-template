---
id: TASK-6
title: Add code-intelligence tooling and process routing
status: Done
assignee: []
created_date: '2026-08-19 14:58'
updated_date: '2026-08-19 15:48'
labels: []
dependencies: []
references:
  - docs/template-design.md
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Generated projects need a lightweight default process and optional code discovery that remains safe, resumable, and isolated from deferred component and visual work.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Generated projects use focused work by default, enter Full SDLC only for qualifying requests, and activate only process extensions that are present locally.
- [x] #2 CodeGraph and Serena tooling is pinned and every project-supplied launch path forces usage reporting and telemetry controls off even when inherited environment values are hostile.
- [x] #3 Installation opt-outs perform no tool download, initialization, or client registration, while invalid switches and client selections fail with a clear error.
- [x] #4 MCP client registration is disabled by default and explicit registrations use project-specific names and project-local launch commands.
- [x] #5 Story sizing is recorded in the seeded state contract, and an XL story remains unclaimed until it is split or a human explicitly accepts continuation.
- [x] #6 The review range contains process-routing and code-intelligence surfaces without deferred component or diagram assets.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the focused-work router, local process-extension contract, pre-claim story sizing, read-only CodeGraph/Serena discovery state, pinned setup, forced-reporting-off wrappers, explicit project-specific client registration, maintainer Serena configuration, and controlled fake-command tests. Verified shell syntax, hostile telemetry overrides, authoritative opt-outs, invalid-input failures, both supported clients, generated output in a path containing spaces, pinned live CLI surfaces, YAML parsing, Serena health, scope exclusions, and git whitespace.

Adversarial review hardening: removed Bash 4-only lowercase expansion; blocked CodeGraph shim downloads; verified the executable versions resolved on PATH; bound MCP registrations to the generated-project root; forced Serena MCP planning mode and read-only project configuration; preflighted requested client binaries; clarified XL gate cleanup and generic story-shaping extension timing; made focused fallbacks state-neutral; and added hermetic default, initialization, override, missing-client, and wrong-version tests.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Generated projects now default to focused work and gain safe, resumable code-intelligence discovery without taking ownership of deferred component or visual work.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 The project quality gate is green: build/type-check clean, linter/formatter clean (see CONTRIBUTING.md > Quality gate)
- [x] #2 Tests added and green: unit for pure logic, integration where it touches external edges
- [x] #3 Public interfaces documented; no dead code; architectural boundaries respected
<!-- DOD:END -->
