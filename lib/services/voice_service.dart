import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_runtime_service.dart';
import 'model_service.dart';
import 'tts_service.dart';
import 'active_models_service.dart';
import 'settings_service.dart';

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
  VoicePipeline? _pipeline;

  @override
  VoiceState build() => VoiceState();

  Future<void> start() async {
    final activeModels = ref.read(activeModelsProvider);
    final runtimeNotifier = ref.read(aiRuntimeProvider.notifier);
    final runtimeState = ref.read(aiRuntimeProvider);
    final tts = ref.read(ttsServiceProvider);
    final modelService = ref.read(modelServiceProvider);

    // Make sure we have a selected STT model and Chat model
    if (activeModels.sttModel == null || activeModels.chatModel == null) {
      throw Exception('Please select both a Chat and an STT model first.');
    }

    // Initialize the AI runtime with the selected Chat model if not initialized
    if (!runtimeState.isInitialized || runtimeState.currentModelId != activeModels.chatModel!.id) {
      final modelPath = await modelService.getModelPath(activeModels.chatModel!.id);
      final settings = ref.read(settingsProvider).value;

      await runtimeNotifier.initWithModel(
        modelPath: modelPath,
        modelId: activeModels.chatModel!.id,
        contextLength: settings?.contextLength ?? 2048,
        numThreads: settings?.numThreads ?? 4,
        useGpu: settings?.useGpu ?? true,
      );
    }

    // Re-read runtime state after init
    final currentRuntime = ref.read(aiRuntimeProvider);
    if (!currentRuntime.isInitialized || currentRuntime.chatSession == null) {
      throw Exception('Failed to initialize AI runtime for Voice.');
    }

    final settings = ref.read(settingsProvider).value;

    _pipeline = VoicePipeline(
      chatSession: currentRuntime.chatSession!,
      tts: tts.tts,
      whisperModelPath: await modelService.getModelPath(activeModels.sttModel!.id),
      scheduler: Scheduler(telemetry: TelemetryService()),
      config: VoicePipelineConfig(
        silenceDuration: Duration(milliseconds: settings?.voiceSilenceDuration ?? 1000),
      ),
    );

    _pipeline!.events.listen((event) {
      if (event is StateChanged) {
        state = state.copyWith(state: event.state);
      } else if (event is TranscriptUpdated) {
        state = state.copyWith(transcript: event.userText);
      }
    });

    await _pipeline!.start();
    state = state.copyWith(isRunning: true);
  }

  Future<void> stop() async {
    await _pipeline?.stop();
    _pipeline = null;
    state = VoiceState();
  }
}
