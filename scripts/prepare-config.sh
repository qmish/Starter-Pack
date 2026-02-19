#!/usr/bin/env bash
# Подготавливает collector/config.yaml из выбранного шаблона и .env
# Использование: ./scripts/prepare-config.sh [full|docker|vm]
# Требует: envsubst (GNU gettext). На Mac: brew install gettext.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COLLECTOR_DIR="$ROOT_DIR/collector"
CONFIG_NAME="${1:-full}"
SOURCE="$COLLECTOR_DIR/config.$CONFIG_NAME.yaml"
TARGET="$COLLECTOR_DIR/config.yaml"

if [ ! -f "$SOURCE" ]; then
  echo "Config template not found: $SOURCE"
  echo "Usage: $0 [full|docker|vm]"
  exit 1
fi

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  source "$ROOT_DIR/.env"
  set +a
  export SIGNOZ_ENDPOINT="${SIGNOZ_OTEL_ENDPOINT:-<SIGNOZ_ENDPOINT>}"
  export INGESTION_KEY="${SIGNOZ_INGESTION_KEY:-<INGESTION_KEY>}"
fi

# Substitute placeholders (envsubst replaces $VAR; we use angle-bracket placeholders)
export SIGNOZ_ENDPOINT="${SIGNOZ_ENDPOINT:-<SIGNOZ_ENDPOINT>}"
export INGESTION_KEY="${INGESTION_KEY:-<INGESTION_KEY>}"

sed -e "s|<SIGNOZ_ENDPOINT>|$SIGNOZ_ENDPOINT|g" \
    -e "s|<INGESTION_KEY>|$INGESTION_KEY|g" \
    "$SOURCE" > "$TARGET"

echo "Written $TARGET from $SOURCE"
echo "Endpoint: $SIGNOZ_ENDPOINT"
