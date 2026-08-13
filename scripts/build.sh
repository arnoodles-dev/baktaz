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
#   -w, --wasm            Build using WebAssembly
#   -r, --web-renderer    Web renderer: auto | canvaskit | html         (default: auto)
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Defaults ──────────────────────────────────────────────────────────────────
APP=""
PLATFORM=""
FLAVOR="development"
OUTPUT_TYPE="apk"
BUILD_TYPE="release"
BUILD_NUMBER=""
WASM=false
WEB_RENDERER="auto"
DART_DEFINE_FILE_PATH=""

# ── Usage ─────────────────────────────────────────────────────────────────────
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
  -h, --help            Show this help

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

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --app)     APP="$2"; shift 2 ;;
    -p|--platform) PLATFORM="$2"; shift 2 ;;
    -f|--flavor) FLAVOR="$2"; shift 2 ;;
    -t|--type) OUTPUT_TYPE="$2"; shift 2 ;;
    -b|--build-type) BUILD_TYPE="$2"; shift 2 ;;
    -c|--build-number) BUILD_NUMBER="$2"; shift 2 ;;
    -d|--dart-define-file) DART_DEFINE_FILE_PATH="$2"; shift 2 ;;
    -w|--wasm) WASM=true; shift ;;
    -r|--web-renderer) WEB_RENDERER="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$APP" ]]; then
  echo "Error: --app is required (flutter, admin, or site)."
  usage; exit 1
fi

case "$APP" in
  flutter|admin|site) ;;
  *) echo "Invalid app: '$APP'. Must be one of: flutter, admin, site"; exit 1 ;;
esac

case "$FLAVOR" in
  development|staging|production) ;;
  *) echo "Invalid flavor: '$FLAVOR'. Must be one of: development, staging, production"; exit 1 ;;
esac

# ── Build ─────────────────────────────────────────────────────────────────────
if [[ "$APP" == "flutter" ]]; then
  # ── Flutter: Android / iOS ──────────────────────────────────────────────────

  if [[ -z "$PLATFORM" ]]; then
    echo "Error: --platform is required for flutter app."
    usage; exit 1
  fi

  case "$PLATFORM" in
    android|ios) ;;
    *) echo "Invalid platform: '$PLATFORM'. Must be one of: android, ios"; exit 1 ;;
  esac

  case "$BUILD_TYPE" in
    debug|release) ;;
    *) echo "Invalid build-type: '$BUILD_TYPE'. Must be one of: debug, release"; exit 1 ;;
  esac

  if [[ "$PLATFORM" == "android" ]]; then
    case "$OUTPUT_TYPE" in
      apk|appbundle) ;;
      *) echo "Invalid type: '$OUTPUT_TYPE'. Must be one of: apk, appbundle"; exit 1 ;;
    esac
  fi

  DART_DEFINE_FILE_PATH="${DART_DEFINE_FILE_PATH:-$PROJECT_ROOT/paxa_flutter/assets/env/.env.$FLAVOR}"
  if [[ ! -f "$DART_DEFINE_FILE_PATH" ]]; then
    echo "Error: Environment file not found at $DART_DEFINE_FILE_PATH"
    exit 1
  fi

  cd "$PROJECT_ROOT/paxa_flutter"

  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: --build-number is required."
    usage; exit 1
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
      "--dart-define-from-file=$DART_DEFINE_FILE_PATH"
    )

    if [[ "$BUILD_TYPE" == "release" ]]; then
      BUILD_ARGS+=(
        "--obfuscate"
        "--split-debug-info=build/debug-info"
      )
    fi

    flutter "${BUILD_ARGS[@]}"

    if [[ "$OUTPUT_TYPE" == "appbundle" ]]; then
      BUILD_TYPE_CAP="$(tr '[:lower:]' '[:upper:]' <<< ${BUILD_TYPE:0:1})${BUILD_TYPE:1}"
      SRC="build/app/outputs/bundle/${FLAVOR}${BUILD_TYPE_CAP}/app-${FLAVOR}-${BUILD_TYPE}.aab"
      ARTIFACT_NAME="${APP_NAME}-${FLAVOR}${SUFFIX}-${VERSION}+${BUILD_NUMBER}.aab"
    else
      SRC="build/app/outputs/flutter-apk/app-${FLAVOR}-${BUILD_TYPE}.apk"
      ARTIFACT_NAME="${APP_NAME}-${FLAVOR}${SUFFIX}-${VERSION}+${BUILD_NUMBER}.apk"
    fi

    mkdir -p outputs
    cp "$SRC" "outputs/$ARTIFACT_NAME"
    rm -rf "$(dirname "$SRC")"

  else
    echo "Building Flutter ipa ($FLAVOR:$BUILD_TYPE)..."

    EXPORT_OPTIONS_PLIST="ios/ExportOptions/ExportOptions-${FLAVOR}.plist"

    BUILD_ARGS=(
      "build" "ipa"
      "--flavor" "$FLAVOR"
      "--$BUILD_TYPE"
      "--export-options-plist=$EXPORT_OPTIONS_PLIST"
      "--build-name=$VERSION"
      "--build-number=$BUILD_NUMBER"
      "--dart-define-from-file=$DART_DEFINE_FILE_PATH"
    )

    if [[ "$BUILD_TYPE" == "debug" ]]; then
      BUILD_ARGS+=("--no-codesign")
    fi

    flutter "${BUILD_ARGS[@]}"

    if [[ "$BUILD_TYPE" == "debug" ]]; then
      ARCHIVE_SRC=$(find "build/ios/archive" -name "*.xcarchive" 2>/dev/null | head -n 1)
      if [[ -z "$ARCHIVE_SRC" ]]; then
        echo "Error: XCArchive artifact not found under build/ios/archive/. Build may have failed."
        exit 1
      fi
      ARTIFACT_NAME="${APP_NAME}-${FLAVOR}${SUFFIX}-${VERSION}+${BUILD_NUMBER}.xcarchive"
      mkdir -p outputs
      cp -R "$ARCHIVE_SRC" "outputs/$ARTIFACT_NAME"
      rm -rf "build/ios/archive"
    else
      IPA_SRC=$(find "build/ios/ipa" -name "*.ipa" 2>/dev/null | head -n 1)
      if [[ -z "$IPA_SRC" ]]; then
        echo "Error: IPA artifact not found under build/ios/ipa/. Build may have failed."
        exit 1
      fi
      ARTIFACT_NAME="${APP_NAME}-${FLAVOR}${SUFFIX}-${VERSION}+${BUILD_NUMBER}.ipa"
      mkdir -p outputs
      cp "$IPA_SRC" "outputs/$ARTIFACT_NAME"
      rm -rf "build/ios/ipa"
    fi
  fi

