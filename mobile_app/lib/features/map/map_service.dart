import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/map/map_diagnostics.dart';
import 'mbtiles_tile_server.dart';

/// Hard fallback tile URL — always valid, FOSS-compliant.
const _kOsmFallbackUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Optional tileserver URL from --dart-define=TILESERVER_URL=...
/// When set, the tile URL resolution chain prefers this server.
/// Example: --dart-define=TILESERVER_URL=http://10.0.2.2:8080/data/india/{z}/{x}/{y}.png
const String _kTileserverUrlEnv =
    String.fromEnvironment('TILESERVER_URL', defaultValue: '');

/// Resolved: null when not configured, otherwise the URL template.
const String? _kTileserverUrl =
    _kTileserverUrlEnv == '' ? null : _kTileserverUrlEnv;

// ---------------------------------------------------------------------------
// India geographic bounds — used to restrict map view to India by default.
// These are additive constants; removing them reverts to world view.
// ---------------------------------------------------------------------------

/// Southernmost latitude of India bounding box.
const double indiaSouth = 6.5546079;

/// Westernmost longitude of India bounding box.
const double indiaWest = 68.1113787;

/// Northernmost latitude of India bounding box.
const double indiaNorth = 35.6745457;

/// Easternmost longitude of India bounding box.
const double indiaEast = 97.395561;

/// Approximate geographic center of India.
const LatLng indiaCenter = LatLng(22.3511148, 78.6677428);

/// Default zoom level showing all of India.
const double indiaDefaultZoom = 5.0;

/// Bounding box for India — used as maxBounds / cameraConstraint.
final LatLngBounds indiaBounds = LatLngBounds(
  const LatLng(indiaSouth, indiaWest),
  const LatLng(indiaNorth, indiaEast),
);

/// Service that manages offline tile serving via MBTiles and tile URL resolution.
///
/// Fallback chain (never leaves tile URL empty):
/// 1. Local MBTiles server → http://localhost:<port>/tiles/{z}/{x}/{y}.png
/// 2. Config remote tile URL from config.json `backend_tile_url`
/// 3. Hard fallback: https://tile.openstreetmap.org/{z}/{x}/{y}.png
class MapService {
  /// Expose the configured TILESERVER_URL for debug UI and tests.
  /// Returns null if not configured via --dart-define.
  static String? get configuredTileserverUrl => _kTileserverUrl;
  MBTilesTileServer? _tileServer;
  bool _initialized = false;
  String _resolvedTileUrl = _kOsmFallbackUrl; // Never empty!
  bool _usingMBTiles = false;
  String? _mbtilesPath;

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

  /// The resolved tile URL template (local or remote). Never null/empty.
  String get tileUrl => _resolvedTileUrl;

  /// The MBTiles path being checked.
  String? get mbtilesPath => _mbtilesPath;

  /// Tile server port (0 if not running).
  int get tileServerPort => _tileServer?.port ?? 0;

  /// A description of which fallback mode was used.
  String get fallbackMode {
    if (_usingMBTiles) return 'MBTiles local server';
    if (_resolvedTileUrl != _kOsmFallbackUrl) return 'Config remote URL';
    return 'OSM hard fallback';
  }

  /// Initialize the map service. Must be called before using [tileUrl].
  ///
  /// [configTileUrl] is the optional remote tile URL from config.json.
  Future<void> initialize({String? configTileUrl}) async {
    if (_initialized) return;

    // Check for local MBTiles file
    _mbtilesPath = await _getMBTilesPath();
    debugPrint('MapService: Checking MBTiles at: $_mbtilesPath');

    if (_mbtilesPath != null) {
      final mbtilesFile = File(_mbtilesPath!);
      final exists = await mbtilesFile.exists();
      debugPrint('MapService: MBTiles file exists: $exists');

      if (exists) {
        debugPrint('MapService: Found MBTiles at $_mbtilesPath');
        try {
          _tileServer = MBTilesTileServer(mbtilesPath: _mbtilesPath!);
          await _tileServer!.start();
          _resolvedTileUrl = _tileServer!.tileUrlTemplate;
          _usingMBTiles = true;
          debugPrint('MapService: Local tile server started at $_resolvedTileUrl');
        } catch (e) {
          debugPrint('MapService: Failed to start MBTiles server: $e');
          _resolvedTileUrl = _getRemoteFallbackUrl(configTileUrl);
          debugPrint('MapService: Falling back to remote: $_resolvedTileUrl');
        }
      } else {
        debugPrint('MapService: No MBTiles file found, using remote tiles');
        _resolvedTileUrl = _getRemoteFallbackUrl(configTileUrl);
        debugPrint('MapService: Resolved remote tile URL: $_resolvedTileUrl');
      }
    } else {
      debugPrint('MapService: Could not determine MBTiles path');
      _resolvedTileUrl = _getRemoteFallbackUrl(configTileUrl);
    }

    // Log diagnostics
    MapDiagnostics.logConfig(
      resolvedTileUrl: _resolvedTileUrl,
      mbtilesPath: _mbtilesPath,
      mbtilesDetected: _usingMBTiles,
      tileServerStarted: _tileServer != null,
      tileServerPort: tileServerPort,
      fallbackMode: fallbackMode,
    );

    _initialized = true;
  }

