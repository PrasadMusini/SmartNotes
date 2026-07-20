import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_transitions.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../application/notes_providers.dart';
import '../../application/notes_state.dart';
import '../../domain/entities/note.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'about_screen.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _openEditor({Note? note}) async {
    await Navigator.of(
      context,
    ).push(AppTransitions.fadeSlide(NoteEditorScreen(note: note)));
  }

  Future<void> _openDetails(Note note) async {
    await Navigator.of(
      context,
    ).push(AppTransitions.fadeSlide(NoteDetailScreen(note: note)));
  }

  Future<void> _confirmDelete(Note note) async {
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
      if (deleted) {
        AppSnackbar.showTop('Note moved to Bin');
      }
    }
  }

  void _handleDrawerSelection(DrawerItem item) {
    Navigator.of(context).pop();
    final notifier = ref.read(notesNotifierProvider.notifier);

    switch (item) {
      case DrawerItem.allNotes:
        notifier.setFilter(NotesViewFilter.all);
      case DrawerItem.favorites:
        notifier.setFilter(NotesViewFilter.favorites);
      case DrawerItem.bin:
        notifier.setFilter(NotesViewFilter.bin);
      case DrawerItem.settings:
        Navigator.of(
          context,
        ).push(AppTransitions.fadeSlide(const SettingsScreen()));
      case DrawerItem.about:
        Navigator.of(
          context,
        ).push(AppTransitions.fadeSlide(const AboutScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesNotifierProvider);
    final notifier = ref.read(notesNotifierProvider.notifier);
    final visibleNotes = notesState.visibleNotes;

    ref.listen<NotesState>(notesNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showTop(next.errorMessage!);
        notifier.clearError();
      }
    });

    final pendingSuffix = notesState.pendingSyncCount > 0
        ? ' (${notesState.pendingSyncCount} Pending)'
        : '';

    return Scaffold(
      drawer: AppDrawer(
        activeFilter: notesState.filter,
        onItemSelected: _handleDrawerSelection,
      ),
      appBar: AppBar(
        title: Text(
          notesState.filter == NotesViewFilter.favorites
              ? 'Favorite Notes$pendingSuffix'
              : notesState.filter == NotesViewFilter.bin
              ? 'Bin$pendingSuffix'
              : 'Notes$pendingSuffix',
        ),
      ),
      body: Column(
        children: [
          if (notesState.isOffline) const _OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.loadNotes,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _buildBody(notesState, visibleNotes),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: notesState.filter == NotesViewFilter.bin
            ? null
            : () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildBody(NotesState notesState, List<Note> visibleNotes) {
    if (notesState.isLoading && notesState.notes.isEmpty) {
      return const _LoadingState();
    }

    if (notesState.errorMessage != null && notesState.notes.isEmpty) {
      return _ErrorState(
        message: notesState.errorMessage!,
        onRetry: ref.read(notesNotifierProvider.notifier).loadNotes,
      );
    }

    if (visibleNotes.isEmpty) {
      return EmptyState(
        onCreatePressed: _openEditor,
        isBinMode: notesState.filter == NotesViewFilter.bin,
      );
    }

    return ListView.separated(
      key: ValueKey(notesState.filter),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      itemCount: visibleNotes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = visibleNotes[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey('note_${note.id}'),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 180 + (index * 35).clamp(0, 220)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 14),
                child: child,
              ),
            );
          },
          child: NoteCard(
            note: note,
            isFaded: !note.isActive,
            trailing: notesState.filter == NotesViewFilter.bin
                ? IconButton(
                    tooltip: 'Restore note',
                    onPressed: () {
                      ref
                          .read(notesNotifierProvider.notifier)
                          .restoreNote(note);
                    },
                    icon: const Icon(Icons.restore_from_trash_rounded),
                  )
                : null,
            onTap: () => _openDetails(note),
            onLongPress: notesState.filter == NotesViewFilter.bin
                ? () {
                    ref.read(notesNotifierProvider.notifier).restoreNote(note);
                  }
                : () => _confirmDelete(note),
            onFavoriteToggle: () {
              if (!note.isActive) {
                return;
              }
              ref.read(notesNotifierProvider.notifier).toggleFavorite(note);
            },
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are offline. Notes will stay local and sync when internet returns.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: SizedBox(
              height: 110,
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 44,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Could not load notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
