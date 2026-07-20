import '../domain/entities/note.dart';

enum NotesViewFilter { all, favorites, bin }

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter = NotesViewFilter.all,
    this.pendingSyncCount = 0,
    this.isOffline = false,
  });

  final List<Note> notes;
  final bool isLoading;
  final String? errorMessage;
  final NotesViewFilter filter;
  final int pendingSyncCount;
  final bool isOffline;

  List<Note> get visibleNotes {
    if (filter == NotesViewFilter.favorites) {
      return notes.where((note) => note.isActive && note.isFavorite).toList();
    }

    if (filter == NotesViewFilter.bin) {
      return notes.where((note) => !note.isActive).toList();
    }

    return notes.where((note) => note.isActive).toList();
  }

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    NotesViewFilter? filter,
    int? pendingSyncCount,
    bool? isOffline,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      filter: filter ?? this.filter,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
