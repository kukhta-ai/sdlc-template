# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (see
[`CONTRIBUTING.md` → Versioning and Releases](./CONTRIBUTING.md#versioning-and-releases)).

## [Unreleased]

### Added

- Maintainer and generated-project contexts with separate instructions, documentation, and backlogs.
- A project initializer that copies the base payload, replaces project placeholders, initializes `dev`, and
  can install the generated project's agent tooling.
- A generated-project process router for focused work and BMAD-based full-SDLC development.
- Backlog.md, CodeGraph, and Serena setup with pinned versions, explicit telemetry controls, and safe local
  fallbacks.
- A selectable architecture-as-code component with Structurizr, Arc42, ADR guidance, provenance, and
  retained third-party license notices.
- MIT licensing for repository-authored and copied scaffold material, with separately retained third-party
  notices.
- CI checks for the maintainer boundary, base and architecture project generation, and retained tooling
  safety contracts.

---

When the first release is cut, move these entries under a dated `## [X.Y.Z] - YYYY-MM-DD` heading and leave
a fresh `## [Unreleased]` section — see [`CONTRIBUTING.md` → Changelog](./CONTRIBUTING.md#changelog).
