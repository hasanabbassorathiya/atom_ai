import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRuntimeServiceProvider = Provider<AiRuntimeService>((ref) => AiRuntimeService());

<<<<<<< HEAD
class AiRuntimeService {
  Future<void> loadModel(String modelId) async {}
  Future<Stream<String>> generateStream(String text) async => Stream.value("AI Runtime unavailable.");
=======
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
    bool useGpu = false, // Changed from true to false for testing emulator
  }) async {
    if (state.isInitialized) {
      await _cleanup();
    }

    debugPrint('[AiRuntime] Initializing model with ID: $modelId, path: $modelPath');

    if (modelPath.isEmpty) {
      debugPrint('[AiRuntime] ERROR: Model path is empty!');
      throw const ConfigurationException('Model path is empty');
    }

    // Remove this faulty debug line which is causing syntax errors
    // debugPrint('[AiRuntime] Config: $config');
    final config = EdgeVedaConfig(
      modelPath: modelPath,
      contextLength: contextLength,
      numThreads: numThreads,
      useGpu: useGpu,
      flashAttn: 0, // Disable flash attention for compatibility
      kvCacheTypeK: 1, // F16
      kvCacheTypeV: 1, // F16
    );

    try {
      await _edgeVeda.init(config);
    } catch (e, stack) {
      debugPrint('[AiRuntime] CRITICAL ERROR: EdgeVeda.init failed: $e\n$stack');
      // final lastError = await _edgeVeda.getLastError();
      
      rethrow;
    }
    _edgeVeda.setScheduler(_scheduler);

    final tools = ToolRegistry([
      ToolDefinition(
        name: 'get_time',
        description: 'Get current local time for a specific city or timezone. Useful when user asks "what time is it in..."',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'City name or timezone (e.g., Tokyo, PST, London)',
            },
          },
          'required': ['location'],
        },
      ),
      ToolDefinition(
        name: 'get_weather',
        description: 'Get current weather conditions for a city.',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'The city and state, e.g. San Francisco, CA',
            },
          },
          'required': ['location'],
        },
      ),
    ]);

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

  void resetChat({String? systemPrompt}) {
    if (state.chatSession != null) {
      state.chatSession!.reset();
    }
    if (systemPrompt != null && state.isInitialized) {
      final chatSession = ChatSession(
        edgeVeda: _edgeVeda,
        systemPrompt: systemPrompt,
      );
      state = state.copyWith(chatSession: chatSession);
    }
  }

  Stream<TokenChunk> sendMessage(String text,
      {GenerateOptions? options}) async* {
    if (!state.isInitialized || state.chatSession == null) {
      throw const InitializationException('AI runtime not initialized');
    }
    if (state.isGenerating) {
      throw const GenerationException('Generation already in progress');
    }

    state = state.copyWith(isGenerating: true);

    try {
      await for (final chunk
          in state.chatSession!.sendStream(text, options: options)) {
        yield chunk;
      }
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<ChatMessage> sendWithTools(String text, {GenerateOptions? options}) async {
    if (!state.isInitialized || state.chatSession == null) {
      throw const InitializationException('AI runtime not initialized');
    }
    if (state.isGenerating) {
      throw const GenerationException('Generation already in progress');
    }

    state = state.copyWith(isGenerating: true);

    try {
      final reply = await state.chatSession!.sendWithTools(
        text,
        onToolCall: _handleToolCall,
        options: options,
      );
      return reply;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<ToolResult> _handleToolCall(ToolCall call) async {
    switch (call.name) {
      case 'get_time':
        final location = (call.arguments['location'] as String? ?? 'UTC').toLowerCase();
        final now = DateTime.now().toUtc();

        // Simple mapping for demo
        double offset = 0;
        if (location.contains('tokyo') || location.contains('japan')) { offset = 9; }
        else if (location.contains('london') || location.contains('uk')) { offset = 0; }
        else if (location.contains('new york') || location.contains('est')) { offset = -5; }
        else if (location.contains('san francisco') || location.contains('pst')) { offset = -8; }
        else if (location.contains('paris') || location.contains('berlin')) { offset = 1; }
        else if (location.contains('india') || location.contains('mumbai')) { offset = 5.5; }
        else if (location.contains('dubai')) { offset = 4; }

        final targetTime = now.add(Duration(
          hours: offset.truncate(),
          minutes: ((offset % 1) * 60).round(),
        ));

        return ToolResult.success(
          toolCallId: call.id,
          data: {
            'location': location,
            'time': '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}',
            'timezone_offset': offset >= 0 ? '+$offset' : offset.toString(),
            'date': targetTime.toIso8601String().split('T')[0],
          },
        );

      case 'get_weather':
        final location = call.arguments['location'] as String? ?? 'Unknown';

        // Mock weather data
        int temp = 22;
        String condition = "Sunny";

        if (location.toLowerCase().contains('london')) { temp = 12; condition = "Rainy"; }
        else if (location.toLowerCase().contains('san francisco')) { temp = 18; condition = "Foggy"; }
        else if (location.toLowerCase().contains('tokyo')) { temp = 25; condition = "Clear"; }

        return ToolResult.success(
          toolCallId: call.id,
          data: {
            'location': location,
            'temperature': '$temp°C',
            'condition': condition,
            'humidity': '45%',
            'wind': '12 km/h',
          },
        );

      default:
        return ToolResult.failure(
          toolCallId: call.id,
          error: 'Unknown tool: ${call.name}',
        );
    }
  }

  Future<MemoryStats> getMemoryStats() => _edgeVeda.getMemoryStats();

  Future<bool> isMemoryPressure() => _edgeVeda.isMemoryPressure();

  Future<void> _cleanup() async {
    await _edgeVeda.dispose();
    state = AiRuntimeState();
  }

  EdgeVeda get engine => _edgeVeda;

  bool get isInitialized => state.isInitialized;
  String? get currentModelId => state.currentModelId;
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
}
