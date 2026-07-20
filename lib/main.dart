import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/utils/app_snackbar.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/notes/presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartNotesApp()));
}

class SmartNotesApp extends StatelessWidget {
  const SmartNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Notes',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: AppSnackbar.messengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
