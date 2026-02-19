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

if grep -q 'scopes = "read_products"' "$APP_DIR/shopify.app.toml"; then
  pass "Shopify scope is least-privilege (read_products)"
else
  fail "Shopify scope is not read_products"
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
