import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ttsServiceProvider = Provider<TtsServiceWrapper>((ref) => TtsServiceWrapper());

class TtsServiceWrapper {
  final TtsService tts = TtsService();

  Future<void> speak(String text) async {
    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }

  Future<void> dispose() async {
    // TtsService does not have a dispose method
  }
}
