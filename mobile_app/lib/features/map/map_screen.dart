import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'dart:math';


import '../../data/repositories/incident_repository.dart';
import '../../models/models.dart' as models;
import '../messaging/messaging_screen.dart';
import 'map_service.dart';

/// Represents a cluster of incidents at a specific location.
class _IncidentCluster {
  final double lat;
  final double lon;
  final List<models.Incident> incidents;

  _IncidentCluster({required this.lat, required this.lon, required this.incidents});

  bool get isSingle => incidents.length == 1;
  models.Incident get first => incidents.first;
  int get count => incidents.length;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _mapController;
  List<models.Incident> _incidents = [];
  double _currentZoom = 2.0;
  bool _mapReady = false;
  String? _tileUrl;
  bool _tileUrlResolved = false;

  /// Cluster radius in degrees — adjusts with zoom level.
  double get _clusterRadiusDeg {
    if (_currentZoom >= 14) return 0.001;
    if (_currentZoom >= 12) return 0.005;
    if (_currentZoom >= 10) return 0.02;
    if (_currentZoom >= 8) return 0.05;
    if (_currentZoom >= 6) return 0.2;
    if (_currentZoom >= 4) return 1.0;
    return 3.0;
  }

  @override
  void initState() {
    super.initState();
    _initTileUrl();
  }

  Future<void> _initTileUrl() async {
    final mapService = context.read<MapService>();
    final url = await mapService.resolveTileUrl();
    if (mounted) {
      setState(() {
        _tileUrl = url;
        _tileUrlResolved = true;
      });
    }
  }

  String _buildStyleJson(String tileUrl) {
    final mapService = context.read<MapService>();
    return mapService.buildStyleJson(tileUrl);
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;

    _mapController!.onSymbolTapped.add((Symbol symbol) {
      final incidentId = symbol.data?['id'] as String?;
      final clusterIds = symbol.data?['cluster_ids'] as String?;
      if (clusterIds != null) {
        _showClusterDetails(clusterIds.split(','));
      } else if (incidentId != null) {
        _showIncidentDetails(incidentId);
      }
    });
  }

  void _onStyleLoaded() {
    _mapReady = true;
    _refreshMarkers();
  }

  void _onCameraIdle() async {
    if (_mapController == null) return;
    final cameraPos = _mapController!.cameraPosition;
    if (cameraPos != null) {
      final newZoom = cameraPos.zoom;
      if ((newZoom - _currentZoom).abs() > 0.5) {
        _currentZoom = newZoom;
        _refreshMarkers();
      }
    }
  }

  /// Cluster incidents based on proximity at current zoom level.
  List<_IncidentCluster> _clusterIncidents(List<models.Incident> incidents) {
    if (incidents.isEmpty) return [];

    final radius = _clusterRadiusDeg;
    final clusters = <_IncidentCluster>[];
    final used = List<bool>.filled(incidents.length, false);

    for (int i = 0; i < incidents.length; i++) {
      if (used[i]) continue;

      final cluster = <models.Incident>[incidents[i]];
      double latSum = incidents[i].lat;
      double lonSum = incidents[i].lon;
      used[i] = true;

      for (int j = i + 1; j < incidents.length; j++) {
        if (used[j]) continue;
        final dLat = (incidents[j].lat - incidents[i].lat).abs();
        final dLon = (incidents[j].lon - incidents[i].lon).abs();
        if (dLat < radius && dLon < radius) {
          cluster.add(incidents[j]);
          latSum += incidents[j].lat;
          lonSum += incidents[j].lon;
          used[j] = true;
        }
      }

      clusters.add(_IncidentCluster(
        lat: latSum / cluster.length,
        lon: lonSum / cluster.length,
        incidents: cluster,
      ));
    }
    return clusters;
  }

