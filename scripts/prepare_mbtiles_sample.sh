#!/usr/bin/env bash
# ============================================================================
# prepare_mbtiles_sample.sh — Day 9 MBTiles Preparation Guide
# ============================================================================
#
# This script provides instructions for creating or obtaining small MBTiles
# tilesets for OpenRescue development. It does NOT download proprietary content.
#
# FOSS-COMPLIANT: All data sources listed here are open-source / open-data.
# ============================================================================

set -euo pipefail

echo "========================================"
echo " OpenRescue MBTiles Sample Preparation"
echo "========================================"
echo ""

# ---- Option 1: Create MBTiles from GeoJSON with tippecanoe ----
echo "=== Option 1: Using tippecanoe (recommended) ==="
echo ""
echo "1. Install tippecanoe:"
echo "   sudo apt-get install -y tippecanoe"
echo "   # or on macOS: brew install tippecanoe"
echo ""
echo "2. Download a small GeoJSON dataset (e.g., from Natural Earth):"
echo "   wget https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson"
echo ""
echo "3. Create MBTiles:"
echo "   tippecanoe -o dev.mbtiles -z8 --drop-densest-as-needed ne_110m_admin_0_countries.geojson"
echo ""

# ---- Option 2: Use tilemaker for raster tiles ----
echo "=== Option 2: Using tilemaker for OSM extracts ==="
echo ""
echo "1. Install tilemaker:"
echo "   sudo apt-get install -y tilemaker"
echo ""
echo "2. Download a small OSM extract (e.g., from Geofabrik for a small region):"
echo "   wget https://download.geofabrik.de/europe/andorra-latest.osm.pbf"
echo ""
echo "3. Create MBTiles with tilemaker:"
echo "   tilemaker --input andorra-latest.osm.pbf --output dev.mbtiles"
echo ""

# ---- Option 3: Convert existing raster tiles ----
echo "=== Option 3: Manual SQLite creation (for dev/test) ==="
echo ""
echo "You can create a minimal MBTiles file with sqlite3 directly:"
echo ""
cat <<'SQLITE_SCRIPT'
sqlite3 dev.mbtiles <<EOF
CREATE TABLE metadata (name TEXT, value TEXT);
CREATE TABLE tiles (zoom_level INTEGER, tile_column INTEGER, tile_row INTEGER, tile_data BLOB);
CREATE UNIQUE INDEX tile_index ON tiles (zoom_level, tile_column, tile_row);

INSERT INTO metadata VALUES ('name', 'dev-tileset');
INSERT INTO metadata VALUES ('format', 'png');
INSERT INTO metadata VALUES ('bounds', '-180,-85.0511,180,85.0511');
INSERT INTO metadata VALUES ('minzoom', '0');
INSERT INTO metadata VALUES ('maxzoom', '8');
INSERT INTO metadata VALUES ('type', 'baselayer');

-- Insert tiles using your own PNG tile images:
-- INSERT INTO tiles VALUES (0, 0, 0, readfile('tile_0_0_0.png'));
EOF
SQLITE_SCRIPT
echo ""

# ---- Placement Instructions ----
echo "=== Placing MBTiles on Device ==="
echo ""
echo "Android emulator:"
echo "  adb push dev.mbtiles /data/local/tmp/dev.mbtiles"
echo "  adb shell run-as com.example.mobile_app mkdir -p files/tiles"
echo "  adb shell run-as com.example.mobile_app cp /data/local/tmp/dev.mbtiles files/tiles/dev.mbtiles"
echo ""
echo "Desktop (Linux/macOS):"
echo "  The app looks for tiles at \$(path_provider getApplicationDocumentsDirectory)/tiles/dev.mbtiles"
echo "  Typically: ~/.local/share/com.example.mobile_app/tiles/dev.mbtiles"
echo ""
echo "=== Done! ==="
echo "After placing the MBTiles file, restart the app. It will detect the file"
echo "and start the local tile server automatically. Look for 'OFFLINE' badge in the app bar."
