import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:mobile_app/features/map/mbtiles_tile_server.dart';

/// Creates an in-memory MBTiles SQLite database with test data.
/// Returns the database instance.
sqlite3.Database _createTestMBTilesDb() {
  final db = sqlite3.sqlite3.openInMemory();

  // Create MBTiles schema
  db.execute('''
    CREATE TABLE metadata (
      name TEXT NOT NULL,
      value TEXT NOT NULL
    )
  ''');

  db.execute('''
    CREATE TABLE tiles (
      zoom_level INTEGER NOT NULL,
      tile_column INTEGER NOT NULL,
      tile_row INTEGER NOT NULL,
      tile_data BLOB NOT NULL,
      PRIMARY KEY (zoom_level, tile_column, tile_row)
    )
  ''');

  // Insert metadata
  db.execute(
    "INSERT INTO metadata (name, value) VALUES ('name', 'test_tileset')",
  );
  db.execute(
    "INSERT INTO metadata (name, value) VALUES ('format', 'png')",
  );

  // Insert a test PNG tile at z=1, x=0, tms_y=1 (which maps to XYZ y=0)
  // Minimal PNG: 8-byte header
  final pngHeader = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
    0x49, 0x48, 0x44, 0x52, // IHDR
    0x00, 0x00, 0x00, 0x01, // width = 1
    0x00, 0x00, 0x00, 0x01, // height = 1
    0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, etc.
  ]);

  // z=1, x=0, tmsY=1 (XYZ y=0 → TMS y = (1<<1)-1-0 = 1)
  final stmt = db.prepare(
    'INSERT INTO tiles (zoom_level, tile_column, tile_row, tile_data) VALUES (?, ?, ?, ?)',
  );
  stmt.execute([1, 0, 1, pngHeader]);

  // Also insert a tile at z=2, x=1, tmsY=2 (XYZ y=1 → TMS y = (1<<2)-1-1 = 2)
  stmt.execute([2, 1, 2, pngHeader]);
  stmt.close();

  return db;
}

void main() {
  group('MBTilesTileServer', () {
    late sqlite3.Database testDb;
    late MBTilesTileServer server;

    setUp(() async {
      testDb = _createTestMBTilesDb();
      server = MBTilesTileServer.fromDatabase(testDb);
      await server.start();
    });

    tearDown(() async {
      await server.stop();
    });

    test('serves a known tile with correct content', () async {
      final port = server.port;
      expect(port, greaterThan(0));

      // Request tile z=1, x=0, y=0 (XYZ) → should map to TMS y=1
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('http://localhost:$port/tiles/1/0/0.png'),
      );
      final response = await request.close();

      expect(response.statusCode, 200);
      expect(response.headers.contentType?.mimeType, 'image/png');

      // Read the response body
      final body = await response.fold<List<int>>(
        <int>[],
        (prev, chunk) => prev..addAll(chunk),
      );
      expect(body.length, greaterThan(0));

      // Verify PNG magic bytes
      expect(body[0], 0x89);
      expect(body[1], 0x50);
      expect(body[2], 0x4E);
      expect(body[3], 0x47);

      client.close();
    });

    test('returns 404 for missing tile', () async {
      final port = server.port;
      final client = HttpClient();

      // Request a tile we didn't insert
      final request = await client.getUrl(
        Uri.parse('http://localhost:$port/tiles/5/10/10.png'),
      );
      final response = await request.close();
      await response.drain();

      expect(response.statusCode, 404);

      client.close();
    });

    test('returns 404 for invalid path', () async {
      final port = server.port;
      final client = HttpClient();

      final request = await client.getUrl(
        Uri.parse('http://localhost:$port/invalid/path'),
      );
      final response = await request.close();
      await response.drain();

      expect(response.statusCode, 404);

      client.close();
    });

    test('tileUrlTemplate has correct format', () {
      final port = server.port;
      expect(
        server.tileUrlTemplate,
        'http://localhost:$port/tiles/{z}/{x}/{y}.png',
      );
    });

    test('handles TMS y-flip correctly for z=2 tile', () async {
      final port = server.port;
      final client = HttpClient();

      // z=2, x=1, y=1 (XYZ) → TMS y = (1<<2)-1-1 = 2
      final request = await client.getUrl(
        Uri.parse('http://localhost:$port/tiles/2/1/1.png'),
      );
      final response = await request.close();

      expect(response.statusCode, 200);

      final body = await response.fold<List<int>>(
        <int>[],
        (prev, chunk) => prev..addAll(chunk),
      );
      expect(body.length, greaterThan(0));

      client.close();
    });
  });
}
