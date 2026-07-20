import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_transitions.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../application/notes_providers.dart';
import '../../domain/entities/note.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.note, super.key});

  final Note note;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete note?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            'This action permanently removes the note from local storage.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final deleted = await ref
          .read(notesNotifierProvider.notifier)
          .deleteNote(note);
      if (deleted && context.mounted) {
        AppSnackbar.showTop('Note moved to Bin');
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openEditor(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(AppTransitions.fadeSlide(NoteEditorScreen(note: note)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUnsynced = !note.isSynced;
    final syncChipColor = isUnsynced
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.primaryContainer;
    final syncChipForeground = isUnsynced
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onPrimaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            tooltip: note.isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () {
              ref.read(notesNotifierProvider.notifier).toggleFavorite(note);
            },
            icon: Icon(
              note.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Edit note',
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete note',
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Hero(
        tag: 'note_${note.id}',
        child: Material(
          color: Colors.transparent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Chip(
                        avatar: Icon(
                          isUnsynced
                              ? Icons.cloud_upload_rounded
                              : Icons.cloud_done_rounded,
                          size: 16,
                          color: syncChipForeground,
                        ),
                        backgroundColor: syncChipColor,
                        side: BorderSide.none,
                        label: Text(
                          isUnsynced
                              ? 'Unsynced changes pending'
                              : 'Synced to server',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: syncChipForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        note.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(
                              'Created ${DateFormatter.dateAndTime(note.createdAt)}',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.update_rounded, size: 16),
                            label: Text(
                              'Updated ${DateFormatter.dateAndTime(note.updatedAt)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
