import 'package:flutter/material.dart';

import '../../application/notes_state.dart';

enum DrawerItem { allNotes, favorites, bin, settings, about }

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.activeFilter,
    required this.onItemSelected,
    super.key,
  });

  final NotesViewFilter activeFilter;
  final ValueChanged<DrawerItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 34,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  'Smart Notes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Capture ideas quickly',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerTile(
            icon: Icons.notes_rounded,
            label: 'All Notes',
            selected: activeFilter == NotesViewFilter.all,
            onTap: () => onItemSelected(DrawerItem.allNotes),
          ),
          _DrawerTile(
            icon: Icons.star_rounded,
            label: 'Favorites',
            selected: activeFilter == NotesViewFilter.favorites,
            onTap: () => onItemSelected(DrawerItem.favorites),
          ),
          _DrawerTile(
            icon: Icons.delete_outline_rounded,
            label: 'Bin',
            selected: activeFilter == NotesViewFilter.bin,
            onTap: () => onItemSelected(DrawerItem.bin),
          ),
          _DrawerTile(
            icon: Icons.settings_rounded,
            label: 'Settings',
            selected: false,
            onTap: () => onItemSelected(DrawerItem.settings),
          ),
          _DrawerTile(
            icon: Icons.info_outline_rounded,
            label: 'About',
            selected: false,
            onTap: () => onItemSelected(DrawerItem.about),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }
}
