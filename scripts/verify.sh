#!/usr/bin/env bash
# Checks that index.html is a complete page with one valid inline script.
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "verify: $1" >&2; exit 1; }

[ -s index.html ] || fail "index.html is missing or empty"
grep -q '<title>' index.html || fail "missing <title>"
[ "$(grep -c '<script' index.html)" -eq 1 ] || fail "expected exactly one <script> block"
grep -q '</script>' index.html || fail "unclosed <script>"
tail -n 3 index.html | grep -q '</html>' || fail "index.html does not end with </html>"

if command -v node >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  sed -n '/<script>/,/<\/script>/p' index.html | sed '1d;$d' > "$tmp/game.js"
  node --check "$tmp/game.js" || fail "JavaScript syntax error"
else
  echo "verify: node not found, skipping JavaScript syntax check"
fi

echo "verify: ok"
