import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            _SettingsCard(
              title: 'Appearance',
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  value: settings.isDarkMode,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setDarkMode(v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'Inference Configuration',
              children: [
                ListTile(
                  title: const Text('Context Length'),
                  subtitle: Text('${settings.contextLength} tokens'),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => _showSliderDialog(
                    context,
                    title: 'Context Length',
                    value: settings.contextLength.toDouble(),
                    min: 512,
                    max: 8192,
                    divisions: 15,
                    suffix: ' tokens',
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .setContextLength(v.round()),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                ListTile(
                  title: const Text('Inference Threads'),
                  subtitle: Text('${settings.numThreads} threads'),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => _showSliderDialog(
                    context,
                    title: 'Inference Threads',
                    value: settings.numThreads.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    suffix: ' threads',
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setNumThreads(v.round()),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                SwitchListTile(
                  title: const Text('GPU Acceleration'),
                  subtitle: const Text('Use Metal/GPU for faster inference'),
                  value: settings.useGpu,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setUseGpu(v),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                ListTile(
                  title: const Text('Temperature'),
                  subtitle: Text(settings.temperature.toStringAsFixed(2)),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => _showSliderDialog(
                    context,
                    title: 'Temperature (Creativity)',
                    value: settings.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    suffix: '',
                    isDouble: true,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setTemperature(v),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                ListTile(
                  title: const Text('Top-P (Nucleus Sampling)'),
                  subtitle: Text(settings.topP.toStringAsFixed(2)),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => _showSliderDialog(
                    context,
                    title: 'Top-P',
                    value: settings.topP,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    suffix: '',
                    isDouble: true,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setTopP(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'Voice & Audio',
              children: [
                ListTile(
                  title: const Text('Silence Duration (VAD)'),
                  subtitle: Text('${settings.voiceSilenceDuration} ms'),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => _showSliderDialog(
                    context,
                    title: 'Silence Duration',
                    value: settings.voiceSilenceDuration.toDouble(),
                    min: 500,
                    max: 3000,
                    divisions: 5,
                    suffix: ' ms',
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setVoiceSilenceDuration(v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'Privacy & Security',
              children: [
                ListTile(
                  title: const Text('Data Storage'),
                  subtitle: const Text('All data stays strictly on your device'),
                  leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                ListTile(
                  title: const Text('Network Access'),
                  subtitle: const Text('Only used for model downloads'),
                  leading: Icon(Icons.wifi_off, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'About Atom AI',
              children: [
                const ListTile(
                  title: Text(AppConstants.appName),
                  subtitle: Text(
                      'v${AppConstants.appVersion}\nPowered by Edge Veda SDK'),
                  isThreeLine: true,
                  leading: Icon(Icons.auto_awesome, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSliderDialog(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
    bool isDouble = false,
  }) {
    var current = value;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: current,
                min: min,
                max: max,
                divisions: divisions,
                label: isDouble ? current.toStringAsFixed(2) : '${current.round()}$suffix',
                onChanged: (v) => setDialogState(() => current = v),
              ),
              Text(isDouble ? current.toStringAsFixed(2) : '${current.round()}$suffix', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onChanged(current);
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
