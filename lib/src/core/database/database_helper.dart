import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'smart_notes.sqlite');

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createNotesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.notesTable}');
      await _createNotesTable(db);
    }
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.notesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        note TEXT,
        updated_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_pinned INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        server_updated_status INTEGER DEFAULT 0
      )
    ''');
  }
}
