import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model_service.dart';
import 'active_models_service.dart';
import 'package:edge_veda/edge_veda.dart';

enum VoicePipelineState { idle, listening, transcribing, thinking, speaking, error }

final voiceServiceProvider = NotifierProvider<VoiceNotifier, VoiceState>(VoiceNotifier.new);

class VoiceState {
  final VoicePipelineState state;
  final String transcript;
  final bool isRunning;

  VoiceState({
    this.state = VoicePipelineState.idle,
    this.transcript = '',
    this.isRunning = false,
  });

  VoiceState copyWith({
    VoicePipelineState? state,
    String? transcript,
    bool? isRunning,
  }) {
    return VoiceState(
      state: state ?? this.state,
      transcript: transcript ?? this.transcript,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class VoiceNotifier extends Notifier<VoiceState> {
  WhisperSession? _whisperSession;

  @override
  VoiceState build() => VoiceState();

  Future<void> start() async {
    final activeModels = ref.read(activeModelsProvider);
    final modelService = ref.read(modelServiceProvider);

    if (activeModels.sttModel == null || activeModels.chatModel == null) {
      throw Exception('Please select both a Chat and an STT model first.');
    }

    state = state.copyWith(state: VoicePipelineState.listening, isRunning: true);

    _whisperSession = WhisperSession(
      modelPath: await modelService.getModelPath(activeModels.sttModel!.id),
      numThreads: 4,
      useGpu: true,
      language: 'en',
    );

    _whisperSession!.onSegment.listen((segment) {
      state = state.copyWith(transcript: segment.text, state: VoicePipelineState.transcribing);
    });

    await _whisperSession!.start();
  }

  Future<void> stop() async {
    await _whisperSession?.stop();
    await _whisperSession?.dispose();
    _whisperSession = null;
    state = VoiceState();
  }
}
