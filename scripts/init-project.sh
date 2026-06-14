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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/template"
DEST_ABS="$(mkdir -p "$DEST" && cd "$DEST" && pwd)"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "error: template payload not found: $TEMPLATE_DIR" >&2
  exit 1
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

echo "==> Copying template payload to $DEST_ABS"
cp -a "$TEMPLATE_DIR"/. "$DEST_ABS"/

echo "==> Replacing project placeholders"
export PROJECT_NAME PROJECT_SLUG
while IFS= read -r -d '' source_file; do
  rel_path="${source_file#"$TEMPLATE_DIR"/}"
  dest_file="$DEST_ABS/$rel_path"
  if [ -f "$dest_file" ] && grep -Iq -e '__PROJECT_NAME__' -e '__PROJECT_SLUG__' "$dest_file"; then
    perl -0pi -e 's/__PROJECT_NAME__/$ENV{PROJECT_NAME}/g; s/__PROJECT_SLUG__/$ENV{PROJECT_SLUG}/g' "$dest_file"
  fi
done < <(find "$TEMPLATE_DIR" -type f -print0)

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

Next steps:
  1. Review README.md and AGENTS.md in the generated project.
  2. Define the project quality gate in CONTRIBUTING.md and CI.
  3. Run scripts/setup.sh if you did not pass --install-sdlc-tools.
  4. Commit the initialized scaffold on dev.
EOF
