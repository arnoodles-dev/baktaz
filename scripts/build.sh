#!/bin/bash

# =============================================================================
# build.sh
# Builds Flutter artifacts with flavor support.
#
# Usage:
#   ./scripts/build.sh --app <app> [OPTIONS]
#
# Apps:
#   flutter   Android (APK/AAB) or iOS (IPA)
#   admin     Web
#   site      Web (Jaspr)
#
# Shared options:
#   -f, --flavor          Flavor: development | staging | production    (default: development)
#   -c, --build-number    Build number, e.g. 42                         (required for non-production)
#   -h, --help            Show this help message
#
# Flutter options:
#   -p, --platform        Platform: android | ios                       (required)
#   -t, --type            Output type: apk | appbundle  [android only]  (default: apk)
#   -b, --build-type      Build type: debug | release                   (default: release)
#   -d, --dart-define-file Path to dart define file                     (optional)
#
# Admin options:
#   -w, --wasm            Build using WebAssembly (WASM)
#   -r, --web-renderer    Web renderer: auto | canvaskit | html         (default: auto)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Dynamically discover packages from melos workspace
discover_packages() {
  local packages=()
  if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
        pkg="${BASH_REMATCH[1]}"
        if [ -d "$ROOT_DIR/$pkg" ]; then
          packages+=("$pkg")
        fi
      fi
    done < <(awk '/^workspace:/,/^[^[:space:]]/ {print}' "$ROOT_DIR/pubspec.yaml" | grep -E '^  - ')
  fi
  # Fallback
  if [ ${#packages[@]} -eq 0 ]; then
    while IFS= read -r pkg_dir; do
      pkg_name=$(basename "$pkg_dir")
      if [ "$pkg_name" != "baktaz_client" ]; then
        packages+=("$pkg_name")
      fi
    done < <(find "$ROOT_DIR" -maxdepth 1 -type d -name "baktaz_*" | sort)
  fi
  echo "${packages[@]}"
}

# Find package by type
find_package() {
  local type=$1
  local packages=($(discover_packages))
  for pkg in "${packages[@]}"; do
    case "$type" in
      flutter) [[ "$pkg" == *flutter* ]] && echo "$pkg" && return ;;
      admin) [[ "$pkg" == *admin* ]] && echo "$pkg" && return ;;
      site) [[ "$pkg" == *site* ]] && echo "$pkg" && return ;;
    esac
  done
}

usage() {
  cat <<EOF
Usage: $0 --app <app> [OPTIONS]

Apps:
  flutter   Android (APK/AAB) or iOS (IPA)
  admin     Web
  site      Web (Jaspr)

Shared options:
  -f, --flavor          Flavor: development | staging | production    (default: development)
  -c, --build-number    Build number, e.g. 42                         (required for non-production)
  -h, --help            Show this help message

Flutter options:
  -p, --platform        Platform: android | ios                       (required)
  -t, --type            Output type: apk | appbundle  [android only]  (default: apk)
  -b, --build-type      Build type: debug | release                   (default: release)
  -d, --dart-define-file Path to dart define file                     (optional)

Admin options:
  -w, --wasm            Build using WebAssembly (WASM)
  -r, --web-renderer    Web renderer: auto | canvaskit | html         (default: auto)
EOF
}

APP=""
FLAVOR="development"
BUILD_NUMBER=""
PLATFORM=""
OUTPUT_TYPE="apk"
BUILD_TYPE="release"
DART_DEFINE_FILE_PATH=""
WASM=false
WEB_RENDERER="auto"

while [[ $# -gt 0 ]]; do
  case $1 in
    --app) APP="$2"; shift 2 ;;
    -f|--flavor) FLAVOR="$2"; shift 2 ;;
    -c|--build-number) BUILD_NUMBER="$2"; shift 2 ;;
    -p|--platform) PLATFORM="$2"; shift 2 ;;
    -t|--type) OUTPUT_TYPE="$2"; shift 2 ;;
    -b|--build-type) BUILD_TYPE="$2"; shift 2 ;;
    -d|--dart-define-file) DART_DEFINE_FILE_PATH="$2"; shift 2 ;;
    -w|--wasm) WASM=true; shift ;;
    -r|--web-renderer) WEB_RENDERER="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [ -z "$APP" ]; then
  echo "Error: --app is required (flutter, admin, or site)."
  usage
  exit 1
