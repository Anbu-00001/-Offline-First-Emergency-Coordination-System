import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// A lightweight local HTTP tile server that serves tiles from an MBTiles
/// (SQLite) file. This enables fully offline map rendering when a `.mbtiles`
/// file is placed on-device.
///
/// MBTiles spec: https://github.com/mapbox/mbtiles-spec
/// Tiles are stored in the `tiles` table using TMS (Tile Map Service) scheme.
/// This server handles the TMS ↔ XYZ Y-coordinate flip automatically.
class MBTilesTileServer {
  final String mbtilesPath;
  HttpServer? _server;
  sqlite3.Database? _db;

  /// The port the server is listening on. Available after [start].
  int get port => _server?.port ?? 0;

  /// The full tile URL template for MapLibre. Available after [start].
  String get tileUrlTemplate =>
      'http://localhost:$port/tiles/{z}/{x}/{y}.png';

  MBTilesTileServer({required this.mbtilesPath});

  /// Creates an MBTilesTileServer from an already-opened database.
  /// Useful for testing with in-memory databases.
  MBTilesTileServer.fromDatabase(this._db) : mbtilesPath = ':memory:';

  /// Start the local HTTP tile server on an available port.
  Future<void> start() async {
    // Open the MBTiles database if not already opened (fromDatabase path)
    _db ??= sqlite3.sqlite3.open(mbtilesPath, mode: sqlite3.OpenMode.readOnly);

    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_handleRequest);

    // Bind to localhost on any available port (port 0)
    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    debugPrint('MBTiles tile server running on http://localhost:${_server!.port}');
  }

  /// Stop the local tile server and close the database.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _db?.close();
    _db = null;
  }

  /// Handle incoming tile requests.
  /// Expected path: /tiles/:z/:x/:y.png
  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final pathSegments = request.url.pathSegments;

    // Parse /tiles/{z}/{x}/{y}.png
    if (pathSegments.length != 4 || pathSegments[0] != 'tiles') {
      return shelf.Response.notFound('Invalid tile path');
    }

    final z = int.tryParse(pathSegments[1]);
    final x = int.tryParse(pathSegments[2]);
    // Remove .png extension from y
    final yStr = pathSegments[3].replaceAll(RegExp(r'\.(png|webp|pbf|jpg|jpeg)$'), '');
    final y = int.tryParse(yStr);

    if (z == null || x == null || y == null) {
      return shelf.Response.notFound('Invalid tile coordinates');
    }

    // Convert XYZ y to TMS y (MBTiles uses TMS convention)
    final tmsY = (1 << z) - 1 - y;

    try {
      final result = _db!.select(
        'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
        [z, x, tmsY],
      );

      if (result.isEmpty) {
        return shelf.Response.notFound('Tile not found');
      }

      final tileData = result.first['tile_data'] as Uint8List;

      // Detect content type from tile data header bytes
      final contentType = _detectContentType(tileData);

      return shelf.Response.ok(
        tileData,
        headers: {
          'Content-Type': contentType,
          'Content-Length': tileData.length.toString(),
          'Cache-Control': 'public, max-age=86400',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      debugPrint('MBTiles tile server error: $e');
      return shelf.Response.internalServerError(body: 'Error reading tile: $e');
    }
  }

  /// Detect content type from magic bytes of tile data.
  String _detectContentType(Uint8List data) {
    if (data.length >= 8) {
      // PNG magic bytes: 89 50 4E 47
      if (data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47) {
        return 'image/png';
      }
      // JPEG magic bytes: FF D8 FF
      if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
        return 'image/jpeg';
      }
      // WebP magic bytes: RIFF....WEBP
      if (data[0] == 0x52 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x46 &&
          data.length > 11 && data[8] == 0x57 && data[9] == 0x45 && data[10] == 0x42 && data[11] == 0x50) {
        return 'image/webp';
      }
      // PBF / protobuf (gzip header 1F 8B)
      if (data[0] == 0x1F && data[1] == 0x8B) {
        return 'application/x-protobuf';
      }
    }
    // Default to PNG
    return 'image/png';
  }
}
