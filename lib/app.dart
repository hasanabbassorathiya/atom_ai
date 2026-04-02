import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/settings_service.dart';

class AtomAIApp extends ConsumerWidget {
  const AtomAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Atom AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settingsAsync.when(
        data: (settings) => settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        error: (e, st) => ThemeMode.light,
        loading: () => ThemeMode.light,
      ),
      routerConfig: router,
    );
  }
}
