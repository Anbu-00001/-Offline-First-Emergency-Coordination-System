import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../models/polygon_model.dart';

class PolygonGenerator {
  static const double _earthRadiusMeters = 6378137.0; // WGS84

  DangerPolygon generatePolygonFromIncident(Incident incident) {
    double radius;
    switch (incident.type.toLowerCase()) {
      case 'fire':
        radius = 150.0;
        break;
      case 'accident':
        radius = 100.0;
        break;
      case 'flood':
        radius = 300.0;
        break;
      default:
        radius = 100.0;
    }

    const int numPoints = 12;
    final List<LatLng> points = [];

    for (int i = 0; i < numPoints; i++) {
      final double angle = (i * 360 / numPoints) * math.pi / 180.0;

      double latRad = incident.lat * math.pi / 180.0;

      double dLat = radius / _earthRadiusMeters;
      double dLon = radius / (_earthRadiusMeters * math.cos(latRad));

      double newLat = incident.lat + (dLat * math.cos(angle)) * 180.0 / math.pi;
      double newLon = incident.lon + (dLon * math.sin(angle)) * 180.0 / math.pi;

      points.add(LatLng(newLat, newLon));
    }

    return DangerPolygon(
      id: '${incident.id}_poly',
      points: points,
      incidentId: incident.id,
    );
  }
}
