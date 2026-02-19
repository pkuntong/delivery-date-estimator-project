#!/usr/bin/env bash
set -euo pipefail

APP_URL="${1:-${APP_URL:-https://delivery-date-estimator-project.vercel.app}}"
APP_URL="${APP_URL%/}"
FAILURES=0

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; FAILURES=$((FAILURES + 1)); }

http_status() {
  local url="$1"
  local output_file="$2"
  local status=""
  local attempts=0

  while [[ "$attempts" -lt 4 ]]; do
    attempts=$((attempts + 1))
    status="$(curl -sS -L "$url" -o "$output_file" -w "%{http_code}" || true)"
    if [[ -n "$status" && "$status" != "000" ]]; then
      echo "$status"
      return 0
    fi
    sleep 2
  done

  echo "000"
}

TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_BODY"' EXIT

echo "Verifying production deployment at $APP_URL"

status="$(http_status "$APP_URL/" "$TMP_BODY")"
if [[ "$status" == "200" ]]; then
  pass "Root URL responds with HTTP 200"
else
  fail "Root URL returned HTTP $status"
fi

status="$(http_status "$APP_URL/privacy-policy" "$TMP_BODY")"
if [[ "$status" == "200" ]]; then
  pass "Privacy policy page is reachable"
else
  fail "Privacy policy page returned HTTP $status"
fi

status="$(http_status "$APP_URL/terms-of-service" "$TMP_BODY")"
if [[ "$status" == "200" ]]; then
  pass "Terms of service page is reachable"
else
  fail "Terms of service page returned HTTP $status"
fi

status="$(http_status "$APP_URL/readyz" "$TMP_BODY")"
if [[ "$status" == "200" ]]; then
  pass "Readiness endpoint responds with HTTP 200"
else
  fail "Readiness endpoint returned HTTP $status"
fi

if grep -q '"ok"[[:space:]]*:[[:space:]]*true' "$TMP_BODY" && \
   grep -q '"database"[[:space:]]*:[[:space:]]*"reachable"' "$TMP_BODY"; then
  pass "Readiness payload reports database reachable"
else
  fail "Readiness payload does not report healthy database"
fi

if [[ "${FAILURES}" -gt 0 ]]; then
  echo "Production verification failed with ${FAILURES} issue(s)."
  exit 1
fi

echo "Production verification passed."
