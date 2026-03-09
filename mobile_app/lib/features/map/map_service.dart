import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'mbtiles_tile_server.dart';

/// Service that manages offline tile serving via MBTiles and tile URL resolution.
///
/// Workflow:
/// 1. On init, check for local MBTiles at `<appFilesDir>/tiles/dev.mbtiles`
/// 2. If found, start a local HTTP tile server and use its URL
/// 3. Otherwise, use the remote tile URL from config or OSM fallback
/// 4. Remote tiles are cached via [CacheManager] for offline robustness
class MapService {
  MBTilesTileServer? _tileServer;
  bool _initialized = false;
  String? _resolvedTileUrl;
  bool _usingMBTiles = false;

  /// Custom cache manager for remote tiles with a 7-day cache duration.
  static final CacheManager tileCacheManager = CacheManager(
    Config(
      'openrescue_tile_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 5000,
    ),
  );

  /// Whether the service is using a local MBTiles file.
  bool get isUsingMBTiles => _usingMBTiles;

  /// The resolved tile URL template (local or remote).
  String? get tileUrl => _resolvedTileUrl;

  /// Initialize the map service. Must be called before using [tileUrl].
  ///
  /// [configTileUrl] is the optional remote tile URL from config.json.
  Future<void> initialize({String? configTileUrl}) async {
    if (_initialized) return;

    // Check for local MBTiles file
    final mbtilesPath = await _getMBTilesPath();
    if (mbtilesPath != null && await File(mbtilesPath).exists()) {
      debugPrint('MapService: Found MBTiles at $mbtilesPath');
      try {
        _tileServer = MBTilesTileServer(mbtilesPath: mbtilesPath);
        await _tileServer!.start();
        _resolvedTileUrl = _tileServer!.tileUrlTemplate;
        _usingMBTiles = true;
        debugPrint('MapService: Local tile server started at $_resolvedTileUrl');
      } catch (e) {
        debugPrint('MapService: Failed to start MBTiles server: $e');
        _resolvedTileUrl = _getRemoteFallbackUrl(configTileUrl);
      }
    } else {
      debugPrint('MapService: No MBTiles found, using remote tiles');
      _resolvedTileUrl = _getRemoteFallbackUrl(configTileUrl);
    }

    _initialized = true;
  }

  /// Resolve the tile URL from config.json or use OSM fallback.
  Future<String> resolveTileUrl() async {
    if (!_initialized) {
      // Load config tile URL
      String? configTileUrl;
      try {
        final configString = await rootBundle.loadString('assets/config.json');
        final configJson = jsonDecode(configString) as Map<String, dynamic>;
        configTileUrl = configJson['backend_tile_url'] as String?;
      } catch (_) {}
      await initialize(configTileUrl: configTileUrl);
    }
    return _resolvedTileUrl!;
  }

  /// Build a MapLibre style JSON string using the resolved tile URL.
  String buildStyleJson(String tileUrl) {
    return jsonEncode({
      'version': 8,
      'name': 'OpenRescue Tiles',
      'sources': {
        'base_tiles': {
          'type': 'raster',
          'tiles': [tileUrl],
          'tileSize': 256,
          'attribution': '© OpenStreetMap contributors',
        }
      },
      'layers': [
        {
          'id': 'base_tiles_layer',
          'type': 'raster',
          'source': 'base_tiles',
          'minzoom': 0,
          'maxzoom': 19,
        }
      ],
    });
  }

  /// Prefetch tiles within a bounding box for background download.
  ///
  /// This downloads remote tiles and stores them in the file cache so they
  /// are available offline. Only works when using remote tiles (not MBTiles).
  ///
  /// Parameters:
  /// - [lat], [lon]: center of the bounding box
  /// - [radiusKm]: radius in kilometers
  /// - [minZoom], [maxZoom]: zoom level range to prefetch
  ///
  /// Returns the number of tiles enqueued for download.
  ///
  /// Note: This is a best-effort implementation. For large areas or zoom ranges,
  /// the number of tiles can grow exponentially (4^zoom). Recommended limits:
  /// - radiusKm <= 10
  /// - maxZoom - minZoom <= 4
  /// - Total tiles per call <= 1000
  Future<int> prefetchTilesBoundingBox({
    required double lat,
    required double lon,
    required double radiusKm,
    required int minZoom,
    required int maxZoom,
  }) async {
    if (_usingMBTiles) {
      debugPrint('MapService: Prefetch not needed — using MBTiles');
      return 0;
    }

    final tileUrl = _resolvedTileUrl;
    if (tileUrl == null) return 0;

    int tileCount = 0;
    const maxTiles = 1000;

    for (int z = minZoom; z <= maxZoom && tileCount < maxTiles; z++) {
      final tiles = _getTilesInBounds(lat, lon, radiusKm, z);
      for (final tile in tiles) {
        if (tileCount >= maxTiles) break;
        final url = tileUrl
            .replaceFirst('{z}', z.toString())
            .replaceFirst('{x}', tile[0].toString())
            .replaceFirst('{y}', tile[1].toString());
        // Enqueue download via cache manager (non-blocking)
        unawaited(
          tileCacheManager
              .downloadFile(url)
              .then((_) {})
              .catchError((_) {}),
        );
        tileCount++;
      }
    }

    debugPrint('MapService: Enqueued $tileCount tiles for prefetch');
    return tileCount;
  }

  /// Get tile coordinates within a bounding box at a given zoom level.
  List<List<int>> _getTilesInBounds(
      double lat, double lon, double radiusKm, int zoom) {
    // Convert radius to approximate lat/lon degrees
    final latDelta = radiusKm / 111.32;
    final lonDelta = radiusKm / (111.32 * cos(lat * pi / 180));

    final minLat = lat - latDelta;
    final maxLat = lat + latDelta;
    final minLon = lon - lonDelta;
    final maxLon = lon + lonDelta;

    // Convert lat/lon to tile coordinates
    final minTileX = _lonToTileX(minLon, zoom);
    final maxTileX = _lonToTileX(maxLon, zoom);
    final minTileY = _latToTileY(maxLat, zoom); // Note: lat is inverted
    final maxTileY = _latToTileY(minLat, zoom);

    final tiles = <List<int>>[];
    for (int x = minTileX; x <= maxTileX; x++) {
      for (int y = minTileY; y <= maxTileY; y++) {
        tiles.add([x, y]);
      }
    }
    return tiles;
  }

  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180) / 360 * (1 << zoom)).floor();
  }

  int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * (1 << zoom))
        .floor();
  }

  /// Get the expected MBTiles file path on device.
  Future<String?> _getMBTilesPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return p.join(appDir.path, 'tiles', 'dev.mbtiles');
    } catch (e) {
      debugPrint('MapService: Could not resolve app directory: $e');
      return null;
    }
  }

  /// Get remote fallback tile URL.
  String _getRemoteFallbackUrl(String? configTileUrl) {
    return configTileUrl ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  /// Dispose and clean up resources.
  Future<void> dispose() async {
    await _tileServer?.stop();
    _tileServer = null;
    _initialized = false;
    _resolvedTileUrl = null;
  }
}
