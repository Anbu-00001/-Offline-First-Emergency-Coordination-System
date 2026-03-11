# Day 10 — Vector Tile Server, MapLibre Demo & OSRM Preparation

This document describes how to set up the Dockerized **tileserver-gl** for serving vector MBTiles, preview vector tiles via **MapLibre GL JS** in the browser, prepare **OSRM routing** scaffolding, and how the mobile app restricts the default map view to India.

---

## 1. Architecture Overview

```
┌─────────────┐       ┌─────────────────────┐
│  Mobile App  │──────▶│  tileserver-gl       │
│  (FlutterMap)│  HTTP │  (Docker container)  │
│              │◀──────│  Port 8080 → 80      │
└─────────────┘       └──────────┬────────────┘
                                 │
                        docker/tileserver/data/
                              india.mbtiles

┌─────────────┐       ┌─────────────────────┐
│  MapLibre    │──────▶│  tileserver-gl       │
│  Web Demo    │  HTTP │  /styles/openrescue  │
│  (Browser)   │◀──────│  Vector + Raster     │
└─────────────┘       └─────────────────────┘

┌─────────────┐       ┌─────────────────────┐
│  Routing     │──────▶│  OSRM Backend        │
│  Clients     │  HTTP │  (Docker container)  │
│              │◀──────│  Port 5000           │
└─────────────┘       └──────────┬────────────┘
                                 │
                         docker/osrm/data/
                        india-latest.osrm*
```

**Tile resolution chain** (unchanged):
1. Local MBTiles server (on-device) — if available
2. TILESERVER_URL (--dart-define) — if configured
3. Backend tile server / config.json — if configured
4. OpenStreetMap fallback

---

## 2. Obtaining India MBTiles

India MBTiles files are large (typically 1–5 GB). The repo does **not** include them. Options:

### Option A — Download with a URL

```bash
export MBTILES_URL='https://your-server.com/india.mbtiles'
bash scripts/prepare_mbtiles_india.sh
```

### Option B — Generate using OpenMapTiles

1. Clone [openmaptiles/openmaptiles](https://github.com/openmaptiles/openmaptiles)
2. Set `BBOX=68.11,6.55,97.40,35.67` in `.env`
3. Run the tile generation pipeline:
   ```bash
   make generate-bbox-file && make download area=india
   make import-data && make generate-tiles-pg
   ```
4. Copy output to `docker/tileserver/data/india.mbtiles`

### Option C — Protomaps

Visit [protomaps.com](https://protomaps.com/downloads/protomaps), create an India extract, and download the `.mbtiles` file.

---

## 3. Running the Tile Server

```bash
# From repo root:
bash scripts/start_tileserver.sh
```

This will:
1. Create `docker/tileserver/data/` if missing
2. Download MBTiles if `$MBTILES_URL` is set
3. Start the tileserver-gl Docker container with OpenRescue style
4. Save logs to `artifacts/day10_tileserver/`

### Verify

```bash
# Status page
curl -I http://localhost:${TILESERVER_PORT:-8080}/

# Test a tile (zoom 5, India center)
curl -s -o /dev/null -w "%{http_code}" \
  http://localhost:8080/data/india/5/23/14.pbf

# Open in browser
xdg-open http://localhost:8080
```

### Stop

```bash
docker compose -f docker-compose.tileserver.yml down
```

---

## 4. MapLibre Web Demo (NEW)

A standalone browser-based preview at `web/maplibre-demo/index.html`.

### Run the demo

```bash
# 1. (Optional) Start tileserver for vector tiles
bash scripts/start_tileserver.sh

# 2. Serve the demo
cd web/maplibre-demo
python3 -m http.server 3000

# 3. Open
xdg-open http://localhost:3000
```

### Features

- **Vector / Raster toggle** — switch between tileserver vector and OSM raster
- **India-bounded** — center 22.35°N, 78.67°E, zoom 5
- **Auto fallback** — uses MapLibre public demotiles if tileserver is offline

---

## 5. OSRM Routing Preparation (NEW)

### Prerequisites

- Docker installed
- ~5 GB disk space for India routing data
- 8+ GB RAM recommended

### Step 1 — Prepare routing data

```bash
# With a PBF URL (recommended):
export OSM_PBF_URL='https://download.geofabrik.de/asia/india-latest.osm.pbf'
bash scripts/prepare_osrm_india.sh

# Without a URL: the script prints step-by-step instructions
bash scripts/prepare_osrm_india.sh
```

### Step 2 — Start OSRM

```bash
bash scripts/start_osrm.sh
```

### Step 3 — Test routing

```bash
# Nearest road
curl 'http://localhost:5000/nearest/v1/driving/78.67,22.35'

# Route: Delhi → Mumbai
curl 'http://localhost:5000/route/v1/driving/77.21,28.61;72.88,19.08'
```

### Stop

```bash
docker compose -f docker/osrm/docker-compose.osrm.yml down
```

---

## 6. Mobile App — India Map Bounds

The app now defaults to an India-centered view with restricted panning:

| Setting | Value |
|---------|-------|
| Center | 22.35°N, 78.67°E |
| Zoom | 5.0 |
| Min Zoom | 4 |
| Max Zoom | 18 |
| Bounds | 6.55°N–35.67°N, 68.11°E–97.40°E |

Constants are defined in `map_service.dart` and used by `map_screen.dart` via `CameraConstraint.containCenter(bounds: indiaBounds)`.

### TILESERVER_URL Configuration (NEW)

The mobile app now supports `TILESERVER_URL` via `--dart-define`:

```bash
flutter run --dart-define=TILESERVER_URL=http://10.0.2.2:8080/data/india/{z}/{x}/{y}.png
```

The resolution chain is now:
1. Local MBTiles server
2. **TILESERVER_URL** (from `--dart-define`)
3. Config file `backend_tile_url`
4. OSM hard fallback

The debug panel (🐛 button) shows the configured TILESERVER_URL.

---

## 7. Offline Testing with ADB

```bash
# 1. Push MBTiles to device
adb push docker/tileserver/data/india.mbtiles \
  /data/data/org.openrescue.mobile/app_flutter/tiles/dev.mbtiles

# 2. Restart the app — MapService detects local MBTiles
# 3. Debug Panel shows: Fallback Mode: MBTiles local server
```

---

## 8. Tileserver Style

The OpenRescue style is at `docker/tileserver/styles/openrescue-style.json`.

- Mapbox Style Spec v8 format — editable with [Maputnik](https://maputnik.github.io/)
- Layers: water, landcover, buildings, roads, admin boundaries, place labels
- Requires OpenMapTiles-compatible MBTiles source
- Config at `docker/tileserver/config.json` maps the style to the MBTiles data

---

## 9. Environment Variables

Add to `.env`:

```env
MBTILES_URL=             # URL to download India MBTiles (optional)
TILESERVER_PORT=8080     # Host port for tileserver-gl
OSM_PBF_URL=             # URL to download India OSM PBF for OSRM (optional)
OSRM_PORT=5000           # Host port for OSRM routing backend
```

---

## 10. Connecting Mobile App to Tileserver

When the tileserver is running, either:

**Option A — dart-define** (build time):
```bash
flutter run --dart-define=TILESERVER_URL=http://10.0.2.2:8080/data/india/{z}/{x}/{y}.png
```

**Option B — config.json** (runtime):
```json
{
  "backend_url": "http://10.0.2.2:8000",
  "backend_tile_url": "http://10.0.2.2:8080/data/india/{z}/{x}/{y}.png"
}
```

> `10.0.2.2` is the Android emulator's alias for the host machine's `localhost`.
