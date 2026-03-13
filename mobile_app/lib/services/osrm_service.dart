import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../core/config.dart';

/// Service for talking to the OSRM Routing API
class OSRMService {
  final http.Client _client;

  OSRMService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a route between two coordinate points
  /// Returns a list of LatLng points forming the route geometry
  Future<List<LatLng>> fetchRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final baseUrl = AppConfig.osrmBaseUrl;
      final uriStr = '$baseUrl/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final uri = Uri.parse(uriStr);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          if (geometry['type'] == 'LineString') {
            final coordinates = geometry['coordinates'] as List;
            return coordinates.map((coord) {
              // GeoJSON provides coordinates in [longitude, latitude] format
              final lon = (coord[0] as num).toDouble();
              final lat = (coord[1] as num).toDouble();
              return LatLng(lat, lon);
            }).toList();
          }
        }
      } else {
        debugPrint(
            'OSRMService: Failed to fetch route. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OSRMService: Exception fetching route: $e');
    }

    return []; // Return empty list on failure or empty route
  }
}
