import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FocusBar extends StatelessWidget {
  final String currentMode;
  final Function(String) onModeChanged;

  const FocusBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF40485D) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.center_focus_strong,
            color: isDark ? AppColors.primary : AppColors.primaryDark,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Mode: $currentMode',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 18,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
