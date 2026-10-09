import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MessageDatabase {
  static final MessageDatabase instance = MessageDatabase._init();
  static Database? _database;

  MessageDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mpesa_messages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        body TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMessage(String body, String timestamp) async {
    final db = await instance.database;
    return await db.insert('messages', {
      'body': body,
      'timestamp': timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await instance.database;
    return await db.query('messages', orderBy: 'id DESC');
  }
}