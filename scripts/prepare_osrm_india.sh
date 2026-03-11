#!/usr/bin/env bash
# prepare_osrm_india.sh — Download India OSM PBF and process it for OSRM.
#
# If $OSM_PBF_URL is set, downloads the PBF and runs osrm-extract + osrm-contract.
# If not set, prints step-by-step instructions for the developer.
#
# Usage:
#   export OSM_PBF_URL='https://download.geofabrik.de/asia/india-latest.osm.pbf'
#   bash scripts/prepare_osrm_india.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OSRM_DATA_DIR="${REPO_ROOT}/docker/osrm/data"
PBF_FILE="${OSRM_DATA_DIR}/india-latest.osm.pbf"
OSRM_FILE="${OSRM_DATA_DIR}/india-latest.osrm"
ARTIFACTS_DIR="${REPO_ROOT}/artifacts/day10"

mkdir -p "${OSRM_DATA_DIR}" "${ARTIFACTS_DIR}"

echo "=== OpenRescue: Prepare OSRM India Routing Data ==="
echo "Data directory: ${OSRM_DATA_DIR}"
echo ""

# ─── Check if already processed ───
if [ -f "${OSRM_FILE}" ]; then
    echo "✓ OSRM data already exists: ${OSRM_FILE}"
    echo "  Delete docker/osrm/data/*.osrm* files to re-process."
    exit 0
fi

# ─── Check if PBF exists ───
if [ -f "${PBF_FILE}" ]; then
    echo "✓ PBF file found: ${PBF_FILE}"
else
    # Try to download if URL provided
    if [ -n "${OSM_PBF_URL:-}" ]; then
        echo "Downloading India PBF from: ${OSM_PBF_URL}"
        echo "  → ${PBF_FILE}"
        echo ""
        echo "⚠  WARNING: India PBF is ~600 MB. This may take a while."
        echo ""

        if command -v curl &>/dev/null; then
            curl -L -C - --progress-bar -o "${PBF_FILE}" "${OSM_PBF_URL}"
        elif command -v wget &>/dev/null; then
            wget -c --show-progress -O "${PBF_FILE}" "${OSM_PBF_URL}"
        else
            echo "ERROR: Neither curl nor wget found."
            exit 1
        fi

        echo "✓ Download complete: ${PBF_FILE}"
    else
        # No URL, no PBF — print instructions
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo " No OSM_PBF_URL environment variable set."
        echo " OSRM requires an India .osm.pbf extract to process."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Step 1 — Download India PBF (~600 MB):"
        echo ""
        echo "  export OSM_PBF_URL='https://download.geofabrik.de/asia/india-latest.osm.pbf'"
        echo "  bash scripts/prepare_osrm_india.sh"
        echo ""
        echo "Alternative sources:"
        echo "  • Geofabrik:  https://download.geofabrik.de/asia/india.html"
        echo "  • BBBike:     https://download.bbbike.org/osm/bbbike/Delhi/"
        echo "                (smaller city-level extracts for testing)"
        echo ""
        echo "Step 2 — Process with OSRM (requires Docker, ~8 GB RAM):"
        echo ""
        echo "  docker run --rm -v ${OSRM_DATA_DIR}:/data \\"
        echo "    osrm/osrm-backend:latest \\"
        echo "    osrm-extract -p /opt/car.lua /data/india-latest.osm.pbf"
        echo ""
        echo "  docker run --rm -v ${OSRM_DATA_DIR}:/data \\"
        echo "    osrm/osrm-backend:latest \\"
        echo "    osrm-partition /data/india-latest.osrm"
        echo ""
        echo "  docker run --rm -v ${OSRM_DATA_DIR}:/data \\"
        echo "    osrm/osrm-backend:latest \\"
        echo "    osrm-customize /data/india-latest.osrm"
        echo ""
        echo "Hardware recommendations:"
        echo "  • RAM: 8 GB minimum, 16 GB recommended for India"
        echo "  • Disk: ~5 GB free space for processed files"
        echo "  • CPU: 4+ cores recommended (extract is CPU-intensive)"
        echo "  • Time: 30–90 minutes depending on hardware"
        echo ""
        echo "Step 3 — Start OSRM server:"
        echo "  bash scripts/start_osrm.sh"
        echo ""
        exit 0
    fi
fi

# ─── Process PBF with OSRM (requires Docker) ───
if ! command -v docker &>/dev/null; then
    echo ""
    echo "⚠  Docker not found. Cannot process PBF."
    echo "   Install Docker and re-run this script."
    echo "   Or process manually — see above instructions."
    exit 1
fi

echo ""
echo "Step 2: Extracting road network (osrm-extract)..."
echo "  This may take 30-90 minutes for India."
echo ""

docker run --rm -v "${OSRM_DATA_DIR}:/data" \
    osrm/osrm-backend:latest \
    osrm-extract -p /opt/car.lua /data/india-latest.osm.pbf \
    2>&1 | tee "${ARTIFACTS_DIR}/osrm_extract.log"

echo ""
echo "Step 3: Partitioning (osrm-partition)..."
docker run --rm -v "${OSRM_DATA_DIR}:/data" \
    osrm/osrm-backend:latest \
    osrm-partition /data/india-latest.osrm \
    2>&1 | tee "${ARTIFACTS_DIR}/osrm_partition.log"

echo ""
echo "Step 4: Customizing (osrm-customize)..."
docker run --rm -v "${OSRM_DATA_DIR}:/data" \
    osrm/osrm-backend:latest \
    osrm-customize /data/india-latest.osrm \
    2>&1 | tee "${ARTIFACTS_DIR}/osrm_customize.log"

echo ""
echo "✓ OSRM data ready at: ${OSRM_DATA_DIR}"
echo "  Run: bash scripts/start_osrm.sh"
echo ""