  /// Resolve the tile URL from config.json or use OSM fallback.
  /// Never returns null or empty.
  Future<String> resolveTileUrl() async {
    if (!_initialized) {
      // Load config tile URL
      String? configTileUrl;
      try {
        final configString = await rootBundle.loadString('assets/config.json');
        final configJson = jsonDecode(configString) as Map<String, dynamic>;
        configTileUrl = configJson['backend_tile_url'] as String?;
        debugPrint('MapService: Config tile URL: $configTileUrl');
      } catch (e) {
        debugPrint('MapService: No config.json or no tile URL: $e');
      }
      await initialize(configTileUrl: configTileUrl);
    }
    debugPrint('MapService: Final resolved tile URL: $_resolvedTileUrl');
    return _resolvedTileUrl;
  }

  /// Build a MapLibre style JSON string using the resolved tile URL.
  String buildStyleJson(String tileUrl) {
    final style = jsonEncode({
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
    debugPrint('MapService: Built style JSON (${style.length} chars) with tile URL: $tileUrl');
    return style;
  }

  /// Prefetch tiles within a bounding box for background download.
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

    int tileCount = 0;
    const maxTiles = 1000;

    for (int z = minZoom; z <= maxZoom && tileCount < maxTiles; z++) {
      final tiles = _getTilesInBounds(lat, lon, radiusKm, z);
      for (final tile in tiles) {
        if (tileCount >= maxTiles) break;
        final url = _resolvedTileUrl
            .replaceFirst('{z}', z.toString())
            .replaceFirst('{x}', tile[0].toString())
            .replaceFirst('{y}', tile[1].toString());
        unawaited(
          tileCacheManager
              .downloadFile(url)
              .then((_) => MapDiagnostics.recordTileSuccess())
              .catchError((e) => MapDiagnostics.recordTileFailure('$e')),
        );
        tileCount++;
      }
    }

    debugPrint('MapService: Enqueued $tileCount tiles for prefetch');
    return tileCount;
  }

  List<List<int>> _getTilesInBounds(
      double lat, double lon, double radiusKm, int zoom) {
    final latDelta = radiusKm / 111.32;
    final lonDelta = radiusKm / (111.32 * cos(lat * pi / 180));

    final minLat = lat - latDelta;
    final maxLat = lat + latDelta;
    final minLon = lon - lonDelta;
    final maxLon = lon + lonDelta;

    final minTileX = _lonToTileX(minLon, zoom);
    final maxTileX = _lonToTileX(maxLon, zoom);
    final minTileY = _latToTileY(maxLat, zoom);
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
      final path = p.join(appDir.path, 'tiles', 'dev.mbtiles');
      debugPrint('MapService: MBTiles expected path: $path');
      return path;
    } catch (e) {
      debugPrint('MapService: Could not resolve app directory: $e');
      return null;
    }
  }

  /// Get remote fallback tile URL. Never returns empty.
  /// Priority: TILESERVER_URL (dart-define) → config.json → OSM fallback.
  String _getRemoteFallbackUrl(String? configTileUrl) {
    // 1. Prefer TILESERVER_URL from --dart-define if set
    if (_kTileserverUrl != null) {
      debugPrint('MapService: Using TILESERVER_URL: $_kTileserverUrl');
      return _kTileserverUrl!;
    }
    // 2. Config file tile URL
    if (configTileUrl != null && configTileUrl.isNotEmpty) {
      return configTileUrl;
    }
    // 3. Hard fallback
    return _kOsmFallbackUrl;
  }

  /// Dispose and clean up resources.
  Future<void> dispose() async {
    await _tileServer?.stop();
    _tileServer = null;
    _initialized = false;
    _resolvedTileUrl = _kOsmFallbackUrl;
  }
}
