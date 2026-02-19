#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/delivery-date-estimator"

echo "Installing app dependencies..."
npm ci --prefix "$APP_DIR"

echo "Generating Prisma client..."
npm --prefix "$APP_DIR" run prisma -- generate

if [[ -n "${DATABASE_URL:-}" ]]; then
  echo "Applying Prisma migrations..."
  npm --prefix "$APP_DIR" run prisma -- migrate deploy
elif [[ "${VERCEL:-}" == "1" ]]; then
  echo "DATABASE_URL is required in Vercel build environment."
  exit 1
else
  echo "Skipping prisma migrate deploy (DATABASE_URL is not set)."
fi

echo "Building React Router app..."
npm run build --prefix "$APP_DIR"
