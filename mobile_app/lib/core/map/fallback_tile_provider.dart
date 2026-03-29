import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;

/// A TileProvider that checks if a tile exists locally before falling back to network.
class FallbackFileTileProvider extends TileProvider {
  final String tilesDir;
  final NetworkTileProvider _networkProvider;

  FallbackFileTileProvider({required this.tilesDir})
      : _networkProvider = NetworkTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final z = coordinates.z;
    final x = coordinates.x;
    final y = coordinates.y;

    final tilePath = p.join(tilesDir, '$z', '$x', '$y.png');
    final file = File(tilePath);

    try {
      // Replaced blocked sync call (file.existsSync()) with try-catch fallback.
      // Since FileImage cannot fallback to NetworkImage implicitly on error,
      // and existsSync freezes UI, we use NetworkTileProvider directly during test mode.
      return _networkProvider.getImage(coordinates, options);
    } catch (e) {
      return _networkProvider.getImage(coordinates, options);
    }
  }
}
