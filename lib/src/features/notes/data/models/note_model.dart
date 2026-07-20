import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.isFavorite,
    super.isActive,
    super.isSynced,
  });

  factory NoteModel.fromMap(Map<String, Object?> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: (map['note'] as String?) ?? (map['content'] as String? ?? ''),
      isFavorite:
          ((map['is_pinned'] as int?) ?? (map['is_favorite'] as int?) ?? 0) ==
          1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      isSynced: (map['server_updated_status'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'note': content,
      'is_pinned': isFavorite ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'server_updated_status': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      isActive: isActive,
      isSynced: isSynced,
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isFavorite: note.isFavorite,
      isActive: note.isActive,
      isSynced: note.isSynced,
    );
  }
}
