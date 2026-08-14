#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh" || {
  echo "Error: common.sh not found at $SCRIPT_DIR/common.sh" >&2
  exit 1
}

APP=""
ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --app) APP="$2"; shift 2 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]}"

if ! validate_or_prompt_feature_name "$@"; then
  print_usage "Creates test scaffolding for feature under test/unit and test/widget"
  exit 1
fi

FEATURE_NAME_SNAKE=$(to_snake_case "$INPUT_NAME")

# Determine target package
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -n "$APP" ]]; then
  # Find package matching app type
  PACKAGES=($(discover_packages "$ROOT_DIR"))
  TARGET_PKG=""
  for pkg in "${PACKAGES[@]}"; do
    case "$APP" in
      flutter) [[ "$pkg" == *flutter* ]] && TARGET_PKG="$pkg" ;;
      admin) [[ "$pkg" == *admin* ]] && TARGET_PKG="$pkg" ;;
      site) [[ "$pkg" == *site* ]] && TARGET_PKG="$pkg" ;;
      shared) [[ "$pkg" == *shared* ]] && TARGET_PKG="$pkg" ;;
      server) [[ "$pkg" == *server* ]] && TARGET_PKG="$pkg" ;;
    esac
    [[ -n "$TARGET_PKG" ]] && break
  done
  [[ -z "$TARGET_PKG" ]] && { echo "Error: No package found for app type: $APP"; exit 1; }
  REPO_ROOT="$ROOT_DIR/$TARGET_PKG"
else
  REPO_ROOT="$ROOT_DIR"
fi

WIDGET_ROOT="$REPO_ROOT/test/widget/features/$FEATURE_NAME_SNAKE"
UNIT_ROOT="$REPO_ROOT/test/unit/features/$FEATURE_NAME_SNAKE"

echo "Creating test scaffold for feature: $FEATURE_NAME_SNAKE"
echo "Root: $REPO_ROOT"

dirs=(
  "$UNIT_ROOT/cubit"
  "$UNIT_ROOT/repository"
  "$WIDGET_ROOT"
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
  if [ ! -f "$d/.gitkeep" ]; then
    touch "$d/.gitkeep"
  fi
done

echo "Test scaffold created"
printf "\n"
printf "test\n"
printf "├── unit\n"
printf "│   └── features\n"
printf "│       └── %s\n" "$FEATURE_NAME_SNAKE"
printf "│           ├── cubit\n"
printf "│           └── repository\n"
printf "└── widget\n"
printf "    └── features\n"
printf "        └── %s\n" "$FEATURE_NAME_SNAKE"