elif [[ "$APP" == "admin" ]]; then
  # ── Admin: Web ──────────────────────────────────────────────────────────────

  cd "$PROJECT_ROOT/paxa_admin"

  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: --build-number is required."
    usage; exit 1
  fi

  case "$WEB_RENDERER" in
    auto|canvaskit|html) ;;
    *) echo "Invalid web renderer: '$WEB_RENDERER'. Must be one of: auto, canvaskit, html"; exit 1 ;;
  esac

  APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d '[:space:]')
  VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//' | tr -d '[:space:]')

  echo "App:          $APP_NAME"
  echo "Platform:     web"
  echo "Flavor:       $FLAVOR"
  echo "Version:      $VERSION+$BUILD_NUMBER"
  echo "WASM:         $WASM"
  echo "Renderer:     $WEB_RENDERER"
  echo ""

  echo "Building Flutter web ($FLAVOR)..."

  BUILD_ARGS=(
    "build" "web"
    "--release"
    "--build-name=$VERSION"
    "--build-number=$BUILD_NUMBER"
    "--web-renderer=$WEB_RENDERER"
  )

  if [ "$WASM" = true ]; then
    BUILD_ARGS+=("--wasm")
  fi

  flutter "${BUILD_ARGS[@]}"

  SUFFIX=""
  if [ "$WASM" = true ]; then
    SUFFIX="-wasm"
  fi

  ARTIFACT_NAME="${APP_NAME}-web-${FLAVOR}${SUFFIX}-${VERSION}+${BUILD_NUMBER}.zip"
  mkdir -p outputs

  echo "Packaging web build to outputs/$ARTIFACT_NAME..."
  cd build/web
  zip -r "../../outputs/$ARTIFACT_NAME" .
  cd ../..

elif [[ "$APP" == "site" ]]; then
  # ── Site: Web (Jaspr) ────────────────────────────────────────────────────────

  cd "$PROJECT_ROOT/paxa_site"

  if [[ "$FLAVOR" == "production" ]]; then
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/.*+//' | tr -d '[:space:]')
  fi

  APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d '[:space:]')
  VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//' | tr -d '[:space:]')

  echo "App:          $APP_NAME"
  echo "Platform:     web (jaspr)"
  echo "Flavor:       $FLAVOR"
  echo "Version:      $VERSION"
  echo ""

  echo "Building Jaspr web site ($FLAVOR)..."

  # Run jaspr build using fvm
  PATH="$HOME/bin:$PATH" fvm dart pub global run jaspr_cli:jaspr build

  ARTIFACT_NAME="${APP_NAME}-web-${FLAVOR}-${VERSION}.zip"
  mkdir -p outputs

  echo "Packaging site build to outputs/$ARTIFACT_NAME..."
  cd build/jaspr
  zip -r "../../outputs/$ARTIFACT_NAME" .
  cd ../..
fi

echo ""
echo "Build completed!"
echo "Artifact: outputs/$ARTIFACT_NAME"
