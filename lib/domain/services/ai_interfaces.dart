abstract class ChatService {
  Future<Stream<String>> chatStream(String prompt);
}

abstract class VoiceService {
  bool get isRunning;
  String get transcript;
  Future<void> startVoiceSession(Function(String, String) onTurnCompleted);
  void stopVoiceSession();
}

abstract class VisionService {
  bool get isVisionInitialized;
  Future<void> initVision({required String modelId});
  Future<String> describeImage(String imagePath, {String prompt = 'Describe this image.'});
  // Added methods required by UI
  Future<void> initImage({required String modelId});
  Future<String> generateImage(String prompt);
}

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
}