fi

# Find target package
TARGET_PKG=$(find_package "$APP")
if [ -z "$TARGET_PKG" ]; then
  echo "Error: No package found for app type: $APP"
  exit 1
fi

PROJECT_ROOT="$ROOT_DIR/$TARGET_PKG"

# Validate
if [[ "$APP" == "flutter" ]]; then
  if [[ -z "$PLATFORM" ]]; then
    echo "Error: --platform is required for flutter app."
    exit 1
  fi
  case "$PLATFORM" in
    android|ios) ;;
    *) echo "Invalid platform: '$PLATFORM'. Must be one of: android, ios"; exit 1 ;;
  esac
  if [[ "$PLATFORM" == "android" ]]; then
    case "$OUTPUT_TYPE" in
      apk|appbundle) ;;
      *) echo "Invalid type: '$OUTPUT_TYPE'. Must be one of: apk, appbundle"; exit 1 ;;
    esac
  fi
  case "$BUILD_TYPE" in
    debug|release) ;;
    *) echo "Invalid build-type: '$BUILD_TYPE'. Must be one of: debug, release"; exit 1 ;;
  esac

  # Find env file
  if [ -z "$DART_DEFINE_FILE_PATH" ]; then
    # Try standard locations
    for env_path in "$PROJECT_ROOT/assets/env/.env.$FLAVOR" "$PROJECT_ROOT/assets/env/.env" "$ROOT_DIR/.env.$FLAVOR" "$ROOT_DIR/.env"; do
      if [ -f "$env_path" ]; then
        DART_DEFINE_FILE_PATH="$env_path"
        break
      fi
    done
  fi

  if [[ ! -f "$DART_DEFINE_FILE_PATH" ]]; then
    echo "Error: Environment file not found at $DART_DEFINE_FILE_PATH"
    exit 1
  fi
fi

cd "$PROJECT_ROOT"

if [[ "$APP" == "flutter" ]]; then
  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: --build-number is required."
    usage
    exit 1
  fi

  APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d '[:space:]')
  VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//' | tr -d '[:space:]')
  SUFFIX=""
  if [[ "$BUILD_TYPE" == "debug" ]]; then
    SUFFIX="-debug"
  fi

  echo "App:      $APP_NAME"
  echo "Platform: $PLATFORM"
  echo "Flavor:   $FLAVOR"
  echo "Version:  $VERSION+$BUILD_NUMBER"
  echo ""

  if [[ "$PLATFORM" == "android" ]]; then
    echo "Building Flutter $OUTPUT_TYPE ($FLAVOR:$BUILD_TYPE)..."

    BUILD_ARGS=(
      "build" "$OUTPUT_TYPE"
      "--flavor" "$FLAVOR"
      "--$BUILD_TYPE"
      "--build-name=$VERSION"
      "--build-number=$BUILD_NUMBER"
    )

    if [[ -n "$DART_DEFINE_FILE_PATH" ]]; then
      BUILD_ARGS+=("--dart-define-from-file=$DART_DEFINE_FILE_PATH")
    fi

    PATH="$HOME/bin:$PATH" fvm flutter "${BUILD_ARGS[@]}"

    ARTIFACT_NAME="${APP_NAME}-android-${FLAVOR}-${VERSION}+${BUILD_NUMBER}${SUFFIX}.$OUTPUT_TYPE"
    mkdir -p outputs

    echo "Copying artifact to outputs/$ARTIFACT_NAME..."
    if [[ "$OUTPUT_TYPE" == "apk" ]]; then
      find build/app/outputs/flutter-apk -name "*.apk" -exec cp {} "outputs/$ARTIFACT_NAME" \;
    else
      find build/app/outputs/bundle -name "*.aab" -exec cp {} "outputs/$ARTIFACT_NAME" \;
    fi

  elif [[ "$PLATFORM" == "ios" ]]; then
    echo "Building Flutter iOS IPA ($FLAVOR:$BUILD_TYPE)..."

    BUILD_ARGS=(
      "build" "ipa"
      "--flavor" "$FLAVOR"
      "--$BUILD_TYPE"
      "--build-name=$VERSION"
      "--build-number=$BUILD_NUMBER"
    )

    if [[ -n "$DART_DEFINE_FILE_PATH" ]]; then
      BUILD_ARGS+=("--dart-define-from-file=$DART_DEFINE_FILE_PATH")
    fi

    PATH="$HOME/bin:$PATH" fvm flutter "${BUILD_ARGS[@]}"

    ARTIFACT_NAME="${APP_NAME}-ios-${FLAVOR}-${VERSION}+${BUILD_NUMBER}${SUFFIX}.ipa"
    mkdir -p outputs

    echo "Packaging IPA to outputs/$ARTIFACT_NAME..."
    if [ -d "build/ios/archive" ]; then
      cd build/ios/archive
      zip -r "../../../outputs/$ARTIFACT_NAME" .
      cd ../../..
    elif [ -d "build/ios/ipa" ]; then
      find build/ios/ipa -name "*.ipa" -exec cp {} "outputs/$ARTIFACT_NAME" \;
    else
      echo "Error: XCArchive artifact not found under build/ios/archive/. Build may have failed."
      exit 1
    fi
  fi

