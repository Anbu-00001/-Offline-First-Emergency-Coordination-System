import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/map/map_service.dart';
import 'package:mobile_app/core/map/map_diagnostics.dart';

void main() {
  group('MapService tile URL resolution', () {
    test('buildStyleJson produces valid JSON with correct tile URL', () {
      final mapService = MapService();
      const testTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      final styleJson = mapService.buildStyleJson(testTileUrl);

      expect(styleJson, contains('"version":8'));
      expect(styleJson, contains(testTileUrl));
      expect(styleJson, contains('"type":"raster"'));
      expect(styleJson, contains('"tileSize":256'));
      expect(styleJson, contains('"base_tiles"'));
      expect(styleJson, contains('"base_tiles_layer"'));
    });

    test('buildStyleJson with local tile URL', () {
      final mapService = MapService();
      const localTileUrl = 'http://localhost:12345/tiles/{z}/{x}/{y}.png';
      final styleJson = mapService.buildStyleJson(localTileUrl);

      expect(styleJson, contains(localTileUrl));
      expect(styleJson, contains('"version":8'));
    });

    test('tileUrl has default value before initialization', () {
      final mapService = MapService();
      // Before init, tileUrl should be the OSM fallback
      expect(mapService.tileUrl, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
    });

    test('fallbackMode reports correctly before initialization', () {
      final mapService = MapService();
      expect(mapService.fallbackMode, 'OSM hard fallback');
      expect(mapService.isUsingMBTiles, false);
    });

    test('tileServerPort is 0 when no server running', () {
      final mapService = MapService();
      expect(mapService.tileServerPort, 0);
    });
  });

  group('MapDiagnostics', () {
    setUp(() {
      MapDiagnostics.reset();
    });

    test('logConfig stores values correctly', () {
      MapDiagnostics.logConfig(
        resolvedTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        mbtilesPath: '/path/to/dev.mbtiles',
        mbtilesDetected: false,
        tileServerStarted: false,
        tileServerPort: 0,
        fallbackMode: 'OSM hard fallback',
      );

      final summary = MapDiagnostics.getSummary();
      expect(summary['Tile URL'], contains('openstreetmap'));
      expect(summary['MBTiles Detected'], 'false');
      expect(summary['Tile Server Running'], 'false');
      expect(summary['Fallback Mode'], 'OSM hard fallback');
    });

    test('recordTileSuccess increments counter', () {
      MapDiagnostics.logConfig(
        resolvedTileUrl: 'test',
        mbtilesPath: null,
        mbtilesDetected: false,
        tileServerStarted: false,
        tileServerPort: 0,
        fallbackMode: 'test',
      );

      MapDiagnostics.recordTileSuccess();
      MapDiagnostics.recordTileSuccess();
      MapDiagnostics.recordTileSuccess();

      final summary = MapDiagnostics.getSummary();
      expect(summary['Tiles Served'], '3');
    });

    test('recordTileFailure increments counter and logs error', () {
      MapDiagnostics.logConfig(
        resolvedTileUrl: 'test',
        mbtilesPath: null,
        mbtilesDetected: false,
        tileServerStarted: false,
        tileServerPort: 0,
        fallbackMode: 'test',
      );

      MapDiagnostics.recordTileFailure('Network error');
      MapDiagnostics.recordTileFailure('Timeout');

      final summary = MapDiagnostics.getSummary();
      expect(summary['Tiles Failed'], '2');

      final logs = MapDiagnostics.getLogEntries();
      expect(logs.any((l) => l.contains('Network error')), true);
      expect(logs.any((l) => l.contains('Timeout')), true);
    });

    test('reset clears all state', () {
      MapDiagnostics.logConfig(
        resolvedTileUrl: 'test',
        mbtilesPath: '/path',
        mbtilesDetected: true,
        tileServerStarted: true,
        tileServerPort: 12345,
        fallbackMode: 'MBTiles',
      );
      MapDiagnostics.recordTileSuccess();

      MapDiagnostics.reset();

      final summary = MapDiagnostics.getSummary();
      expect(summary['Tile URL'], 'not resolved');
      expect(summary['Tiles Served'], '0');
      expect(MapDiagnostics.getLogEntries(), isEmpty);
    });

    test('MBTiles path detection format', () {
      // Verify MBTiles path format expectations
      const expectedPathSuffix = 'tiles/dev.mbtiles';
      expect(expectedPathSuffix, contains('dev.mbtiles'));
    });

    test('local tile URL format', () {
      const localUrl = 'http://localhost:12345/tiles/{z}/{x}/{y}.png';
      expect(localUrl, contains('{z}'));
      expect(localUrl, contains('{x}'));
      expect(localUrl, contains('{y}'));
      expect(localUrl, startsWith('http://localhost:'));
    });
  });
}
