#!/bin/bash
# ABOUTME: Serve scenario export outputs over a local HTTP server.
# ABOUTME: Useful for previewing HTML or JS outputs in a browser.

set -e

SCENARIO_ID=$1
PORT=${2:-8000}

if [ -z "$SCENARIO_ID" ]; then
    echo "Usage: $0 SCENARIO-YYYY-NNN [port]" >&2
    exit 1
fi

EXPORT_DIR="scenarios/active/${SCENARIO_ID}/exports"
if [ ! -d "$EXPORT_DIR" ]; then
    echo "Exports directory not found: ${EXPORT_DIR}" >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to serve exports." >&2
    exit 1
fi

cd "$EXPORT_DIR"
echo "Serving exports for ${SCENARIO_ID} at http://localhost:${PORT}"
python3 -m http.server "$PORT"
