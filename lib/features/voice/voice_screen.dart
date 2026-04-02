import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/model_selector_dropdown.dart';
import '../../services/voice_service.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.stt),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.chat),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedBuilder(
                animation: _orbController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: _OrbPainter(
                      isRunning: voiceState.isRunning,
                      animationValue: _orbController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  voiceState.transcript.isEmpty
                      ? (voiceState.isRunning ? 'Listening...' : 'Tap the mic to start a voice conversation')
                      : voiceState.transcript,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: GestureDetector(
              onTap: () async {
                if (voiceState.isRunning) {
                  await ref.read(voiceServiceProvider.notifier).stop();
                } else {
                  final status = await Permission.microphone.request();
                  if (status != PermissionStatus.granted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Microphone permission required')),
                      );
                    }
                    return;
                  }
                  await ref.read(voiceServiceProvider.notifier).start();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: voiceState.isRunning ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
                child: Icon(
                  voiceState.isRunning ? Icons.stop_rounded : Icons.mic,
                  color: theme.colorScheme.onPrimary,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final bool isRunning;
  final double animationValue;

  _OrbPainter({
    required this.isRunning,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = isRunning ? AppColors.primary : Colors.grey
      ..style = PaintingStyle.fill;

    final radius = isRunning ? 80.0 * (0.9 + 0.1 * sin(animationValue * 2 * pi)) : 40.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}
