import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final runAnywhereServiceProvider = Provider<RunAnywhereService>((ref) => RunAnywhereService());

class RunAnywhereService {
  bool _initialized = false;
  VoiceSessionHandle? _voiceSession;

  Future<void> init() async {
    if (_initialized) return;
    await RunAnywhere.initialize();
    _initialized = true;
  }

  Future<void> loadModels() async {
    // Register and load models. Ensure IDs match registered models.
    await RunAnywhere.loadModel('llama3');
    // Using loadModel for STT/TTS as per generic API
    await RunAnywhere.loadModel('whisper');
  }

  Future<Stream<String>> chatStream(String prompt) async {
    final streamResult = await RunAnywhere.generateStream(prompt);
    return streamResult.stream;
  }

  Future<void> startVoiceSession(Function(String, String) onTurnCompleted) async {
    // startVoiceSession returns a VoiceSessionHandle.
    _voiceSession = await RunAnywhere.startVoiceSession();
  }

  Future<String> processVision(String imagePath, String prompt) async {
    return "Vision processing not directly supported by current RunAnywhere version.";
  }

  Future<void> speak(String text) async {
    // TTS synthesize returns a TTSResult.
    await RunAnywhere.synthesize(text);
  }

  void stopVoiceSession() {
    _voiceSession?.stop();
    _voiceSession = null;
  }
}
