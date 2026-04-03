import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRuntimeServiceProvider = Provider<AiRuntimeService>((ref) => AiRuntimeService());

class AiRuntimeService {
  Future<void> loadModel(String modelId) async {}
  Future<Stream<String>> generateStream(String text) async => Stream.value("AI Runtime unavailable.");
}
