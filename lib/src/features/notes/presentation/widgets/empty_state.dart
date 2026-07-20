import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.onCreatePressed,
    this.isBinMode = false,
    super.key,
  });

  final VoidCallback onCreatePressed;
  final bool isBinMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 42,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBinMode ? 'Bin is empty' : 'Your notebook is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isBinMode
                  ? 'Deleted notes will appear here. Restore notes anytime.'
                  : 'Capture your thoughts and ideas by creating your first note.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // quoteAsync.when(
            //   data: (quote) => Text(
            //     quote,
            //     style: theme.textTheme.bodyMedium?.copyWith(
            //       color: theme.colorScheme.outline,
            //       fontStyle: FontStyle.italic,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            //   loading: () => const SizedBox.shrink(),
            //   error: (error, stackTrace) => const SizedBox.shrink(),
            // ),
            // const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isBinMode ? null : onCreatePressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                isBinMode ? 'No deleted notes' : 'Create your first note',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
