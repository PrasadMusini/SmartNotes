import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/entities/note.dart';
import '../../notes/domain/repositories/notes_repository.dart';
import 'notes_state.dart';

class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier(this._repository) : super(const NotesState(isLoading: true)) {
    _initialize();
  }

  final NotesRepository _repository;
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _isSyncInProgress = false;

  Future<void> _initialize() async {
    await loadNotes();
    await _setupConnectivitySync();
  }

  Future<void> _setupConnectivitySync() async {
    final connectivity = Connectivity();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      result,
    ) {
      final hasInternet = _hasInternet(result);
      _updateConnectivityState(hasInternet);
      if (hasInternet) {
        syncPendingNotes();
      }
    });

    final initial = await connectivity.checkConnectivity();
    final hasInternet = _hasInternet(initial);
    _updateConnectivityState(hasInternet);
    if (hasInternet) {
      await syncPendingNotes();
    }
  }

  void _updateConnectivityState(bool hasInternet) {
    final isOffline = !hasInternet;
    if (state.isOffline == isOffline) {
      return;
    }

    state = state.copyWith(isOffline: isOffline);
  }

  bool _hasInternet(dynamic connectivityResult) {
    if (connectivityResult is ConnectivityResult) {
      return connectivityResult != ConnectivityResult.none;
    }

    if (connectivityResult is List<ConnectivityResult>) {
      return connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );
    }

    return false;
  }

  Future<void> _refreshPendingCount() async {
    final count = await _repository.getPendingSyncCount();
    state = state.copyWith(pendingSyncCount: count);
  }

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final notes = await _repository.getNotes();
      final pending = await _repository.getPendingSyncCount();
      state = state.copyWith(
        notes: notes,
        isLoading: false,
        pendingSyncCount: pending,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<Note?> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final created = await _repository.createNote(
        title: title,
        content: content,
      );
      final updated = [created, ...state.notes]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(notes: updated, clearError: true);
      await _refreshPendingCount();
      await syncPendingNotes();
      return created;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return null;
    }
  }

  Future<Note?> updateNote(Note note) async {
    try {
      final saved = await _repository.updateNote(note);
      final updated =
          state.notes.map((item) => item.id == saved.id ? saved : item).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(notes: updated, clearError: true);
      await _refreshPendingCount();
      await syncPendingNotes();
      return saved;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return null;
    }
  }

  Future<bool> deleteNote(Note note) async {
    if (note.id == null) {
      return false;
    }

    try {
      await _repository.deleteNote(note.id!);
      final updated =
          state.notes
              .map(
                (item) =>
                    item.id == note.id ? item.copyWith(isActive: false) : item,
              )
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(notes: updated, clearError: true);
      await _refreshPendingCount();
      await syncPendingNotes();
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  Future<void> restoreNote(Note note) async {
    if (note.id == null) {
      return;
    }

    try {
      await _repository.restoreNote(note.id!);
      final updated =
          state.notes
              .map(
                (item) =>
                    item.id == note.id ? item.copyWith(isActive: true) : item,
              )
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(notes: updated, clearError: true);
      await _refreshPendingCount();
      await syncPendingNotes();
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> toggleFavorite(Note note) async {
    try {
      final saved = await _repository.toggleFavorite(note);
      final updated =
          state.notes.map((item) => item.id == saved.id ? saved : item).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(notes: updated, clearError: true);
      await _refreshPendingCount();
      await syncPendingNotes();
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> syncPendingNotes() async {
    if (_isSyncInProgress) {
      return;
    }

    _isSyncInProgress = true;

    try {
      await _repository.syncPendingNotes();
      await _refreshPendingCount();
    } catch (_) {
      // Keep app fully offline-first: failures are retried automatically.
    } finally {
      _isSyncInProgress = false;
    }
  }

  void setFilter(NotesViewFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
