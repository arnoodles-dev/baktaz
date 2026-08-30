#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  echo "Usage: sh scripts/inject_env_secrets.sh [development|staging|production|all] [working-directory]"
  exit 1
}

ENV_TARGET="${1:-development}"
TARGET_DIR_INPUT="${2:-.}"

if [ -d "$TARGET_DIR_INPUT" ]; then
  WORKING_DIR="$(cd "$TARGET_DIR_INPUT" && pwd)"
elif [ -d "$ROOT_DIR/$TARGET_DIR_INPUT" ]; then
  WORKING_DIR="$(cd "$ROOT_DIR/$TARGET_DIR_INPUT" && pwd)"
else
  echo "Working directory does not exist: $TARGET_DIR_INPUT"
  exit 1
fi

find_target_dirs() {
  if [ -f "$WORKING_DIR/assets/env/.env.development" ]; then
    echo "$WORKING_DIR"
  else
    for sub in "$WORKING_DIR"/*; do
      if [ -f "$sub/assets/env/.env.development" ]; then
        echo "$sub"
      fi
    done
  fi
}

inject_for_target_and_dir() {
  TARGET_FLAVOR="$1"
  DIR_PATH="$2"

  TEMPLATE_FILE="$DIR_PATH/assets/env/.env.development"
  TARGET_FILE="$DIR_PATH/assets/env/.env.$TARGET_FLAVOR"

  if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template file not found: $TEMPLATE_FILE"
    exit 1
  fi

  mkdir -p "$DIR_PATH/assets/env"

  TMP_FILE="$(mktemp)"

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      "" | \#*)
        echo "$line" >> "$TMP_FILE"
        continue
        ;;
    esac

    case "$line" in
      *=*)
        ;;
      *)
        echo "$line" >> "$TMP_FILE"
        continue
        ;;
    esac

    RAW_KEY="${line%%=*}"
    RAW_VAL="${line#*=}"

    KEY="$(echo "$RAW_KEY" | tr -d '[:space:]')"

    case "$TARGET_FLAVOR" in
      development)
        LOOKUP_KEYS="DEV_${KEY} ${KEY}"
        ;;
      staging)
        LOOKUP_KEYS="STG_${KEY} STAGING_${KEY} ${KEY}"
        ;;
      production)
        LOOKUP_KEYS="PROD_${KEY} ${KEY}"
        ;;
      *)
        LOOKUP_KEYS="${KEY}"
        ;;
    esac

    FINAL_VAL=""

    # Check SECRETS_JSON using jq if SECRETS_JSON is provided and non-empty/not null
    if [ -n "$SECRETS_JSON" ] && [ "$SECRETS_JSON" != "null" ] && [ "$SECRETS_JSON" != "{}" ]; then
      for lookup_key in $LOOKUP_KEYS; do
        SECRET_VAL="$(echo "$SECRETS_JSON" | jq -r --arg k "$lookup_key" '.[$k] | select(. != null and . != "")' 2>/dev/null || true)"
        if [ -n "$SECRET_VAL" ]; then
          FINAL_VAL="$SECRET_VAL"
          break
        fi
      done
    fi

    # Check process environment variables
    if [ -z "$FINAL_VAL" ]; then
      for lookup_key in $LOOKUP_KEYS; do
        ENV_VAL=""
        eval "ENV_VAL=\"\${$lookup_key:-}\""
        if [ -n "$ENV_VAL" ]; then
          FINAL_VAL="$ENV_VAL"
          break
        fi
      done
    fi

    # Fall back to default value parsed from .env.development
    if [ -z "$FINAL_VAL" ]; then
      FINAL_VAL="$RAW_VAL"
    fi

    CLEAN_VAL="$FINAL_VAL"
    CLEAN_VAL="${CLEAN_VAL#\'}"
    CLEAN_VAL="${CLEAN_VAL#\"}"
    CLEAN_VAL="${CLEAN_VAL%\'}"
    CLEAN_VAL="${CLEAN_VAL%\"}"

    echo "${KEY}='${CLEAN_VAL}'" >> "$TMP_FILE"
  done < "$TEMPLATE_FILE"

  mv "$TMP_FILE" "$TARGET_FILE"
  echo "Successfully generated $TARGET_FILE"
}

ensure_all_env_files_exist() {
  DIR_PATH="$1"
  TEMPLATE_FILE="$DIR_PATH/assets/env/.env.development"

  if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Warning: Cannot create placeholder files because template $TEMPLATE_FILE does not exist."
    return
  fi

  for flavor in development staging production; do
    FLAVOR_FILE="$DIR_PATH/assets/env/.env.$flavor"
    if [ ! -f "$FLAVOR_FILE" ]; then
      cp "$TEMPLATE_FILE" "$FLAVOR_FILE"
      echo "Created placeholder file: $FLAVOR_FILE from $TEMPLATE_FILE"
    fi
  done
}

process_flavor_dir() {
  TARGET_FLAVOR="$1"
  DIR_PATH="$2"

  # If SECRETS_JSON is null or empty, and TARGET_FLAVOR is not development,
  # clone .env.development directly (Scenario 2: CI workflow)
  if [ -z "$SECRETS_JSON" ] || [ "$SECRETS_JSON" = "null" ] || [ "$SECRETS_JSON" = "{}" ]; then
    if [ "$TARGET_FLAVOR" != "development" ]; then
      cp "$DIR_PATH/assets/env/.env.development" "$DIR_PATH/assets/env/.env.$TARGET_FLAVOR"
      echo "Cloned .env.development to $DIR_PATH/assets/env/.env.$TARGET_FLAVOR (CI mock file)"
      return 0
    fi
  fi

  inject_for_target_and_dir "$TARGET_FLAVOR" "$DIR_PATH"
}

process_flavor() {
  FLAVOR="$1"
  TARGET_DIRS="$(find_target_dirs)"
  if [ -z "$TARGET_DIRS" ]; then
    echo "Notice: No target directories with assets/env/.env.development found under $WORKING_DIR. Skipping secret injection."
    return 0
  fi

  for dir in $TARGET_DIRS; do
    if [ "$FLAVOR" = "all" ]; then
      process_flavor_dir "development" "$dir"
      process_flavor_dir "staging" "$dir"
      process_flavor_dir "production" "$dir"
    else
      process_flavor_dir "$FLAVOR" "$dir"
    fi
    ensure_all_env_files_exist "$dir"
  done
}

case "$ENV_TARGET" in
  development|staging|production|all)
    process_flavor "$ENV_TARGET"
    ;;
  *)
    usage
    ;;
esac
