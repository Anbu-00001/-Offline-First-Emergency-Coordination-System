import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/features/map/map_service.dart';

void main() {
  group('India bounds constants', () {
    test('India bounding box values are valid', () {
      expect(indiaSouth, greaterThan(0));
      expect(indiaNorth, greaterThan(indiaSouth));
      expect(indiaWest, greaterThan(0));
      expect(indiaEast, greaterThan(indiaWest));
    });

    test('India center is within bounding box', () {
      expect(indiaCenter.latitude, greaterThanOrEqualTo(indiaSouth));
      expect(indiaCenter.latitude, lessThanOrEqualTo(indiaNorth));
      expect(indiaCenter.longitude, greaterThanOrEqualTo(indiaWest));
      expect(indiaCenter.longitude, lessThanOrEqualTo(indiaEast));
    });

    test('India default zoom is reasonable', () {
      expect(indiaDefaultZoom, greaterThanOrEqualTo(3.0));
      expect(indiaDefaultZoom, lessThanOrEqualTo(8.0));
    });

    test('indiaBounds is a valid LatLngBounds containing center', () {
      expect(indiaBounds.south, indiaSouth);
      expect(indiaBounds.north, indiaNorth);
      expect(indiaBounds.west, indiaWest);
      expect(indiaBounds.east, indiaEast);
      expect(indiaBounds.contains(indiaCenter), isTrue);
    });

    test('indiaBounds does not contain locations far outside India', () {
      // London
      expect(indiaBounds.contains(const LatLng(51.5, -0.12)), isFalse);
      // New York
      expect(indiaBounds.contains(const LatLng(40.7, -74.0)), isFalse);
      // Sydney
      expect(indiaBounds.contains(const LatLng(-33.8, 151.2)), isFalse);
    });

    test('major Indian cities are within bounds', () {
      // Delhi
      expect(indiaBounds.contains(const LatLng(28.6139, 77.2090)), isTrue);
      // Mumbai
      expect(indiaBounds.contains(const LatLng(19.0760, 72.8777)), isTrue);
      // Chennai
      expect(indiaBounds.contains(const LatLng(13.0827, 80.2707)), isTrue);
      // Kolkata
      expect(indiaBounds.contains(const LatLng(22.5726, 88.3639)), isTrue);
    });
  });
}
