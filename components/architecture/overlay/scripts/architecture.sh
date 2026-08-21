#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHITECTURE_DIR="$PROJECT_ROOT/architecture"
COMPOSE_FILE="$ARCHITECTURE_DIR/compose.yaml"

usage() {
  cat <<'EOF'
Usage: scripts/architecture.sh <command> [workspace]

Commands:
  up [target|baseline]  Start target (default) or the optional baseline.
  validate              Validate target and baseline DSL with the pinned image.
  down                  Stop all architecture services and remove their network.
  help                  Show this help.
EOF
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "error: Docker is required for the architecture component" >&2
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "error: the Docker Compose plugin is required" >&2
    exit 1
  fi
}

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "error: architecture Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

command_name="${1:-help}"
shift || true

case "$command_name" in
  up)
    require_docker
    workspace="${1:-target}"
    if [ "$#" -gt 1 ]; then
      echo "error: up accepts at most one workspace" >&2
      usage >&2
      exit 2
    fi
    case "$workspace" in
      target)
        docker compose -f "$COMPOSE_FILE" up -d target-architecture
        ;;
      baseline)
        docker compose -f "$COMPOSE_FILE" up -d baseline-architecture
        ;;
      *)
        echo "error: unsupported workspace: $workspace" >&2
        usage >&2
        exit 2
        ;;
    esac
    ;;
  validate)
    require_docker
    if [ "$#" -ne 0 ]; then
      echo "error: validate accepts no additional arguments" >&2
      usage >&2
      exit 2
    fi
    docker compose -f "$COMPOSE_FILE" config --quiet
    image="$(docker compose -f "$COMPOSE_FILE" config --images | head -n 1)"
    validation_args=(
      --rm
      --network none
      --read-only
      --cap-drop ALL
      --security-opt no-new-privileges
      --tmpfs /tmp:rw,noexec,nosuid,size=256m
      --user "${STRUCTURIZR_USER:-1000:1000}"
      --volume "$ARCHITECTURE_DIR/base:/usr/local/base:ro"
    )
    docker run "${validation_args[@]}" \
      --volume "$ARCHITECTURE_DIR/baseline:/usr/local/baseline:ro" \
      --volume "$ARCHITECTURE_DIR/target:/usr/local/structurizr:ro" \
      "$image" validate -workspace workspace.dsl
    docker run "${validation_args[@]}" \
      --volume "$ARCHITECTURE_DIR/baseline:/usr/local/structurizr:ro" \
      "$image" validate -workspace workspace.dsl
    ;;
  down)
    require_docker
    if [ "$#" -ne 0 ]; then
      echo "error: down accepts no additional arguments" >&2
      usage >&2
      exit 2
    fi
    docker compose -f "$COMPOSE_FILE" --profile optional down --remove-orphans
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "error: unknown command: $command_name" >&2
    usage >&2
    exit 2
    ;;
esac
