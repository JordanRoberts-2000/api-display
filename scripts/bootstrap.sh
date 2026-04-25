#!/bin/bash
# everything needed to go from bare EC2 to running app
set -euo pipefail

APP_DIR="/opt/api-display"
REGION="eu-west-2"
PREFIX="/api-display"
COMPOSE_URL="https://raw.githubusercontent.com/JordanRoberts-2000/api-display/main/docker-compose.prod.yml"

# System setup
apt-get update
apt-get install -y docker.io docker-compose awscli curl
systemctl enable docker
systemctl start docker
usermod -aG docker admin

# App setup
mkdir -p "$APP_DIR"
cd "$APP_DIR"
curl -fsSL "$COMPOSE_URL" -o docker-compose.prod.yml

# Env var setup
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

docker compose -f docker-compose.prod.yml up -d