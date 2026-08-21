# Architecture documentation

This project was generated with the architecture-as-code component enabled. It is active: explicit C4,
Arc42, or ADR work uses the registered Architecture documentation process, and Full SDLC solutioning keeps
the canonical workspace in sync.

The source of truth lives under `architecture/target/`:

- `model.dsl`, `views.dsl`, and `deployment/` define the Structurizr/C4 model.
- `docs/src/` contains the Arc42 sections rendered by Structurizr Local.
- `adrs/` records consequential architecture decisions.

`architecture/baseline/` is optional as-is context for a brownfield redesign. It is not a second source of
truth for the target design.

Start, validate, and stop the workspace from the repository root:

```bash
bash scripts/architecture.sh up
bash scripts/architecture.sh validate
bash scripts/architecture.sh down
```

See [`architecture/README.md`](../architecture/README.md) for the complete authoring journey, baseline
lifecycle, ports, permissions, and provenance.

BMAD may still require a generated `architecture.md` artifact. That artifact should point here and to the
canonical workspace rather than restating the model, documentation, or ADRs.
