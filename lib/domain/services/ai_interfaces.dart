import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';

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
  bool get isImageInitialized;
  String? get currentModelId;
  Future<void> initVision({required String modelId, String? modelPath, String? mmprojPath});
  Future<String> describeImage(Uint8List rgbBytes, {required int width, required int height});
  Future<void> initImage({required String modelId, String? modelPath});
  Future<Uint8List> generateImage(String prompt, {required ImageGenerationConfig config, Function(ImageProgress)? onProgress});
}

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
}
