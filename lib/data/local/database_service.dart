import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../models/conversation.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/atom_ai.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            system_prompt TEXT,
            message_count INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            token_count INTEGER,
            latency_ms INTEGER,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
      },
    );
  }

  // Conversations
  Future<List<Conversation>> getConversations() async {
    final db = await database;
    final maps =
        await db.query('conversations', orderBy: 'updated_at DESC');
    return maps.map(Conversation.fromMap).toList();
  }

  Future<void> upsertConversation(Conversation conv) async {
    final db = await database;
    await db.insert(
      'conversations',
      conv.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateConversationTitle(String id, String title) async {
    final db = await database;
    await db.update(
      'conversations',
      {'title': title, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Messages
  Future<List<Message>> getMessages(String conversationId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return maps.map(Message.fromMap).toList();
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
    await db.rawUpdate(
      'UPDATE conversations SET message_count = message_count + 1, updated_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), message.conversationId],
    );
  }

  Future<void> close() async {
    _db?.close();
    _db = null;
  }
}
