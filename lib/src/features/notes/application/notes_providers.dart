import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/dio_client.dart';
import '../data/datasources/inspiration_remote_datasource.dart';
import '../data/datasources/notes_local_datasource.dart';
import '../data/datasources/notes_remote_datasource.dart';
import '../data/repositories/notes_repository_impl.dart';
import 'notes_notifier.dart';
import 'notes_state.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return NotesLocalDataSource(dbHelper);
});

final inspirationRemoteDataSourceProvider =
    Provider<InspirationRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return InspirationRemoteDataSource(dio);
    });

final notesRemoteDataSourceProvider = Provider<NotesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NotesRemoteDataSource(dio);
});

final notesRepositoryProvider = Provider<NotesRepositoryImpl>((ref) {
  final localDataSource = ref.watch(notesLocalDataSourceProvider);
  final remoteDataSource = ref.watch(notesRemoteDataSourceProvider);
  return NotesRepositoryImpl(localDataSource, remoteDataSource);
});

final notesNotifierProvider = StateNotifierProvider<NotesNotifier, NotesState>((
  ref,
) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesNotifier(repository);
});

final inspirationQuoteProvider = FutureProvider<String>((ref) async {
  try {
    final remoteDataSource = ref.watch(inspirationRemoteDataSourceProvider);
    return await remoteDataSource.fetchInspirationQuote();
  } catch (_) {
    return 'Write your next big idea. Offline first, always ready.';
  }
});
