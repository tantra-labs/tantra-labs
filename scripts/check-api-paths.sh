#!/usr/bin/env bash
# CI grep gate (root design 0006 R4/R5): no client, example or doc may call a runtime path that
# is not canonical `/api/v2`. Since R5 the runtime serves nothing else, so a hit is a broken call.
#
#   scripts/check-api-paths.sh        # exit 1 and list offending lines
#
# Allowed exceptions are the tests that assert those paths are gone, plus design/plan history.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SCAN=(
  tantra-ui/crates
  tantra-ui-web/src
  tantra-agent/crates
  tantra-ffi/python
  tantra-examples
  tantra-docs/docs
  tantra-runtime/crates
)

# Removed prefixes, sockets and alias spellings (PCRE).
PATTERNS=(
  '/api/v1\b'
  '/ws/live\b'
  '/ws/market\b'
  '(?<![\w/])/ws(?=["'"'"'`\s?)]|$)'
  '/schema/openapi(?=[/"'"'"'`\s)]|$)'
  '(?<!/studies)(?<!organisms)/experimental-analysis/'
  '/screener/scan(?!s)\b'
  '/market-data/'
  '/approval/(queue|approve|reject)\b'
  '/tax/report\b'
  '(?<![\w/-])/journals/'
  '(localhost|127\.0\.0\.1):8000/(?!api/v2|docs|swagger-ui|sse\b)[a-z]'
)

# Files that must mention removed paths: removal tests and client-side guards.
EXCLUDES=(
  --glob '!**/target/**'
  --glob '!**/node_modules/**'
  --glob '!**/.next/**'
  --glob '!**/*.lock'
  --glob '!tantra-runtime/crates/tantra-runtime-api-rest/tests/r5_removed_paths.rs'
  --glob '!tantra-runtime/crates/tantra-runtime-api-rest/tests/inproc_router.rs'
  --glob '!tantra-ui-web/src/lib/api-client.ts'
  --glob '!tantra-ui-web/src/lib/api-client.test.ts'
  --glob '!tantra-ui-web/src/lib/runtime-proxy.test.ts'
  --glob '!tantra-runtime/crates/tantra-runtime-api-rest/tests/chat_ws_gap0014.rs'
  --glob '!tantra-ui/crates/tantra-cli/tests/paper_test.rs'
  --glob '!**/docs/gaps/**'
  --glob '!**/docs/plans/**'
  --glob '!**/docs/design/**'
  --glob '!**/CHANGELOG*'
)

status=0
for pat in "${PATTERNS[@]}"; do
  if out=$(rg --pcre2 -n --no-heading "${EXCLUDES[@]}" -e "$pat" "${SCAN[@]}" 2>/dev/null); then
    echo "non-canonical runtime path (pattern: $pat):"
    echo "$out" | sed 's/^/  /'
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "api path gate: OK (only /api/v2 runtime paths referenced)"
fi
exit $status
