#!/usr/bin/env bash
# prepare_mbtiles_india.sh — Create tileserver data directory and optionally
# download India MBTiles if MBTILES_URL is set.
#
# Usage:
#   export MBTILES_URL=https://example.com/india.mbtiles  # optional
#   bash scripts/prepare_mbtiles_india.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="${REPO_ROOT}/docker/tileserver/data"
MBTILES_FILE="${DATA_DIR}/india.mbtiles"

echo "=== OpenRescue: Prepare India MBTiles ==="
echo "Data directory: ${DATA_DIR}"

# 1. Create the data directory
mkdir -p "${DATA_DIR}"
echo "✓ Directory ensured: ${DATA_DIR}"

# 2. Check if MBTiles already exists
if [ -f "${MBTILES_FILE}" ]; then
    SIZE=$(du -h "${MBTILES_FILE}" | cut -f1)
    echo "✓ MBTiles file already exists: ${MBTILES_FILE} (${SIZE})"
    echo "  Delete it manually if you want to re-download."
    exit 0
fi

# 3. Download if MBTILES_URL is set
if [ -n "${MBTILES_URL:-}" ]; then
    echo "Downloading MBTiles from: ${MBTILES_URL}"
    echo "  → ${MBTILES_FILE}"

    if command -v curl &>/dev/null; then
        curl -L -C - --progress-bar -o "${MBTILES_FILE}" "${MBTILES_URL}"
    elif command -v wget &>/dev/null; then
        wget -c --show-progress -O "${MBTILES_FILE}" "${MBTILES_URL}"
    else
        echo "ERROR: Neither curl nor wget found. Install one and retry."
        exit 1
    fi

    echo "✓ Download complete: ${MBTILES_FILE}"
    exit 0
fi

# 4. No URL provided — print instructions
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " No MBTILES_URL environment variable set."
echo " To use the tileserver you need an MBTiles file."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Option A — Download a pre-built MBTiles:"
echo "  export MBTILES_URL='https://your-url/india.mbtiles'"
echo "  bash scripts/prepare_mbtiles_india.sh"
echo ""
echo "Option B — Generate from OpenMapTiles (advanced):"
echo "  1. Clone https://github.com/openmaptiles/openmaptiles"
echo "  2. Edit .env to set BBOX=68.11,6.55,97.40,35.67 (India)"
echo "  3. Run: make generate-bbox-file && make download area=india"
echo "  4. Run: make import-data && make generate-tiles-pg"
echo "  5. Copy the output .mbtiles to ${MBTILES_FILE}"
echo ""
echo "Option C — Use Protomaps or similar:"
echo "  Visit https://protomaps.com/downloads/protomaps"
echo "  Create an India extract and download the .pmtiles/.mbtiles"
echo "  Place it at: ${MBTILES_FILE}"
echo ""
echo "Once placed, run: bash scripts/start_tileserver.sh"
echo ""
