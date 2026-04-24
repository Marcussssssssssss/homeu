import 'dart:convert';

import 'package:homeu/app/profile/profile_models.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class HomeUProfileLocalDataSource {
  HomeUProfileLocalDataSource();

  static const _dbName = 'homeu_local_cache.db';
  static const _dbVersion = 1;
  static const _profileTable = 'cached_profiles';
  static const _preferenceTable = 'cached_user_preferences';
  static const _globalSettingsTable = 'app_global_settings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_profileTable(
            user_id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            role TEXT NOT NULL,
            profile_image_url TEXT,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_preferenceTable(
            user_id TEXT PRIMARY KEY,
            raw_json TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_globalSettingsTable(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<HomeUProfileData?> getCachedProfile(String userId) async {
    final db = await database;
    final rows = await db.query(
      _profileTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return HomeUProfileData.fromCacheMap(rows.first);
  }

  Future<void> saveProfile(HomeUProfileData profile) async {
    final db = await database;
    await db.insert(
      _profileTable,
      profile.toCacheMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedPreferences(String userId) async {
    final db = await database;
    final rows = await db.query(
      _preferenceTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final raw = rows.first['raw_json']?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<void> savePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    final db = await database;
    await db.insert(
      _preferenceTable,
      {
        'user_id': userId,
        'raw_json': jsonEncode(preferences),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getGlobalSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      _globalSettingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['value']?.toString();
  }

  Future<void> saveGlobalSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      _globalSettingsTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAuthData() async {
    final db = await database;
    await db.delete(_profileTable);
    await db.delete(_preferenceTable);
    // Note: $_globalSettingsTable is NOT cleared to preserve theme/language
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_profileTable);
    await db.delete(_preferenceTable);
    await db.delete(_globalSettingsTable);
  }
}
