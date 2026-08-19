#!/usr/bin/env bash
# Create a new project from this repository's template/ payload.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/init-project.sh <destination> --name <project-name> [options]

Options:
  --name <project-name>       Required display name for the generated project.
  --force                     Allow copying into a non-empty destination.
  --no-git                    Do not initialize git or create/switch to dev.
  --install-sdlc-tools        Run the generated project's scripts/setup.sh after copying.
  --with-architecture         Include and activate the Structurizr/Arc42/ADR component.
  -h, --help                  Show this help.
EOF
}

if [ "$#" -eq 0 ]; then
  usage
  exit 2
fi

DEST=""
PROJECT_NAME=""
FORCE=0
USE_GIT=1
INSTALL_SDLC_TOOLS=0
WITH_ARCHITECTURE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name)
      if [ "$#" -lt 2 ]; then
        echo "error: --name requires a value" >&2
        exit 2
      fi
      PROJECT_NAME="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --no-git)
      USE_GIT=0
      shift
      ;;
    --install-sdlc-tools)
      INSTALL_SDLC_TOOLS=1
      shift
      ;;
    --with-architecture)
      WITH_ARCHITECTURE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$DEST" ]; then
        echo "error: destination already set: $DEST" >&2
        exit 2
      fi
      DEST="$1"
      shift
      ;;
  esac
done

if [ -z "$DEST" ]; then
  echo "error: destination is required" >&2
  usage >&2
  exit 2
fi

if [ -z "$PROJECT_NAME" ]; then
  echo "error: --name is required" >&2
  usage >&2
  exit 2
fi

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"
TEMPLATE_DIR="$REPO_ROOT/template"
COMPONENTS_DIR="$REPO_ROOT/components"
ARCHITECTURE_OVERLAY_DIR="$COMPONENTS_DIR/architecture/overlay"
DEST_ABS="$(mkdir -p "$DEST" && cd -P "$DEST" && pwd -P)"

case "$DEST_ABS/" in
  "$REPO_ROOT/"|"$REPO_ROOT/"*)
    echo "error: destination cannot be the maintainer repository or one of its descendants: $DEST_ABS" >&2
    exit 1
    ;;
esac

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "error: template payload not found: $TEMPLATE_DIR" >&2
  exit 1
fi

if [ "$WITH_ARCHITECTURE" -eq 1 ] && [ ! -d "$ARCHITECTURE_OVERLAY_DIR" ]; then
  echo "error: architecture component payload not found: $ARCHITECTURE_OVERLAY_DIR" >&2
  exit 1
fi

if [ "$WITH_ARCHITECTURE" -eq 1 ]; then
  architecture_overlap="$(LC_ALL=C comm -12 \
    <(cd "$TEMPLATE_DIR" && find . \( -type f -o -type l \) -print | LC_ALL=C sort) \
    <(cd "$ARCHITECTURE_OVERLAY_DIR" && find . \( -type f -o -type l \) -print | LC_ALL=C sort))"
  if [ -n "$architecture_overlap" ]; then
    echo "error: architecture component would replace base payload files:" >&2
    echo "$architecture_overlap" >&2
    exit 1
  fi
fi

if [ "$FORCE" -ne 1 ] && [ -n "$(find "$DEST_ABS" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
  echo "error: destination is not empty: $DEST_ABS" >&2
  echo "use --force to copy into it anyway" >&2
  exit 1
fi

PROJECT_SLUG="$(printf '%s' "$PROJECT_NAME" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

if [ -z "$PROJECT_SLUG" ]; then
  echo "error: project name does not produce a usable slug" >&2
  exit 1
fi

PROJECT_NAME_DSL="${PROJECT_NAME//\\/\\\\}"
PROJECT_NAME_DSL="${PROJECT_NAME_DSL//\"/\\\"}"

echo "==> Copying template payload to $DEST_ABS"
cp -a "$TEMPLATE_DIR"/. "$DEST_ABS"/

payload_roots=("$TEMPLATE_DIR")
if [ "$WITH_ARCHITECTURE" -eq 1 ]; then
  echo "==> Including active architecture component"
  cp -a "$ARCHITECTURE_OVERLAY_DIR"/. "$DEST_ABS"/
  payload_roots+=("$ARCHITECTURE_OVERLAY_DIR")
fi

echo "==> Replacing project placeholders"
export PROJECT_NAME PROJECT_NAME_DSL PROJECT_SLUG
for payload_root in "${payload_roots[@]}"; do
  while IFS= read -r -d '' source_file; do
    rel_path="${source_file#"$payload_root"/}"
    dest_file="$DEST_ABS/$rel_path"
    if [ -f "$dest_file" ] && \
      grep -Iq -e '__PROJECT_NAME__' -e '__PROJECT_NAME_DSL__' -e '__PROJECT_SLUG__' "$dest_file"; then
      perl -0pi -e '
        s/__PROJECT_NAME__/$ENV{PROJECT_NAME}/g;
        s/__PROJECT_NAME_DSL__/$ENV{PROJECT_NAME_DSL}/g;
        s/__PROJECT_SLUG__/$ENV{PROJECT_SLUG}/g
      ' "$dest_file"
    fi
  done < <(find "$payload_root" -type f -print0)
done

if command -v backlog >/dev/null 2>&1; then
  echo "==> Setting generated backlog project name"
  (cd "$DEST_ABS" && backlog config set projectName "$PROJECT_NAME")
else
  echo "==> Backlog.md CLI not found; leaving backlog/config.yml placeholder for setup.sh or manual config"
fi

if [ "$USE_GIT" -eq 1 ]; then
  echo "==> Initializing git/dev branch"
  (
    cd "$DEST_ABS"
    if [ ! -d .git ]; then
      git init
    fi
    if git show-ref --verify --quiet refs/heads/dev; then
      git checkout dev
    else
      git checkout -b dev
    fi
  )
fi

if [ "$INSTALL_SDLC_TOOLS" -eq 1 ]; then
  echo "==> Installing generated-project SDLC tooling"
  (cd "$DEST_ABS" && bash scripts/setup.sh)
fi

cat <<EOF

Project initialized at: $DEST_ABS
Project name: $PROJECT_NAME
Project slug: $PROJECT_SLUG
Architecture component: $([ "$WITH_ARCHITECTURE" -eq 1 ] && printf 'enabled' || printf 'not included')

Next steps:
  1. Review README.md and AGENTS.md in the generated project.
  2. Define the project quality gate in CONTRIBUTING.md and CI.
  3. Run scripts/setup.sh if you did not pass --install-sdlc-tools.
$([ "$WITH_ARCHITECTURE" -eq 1 ] && printf '%s\n' '  4. Validate the active architecture workspace: bash scripts/architecture.sh validate' '  5. Commit the initialized scaffold on dev.' || printf '%s\n' '  4. Commit the initialized scaffold on dev.')
EOF
