import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final edgeVedaServiceProvider = Provider<EdgeVedaService>((ref) => EdgeVedaService());

class EdgeVedaService {
  final _edgeVeda = EdgeVeda();
  final _modelManager = ModelManager();

  // Services
  late final TtsService tts;
  late final VisionWorker visionWorker;

  EdgeVedaService() {
    tts = TtsService();
    visionWorker = VisionWorker();
  }

  // Session
  ChatSession? _chatSession;
  ChatSession? get chatSession => _chatSession;

  Future<void> init(String modelPath) async {
    await _edgeVeda.init(EdgeVedaConfig(
      modelPath: modelPath,
      useGpu: true,
    ));
    _chatSession = ChatSession(edgeVeda: _edgeVeda);
    await visionWorker.spawn();
    // Initialize TTS here if needed, or lazy-load
  }

  // STT Helper
  Future<WhisperSession> createWhisperSession(String modelPath) async {
    return WhisperSession(modelPath: modelPath, useGpu: true);
  }

  Future<void> dispose() async {
    await _edgeVeda.dispose();
    await _modelManager.dispose();
    await visionWorker.dispose();
    await tts.dispose();
  }
}
