import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:atom_ai/services/voice_service.dart' as voice_service;

import '../../core/theme/app_theme.dart';
import '../../core/widgets/model_selector_dropdown.dart';

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

  String _stateLabel(voice_service.VoicePipelineState state) {
    switch (state) {
      case voice_service.VoicePipelineState.idle:
        return 'IDLE';
      case voice_service.VoicePipelineState.listening:
        return 'LISTENING';
      case voice_service.VoicePipelineState.transcribing:
        return 'TRANSCRIBING';
      case voice_service.VoicePipelineState.thinking:
        return 'THINKING';
      case voice_service.VoicePipelineState.speaking:
        return 'SPEAKING';
      case voice_service.VoicePipelineState.error:
        return 'ERROR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voice_service.voiceServiceProvider);
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
                      state: voiceState.state,
                      animationValue: _orbController.value,
                      audioLevel: voiceState.state == voice_service.VoicePipelineState.listening ? 0.3 + 0.7 * sin(_orbController.value * 10) : 0.0,
                    ),
                  );
                },
              ),
            ),
          ),

          // State Label
          Text(
            _stateLabel(voiceState.state),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),

          // Transcript Area
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
                  await ref.read(voice_service.voiceServiceProvider.notifier).stop();
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
                  try {
                    await ref.read(voice_service.voiceServiceProvider.notifier).start();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
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
  final voice_service.VoicePipelineState state;
  final double animationValue;
  final double audioLevel;

  _OrbPainter({
    required this.state,
    required this.animationValue,
    required this.audioLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = 80.0;

    switch (state) {
      case voice_service.VoicePipelineState.idle:
        _paintIdle(canvas, center, baseRadius);
        break;
      case voice_service.VoicePipelineState.listening:
        _paintListening(canvas, center, baseRadius);
        break;
      case voice_service.VoicePipelineState.transcribing:
        _paintTranscribing(canvas, center, baseRadius);
        break;
      case voice_service.VoicePipelineState.thinking:
        _paintThinking(canvas, center, baseRadius);
        break;
      case voice_service.VoicePipelineState.speaking:
        _paintSpeaking(canvas, center, baseRadius);
        break;
      case voice_service.VoicePipelineState.error:
        _paintError(canvas, center, baseRadius);
        break;
    }
  }

  void _paintIdle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 40.0, paint);
  }

  void _paintListening(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final r = radius * (0.8 + 0.2 * audioLevel);
    canvas.drawCircle(center, r, paint);
  }

  void _paintTranscribing(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _paintThinking(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _paintSpeaking(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _paintError(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}
