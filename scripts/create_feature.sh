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
  print_usage "Creates Clean Architecture folders under lib/features/<feature_name>"
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

FEATURE_ROOT="$REPO_ROOT/lib/features/$FEATURE_NAME_SNAKE"

echo "Creating feature: $FEATURE_NAME_SNAKE"
echo "Root: $FEATURE_ROOT"

dirs=(
  "$FEATURE_ROOT/data/dto"
  "$FEATURE_ROOT/data/repository"
  "$FEATURE_ROOT/data/service"
  "$FEATURE_ROOT/domain/cubit"
  "$FEATURE_ROOT/domain/interface"
  "$FEATURE_ROOT/domain/entity"
  "$FEATURE_ROOT/presentation/views"
  "$FEATURE_ROOT/presentation/widgets"
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
  if [ ! -f "$d/.gitkeep" ]; then
    touch "$d/.gitkeep"
  fi
done

echo "Feature scaffold created at lib/features/$FEATURE_NAME_SNAKE"
echo "Structure:"
printf "\n"
printf "lib\n"
printf "└── features\n"
printf "    └── %s\n" "$FEATURE_NAME_SNAKE"
printf "        ├── data\n"
printf "        │   ├── dto\n"
printf "        │   ├── repository\n"
printf "        │   └── service\n"
printf "        ├── domain\n"
printf "        │   ├── cubit\n"
printf "        │   ├── interface\n"
printf "        │   └── entity\n"
printf "        └── presentation\n"
printf "            ├── views\n"
printf "            └── widgets\n"
