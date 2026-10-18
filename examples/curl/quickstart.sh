#!/usr/bin/env bash
# RailNow API quick start with curl.
# Usage: RAILNOW_API_KEY=jl_... ./quickstart.sh
set -euo pipefail

: "${RAILNOW_API_KEY:?Set RAILNOW_API_KEY to the key from https://railnow.runvia.app/developer}"
BASE="https://railnow.runvia.app/api/v1"

get() {
  curl -fsS -H "X-API-Key: ${RAILNOW_API_KEY}" "${BASE}$1"
  echo
}

echo "# Lines with real-time tracking"
get "/train/lines?lang=en"

echo "# Search stations named Gangnam"
get "/station/search?q=%EA%B0%95%EB%82%A8&lang=en"

echo "# Arrival board at Gangnam on Line 2 (station ID 1002000222)"
get "/station/1002000222/board?lang=en"

echo "# Every active train on Line 2"
get "/train/lines/1002/trains?lang=en&simple=true"
