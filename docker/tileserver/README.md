# OpenRescue Tileserver

This directory hosts the data for the [tileserver-gl](https://github.com/maptiler/tileserver-gl) Docker container.

## Directory Structure

```
docker/tileserver/
├── data/           ← Place .mbtiles files here
│   └── india.mbtiles  (not committed — too large)
└── README.md
```

## Quick Start

1. **Obtain an MBTiles file** for India (see `docs/day10_vector_tiles.md` for sources).
2. Place it at `docker/tileserver/data/india.mbtiles`.
3. From the repo root, run:
   ```bash
   bash scripts/start_tileserver.sh
   ```
4. Open http://localhost:8080 to verify the tile server is running.

## Tile Endpoints

Once the server is running with an MBTiles file:

| Endpoint | Description |
|----------|-------------|
| `http://localhost:8080/` | Web UI / status page |
| `http://localhost:8080/data/india/{z}/{x}/{y}.pbf` | Vector tiles (PBF) |
| `http://localhost:8080/styles/` | Available rendered styles |
| `http://localhost:8080/styles/basic-preview/{z}/{x}/{y}.png` | Rasterized tiles from style |

> **Note:** The exact endpoint paths depend on the MBTiles metadata and tileserver-gl configuration. Check the web UI for the correct URLs.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TILESERVER_PORT` | `8080` | Host port mapped to the tileserver |
| `MBTILES_URL` | _(empty)_ | URL to download MBTiles (used by `prepare_mbtiles_india.sh`) |
