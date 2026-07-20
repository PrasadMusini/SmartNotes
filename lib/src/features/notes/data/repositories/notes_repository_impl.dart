import '../../../../core/error/app_exception.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final NotesLocalDataSource _localDataSource;
  final NotesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Note>> getNotes() async {
    try {
      final notes = await _localDataSource.getAllNotes();
      return notes.map((note) => note.toEntity()).toList();
    } catch (_) {
      throw const AppException('Unable to load notes from local storage.');
    }
  }

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      title: title.trim(),
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
      isSynced: false,
    );

    try {
      final created = await _localDataSource.insertNote(note);
      return created.toEntity();
    } catch (_) {
      throw const AppException('Unable to save your note. Please try again.');
    }
  }

  @override
  Future<Note> updateNote(Note note) async {
    final updated = NoteModel.fromEntity(
      note.copyWith(updatedAt: DateTime.now(), isSynced: false),
    );

    try {
      final saved = await _localDataSource.updateNote(updated);
      return saved.toEntity();
    } catch (_) {
      throw const AppException('Unable to update your note. Please try again.');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await _localDataSource.deleteNote(id);
    } catch (_) {
      throw const AppException('Unable to delete the selected note.');
    }
  }

  @override
  Future<void> restoreNote(int id) async {
    try {
      await _localDataSource.restoreNote(id);
    } catch (_) {
      throw const AppException('Unable to restore the selected note.');
    }
  }

  @override
  Future<Note> toggleFavorite(Note note) {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    return updateNote(updated);
  }

  @override
  Future<void> syncPendingNotes() async {
    try {
      final unsynced = await _localDataSource.getUnsyncedNotes();
      if (unsynced.isEmpty) {
        return;
      }

      await _remoteDataSource.syncNotes(unsynced);
      final ids = unsynced.map((note) => note.id).whereType<int>().toList();
      await _localDataSource.markNotesAsSynced(ids);
    } catch (_) {
      throw const AppException('Unable to synchronize notes right now.');
    }
  }

  @override
  Future<int> getPendingSyncCount() {
    return _localDataSource.getPendingSyncCount();
  }
}
