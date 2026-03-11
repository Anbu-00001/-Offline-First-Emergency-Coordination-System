#!/usr/bin/env bash
# start_osrm.sh — Start the OSRM routing backend container.
#
# Checks for processed .osrm files and starts the container via docker compose.
# Exits gracefully with instructions if data files are missing.
#
# Usage:
#   bash scripts/start_osrm.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OSRM_DATA_DIR="${REPO_ROOT}/docker/osrm/data"
OSRM_FILE="${OSRM_DATA_DIR}/india-latest.osrm"
COMPOSE_FILE="${REPO_ROOT}/docker/osrm/docker-compose.osrm.yml"
ARTIFACTS_DIR="${REPO_ROOT}/artifacts/day10"
LOG_FILE="${ARTIFACTS_DIR}/osrm.log"

mkdir -p "${ARTIFACTS_DIR}"

echo "=== OpenRescue: Start OSRM Routing Backend ==="

# ─── Check prerequisites ───
if [ ! -f "${OSRM_FILE}" ]; then
    echo ""
    echo "⚠  OSRM data files not found at: ${OSRM_FILE}"
    echo ""
    echo "   You need to prepare the routing data first:"
    echo "   bash scripts/prepare_osrm_india.sh"
    echo ""
    echo "   See docs/day10_vector_tiles.md for full instructions."
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker not found. Install Docker and retry."
    exit 1
fi

# ─── Start OSRM container ───
OSRM_PORT="${OSRM_PORT:-5000}"
echo "Starting OSRM backend on port ${OSRM_PORT}..."

docker compose -f "${COMPOSE_FILE}" up -d 2>&1 | tee "${LOG_FILE}"

echo ""
echo "Waiting for OSRM to start..."
sleep 3

# ─── Health check ───
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${OSRM_PORT}/nearest/v1/driving/78.67,22.35" | grep -q "200"; then
    echo "✓ OSRM is running at http://localhost:${OSRM_PORT}/"
    echo ""
    echo "Test endpoints:"
    echo "  Nearest: curl 'http://localhost:${OSRM_PORT}/nearest/v1/driving/78.67,22.35'"
    echo "  Route:   curl 'http://localhost:${OSRM_PORT}/route/v1/driving/77.21,28.61;72.88,19.08'"
else
    echo "⚠  OSRM may not be ready yet."
    echo "   Check: docker logs openrescue_osrm"
fi

# ─── Save logs ───
docker logs openrescue_osrm > "${LOG_FILE}" 2>&1 || true

echo ""
echo "Logs: ${LOG_FILE}"
echo "Stop: docker compose -f ${COMPOSE_FILE} down"
