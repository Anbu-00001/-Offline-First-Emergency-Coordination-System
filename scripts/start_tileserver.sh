#!/usr/bin/env bash
# start_tileserver.sh — Prepare MBTiles and start the tileserver-gl container.
#
# Usage:
#   bash scripts/start_tileserver.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="${REPO_ROOT}/artifacts/day10_tileserver"
LOG_FILE="${ARTIFACTS_DIR}/tileserver.log"

mkdir -p "${ARTIFACTS_DIR}"

echo "=== OpenRescue: Start Tileserver ==="

# 1. Prepare MBTiles data directory
echo "Step 1: Preparing MBTiles..."
bash "${REPO_ROOT}/scripts/prepare_mbtiles_india.sh" 2>&1 | tee "${ARTIFACTS_DIR}/prepare_mbtiles_india.out"

# 2. Check if MBTiles file exists (server needs at least one)
MBTILES_FILE="${REPO_ROOT}/docker/tileserver/data/india.mbtiles"
if [ ! -f "${MBTILES_FILE}" ]; then
    echo ""
    echo "⚠  No MBTiles file found at ${MBTILES_FILE}"
    echo "   The tileserver will start but may show an empty map."
    echo "   See docs/day10_vector_tiles.md for how to obtain tiles."
    echo ""
fi

# 3. Start tileserver via docker compose
echo "Step 2: Starting tileserver container..."
TILESERVER_PORT="${TILESERVER_PORT:-8080}"

if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker is not installed or not in PATH."
    echo "Install Docker and retry: https://docs.docker.com/get-docker/"
    exit 1
fi

docker compose -f "${REPO_ROOT}/docker-compose.tileserver.yml" up -d 2>&1 | tee -a "${LOG_FILE}"

echo ""
echo "Step 3: Waiting for container to start..."
sleep 3

# 4. Health check
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${TILESERVER_PORT}/" | grep -q "200"; then
    echo "✓ Tileserver is running at http://localhost:${TILESERVER_PORT}/"
else
    echo "⚠  Tileserver may not be fully ready yet."
    echo "   Check: docker logs openrescue_tileserver"
fi

# 5. Save container logs
docker logs openrescue_tileserver > "${LOG_FILE}" 2>&1 || true

echo ""
echo "Logs saved to: ${LOG_FILE}"
echo "Artifacts dir:  ${ARTIFACTS_DIR}"
echo ""
echo "To stop: docker compose -f docker-compose.tileserver.yml down"
