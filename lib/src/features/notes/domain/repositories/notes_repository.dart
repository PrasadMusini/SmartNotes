import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getNotes();
  Future<Note> createNote({required String title, required String content});
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(int id);
  Future<void> restoreNote(int id);
  Future<Note> toggleFavorite(Note note);
  Future<void> syncPendingNotes();
  Future<int> getPendingSyncCount();
}
