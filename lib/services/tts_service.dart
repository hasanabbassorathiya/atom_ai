import 'package:runanywhere/runanywhere.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());

class TtsService {
  Future<void> speak(String text) async {
    // TTS synthesize returns a TTSResult.
    await RunAnywhere.synthesize(text);
  }

  Future<void> stop() async {
    // RunAnywhere SDK does not provide stopTts directly.
    // Assuming TTS stops automatically or is non-interruptible.
  }
}
