#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/delivery-date-estimator"
FAILURES=0

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; FAILURES=$((FAILURES + 1)); }
check_file() {
  if [[ -f "$1" ]]; then
    pass "$2"
  else
    fail "$2"
  fi
}

echo "Running launch verification..."

check_file "$APP_DIR/app/routes/privacy-policy.tsx" "Privacy policy route exists"
check_file "$APP_DIR/app/routes/terms-of-service.tsx" "Terms route exists"
check_file "$APP_DIR/app/routes/api.health.tsx" "Health endpoint exists"
check_file "$APP_DIR/app/routes/readyz.tsx" "Public readiness endpoint exists"
check_file "$ROOT_DIR/POSTGRES_CUTOVER.md" "Postgres cutover runbook exists"
check_file "$ROOT_DIR/scripts/cutover-postgres.sh" "Postgres cutover script exists"
check_file "$ROOT_DIR/scripts/build.sh" "Build script exists"
check_file "$ROOT_DIR/scripts/verify-production.sh" "Production verification script exists"

if grep -q 'scopes = "read_products"' "$APP_DIR/shopify.app.toml"; then
  pass "Shopify scope is least-privilege (read_products)"
else
  fail "Shopify scope is not read_products"
fi

if grep -q 'provider = "postgresql"' "$APP_DIR/prisma/schema.prisma" && \
   grep -q 'env("DATABASE_URL")' "$APP_DIR/prisma/schema.prisma"; then
  pass "Prisma datasource is PostgreSQL with DATABASE_URL"
else
  fail "Prisma datasource is not configured for PostgreSQL + DATABASE_URL"
fi

if grep -q 'prisma -- migrate deploy' "$ROOT_DIR/scripts/build.sh"; then
  pass "Build pipeline applies Prisma migrations"
else
  fail "Build pipeline does not apply Prisma migrations"
fi

if grep -q "authenticate.public.appProxy" "$APP_DIR/app/routes/apps.delivery-date-estimator.config.tsx"; then
  pass "App proxy config route validates Shopify signature"
else
  fail "App proxy config route is missing app proxy auth"
fi

if grep -q "authenticate.public.appProxy" "$APP_DIR/app/routes/apps.delivery-date-estimator.event.tsx"; then
  pass "App proxy event route validates Shopify signature"
else
  fail "App proxy event route is missing app proxy auth"
fi

if grep -q "purgeShopData" "$APP_DIR/app/routes/webhooks.app.uninstalled.tsx"; then
  pass "Uninstall webhook purges tenant data"
else
  fail "Uninstall webhook does not purge tenant data"
fi

if grep -q "authenticate.admin" "$APP_DIR/app/routes/api.config.tsx"; then
  pass "Internal /api/config route is admin-authenticated"
else
  fail "Internal /api/config route is missing admin auth"
fi

if grep -q "support@deliverydateestimator.app" "$ROOT_DIR/APP_STORE_LISTING.md"; then
  pass "App listing support email is set"
else
  fail "App listing support email is not set"
fi

if grep -q "https://delivery-date-estimator-project.vercel.app" "$ROOT_DIR/APP_STORE_LISTING.md"; then
  pass "App listing website URL is set"
else
  fail "App listing website URL is not set"
fi

if grep -qF "[your-email@domain.com]" "$ROOT_DIR/APP_STORE_LISTING.md" || \
   grep -qF "[your-website.com]" "$ROOT_DIR/APP_STORE_LISTING.md"; then
  fail "App listing still contains placeholder support fields"
else
  pass "App listing support placeholders removed"
fi

echo "Running production build check..."
if npm run build >/tmp/verify-launch-build.log 2>&1; then
  pass "Production build succeeds"
else
  fail "Production build failed (see /tmp/verify-launch-build.log)"
fi

if [[ "${FAILURES}" -gt 0 ]]; then
  echo "Launch verification failed with ${FAILURES} issue(s)."
  exit 1
fi

echo "Launch verification passed."
