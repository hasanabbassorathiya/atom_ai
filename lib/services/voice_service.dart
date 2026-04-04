import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import '../domain/services/ai_interfaces.dart';
import 'voice_service_impl.dart';

final voiceServiceProvider = NotifierProvider<VoiceNotifier, VoiceServiceImpl>(VoiceNotifier.new);
=======
import 'model_service.dart';
import 'active_models_service.dart';

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
  // TODO: Implement orchestrator logic for LLM + TTS
  // VoicePipeline? _pipeline;
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)

class VoiceNotifier extends Notifier<VoiceServiceImpl> {
  @override
  VoiceServiceImpl build() => VoiceServiceImpl();

  Future<void> start() async {
<<<<<<< HEAD
    await state.startVoiceSession((transcript, response) {});
  }

  Future<void> stop() async {
    state.stopVoiceSession();
=======
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
      // TODO: Once transcribing is done, trigger LLM + TTS
    });

    await _whisperSession!.start();

    // Start microphone feed
    // final micStream = WhisperSession.microphone();
    // micStream.listen((samples) => _whisperSession!.feedAudio(samples));
  }

  Future<void> stop() async {
    await _whisperSession?.stop();
    await _whisperSession?.dispose();
    _whisperSession = null;
    state = VoiceState();
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
  }
}
