# Architecture component provenance

The runtime and workspace organization are derived from:

- [`kukhta-ai/masad`](https://github.com/kukhta-ai/masad), commit
  `f1e02f8ab0e02e09fbd2595bb4e171103d614812`
- parent project [`max-arshinov/masad`](https://github.com/max-arshinov/masad)
- license: MIT; retained in `licenses/MASAD-MIT.txt`

The Arc42 starter sections are derived from the official English plain AsciiDoc distribution:

- [`arc42/arc42-template`](https://github.com/arc42/arc42-template), commit
  `8dff0d9b1f9640684df8c3bbcdc2ee45f989ca0f`
- Arc42 version `9.0-EN`, July 2025
- license: [Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/);
  notice retained in `licenses/ARC42-CC-BY-SA-4.0.txt`

## Integration changes

- Kept only the base, baseline, target, documentation, and ADR kernel; upstream examples, screenshots,
  Copilot prompts, repository-level files, and fixed container names are not distributed.
- Namespaced Compose under `architecture/`, parameterized project names and ports, and made target the only
  default service.
- Defaulted the target workspace to the shared base for greenfield projects; baseline inheritance is an
  explicit brownfield choice.
- Added stable starter views and project-name placeholders.
- Replaced the older embedded Arc42 files with the official 9.0 plain starter and added safe placeholders
  where a diagram does not yet exist.
- Added the project wrapper, process registration, and path-scoped validation workflow.

Project-authored content placed into the Arc42 structure remains the project's content. Preserve the notices
in this directory when redistributing the template files themselves.
