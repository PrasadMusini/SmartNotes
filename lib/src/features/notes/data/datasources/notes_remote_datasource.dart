import 'package:dio/dio.dart';

import '../models/note_model.dart';

class NotesRemoteDataSource {
  NotesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> syncNotes(List<NoteModel> notes) async {
    if (notes.isEmpty) {
      return;
    }

    final payload = notes
        .map(
          (note) => {
            'id': note.id,
            'title': note.title,
            'note': note.content,
            'created_at': note.createdAt.toIso8601String(),
            'updated_at': note.updatedAt.toIso8601String(),
            'is_pinned': note.isFavorite ? 1 : 0,
            'is_active': note.isActive ? 1 : 0,
            'server_updated_status': 0,
          },
        )
        .toList();

    await _dio.post<Map<String, dynamic>>('/api/note', data: payload);
  }
}
