import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showTop(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final state = messengerKey.currentState;
    final context = messengerKey.currentContext;

    if (state == null || context == null) {
      return;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    final topMargin = (mediaQuery?.padding.top ?? 0) + 24;
    final screenHeight = mediaQuery?.size.height ?? 800;
    final bottomMargin = (screenHeight - topMargin - 72)
        .clamp(24.0, screenHeight)
        .toDouble();

    state
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(12, topMargin, 12, bottomMargin),
          backgroundColor: backgroundColor,
        ),
      );
  }
}
