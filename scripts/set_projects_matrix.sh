#!/usr/bin/env bash
set -e

FLUTTER_PROJECTS="[]"
DART_PROJECTS="[]"

if [ "$FLUTTER" = "true" ]; then
  FLUTTER_PROJECTS=$(echo "$FLUTTER_PROJECTS" | jq -c '. + ["paxa_flutter"]')
fi
if [ "$ADMIN" = "true" ]; then
  FLUTTER_PROJECTS=$(echo "$FLUTTER_PROJECTS" | jq -c '. + ["paxa_admin"]')
fi
if [ "$SHARED" = "true" ]; then
  FLUTTER_PROJECTS=$(echo "$FLUTTER_PROJECTS" | jq -c '. + ["paxa_shared"]')
fi
if [ "$SERVER" = "true" ]; then
  DART_PROJECTS=$(echo "$DART_PROJECTS" | jq -c '. + ["paxa_server"]')
fi
if [ "$SITE" = "true" ]; then
  DART_PROJECTS=$(echo "$DART_PROJECTS" | jq -c '. + ["paxa_site"]')
fi

ALL_PROJECTS=$(echo "$FLUTTER_PROJECTS $DART_PROJECTS" | jq -sc 'add' | jq -c '.')

echo "flutter_projects=$FLUTTER_PROJECTS" >> $GITHUB_OUTPUT
echo "dart_projects=$DART_PROJECTS" >> $GITHUB_OUTPUT
echo "all_projects=$ALL_PROJECTS" >> $GITHUB_OUTPUT
