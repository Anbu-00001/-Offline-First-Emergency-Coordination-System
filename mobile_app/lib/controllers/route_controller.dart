import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../services/osrm_service.dart';

/// Controller to manage route requests and emit the current active route
class RouteController {
  final OSRMService _osrmService;

  // Stream controller to broadcast the latest route to the UI layer
  final StreamController<List<LatLng>> _routeStreamController =
      StreamController<List<LatLng>>.broadcast();

  RouteController(this._osrmService);

  Stream<List<LatLng>> get routeStream => _routeStreamController.stream;

  /// Requests a route from start to end and emits the result.
  /// Also emits an empty list first to clear any old route.
  Future<void> requestRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    // Clear previous route immediately
    _routeStreamController.add([]);

    final route = await _osrmService.fetchRoute(start: start, end: end);
    _routeStreamController.add(route);
  }

  void clearRoute() {
    _routeStreamController.add([]);
  }

  void dispose() {
    _routeStreamController.close();
  }
}
