import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteToggle,
    this.isFaded = false,
    this.trailing,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteToggle;
  final bool isFaded;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnsynced = !note.isSynced;
    final statusBackground = isUnsynced
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.primaryContainer;
    final statusForeground = isUnsynced
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onPrimaryContainer;
    final borderColor = isUnsynced
        ? theme.colorScheme.tertiary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.55);

    return Hero(
      tag: 'note_${note.id}',
      child: Opacity(
        opacity: isFaded ? 0.48 : 1,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor, width: isUnsynced ? 1.4 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (trailing != null)
                        trailing!
                      else
                        IconButton(
                          onPressed: onFavoriteToggle,
                          icon: Icon(
                            note.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: note.isFavorite
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnsynced
                                  ? Icons.cloud_upload_rounded
                                  : Icons.cloud_done_rounded,
                              size: 16,
                              color: statusForeground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUnsynced ? 'Unsynced' : 'Synced',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusForeground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
