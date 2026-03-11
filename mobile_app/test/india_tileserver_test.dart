import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/map/map_service.dart';

void main() {
  group('MapService tileserver configuration', () {
    test('tileserverUrl constant is accessible', () {
      // The static const tileserverUrl should be defined (may be null by default)
      // This test verifies the constant exists and the class can be checked.
      final url = MapService.configuredTileserverUrl;
      // In test environment, TILESERVER_URL is not set via --dart-define,
      // so it should be null.
      expect(url, isNull);
    });

    test('MapService initializes with OSM fallback when no config', () async {
      final service = MapService();
      // Without initialization, tileUrl should be OSM fallback
      expect(service.tileUrl, contains('openstreetmap.org'));
    });

    test('MapService fallbackMode returns OSM hard fallback by default', () {
      final service = MapService();
      expect(service.fallbackMode, equals('OSM hard fallback'));
    });

    test('India bounds constants are valid for tileserver integration', () {
      expect(indiaSouth, closeTo(6.55, 0.1));
      expect(indiaNorth, closeTo(35.67, 0.1));
      expect(indiaWest, closeTo(68.11, 0.1));
      expect(indiaEast, closeTo(97.40, 0.1));
    });

    test('MapService exposes tileServerPort as 0 when not started', () {
      final service = MapService();
      expect(service.tileServerPort, equals(0));
    });

    test('MapService isUsingMBTiles is false by default', () {
      final service = MapService();
      expect(service.isUsingMBTiles, isFalse);
    });
  });
}