  Future<void> _refreshMarkers() async {
    if (_mapController == null || !_mapReady) return;

    await _mapController!.clearSymbols();

    final clusters = _clusterIncidents(_incidents);

    for (var cluster in clusters) {
      if (cluster.isSingle) {
        await _mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(cluster.lat, cluster.lon),
            iconImage: 'marker-15',
            iconSize: 2.0,
            textField: cluster.first.type,
            textOffset: const Offset(0, 1.5),
            textSize: 12,
          ),
          {'id': cluster.first.id},
        );
      } else {
        // Cluster marker showing count
        await _mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(cluster.lat, cluster.lon),
            iconImage: 'marker-15',
            iconSize: 2.5,
            textField: '${cluster.count} incidents',
            textOffset: const Offset(0, 1.5),
            textSize: 14,
            textColor: '#FF0000',
          ),
          {
            'cluster_ids': cluster.incidents.map((i) => i.id).join(','),
          },
        );
      }
    }
  }

  void _showIncidentDetails(String id) async {
    final repo = context.read<IncidentRepository>();
    final incident = await repo.getIncident(id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Incident: ${incident.type}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.flag, 'Status', incident.status),
              _buildDetailRow(Icons.priority_high, 'Priority', incident.priority),
              _buildDetailRow(Icons.person, 'Reporter', incident.reporter_id),
              _buildDetailRow(Icons.location_on, 'Location',
                  '${incident.lat.toStringAsFixed(4)}, ${incident.lon.toStringAsFixed(4)}'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.visibility, 'View', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing incident details')));
                  }),
                  _buildActionButton(Icons.assignment_ind, 'Assign', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assign responder')));
                  }),
                  _buildActionButton(Icons.navigation, 'Navigate', () {
                    Navigator.pop(context);
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                          LatLng(incident.lat, incident.lon), 15),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }

  void _showClusterDetails(List<String> incidentIds) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final clusterIncidents =
            _incidents.where((i) => incidentIds.contains(i.id)).toList();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${clusterIncidents.length} Incidents',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...clusterIncidents.take(5).map((i) => ListTile(
                    leading: Icon(_incidentIcon(i.type)),
                    title: Text(i.type),
                    subtitle: Text('${i.status} — ${i.priority}'),
                    onTap: () {
                      Navigator.pop(context);
                      _showIncidentDetails(i.id);
                    },
                  )),
              if (clusterIncidents.length > 5)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                      '+ ${clusterIncidents.length - 5} more incidents',
                      style: TextStyle(color: Colors.grey[600])),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _incidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return Icons.medical_services;
      case 'fire':
        return Icons.local_fire_department;
      case 'flood':
        return Icons.water;
      case 'earthquake':
        return Icons.terrain;
      default:
        return Icons.warning;
    }
  }

  void _openCreateIncidentForm({double? lat, double? lon}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _CreateIncidentForm(initialLat: lat, initialLon: lon);
      },
    );
  }

  void _onMapLongPress(Point<double> point, LatLng coordinates) {
    _openCreateIncidentForm(lat: coordinates.latitude, lon: coordinates.longitude);
  }

  void _centerOnMyLocation() {
    // Default center or last known position
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(0, 0), 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<IncidentRepository>();
    final mapService = context.watch<MapService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('OpenRescue Map'),
            if (mapService.isUsingMBTiles) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('OFFLINE',
                    style: TextStyle(fontSize: 10, color: Colors.green,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnMyLocation,
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MessagingScreen()));
            },
          ),
        ],
      ),
      body: !_tileUrlResolved
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<models.Incident>>(
              stream: repo.watchIncidents(),
              builder: (context, streamSnapshot) {
                if (streamSnapshot.hasData) {
                  _incidents = streamSnapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _refreshMarkers();
                  });
                }

                return MapLibreMap(
                  styleString: _buildStyleJson(_tileUrl!),
                  onMapCreated: _onMapCreated,
                  onStyleLoadedCallback: _onStyleLoaded,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2.0,
                  ),
                  myLocationEnabled: true,
                  onMapLongClick: _onMapLongPress,
                  onCameraIdle: _onCameraIdle,
                  trackCameraPosition: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateIncidentForm(),
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

class _CreateIncidentForm extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;

  const _CreateIncidentForm({this.initialLat, this.initialLon});

  @override
  State<_CreateIncidentForm> createState() => _CreateIncidentFormState();
}

class _CreateIncidentFormState extends State<_CreateIncidentForm> {
  final _typeController = TextEditingController(text: 'Medical');
  final _priorityController = TextEditingController(text: 'High');
  late final TextEditingController _latController;
  late final TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
        text: widget.initialLat?.toStringAsFixed(6) ?? '');
    _lonController = TextEditingController(
        text: widget.initialLon?.toStringAsFixed(6) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Report New Incident',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (widget.initialLat != null && widget.initialLon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Location: ${widget.initialLat!.toStringAsFixed(4)}, '
                    '${widget.initialLon!.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),
          TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type')),
          TextField(
              controller: _priorityController,
              decoration: const InputDecoration(labelText: 'Priority')),
          if (widget.initialLat == null) ...[
            TextField(
                controller: _latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude')),
            TextField(
                controller: _lonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitude')),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Incident'),
            onPressed: () async {
              final repo = context.read<IncidentRepository>();
              final lat = widget.initialLat ??
                  double.tryParse(_latController.text) ??
                  (Random().nextDouble() * 180) - 90;
              final lon = widget.initialLon ??
                  double.tryParse(_lonController.text) ??
                  (Random().nextDouble() * 360) - 180;

              final dto = models.IncidentCreateDto(
                type: _typeController.text,
                lat: lat,
                lon: lon,
                priority: _priorityController.text,
                status: 'New',
                client_id: 'device_123',
                sequence_num: DateTime.now().millisecondsSinceEpoch,
              );
              await repo.createIncident(dto);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incident created & queued for sync')));
              }

              repo.pushLocalChanges();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
