import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';
import 'package:runanywhere_llamacpp/runanywhere_llamacpp.dart';
import 'package:runanywhere_onnx/runanywhere_onnx.dart';

final runAnywhereServiceProvider = Provider<RunAnywhereService>((ref) => RunAnywhereService());

class RunAnywhereService {
  bool _initialized = false;
  VoiceSession? _voiceSession;

  Future<void> init() async {
    if (_initialized) return;
    await RunAnywhere.initialize();
    await LlamaCpp.register();
    await Onnx.register();
    _initialized = true;
  }

  Future<void> loadModels() async {
    // Register and load models
    await LlamaCpp.addModel(id: 'llama3', name: 'Llama 3 8B', url: 'https://...', memoryRequirement: 8000000000);
    await Onnx.addModel(id: 'whisper', name: 'Whisper', url: 'https://...', modality: ModelCategory.speechRecognition);

    await RunAnywhere.loadModel('llama3');
    await RunAnywhere.loadSTTModel('whisper');
  }

  Future<Stream<String>> chatStream(String prompt) async {
    final streamResult = await RunAnywhere.generateStream(prompt);
    return streamResult.stream;
  }

  Future<void> startVoiceSession(Function(String, String) onTurnCompleted) async {
    _voiceSession = await RunAnywhere.startVoiceSession();
    _voiceSession!.events.listen((event) {
      if (event is VoiceSessionTurnCompleted) {
        onTurnCompleted(event.transcript, event.response);
      }
    });
  }

  Future<void> processVision(String imagePath, String prompt) async {
    // Actual implementation using RunAnywhere ONNX backend for vision
    final result = await RunAnywhere.generateVision(imagePath, prompt: prompt);
    await speak(result);
  }

  Future<void> speak(String text) async {
    await RunAnywhere.tts(text);
  }

  void stopVoiceSession() {
    _voiceSession?.stop();
    _voiceSession = null;
  }
}
