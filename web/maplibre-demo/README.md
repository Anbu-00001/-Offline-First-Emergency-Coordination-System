# OpenRescue — MapLibre Vector Tile Demo

Developer tool for previewing vector and raster tile sources in-browser.

## Quick Start

```bash
# 1. (Optional) Start the tileserver for vector tiles
bash scripts/start_tileserver.sh

# 2. Serve this directory
cd web/maplibre-demo
python3 -m http.server 3000

# 3. Open in browser
xdg-open http://localhost:3000
```

## Features

- **Vector / Raster toggle** — switch between tileserver vector style and OSM raster tiles
- **India-bounded view** — default center 22.35°N, 78.67°E, zoom 5, max bounds restricted
- **Auto fallback** — if local tileserver is not running, falls back to MapLibre public demotiles

## Requirements

- Modern browser with WebGL support
- (Optional) Running tileserver-gl at `localhost:8080` for local vector tiles
- No Node.js or npm required — plain HTML + JS

## FOSS Compliance

- [MapLibre GL JS](https://maplibre.org/) — BSD-3-Clause
- [OpenStreetMap](https://www.openstreetmap.org/) — ODbL
- No proprietary APIs or services used
