import 'package:latlong2/latlong.dart';

class DangerPolygon {
  final String id;
  final List<LatLng> points;
  final String incidentId;

  DangerPolygon({
    required this.id,
    required this.points,
    required this.incidentId,
  });
}
