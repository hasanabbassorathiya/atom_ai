
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/voice/voice_screen.dart';
import '../../features/vision/vision_screen.dart';
import '../../features/image_gen/image_gen_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/models/models_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/voice',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VoiceScreen(),
            ),
          ),
          GoRoute(
            path: '/vision',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisionScreen(),
            ),
          ),
          GoRoute(
            path: '/image',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ImageGenScreen(),
            ),
          ),
          GoRoute(
            path: '/documents',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsScreen(),
            ),
          ),
          GoRoute(
            path: '/models',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ModelsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
