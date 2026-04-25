#!/bin/bash
set -euo pipefail

APP_DIR="/opt/api-display"
REGION="eu-west-2"
PREFIX="/api-display"

cd "$APP_DIR"

export AWS_REGION="$REGION"
export HOST_PORT="80"
export CONTAINER_PORT="8080"
export IMAGE_NAME="jordanroberts2000/api-display:latest"
export APP_ENV="production"

LOG_LEVEL="$(aws ssm get-parameter \
  --name "$PREFIX/log_level" \
  --region "$REGION" \
  --query "Parameter.Value" \
  --output text)"
: "${LOG_LEVEL:?LOG_LEVEL is required}"
export LOG_LEVEL

DATABASE_URL="$(aws ssm get-parameter \
  --name "$PREFIX/database_url" \
  --with-decryption \
  --region "$REGION" \
  --query "Parameter.Value" \
  --output text)"
: "${DATABASE_URL:?DATABASE_URL is required}"
export DATABASE_URL

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d