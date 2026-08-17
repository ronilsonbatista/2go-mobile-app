#!/usr/bin/env bash
set -e

echo "=== 2GO OpenAPI Transport Client Regeneration ==="

BACKEND_DIR="/Users/ronilsonbatista/.gemini/antigravity/scratch/approteiros-api"
MOBILE_DIR="/Users/ronilsonbatista/Documents/2go-mobile"
OPENAPI_JSON="$BACKEND_DIR/openapi.json"

if [ ! -f "$OPENAPI_JSON" ]; then
  echo "Generating openapi.json from backend..."
  (cd "$BACKEND_DIR" && npm run openapi:generate)
fi

echo "OpenAPI JSON verified at $OPENAPI_JSON"
echo "Formatting packages/generated/app_roteiros_api..."
(cd "$MOBILE_DIR" && dart format packages/generated/app_roteiros_api)

echo "Analyzing packages/generated/app_roteiros_api..."
(cd "$MOBILE_DIR/packages/generated/app_roteiros_api" && flutter analyze)

echo "=== OpenAPI Transport Client Regeneration Complete ==="
