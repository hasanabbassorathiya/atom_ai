import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edge_veda/edge_veda.dart';

class AiRuntimeState {
  final bool isInitialized;
  final bool isGenerating;
  final String? currentModelId;
  final ChatSession? chatSession;

  AiRuntimeState({
    this.isInitialized = false,
    this.isGenerating = false,
    this.currentModelId,
    this.chatSession,
  });

  AiRuntimeState copyWith({
    bool? isInitialized,
    bool? isGenerating,
    String? currentModelId,
    ChatSession? chatSession,
  }) {
    return AiRuntimeState(
      isInitialized: isInitialized ?? this.isInitialized,
      isGenerating: isGenerating ?? this.isGenerating,
      currentModelId: currentModelId ?? this.currentModelId,
      chatSession: chatSession ?? this.chatSession,
    );
  }
}

class AiRuntimeNotifier extends Notifier<AiRuntimeState> {
  final EdgeVeda _edgeVeda = EdgeVeda();
  late final TelemetryService _telemetry = TelemetryService();
  late final Scheduler _scheduler = Scheduler(telemetry: _telemetry);

  @override
  AiRuntimeState build() => AiRuntimeState();

  Future<void> initWithModel({
    required String modelPath,
    required String modelId,
    int contextLength = 2048,
    int numThreads = 4,
    bool useGpu = false,
  }) async {
    if (state.isInitialized) {
      await _cleanup();
    }

    final config = EdgeVedaConfig(
      modelPath: modelPath,
      contextLength: contextLength,
      numThreads: numThreads,
      useGpu: useGpu,
      flashAttn: 0,
      kvCacheTypeK: 1,
      kvCacheTypeV: 1,
    );

    await _edgeVeda.init(config);
    _edgeVeda.setScheduler(_scheduler);

    final tools = ToolRegistry([]); // Add tools as needed

    final chatSession = ChatSession(
      edgeVeda: _edgeVeda,
      preset: SystemPromptPreset.assistant,
      tools: tools,
    );

    state = state.copyWith(
      isInitialized: true,
      currentModelId: modelId,
      chatSession: chatSession,
    );
  }

  Future<void> _cleanup() async {
    await _edgeVeda.dispose();
    state = AiRuntimeState();
  }
}

final aiRuntimeServiceProvider = NotifierProvider<AiRuntimeNotifier, AiRuntimeState>(AiRuntimeNotifier.new);