elif [[ "$APP" == "admin" ]]; then
  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: --build-number is required."
    usage
    exit 1
  fi

  APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d '[:space:]')
  VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//' | tr -d '[:space:]')

  echo "App:     $APP_NAME"
  echo "Flavor:  $FLAVOR"
  echo "Version: $VERSION+$BUILD_NUMBER"
  echo ""

  echo "Building Flutter web admin ($FLAVOR)..."

  BUILD_ARGS=(
    "build" "web"
    "--flavor" "$FLAVOR"
    "--release"
    "--build-name=$VERSION"
    "--build-number=$BUILD_NUMBER"
    "--web-renderer" "$WEB_RENDERER"
  )

  if [[ "$WASM" == true ]]; then
    BUILD_ARGS+=("--wasm")
  fi

  PATH="$HOME/bin:$PATH" fvm flutter "${BUILD_ARGS[@]}"

  ARTIFACT_NAME="${APP_NAME}-web-${FLAVOR}-${VERSION}+${BUILD_NUMBER}.zip"
  mkdir -p outputs

  echo "Packaging admin build to outputs/$ARTIFACT_NAME..."
  cd build/web
  zip -r "../../outputs/$ARTIFACT_NAME" .
  cd ../..

elif [[ "$APP" == "site" ]]; then
  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: --build-number is required."
    usage
    exit 1
  fi

  APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d '[:space:]')
  VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//' | tr -d '[:space:]')

  echo "App:     $APP_NAME"
  echo "Flavor:  $FLAVOR"
  echo "Version: $VERSION+$BUILD_NUMBER"
  echo ""

  echo "Building Jaspr web site ($FLAVOR)..."

  # Run jaspr build using fvm
  PATH="$HOME/bin:$PATH" fvm dart pub global run jaspr_cli:jaspr build

  ARTIFACT_NAME="${APP_NAME}-web-${FLAVOR}-${VERSION}+${BUILD_NUMBER}.zip"
  mkdir -p outputs

  echo "Packaging site build to outputs/$ARTIFACT_NAME..."
  cd build/jaspr
  zip -r "../../outputs/$ARTIFACT_NAME" .
  cd ../..
fi

echo ""
echo "Build completed!"
echo "Artifact: outputs/$ARTIFACT_NAME"
