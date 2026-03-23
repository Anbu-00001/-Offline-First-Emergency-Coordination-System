import 'package:latlong2/latlong.dart';

/// Checks if a point is within a polygon using the Ray Casting algorithm.
bool pointInPolygon(LatLng point, List<LatLng> polygon) {
  bool inside = false;
  for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final pi = polygon[i];
    final pj = polygon[j];

    if (((pi.longitude > point.longitude) != (pj.longitude > point.longitude)) &&
        (point.latitude <
            (pj.latitude - pi.latitude) *
                    (point.longitude - pi.longitude) /
                    (pj.longitude - pi.longitude) +
                pi.latitude)) {
      inside = !inside;
    }
  }
  return inside;
}

/// Checks if any point in a polyline intersects with a polygon
bool doesPolylineIntersectPolygon(List<LatLng> route, List<LatLng> polygon) {
  // Simple check: if any of the route points are inside the polygon
  for (final point in route) {
    if (pointInPolygon(point, polygon)) {
      return true;
    }
  }
  return false;
}
