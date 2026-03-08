import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../core/config.dart';
import '../../data/repositories/incident_repository.dart';
import '../../models/models.dart' as models;
import '../messaging/messaging_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MaplibreMapController? _mapController;
  List<models.Incident> _incidents = [];

  String _buildStyleJson(String baseUrl) {
    // If we have an offline tileset, we would serve it locally and point here.
    // As per task, fallback to HTTP dev tile URL injected via AppConfig.
    // For demo/development, we use standard OSM raster tiles if no specific path is given.
    final tileUrl = '\$baseUrl/tiles/{z}/{x}/{y}.png'; // hypothetical backend tile endpoint
    final fallbackTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    
    return '''{
      "version": 8,
      "sources": {
        "base_tiles": {
          "type": "raster",
          "tiles": [
            "\$fallbackTileUrl"
          ],
          "tileSize": 256
        }
      },
      "layers": [
        {
          "id": "base_tiles_layer",
          "type": "raster",
          "source": "base_tiles",
          "minzoom": 0,
          "maxzoom": 22
        }
      ]
    }''';
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    
    _mapController!.onSymbolTapped.add((Symbol symbol) {
      final incidentId = symbol.data?['id'] as String?;
      if (incidentId != null) {
        _showIncidentDetails(incidentId);
      }
    });

    _refreshMarkers();
  }

  void _onStyleLoaded() {
    _refreshMarkers();
  }

  Future<void> _refreshMarkers() async {
    if (_mapController == null || _incidents.isEmpty) return;
    
    await _mapController!.clearSymbols();
    for (var incident in _incidents) {
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(incident.lat, incident.lon),
          iconImage: 'marker-15', // Ensure this icon exists in style or use fallback
          iconSize: 2.0,
          textField: incident.type,
          textOffset: const Offset(0, 1.5),
        ),
        {'id': incident.id},
      );
    }
  }

  void _showIncidentDetails(String id) async {
    final repo = context.read<IncidentRepository>();
    final incident = await repo.getIncident(id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Incident: \${incident.type}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Status: \${incident.status_enum}'),
              Text('Priority: \${incident.priority}'),
              Text('Reporter: \${incident.reporter_id}'),
              Text('Lat/Lon: \${incident.lat.toStringAsFixed(4)}, \${incident.lon.toStringAsFixed(4)}'),
            ],
          ),
        );
      },
    );
  }

  void _openCreateIncidentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _CreateIncidentForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final repo = context.watch<IncidentRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenRescue Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagingScreen()));
            },
          )
        ],
      ),
      body: FutureBuilder<String>(
        future: config.resolveBackendBaseUrl(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final baseUrl = snapshot.data!;

          return StreamBuilder<List<models.Incident>>(
            stream: repo.watchIncidents(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                _incidents = streamSnapshot.data!;
                // Update markers if map already loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshMarkers();
                });
              }

              return MaplibreMap(
                styleString: _buildStyleJson(baseUrl),
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 2.0,
                ),
                myLocationEnabled: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateIncidentForm,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

class _CreateIncidentForm extends StatefulWidget {
  const _CreateIncidentForm();

  @override
  State<_CreateIncidentForm> createState() => _CreateIncidentFormState();
}

class _CreateIncidentFormState extends State<_CreateIncidentForm> {
  final _typeController = TextEditingController(text: 'Medical');
  final _priorityController = TextEditingController(text: 'High');

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
          const Text('Report New Incident', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type')),
          TextField(controller: _priorityController, decoration: const InputDecoration(labelText: 'Priority')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final repo = context.read<IncidentRepository>();
              final dto = models.IncidentCreateDto(
                type: _typeController.text,
                lat: (Random().nextDouble() * 180) - 90, // Random location for demo
                lon: (Random().nextDouble() * 360) - 180,
                priority: _priorityController.text,
                status: 'New',
                client_id: 'device_123',
                sequence_num: DateTime.now().millisecondsSinceEpoch,
              );
              await repo.createIncident(dto);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident created & queued for sync')));
              }
              
              // Trigger sync
              repo.pushLocalChanges();
            },
            child: const Text('Save Incident'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
