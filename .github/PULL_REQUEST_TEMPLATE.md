## Summary

<!-- What does this change do, and why? Say whether it changes the maintainer repo, template payload, or both. -->

## Linked Root Backlog Task

Closes task-<id>

## Verification

```text
$ bash -n scripts/init-project.sh
$ bash -n template/scripts/setup.sh
$ bash -n template/scripts/codegraph-telemetry-off.sh
$ bash -n template/scripts/serena-telemetry-off.sh
$ bash -n components/architecture/overlay/scripts/architecture.sh
$ bash tests/code-intelligence-tooling.sh
$ git diff --check
```

## Boundary Check

- [ ] Root files describe maintaining `sdlc-template`.
- [ ] Payload files under `template/` make sense after being copied to a generated project root.
- [ ] Root `backlog/` and `template/backlog/` are not confused.
