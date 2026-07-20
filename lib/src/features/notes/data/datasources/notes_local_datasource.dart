import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  NotesLocalDataSource(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<NoteModel>> getAllNotes() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      AppConstants.notesTable,
      orderBy: 'updated_at DESC, id DESC',
    );

    return rows.map(NoteModel.fromMap).toList();
  }

  Future<NoteModel> insertNote(NoteModel note) async {
    final db = await _databaseHelper.database;
    final payload = note.toMap()..remove('id');

    final id = await db.insert(
      AppConstants.notesTable,
      payload,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return NoteModel(
      id: id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isFavorite: note.isFavorite,
      isActive: note.isActive,
      isSynced: note.isSynced,
    );
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.notesTable,
      note.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return note;
  }

  Future<void> deleteNote(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.notesTable,
      {
        'is_active': 0,
        'server_updated_status': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreNote(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.notesTable,
      {
        'is_active': 1,
        'server_updated_status': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> getUnsyncedNotes() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      AppConstants.notesTable,
      where: 'server_updated_status = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC, id DESC',
    );

    return rows.map(NoteModel.fromMap).toList();
  }

  Future<int> getPendingSyncCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppConstants.notesTable} WHERE server_updated_status = 0',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markNotesAsSynced(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }

    final db = await _databaseHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.rawUpdate(
      'UPDATE ${AppConstants.notesTable} SET server_updated_status = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }
}
