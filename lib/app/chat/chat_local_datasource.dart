import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:homeu/app/chat/chat_models.dart';

class ChatLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'homeu_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_messages (
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            id TEXT,
            conversation_id TEXT,
            sender_id TEXT,
            message_text TEXT,
            attachment_url TEXT,
            created_at TEXT,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');
      },
    );
  }

  Future<int> insertMessage(
    ChatMessage message, {
    String syncStatus = 'pending',
  }) async {
    final db = await database;
    return await db.insert('local_messages', {
      'id': message.id,
      'conversation_id': message.conversationId,
      'sender_id': message.senderId,
      'message_text': message.messageText,
      'attachment_url': message.attachmentUrl,
      'created_at': message.createdAt.toIso8601String(),
      'sync_status': syncStatus,
    });
  }

  Future<List<ChatMessage>> getPendingMessages(String conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_messages',
      where: 'conversation_id = ? AND sync_status = ?',
      whereArgs: [conversationId, 'pending'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => ChatMessage.fromJson(map)).toList();
  }

  Future<List<ChatMessage>> getAllPendingMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_messages',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => ChatMessage.fromJson(map)).toList();
  }

  Future<void> markAsSynced(String localIdOrId) async {
    final db = await database;
    await db.update(
      'local_messages',
      {'sync_status': 'synced'},
      where: 'id = ? OR local_id = ?',
      whereArgs: [localIdOrId, localIdOrId],
    );
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete('local_messages', where: 'id = ?', whereArgs: [id]);
  }
}
