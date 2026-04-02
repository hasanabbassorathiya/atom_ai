import 'dart:math';
import 'package:edge_veda/edge_veda.dart';
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

  String _stateLabel(VoicePipelineState state) {
    switch (state) {
      case VoicePipelineState.idle:
        return 'IDLE';
      case VoicePipelineState.listening:
        return 'LISTENING';
      case VoicePipelineState.transcribing:
        return 'TRANSCRIBING';
      case VoicePipelineState.thinking:
        return 'THINKING';
      case VoicePipelineState.speaking:
        return 'SPEAKING';
      case VoicePipelineState.error:
        return 'ERROR';
    }
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
          // Orb Area
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
                      audioLevel: voiceState.state == VoicePipelineState.listening ? 0.3 + 0.7 * sin(_orbController.value * 10) : 0.0,
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
                      ? (voiceState.isRunning ? 'Speak and your words will appear here' : 'Tap the mic to start a voice conversation')
                      : voiceState.transcript,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                ),
              ),
            ),
          ),

          // Mic Button
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
                  try {
                    await ref.read(voiceServiceProvider.notifier).start();
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
                  boxShadow: [
                    BoxShadow(
                      color: (voiceState.isRunning ? theme.colorScheme.error : theme.colorScheme.primary).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
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
  final VoicePipelineState state;
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
      case VoicePipelineState.idle:
        _paintIdle(canvas, center, baseRadius);
        break;
      case VoicePipelineState.listening:
        _paintListening(canvas, center, baseRadius);
        break;
      case VoicePipelineState.transcribing:
        _paintTranscribing(canvas, center, baseRadius);
        break;
      case VoicePipelineState.thinking:
        _paintThinking(canvas, center, baseRadius);
        break;
      case VoicePipelineState.speaking:
        _paintSpeaking(canvas, center, baseRadius);
        break;
      case VoicePipelineState.error:
        _paintError(canvas, center, baseRadius);
        break;
    }
  }

  void _paintIdle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8, paint);
  }

  void _paintListening(Canvas canvas, Offset center, double radius) {
    final baseScale = 0.95 + 0.05 * sin(animationValue * 2 * pi);
    final levelScale = 1.0 + 0.2 * audioLevel;
    final scale = baseScale * levelScale;
    final glowRadius = radius * 1.3 * scale;
    final glowAlpha = 0.15 + 0.2 * audioLevel;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.success.withValues(alpha: glowAlpha),
          AppColors.success.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    final coreAlpha = 0.7 + 0.3 * audioLevel;
    final paint = Paint()
      ..color = AppColors.success.withValues(alpha: coreAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8 * scale, paint);
  }

  void _paintTranscribing(Canvas canvas, Offset center, double radius) {
    final scale = 0.85 + 0.15 * sin(animationValue * 4 * pi);
    final color = Color.lerp(
      AppColors.success,
      AppColors.primary,
      (sin(animationValue * 2 * pi) + 1) / 2,
    )!;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8 * scale, paint);
  }

  void _paintThinking(Canvas canvas, Offset center, double radius) {
    final rotationAngle = animationValue * 2 * pi;
    for (int i = 0; i < 3; i++) {
      final phase = i * (2 * pi / 3);
      final ringRadius = radius * (0.6 + 0.2 * i);
      final opacity = 0.4 - 0.1 * i;
      final ringScale = 0.95 + 0.05 * sin(rotationAngle + phase);

      final ringPaint = Paint()
        ..color = Color.lerp(
          AppColors.warning,
          AppColors.primary,
          (sin(rotationAngle + phase) + 1) / 2,
        )!.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(center, ringRadius * ringScale, ringPaint);
    }

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.warning.withValues(alpha: 0.9),
          AppColors.primary.withValues(alpha: 0.5),
        ],
        stops: const [0.3, 1.0],
        transform: GradientRotation(rotationAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));
    canvas.drawCircle(center, radius * 0.6, corePaint);
  }

  void _paintSpeaking(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 4; i++) {
      final phase = i * (2 * pi / 4);
      final waveValue = sin(animationValue * 4 * pi - phase);
      final ringRadius = radius * (0.5 + 0.15 * i) + 10 * waveValue;
      final opacity = (0.7 - 0.15 * i).clamp(0.1, 1.0);

      final ringPaint = Paint()
        ..color = AppColors.info.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    final corePaint = Paint()
      ..color = AppColors.info.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.45, corePaint);
  }

  void _paintError(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.error.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.audioLevel != audioLevel;
  }
}
