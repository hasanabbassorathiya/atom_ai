import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/focus_bar.dart';
import '../models/download_state.dart';
import 'providers/focus_mode_provider.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  static int _indexFromLocation(String location) {
    if (location.startsWith('/voice')) return 1;
    if (location.startsWith('/vision')) return 2;
    if (location.startsWith('/image')) return 3;
    if (location.startsWith('/documents')) return 4;
    if (location.startsWith('/models')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0;
  }

  static const _destinations = [
    (icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'Chat'),
    (icon: Icons.mic_none, selectedIcon: Icons.mic, label: 'Voice'),
    (icon: Icons.visibility_outlined, selectedIcon: Icons.visibility, label: 'Vision'),
    (icon: Icons.image_outlined, selectedIcon: Icons.image, label: 'Create'),
    (icon: Icons.description_outlined, selectedIcon: Icons.description, label: 'Docs'),
    (icon: Icons.download_outlined, selectedIcon: Icons.download, label: 'Models'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  static const _routes = [
    '/',
    '/voice',
    '/vision',
    '/image',
    '/documents',
    '/models',
    '/settings',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeDownloads = ref.watch(downloadStateProvider);
    final focusMode = ref.watch(focusModeProvider);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 80,
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            child: Column(
              children: [
                const SizedBox(height: 48), // Top padding/safe area
                Icon(
                  Icons.auto_awesome,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                  size: 32
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: _destinations.length,
                    itemBuilder: (context, index) {
                      final isSelected = currentIndex == index;
                      final dest = _destinations[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: InkWell(
                          onTap: () => context.go(_routes[index]),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight.withValues(alpha: 0.3))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? dest.selectedIcon : dest.icon,
                                  color: isSelected
                                      ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                      : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dest.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                      ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                      : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: FocusBar(
                    currentMode: focusMode,
                    onModeChanged: (newMode) => ref.read(focusModeProvider.notifier).state = newMode,
                  ),
                ),
              ],
            ),
          ),
          // Subtle divider line
          Container(
            width: 1,
            color: isDark ? const Color(0xFF40485D) : Colors.grey.shade200,
          ),
          Expanded(
            child: Stack(
              children: [
                child,
                if (activeDownloads.isNotEmpty && !location.startsWith('/models'))
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: _GlobalDownloadOverlay(downloads: activeDownloads),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalDownloadOverlay extends StatelessWidget {
  final Map<String, ActiveDownload> downloads;

  const _GlobalDownloadOverlay({required this.downloads});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = downloads.values.first;

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: active.progress,
                strokeWidth: 3,
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Downloading ${active.modelId}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${(active.progress * 100).toStringAsFixed(1)}% - Background task',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (downloads.length > 1) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${downloads.length - 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
