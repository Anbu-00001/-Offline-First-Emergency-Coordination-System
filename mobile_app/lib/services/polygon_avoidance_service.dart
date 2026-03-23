import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../models/polygon_model.dart';
import 'polygon_generator.dart';
import '../utils/geo_spatial_utils.dart';

class PolygonAvoidanceService {
  final PolygonGenerator _generator;

  PolygonAvoidanceService(this._generator);

  bool isRouteSafeWithPolygons(List<LatLng> route, List<Incident> incidents) {
    if (incidents.isEmpty) return true;

    final List<DangerPolygon> polygons = incidents.map((i) {
      debugPrint('POLYGON_GENERATED');
      return _generator.generatePolygonFromIncident(i);
    }).toList();

    for (final polygon in polygons) {
      if (doesPolylineIntersectPolygon(route, polygon.points)) {
        debugPrint('POLYGON_INTERSECTION_DETECTED');
        return false;
      }
    }
    return true;
  }
}
