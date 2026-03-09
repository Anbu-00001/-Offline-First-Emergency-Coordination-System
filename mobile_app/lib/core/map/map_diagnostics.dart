import 'dart:io';
import 'package:flutter/foundation.dart';

/// Diagnostics helper for debugging MapLibre tile loading issues.
///
/// Provides structured logging of tile URL resolution, MBTiles detection,
/// tile server status, and HTTP tile request outcomes.
class MapDiagnostics {
  static String? _resolvedTileUrl;
  static String? _mbtilesPath;
  static bool _mbtilesDetected = false;
  static bool _tileServerStarted = false;
  static int _tileServerPort = 0;
  static String _fallbackMode = 'unknown';
  static int _tileRequestsServed = 0;
  static int _tileRequestsFailed = 0;
  static final List<String> _logEntries = [];

  /// Log the full tile configuration at startup.
  static void logConfig({
    required String resolvedTileUrl,
    required String? mbtilesPath,
    required bool mbtilesDetected,
    required bool tileServerStarted,
    required int tileServerPort,
    required String fallbackMode,
  }) {
    _resolvedTileUrl = resolvedTileUrl;
    _mbtilesPath = mbtilesPath;
    _mbtilesDetected = mbtilesDetected;
    _tileServerStarted = tileServerStarted;
    _tileServerPort = tileServerPort;
    _fallbackMode = fallbackMode;

    _log('====== MAP DIAGNOSTICS ======');
    _log('Resolved tile URL: $resolvedTileUrl');
    _log('MBTiles path: ${mbtilesPath ?? "not set"}');
    _log('MBTiles detected: $mbtilesDetected');
    _log('Tile server started: $tileServerStarted');
    if (tileServerStarted) {
      _log('Tile server port: $tileServerPort');
    }
    _log('Fallback mode: $fallbackMode');
    _log('============================');
  }

  /// Record a successful tile request.
  static void recordTileSuccess() {
    _tileRequestsServed++;
  }

  /// Record a failed tile request.
  static void recordTileFailure(String error) {
    _tileRequestsFailed++;
    _log('Tile request failed: $error');
  }

  /// Log a tile URL probe (HTTP HEAD check).
  static Future<bool> probeTileUrl(String tileUrl) async {
    // Build a test URL for z=0, x=0, y=0
    final testUrl = tileUrl
        .replaceFirst('{z}', '0')
        .replaceFirst('{x}', '0')
        .replaceFirst('{y}', '0');

    _log('Probing tile URL: $testUrl');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(testUrl));
      final response = await request.close();
      await response.drain();
      final success = response.statusCode == 200;
      _log('Tile probe result: HTTP ${response.statusCode} (${success ? "OK" : "FAIL"})');
      client.close();
      return success;
    } catch (e) {
      _log('Tile probe error: $e');
      return false;
    }
  }

  /// Get a summary of diagnostics for the debug panel.
  static Map<String, String> getSummary() {
    return {
      'Tile URL': _resolvedTileUrl ?? 'not resolved',
      'MBTiles Path': _mbtilesPath ?? 'not set',
      'MBTiles Detected': _mbtilesDetected.toString(),
      'Tile Server Running': _tileServerStarted.toString(),
      'Tile Server Port': _tileServerPort > 0 ? _tileServerPort.toString() : 'N/A',
      'Fallback Mode': _fallbackMode,
      'Tiles Served': _tileRequestsServed.toString(),
      'Tiles Failed': _tileRequestsFailed.toString(),
    };
  }

  /// Get all log entries.
  static List<String> getLogEntries() => List.unmodifiable(_logEntries);

  static void _log(String message) {
    _logEntries.add('[${DateTime.now().toIso8601String()}] $message');
    debugPrint('MapDiagnostics: $message');
  }

  /// Reset diagnostics (for testing).
  static void reset() {
    _resolvedTileUrl = null;
    _mbtilesPath = null;
    _mbtilesDetected = false;
    _tileServerStarted = false;
    _tileServerPort = 0;
    _fallbackMode = 'unknown';
    _tileRequestsServed = 0;
    _tileRequestsFailed = 0;
    _logEntries.clear();
  }
}
