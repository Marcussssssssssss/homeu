import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:homeu/app/viewing/viewing_models.dart';

class ViewingLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'homeu_viewing_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE viewing_requests (
            id TEXT PRIMARY KEY,
            property_id TEXT,
            owner_id TEXT,
            tenant_id TEXT,
            scheduled_at TEXT,
            status TEXT,
            reschedule_to TEXT,
            reschedule_reason TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveViewingRequest(ViewingRequest request) async {
    final db = await database;
    await db.insert(
      'viewing_requests',
      request.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveViewingRequests(List<ViewingRequest> requests) async {
    final db = await database;
    final batch = db.batch();
    for (final request in requests) {
      batch.insert(
        'viewing_requests',
        request.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ViewingRequest>> getViewingRequests(String tenantId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'viewing_requests',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ViewingRequest.fromJson(map)).toList();
  }
}
