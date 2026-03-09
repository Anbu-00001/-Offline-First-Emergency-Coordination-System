# OpenRescue Mobile App

This is the Day-9 Flutter mobile client for OpenRescue.

## Features

*   **MapLibre Offline-Capable Map:** Displays mobile maps via MapLibre, supporting both remote tile fallback and local MBTiles (via in-app tile server).
*   **MBTiles Offline Tile Server:** When a `.mbtiles` file is present on-device, the app starts a local HTTP tile server (using `shelf`) that reads tiles from the SQLite-based MBTiles file and serves them to the map control. No internet required.
*   **Incident Marker Clustering:** Incident markers are clustered at low zoom levels for readability. Tap a cluster to see constituent incidents.
*   **Tile Caching:** Remote tiles are cached locally via `flutter_cache_manager` for offline robustness.
*   **Tile Prefetching:** `MapService.prefetchTilesBoundingBox()` enqueues tiles within a bounding box for background download.
*   **mDNS Discovery:** Automatically scans `_openrescue._tcp.local` to find the backend server seamlessly on a local network.
*   **Robust API Client:** Uses Dio with exponential backoff and retry strategy for all requests.
*   **WebSocket Messaging:** Includes an auto-reconnecting WebSocket client with a local DB store-and-forward mechanism.
*   **Local DB & Sync:** Implements Drift/SQLite for local-first persistence.
*   **Secure Auth Storage:** Employs `flutter_secure_storage` to keep JWT securely encrypted on devices.
*   **Clean Architecture:** Organizes under `core/`, `models/`, `data/`, and `features/`.

## Prerequisites & Backend Setup

1.  Make sure you start the backend first (see `backend/README.md` in the OpenRescue repository).
2.  Start the backend using uvicorn:
    ```bash
    cd ../backend
    source ../.venv_openrescue/bin/activate
    alembic upgrade head
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```
3.  Ensure the mDNS advertiser is running via the custom Python scripts (or within the app) on `8000`.

## Local Dev Configuration

The app will prefer mDNS discovery when resolving the backend address.
If you need to bypass mDNS (e.g., CI, or running on an Emulator where mDNS propagation is tricky), you can override the base URL via config.

1.  Copy `assets/config.example.json` to `assets/config.json`.
2.  Set your desired `base_url`:
    ```json
    {
      "base_url": "http://10.0.2.2:8000",
      "backend_tile_url": "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      "tile_style_url": null
    }
    ```
   *(Note: `10.0.2.2` is the special Android Emulator alias to `127.0.0.1` on your host machine. iOS uses `127.0.0.1`.)*

### Configuration Fields

| Field | Description | Default |
|---|---|---|
| `base_url` | Backend API base URL | Auto-detected via mDNS |
| `backend_tile_url` | Remote tile URL template (must use `{z}/{x}/{y}` placeholders) | OSM tiles |
| `tile_style_url` | Optional MapLibre style JSON URL | null (uses built-in raster style) |

## Day 9: MBTiles Offline Tiles

### How It Works

1.  **MBTiles Detection:** On startup, `MapService` checks for a file at `<appDocumentsDir>/tiles/dev.mbtiles`.
2.  **Local Tile Server:** If found, a lightweight HTTP server (using `shelf`) starts on `localhost` at an auto-assigned port.
3.  **Tile Serving:** The server reads tiles from the MBTiles `tiles` table, handling TMS↔XYZ Y-coordinate flip automatically.
4.  **Fallback:** If MBTiles is absent, the map uses the configured `backend_tile_url` or falls back to OpenStreetMap tiles.

### Placing MBTiles on Device/Emulator

1.  **Create or obtain MBTiles:** See `scripts/prepare_mbtiles_sample.sh` for instructions on creating small sample tilesets.
2.  **Push to emulator (Android):**
    ```bash
    # Find your app's data directory
    adb shell run-as com.example.mobile_app ls files/

    # Push MBTiles file
    adb push dev.mbtiles /data/local/tmp/dev.mbtiles
    adb shell run-as com.example.mobile_app mkdir -p files/tiles
    adb shell run-as com.example.mobile_app cp /data/local/tmp/dev.mbtiles files/tiles/dev.mbtiles
    ```
3.  **Alternative (desktop/iOS):** Place the file at the app's documents directory under `tiles/dev.mbtiles`.

### Running with MBTiles

```bash
# 1. Start backend
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000

# 2. Set up dev environment (adb reverse, etc.)
./scripts/start_dev_environment.sh

# 3. Push MBTiles to emulator
adb push dev.mbtiles /data/local/tmp/dev.mbtiles
adb shell run-as com.example.mobile_app mkdir -p files/tiles
adb shell run-as com.example.mobile_app cp /data/local/tmp/dev.mbtiles files/tiles/dev.mbtiles

# 4. Run the app
cd mobile_app && flutter run -d emulator-5554
```

The map will show an "OFFLINE" badge in the app bar when using local MBTiles.

## Development Helpers (ADB Reverse Proxy)

When running on an Android emulator, resolving `127.0.0.1` points to the emulator itself, not your host machine where the backend is running.
To seamlessly bridge this gap without changing code or editing config files constantly:

1.  We use `adb reverse tcp:8000 tcp:8000` to map the emulator's port 8000 to the host's port 8000.
2.  Use the included helper script to set this up automatically:
    ```bash
    # From the repo root layer:
    ./scripts/start_dev_environment.sh
    # or directly:
    ./scripts/dev_backend_proxy.sh
    ```

## Running the App

1.  Launch your emulator using available scripts (e.g., `scripts/run_emulator.sh`) or manually via Android Studio/Xcode.
2.  Run Flutter:
    ```bash
    cd mobile_app
    flutter run -d emulator-5554
    ```

## Architecture (Day 9 Map Flow)

```
┌──────────────┐     ┌─────────────────────┐
│  MapScreen   │────▶│    MapService        │
│  (MapLibre)  │     │  ├─ resolveTileUrl() │
└──────┬───────┘     │  ├─ prefetchTiles()  │
       │             │  └─ buildStyleJson() │
       │             └──────────┬───────────┘
       │                        │
       │           ┌────────────┴────────────┐
       │           ▼                         ▼
       │  ┌──────────────────┐  ┌───────────────────┐
       │  │ MBTilesTileServer│  │ Remote Tile URL   │
       │  │ (shelf + sqlite3)│  │ (OSM / config)    │
       │  │ localhost:<port>  │  │ + CacheManager    │
       │  └──────────────────┘  └───────────────────┘
       │
       ▼
┌──────────────────┐
│ IncidentRepo     │
│ watchIncidents() │
│ → Marker Cluster │
└──────────────────┘
```

## Acceptance Criteria (Day 9)

1.  **Map Display & MBTiles:** MapScreen renders tiles from local MBTiles server or remote URL.
2.  **Incident Markers:** Markers with clustering at low zoom. Tap → bottom sheet with View/Assign/Navigate.
3.  **Offline Robustness:** MBTiles serves tiles without internet; remote tiles are cached.
4.  **Long-press:** Pick location on map for new incident report.
5.  **No Backend Changes:** Strictly isolated to `mobile_app/*` folder.

